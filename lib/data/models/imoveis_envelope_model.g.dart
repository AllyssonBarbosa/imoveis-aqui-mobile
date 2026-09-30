// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imoveis_envelope_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImoveisEnvelopeModel _$ImoveisEnvelopeModelFromJson(
  Map<String, dynamic> json,
) => _ImoveisEnvelopeModel(
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => ImovelModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ImoveisEnvelopeModelToJson(
  _ImoveisEnvelopeModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
