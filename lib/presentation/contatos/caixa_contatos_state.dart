import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/contato_recebido.dart';
import '../../domain/entities/imovel_com_contato.dart';

part 'caixa_contatos_state.freezed.dart';

/// Estado de tela da caixa "Meus contatos" (CXA-01, CXA-05, CXA-06).
///
/// [consulta] é o que está aplicado à lista; [semRetorno] é o número que o
/// servidor devolveu para a caixa inteira e sobrevive a qualquer troca de
/// consulta (D-05); [conteudo] é a união selada dos desfechos da lista.
@freezed
abstract class CaixaContatosState with _$CaixaContatosState {
  const factory CaixaContatosState({
    /// Consulta aplicada à lista (imóvel e período); sem filtro por padrão.
    @Default(ConsultaContatos()) ConsultaContatos consulta,

    /// Contatos sem retorno, como o servidor contou (D-04, D-06). `null` =
    /// ainda não veio ou falhou: a tela some com a linha e a lista segue
    /// (D-22). O app nunca soma nem subtrai este número.
    int? semRetorno,
    @Default(ConteudoCaixa.carregando()) ConteudoCaixa conteudo,

    /// Opções do filtro por imóvel, como o servidor devolveu (D-19). Pedidas a
    /// cada abertura da folha — não fazem parte da lista nem da consulta.
    @Default(OpcoesDeImovel.naoCarregadas()) OpcoesDeImovel opcoesDeImovel,

    /// Aviso de uma anotação que não deu certo — one-shot da `SnackBar` (D-17).
    /// Toda anotação começa limpando-o, então duas falhas seguidas passam por
    /// um estado sem aviso e a tela mostra as duas.
    AvisoCaixa? aviso,
  }) = _CaixaContatosState;
}

/// Por que a anotação de um retorno não valeu (D-17). A tela escolhe o texto
/// fixo; nada que o servidor escreveu chega ao usuário.
enum AvisoCaixa {
  /// Rede, timeout, 5xx ou 400: o item ficou como estava.
  falhouAoAnotar,

  /// 404: o contato não está mais na caixa; a lista e o número foram pedidos
  /// de novo.
  contatoSumiu,
}

/// União selada dos desfechos da lista da caixa — estado "achatado" único de
/// sucesso ([CaixaCarregada]): uma falha ao carregar mais itens nunca derruba
/// a lista já visível (D-12).
@freezed
sealed class ConteudoCaixa with _$ConteudoCaixa {
  /// Primeira página em voo.
  const factory ConteudoCaixa.carregando() = CaixaCarregando;

  /// A caixa não tem nenhum contato (sem filtro) — D-21.
  const factory ConteudoCaixa.vazio() = CaixaVazia;

  /// Nenhum contato para o filtro aplicado — distinto de
  /// [ConteudoCaixa.vazio] (D-21).
  const factory ConteudoCaixa.semResultado() = CaixaSemResultado;

  /// Falha na primeira página — "Tentar de novo" chama `tentarNovamente()`
  /// e repete a lista e a contagem (D-22).
  const factory ConteudoCaixa.erro() = CaixaErro;

  /// O servidor recusou o token (401) na lista, na página seguinte ou na
  /// contagem: a sessão terminou (D-23). Estado terminal.
  const factory ConteudoCaixa.sessaoExpirada() = CaixaSessaoExpirada;

  /// Sucesso — lista carregada na ordem do servidor (D-08).
  const factory ConteudoCaixa.carregada({
    required List<ContatoRecebido> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,

    /// Ids com `PATCH` em voo (D-16): o item mostra carregamento e ignora
    /// toques até o servidor responder.
    @Default(<int>{}) Set<int> anotando,
  }) = CaixaCarregada;
}

/// Desfechos do pedido das opções do filtro por imóvel (D-19). São carregadas
/// a cada abertura da folha (R3), então um imóvel que acabou de receber contato
/// já aparece; a lista e a ordem são as do servidor.
@freezed
sealed class OpcoesDeImovel with _$OpcoesDeImovel {
  /// A folha ainda não foi aberta.
  const factory OpcoesDeImovel.naoCarregadas() = OpcoesNaoCarregadas;

  /// Pedido em voo.
  const factory OpcoesDeImovel.carregando() = OpcoesCarregando;

  /// Imóveis que já receberam contato, na ordem do servidor.
  const factory OpcoesDeImovel.carregadas(List<ImovelComContato> imoveis) =
      OpcoesCarregadas;

  /// Falha que não é de sessão (rede, 500): a folha oferece tentar de novo.
  const factory OpcoesDeImovel.erro() = OpcoesComErro;
}
