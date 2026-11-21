// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acervo_envelope_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcervoEnvelopeModel _$AcervoEnvelopeModelFromJson(Map<String, dynamic> json) =>
    _AcervoEnvelopeModel(
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => ImovelAcervoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcervoEnvelopeModelToJson(
  _AcervoEnvelopeModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
