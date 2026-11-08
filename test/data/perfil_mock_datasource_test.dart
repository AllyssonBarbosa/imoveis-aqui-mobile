import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
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

  group('corretor desativado (PERF-05)', () {
    test('o id reservado 99 fica fora do acervo de perfis', () {
      expect(idCorretorDesativadoMock, 99);
      expect(corretoresPerfisFixture().containsKey(99), isFalse);
    });

    test('buscarCorretor(99) falha com PerfilNaoEncontradoException', () async {
      final resultado = await construir().buscarCorretor(
        idCorretorDesativadoMock,
      );

      expect(resultado, isA<Failure<PerfilCorretor>>());
      expect(
        (resultado as Failure<PerfilCorretor>).erro,
        isA<PerfilNaoEncontradoException>(),
      );
    });

    test('o 404 é forçado mesmo quando o mapa injetado contém o id 99', () async {
      final corretores = corretoresPerfisFixture();
      corretores[idCorretorDesativadoMock] = {
        ...corretores[7]!,
        'id': idCorretorDesativadoMock,
        'nome': 'Paulo Teixeira',
      };
      final repositorio = PerfilRepositoryImpl(
        PerfilMockDataSource.paraTeste(corretores: corretores),
      );

      final resultado = await repositorio.buscarCorretor(
        idCorretorDesativadoMock,
      );

      expect(resultado, isA<Failure<PerfilCorretor>>());
      expect(
        (resultado as Failure<PerfilCorretor>).erro,
        isA<PerfilNaoEncontradoException>(),
      );
    });

    test('o corretor regular 7 continua devolvendo a Marina Lopes', () async {
      final perfil = sucesso(await construir().buscarCorretor(7));

      expect(perfil.nome, 'Marina Lopes');
      expect(perfil.empresaId, 3);
    });

    test('todo corretor dos detalhes tem perfil, exceto o reservado 99', () {
      final perfis = corretoresPerfisFixture();
      final idsNosDetalhes = <int>{
        for (final detalhe in detalhesAcervoFixture().values)
          if (detalhe['corretor'] case final Map<String, Object?> corretor)
            corretor['id']! as int,
      };

      expect(idsNosDetalhes, containsAll([7, 8, 9, idCorretorDesativadoMock]));
      for (final id in idsNosDetalhes.difference({idCorretorDesativadoMock})) {
        expect(perfis.containsKey(id), isTrue, reason: 'corretor $id sem perfil');
      }
    });

    test('só o detalhe 337 carrega o corretor reservado 99', () {
      final detalhes = detalhesAcervoFixture();
      final comOReservado = [
        for (final detalhe in detalhes.values)
          if (detalhe['corretor'] case final Map<String, Object?> corretor
              when corretor['id'] == idCorretorDesativadoMock)
            detalhe['id']! as int,
      ];

      expect(idDetalheCorretorDesativadoMock, 337);
      expect(comOReservado, [idDetalheCorretorDesativadoMock]);
      final corretor =
          detalhes[idDetalheCorretorDesativadoMock]!['corretor']!
              as Map<String, Object?>;
      expect(corretor.keys.toSet(), {'id', 'nome', 'foto', 'slug'});
      expect(corretor['nome'], 'Paulo Teixeira');
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
