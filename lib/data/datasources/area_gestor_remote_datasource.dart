import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../models/acervo_por_corretor_model.dart';
import '../models/contatos_por_corretor_model.dart';
import '../models/mudancas_recentes_model.dart';
import '../models/totais_por_situacao_model.dart';
import 'area_gestor_datasource.dart';
import 'parametros_consulta_contatos.dart';

/// Lê os relatórios da Área do gestor (`/api/relatorios/...`) pelo `Dio`
/// `@Named('autenticado')`, o único que leva o token (D-22). Nenhuma leitura
/// leva filtro de imóvel (D-15) nem janela de dias (D-19); só os contatos
/// levam `de`/`ate`, e pelo mesmo mapeamento da caixa da APP-10.
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 401 e
/// 403), não loga e não filtra nem ordena nada.
@LazySingleton(as: AreaGestorDataSource)
class AreaGestorRemoteDataSource implements AreaGestorDataSource {
  AreaGestorRemoteDataSource(@Named('autenticado') this._dio);

  final Dio _dio;

  @override
  Future<TotaisPorSituacaoModel> obterTotaisPorSituacao() async {
    final resposta = await _dio.get<Object?>('/api/relatorios/acervo/');
    return TotaisPorSituacaoModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<AcervoPorCorretorModel> obterAcervoPorCorretor() async {
    final resposta = await _dio.get<Object?>(
      '/api/relatorios/acervo-por-corretor/',
    );
    return AcervoPorCorretorModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<ContatosPorCorretorModel> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]) async {
    final resposta = await _dio.get<Object?>(
      '/api/relatorios/contatos/',
      queryParameters: parametrosDaConsultaContatos(
        ConsultaContatos(periodo: periodo),
      ),
    );
    return ContatosPorCorretorModel.fromJson(_lerObjeto(resposta.data));
  }

  @override
  Future<MudancasRecentesModel> obterMudancasRecentes() async {
    final resposta = await _dio.get<Object?>(
      '/api/relatorios/mudancas-situacao/',
    );
    return MudancasRecentesModel.fromJson(_lerObjeto(resposta.data));
  }

  Map<String, Object?> _lerObjeto(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do relatório não é um objeto JSON.');
    }
    return corpo;
  }
}
