import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/perfil_remote_datasource.dart';
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/domain/entities/perfil_empresa.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';

import '../support/api_falsa.dart';

/// Perfis públicos (PERF-04) sobre o wire capturado do Django real, servido
/// pela [ApiFalsa]: a DataSource remota lê o JSON e o repositório traduz cada
/// erro em falha tipada.
void main() {
  late ApiFalsa api;
  late PerfilRemoteDataSource remota;
  late PerfilRepository repositorio;
  late Map<String, Object?> corretor;
  late Map<String, Object?> empresa;

  bool rotaDoCorretor(Uri uri) =>
      uri.path.startsWith('/api/publico/corretores/');
  bool rotaDaEmpresa(Uri uri) => uri.path.startsWith('/api/publico/empresas/');

  Exception? falhaDe<T>(Result<T> resultado) => switch (resultado) {
    Failure<T>(:final erro) => erro,
    _ => null,
  };

  setUp(() {
    api = ApiFalsa();
    final dio = api.criarDio();
    remota = PerfilRemoteDataSource(dio);
    repositorio = PerfilRepositoryImpl(remota);
    corretor = lerFixtureApi('perfil_corretor.json')! as Map<String, Object?>;
    empresa = lerFixtureApi('perfil_empresa.json')! as Map<String, Object?>;
  });

  group('corretor', () {
    test('buscarCorretor pede /api/publico/corretores/<id>/ e devolve o model '
        'capturado', () async {
      final id = corretor['id']! as int;

      final modelo = await remota.buscarCorretor(id);

      expect(api.requisicoes.map((u) => u.path), [
        '/api/publico/corretores/$id/',
      ]);
      expect(api.requisicoes.single.queryParameters, isEmpty);
      expect(modelo.id, id);
      expect(modelo.nome, corretor['nome']);
      expect(modelo.empresaId, corretor['empresa_id']);
    });

    test('200 vira Success com a entidade igual à fixture', () async {
      final resultado = await repositorio.buscarCorretor(
        corretor['id']! as int,
      );

      expect(resultado, isA<Success<PerfilCorretor>>());
      final perfil = (resultado as Success<PerfilCorretor>).data;
      expect(perfil.nome, corretor['nome']);
      expect(perfil.creci, corretor['creci']);
      expect(perfil.empresaId, corretor['empresa_id']);
      expect(perfil.foto, anyOf(isNull, startsWith('http')));
    });

    test(
      'id inexistente (404 da API) vira PerfilNaoEncontradoException',
      () async {
        final resultado = await repositorio.buscarCorretor(999999);

        expect(falhaDe(resultado), isA<PerfilNaoEncontradoException>());
      },
    );

    test('500 vira DioException', () async {
      api.falharProximas('/api/publico/corretores/');

      final resultado = await repositorio.buscarCorretor(
        corretor['id']! as int,
      );

      expect(falhaDe(resultado), isA<DioException>());
    });

    test('corpo que é uma lista JSON vira FormatException', () async {
      api.responder(rotaDoCorretor, status: 200, corpo: <Object?>[]);

      final resultado = await repositorio.buscarCorretor(
        corretor['id']! as int,
      );

      expect(falhaDe(resultado), isA<FormatException>());
    });

    test('corpo sem nome vira FormatException', () async {
      api.responder(
        rotaDoCorretor,
        status: 200,
        corpo: {...corretor}..remove('nome'),
      );

      final resultado = await repositorio.buscarCorretor(
        corretor['id']! as int,
      );

      expect(falhaDe(resultado), isA<FormatException>());
    });
  });

  group('empresa', () {
    test('buscarEmpresa pede /api/publico/empresas/<id>/ e parseia o corpo '
        'capturado', () async {
      final id = empresa['id']! as int;

      final modelo = await remota.buscarEmpresa(id);

      expect(api.requisicoes.map((u) => u.path), [
        '/api/publico/empresas/$id/',
      ]);
      expect(modelo.id, id);
      expect(modelo.nome, empresa['razao_social_ou_nome']);
      expect(
        modelo.cidadesAtuacao,
        hasLength((empresa['cidades_atuacao']! as List).length),
      );
    });

    test('200 vira Success com a entidade igual à fixture', () async {
      final resultado = await repositorio.buscarEmpresa(empresa['id']! as int);

      expect(resultado, isA<Success<PerfilEmpresa>>());
      final perfil = (resultado as Success<PerfilEmpresa>).data;
      expect(perfil.nome, empresa['razao_social_ou_nome']);
      expect(perfil.tipo, TipoEmpresa.imobiliaria);
      expect(perfil.logomarca, anyOf(isNull, startsWith('http')));
    });

    test(
      'id inexistente (404 da API) vira PerfilNaoEncontradoException',
      () async {
        final resultado = await repositorio.buscarEmpresa(999999);

        expect(falhaDe(resultado), isA<PerfilNaoEncontradoException>());
      },
    );

    test('500 vira DioException', () async {
      api.falharProximas('/api/publico/empresas/');

      final resultado = await repositorio.buscarEmpresa(empresa['id']! as int);

      expect(falhaDe(resultado), isA<DioException>());
    });

    test('corpo que é uma lista JSON vira FormatException', () async {
      api.responder(rotaDaEmpresa, status: 200, corpo: <Object?>[]);

      final resultado = await repositorio.buscarEmpresa(empresa['id']! as int);

      expect(falhaDe(resultado), isA<FormatException>());
    });

    test('corpo sem o nome vira FormatException', () async {
      api.responder(
        rotaDaEmpresa,
        status: 200,
        corpo: {...empresa}..remove('razao_social_ou_nome'),
      );

      final resultado = await repositorio.buscarEmpresa(empresa['id']! as int);

      expect(falhaDe(resultado), isA<FormatException>());
    });
  });

  test(
    'duas buscas simultâneas resolvem cada uma com o próprio corpo',
    () async {
      final resultados = await Future.wait([
        repositorio.buscarCorretor(corretor['id']! as int),
        repositorio.buscarEmpresa(empresa['id']! as int),
      ]);

      expect(
        (resultados[0] as Success<PerfilCorretor>).data.nome,
        corretor['nome'],
      );
      expect(
        (resultados[1] as Success<PerfilEmpresa>).data.nome,
        empresa['razao_social_ou_nome'],
      );
      expect(
        api.requisicoes.map((u) => u.path),
        unorderedEquals([
          '/api/publico/corretores/${corretor['id']}/',
          '/api/publico/empresas/${empresa['id']}/',
        ]),
      );
    },
  );
}
