import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/consulta_acervo.dart';
import '../../domain/entities/situacao_imovel.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/usecases/buscar_acervo_usecase.dart';
import 'acervo_state.dart';

/// Orquestra a tela "Meu acervo" (ACV-01, ACV-02, ACV-04). Não filtra, não
/// ordena e não decide nada de negócio: repassa a consulta ao use case e
/// mostra a página como o servidor entregou. Decide só pelo TIPO da falha
/// (`SessaoExpiradaException` vira o estado de sessão terminada).
///
/// Token de versão (`_versaoConsulta`) descarta respostas obsoletas quando uma
/// consulta nova sai com outra em voo (T-08-36), e `isClosed` é conferido
/// antes de todo `emit`.
@injectable
class AcervoCubit extends Cubit<AcervoState> {
  AcervoCubit(this._buscarAcervo) : super(const AcervoState());

  final BuscarAcervoUseCase _buscarAcervo;

  int _versaoConsulta = 0;

  /// Atraso da busca por texto (D-08) — `Timer` próprio, igual ao da vitrine;
  /// cancelado a cada nova tecla e em [close].
  Timer? _debounce;

  /// Ponto de entrada — chamado ao montar a tela: busca a primeira página com
  /// a busca e a situação atuais (por padrão, sem nenhuma).
  void carregar() {
    unawaited(_aplicarConsulta(state.termoBusca, state.situacao));
  }

  /// Relê a primeira página mantendo a busca e a situação atuais (D-12) —
  /// chamado quando a gestão de um imóvel devolve "mudou". O chip do cartão
  /// passa a ser o que o servidor mandar; o app não altera o item. Volta ao
  /// topo com o carregando (comportamento aceito).
  void recarregar() {
    unawaited(_aplicarConsulta(state.termoBusca, state.situacao));
  }

  /// Busca por texto (D-08): 400 ms depois da última tecla, a partir de 1
  /// caractere (os códigos do acervo, como `DEV-CAMPINAS-14`, pedem busca
  /// curta). Apagar tudo (após `trim`) volta à lista completa na hora, mas só
  /// dispara se havia um termo aplicado; o mesmo termo já aplicado não gera
  /// nova chamada.
  void buscar(String texto) {
    _debounce?.cancel();
    final termo = texto.trim();

    if (termo.isEmpty) {
      if (state.termoBusca.isNotEmpty) {
        unawaited(_aplicarConsulta('', state.situacao));
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (termo == state.termoBusca) return;
      unawaited(_aplicarConsulta(termo, state.situacao));
    });
  }

  /// Limpa a busca na hora (botão "Limpar busca") — mesmo efeito de apagar o
  /// campo por completo em [buscar].
  void limparBusca() {
    _debounce?.cancel();
    if (state.termoBusca.isNotEmpty) {
      unawaited(_aplicarConsulta('', state.situacao));
    }
  }

  /// Troca a situação dos chips (D-09) na hora, mantendo a busca aplicada.
  /// `null` é "Todas". Escolher a situação que já está ativa não faz nada.
  Future<void> escolherSituacao(SituacaoImovel? situacao) {
    if (situacao == state.situacao) return Future<void>.value();
    return _aplicarConsulta(state.termoBusca, situacao);
  }

  /// Refaz a consulta atual depois de uma falha — na primeira página repete a
  /// consulta; em "carregar mais" repete a MESMA página pendente. Retry é
  /// sempre explícito: a rolagem nunca redispara sozinha depois de uma falha.
  Future<void> tentarNovamente() async {
    final conteudo = state.conteudo;
    if (conteudo is AcervoErro) {
      await _aplicarConsulta(state.termoBusca, state.situacao);
    } else if (conteudo is AcervoCarregada && conteudo.erroAoCarregarMais) {
      await _carregarProximaPagina();
    }
  }

  /// Pede a próxima página (rolagem infinita, D-10) — sem efeito fora de
  /// [AcervoCarregada], com uma página já em voo, depois de uma falha (o
  /// retry é só por [tentarNovamente]) ou sem próxima página.
  Future<void> carregarMais() async {
    final conteudo = state.conteudo;
    if (conteudo is! AcervoCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;
    await _carregarProximaPagina();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  /// Acrescenta a página apontada por `proximaPagina` sem substituir nem
  /// descartar os itens já visíveis. Um id já listado não entra de novo
  /// (integridade da lista, não filtro de negócio); a ordem é a do servidor.
  Future<void> _carregarProximaPagina() async {
    final conteudo = state.conteudo;
    if (conteudo is! AcervoCarregada) return;
    final proximaPagina = conteudo.proximaPagina;
    if (proximaPagina == null) return;

    // Captura a versão vigente SEM incrementar: uma consulta nova (busca ou
    // situação) incrementa `_versaoConsulta` e invalida esta página em voo.
    final minhaVersao = _versaoConsulta;
    emit(
      state.copyWith(
        conteudo: conteudo.copyWith(
          carregandoMais: true,
          erroAoCarregarMais: false,
        ),
      ),
    );

    final resultado = await _buscarAcervo.seguir(proximaPagina);

    if (minhaVersao != _versaoConsulta || isClosed) return;
    final conteudoAtual = state.conteudo;
    if (conteudoAtual is! AcervoCarregada) return;

    switch (resultado) {
      case Success(:final data):
        final idsListados = conteudoAtual.itens.map((i) => i.id).toSet();
        final novos = data.itens.where((i) => !idsListados.contains(i.id));
        emit(
          state.copyWith(
            conteudo: conteudoAtual.copyWith(
              itens: [...conteudoAtual.itens, ...novos],
              proximaPagina: data.proximaPagina,
              carregandoMais: false,
            ),
          ),
        );
      case Failure(:final erro):
        if (erro is SessaoExpiradaException) {
          emit(state.copyWith(conteudo: const ConteudoAcervo.sessaoExpirada()));
        } else {
          emit(
            state.copyWith(
              conteudo: conteudoAtual.copyWith(
                carregandoMais: false,
                erroAoCarregarMais: true,
              ),
            ),
          );
        }
      case Loading():
        break;
    }
  }

  /// Reinicia a lista do topo com uma nova combinação de busca e situação:
  /// incrementa o token de versão (descarta qualquer resposta em voo), emite
  /// UM estado de carregamento e busca a primeira página.
  Future<void> _aplicarConsulta(
    String termoBusca,
    SituacaoImovel? situacao,
  ) async {
    final minhaVersao = ++_versaoConsulta;
    emit(
      AcervoState(
        termoBusca: termoBusca,
        situacao: situacao,
        conteudo: const ConteudoAcervo.carregando(),
      ),
    );

    final resultado = await _buscarAcervo(
      ConsultaAcervo(busca: termoBusca, situacao: situacao),
    );

    if (minhaVersao != _versaoConsulta || isClosed) return;

    switch (resultado) {
      case Success(:final data):
        if (data.itens.isNotEmpty) {
          emit(
            state.copyWith(
              conteudo: ConteudoAcervo.carregada(
                itens: data.itens,
                proximaPagina: data.proximaPagina,
              ),
            ),
          );
        } else if (termoBusca.isNotEmpty || situacao != null) {
          emit(state.copyWith(conteudo: const ConteudoAcervo.semResultado()));
        } else {
          emit(state.copyWith(conteudo: const ConteudoAcervo.vazio()));
        }
      case Failure(:final erro):
        emit(
          state.copyWith(
            conteudo: erro is SessaoExpiradaException
                ? const ConteudoAcervo.sessaoExpirada()
                : const ConteudoAcervo.erro(),
          ),
        );
      case Loading():
        break;
    }
  }
}
