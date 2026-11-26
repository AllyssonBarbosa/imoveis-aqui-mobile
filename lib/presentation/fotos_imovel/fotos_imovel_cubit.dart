import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/foto_imovel.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/fotos_imovel_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../../domain/usecases/apagar_foto_usecase.dart';
import '../../domain/usecases/definir_capa_usecase.dart';
import '../../domain/usecases/descartar_foto_preparada_usecase.dart';
import '../../domain/usecases/enviar_foto_usecase.dart';
import '../../domain/usecases/escolher_fotos_da_galeria_usecase.dart';
import '../../domain/usecases/listar_fotos_usecase.dart';
import '../../domain/usecases/preparar_foto_usecase.dart';
import '../../domain/usecases/reordenar_fotos_usecase.dart';
import '../../domain/usecases/tirar_foto_usecase.dart';
import 'fotos_imovel_state.dart';

/// Orquestra a tela de fotos do imóvel (APP 11). Quem decide é o servidor:
/// nenhuma ordem, capa ou exclusão muda [FotosImovelState.lista] antes da
/// resposta — a lista exibida é sempre a última que o servidor devolveu (D-02,
/// D-20 a D-22).
///
/// A fila de envio processa UMA foto por vez, na ordem da escolha: prepara (JPEG
/// reduzido), envia com progresso e, aceita, sai da fila e a lista é relida.
/// Uma falha marca só aquela foto (com a mensagem do servidor, se houver) e a
/// fila segue para a próxima (D-18). 401 em qualquer chamada encerra tudo: a
/// lista vira "sessão expirada" e nenhum envio novo começa (D-23).
///
/// `isClosed` é conferido antes de todo `emit`: o abridor fecha o Cubit na volta
/// da tela, com resposta ainda em voo. Ao fechar, os JPEGs preparados que ficaram
/// na fila são apagados.
@injectable
class FotosImovelCubit extends Cubit<FotosImovelState> {
  FotosImovelCubit(
    this._listar,
    this._tirarFoto,
    this._escolherDaGaleria,
    this._preparar,
    this._enviar,
    this._descartar,
    this._reordenar,
    this._definirCapa,
    this._apagar,
  ) : super(const FotosImovelState());

  final ListarFotosUseCase _listar;
  final TirarFotoUseCase _tirarFoto;
  final EscolherFotosDaGaleriaUseCase _escolherDaGaleria;
  final PrepararFotoUseCase _preparar;
  final EnviarFotoUseCase _enviar;
  final DescartarFotoPreparadaUseCase _descartar;
  final ReordenarFotosUseCase _reordenar;
  final DefinirCapaUseCase _definirCapa;
  final ApagarFotoUseCase _apagar;

  int? _imovelId;
  int _proximoIdLocal = 0;
  bool _processandoFila = false;

  bool get _encerrada =>
      isClosed ||
      state.lista is ListaFotosSessaoExpirada ||
      state.lista is ListaFotosNaoEncontrado;

  // --- Leitura ------------------------------------------------------------

  /// Lê as fotos do imóvel [imovelId] e guarda o id para as próximas chamadas.
  Future<void> carregar(int imovelId) async {
    _imovelId = imovelId;
    if (isClosed) return;
    emit(state.copyWith(lista: const ListaFotos.carregando()));
    final resultado = await _listar(imovelId);
    if (isClosed) return;
    emit(state.copyWith(lista: _listaDe(resultado, semConteudo: true)));
  }

  /// Repete a primeira leitura (o "Tentar de novo" do erro).
  Future<void> tentarNovamente() async {
    final id = _imovelId;
    if (id == null) return;
    await carregar(id);
  }

  /// Relê a lista sem mostrar carregando: no sucesso troca pela lida; numa
  /// falha genérica mantém a que está na tela.
  Future<void> _relerLista() async {
    final id = _imovelId;
    if (id == null || isClosed) return;
    final resultado = await _listar(id);
    if (isClosed) return;
    emit(state.copyWith(lista: _listaDe(resultado, semConteudo: false)));
  }

  /// Desfecho da leitura, decidido só pelo TIPO da falha. [semConteudo]: numa
  /// falha genérica sem lista anterior vira erro; com lista, ela fica.
  ListaFotos _listaDe(
    Result<List<FotoImovel>> resultado, {
    required bool semConteudo,
  }) => switch (resultado) {
    Success(:final data) => ListaFotos.carregada(data),
    Failure(:final erro) when erro is SessaoExpiradaException =>
      const ListaFotos.sessaoExpirada(),
    Failure(:final erro) when erro is ImovelNaoEncontradoException =>
      const ListaFotos.naoEncontrado(),
    Failure() =>
      semConteudo || state.lista is! ListaFotosCarregada
          ? const ListaFotos.erro()
          : state.lista,
    Loading() => state.lista,
  };

  // --- Escolha e fila de envio --------------------------------------------

  /// Abre a câmera; a foto tirada entra na fila. Cancelar não faz nada.
  Future<void> tirarFoto() async {
    if (_encerrada) return;
    final resultado = await _tirarFoto();
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        if (data != null) adicionar([data]);
      case Failure():
        emit(state.copyWith(falhasAoEscolher: state.falhasAoEscolher + 1));
      case Loading():
        break;
    }
  }

  /// Abre a galeria; as fotos escolhidas entram na fila, na ordem da escolha.
  Future<void> escolherDaGaleria() async {
    if (_encerrada) return;
    final resultado = await _escolherDaGaleria();
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        adicionar(data);
      case Failure():
        emit(state.copyWith(falhasAoEscolher: state.falhasAoEscolher + 1));
      case Loading():
        break;
    }
  }

  /// Coloca [fotos] no fim da fila, aguardando, e começa a enviar se a fila
  /// estava parada. O app não limita a quantidade: o teto é do servidor (D-06).
  void adicionar(List<FotoEscolhida> fotos) {
    if (_encerrada || fotos.isEmpty) return;
    emit(
      state.copyWith(
        fila: List.unmodifiable([
          ...state.fila,
          for (final foto in fotos)
            EnvioDeFoto(id: _proximoIdLocal++, original: foto),
        ]),
      ),
    );
    unawaited(_processarFila());
  }

  /// Recoloca a foto que falhou na fila. Se ela já tinha sido preparada, o
  /// mesmo JPEG é reenviado; se a falha foi no preparo, prepara de novo.
  void tentarDeNovoEnvio(int idLocal) {
    if (_encerrada) return;
    final envio = _envio(idLocal);
    if (envio == null || envio.estado is! EnvioFalhou) return;
    _atualizarEnvio(
      idLocal,
      (envio) => envio.copyWith(estado: const EstadoEnvio.aguardando()),
    );
    unawaited(_processarFila());
  }

  /// Tira da fila uma foto que falhou, sem reenviar, e apaga o JPEG preparado.
  Future<void> remover(int idLocal) async {
    final envio = _envio(idLocal);
    if (envio == null || envio.estado is! EnvioFalhou || isClosed) return;
    emit(
      state.copyWith(
        fila: List.unmodifiable(state.fila.where((item) => item.id != idLocal)),
      ),
    );
    final preparada = envio.preparada;
    if (preparada != null) await _descartar(preparada);
  }

  /// Uma foto por vez, na ordem: só uma execução do laço existe por vez.
  Future<void> _processarFila() async {
    if (_processandoFila) return;
    _processandoFila = true;
    try {
      while (!_encerrada) {
        final proximo = state.fila
            .where((envio) => envio.estado is EnvioAguardando)
            .firstOrNull;
        if (proximo == null) break;
        await _enviarUm(proximo);
      }
    } finally {
      _processandoFila = false;
    }
  }

  Future<void> _enviarUm(EnvioDeFoto envio) async {
    final imovelId = _imovelId;
    if (imovelId == null) return;

    var preparada = envio.preparada;
    if (preparada == null) {
      _atualizarEnvio(
        envio.id,
        (item) => item.copyWith(estado: const EstadoEnvio.preparando()),
      );
      final preparo = await _preparar(envio.original);
      if (isClosed) return;
      switch (preparo) {
        case Success(:final data):
          preparada = data;
        case Failure() || Loading():
          _atualizarEnvio(
            envio.id,
            (item) => item.copyWith(
              estado: const EstadoEnvio.falhou(noPreparo: true),
            ),
          );
          return;
      }
    }

    final arquivo = preparada;
    _atualizarEnvio(
      envio.id,
      (item) => item.copyWith(
        preparada: arquivo,
        estado: const EstadoEnvio.enviando(progresso: 0),
      ),
    );
    final resultado = await _enviar(
      imovelId,
      arquivo,
      aoProgredir: (fracao) {
        if (isClosed) return;
        _atualizarEnvio(
          envio.id,
          (item) => item.estado is EnvioEnviando
              ? item.copyWith(estado: EstadoEnvio.enviando(progresso: fracao))
              : item,
        );
      },
    );
    if (isClosed) return;

    switch (resultado) {
      case Success():
        // Aceita: sai da fila e a lista é relida (ordem e capa do servidor).
        emit(
          state.copyWith(
            mudou: true,
            fila: List.unmodifiable(
              state.fila.where((item) => item.id != envio.id),
            ),
          ),
        );
        await _relerLista();
      case Failure(:final erro) when erro is SessaoExpiradaException:
        _marcarFalha(envio.id);
        emit(state.copyWith(lista: const ListaFotos.sessaoExpirada()));
      case Failure(:final erro) when erro is ImovelNaoEncontradoException:
        _marcarFalha(envio.id);
        emit(state.copyWith(lista: const ListaFotos.naoEncontrado()));
      case Failure(:final erro) when erro is FotoRecusadaException:
        _marcarFalha(envio.id, mensagemDoServidor: erro.mensagem);
      case Failure() || Loading():
        // Pode ter gravado (tempo esgotado): relê para mostrar a verdade.
        _marcarFalha(envio.id);
        await _relerLista();
    }
  }

  void _marcarFalha(int idLocal, {String? mensagemDoServidor}) =>
      _atualizarEnvio(
        idLocal,
        (item) => item.copyWith(
          estado: EstadoEnvio.falhou(mensagemDoServidor: mensagemDoServidor),
        ),
      );

  EnvioDeFoto? _envio(int idLocal) =>
      state.fila.where((item) => item.id == idLocal).firstOrNull;

  void _atualizarEnvio(
    int idLocal,
    EnvioDeFoto Function(EnvioDeFoto envio) atualizar,
  ) {
    if (isClosed) return;
    emit(
      state.copyWith(
        fila: List.unmodifiable([
          for (final item in state.fila)
            item.id == idLocal ? atualizar(item) : item,
        ]),
      ),
    );
  }

  // --- Ordem, capa e exclusão (o servidor decide) -------------------------

  /// O corretor arrastou a foto de [de] para a posição final [destino]
  /// (`onReorderItem` do `ReorderableListView`).
  /// Pede a lista completa na ordem nova e mostra a lista devolvida; até lá a
  /// lista exibida não muda (D-20). Ignorado com envio ou operação em andamento.
  Future<void> reordenar(int de, int destino) async {
    final lista = state.lista;
    if (!state.podeAlterarFotos || lista is! ListaFotosCarregada) return;
    final ids = idsNaOrdemPedida(lista.fotos, de, destino);
    if (ids == null) return;
    await _operar(
      const OperacaoFotos.reordenando(),
      (imovelId) => _reordenar(imovelId, ids),
    );
  }

  /// Pede que [fotoId] vire a capa e mostra a lista devolvida (D-21).
  Future<void> definirCapa(int fotoId) async {
    if (!state.podeAlterarFotos) return;
    await _operar(
      OperacaoFotos.definindoCapa(fotoId),
      (imovelId) => _definirCapa(imovelId, fotoId),
    );
  }

  /// Pede a exclusão de [fotoId] (a tela já confirmou) e mostra a lista
  /// devolvida; quem promove a nova capa é o servidor (D-22).
  Future<void> apagar(int fotoId) async {
    if (!state.podeAlterarFotos) return;
    await _operar(
      OperacaoFotos.apagando(fotoId),
      (imovelId) => _apagar(imovelId, fotoId),
      aoConcluir: (estado) =>
          estado.copyWith(fotosApagadas: estado.fotosApagadas + 1),
    );
  }

  Future<void> _operar(
    OperacaoFotos operacao,
    Future<Result<List<FotoImovel>>> Function(int imovelId) pedir, {
    FotosImovelState Function(FotosImovelState estado)? aoConcluir,
  }) async {
    final imovelId = _imovelId;
    if (imovelId == null || isClosed) return;
    emit(state.copyWith(operacao: operacao));
    final resultado = await pedir(imovelId);
    if (isClosed) return;
    const nenhuma = OperacaoFotos.nenhuma();
    switch (resultado) {
      case Success(:final data):
        final concluido = state.copyWith(
          operacao: nenhuma,
          lista: ListaFotos.carregada(data),
          mudou: true,
        );
        emit(aoConcluir?.call(concluido) ?? concluido);
      case Failure(:final erro) when erro is SessaoExpiradaException:
        emit(
          state.copyWith(
            operacao: nenhuma,
            lista: const ListaFotos.sessaoExpirada(),
          ),
        );
      case Failure(:final erro) when erro is ImovelNaoEncontradoException:
        emit(
          state.copyWith(
            operacao: nenhuma,
            lista: const ListaFotos.naoEncontrado(),
          ),
        );
      case Failure(:final erro):
        emit(
          state.copyWith(
            operacao: nenhuma,
            falhasDeOperacao: state.falhasDeOperacao + 1,
            mensagemDaUltimaFalha: erro is FotoRecusadaException
                ? erro.mensagem
                : null,
          ),
        );
        // A escrita pode ter acontecido ou não: relê para mostrar a verdade.
        await _relerLista();
      case Loading():
        emit(state.copyWith(operacao: nenhuma));
    }
  }

  /// Ao fechar (o corretor saiu da tela), apaga os JPEGs preparados que não
  /// foram enviados. A fila não sobrevive à tela (D-18).
  @override
  Future<void> close() async {
    final preparadas = [
      for (final envio in state.fila)
        if (envio.preparada != null) envio.preparada!,
    ];
    await super.close();
    for (final preparada in preparadas) {
      await _descartar(preparada);
    }
  }
}
