import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil_corretor.freezed.dart';

/// Perfil público de um corretor (PERF-04) — exatamente o que a API de perfis
/// (WEB 02) publica. Tudo chega pronto da camada de dados: textos opcionais já
/// normalizados (`null` = não veio ou veio vazio) e [foto] já filtrada para
/// http(s). O app nunca completa, infere nem formata nenhum campo — a herança
/// de contato da empresa para o corretor autônomo é regra do servidor (D-01).
@freezed
abstract class PerfilCorretor with _$PerfilCorretor {
  const factory PerfilCorretor({
    required int id,

    /// Empresa à qual o corretor pertence; `null` quando o servidor não manda.
    int? empresaId,
    String? foto,
    required String nome,
    String? email,
    String? creci,
    String? telefone,
    String? whatsapp,
    String? apresentacao,
  }) = _PerfilCorretor;
}
