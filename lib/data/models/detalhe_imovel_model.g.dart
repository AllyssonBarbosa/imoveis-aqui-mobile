// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalhe_imovel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetalheImovelModel _$DetalheImovelModelFromJson(
  Map<String, dynamic> json,
) => _DetalheImovelModel(
  id: (json['id'] as num).toInt(),
  titulo: json['titulo'] as String,
  finalidade: json['finalidade'] as String,
  precoVenda: json['preco_venda'] as String?,
  precoAluguel: json['preco_aluguel'] as String?,
  precoCondominio: json['preco_condominio'] as String?,
  precoIptu: json['preco_iptu'] as String?,
  descricao: json['descricao'] as String,
  endereco: json['endereco'] == null
      ? null
      : EnderecoPublicoModel.fromJson(json['endereco'] as Map<String, dynamic>),
  fotos:
      (json['fotos'] as List<dynamic>?)
          ?.map((e) => FotoImovelModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FotoImovelModel>[],
  caracteristicas:
      (json['caracteristicas'] as List<dynamic>?)
          ?.map((e) => CaracteristicaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CaracteristicaModel>[],
  corretor: json['corretor_responsavel'] == null
      ? null
      : CorretorModel.fromJson(
          json['corretor_responsavel'] as Map<String, dynamic>,
        ),
  natureza: json['natureza'] as String?,
  casa: json['casa'] == null
      ? null
      : CasaModel.fromJson(json['casa'] as Map<String, dynamic>),
  apartamento: json['apartamento'] == null
      ? null
      : ApartamentoModel.fromJson(json['apartamento'] as Map<String, dynamic>),
  terreno: json['terreno'] == null
      ? null
      : TerrenoModel.fromJson(json['terreno'] as Map<String, dynamic>),
  lote: json['lote'] == null
      ? null
      : LoteModel.fromJson(json['lote'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DetalheImovelModelToJson(_DetalheImovelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'finalidade': instance.finalidade,
      'preco_venda': instance.precoVenda,
      'preco_aluguel': instance.precoAluguel,
      'preco_condominio': instance.precoCondominio,
      'preco_iptu': instance.precoIptu,
      'descricao': instance.descricao,
      'endereco': instance.endereco,
      'fotos': instance.fotos,
      'caracteristicas': instance.caracteristicas,
      'corretor_responsavel': instance.corretor,
      'natureza': instance.natureza,
      'casa': instance.casa,
      'apartamento': instance.apartamento,
      'terreno': instance.terreno,
      'lote': instance.lote,
    };

_EnderecoPublicoModel _$EnderecoPublicoModelFromJson(
  Map<String, dynamic> json,
) => _EnderecoPublicoModel(
  logradouro: json['logradouro'] as String?,
  numero: json['numero'] as String?,
  bairro: json['bairro'] as String?,
  cep: json['cep'] as String?,
  cidade: json['cidade'] == null
      ? null
      : CidadeModel.fromJson(json['cidade'] as Map<String, dynamic>),
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
);

Map<String, dynamic> _$EnderecoPublicoModelToJson(
  _EnderecoPublicoModel instance,
) => <String, dynamic>{
  'logradouro': instance.logradouro,
  'numero': instance.numero,
  'bairro': instance.bairro,
  'cep': instance.cep,
  'cidade': instance.cidade,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_FotoImovelModel _$FotoImovelModelFromJson(Map<String, dynamic> json) =>
    _FotoImovelModel(
      url: json['imagem'] as String,
      ordem: (json['ordem'] as num).toInt(),
      capa: json['capa'] as bool,
    );

Map<String, dynamic> _$FotoImovelModelToJson(_FotoImovelModel instance) =>
    <String, dynamic>{
      'imagem': instance.url,
      'ordem': instance.ordem,
      'capa': instance.capa,
    };

_CorretorModel _$CorretorModelFromJson(Map<String, dynamic> json) =>
    _CorretorModel(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      foto: json['foto'] as String?,
    );

Map<String, dynamic> _$CorretorModelToJson(_CorretorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'foto': instance.foto,
    };
