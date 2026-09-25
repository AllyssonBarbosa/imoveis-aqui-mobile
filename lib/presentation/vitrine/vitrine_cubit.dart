import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
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

  /// Ponto de entrada — chamado ao montar a vitrine para a cidade escolhida.
  void carregar(Cidade cidade) {
    _cidade = cidade;
    unawaited(_reiniciar());
  }

  /// Refaz a consulta atual — usado pelo "Tentar de novo" no estado
  /// [VitrineErro].
  void tentarNovamente() {
    if (state.conteudo is! VitrineErro) return;
    unawaited(_reiniciar());
  }

  Future<void> _reiniciar() async {
    final cidade = _cidade;
    if (cidade == null) return;

    final minhaVersao = ++_versaoConsulta;
    emit(state.copyWith(conteudo: const ConteudoVitrine.carregando()));

    final resultado = await _buscarImoveis(
      ConsultaImoveis(
        cidade: cidade,
        busca: state.termoBusca,
        ordenacao: state.ordenacao,
      ),
    );

    // Resposta obsoleta (nova consulta disparada nesse meio-tempo) ou Cubit
    // fechado enquanto a busca estava em voo — nunca emitir (D-13).
    if (minhaVersao != _versaoConsulta || isClosed) return;

    switch (resultado) {
      case Success(:final data):
        if (data.itens.isEmpty && state.termoBusca != null) {
          emit(
            state.copyWith(
              conteudo: ConteudoVitrine.semResultado(state.termoBusca!),
            ),
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
