import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/ordenacao_vitrine.dart';
import '../../domain/usecases/buscar_imoveis_usecase.dart';
import 'vitrine_state.dart';

/// Orquestra o carregamento da vitrine (VIT-01). Token de versão
/// (`_versaoConsulta`, D-13) descarta respostas obsoletas quando a cidade
/// muda com uma consulta em voo, e a checagem de `isClosed` garante que
/// nenhum `emit` acontece depois de `close()` (T-02-01-04).
@injectable
class VitrineCubit extends Cubit<VitrineState> {
  VitrineCubit(this._buscarImoveis) : super(const VitrineState());

  final BuscarImoveisUseCase _buscarImoveis;

  Cidade? _cidade;
  int _versaoConsulta = 0;

  /// Debounce da busca por texto (D-08) — `Timer` próprio, sem
  /// `easy_debounce` (CLAUDE.md); cancelado a cada nova tecla e em [close].
  Timer? _debounce;

  /// Ponto de entrada — chamado ao montar a vitrine para a cidade escolhida.
  void carregar(Cidade cidade) {
    _cidade = cidade;
    unawaited(_reiniciar());
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
          _aplicarConsulta(ordenacao: state.ordenacao, termoBusca: null),
        );
      }
      return;
    }

    if (termo.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (termo == state.termoBusca) return;
      unawaited(
        _aplicarConsulta(ordenacao: state.ordenacao, termoBusca: termo),
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
        _aplicarConsulta(ordenacao: state.ordenacao, termoBusca: null),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
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

  /// Refaz a consulta atual (mesmos `ordenacao`/`termoBusca` do estado) —
  /// usada por [carregar]. Delega a [_aplicarConsulta].
  Future<void> _reiniciar() =>
      _aplicarConsulta(ordenacao: state.ordenacao, termoBusca: state.termoBusca);

  /// Reinicia a lista do topo (D-13) com uma nova combinação de
  /// `ordenacao`/`termoBusca`: incrementa o token de versão (descarta
  /// qualquer resposta em voo — inclusive um `carregarMais()` — de uma
  /// consulta anterior), emite UM único estado de loading (descartando
  /// cursor/itens antigos) e então busca a primeira página. Usada por
  /// [_reiniciar] (mesmos valores do estado), [buscar]/[limparBusca] (novo
  /// `termoBusca`, mesma `ordenacao`) e `ordenarPor` (nova `ordenacao`, mesmo
  /// `termoBusca`).
  Future<void> _aplicarConsulta({
    required OrdenacaoVitrine ordenacao,
    required String? termoBusca,
  }) async {
    final cidade = _cidade;
    if (cidade == null) return;

    final minhaVersao = ++_versaoConsulta;
    emit(
      state.copyWith(
        ordenacao: ordenacao,
        termoBusca: termoBusca,
        conteudo: const ConteudoVitrine.carregando(),
      ),
    );

    final resultado = await _buscarImoveis(
      ConsultaImoveis(cidade: cidade, busca: termoBusca, ordenacao: ordenacao),
    );

    // Resposta obsoleta (nova consulta disparada nesse meio-tempo) ou Cubit
    // fechado enquanto a busca estava em voo — nunca emitir (D-13).
    if (minhaVersao != _versaoConsulta || isClosed) return;

    switch (resultado) {
      case Success(:final data):
        if (data.itens.isEmpty && termoBusca != null) {
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
