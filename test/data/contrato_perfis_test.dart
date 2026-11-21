import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/imoveis_envelope_model.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';
import 'package:imoveis_aqui/data/models/perfil_empresa_model.dart';

import '../support/api_falsa.dart';

/// Teste de contrato dos perfis públicos e da vitrine do anunciante (API-08,
/// PERF-04, PERF-03): os exemplos de `01-CONTRATO-API.md`
/// (`contrato/*.example.json`) são cópias EXATAS das respostas capturadas do
/// Django da `feat/APP07` da web (`test/fixtures/api/`, nenhum wire escrito à
/// mão), e o conjunto de chaves de cada objeto é o travado pelos serializers
/// públicos do servidor. Chave nova no Django quebra este teste: sem drift
/// silencioso entre os dois repositórios.
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova os três `*.example.json` e corrija [_pastaContrato].
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

const _chavesCorretor = {
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
const _chavesEmpresa = {
  'id',
  'tipo',
  'razao_social_ou_nome',
  'creci',
  'telefone',
  'whatsapp',
  'email',
  'descricao',
  'logomarca',
  'cidades_atuacao',
  'corretores_ativos',
};
const _chavesCidade = {'id', 'nome', 'uf'};
const _chavesEnvelope = {'count', 'next', 'previous', 'results'};
const _chavesItem = {
  'id',
  'titulo',
  'natureza',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'preco_condominio',
  'bairro',
  'area',
  'quartos',
  'suites',
  'vagas',
  'foto_capa',
};

/// Conteúdo textual de um exemplo do contrato.
String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

/// Conteúdo textual de uma fixture capturada.
String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

/// Confere que as chaves de [objeto] são EXATAMENTE as de [esperadas]; falha
/// tanto por chave extra (vazamento) quanto por chave faltando.
void _exigirChavesExatas(Object? objeto, Set<String> esperadas, String rotulo) {
  final mapa = objeto! as Map<String, Object?>;
  final chaves = mapa.keys.toSet();
  expect(
    chaves.difference(esperadas),
    isEmpty,
    reason: '$rotulo tem chave fora da allowlist do servidor',
  );
  expect(
    esperadas.difference(chaves),
    isEmpty,
    reason: '$rotulo perdeu chave da allowlist do servidor',
  );
}

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'perfil_corretor.example.json': 'perfil_corretor.json',
      'perfil_empresa.example.json': 'perfil_empresa.json',
      'vitrine_anunciante.example.json': 'vitrine_corretor_p1.json',
    };

    for (final par in pares.entries) {
      test('${par.key} é cópia exata de ${par.value}', () {
        // Byte a byte (o exemplo nunca é editado à mão) e, por garantia,
        // igualdade profunda do JSON decodificado.
        expect(_textoDoExemplo(par.key), _textoDaFixture(par.value));
        expect(
          jsonDecode(_textoDoExemplo(par.key)),
          equals(lerFixtureApi(par.value)),
        );
      });
    }
  });

  group('perfil do corretor', () {
    final corretor = _fixture('perfil_corretor.json');

    test('tem exatamente as 9 chaves públicas do serializer', () {
      _exigirChavesExatas(corretor, _chavesCorretor, 'perfil do corretor');
    });

    test('parseia pelo Model do app com id, nome e CRECI da captura', () {
      final perfil = PerfilCorretorModel.fromJson(corretor).paraEntidade();

      expect(perfil.id, corretor['id']);
      expect(perfil.nome, corretor['nome']);
      expect(perfil.creci, corretor['creci']);
      expect(perfil.empresaId, corretor['empresa_id']);
    });

    test('é o mesmo corretor do detalhe capturado (sem comparar a foto)', () {
      // A URL da foto muda a cada banco semeado (o Django acrescenta sufixo ao
      // nome do arquivo já existente), então só a identidade é comparada.
      final responsavel =
          _fixture('detalhe_casa.json')['corretor_responsavel']!
              as Map<String, Object?>;

      expect(responsavel['id'], corretor['id']);
      expect(responsavel['nome'], corretor['nome']);
      expect(responsavel['creci'], corretor['creci']);
      expect(responsavel['empresa_id'], corretor['empresa_id']);
    });

    test(
      'o 404 capturado traz a chave detail (texto nunca é lido pelo app)',
      () {
        expect(_fixture('erro_404_perfil.json'), contains('detail'));
      },
    );
  });

  group('perfil da empresa', () {
    final empresa = _fixture('perfil_empresa.json');

    test('tem exatamente as 11 chaves públicas do serializer', () {
      _exigirChavesExatas(empresa, _chavesEmpresa, 'perfil da empresa');
    });

    test('cada cidade de atuação tem exatamente id, nome e uf', () {
      final cidades = empresa['cidades_atuacao']! as List<Object?>;

      expect(cidades, isNotEmpty);
      for (final cidade in cidades) {
        _exigirChavesExatas(cidade, _chavesCidade, 'cidades_atuacao[]');
      }
    });

    test(
      'cada corretor ativo tem as 9 chaves do corretor e a empresa dela',
      () {
        // O app não lê esta lista (Deferred da Fase 7), mas o wire a traz.
        final ativos = empresa['corretores_ativos']! as List<Object?>;

        expect(ativos, isNotEmpty);
        for (final ativo in ativos) {
          _exigirChavesExatas(ativo, _chavesCorretor, 'corretores_ativos[]');
          expect((ativo! as Map<String, Object?>)['empresa_id'], empresa['id']);
        }
      },
    );

    test('é a empresa do corretor capturado', () {
      expect(empresa['id'], _fixture('perfil_corretor.json')['empresa_id']);
    });

    test('parseia pelo Model do app com as cidades na ordem recebida', () {
      final perfil = PerfilEmpresaModel.fromJson(empresa).paraEntidade();
      final cidades = empresa['cidades_atuacao']! as List<Object?>;

      expect(perfil.id, empresa['id']);
      expect(perfil.nome, empresa['razao_social_ou_nome']);
      expect(perfil.cidadesAtuacao, hasLength(cidades.length));
      expect(perfil.cidadesAtuacao.map((c) => c.id), [
        for (final c in cidades) (c! as Map<String, Object?>)['id'],
      ]);
    });
  });

  group('vitrine do anunciante (PageNumberPagination)', () {
    final idCorretor = _fixture('perfil_corretor.json')['id']! as int;

    for (final recurso in ['corretor', 'empresa']) {
      for (final pagina in ['p1', 'p2']) {
        final arquivo = 'vitrine_${recurso}_$pagina.json';
        final envelope = _fixture(arquivo);

        test('$arquivo: envelope com exatamente count, next, previous e '
            'results', () {
          _exigirChavesExatas(envelope, _chavesEnvelope, arquivo);
          expect(envelope['count'], isA<int>());
          expect(envelope['results'], isNotEmpty);
        });

        test(
          '$arquivo: todo item tem as 13 chaves da lista e não tem cidade',
          () {
            for (final item in envelope['results']! as List<Object?>) {
              _exigirChavesExatas(item, _chavesItem, '$arquivo item');
              expect(
                (item! as Map<String, Object?>),
                isNot(contains('cidade')),
              );
            }
          },
        );
      }
    }

    test('o next da p1 é absoluto na origem da API falsa, com page=2', () {
      final proxima = Uri.parse(
        _fixture('vitrine_corretor_p1.json')['next']! as String,
      );

      expect(
        '${proxima.scheme}://${proxima.host}:${proxima.port}',
        urlBaseApiFalsa,
      );
      expect(proxima.path, '/api/publico/corretores/$idCorretor/imoveis/');
      expect(proxima.queryParameters, {'page': '2'});
    });

    test('a p2 aponta de volta (previous) para a rota do anunciante', () {
      final anterior = Uri.parse(
        _fixture('vitrine_corretor_p2.json')['previous']! as String,
      );

      expect(anterior.path, '/api/publico/corretores/$idCorretor/imoveis/');
      expect(_fixture('vitrine_corretor_p2.json')['next'], isNull);
    });

    test('o exemplo parseia com ImoveisEnvelopeModel.fromJson', () {
      final exemplo =
          jsonDecode(_textoDoExemplo('vitrine_anunciante.example.json'))!
              as Map<String, Object?>;

      final envelope = ImoveisEnvelopeModel.fromJson(exemplo);

      expect(envelope.results, hasLength((exemplo['results']! as List).length));
      expect(envelope.next, exemplo['next']);
      expect(envelope.paraPagina().proximaPagina, exemplo['next']);
    });
  });

  group('guarda do contrato (prova de que o teste morde)', () {
    test('chave extra no perfil do corretor é detectada', () {
      final sujo = {
        ..._fixture('perfil_corretor.json'),
        'cpf': '000.000.000-00',
      };

      expect(
        () => _exigirChavesExatas(sujo, _chavesCorretor, 'sujo'),
        throwsA(isA<TestFailure>()),
      );
    });

    test('chave extra num item da vitrine é detectada', () {
      final item = Map<String, Object?>.of(
        (_fixture('vitrine_corretor_p1.json')['results']! as List<Object?>)
                .first!
            as Map<String, Object?>,
      )..['proprietario'] = 'Fulano';

      expect(
        () => _exigirChavesExatas(item, _chavesItem, 'sujo'),
        throwsA(isA<TestFailure>()),
      );
    });

    test('chave faltando no perfil também é detectada', () {
      final incompleto = {..._fixture('perfil_corretor.json')}..remove('creci');

      expect(
        () => _exigirChavesExatas(incompleto, _chavesCorretor, 'incompleto'),
        throwsA(isA<TestFailure>()),
      );
    });

    test('exemplo adulterado deixaria de ser igual à fixture', () {
      final adulterado = _textoDoExemplo('perfil_corretor.example.json')
          .replaceFirst('"nome": "', '"nome": "X');

      expect(adulterado, isNot(_textoDaFixture('perfil_corretor.json')));
    });
  });
}
