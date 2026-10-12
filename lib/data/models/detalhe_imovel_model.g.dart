// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalhe_imovel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DetalheImovelModel _$DetalheImovelModelFromJson(Map<String, dynamic> json) =>
    _DetalheImovelModel(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String,
      finalidade: json['finalidade'] as String,
      precoVenda: json['preco_venda'] as String?,
      precoAluguel: json['preco_aluguel'] as String?,
      precoCondominio: json['preco_condominio'] as String?,
      precoIptu: json['preco_iptu'] as String?,
      descricao: json['descricao'] as String,
      bairro: json['bairro'] as String,
      cidade: CidadeModel.fromJson(json['cidade'] as Map<String, dynamic>),
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      fotos:
          (json['fotos'] as List<dynamic>?)
              ?.map((e) => FotoImovelModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FotoImovelModel>[],
      caracteristicas:
          (json['caracteristicas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      corretor: json['corretor'] == null
          ? null
          : CorretorModel.fromJson(json['corretor'] as Map<String, dynamic>),
      natureza: json['natureza'] as String?,
      casa: json['casa'] == null
          ? null
          : CasaModel.fromJson(json['casa'] as Map<String, dynamic>),
      apartamento: json['apartamento'] == null
          ? null
          : ApartamentoModel.fromJson(
              json['apartamento'] as Map<String, dynamic>,
            ),
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
      'bairro': instance.bairro,
      'cidade': instance.cidade,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'fotos': instance.fotos,
      'caracteristicas': instance.caracteristicas,
      'corretor': instance.corretor,
      'natureza': instance.natureza,
      'casa': instance.casa,
      'apartamento': instance.apartamento,
      'terreno': instance.terreno,
      'lote': instance.lote,
    };

_FotoImovelModel _$FotoImovelModelFromJson(Map<String, dynamic> json) =>
    _FotoImovelModel(
      url: json['url'] as String,
      capa: json['capa'] as bool,
      ordem: (json['ordem'] as num).toInt(),
    );

Map<String, dynamic> _$FotoImovelModelToJson(_FotoImovelModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'capa': instance.capa,
      'ordem': instance.ordem,
    };

_CorretorModel _$CorretorModelFromJson(Map<String, dynamic> json) =>
    _CorretorModel(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      foto: json['foto'] as String?,
      slug: json['slug'] as String?,
    );

Map<String, dynamic> _$CorretorModelToJson(_CorretorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'foto': instance.foto,
      'slug': instance.slug,
    };
