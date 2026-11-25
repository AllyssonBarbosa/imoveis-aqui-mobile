import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/acervo_por_corretor.dart';

part 'acervo_por_corretor_model.freezed.dart';
part 'acervo_por_corretor_model.g.dart';

/// Linha de `GET /api/relatorios/acervo/por-corretor/` (§18.2): as 4 chaves que
/// o app lê. Todas obrigatórias: wire malformado lança no `fromJson` e o
/// repositório converte em falha tipada (T-12-12).
@freezed
abstract class LinhaAcervoCorretorModel with _$LinhaAcervoCorretorModel {
  const LinhaAcervoCorretorModel._();

  const factory LinhaAcervoCorretorModel({
    @JsonKey(name: 'corretor_id') required int corretorId,
    required String corretor,
    required bool ativo,
    required int total,
  }) = _LinhaAcervoCorretorModel;

  factory LinhaAcervoCorretorModel.fromJson(Map<String, Object?> json) =>
      _$LinhaAcervoCorretorModelFromJson(json);

  /// Mapeia para a entidade; `nome` recebe o texto de `corretor` (D-13).
  AcervoDoCorretor paraEntidade() => AcervoDoCorretor(
    corretorId: corretorId,
    nome: corretor,
    ativo: ativo,
    total: total,
  );
}

/// Envelope de `GET /api/relatorios/acervo/por-corretor/`: [linhas] na ordem do
/// servidor e o [total] como veio (D-13).
@freezed
abstract class AcervoPorCorretorModel with _$AcervoPorCorretorModel {
  const AcervoPorCorretorModel._();

  const factory AcervoPorCorretorModel({
    required List<LinhaAcervoCorretorModel> linhas,
    required int total,
  }) = _AcervoPorCorretorModel;

  factory AcervoPorCorretorModel.fromJson(Map<String, Object?> json) =>
      _$AcervoPorCorretorModelFromJson(json);

  /// Mapeia para a entidade, preservando a ordem recebida; o total não é
  /// recalculado.
  AcervoPorCorretor paraEntidade() => AcervoPorCorretor(
    linhas: [for (final linha in linhas) linha.paraEntidade()],
    total: total,
  );
}
