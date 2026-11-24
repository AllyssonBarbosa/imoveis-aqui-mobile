import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/imovel_com_contato.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/entities/retorno_contato.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/falhas_caixa_contatos.dart';
import '../../domain/usecases/anotar_retorno_usecase.dart';
import '../../domain/usecases/buscar_contatos_usecase.dart';
import '../../domain/usecases/listar_imoveis_dos_contatos_usecase.dart';
import '../../domain/usecases/obter_sem_retorno_usecase.dart';
import 'caixa_contatos_state.dart';

/// Orquestra a tela "Meus contatos" (CXA-01, CXA-05, CXA-06). Não filtra, não
/// ordena e não conta nada: repassa a consulta ao use case, mostra a página na
/// ordem do servidor (D-08) e guarda o número de sem retorno exatamente como
/// o servidor devolveu (D-04, D-06) — nunca soma nem subtrai. Decide só pelo
/// TIPO da falha (`SessaoExpiradaException` vira o estado de sessão
/// terminada, D-23).
///
/// A lista e o número são dois pedidos independentes (D-22): se só o número
/// falha, a lista segue e `semRetorno` fica nulo. Cada um tem o seu token de
/// versão — `_versaoConsulta` descarta uma lista de consulta antiga e
/// `_versaoResumo` impede que um número antigo cubra um mais novo. [isClosed]
/// é conferido antes de todo `emit`, e [CaixaSessaoExpirada] é terminal.
@injectable
class CaixaContatosCubit extends Cubit<CaixaContatosState> {
  CaixaContatosCubit(
    this._buscarContatos,
    this._obterSemRetorno,
    this._listarImoveis,
    this._anotarRetorno,
  ) : super(const CaixaContatosState());

  final BuscarContatosUseCase _buscarContatos;
  final ObterSemRetornoUseCase _obterSemRetorno;
  final ListarImoveisDosContatosUseCase _listarImoveis;
  final AnotarRetornoUseCase _anotarRetorno;

  int _versaoConsulta = 0;
  int _versaoResumo = 0;

  /// Ponto de entrada — chamado ao abrir a tela: pede a primeira página com a
  /// consulta atual e, em paralelo, o número de sem retorno.
  void carregar() {
    unawaited(_aplicarConsulta(state.consulta));
    unawaited(_recarregarResumo());
  }

  /// Refaz o que falhou — na primeira página repete a consulta E pede o número
  /// de novo (D-22); em "carregar mais" repete só a MESMA página pendente.
  /// Retry é sempre explícito: a rolagem nunca redispara sozinha depois de
  /// uma falha.
  Future<void> tentarNovamente() async {
    final conteudo = state.conteudo;
    if (conteudo is CaixaErro) {
      unawaited(_recarregarResumo());
      await _aplicarConsulta(state.consulta);
    } else if (conteudo is CaixaCarregada && conteudo.erroAoCarregarMais) {
      await _carregarProximaPagina();
    }
  }

  /// Filtra a caixa por [imovel] (D-19), mantendo o período. Reinicia a lista
  /// do topo e NÃO pede o número de novo (D-05, D-18). Sem efeito se o imóvel
  /// já é o aplicado.
  Future<void> aplicarImovel(ImovelComContato imovel) =>
      _trocarConsulta(state.consulta.copyWith(imovel: imovel));

  /// Tira o filtro de imóvel (D-18), mantendo o período.
  Future<void> limparImovel() =>
      _trocarConsulta(state.consulta.copyWith(limparImovel: true));

  /// Filtra a caixa por [periodo] (D-20), mantendo o imóvel.
  Future<void> aplicarPeriodo(PeriodoContatos periodo) =>
      _trocarConsulta(state.consulta.copyWith(periodo: periodo));

  /// Tira o filtro de período (D-18), mantendo o imóvel.
  Future<void> limparPeriodo() =>
      _trocarConsulta(state.consulta.copyWith(limparPeriodo: true));

  /// Pede ao servidor as opções do filtro por imóvel (D-19) — chamado a cada
  /// abertura da folha, então sempre recarrega. Uma chamada com o pedido ainda
  /// em voo é ignorada. 401 encerra a sessão como na lista (D-23); qualquer
  /// outra falha vira [OpcoesComErro].
  Future<void> carregarOpcoesDeImovel() async {
    if (state.opcoesDeImovel is OpcoesCarregando) return;
    if (state.conteudo is CaixaSessaoExpirada) return;
    emit(state.copyWith(opcoesDeImovel: const OpcoesDeImovel.carregando()));

    final resultado = await _listarImoveis();

    if (isClosed) return;
    if (state.conteudo is CaixaSessaoExpirada) return;

    switch (resultado) {
      case Success(:final data):
        emit(state.copyWith(opcoesDeImovel: OpcoesDeImovel.carregadas(data)));
      case Failure(:final erro):
        if (erro is SessaoExpiradaException) {
          emit(
            state.copyWith(
              conteudo: const ConteudoCaixa.sessaoExpirada(),
              opcoesDeImovel: const OpcoesDeImovel.naoCarregadas(),
            ),
          );
        } else {
          emit(state.copyWith(opcoesDeImovel: const OpcoesDeImovel.erro()));
        }
      case Loading():
        break;
    }
  }

  /// Anota [retorno] no contato [id] (CXA-03) e ESPERA o servidor (D-16): o
  /// item fica em `anotando` (carregamento, sem novos toques) e só muda com o
  /// 200, trocado pelo item que o servidor devolveu — sem atualização
  /// otimista. Depois de qualquer resposta o número é pedido de novo (D-06);
  /// o app nunca soma nem subtrai.
  ///
  /// Sem efeito fora de [CaixaCarregada], com o id já em voo, para um id que
  /// não está na lista, para [RetornoContato.pendente] (a API recusa) ou para
  /// a opção que já é a atual — nesse caso a anotação não é regravada (A6).
  /// Falha → aviso de texto fixo (D-17); 404 também recarrega a lista; 401
  /// encerra a sessão (D-23).
  Future<void> anotarRetorno(int id, RetornoContato retorno) async {
    if (isClosed) return;
    final conteudo = state.conteudo;
    if (conteudo is! CaixaCarregada) return;
    if (conteudo.anotando.contains(id)) return;
    if (!RetornoContato.anotaveis.contains(retorno)) return;
    final indice = conteudo.itens.indexWhere((i) => i.id == id);
    if (indice < 0) return;
    if (conteudo.itens[indice].retorno == retorno) return;

    // Pitfall 6: começar sempre limpando o aviso faz toda falha produzir uma
    // emissão diferente da anterior.
    emit(
      state.copyWith(
        aviso: null,
        conteudo: conteudo.copyWith(anotando: {...conteudo.anotando, id}),
      ),
    );

    final resultado = await _anotarRetorno(id, retorno);

    if (isClosed) return;

    switch (resultado) {
      case Success(:final data):
        final atual = state.conteudo;
        if (atual is CaixaCarregada) {
          emit(
            state.copyWith(
              conteudo: atual.copyWith(
                itens: [for (final i in atual.itens) i.id == id ? data : i],
                anotando: {...atual.anotando}..remove(id),
              ),
            ),
          );
        }
        unawaited(_recarregarResumo());
      case Failure(:final erro):
        if (erro is SessaoExpiradaException) {
          emit(state.copyWith(conteudo: const ConteudoCaixa.sessaoExpirada()));
          return;
        }
        emit(
          state.copyWith(
            aviso: erro is ContatoNaoEncontradoException
                ? AvisoCaixa.contatoSumiu
                : AvisoCaixa.falhouAoAnotar,
            conteudo: _semEmVoo(state.conteudo, id),
          ),
        );
        if (erro is ContatoNaoEncontradoException) {
          unawaited(_aplicarConsulta(state.consulta));
          unawaited(_recarregarResumo());
        }
      case Loading():
        break;
    }
  }

  /// Tira [id] de `anotando` se a lista ainda é a mesma (uma troca de filtro
  /// pode ter trocado o conteúdo enquanto o PATCH estava em voo).
  ConteudoCaixa _semEmVoo(ConteudoCaixa conteudo, int id) {
    if (conteudo is! CaixaCarregada) return conteudo;
    return conteudo.copyWith(anotando: {...conteudo.anotando}..remove(id));
  }

  /// Recomeça a lista com [consulta] só se ela mudou (D-18). Nunca refaz o
  /// resumo: o número de sem retorno vale para a caixa inteira (D-05).
  Future<void> _trocarConsulta(ConsultaContatos consulta) async {
    if (consulta == state.consulta) return;
    await _aplicarConsulta(consulta);
  }

  /// Pede a próxima página (rolagem infinita, D-12) — sem efeito fora de
  /// [CaixaCarregada], com uma página já em voo, depois de uma falha (o retry
  /// é só por [tentarNovamente]) ou sem próxima página.
  Future<void> carregarMais() async {
    final conteudo = state.conteudo;
    if (conteudo is! CaixaCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;
    await _carregarProximaPagina();
  }

  /// Acrescenta a página apontada por `proximaPagina` sem substituir nem
  /// descartar os itens já visíveis. Um id já listado não entra de novo
  /// (integridade da lista, não filtro de negócio); a ordem é a do servidor.
  Future<void> _carregarProximaPagina() async {
    final conteudo = state.conteudo;
    if (conteudo is! CaixaCarregada) return;
    final proximaPagina = conteudo.proximaPagina;
    if (proximaPagina == null) return;

    // Captura a versão vigente SEM incrementar: uma consulta nova incrementa
    // `_versaoConsulta` e invalida esta página em voo.
    final minhaVersao = _versaoConsulta;
    emit(
      state.copyWith(
        conteudo: conteudo.copyWith(
          carregandoMais: true,
          erroAoCarregarMais: false,
        ),
      ),
    );

    final resultado = await _buscarContatos.seguir(proximaPagina);

    if (minhaVersao != _versaoConsulta || isClosed) return;
    final conteudoAtual = state.conteudo;
    if (conteudoAtual is! CaixaCarregada) return;

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
          emit(state.copyWith(conteudo: const ConteudoCaixa.sessaoExpirada()));
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

  /// Reinicia a lista do topo com [consulta]: incrementa o token de versão
  /// (descarta qualquer resposta em voo), emite UM estado de carregamento e
  /// busca a primeira página. Usa `copyWith`, nunca um estado novo, para não
  /// apagar o número de sem retorno (D-05).
  Future<void> _aplicarConsulta(ConsultaContatos consulta) async {
    final minhaVersao = ++_versaoConsulta;
    emit(
      state.copyWith(
        consulta: consulta,
        conteudo: const ConteudoCaixa.carregando(),
      ),
    );

    final resultado = await _buscarContatos(consulta);

    if (minhaVersao != _versaoConsulta || isClosed) return;
    if (state.conteudo is CaixaSessaoExpirada) return;

    switch (resultado) {
      case Success(:final data):
        if (data.itens.isNotEmpty) {
          emit(
            state.copyWith(
              conteudo: ConteudoCaixa.carregada(
                itens: data.itens,
                proximaPagina: data.proximaPagina,
              ),
            ),
          );
        } else if (consulta.temFiltro) {
          emit(state.copyWith(conteudo: const ConteudoCaixa.semResultado()));
        } else {
          emit(state.copyWith(conteudo: const ConteudoCaixa.vazio()));
        }
      case Failure(:final erro):
        emit(
          state.copyWith(
            conteudo: erro is SessaoExpiradaException
                ? const ConteudoCaixa.sessaoExpirada()
                : const ConteudoCaixa.erro(),
          ),
        );
      case Loading():
        break;
    }
  }

  /// Pede ao servidor o número de contatos sem retorno e o guarda como veio.
  /// Falha genérica (rede, 500) deixa o número nulo e a lista intacta (D-22);
  /// 401 encerra a sessão como na lista (D-23).
  Future<void> _recarregarResumo() async {
    final minha = ++_versaoResumo;

    final resultado = await _obterSemRetorno();

    if (minha != _versaoResumo || isClosed) return;
    if (state.conteudo is CaixaSessaoExpirada) return;

    switch (resultado) {
      case Success(:final data):
        emit(state.copyWith(semRetorno: data));
      case Failure(:final erro):
        if (erro is SessaoExpiradaException) {
          emit(state.copyWith(conteudo: const ConteudoCaixa.sessaoExpirada()));
        } else {
          emit(state.copyWith(semRetorno: null));
        }
      case Loading():
        break;
    }
  }
}
