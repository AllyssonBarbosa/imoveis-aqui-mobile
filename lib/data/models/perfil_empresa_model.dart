import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/perfil_empresa.dart';
import 'cidade_model.dart';
import 'texto_opcional.dart';
import 'url_segura.dart';

part 'perfil_empresa_model.freezed.dart';
part 'perfil_empresa_model.g.dart';

/// Modelo de transporte do perfil público da empresa (WEB 02). Declara só as
/// dez chaves públicas que o app usa: a lista de corretores ativos do wire
/// (`corretores_ativos`) NÃO é declarada — minimização de dados, o
/// `json_serializable` a ignora e ela nunca chega ao aparelho. Qualquer outra
/// chave extra também é ignorada.
@freezed
abstract class PerfilEmpresaModel with _$PerfilEmpresaModel {
  const PerfilEmpresaModel._();

  const factory PerfilEmpresaModel({
    required int id,
    String? tipo,
    @JsonKey(name: 'razao_social_ou_nome') required String nome,
    String? creci,
    String? telefone,
    String? whatsapp,
    String? email,
    String? descricao,
    String? logomarca,
    @JsonKey(name: 'cidades_atuacao')
    @Default(<CidadeModel>[])
    List<CidadeModel> cidadesAtuacao,
  }) = _PerfilEmpresaModel;

  factory PerfilEmpresaModel.fromJson(Map<String, Object?> json) =>
      _$PerfilEmpresaModelFromJson(json);

  /// Mapeia para a entidade de domínio sem completar nem formatar nada. O
  /// [tipo] desconhecido ou ausente vira `null` (nunca lança), a logomarca que
  /// não for http(s) vira `null` e os textos opcionais em branco viram `null`
  /// (D-01); as cidades seguem na ordem recebida.
  PerfilEmpresa paraEntidade() => PerfilEmpresa(
    id: id,
    tipo: switch (tipo) {
      'IMOBILIARIA' => TipoEmpresa.imobiliaria,
      'AUTONOMO' => TipoEmpresa.autonomo,
      _ => null,
    },
    nome: nome,
    creci: textoOuNulo(creci),
    telefone: textoOuNulo(telefone),
    whatsapp: textoOuNulo(whatsapp),
    email: textoOuNulo(email),
    descricao: textoOuNulo(descricao),
    logomarca: urlHttpOuNula(logomarca),
    cidadesAtuacao: [for (final c in cidadesAtuacao) c.paraEntidade()],
  );
}
