import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_datasource.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_remote_datasource.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_empresa_usecase.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_state.dart';

import '../support/api_falsa.dart';

/// Canário do DI dos perfis públicos e TRACER da fase 07.1: prova que o app de
/// verdade resolve os Cubits e use cases dos perfis, que as DataSources ativas
/// são as remotas (D-08, sem mock em produção) e que a vitrine do anunciante
/// chega até a rota aninhada do Django passando por todas as camadas (D-09).
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  /// Troca o `Dio` do DI de produção pelo da [ApiFalsa] ANTES de qualquer
  /// DataSource ser resolvida (todas são preguiçosas), para o tracer exercitar
  /// o grafo real de dependências sobre a rede falsa.
  Future<void> trocarDioPelaApiFalsa(ApiFalsa api) async {
    await configureDependencies();
    getIt.unregister<Dio>();
    getIt.registerLazySingleton<Dio>(api.criarDio);
  }

  test('resolve PerfilCorretorCubit pelo DI de produção', () async {
    await configureDependencies();

    expect(getIt<PerfilCorretorCubit>(), isA<PerfilCorretorCubit>());
  });

  test('resolve ObterPerfilCorretorUseCase pelo DI de produção', () async {
    await configureDependencies();

    expect(
      getIt<ObterPerfilCorretorUseCase>(),
      isA<ObterPerfilCorretorUseCase>(),
    );
  });

  test('resolve PerfilEmpresaCubit pelo DI de produção', () async {
    await configureDependencies();

    expect(getIt<PerfilEmpresaCubit>(), isA<PerfilEmpresaCubit>());
  });

  test('resolve ObterPerfilEmpresaUseCase pelo DI de produção', () async {
    await configureDependencies();

    expect(
      getIt<ObterPerfilEmpresaUseCase>(),
      isA<ObterPerfilEmpresaUseCase>(),
    );
  });

  test('resolve BuscarImoveisDoAnuncianteUseCase pelo DI de produção', () async {
    await configureDependencies();

    expect(
      getIt<BuscarImoveisDoAnuncianteUseCase>(),
      isA<BuscarImoveisDoAnuncianteUseCase>(),
    );
  });

  test('resolve VitrineAnuncianteCubit pelo DI de produção', () async {
    await configureDependencies();

    final cubit = getIt<VitrineAnuncianteCubit>();
    addTearDown(cubit.close);

    expect(cubit, isA<VitrineAnuncianteCubit>());
  });

  test('a PerfilDataSource ativa é a PerfilRemoteDataSource (D-08)', () async {
    await configureDependencies();

    expect(getIt<PerfilDataSource>(), isA<PerfilRemoteDataSource>());
  });

  test(
    'a VitrineAnuncianteDataSource ativa é a VitrineAnuncianteRemoteDataSource',
    () async {
      await configureDependencies();

      expect(
        getIt<VitrineAnuncianteDataSource>(),
        isA<VitrineAnuncianteRemoteDataSource>(),
      );
    },
  );

  group('tracer: vitrine do anunciante pelo DI real sobre a ApiFalsa', () {
    // A resposta é o envelope capturado da lista da cidade: mesmo serializer
    // (allowlist de 13 chaves) e mesma `PageNumberPagination` das rotas novas
    // do Django. É uma resposta DERIVADA; o wire real das rotas de anunciante
    // é capturado no 07.1-03.
    final envelope = lerFixtureApi('lista_campinas_p1.json')!
        as Map<String, dynamic>;
    final resultados = envelope['results']! as List<Object?>;
    final proxima = envelope['next']! as String;

    Future<void> conferirVitrine({
      required AnuncianteRef anunciante,
      required String caminho,
    }) async {
      final api = ApiFalsa();
      await trocarDioPelaApiFalsa(api);
      api.responder(
        (uri) => uri.path == caminho,
        status: 200,
        fixture: 'lista_campinas_p1.json',
      );

      final cubit = getIt<VitrineAnuncianteCubit>();
      addTearDown(cubit.close);
      await cubit.carregar(anunciante);

      final estado = cubit.state;
      expect(estado, isA<VitrineAnuncianteCarregada>());
      final carregada = estado as VitrineAnuncianteCarregada;
      expect(carregada.itens, hasLength(resultados.length));
      expect(carregada.proximaPagina, proxima);

      // Exatamente uma requisição, no caminho aninhado e sem query string:
      // ordem e recorte são do servidor.
      expect(api.requisicoes, hasLength(1));
      expect(api.requisicoes.single.path, caminho);
      expect(api.requisicoes.single.queryParameters, isEmpty);
    }

    test('corretor -> GET /api/publico/corretores/1/imoveis/', () {
      return conferirVitrine(
        anunciante: const AnuncianteRef.corretor(1),
        caminho: '/api/publico/corretores/1/imoveis/',
      );
    });

    test('empresa -> GET /api/publico/empresas/1/imoveis/', () {
      return conferirVitrine(
        anunciante: const AnuncianteRef.empresa(1),
        caminho: '/api/publico/empresas/1/imoveis/',
      );
    });
  });
}
