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
    @JsonKey(name: 'lateral_esquerda') String? lateralEsquerda,
    @JsonKey(name: 'lateral_direita') String? lateralDireita,
    @JsonKey(name: 'topografia') String? topografia,
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
    lateralEsquerda: lateralEsquerda,
    lateralDireita: lateralDireita,
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
/// `posicao_solar` chega como código e segue assim até a apresentação (A-04).
@freezed
abstract class ApartamentoModel with _$ApartamentoModel {
  const ApartamentoModel._();

  const factory ApartamentoModel({
    int? andar,
    @JsonKey(name: 'area_privativa') String? areaPrivativa,
    @JsonKey(name: 'area_total') String? areaTotal,
    int? quartos,
    int? suites,
    int? banheiros,
    int? vagas,
    bool? varanda,
    @JsonKey(name: 'posicao_solar') String? posicaoSolar,
    PredioModel? predio,
  }) = _ApartamentoModel;

  factory ApartamentoModel.fromJson(Map<String, Object?> json) =>
      _$ApartamentoModelFromJson(json);

  DadosNatureza paraEntidade() => DadosNatureza.apartamento(
    andar: andar,
    areaPrivativa: areaPrivativa,
    areaTotal: areaTotal,
    quartos: quartos,
    suites: suites,
    banheiros: banheiros,
    vagas: vagas,
    varanda: varanda,
    posicaoSolar: posicaoSolar,
    predio: predio?.paraEntidade(),
  );
}

/// Bloco `lote` do detalhe no formato de transporte. O lote não tem preço
/// próprio: o preço é o de venda do imóvel (§11.5 d).
@freezed
abstract class LoteModel with _$LoteModel {
  const LoteModel._();

  const factory LoteModel({
    String? numero,
    String? area,
    String? frente,
    String? fundo,
    @JsonKey(name: 'entrada_minima') String? entradaMinima,
    @JsonKey(name: 'parcelas_maximas') int? parcelasMaximas,
    @JsonKey(name: 'condicoes_parcelamento') String? condicoesParcelamento,
    QuadraModel? quadra,
  }) = _LoteModel;

  factory LoteModel.fromJson(Map<String, Object?> json) =>
      _$LoteModelFromJson(json);

  DadosNatureza paraEntidade() => DadosNatureza.lote(
    numero: numero,
    area: area,
    frente: frente,
    fundo: fundo,
    entradaMinima: entradaMinima,
    parcelasMaximas: parcelasMaximas,
    condicoesParcelamento: condicoesParcelamento,
    quadra: quadra?.paraEntidade(),
  );
}

/// Prédio embutido em `apartamento.predio` no formato de transporte.
@freezed
abstract class PredioModel with _$PredioModel {
  const PredioModel._();

  const factory PredioModel({
    String? nome,
    int? andares,
    @JsonKey(name: 'ano_construcao') int? anoConstrucao,
    int? elevadores,
    @JsonKey(name: 'portaria_24h') bool? portaria24h,
    bool? piscina,
    bool? academia,
    @JsonKey(name: 'salao_de_festas') bool? salaoDeFestas,
    bool? playground,
  }) = _PredioModel;

  factory PredioModel.fromJson(Map<String, Object?> json) =>
      _$PredioModelFromJson(json);

  DadosPredio paraEntidade() => DadosPredio(
    nome: nome,
    andares: andares,
    anoConstrucao: anoConstrucao,
    elevadores: elevadores,
    portaria24h: portaria24h,
    piscina: piscina,
    academia: academia,
    salaoDeFestas: salaoDeFestas,
    playground: playground,
  );
}

/// Quadra embutida em `lote.quadra` no formato de transporte.
@freezed
abstract class QuadraModel with _$QuadraModel {
  const QuadraModel._();

  const factory QuadraModel({
    String? identificacao,
    LoteamentoModel? loteamento,
  }) = _QuadraModel;

  factory QuadraModel.fromJson(Map<String, Object?> json) =>
      _$QuadraModelFromJson(json);

  DadosQuadra paraEntidade() => DadosQuadra(
    identificacao: identificacao,
    loteamento: loteamento?.paraEntidade(),
  );
}

/// Loteamento embutido em `quadra.loteamento` no formato de transporte. A API
/// manda a infraestrutura como cinco booleanos; a tradução para rótulos (só os
/// verdadeiros, em ordem fixa) fica aqui em data/ (A-03). `areas_de_lazer` é
/// texto corrido e nunca é dividido.
@freezed
abstract class LoteamentoModel with _$LoteamentoModel {
  const LoteamentoModel._();

  const factory LoteamentoModel({
    String? nome,
    String? incorporadora,
    bool? asfalto,
    bool? agua,
    bool? energia,
    bool? esgoto,
    bool? iluminacao,
    @JsonKey(name: 'areas_de_lazer') String? areasDeLazer,
  }) = _LoteamentoModel;

  factory LoteamentoModel.fromJson(Map<String, Object?> json) =>
      _$LoteamentoModelFromJson(json);

  DadosLoteamento paraEntidade() => DadosLoteamento(
    nome: nome,
    incorporadora: incorporadora,
    infraestrutura: [
      if (asfalto == true) 'Asfalto',
      if (agua == true) 'Água',
      if (energia == true) 'Energia',
      if (esgoto == true) 'Esgoto',
      if (iluminacao == true) 'Iluminação pública',
    ],
    areasDeLazer: (areasDeLazer?.trim().isEmpty ?? true) ? null : areasDeLazer,
  );
}
