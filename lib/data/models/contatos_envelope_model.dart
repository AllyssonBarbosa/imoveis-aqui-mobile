import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/pagina_contatos.dart';
import 'contato_recebido_model.dart';

part 'contatos_envelope_model.freezed.dart';
part 'contatos_envelope_model.g.dart';

/// Envelope `PageNumberPagination` de `GET /api/contatos/` (caixa de contatos,
/// §16): `count` é ignorado; `next` é uma URL absoluta ou nulo — não-genérico
/// de propósito, como `AcervoEnvelopeModel`.
@freezed
abstract class ContatosEnvelopeModel with _$ContatosEnvelopeModel {
  const ContatosEnvelopeModel._();

  const factory ContatosEnvelopeModel({
    String? next,
    String? previous,
    required List<ContatoRecebidoModel> results,
  }) = _ContatosEnvelopeModel;

  factory ContatosEnvelopeModel.fromJson(Map<String, Object?> json) =>
      _$ContatosEnvelopeModelFromJson(json);

  /// Mapeia para a página de domínio — guarda só o que chega (D-08); `next`
  /// continua opaco, nunca interpretado fora da camada `data/`.
  PaginaContatos paraPagina() => PaginaContatos(
    itens: results.map((modelo) => modelo.paraEntidade()).toList(),
    proximaPagina: next,
  );
}
