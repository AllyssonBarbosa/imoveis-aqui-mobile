import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/entities/imovel.dart';
import 'cidade_model.dart';

part 'detalhe_imovel_model.freezed.dart';
part 'detalhe_imovel_model.g.dart';

/// Modelo de transporte do detalhe de um imóvel
/// (`GET /api/publico/imoveis/{id}/`), hoje servido por
/// `ImovelDetalheMockDataSource` e futuramente pelo endpoint real (API-07).
/// Declara só os campos públicos (D-06): qualquer chave extra do JSON é
/// ignorada pelo `json_serializable`, então nenhum dado privado vaza para o
/// app.
@freezed
abstract class DetalheImovelModel with _$DetalheImovelModel {
  const DetalheImovelModel._();

  const factory DetalheImovelModel({
    required int id,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    @JsonKey(name: 'preco_condominio') String? precoCondominio,
    @JsonKey(name: 'preco_iptu') String? precoIptu,
    required String descricao,
    required String bairro,
    required CidadeModel cidade,
    String? latitude,
    String? longitude,
    @Default(<FotoImovelModel>[]) List<FotoImovelModel> fotos,
    @Default(<String>[]) List<String> caracteristicas,
    CorretorModel? corretor,
    String? natureza,
  }) = _DetalheImovelModel;

  factory DetalheImovelModel.fromJson(Map<String, Object?> json) =>
      _$DetalheImovelModelFromJson(json);

  /// Mapeia para a entidade de domínio. `finalidade` desconhecida lança
  /// [FormatException] (o repositório converte em `Result.failure`);
  /// `natureza` desconhecida ou ausente vira `null`. As fotos mantêm a ordem
  /// recebida — o app nunca reordena.
  DetalheImovel paraEntidade() {
    return DetalheImovel(
      id: id,
      titulo: titulo,
      finalidade: _mapearFinalidade(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      precoCondominio: precoCondominio,
      precoIptu: precoIptu,
      descricao: descricao,
      bairro: bairro,
      cidade: cidade.paraEntidade(),
      latitude: latitude,
      longitude: longitude,
      fotos: [for (final foto in fotos) foto.paraEntidade()],
      caracteristicas: caracteristicas,
      corretor: corretor?.paraEntidade(),
      natureza: _mapearNatureza(natureza),
    );
  }

  static FinalidadeImovel _mapearFinalidade(String valor) {
    switch (valor) {
      case 'VENDA':
        return FinalidadeImovel.venda;
      case 'ALUGUEL':
        return FinalidadeImovel.aluguel;
      case 'VENDA_E_ALUGUEL':
        return FinalidadeImovel.vendaEAluguel;
      default:
        throw FormatException('finalidade desconhecida: $valor');
    }
  }

  static NaturezaImovel? _mapearNatureza(String? valor) {
    switch (valor) {
      case 'CASA':
        return NaturezaImovel.casa;
      case 'APARTAMENTO':
        return NaturezaImovel.apartamento;
      case 'TERRENO':
        return NaturezaImovel.terreno;
      case 'LOTE':
        return NaturezaImovel.lote;
      default:
        return null;
    }
  }
}

/// Foto da galeria no formato de transporte; `ordem` vem do servidor.
@freezed
abstract class FotoImovelModel with _$FotoImovelModel {
  const FotoImovelModel._();

  const factory FotoImovelModel({
    required String url,
    required bool capa,
    required int ordem,
  }) = _FotoImovelModel;

  factory FotoImovelModel.fromJson(Map<String, Object?> json) =>
      _$FotoImovelModelFromJson(json);

  FotoImovel paraEntidade() => FotoImovel(url: url, capa: capa);
}

/// Corretor responsável no formato de transporte.
@freezed
abstract class CorretorModel with _$CorretorModel {
  const CorretorModel._();

  const factory CorretorModel({
    required int id,
    required String nome,
    String? foto,
    String? slug,
  }) = _CorretorModel;

  factory CorretorModel.fromJson(Map<String, Object?> json) =>
      _$CorretorModelFromJson(json);

  CorretorResponsavel paraEntidade() =>
      CorretorResponsavel(id: id, nome: nome, foto: foto, slug: slug);
}
