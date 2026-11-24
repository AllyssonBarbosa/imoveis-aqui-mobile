// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imovel_com_contato_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImovelComContatoModel _$ImovelComContatoModelFromJson(
  Map<String, dynamic> json,
) => _ImovelComContatoModel(
  id: (json['id'] as num).toInt(),
  codigo: json['codigo'] as String,
  titulo: json['titulo'] as String,
);

Map<String, dynamic> _$ImovelComContatoModelToJson(
  _ImovelComContatoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'codigo': instance.codigo,
  'titulo': instance.titulo,
};
