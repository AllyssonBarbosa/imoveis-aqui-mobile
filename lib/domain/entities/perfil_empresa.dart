import 'package:freezed_annotation/freezed_annotation.dart';

import 'cidade.dart';

part 'perfil_empresa.freezed.dart';

/// Natureza da empresa anunciante, como a API informa (PERF-01).
enum TipoEmpresa { imobiliaria, autonomo }

/// Perfil público de uma empresa (PERF-01) — exatamente o que a API de perfis
/// (WEB 02) publica. Tudo chega pronto da camada de dados: textos opcionais já
/// normalizados (`null` = não veio ou veio vazio), [logomarca] já filtrada para
/// http(s) e [tipo] nulo quando a API manda um valor desconhecido (a tela não
/// mostra rótulo). A lista de corretores da empresa nunca é carregada aqui.
@freezed
abstract class PerfilEmpresa with _$PerfilEmpresa {
  const factory PerfilEmpresa({
    required int id,
    TipoEmpresa? tipo,
    required String nome,
    String? creci,
    String? telefone,
    String? whatsapp,
    String? email,
    String? descricao,
    String? logomarca,

    /// Cidades de atuação, na ordem recebida da API.
    @Default(<Cidade>[]) List<Cidade> cidadesAtuacao,
  }) = _PerfilEmpresa;
}
