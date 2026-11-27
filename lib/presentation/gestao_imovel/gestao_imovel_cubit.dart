import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/imovel_gestao.dart';
import '../../domain/entities/mudanca_situacao.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../../domain/usecases/obter_historico_situacao_usecase.dart';
import '../../domain/usecases/obter_imovel_gestao_usecase.dart';
import '../fotos_imovel/fotos_alteradas.dart';
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
    // `mudou` sobrevive a uma nova carga: a mudança já aconteceu no servidor
    // (D-18).
    emit(
      GestaoImovelState(
        mudou: state.mudou,
        fotosMudaram: state.fotosMudaram,
        capaAtualizada: state.capaAtualizada,
        temCapaAtualizada: state.temCapaAtualizada,
      ),
    );

    final leituraDoImovel = _obterImovel(id);
    final leituraDoHistorico = _obterHistorico(id);
    await Future.wait<Object>([leituraDoImovel, leituraDoHistorico]);
    final resultadoDoImovel = await leituraDoImovel;
    final resultadoDoHistorico = await leituraDoHistorico;

    if (minhaVersao != _versao || isClosed) return;

    emit(
      state.copyWith(
        imovel: _paraConteudoDoImovel(
          resultadoDoImovel,
          historicoSessaoExpirada: _sessaoExpirou(resultadoDoHistorico),
        ),
        historico: _paraConteudo(resultadoDoHistorico),
      ),
    );
  }

  /// Relê o imóvel e o histórico em paralelo SEM emitir carregando (puxar para
  /// atualizar e, depois de uma mudança de situação, o único caminho de
  /// releitura): no sucesso troca os dois pelos lidos; numa falha genérica com
  /// conteúdo já carregado mantém tudo e soma 1 em `falhasAoAtualizar`. Sem
  /// conteúdo anterior, 401 e 404 aplicam o desfecho normal de [carregar]. A
  /// tela só muda pelo que a API devolveu (SIT-02, T-09-03). Sem leitura
  /// anterior não faz nada.
  Future<void> recarregar() async {
    final id = _id;
    if (id == null) return;
    final minhaVersao = ++_versao;

    final leituraDoImovel = _obterImovel(id);
    final leituraDoHistorico = _obterHistorico(id);
    await Future.wait<Object>([leituraDoImovel, leituraDoHistorico]);
    final resultadoDoImovel = await leituraDoImovel;
    final resultadoDoHistorico = await leituraDoHistorico;

    if (minhaVersao != _versao || isClosed) return;

    final imovelLido = _paraConteudoDoImovel(
      resultadoDoImovel,
      historicoSessaoExpirada: _sessaoExpirou(resultadoDoHistorico),
    );
    final historicoLido = _paraConteudo(resultadoDoHistorico);
    final tinhaImovel = state.imovel is ImovelGestaoCarregado;
    final tinhaHistorico = state.historico is HistoricoCarregado;

    // Falha genérica do imóvel com imóvel na tela: nada muda, só o aviso.
    if (imovelLido is ImovelGestaoErro && tinhaImovel) {
      emit(state.copyWith(falhasAoAtualizar: state.falhasAoAtualizar + 1));
      return;
    }
    // Falha só do histórico com histórico na tela: o imóvel lido entra e o
    // histórico anterior fica.
    if (imovelLido is ImovelGestaoCarregado &&
        historicoLido is HistoricoErro &&
        tinhaHistorico) {
      emit(
        state.copyWith(
          imovel: imovelLido,
          falhasAoAtualizar: state.falhasAoAtualizar + 1,
        ),
      );
      return;
    }
    emit(state.copyWith(imovel: imovelLido, historico: historicoLido));
  }

  /// Chamado pela tela depois que o servidor aceitou uma mudança de situação:
  /// marca [GestaoImovelState.mudou] SEM tocar no imóvel nem no histórico (a
  /// situação antiga continua na tela) e relê os dois por [recarregar] — só a
  /// releitura da API troca o que a tela mostra (D-10, T-09-03). `mudou` fica
  /// verdadeiro mesmo se a releitura falhar (Pitfall 3).
  Future<void> registrarMudanca() async {
    if (isClosed) return;
    emit(state.copyWith(mudou: true));
    await recarregar();
  }

  /// Chamado na volta da tela de fotos quando alguma foto mudou no servidor
  /// (APP 11, D-23): marca [GestaoImovelState.fotosMudaram] (o acervo relê) e,
  /// se a tela de fotos conhecia a lista final, guarda a capa que o SERVIDOR
  /// marcou para o cabeçalho. Não relê o imóvel: os dados dele não mudam com
  /// as fotos.
  void registrarMudancaDeFotos(FotosAlteradas alteradas) {
    if (isClosed) return;
    emit(
      alteradas.capaConhecida
          ? state.copyWith(
              fotosMudaram: true,
              capaAtualizada: alteradas.urlDaCapa,
              temCapaAtualizada: true,
            )
          : state.copyWith(fotosMudaram: true),
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
    emit(
      state.copyWith(
        imovel: _sessaoExpirou(resultado)
            ? const ConteudoImovelGestao.sessaoExpirada()
            : state.imovel,
        historico: _paraConteudo(resultado),
      ),
    );
  }

  /// Mapeamento único do desfecho da leitura do imóvel, decidido só pelo TIPO
  /// da falha (D-10): 401 vale para a tela toda — também quando vem só do
  /// histórico ([historicoSessaoExpirada]) —, 404 é "fora do acervo" e o resto
  /// é erro genérico.
  ConteudoImovelGestao _paraConteudoDoImovel(
    Result<ImovelGestao> resultado, {
    required bool historicoSessaoExpirada,
  }) {
    if (historicoSessaoExpirada) {
      return const ConteudoImovelGestao.sessaoExpirada();
    }
    return switch (resultado) {
      Success(:final data) => ConteudoImovelGestao.carregado(data),
      Failure(:final erro) when erro is SessaoExpiradaException =>
        const ConteudoImovelGestao.sessaoExpirada(),
      Failure(:final erro) when erro is ImovelNaoEncontradoException =>
        const ConteudoImovelGestao.naoEncontrado(),
      Failure() => const ConteudoImovelGestao.erro(),
      Loading() => state.imovel,
    };
  }

  bool _sessaoExpirou(Result<List<MudancaSituacao>> resultado) =>
      resultado is Failure<List<MudancaSituacao>> &&
      resultado.erro is SessaoExpiradaException;

  ConteudoHistorico _paraConteudo(Result<List<MudancaSituacao>> resultado) =>
      switch (resultado) {
        Success(:final data) => ConteudoHistorico.carregado(data),
        Failure() => const ConteudoHistorico.erro(),
        Loading() => const ConteudoHistorico.carregando(),
      };
}
