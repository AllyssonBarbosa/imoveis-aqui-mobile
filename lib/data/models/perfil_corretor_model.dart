import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/perfil_corretor.dart';
import 'texto_opcional.dart';
import 'url_segura.dart';

part 'perfil_corretor_model.freezed.dart';
part 'perfil_corretor_model.g.dart';

/// Modelo de transporte do perfil público do corretor
/// (`GET /api/publico/corretores/{id}/`, WEB 02), lido pela
/// `PerfilRemoteDataSource` (WEB 02). Declara só as nove
/// chaves públicas: qualquer chave extra do JSON é ignorada pelo
/// `json_serializable`, então nenhum dado privado vaza para o app.
@freezed
abstract class PerfilCorretorModel with _$PerfilCorretorModel {
  const PerfilCorretorModel._();

  const factory PerfilCorretorModel({
    required int id,
    @JsonKey(name: 'empresa_id') int? empresaId,
    String? foto,
    required String nome,
    String? email,
    String? creci,
    String? telefone,
    String? whatsapp,
    String? apresentacao,
  }) = _PerfilCorretorModel;

  factory PerfilCorretorModel.fromJson(Map<String, Object?> json) =>
      _$PerfilCorretorModelFromJson(json);

  /// Mapeia para a entidade de domínio sem completar nem formatar nada: o
  /// nome e os ids saem como vieram, o telefone também. A foto que não for
  /// http(s) vira `null` (a tela mostra o avatar padrão) e os textos opcionais
  /// em branco viram `null` (D-01).
  PerfilCorretor paraEntidade() => PerfilCorretor(
    id: id,
    empresaId: empresaId,
    foto: urlHttpOuNula(foto),
    nome: nome,
    email: textoOuNulo(email),
    creci: textoOuNulo(creci),
    telefone: textoOuNulo(telefone),
    whatsapp: textoOuNulo(whatsapp),
    apresentacao: textoOuNulo(apresentacao),
  );
}
