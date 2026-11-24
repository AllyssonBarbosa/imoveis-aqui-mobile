// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contatos_envelope_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContatosEnvelopeModel _$ContatosEnvelopeModelFromJson(
  Map<String, dynamic> json,
) => _ContatosEnvelopeModel(
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => ContatoRecebidoModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ContatosEnvelopeModelToJson(
  _ContatosEnvelopeModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
