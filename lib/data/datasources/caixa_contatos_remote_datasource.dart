import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/retorno_contato.dart';
import '../models/contato_recebido_model.dart';
import '../models/contatos_envelope_model.dart';
import '../models/imovel_com_contato_model.dart';
import '../models/resumo_contatos_model.dart';
import '../models/retorno_contato_api.dart';
import '../network/mesma_origem.dart';
import 'caixa_contatos_datasource.dart';
import 'parametros_consulta_contatos.dart';

/// Lê e altera a caixa de contatos (`/api/contatos/...`) pelo `Dio`
/// `@Named('autenticado')`, o único que leva o token (D-23). Os filtros vão na
/// query (D-19, D-20) e a paginação segue o `next` absoluto da resposta
/// (D-12), seguido tal e qual e só se tiver a mesma origem da base URL: a
/// credencial nunca sai da origem da API (T-08-30).
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 401,
/// 403, 404 e demais), não loga e não aplica nenhum filtro nem ordenação local.
@LazySingleton(as: CaixaContatosDataSource)
class CaixaContatosRemoteDataSource implements CaixaContatosDataSource {
  CaixaContatosRemoteDataSource(@Named('autenticado') this._dio);

  final Dio _dio;

  @override
  Future<ContatosEnvelopeModel> buscar(ConsultaContatos consulta) async {
    final resposta = await _dio.get<Object?>(
      '/api/contatos/',
      queryParameters: parametrosDaConsultaContatos(consulta),
    );
    return ContatosEnvelopeModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<ContatosEnvelopeModel> seguir(String proximaPagina) async {
    if (!mesmaOrigem(
      Uri.parse(proximaPagina),
      Uri.parse(_dio.options.baseUrl),
    )) {
      throw const FormatException(
        'URL "next" da caixa aponta para outra origem.',
      );
    }
    final resposta = await _dio.get<Object?>(proximaPagina);
    return ContatosEnvelopeModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<ResumoContatosModel> contarSemRetorno() async {
    final resposta = await _dio.get<Object?>('/api/contatos/resumo/');
    return ResumoContatosModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<List<ImovelComContatoModel>> listarImoveis() async {
    final resposta = await _dio.get<Object?>('/api/contatos/imoveis/');
    return _lerLista(resposta.data)
        .map(ImovelComContatoModel.fromJson)
        .toList();
  }

  @override
  Future<ContatoRecebidoModel> anotarRetorno(
    int id,
    RetornoContato retorno,
  ) async {
    // Barra final obrigatória: o Dio autenticado tem `followRedirects: false` e
    // o APPEND_SLASH do Django não redireciona PATCH (Pitfall 2).
    final resposta = await _dio.patch<Object?>(
      '/api/contatos/$id/',
      data: {'retorno': retorno.valorApi},
    );
    return ContatoRecebidoModel.fromJson(_lerObjeto(resposta.data));
  }

  Map<String, Object?> _lerObjeto(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo da caixa não é um objeto JSON.');
    }
    return corpo;
  }

  List<Map<String, Object?>> _lerLista(Object? corpo) {
    if (corpo is! List<Object?>) {
      throw const FormatException('Corpo da caixa não é uma lista JSON.');
    }
    return corpo.map((elemento) {
      if (elemento is! Map<String, dynamic>) {
        throw const FormatException('Item da caixa não é um objeto JSON.');
      }
      return elemento;
    }).toList();
  }
}
