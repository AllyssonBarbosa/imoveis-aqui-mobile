import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/ordenacao_vitrine.dart';
import '../../domain/usecases/buscar_imoveis_usecase.dart';
import 'sessao_filtros_vitrine.dart';
import 'vitrine_state.dart';

/// Orquestra o carregamento da vitrine (VIT-01). Token de versão
/// (`_versaoConsulta`, D-13) descarta respostas obsoletas quando a cidade
/// muda com uma consulta em voo, e a checagem de `isClosed` garante que
/// nenhum `emit` acontece depois de `close()` (T-02-01-04).
///
/// [SessaoFiltrosVitrine] (Task 2, D-14, D-23) sobrevive à troca de cidade
/// mesmo que este Cubit seja recriado do zero — é ela quem fornece os
/// filtros da PRIMEIRA consulta de uma cidade recém-aberta (`carregar`) e
/// quem registra os filtros de toda consulta reiniciada
/// (`_aplicarConsulta`), nunca o inverso.
@injectable
class VitrineCubit extends Cubit<VitrineState> {
  VitrineCubit(this._buscarImoveis, this._sessaoFiltros)
    : super(const VitrineState());

  final BuscarImoveisUseCase _buscarImoveis;
  final SessaoFiltrosVitrine _sessaoFiltros;

  Cidade? _cidade;
  int _versaoConsulta = 0;

  /// Debounce da busca por texto (D-08) — `Timer` próprio, sem
  /// `easy_debounce` (CLAUDE.md); cancelado a cada nova tecla e em [close].
  Timer? _debounce;

  /// Ponto de entrada — chamado ao montar a vitrine para a cidade escolhida.
  /// A PRIMEIRA consulta parte de [SessaoFiltrosVitrine.filtrosPara] (D-14):
  /// cidade nunca vista nesta sessão -> filtro vazio (igual ao comportamento
  /// da F2); mesma sessão de uma cidade já filtrada -> os filtros gerais
  /// sobrevivem (sem bairros de outra cidade).
  void carregar(Cidade cidade) {
    _cidade = cidade;
    unawaited(
      _aplicarConsulta(
        ordenacao: state.ordenacao,
        termoBusca: state.termoBusca,
        filtros: _sessaoFiltros.filtrosPara(cidade),
      ),
    );
  }

  /// Busca por texto (VIT-03) com debounce de 400 ms a partir de 2
  /// caracteres (D-08): cancela qualquer debounce pendente a cada chamada;
  /// campo vazio (após `trim`) volta à lista completa IMEDIATAMENTE, sem
  /// esperar o debounce, mas só dispara se havia um termo aplicado; menos de
  /// 2 caracteres não dispara nada e a lista atual continua; o mesmo termo já
  /// aplicado nunca gera uma nova chamada (idempotência).
  void buscar(String texto) {
    _debounce?.cancel();
    final termo = texto.trim();

    if (termo.isEmpty) {
      if (state.termoBusca != null) {
        unawaited(
          _aplicarConsulta(
            ordenacao: state.ordenacao,
            termoBusca: null,
            filtros: state.filtros,
          ),
        );
      }
      return;
    }

    if (termo.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (termo == state.termoBusca) return;
      unawaited(
        _aplicarConsulta(
          ordenacao: state.ordenacao,
          termoBusca: termo,
          filtros: state.filtros,
        ),
      );
    });
  }

  /// Limpa a busca imediatamente (botão "Limpar busca", D-09) — mesmo efeito
  /// de apagar o campo por completo em [buscar], mas chamado diretamente
  /// pela UI (ex.: toque no "X" da `SearchBar` ou no botão do estado
  /// sem-resultado).
  void limparBusca() {
    _debounce?.cancel();
    if (state.termoBusca != null) {
      unawaited(
        _aplicarConsulta(
          ordenacao: state.ordenacao,
          termoBusca: null,
          filtros: state.filtros,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  /// Ordena a vitrine (VIT-04) — sem efeito quando [ordenacao] já é a atual
  /// (idempotência, mesma disciplina de [buscar]); caso contrário reinicia a
  /// lista do topo (D-13) via [_aplicarConsulta], preservando o termo de
  /// busca aplicado. O token de versão bumped por [_aplicarConsulta] também
  /// invalida qualquer `carregarMais()` em voo.
  Future<void> ordenarPor(OrdenacaoVitrine ordenacao) {
    if (ordenacao == state.ordenacao) return Future<void>.value();
    return _aplicarConsulta(
      ordenacao: ordenacao,
      termoBusca: state.termoBusca,
      filtros: state.filtros,
    );
  }

  /// Aplica um novo conjunto de filtros (FIL-01..FIL-06) — sem efeito quando
  /// igual ao já aplicado (idempotência, mesma disciplina de [ordenarPor]);
  /// caso contrário reinicia a lista do topo (D-19) via [_aplicarConsulta],
  /// preservando `ordenacao`/`termoBusca`. Nunca reimplementa o reinício
  /// (RESEARCH Pitfall 2) — [removerFiltro]/[limparFiltros] também delegam
  /// aqui.
  Future<void> aplicarFiltros(FiltrosVitrine filtros) {
    if (filtros == state.filtros) return Future<void>.value();
    return _aplicarConsulta(
      ordenacao: state.ordenacao,
      termoBusca: state.termoBusca,
      filtros: filtros,
    );
  }

  /// "x" do chip (D-17) — remove só a dimensão [filtro] e reconsulta na
  /// hora, sem passar pelo sheet; busca e ordenação continuam intactas.
  Future<void> removerFiltro(FiltroAtivo filtro) =>
      aplicarFiltros(state.filtros.semFiltro(filtro));

  /// `ActionChip` "Limpar filtros" (D-18) — zera TODOS os filtros na hora;
  /// busca e ordenação continuam intactas (D-18 — nenhum dos dois "Limpar"
  /// mexe nelas).
  Future<void> limparFiltros() => aplicarFiltros(const FiltrosVitrine());

  /// Botão "Limpar busca e filtros" do estado vazio-com-filtros-e-busca
  /// (D-22) — cancela um debounce de busca pendente e faz EXATAMENTE uma
  /// consulta, sem termo e sem filtros, pelo mesmo caminho de reinício
  /// (D-19); nunca dois emits/duas chamadas separadas.
  void limparBuscaEFiltros() {
    _debounce?.cancel();
    unawaited(
      _aplicarConsulta(
        ordenacao: state.ordenacao,
        termoBusca: null,
        filtros: const FiltrosVitrine(),
      ),
    );
  }

  /// Refaz a consulta atual — usado pelo "Tentar de novo" tanto no erro da
  /// primeira página ([VitrineErro]) quanto no erro de "carregar mais"
  /// ([VitrineCarregada.erroAoCarregarMais]). Retry é sempre explícito: o
  /// scroll nunca redispara sozinho depois de uma falha (T-02-03-01).
  void tentarNovamente() {
    final conteudo = state.conteudo;
    if (conteudo is VitrineErro) {
      unawaited(_reiniciar());
    } else if (conteudo is VitrineCarregada && conteudo.erroAoCarregarMais) {
      unawaited(_carregarProximaPagina());
    }
  }

  /// Pede a próxima página (scroll infinito, VIT-05/D-13) — chamada pelo
  /// listener do `ScrollController` a 90% do fim da lista. Sem efeito fora
  /// de [VitrineCarregada], enquanto já há uma página em voo
  /// (`carregandoMais`), depois de uma falha de "carregar mais"
  /// (`erroAoCarregarMais` — retry é só via [tentarNovamente]) ou quando não
  /// há próxima página (`proximaPagina == null`).
  Future<void> carregarMais() async {
    final conteudo = state.conteudo;
    if (conteudo is! VitrineCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;
    await _carregarProximaPagina();
  }

  /// Busca a página apontada por `proximaPagina` e a acrescenta aos itens já
  /// visíveis — nunca os substitui nem os descarta em caso de falha
  /// (prohibition do plano: uma falha ao carregar mais nunca derruba a
  /// lista visível). Reaproveitada por [carregarMais] e por
  /// [tentarNovamente] quando o erro é de "carregar mais".
  Future<void> _carregarProximaPagina() async {
    final conteudo = state.conteudo;
    if (conteudo is! VitrineCarregada) return;
    final proximaPagina = conteudo.proximaPagina;
    if (proximaPagina == null) return;

    // Captura a versão vigente SEM incrementar (D-13) — um reinício em
    // paralelo (troca de cidade/busca/ordenação) incrementa `_versaoConsulta`
    // em `_reiniciar`, invalidando esta requisição quando ela responder.
    final minhaVersao = _versaoConsulta;
    emit(
      state.copyWith(
        conteudo: conteudo.copyWith(
          carregandoMais: true,
          erroAoCarregarMais: false,
        ),
      ),
    );

    final resultado = await _buscarImoveis.proximaPagina(proximaPagina);

    // Resposta obsoleta (consulta reiniciada nesse meio-tempo) ou Cubit
    // fechado enquanto a página estava em voo — nunca emitir (D-13,
    // T-02-03-04).
    if (minhaVersao != _versaoConsulta || isClosed) return;

    final conteudoAtual = state.conteudo;
    if (conteudoAtual is! VitrineCarregada) return;

    switch (resultado) {
      case Success(:final data):
        emit(
          state.copyWith(
            conteudo: conteudoAtual.copyWith(
              itens: [...conteudoAtual.itens, ...data.itens],
              proximaPagina: data.proximaPagina,
              carregandoMais: false,
            ),
          ),
        );
      case Failure():
        emit(
          state.copyWith(
            conteudo: conteudoAtual.copyWith(
              carregandoMais: false,
              erroAoCarregarMais: true,
            ),
          ),
        );
      case Loading():
        break;
    }
  }

  /// Refaz a consulta atual (mesmos `ordenacao`/`termoBusca`/`filtros` do
  /// estado) — usada por [tentarNovamente] no caminho de erro da primeira
  /// página. Delega a [_aplicarConsulta].
  Future<void> _reiniciar() => _aplicarConsulta(
    ordenacao: state.ordenacao,
    termoBusca: state.termoBusca,
    filtros: state.filtros,
  );

  /// Reinicia a lista do topo (D-13/D-19) com uma nova combinação de
  /// `ordenacao`/`termoBusca`/`filtros`: incrementa o token de versão
  /// (descarta qualquer resposta em voo — inclusive um `carregarMais()` —
  /// de uma consulta anterior), emite UM único estado de loading
  /// (descartando cursor/itens antigos) e então busca a primeira página.
  /// Usada por [carregar] (filtros da sessão), [_reiniciar] (mesmos valores
  /// do estado), [buscar]/[limparBusca] (novo `termoBusca`), `ordenarPor`
  /// (nova `ordenacao`) e [aplicarFiltros] (novo `filtros`) — nenhum caminho
  /// reimplementa este reinício (RESEARCH Pitfall 2).
  ///
  /// Registra [filtros] em [SessaoFiltrosVitrine.lembrar] JUNTO com o emit de
  /// `carregando` (D-14) — a memória sempre reflete os filtros da ÚLTIMA
  /// consulta disparada, mesmo que o Cubit feche antes dela responder.
  Future<void> _aplicarConsulta({
    required OrdenacaoVitrine ordenacao,
    required String? termoBusca,
    required FiltrosVitrine filtros,
  }) async {
    final cidade = _cidade;
    if (cidade == null) return;

    _sessaoFiltros.lembrar(cidade, filtros);

    final minhaVersao = ++_versaoConsulta;
    emit(
      state.copyWith(
        ordenacao: ordenacao,
        termoBusca: termoBusca,
        filtros: filtros,
        conteudo: const ConteudoVitrine.carregando(),
      ),
    );

    final resultado = await _buscarImoveis(
      ConsultaImoveis(
        cidade: cidade,
        busca: termoBusca,
        ordenacao: ordenacao,
        filtros: filtros,
      ),
    );

    // Resposta obsoleta (nova consulta disparada nesse meio-tempo) ou Cubit
    // fechado enquanto a busca estava em voo — nunca emitir (D-13).
    if (minhaVersao != _versaoConsulta || isClosed) return;

    switch (resultado) {
      case Success(:final data):
        // 4 combinações (D-22): filtros ativos vencem (com ou sem busca —
        // o "termo" viaja junto para a mensagem combinada); senão só busca
        // (F2/D-09); senão nem um nem outro (F2/D-15).
        if (data.itens.isEmpty && filtros.quantidadeAtiva > 0) {
          emit(
            state.copyWith(
              conteudo: ConteudoVitrine.semResultadoComFiltros(
                termo: termoBusca,
              ),
            ),
          );
        } else if (data.itens.isEmpty && termoBusca != null) {
          emit(
            state.copyWith(conteudo: ConteudoVitrine.semResultado(termoBusca)),
          );
        } else if (data.itens.isEmpty) {
          emit(
            state.copyWith(conteudo: const ConteudoVitrine.vazioNaCidade()),
          );
        } else {
          emit(
            state.copyWith(
              conteudo: ConteudoVitrine.carregada(
                itens: data.itens,
                proximaPagina: data.proximaPagina,
              ),
            ),
          );
        }
      case Failure():
        emit(state.copyWith(conteudo: const ConteudoVitrine.erro()));
      case Loading():
        break;
    }
  }
}
