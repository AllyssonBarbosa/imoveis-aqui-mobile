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

  /// "Tentar de novo" da falha na primeira página — só age a partir do erro:
  /// antes de `carregar`, durante o carregamento, com a lista ou o vazio na
  /// tela, repetir não faz sentido (sem busca dupla num toque duplo).
  Future<void> tentarNovamente() async {
    final anunciante = _anunciante;
    if (isClosed || anunciante == null || state is! VitrineAnuncianteErro) {
      return;
    }
    emit(const VitrineAnuncianteState.carregando());
    await _buscarPrimeiraPagina(anunciante);
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
