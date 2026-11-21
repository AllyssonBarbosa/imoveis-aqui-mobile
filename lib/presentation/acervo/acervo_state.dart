import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_acervo.dart';
import '../../domain/entities/situacao_imovel.dart';

part 'acervo_state.freezed.dart';

/// Estado de tela do acervo do corretor (ACV-01, ACV-02, ACV-04) — [termoBusca]
/// e [situacao] persistem através de qualquer transição de [conteudo] (D-08,
/// D-09); [conteudo] é a união selada dos desfechos de carregamento.
@freezed
abstract class AcervoState with _$AcervoState {
  const factory AcervoState({
    /// Termo de busca já aplicado (sem espaços nas pontas); vazio = sem busca.
    @Default('') String termoBusca,

    /// Situação escolhida nos chips; `null` é "Todas" (D-09).
    SituacaoImovel? situacao,
    @Default(ConteudoAcervo.carregando()) ConteudoAcervo conteudo,
  }) = _AcervoState;
}

/// União selada dos desfechos do acervo — estado "achatado" único de sucesso
/// ([AcervoCarregada]): uma falha ao carregar mais itens nunca derruba a lista
/// já visível (D-10).
@freezed
sealed class ConteudoAcervo with _$ConteudoAcervo {
  /// Primeira página em voo.
  const factory ConteudoAcervo.carregando() = AcervoCarregando;

  /// O acervo não tem nenhum imóvel (sem busca e sem situação).
  const factory ConteudoAcervo.vazio() = AcervoVazio;

  /// Nenhum imóvel para a busca e/ou situação aplicadas — distinto de
  /// [ConteudoAcervo.vazio].
  const factory ConteudoAcervo.semResultado() = AcervoSemResultado;

  /// Falha na primeira página — "Tentar de novo" chama `tentarNovamente()`.
  const factory ConteudoAcervo.erro() = AcervoErro;

  /// O servidor recusou o token (401): a sessão terminou. A tela avisa; quem
  /// leva ao login é a navegação de sessão (08-10).
  const factory ConteudoAcervo.sessaoExpirada() = AcervoSessaoExpirada;

  /// Sucesso — lista carregada na ordem do servidor.
  const factory ConteudoAcervo.carregada({
    required List<ImovelAcervo> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
  }) = AcervoCarregada;
}
