// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dados_natureza_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CasaModel _$CasaModelFromJson(Map<String, dynamic> json) => _CasaModel(
  areaTerreno: json['area_terreno'] as String?,
  areaConstruida: json['area_construida'] as String?,
  areaLivre: json['area_livre'] as String?,
  quartos: (json['quartos'] as num?)?.toInt(),
  suites: (json['suites'] as num?)?.toInt(),
  banheiros: (json['banheiros'] as num?)?.toInt(),
  salas: (json['salas'] as num?)?.toInt(),
  vagas: (json['vagas'] as num?)?.toInt(),
  pavimentos: (json['pavimentos'] as num?)?.toInt(),
  anoConstrucao: (json['ano_construcao'] as num?)?.toInt(),
  piscina: json['piscina'] as bool?,
  quintal: json['quintal'] as bool?,
  churrasqueira: json['churrasqueira'] as bool?,
  mobiliada: json['mobiliada'] as bool?,
);

Map<String, dynamic> _$CasaModelToJson(_CasaModel instance) =>
    <String, dynamic>{
      'area_terreno': instance.areaTerreno,
      'area_construida': instance.areaConstruida,
      'area_livre': instance.areaLivre,
      'quartos': instance.quartos,
      'suites': instance.suites,
      'banheiros': instance.banheiros,
      'salas': instance.salas,
      'vagas': instance.vagas,
      'pavimentos': instance.pavimentos,
      'ano_construcao': instance.anoConstrucao,
      'piscina': instance.piscina,
      'quintal': instance.quintal,
      'churrasqueira': instance.churrasqueira,
      'mobiliada': instance.mobiliada,
    };

_TerrenoModel _$TerrenoModelFromJson(Map<String, dynamic> json) =>
    _TerrenoModel(
      areaTotal: json['area_total'] as String?,
      frente: json['frente'] as String?,
      fundo: json['fundo'] as String?,
      laterais: json['laterais'] as String?,
      topografia: json['topografia'] as String?,
      murado: json['murado'] as bool?,
      esquina: json['esquina'] as bool?,
      usoPermitido: json['uso_permitido'] as String?,
    );

Map<String, dynamic> _$TerrenoModelToJson(_TerrenoModel instance) =>
    <String, dynamic>{
      'area_total': instance.areaTotal,
      'frente': instance.frente,
      'fundo': instance.fundo,
      'laterais': instance.laterais,
      'topografia': instance.topografia,
      'murado': instance.murado,
      'esquina': instance.esquina,
      'uso_permitido': instance.usoPermitido,
    };

_ApartamentoModel _$ApartamentoModelFromJson(Map<String, dynamic> json) =>
    _ApartamentoModel(
      andar: (json['andar'] as num?)?.toInt(),
      numero: json['numero'] as String?,
      areaPrivativa: json['area_privativa'] as String?,
      areaTotal: json['area_total'] as String?,
      quartos: (json['quartos'] as num?)?.toInt(),
      suites: (json['suites'] as num?)?.toInt(),
      banheiros: (json['banheiros'] as num?)?.toInt(),
      vagas: (json['vagas'] as num?)?.toInt(),
      varanda: json['varanda'] as bool?,
      posicaoSolar: json['posicao_solar'] as String?,
    );

Map<String, dynamic> _$ApartamentoModelToJson(_ApartamentoModel instance) =>
    <String, dynamic>{
      'andar': instance.andar,
      'numero': instance.numero,
      'area_privativa': instance.areaPrivativa,
      'area_total': instance.areaTotal,
      'quartos': instance.quartos,
      'suites': instance.suites,
      'banheiros': instance.banheiros,
      'vagas': instance.vagas,
      'varanda': instance.varanda,
      'posicao_solar': instance.posicaoSolar,
    };

_LoteModel _$LoteModelFromJson(Map<String, dynamic> json) => _LoteModel(
  numero: json['numero'] as String?,
  area: json['area'] as String?,
  frente: json['frente'] as String?,
  fundo: json['fundo'] as String?,
  preco: json['preco'] as String?,
  condicoesParcelamento: json['condicoes_parcelamento'] as String?,
);

Map<String, dynamic> _$LoteModelToJson(_LoteModel instance) =>
    <String, dynamic>{
      'numero': instance.numero,
      'area': instance.area,
      'frente': instance.frente,
      'fundo': instance.fundo,
      'preco': instance.preco,
      'condicoes_parcelamento': instance.condicoesParcelamento,
    };
