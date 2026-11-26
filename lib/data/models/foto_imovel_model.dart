import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/foto_imovel.dart';

part 'foto_imovel_model.freezed.dart';
part 'foto_imovel_model.g.dart';

/// Modelo de transporte de uma foto de `/api/imoveis/{id}/fotos/` (§19.2): as 4
/// chaves do `FotoDoImovelSerializer`. Chave faltando ou de tipo errado quebra
/// a desserialização, e o repositório traduz isso em falha tipada (sem foto
/// inventada).
@freezed
abstract class FotoImovelModel with _$FotoImovelModel {
  const FotoImovelModel._();

  const factory FotoImovelModel({
    required int id,
    required String imagem,
    required int ordem,
    required bool capa,
  }) = _FotoImovelModel;

  factory FotoImovelModel.fromJson(Map<String, Object?> json) =>
      _$FotoImovelModelFromJson(json);

  /// Mapeia para a entidade de domínio, sem mudar ordem nem capa.
  FotoImovel paraEntidade() =>
      FotoImovel(id: id, url: imagem, ordem: ordem, capa: capa);
}
