import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/perfis_fixture.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';

/// Servidor simulado dos perfis (PERF-04, D-03, D-04): repositório -> mock ->
/// Model -> entidade normalizada, sem latência.
void main() {
  PerfilRepositoryImpl construir() => PerfilRepositoryImpl(
    PerfilMockDataSource.paraTeste(corretores: corretoresPerfisFixture()),
  );

  PerfilCorretor sucesso(Result<PerfilCorretor> resultado) {
    expect(resultado, isA<Success<PerfilCorretor>>());
    return (resultado as Success<PerfilCorretor>).data;
  }

  group('buscarCorretor pela pilha repositório -> mock', () {
    test('corretor 7 chega completo, com o telefone como veio', () async {
      final perfil = sucesso(await construir().buscarCorretor(7));

      expect(perfil.id, 7);
      expect(perfil.nome, 'Marina Lopes');
      expect(perfil.creci, '12345-F');
      expect(perfil.empresaId, 3);
      expect(perfil.telefone, '(19) 3333-4444');
      expect(perfil.foto, 'https://picsum.photos/seed/corretor-7/200/200');
    });

    test('corretor 9 tem os vazios do wire normalizados para ausentes', () async {
      final perfil = sucesso(await construir().buscarCorretor(9));

      expect(perfil.nome, 'Camila Duarte');
      expect(perfil.telefone, isNull);
      expect(perfil.apresentacao, isNull);
      expect(perfil.foto, isNull);
      expect(perfil.whatsapp, '19977776666');
    });

    test('corretor 10 existe sem nenhum imóvel no acervo', () async {
      final perfil = sucesso(await construir().buscarCorretor(10));

      expect(perfil.nome, 'Bruno Sales');
      expect(perfil.empresaId, 3);
    });

    test('id sem perfil falha com PerfilNaoEncontradoException', () async {
      final resultado = await construir().buscarCorretor(12345);

      expect(resultado, isA<Failure<PerfilCorretor>>());
      expect(
        (resultado as Failure<PerfilCorretor>).erro,
        isA<PerfilNaoEncontradoException>(),
      );
    });
  });

  test('caminhoPerfilCorretor monta o endpoint público com barra final', () {
    expect(caminhoPerfilCorretor(7), '/api/publico/corretores/7/');
  });

  group('corretoresPerfisFixture', () {
    test('duas chamadas são iguais e independentes', () {
      final a = corretoresPerfisFixture();
      final b = corretoresPerfisFixture();

      expect(a, equals(b));
      a[7]!['nome'] = 'Alterado';
      expect(b[7]!['nome'], 'Marina Lopes');
      expect(corretoresPerfisFixture()[7]!['nome'], 'Marina Lopes');
    });

    test('cada entrada tem as nove chaves e parseia por fromJson', () {
      const chaves = {
        'id',
        'empresa_id',
        'foto',
        'nome',
        'email',
        'creci',
        'telefone',
        'whatsapp',
        'apresentacao',
      };
      final fixture = corretoresPerfisFixture();

      expect(fixture.keys, containsAll([7, 8, 9, 10]));
      for (final entrada in fixture.entries) {
        expect(entrada.value.keys.toSet(), chaves);
        final modelo = PerfilCorretorModel.fromJson(entrada.value);
        expect(modelo.id, entrada.key);
      }
    });
  });
}
