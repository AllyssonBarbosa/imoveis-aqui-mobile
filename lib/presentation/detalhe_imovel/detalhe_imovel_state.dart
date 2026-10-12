import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/detalhe_imovel.dart';

part 'detalhe_imovel_state.freezed.dart';

/// Estado de `DetalheImovelCubit` — união selada do ciclo de carregamento
/// do detalhe; a tela faz `switch` exaustivo, sem ramo abrangente.
@freezed
sealed class DetalheImovelState with _$DetalheImovelState {
  const factory DetalheImovelState.carregando() = DetalheCarregando;

  const factory DetalheImovelState.carregado(DetalheImovel detalhe) =
      DetalheCarregado;

  const factory DetalheImovelState.erro() = DetalheErro;

  /// 404 (D-01/D-17): o imóvel não existe ou foi despublicado — repetir a
  /// busca não resolve, então este estado não oferece "Tentar de novo".
  const factory DetalheImovelState.naoEncontrado() = DetalheNaoEncontrado;
}
