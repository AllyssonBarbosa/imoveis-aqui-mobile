import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/contato_recebido.dart';

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
  }) = _CaixaContatosState;
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
  }) = CaixaCarregada;
}
