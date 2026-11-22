import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_gestao.dart';

part 'gestao_imovel_state.freezed.dart';

/// Estado de tela da gestão do imóvel (SIT-07): hoje só o desfecho da leitura
/// do imóvel em [imovel]; as seções de histórico e de mudança de situação
/// entram nos planos seguintes da fase.
@freezed
abstract class GestaoImovelState with _$GestaoImovelState {
  const factory GestaoImovelState({
    @Default(ConteudoImovelGestao.carregando()) ConteudoImovelGestao imovel,
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
}
