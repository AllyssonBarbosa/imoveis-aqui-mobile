import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/anunciante_ref.dart';
import '../../domain/usecases/buscar_imoveis_do_anunciante_usecase.dart';
import 'vitrine_anunciante_state.dart';

/// Carrega a vitrine de imóveis de UM anunciante — criado junto com a página
/// do perfil (via `BlocProvider`, preguiçoso: só nasce com o perfil já
/// carregado). Não filtra nem reordena: mostra a página como o repositório
/// entregou. A checagem de `isClosed` garante que nenhum `emit` acontece
/// depois de `close()`.
@injectable
class VitrineAnuncianteCubit extends Cubit<VitrineAnuncianteState> {
  VitrineAnuncianteCubit(this._buscarImoveis)
    : super(const VitrineAnuncianteState.carregando());

  final BuscarImoveisDoAnuncianteUseCase _buscarImoveis;

  AnuncianteRef? _anunciante;

  /// Ponto de entrada — guarda o [anunciante] e busca a primeira página.
  Future<void> carregar(AnuncianteRef anunciante) {
    _anunciante = anunciante;
    return _buscarPrimeiraPagina(anunciante);
  }

  /// "Tentar de novo" — atende os dois erros: a falha da primeira página
  /// (repete a busca) e a falha de "carregar mais" (repete a MESMA página
  /// pendente, mesma URL). Antes de `carregar`, durante o carregamento,
  /// com a lista sem erro ou o vazio na tela, repetir não faz sentido (sem
  /// busca dupla num toque duplo). Retry é sempre explícito: a rolagem nunca
  /// redispara sozinha depois de uma falha (T-02-03-01).
  Future<void> tentarNovamente() async {
    if (isClosed) return;
    final atual = state;
    if (atual is VitrineAnuncianteCarregada && atual.erroAoCarregarMais) {
      await _carregarProximaPagina();
      return;
    }
    final anunciante = _anunciante;
    if (anunciante == null || atual is! VitrineAnuncianteErro) return;
    emit(const VitrineAnuncianteState.carregando());
    await _buscarPrimeiraPagina(anunciante);
  }

  /// Pede a próxima página (rolagem infinita, PERF-03/D-12) — chamada pelo
  /// gatilho de rolagem a 90% do fim. Sem efeito fora de
  /// [VitrineAnuncianteCarregada], com uma página já em voo
  /// (`carregandoMais`), depois de uma falha (`erroAoCarregarMais` — o retry
  /// é só por [tentarNovamente]) ou sem próxima página.
  Future<void> carregarMais() async {
    final atual = state;
    if (atual is! VitrineAnuncianteCarregada) return;
    if (atual.carregandoMais || atual.erroAoCarregarMais) return;
    if (atual.proximaPagina == null) return;
    await _carregarProximaPagina();
  }

  /// Busca a página apontada por `proximaPagina` (próxima página — URL `next`
  /// do `PageNumberPagination`, opaca para o app: o Cubit só a repassa) e a
  /// acrescenta aos itens visíveis, sem substituí-los nem
  /// descartá-los em caso de falha. Não há token de versão: o anunciante de
  /// um Cubit nunca muda.
  Future<void> _carregarProximaPagina() async {
    final atual = state;
    if (atual is! VitrineAnuncianteCarregada) return;
    final proximaPagina = atual.proximaPagina;
    if (proximaPagina == null) return;

    emit(atual.copyWith(carregandoMais: true, erroAoCarregarMais: false));

    final resultado = await _buscarImoveis.proximaPagina(proximaPagina);

    // Cubit fechado com a página em voo: nunca emitir.
    if (isClosed) return;
    final atualizado = state;
    if (atualizado is! VitrineAnuncianteCarregada) return;

    switch (resultado) {
      case Success(:final data):
        // Integridade da lista (não é filtro de negócio): se o acervo mudou
        // entre as páginas, um id já exibido não entra de novo. A ordem é a
        // do servidor.
        final idsListados = atualizado.itens.map((i) => i.id).toSet();
        final novos = data.itens.where((i) => !idsListados.contains(i.id));
        emit(
          atualizado.copyWith(
            itens: [...atualizado.itens, ...novos],
            proximaPagina: data.proximaPagina,
            carregandoMais: false,
          ),
        );
      case Failure():
        emit(
          atualizado.copyWith(carregandoMais: false, erroAoCarregarMais: true),
        );
      case Loading():
        break;
    }
  }

  Future<void> _buscarPrimeiraPagina(AnuncianteRef anunciante) async {
    final resultado = await _buscarImoveis(anunciante);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(
          data.itens.isEmpty
              ? const VitrineAnuncianteState.vazia()
              : VitrineAnuncianteState.carregada(
                  itens: data.itens,
                  proximaPagina: data.proximaPagina,
                ),
        );
      case Failure():
        emit(const VitrineAnuncianteState.erro());
      case Loading():
        break;
    }
  }
}
