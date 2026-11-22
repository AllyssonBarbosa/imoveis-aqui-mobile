import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_gestao.dart';
import 'codigos_imovel_api.dart';

part 'imovel_gestao_model.freezed.dart';
part 'imovel_gestao_model.g.dart';

/// Modelo de transporte para `GET /api/imoveis/{id}/` na gestão da situação:
/// só as 9 chaves que o app lê, mais nada (T-09-06). As demais chaves do
/// serializer do servidor são ignoradas na desserialização e nunca ficam em
/// memória. `pode_mudar_situacao` e `situacao_desde` chegam decididos pelo
/// Django (D-04, D-05) e só são lidos.
@freezed
abstract class ImovelGestaoModel with _$ImovelGestaoModel {
  const ImovelGestaoModel._();

  const factory ImovelGestaoModel({
    required int id,
    required String codigo,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    String? situacao,
    @JsonKey(name: 'situacao_desde') required String situacaoDesde,
    @JsonKey(name: 'pode_mudar_situacao') required bool podeMudarSituacao,
  }) = _ImovelGestaoModel;

  factory ImovelGestaoModel.fromJson(Map<String, Object?> json) =>
      _$ImovelGestaoModelFromJson(json);

  /// Mapeia para a entidade de domínio. Finalidade e situação passam pelo mapa
  /// único de `codigos_imovel_api.dart`: `finalidade` desconhecida lança
  /// [FormatException]; `situacao` desconhecida ou nula vira `null` (T-09-10).
  /// `situacao_desde` é lida como instante UTC; data inválida lança
  /// [FormatException].
  ImovelGestao paraEntidade() {
    return ImovelGestao(
      id: id,
      codigo: codigo,
      titulo: titulo,
      finalidade: finalidadeDoCodigo(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      situacao: situacaoDoCodigo(situacao),
      situacaoDesde: DateTime.parse(situacaoDesde).toUtc(),
      podeMudarSituacao: podeMudarSituacao,
    );
  }
}
