import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dados_natureza.dart';

part 'dados_natureza_model.freezed.dart';
part 'dados_natureza_model.g.dart';

/// Bloco `casa` do detalhe no formato de transporte. Todos os campos são
/// opcionais (D-14); chaves extras do JSON são ignoradas.
@freezed
abstract class CasaModel with _$CasaModel {
  const CasaModel._();

  const factory CasaModel({
    @JsonKey(name: 'area_terreno') String? areaTerreno,
    @JsonKey(name: 'area_construida') String? areaConstruida,
    @JsonKey(name: 'area_livre') String? areaLivre,
    int? quartos,
    int? suites,
    int? banheiros,
    int? salas,
    int? vagas,
    int? pavimentos,
    @JsonKey(name: 'ano_construcao') int? anoConstrucao,
    bool? piscina,
    bool? quintal,
    bool? churrasqueira,
    bool? mobiliada,
  }) = _CasaModel;

  factory CasaModel.fromJson(Map<String, Object?> json) =>
      _$CasaModelFromJson(json);

  /// Copia os valores como vieram — `area_livre` inclusive (D-04).
  DadosNatureza paraEntidade() => DadosNatureza.casa(
    areaTerreno: areaTerreno,
    areaConstruida: areaConstruida,
    areaLivre: areaLivre,
    quartos: quartos,
    suites: suites,
    banheiros: banheiros,
    salas: salas,
    vagas: vagas,
    pavimentos: pavimentos,
    anoConstrucao: anoConstrucao,
    piscina: piscina,
    quintal: quintal,
    churrasqueira: churrasqueira,
    mobiliada: mobiliada,
  );
}

/// Bloco `terreno` do detalhe no formato de transporte.
@freezed
abstract class TerrenoModel with _$TerrenoModel {
  const TerrenoModel._();

  const factory TerrenoModel({
    @JsonKey(name: 'area_total') String? areaTotal,
    String? frente,
    String? fundo,
    String? laterais,
    String? topografia,
    bool? murado,
    bool? esquina,
    @JsonKey(name: 'uso_permitido') String? usoPermitido,
  }) = _TerrenoModel;

  factory TerrenoModel.fromJson(Map<String, Object?> json) =>
      _$TerrenoModelFromJson(json);

  /// `topografia` desconhecida ou ausente vira `null`, sem derrubar o parse.
  DadosNatureza paraEntidade() => DadosNatureza.terreno(
    areaTotal: areaTotal,
    frente: frente,
    fundo: fundo,
    laterais: laterais,
    topografia: _mapearTopografia(topografia),
    murado: murado,
    esquina: esquina,
    usoPermitido: usoPermitido,
  );

  static Topografia? _mapearTopografia(String? valor) {
    switch (valor) {
      case 'PLANO':
        return Topografia.plano;
      case 'ACLIVE':
        return Topografia.aclive;
      case 'DECLIVE':
        return Topografia.declive;
      default:
        return null;
    }
  }
}

/// Bloco `apartamento` do detalhe no formato de transporte.
/// `posicao_solar` é o texto da API, sem enum no app (D-19 b).
@freezed
abstract class ApartamentoModel with _$ApartamentoModel {
  const ApartamentoModel._();

  const factory ApartamentoModel({
    int? andar,
    String? numero,
    @JsonKey(name: 'area_privativa') String? areaPrivativa,
    @JsonKey(name: 'area_total') String? areaTotal,
    int? quartos,
    int? suites,
    int? banheiros,
    int? vagas,
    bool? varanda,
    @JsonKey(name: 'posicao_solar') String? posicaoSolar,
  }) = _ApartamentoModel;

  factory ApartamentoModel.fromJson(Map<String, Object?> json) =>
      _$ApartamentoModelFromJson(json);

  DadosNatureza paraEntidade() => DadosNatureza.apartamento(
    andar: andar,
    numero: numero,
    areaPrivativa: areaPrivativa,
    areaTotal: areaTotal,
    quartos: quartos,
    suites: suites,
    banheiros: banheiros,
    vagas: vagas,
    varanda: varanda,
    posicaoSolar: posicaoSolar,
  );
}

/// Bloco `lote` do detalhe no formato de transporte. `preco` só vem quando o
/// servidor manda e nunca é derivado de outro campo (D-19 d).
@freezed
abstract class LoteModel with _$LoteModel {
  const LoteModel._();

  const factory LoteModel({
    String? numero,
    String? area,
    String? frente,
    String? fundo,
    String? preco,
    @JsonKey(name: 'condicoes_parcelamento') String? condicoesParcelamento,
  }) = _LoteModel;

  factory LoteModel.fromJson(Map<String, Object?> json) =>
      _$LoteModelFromJson(json);

  DadosNatureza paraEntidade() => DadosNatureza.lote(
    numero: numero,
    area: area,
    frente: frente,
    fundo: fundo,
    preco: preco,
    condicoesParcelamento: condicoesParcelamento,
  );
}
