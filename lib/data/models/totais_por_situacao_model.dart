import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/situacao_imovel.dart';
import '../../domain/entities/totais_por_situacao.dart';
import 'codigos_imovel_api.dart';

part 'totais_por_situacao_model.freezed.dart';
part 'totais_por_situacao_model.g.dart';

/// Modelo de transporte de `GET /api/relatorios/acervo/` (§18.1): lê só as
/// chaves `totais` e `total` (D-09). As chaves `situacoes` e `linhas` do wire
/// (rótulos e quebra por natureza) são ignoradas na desserialização e nunca
/// ficam em memória.
@freezed
abstract class TotaisPorSituacaoModel with _$TotaisPorSituacaoModel {
  const TotaisPorSituacaoModel._();

  const factory TotaisPorSituacaoModel({
    required Map<String, int> totais,
    required int total,
  }) = _TotaisPorSituacaoModel;

  factory TotaisPorSituacaoModel.fromJson(Map<String, Object?> json) =>
      _$TotaisPorSituacaoModelFromJson(json);

  /// Mapeia para a entidade de domínio. Cada chave passa pelo mapa único de
  /// `codigos_imovel_api.dart`; chave desconhecida ou uma das 4 situações
  /// faltando lança [FormatException] (D-24, T-12-12). O `total` é o do
  /// servidor, sem soma no aparelho (D-10).
  TotaisPorSituacao paraEntidade() {
    final porSituacao = <SituacaoImovel, int>{};
    for (final entrada in totais.entries) {
      final situacao = situacaoDoCodigo(entrada.key);
      if (situacao == null) {
        throw FormatException('situação desconhecida nos totais: ${entrada.key}');
      }
      porSituacao[situacao] = entrada.value;
    }
    for (final situacao in SituacaoImovel.values) {
      if (!porSituacao.containsKey(situacao)) {
        throw FormatException('situação faltando nos totais: $situacao');
      }
    }
    return TotaisPorSituacao(porSituacao: porSituacao, total: total);
  }
}
