import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_gestao.dart';
import '../../domain/entities/mudanca_situacao.dart';

part 'gestao_imovel_state.freezed.dart';

/// Estado de tela da gestão do imóvel (SIT-07, SIT-03): o desfecho da leitura
/// do imóvel em [imovel] e o do histórico de situações em [historico] — as duas
/// leituras são independentes (a falha de uma não derruba a outra). A seção de
/// mudança de situação entra nos planos seguintes da fase.
@freezed
abstract class GestaoImovelState with _$GestaoImovelState {
  const factory GestaoImovelState({
    @Default(ConteudoImovelGestao.carregando()) ConteudoImovelGestao imovel,
    @Default(ConteudoHistorico.carregando()) ConteudoHistorico historico,
  }) = _GestaoImovelState;
}

/// União selada dos desfechos da leitura do imóvel — a tela decide o que
/// mostrar por `switch` exaustivo, sem ramo abrangente.
@freezed
sealed class ConteudoImovelGestao with _$ConteudoImovelGestao {
  /// Leitura em voo.
  const factory ConteudoImovelGestao.carregando() = ImovelGestaoCarregando;

  /// Sucesso — o imóvel como o servidor entregou.
  const factory ConteudoImovelGestao.carregado(ImovelGestao imovel) =
      ImovelGestaoCarregado;

  /// Falha na leitura — "Tentar de novo" chama `tentarNovamente()`.
  const factory ConteudoImovelGestao.erro() = ImovelGestaoErro;

  /// O servidor respondeu 404: o imóvel não está (mais) no acervo do corretor;
  /// a tela mostra um texto fixo, sem "Tentar de novo" (D-10).
  const factory ConteudoImovelGestao.naoEncontrado() =
      ImovelGestaoNaoEncontrado;

  /// O servidor recusou o token (401) em qualquer das duas leituras: a tela
  /// volta ao login (D-10, padrão da Fase 8).
  const factory ConteudoImovelGestao.sessaoExpirada() =
      ImovelGestaoSessaoExpirada;
}

/// União selada dos desfechos da leitura do histórico — a seção decide o que
/// mostrar por `switch` exaustivo, sem ramo abrangente.
@freezed
sealed class ConteudoHistorico with _$ConteudoHistorico {
  /// Leitura em voo.
  const factory ConteudoHistorico.carregando() = HistoricoCarregando;

  /// Sucesso — as mudanças na ordem que o servidor mandou (D-11); lista vazia
  /// quando o imóvel nunca mudou de situação.
  const factory ConteudoHistorico.carregado(List<MudancaSituacao> itens) =
      HistoricoCarregado;

  /// Falha só do histórico — "Tentar de novo" chama
  /// `tentarNovamenteHistorico()`.
  const factory ConteudoHistorico.erro() = HistoricoErro;
}
