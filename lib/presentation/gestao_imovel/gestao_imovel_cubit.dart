import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/mudanca_situacao.dart';
import '../../domain/usecases/obter_historico_situacao_usecase.dart';
import '../../domain/usecases/obter_imovel_gestao_usecase.dart';
import 'gestao_imovel_state.dart';

/// Orquestra a tela de gestão do imóvel (SIT-07, SIT-03): pede o imóvel e o
/// histórico de situações aos use cases, em paralelo, e mostra o que o servidor
/// entregou — nada é montado no app (D-01, D-11). Decide só pelo desfecho do
/// `Result` de cada leitura; a falha de uma não derruba a outra.
///
/// Token de versão (`_versao`) descarta a resposta de uma leitura que já foi
/// superada por outra, e `isClosed` é conferido antes de todo `emit` (o abridor
/// fecha o Cubit na volta da tela, com resposta ainda em voo).
@injectable
class GestaoImovelCubit extends Cubit<GestaoImovelState> {
  GestaoImovelCubit(this._obterImovel, this._obterHistorico)
    : super(const GestaoImovelState());

  final ObterImovelGestaoUseCase _obterImovel;
  final ObterHistoricoSituacaoUseCase _obterHistorico;

  int _versao = 0;
  int _versaoHistorico = 0;
  int? _id;

  /// Lê o imóvel [id] e o histórico dele em paralelo: guarda o id (para
  /// [tentarNovamente]), emite os dois em carregando e depois, num único
  /// estado, os dois desfechos.
  Future<void> carregar(int id) async {
    _id = id;
    final minhaVersao = ++_versao;
    if (isClosed) return;
    emit(const GestaoImovelState());

    final leituraDoImovel = _obterImovel(id);
    final leituraDoHistorico = _obterHistorico(id);
    await Future.wait<Object>([leituraDoImovel, leituraDoHistorico]);
    final resultadoDoImovel = await leituraDoImovel;
    final resultadoDoHistorico = await leituraDoHistorico;

    if (minhaVersao != _versao || isClosed) return;

    emit(
      state.copyWith(
        imovel: switch (resultadoDoImovel) {
          Success(:final data) => ConteudoImovelGestao.carregado(data),
          Failure() => const ConteudoImovelGestao.erro(),
          Loading() => state.imovel,
        },
        historico: _paraConteudo(resultadoDoHistorico),
      ),
    );
  }

  /// Repete a leitura do imóvel (e do histórico) com o id guardado; sem
  /// leitura anterior não faz nada.
  Future<void> tentarNovamente() async {
    final id = _id;
    if (id == null) return;
    await carregar(id);
  }

  /// Repete só o histórico com o id guardado, mantendo o imóvel na tela; sem
  /// leitura anterior não faz nada. Respostas de uma carga mais nova ou de uma
  /// repetição mais nova vencem esta.
  Future<void> tentarNovamenteHistorico() async {
    final id = _id;
    if (id == null) return;
    final versaoDaCarga = _versao;
    final minhaVersao = ++_versaoHistorico;
    if (isClosed) return;
    emit(state.copyWith(historico: const ConteudoHistorico.carregando()));

    final resultado = await _obterHistorico(id);

    if (versaoDaCarga != _versao ||
        minhaVersao != _versaoHistorico ||
        isClosed) {
      return;
    }
    emit(state.copyWith(historico: _paraConteudo(resultado)));
  }

  ConteudoHistorico _paraConteudo(Result<List<MudancaSituacao>> resultado) =>
      switch (resultado) {
        Success(:final data) => ConteudoHistorico.carregado(data),
        Failure() => const ConteudoHistorico.erro(),
        Loading() => const ConteudoHistorico.carregando(),
      };
}
