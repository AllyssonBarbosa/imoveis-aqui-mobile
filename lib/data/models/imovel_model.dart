import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel.dart';
import 'cidade_model.dart';

part 'imovel_model.freezed.dart';
part 'imovel_model.g.dart';

/// Modelo de transporte para uma linha de `GET /imoveis` (contrato §3.1 +
/// §3.2), hoje servida por `ImovelMockDataSource` (D-14) e futuramente pelo
/// endpoint real (Fase 4, API-04). Campos PENDENTE E2 (`natureza`, `quartos`,
/// `suites`, `vagas`, `area`) ficam nullable até o backend confirmar o campo
/// real.
@freezed
abstract class ImovelModel with _$ImovelModel {
  const ImovelModel._();

  const factory ImovelModel({
    required int id,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    required String descricao,
    required String bairro,
    required CidadeModel cidade,
    @JsonKey(name: 'foto_capa') String? fotoCapa,
    required List<String> caracteristicas,
    @JsonKey(name: 'criado_em') required String criadoEm,
    String? natureza,
    int? quartos,
    int? suites,
    int? vagas,
    String? area,
  }) = _ImovelModel;

  factory ImovelModel.fromJson(Map<String, Object?> json) =>
      _$ImovelModelFromJson(json);

  /// Mapeia para a entidade de domínio. `finalidade` desconhecida lança
  /// [FormatException] — o repositório converte em `Result.failure`
  /// (T-02-01-01); `natureza` desconhecida ou ausente vira `null`.
  Imovel paraEntidade() {
    return Imovel(
      id: id,
      titulo: titulo,
      finalidade: _mapearFinalidade(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      bairro: bairro,
      cidade: cidade.paraEntidade(),
      fotoCapa: fotoCapa,
      natureza: _mapearNatureza(natureza),
      quartos: quartos,
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
