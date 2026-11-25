import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/situacao_imovel.dart';
import 'codigos_imovel_api.dart';

part 'mudancas_recentes_model.freezed.dart';
part 'mudancas_recentes_model.g.dart';

/// Item de `GET /api/relatorios/mudancas-situacao/` (§18.4, §18.5): as 9 chaves
/// que a tela usa. Diferente do histórico da APP-09, aqui situação
/// desconhecida é falha de formato (D-24), não `null`.
@freezed
abstract class MudancaRecenteModel with _$MudancaRecenteModel {
  const MudancaRecenteModel._();

  const factory MudancaRecenteModel({
    required int id,
    @JsonKey(name: 'imovel_id') required int imovelId,
    @JsonKey(name: 'imovel_codigo') required String imovelCodigo,
    @JsonKey(name: 'imovel_titulo') required String imovelTitulo,
    @JsonKey(name: 'situacao_anterior') required String situacaoAnterior,
    @JsonKey(name: 'situacao_nova') required String situacaoNova,
    @JsonKey(name: 'alterado_por') required String alteradoPor,
    @JsonKey(name: 'alterado_em') required String alteradoEm,
    @Default('') String observacao,
  }) = _MudancaRecenteModel;

  factory MudancaRecenteModel.fromJson(Map<String, Object?> json) =>
      _$MudancaRecenteModelFromJson(json);

  /// Mapeia para a entidade. As situações passam pelo mapa único de
  /// `codigos_imovel_api.dart`; código desconhecido lança [FormatException]
  /// (D-24, T-12-12). `alterado_em` vira instante UTC (D-21): a hora local só
  /// existe na apresentação; data inválida também lança [FormatException].
  MudancaRecente paraEntidade() {
    return MudancaRecente(
      id: id,
      imovelId: imovelId,
      imovelCodigo: imovelCodigo,
      imovelTitulo: imovelTitulo,
      situacaoAnterior: _situacaoEstrita(situacaoAnterior),
      situacaoNova: _situacaoEstrita(situacaoNova),
      alteradoPor: alteradoPor,
      alteradoEm: DateTime.parse(alteradoEm).toUtc(),
      observacao: observacao,
    );
  }
}

SituacaoImovel _situacaoEstrita(String codigo) =>
    situacaoDoCodigo(codigo) ??
    (throw FormatException('situação desconhecida na mudança: $codigo'));

/// Envelope de `GET /api/relatorios/mudancas-situacao/`: [dias] é a janela que
/// o servidor aplicou (D-19) e [mudancas] vem na ordem do servidor. A chave
/// `desde` do wire é ignorada.
@freezed
abstract class MudancasRecentesModel with _$MudancasRecentesModel {
  const MudancasRecentesModel._();

  const factory MudancasRecentesModel({
    required int dias,
    required List<MudancaRecenteModel> mudancas,
  }) = _MudancasRecentesModel;

  factory MudancasRecentesModel.fromJson(Map<String, Object?> json) =>
      _$MudancasRecentesModelFromJson(json);

  /// Mapeia para a entidade, preservando a ordem recebida.
  MudancasRecentes paraEntidade() => MudancasRecentes(
    dias: dias,
    mudancas: [for (final mudanca in mudancas) mudanca.paraEntidade()],
  );
}
