import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/contato_recebido.dart';
import 'canal_contato_api.dart';
import 'retorno_contato_api.dart';

part 'contato_recebido_model.freezed.dart';
part 'contato_recebido_model.g.dart';

/// Modelo de transporte para um item da caixa de contatos do corretor
/// (`GET /api/contatos/` e o 200 do `PATCH`, §17.2).
///
/// Lê só o que o app usa (D-09): imóvel (código e título), canal, quando
/// chegou e o retorno anotado. As chaves a mais são ignoradas de propósito —
/// inclusive os campos de exibição do servidor (os textos da tela são fixos
/// do app, D-10) e `imovel`/`corretor`/`corretor_nome`, que o app não exibe.
@freezed
abstract class ContatoRecebidoModel with _$ContatoRecebidoModel {
  const ContatoRecebidoModel._();

  const factory ContatoRecebidoModel({
    required int id,
    @JsonKey(name: 'imovel_codigo') required String imovelCodigo,
    @JsonKey(name: 'imovel_titulo') required String imovelTitulo,
    required String canal,
    @JsonKey(name: 'criado_em') required String criadoEm,
    required String retorno,
    @JsonKey(name: 'retorno_em') String? retornoEm,
  }) = _ContatoRecebidoModel;

  factory ContatoRecebidoModel.fromJson(Map<String, Object?> json) =>
      _$ContatoRecebidoModelFromJson(json);

  /// Mapeia para a entidade de domínio. `canal` ou `retorno` fora do conjunto
  /// conhecido lançam [FormatException] (o repositório converte em falha).
  ///
  /// Este é o ÚNICO ponto onde as datas viram a hora local do aparelho
  /// (`toLocal()`, Achado 7 da pesquisa): o servidor manda o instante com
  /// offset de São Paulo, e a tela só formata o que já é local.
  ContatoRecebido paraEntidade() {
    return ContatoRecebido(
      id: id,
      imovelCodigo: imovelCodigo,
      imovelTitulo: imovelTitulo,
      canal: canalContatoDaApi(canal),
      criadoEm: DateTime.parse(criadoEm).toLocal(),
      retorno: retornoContatoDaApi(retorno),
      retornoEm: retornoEm == null
          ? null
          : DateTime.parse(retornoEm!).toLocal(),
    );
  }
}
