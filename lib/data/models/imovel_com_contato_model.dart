import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_com_contato.dart';

part 'imovel_com_contato_model.freezed.dart';
part 'imovel_com_contato_model.g.dart';

/// Modelo de transporte de uma opção do filtro por imóvel da caixa
/// (`GET /api/contatos/imoveis/`, §17.5): `id`, `codigo` e `titulo` de um
/// imóvel que já recebeu contato. A lista vem pronta e ordenada do servidor.
@freezed
abstract class ImovelComContatoModel with _$ImovelComContatoModel {
  const ImovelComContatoModel._();

  const factory ImovelComContatoModel({
    required int id,
    required String codigo,
    required String titulo,
  }) = _ImovelComContatoModel;

  factory ImovelComContatoModel.fromJson(Map<String, Object?> json) =>
      _$ImovelComContatoModelFromJson(json);

  /// Mapeia para a entidade de domínio.
  ImovelComContato paraEntidade() =>
      ImovelComContato(id: id, codigo: codigo, titulo: titulo);
}
