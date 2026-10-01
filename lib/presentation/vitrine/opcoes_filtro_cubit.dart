import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/usecases/obter_bairros_usecase.dart';
import '../../domain/usecases/obter_caracteristicas_usecase.dart';
import 'opcoes_filtro_state.dart';

/// Carrega as opções de bairro/característica de UMA cidade (D-20) — criado
/// por cidade (lazy, via `BlocProvider`) ao lado do `VitrineCubit`;
/// `carregar` dispara as duas dimensões concorrentemente, cada uma emitindo
/// só o seu próprio campo; `tentarNovamente` recarrega só as dimensões em
/// `falha`. A checagem de `isClosed` garante que nenhum `emit` acontece
/// depois de `close()` (mesma disciplina de `VitrineCubit`).
@injectable
class OpcoesFiltroCubit extends Cubit<OpcoesFiltroState> {
  OpcoesFiltroCubit(this._obterBairros, this._obterCaracteristicas)
    : super(const OpcoesFiltroState());

  final ObterBairrosUseCase _obterBairros;
  final ObterCaracteristicasUseCase _obterCaracteristicas;

  Cidade? _cidade;

  /// Ponto de entrada — chamado na primeira abertura do sheet para a cidade
  /// (reusado nas aberturas seguintes, nunca recarregado de novo).
  Future<void> carregar(Cidade cidade) async {
    _cidade = cidade;
    emit(
      state.copyWith(
        bairros: const CarregamentoOpcoes.carregando(),
        caracteristicas: const CarregamentoOpcoes.carregando(),
      ),
    );
    await Future.wait([_carregarBairros(cidade), _carregarCaracteristicas()]);
  }

  /// "Tentar de novo" da seção com falha — recarrega só as dimensões que
  /// ainda estão em [OpcoesFalha], passando por `carregando`; a dimensão já
  /// `carregadas` nunca é tocada.
  Future<void> tentarNovamente() async {
    final cidade = _cidade;
    if (cidade == null) return;

    final tarefas = <Future<void>>[];
    if (state.bairros is OpcoesFalha) {
      emit(state.copyWith(bairros: const CarregamentoOpcoes.carregando()));
      tarefas.add(_carregarBairros(cidade));
    }
    if (state.caracteristicas is OpcoesFalha) {
      emit(
        state.copyWith(
          caracteristicas: const CarregamentoOpcoes.carregando(),
        ),
      );
      tarefas.add(_carregarCaracteristicas());
    }
    await Future.wait(tarefas);
  }

  Future<void> _carregarBairros(Cidade cidade) async {
    final resultado = await _obterBairros(cidade);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(state.copyWith(bairros: CarregamentoOpcoes.carregadas(data)));
      case Failure():
        emit(state.copyWith(bairros: const CarregamentoOpcoes.falha()));
      case Loading():
        break;
    }
  }

  Future<void> _carregarCaracteristicas() async {
    final resultado = await _obterCaracteristicas();
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(
          state.copyWith(caracteristicas: CarregamentoOpcoes.carregadas(data)),
        );
      case Failure():
        emit(
          state.copyWith(caracteristicas: const CarregamentoOpcoes.falha()),
        );
      case Loading():
        break;
    }
  }
}
