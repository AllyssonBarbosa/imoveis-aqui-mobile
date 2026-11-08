import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_datasource.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/mocks/perfis_fixture.dart';
import 'package:imoveis_aqui/data/models/imoveis_envelope_model.dart';
import 'package:imoveis_aqui/data/repositories/vitrine_anunciante_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';
import 'package:imoveis_aqui/domain/entities/pagina_imoveis.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart';

void main() {
  group('parâmetros (§12.2, §12.6)', () {
    test('corretor vira só corretor=<id>', () {
      expect(parametrosDoAnunciante(const AnuncianteRef.corretor(7)), {
        'corretor': '7',
      });
    });

    test('empresa vira só empresa=<id>', () {
      expect(parametrosDoAnunciante(const AnuncianteRef.empresa(3)), {
        'empresa': '3',
      });
    });

    test('nunca carrega cidade, ordenacao nem busca', () {
      for (final anunciante in const [
        AnuncianteRef.corretor(7),
        AnuncianteRef.empresa(3),
      ]) {
        final chaves = parametrosDoAnunciante(anunciante).keys;
        expect(chaves, isNot(contains('cidade')));
        expect(chaves, isNot(contains('ordenacao')));
        expect(chaves, isNot(contains('busca')));
      }
    });

    test('anuncianteDosParametros é o inverso exato das duas formas', () {
      for (final anunciante in const [
        AnuncianteRef.corretor(7),
        AnuncianteRef.empresa(3),
      ]) {
        expect(
          anuncianteDosParametros(parametrosDoAnunciante(anunciante)),
          anunciante,
        );
      }
    });

    test('as duas chaves juntas lançam FormatException', () {
      expect(
        () => anuncianteDosParametros({'corretor': '7', 'empresa': '3'}),
        throwsFormatException,
      );
    });

    test('nenhuma das chaves lança FormatException', () {
      expect(() => anuncianteDosParametros({}), throwsFormatException);
      expect(
        () => anuncianteDosParametros({'cidade': 'Campinas-SP'}),
        throwsFormatException,
      );
    });

    test('valor não inteiro lança FormatException', () {
      expect(
        () => anuncianteDosParametros({'corretor': 'abc'}),
        throwsFormatException,
      );
      expect(
        () => anuncianteDosParametros({'empresa': '3.5'}),
        throwsFormatException,
      );
    });
  });

  group('servidor simulado (§12.3-§12.5)', () {
    VitrineAnuncianteMockDataSource construir({int tamanhoPagina = 10}) =>
        VitrineAnuncianteMockDataSource.paraTeste(
          linhas: linhasAcervoFixture(),
          detalhes: detalhesAcervoFixture(),
          corretores: corretoresPerfisFixture(),
          tamanhoPagina: tamanhoPagina,
        );

    /// Ids esperados, calculados das fixtures em tempo de execução (nunca
    /// com ids fixos de corretor), na ordem `criado_em` desc, `id` desc.
    List<int> esperadosPorCorretores(Set<int> idsDeCorretor) {
      final detalhes = detalhesAcervoFixture();
      final linhas = linhasAcervoFixture().where((linha) {
        final detalhe = detalhes[linha['id']! as int];
        if (detalhe == null) return false;
        final corretor = detalhe['corretor'] as Map<String, Object?>?;
        return idsDeCorretor.contains(corretor?['id']);
      }).toList()
        ..sort((a, b) {
          final porData = (b['criado_em']! as String).compareTo(
            a['criado_em']! as String,
          );
          if (porData != 0) return porData;
          return (b['id']! as int).compareTo(a['id']! as int);
        });
      return [for (final linha in linhas) linha['id']! as int];
    }

    Future<List<int>> percorrer(
      VitrineAnuncianteMockDataSource fonte,
      AnuncianteRef anunciante,
    ) async {
      final ids = <int>[];
      var envelope = await fonte.buscar(anunciante);
      while (true) {
        ids.addAll(envelope.results.map((modelo) => modelo.id));
        final proxima = envelope.next;
        if (proxima == null) break;
        envelope = await fonte.seguir(proxima);
      }
      return ids;
    }

    test('corretor 7: primeira página tem 10 itens e next não nulo', () async {
      final envelope = await construir().buscar(const AnuncianteRef.corretor(7));

      expect(envelope.results, hasLength(10));
      expect(envelope.next, isNotNull);
    });

    test('corretor 7: percorrer as páginas dá exatamente o recorte do '
        'detalhe, sem repetição, do mais recente ao mais antigo', () async {
      final ids = await percorrer(construir(), const AnuncianteRef.corretor(7));

      expect(ids, esperadosPorCorretores({7}));
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.length, greaterThan(10));
    });

    test('empresa 3 reúne os imóveis de todos os corretores dela', () async {
      final empresa3 = {
        for (final entrada in corretoresPerfisFixture().entries)
          if (entrada.value['empresa_id'] == 3) entrada.key,
      };
      final ids = await percorrer(construir(), const AnuncianteRef.empresa(3));

      expect(ids, esperadosPorCorretores(empresa3));
      expect(ids, isNotEmpty);
    });

    test('empresa 4 reúne os imóveis da autônoma (corretor 9)', () async {
      final empresa4 = {
        for (final entrada in corretoresPerfisFixture().entries)
          if (entrada.value['empresa_id'] == 4) entrada.key,
      };
      final ids = await percorrer(construir(), const AnuncianteRef.empresa(4));

      expect(ids, esperadosPorCorretores(empresa4));
      expect(ids, isNotEmpty);
    });

    test('o imóvel despublicado (339) nunca aparece', () async {
      for (final anunciante in [
        for (final id in corretoresPerfisFixture().keys)
          AnuncianteRef.corretor(id),
        const AnuncianteRef.empresa(3),
        const AnuncianteRef.empresa(4),
      ]) {
        final ids = await percorrer(construir(), anunciante);
        expect(ids, isNot(contains(idDetalheDespublicadoMock)));
      }
    });

    test('corretor 10 (sem imóveis) devolve vitrine vazia, sem erro', () async {
      final envelope = await construir().buscar(
        const AnuncianteRef.corretor(10),
      );

      expect(envelope.results, isEmpty);
      expect(envelope.next, isNull);
    });

    test('id desconhecido de corretor ou empresa devolve vitrine vazia', () async {
      final corretor = await construir().buscar(
        const AnuncianteRef.corretor(12345),
      );
      final empresa = await construir().buscar(const AnuncianteRef.empresa(999));

      expect(corretor.results, isEmpty);
      expect(corretor.next, isNull);
      expect(empresa.results, isEmpty);
      expect(empresa.next, isNull);
    });

    test('seguir com cursor inválido lança FormatException', () {
      final fonte = construir();
      final base = 'https://mock.imoveisaqui.local/api/publico/imoveis/'
          '?corretor=7';

      expect(
        () => fonte.seguir('$base&cursor=%%%'),
        throwsFormatException,
      );
      expect(
        () => fonte.seguir('$base&cursor=bm9fb2Zmc2V0'),
        throwsFormatException,
      );
    });

    test('seguir sem cursor lança FormatException', () {
      expect(
        () => construir().seguir(
          'https://mock.imoveisaqui.local/api/publico/imoveis/?corretor=7',
        ),
        throwsFormatException,
      );
    });

    test('seguir com cursor válido mas sem anunciante lança FormatException', () {
      final fonte = construir();
      final proxima = Uri.parse(
        'https://mock.imoveisaqui.local/api/publico/imoveis/',
      ).replace(queryParameters: {'cursor': 'bz0xMA=='}).toString();

      expect(() => fonte.seguir(proxima), throwsFormatException);
    });

    test('next carrega corretor=<id> e cursor, nunca cidade', () async {
      final envelope = await construir().buscar(const AnuncianteRef.corretor(7));
      final query = Uri.parse(envelope.next!).queryParameters;

      expect(query.keys.toSet(), {'corretor', 'cursor'});
      expect(query['corretor'], '7');
    });

    test('as linhas servidas não expõem corretor, empresa nem proprietário '
        '(allowlist §6/§12.3)', () async {
      // Fixture adversarial: uma linha da lista que vazasse as chaves
      // proibidas é saneada pelo servidor simulado.
      final linhas = linhasAcervoFixture();
      final detalhes = detalhesAcervoFixture();
      // O 42 é o exemplo do §11: o detalhe dele traz o corretor 7.
      final linhaSuja = <String, Object?>{
        ...linhas.firstWhere((l) => l['id'] == 42),
        'corretor': {'id': 7},
        'empresa': {'id': 3},
        'proprietario': {'id': 1},
      };
      const idCorretor = 7;
      final fonte = VitrineAnuncianteMockDataSource.paraTeste(
        linhas: [linhaSuja],
        detalhes: detalhes,
        corretores: corretoresPerfisFixture(),
      );

      final envelope = await fonte.buscar(AnuncianteRef.corretor(idCorretor));

      expect(envelope.results, hasLength(1));
      final json = envelope.results.single.toJson();
      expect(json.containsKey('corretor'), isFalse);
      expect(json.containsKey('empresa'), isFalse);
      expect(json.containsKey('proprietario'), isFalse);
    });

    test('chamadas repetidas dão o mesmo resultado (sem estado mutável)',
        () async {
      final fonte = construir();
      final primeira = await fonte.buscar(const AnuncianteRef.corretor(7));
      final segunda = await fonte.buscar(const AnuncianteRef.corretor(7));

      expect(
        segunda.results.map((m) => m.id).toList(),
        primeira.results.map((m) => m.id).toList(),
      );
    });
  });

  group('pilha use case -> repositório -> mock', () {
    BuscarImoveisDoAnuncianteUseCase montar() {
      final fonte = VitrineAnuncianteMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        detalhes: detalhesAcervoFixture(),
        corretores: corretoresPerfisFixture(),
      );
      return BuscarImoveisDoAnuncianteUseCase(
        VitrineAnuncianteRepositoryImpl(fonte),
      );
    }

    test('primeira página do corretor 7: Success com 10 imóveis, mesmos ids '
        'e ordem do envelope do mock', () async {
      final fonte = VitrineAnuncianteMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        detalhes: detalhesAcervoFixture(),
        corretores: corretoresPerfisFixture(),
      );
      final envelope = await fonte.buscar(const AnuncianteRef.corretor(7));
      final resultado = await BuscarImoveisDoAnuncianteUseCase(
        VitrineAnuncianteRepositoryImpl(fonte),
      )(const AnuncianteRef.corretor(7));

      expect(resultado, isA<Success<PaginaImoveis>>());
      final pagina = (resultado as Success<PaginaImoveis>).data;
      expect(pagina.itens, hasLength(10));
      expect(
        pagina.itens.map((i) => i.id).toList(),
        envelope.results.map((m) => m.id).toList(),
      );
      expect(pagina.proximaPagina, envelope.next);
    });

    test('seguir a proxima página pelo use case não repete itens', () async {
      final casoDeUso = montar();
      final primeira =
          (await casoDeUso(const AnuncianteRef.corretor(7)))
                  as Success<PaginaImoveis>;
      final segunda =
          (await casoDeUso.proximaPagina(primeira.data.proximaPagina!))
                  as Success<PaginaImoveis>;

      final idsPrimeira = primeira.data.itens.map((i) => i.id).toSet();
      expect(
        segunda.data.itens.map((i) => i.id).toSet().intersection(idsPrimeira),
        isEmpty,
      );
    });

    test('vitrine vazia (corretor 10) é Success vazio, não erro', () async {
      final resultado = await montar()(const AnuncianteRef.corretor(10));

      expect(resultado, isA<Success<PaginaImoveis>>());
      expect((resultado as Success<PaginaImoveis>).data.itens, isEmpty);
    });

    test('proximaPagina com cursor inválido é Failure(FormatException)',
        () async {
      final resultado = await montar().proximaPagina(
        'https://mock.imoveisaqui.local/api/publico/imoveis/'
        '?corretor=7&cursor=%%%',
      );

      expect(resultado, isA<Failure<PaginaImoveis>>());
      expect(
        (resultado as Failure<PaginaImoveis>).erro,
        isA<FormatException>(),
      );
    });

    test('envelope malformado (TypeError) vira Failure(FormatException)',
        () async {
      final repositorio = VitrineAnuncianteRepositoryImpl(
        _FonteMalformada(),
      );

      final resultado = await repositorio.buscarPrimeiraPagina(
        const AnuncianteRef.corretor(7),
      );

      expect(resultado, isA<Failure<PaginaImoveis>>());
      expect(
        (resultado as Failure<PaginaImoveis>).erro,
        isA<FormatException>(),
      );
    });
  });
}

/// DataSource que entrega um JSON sem os campos obrigatórios: o `fromJson`
/// gerado lança [TypeError], que o repositório precisa traduzir.
class _FonteMalformada implements VitrineAnuncianteDataSource {
  @override
  Future<ImoveisEnvelopeModel> buscar(AnuncianteRef anunciante) async =>
      ImoveisEnvelopeModel.fromJson({
        'next': null,
        'previous': null,
        'results': [
          {'id': 'não é inteiro'},
        ],
      });

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) =>
      buscar(const AnuncianteRef.corretor(0));
}
