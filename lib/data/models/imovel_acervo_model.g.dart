// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imovel_acervo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImovelAcervoModel _$ImovelAcervoModelFromJson(Map<String, dynamic> json) =>
    _ImovelAcervoModel(
      id: (json['id'] as num).toInt(),
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      finalidade: json['finalidade'] as String,
      precoVenda: json['preco_venda'] as String?,
      precoAluguel: json['preco_aluguel'] as String?,
      fotoCapa: json['foto_capa'] as String?,
      situacao: json['situacao'] as String?,
      meuImovel: json['meu_imovel'] as bool,
      naVitrine: json['na_vitrine'] as bool,
    );

Map<String, dynamic> _$ImovelAcervoModelToJson(_ImovelAcervoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'titulo': instance.titulo,
      'finalidade': instance.finalidade,
      'preco_venda': instance.precoVenda,
      'preco_aluguel': instance.precoAluguel,
      'foto_capa': instance.fotoCapa,
      'situacao': instance.situacao,
      'meu_imovel': instance.meuImovel,
      'na_vitrine': instance.naVitrine,
    };
