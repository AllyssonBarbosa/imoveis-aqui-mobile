import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cidade.dart';

part 'cidade_model.freezed.dart';
part 'cidade_model.g.dart';

/// Modelo de transporte para uma linha de `GET /api/publico/cidades/`
/// (VIT-06, D-16). `id` segue para a entidade só como atributo de rota; a
/// identidade da cidade continua sendo [Cidade.chaveNatural] (D-15, A-01).
@freezed
abstract class CidadeModel with _$CidadeModel {
  const CidadeModel._();

  const factory CidadeModel({
    required int id,
    required String nome,
    required String uf,
  }) = _CidadeModel;

  factory CidadeModel.fromJson(Map<String, Object?> json) =>
      _$CidadeModelFromJson(json);

  /// Mapeia para a entidade de domínio (o `id` vai fora da igualdade, A-01).
  Cidade paraEntidade() => Cidade(id: id, nome: nome, uf: uf);
}
