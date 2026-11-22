// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil_corretor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerfilCorretorModel _$PerfilCorretorModelFromJson(Map<String, dynamic> json) =>
    _PerfilCorretorModel(
      id: (json['id'] as num).toInt(),
      empresaId: (json['empresa_id'] as num?)?.toInt(),
      foto: json['foto'] as String?,
      nome: json['nome'] as String,
      email: json['email'] as String?,
      creci: json['creci'] as String?,
      telefone: json['telefone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      apresentacao: json['apresentacao'] as String?,
    );

Map<String, dynamic> _$PerfilCorretorModelToJson(
  _PerfilCorretorModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'empresa_id': instance.empresaId,
  'foto': instance.foto,
  'nome': instance.nome,
  'email': instance.email,
  'creci': instance.creci,
  'telefone': instance.telefone,
  'whatsapp': instance.whatsapp,
  'apresentacao': instance.apresentacao,
};
