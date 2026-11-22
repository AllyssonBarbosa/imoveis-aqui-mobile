// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil_empresa_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerfilEmpresaModel _$PerfilEmpresaModelFromJson(Map<String, dynamic> json) =>
    _PerfilEmpresaModel(
      id: (json['id'] as num).toInt(),
      tipo: json['tipo'] as String?,
      nome: json['razao_social_ou_nome'] as String,
      creci: json['creci'] as String?,
      telefone: json['telefone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      descricao: json['descricao'] as String?,
      logomarca: json['logomarca'] as String?,
      cidadesAtuacao:
          (json['cidades_atuacao'] as List<dynamic>?)
              ?.map((e) => CidadeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CidadeModel>[],
    );

Map<String, dynamic> _$PerfilEmpresaModelToJson(_PerfilEmpresaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': instance.tipo,
      'razao_social_ou_nome': instance.nome,
      'creci': instance.creci,
      'telefone': instance.telefone,
      'whatsapp': instance.whatsapp,
      'email': instance.email,
      'descricao': instance.descricao,
      'logomarca': instance.logomarca,
      'cidades_atuacao': instance.cidadesAtuacao,
    };
