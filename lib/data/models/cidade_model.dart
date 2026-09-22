import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cidade.dart';

part 'cidade_model.freezed.dart';
part 'cidade_model.g.dart';

/// Modelo de transporte para uma linha de `GET /cidades` (ou do fixture local
/// `assets/cidades.json`, mesma forma, D-13). `id` existe no contrato, mas
/// NÃO é o que persistimos — ver D-15 / [Cidade.chaveNatural].
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

  /// Mapeia para a entidade de domínio (descarta o `id`, D-15).
  Cidade paraEntidade() => Cidade(nome: nome, uf: uf);
}
