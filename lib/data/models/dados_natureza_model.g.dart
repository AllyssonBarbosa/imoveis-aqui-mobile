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
      predio: json['predio'] == null
          ? null
          : PredioModel.fromJson(json['predio'] as Map<String, dynamic>),
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
      'predio': instance.predio,
    };

_LoteModel _$LoteModelFromJson(Map<String, dynamic> json) => _LoteModel(
  numero: json['numero'] as String?,
  area: json['area'] as String?,
  frente: json['frente'] as String?,
  fundo: json['fundo'] as String?,
  entradaMinima: json['entrada_minima'] as String?,
  parcelasMaximas: (json['parcelas_maximas'] as num?)?.toInt(),
  condicoesParcelamento: json['condicoes_parcelamento'] as String?,
  quadra: json['quadra'] == null
      ? null
      : QuadraModel.fromJson(json['quadra'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoteModelToJson(_LoteModel instance) =>
    <String, dynamic>{
      'numero': instance.numero,
      'area': instance.area,
      'frente': instance.frente,
      'fundo': instance.fundo,
      'entrada_minima': instance.entradaMinima,
      'parcelas_maximas': instance.parcelasMaximas,
      'condicoes_parcelamento': instance.condicoesParcelamento,
      'quadra': instance.quadra,
    };

_PredioModel _$PredioModelFromJson(Map<String, dynamic> json) => _PredioModel(
  nome: json['nome'] as String?,
  andares: (json['andares'] as num?)?.toInt(),
  unidadesPorAndar: (json['unidades_por_andar'] as num?)?.toInt(),
  ano: (json['ano'] as num?)?.toInt(),
  elevadores: (json['elevadores'] as num?)?.toInt(),
  portaria24h: json['portaria_24h'] as bool?,
  piscina: json['piscina'] as bool?,
  academia: json['academia'] as bool?,
  salaoDeFestas: json['salao_de_festas'] as bool?,
  playground: json['playground'] as bool?,
);

Map<String, dynamic> _$PredioModelToJson(_PredioModel instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'andares': instance.andares,
      'unidades_por_andar': instance.unidadesPorAndar,
      'ano': instance.ano,
      'elevadores': instance.elevadores,
      'portaria_24h': instance.portaria24h,
      'piscina': instance.piscina,
      'academia': instance.academia,
      'salao_de_festas': instance.salaoDeFestas,
      'playground': instance.playground,
    };

_QuadraModel _$QuadraModelFromJson(Map<String, dynamic> json) => _QuadraModel(
  identificacao: json['identificacao'] as String?,
  loteamento: json['loteamento'] == null
      ? null
      : LoteamentoModel.fromJson(json['loteamento'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuadraModelToJson(_QuadraModel instance) =>
    <String, dynamic>{
      'identificacao': instance.identificacao,
      'loteamento': instance.loteamento,
    };

_LoteamentoModel _$LoteamentoModelFromJson(Map<String, dynamic> json) =>
    _LoteamentoModel(
      nome: json['nome'] as String?,
      incorporadora: json['incorporadora'] as String?,
      asfalto: json['asfalto'] as bool?,
      agua: json['agua'] as bool?,
      energia: json['energia'] as bool?,
      esgoto: json['esgoto'] as bool?,
      iluminacao: json['iluminacao'] as bool?,
      areasDeLazer: json['areas_de_lazer'] as String?,
    );

Map<String, dynamic> _$LoteamentoModelToJson(_LoteamentoModel instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'incorporadora': instance.incorporadora,
      'asfalto': instance.asfalto,
      'agua': instance.agua,
      'energia': instance.energia,
      'esgoto': instance.esgoto,
      'iluminacao': instance.iluminacao,
      'areas_de_lazer': instance.areasDeLazer,
    };
