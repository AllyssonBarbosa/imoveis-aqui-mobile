import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/contatos_por_corretor.dart';

part 'contatos_por_corretor_model.freezed.dart';
part 'contatos_por_corretor_model.g.dart';

/// Linha de `GET /api/relatorios/contatos/` (§18.3). `corretor_id`, `corretor`
/// e `ativo` são anuláveis porque a linha da empresa (contato que caiu na
/// empresa por corretor desativado no clique) vem sem corretor.
@freezed
abstract class LinhaContatosCorretorModel with _$LinhaContatosCorretorModel {
  const LinhaContatosCorretorModel._();

  const factory LinhaContatosCorretorModel({
    @JsonKey(name: 'corretor_id') int? corretorId,
    String? corretor,
    bool? ativo,
    required int total,
    required int pendentes,
  }) = _LinhaContatosCorretorModel;

  factory LinhaContatosCorretorModel.fromJson(Map<String, Object?> json) =>
      _$LinhaContatosCorretorModelFromJson(json);

  /// Mapeia para a entidade. Linha da empresa (`corretor_id` nulo): NÃO repassa
  /// `corretor` nem `ativo` — a tela usa texto fixo, nunca o do servidor
  /// (D-17, T-12-13).
  ContatosDoCorretor paraEntidade() {
    final id = corretorId;
    if (id == null) {
      return ContatosDoCorretor(total: total, pendentes: pendentes);
    }
    return ContatosDoCorretor(
      corretorId: id,
      nome: corretor,
      ativo: ativo,
      total: total,
      pendentes: pendentes,
    );
  }
}

/// Envelope de `GET /api/relatorios/contatos/`: [linhas] na ordem do servidor,
/// com [total] e [pendentes] como vieram. As chaves `de` e `ate` do wire são
/// ignoradas: a tela mostra o período que o próprio usuário escolheu (D-16).
@freezed
abstract class ContatosPorCorretorModel with _$ContatosPorCorretorModel {
  const ContatosPorCorretorModel._();

  const factory ContatosPorCorretorModel({
    required List<LinhaContatosCorretorModel> linhas,
    required int total,
    required int pendentes,
  }) = _ContatosPorCorretorModel;

  factory ContatosPorCorretorModel.fromJson(Map<String, Object?> json) =>
      _$ContatosPorCorretorModelFromJson(json);

  /// Mapeia para a entidade, preservando a ordem recebida; os totais não são
  /// recalculados.
  ContatosPorCorretor paraEntidade() => ContatosPorCorretor(
    linhas: [for (final linha in linhas) linha.paraEntidade()],
    total: total,
    pendentes: pendentes,
  );
}
