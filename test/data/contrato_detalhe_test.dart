import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';

import '../support/api_falsa.dart';

/// Teste de contrato do detalhe do imóvel: o app é comparado com o JSON REAL
/// capturado da API (`test/fixtures/api/detalhe_*.json`, D-02, D-15). O
/// conjunto de chaves de cada objeto público é igual ao travado pelos testes
/// Django do 05-02 (`VitrineAllowlistExataTests`): se o servidor ganhar ou
/// perder uma chave, a captura muda e este teste (e o do Django) quebra —
/// drift entre os dois repositórios não passa em silêncio.

// --- Chaves exatas por objeto (allowlist do 05-02) -------------------------

const _chavesDetalhe = {
  'id',
  'titulo',
  'natureza',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'preco_condominio',
  'preco_iptu',
  'descricao',
  'caracteristicas',
  'casa',
  'terreno',
  'apartamento',
  'lote',
  'endereco',
  'fotos',
  'corretor_responsavel',
  'canais_contato',
};

const _chavesEndereco = {
  'logradouro',
  'numero',
  'bairro',
  'cep',
  'cidade',
  'latitude',
  'longitude',
};

const _chavesCidade = {'id', 'nome', 'uf'};
const _chavesFoto = {'imagem', 'ordem', 'capa'};
const _chavesCaracteristica = {'id', 'nome'};

/// `CorretorPublicoSerializer` (05-02-SUMMARY): `empresa_id` e os campos de
/// contato estão no payload público (PENDENTE de revisão LGPD pela frente
/// web); o app declara só id, nome e foto (D-16).
const _chavesCorretor = {
  'id',
  'empresa_id',
  'nome',
  'foto',
  'email',
  'creci',
  'telefone',
  'whatsapp',
  'apresentacao',
};

/// Blocos por natureza (serializers públicos de casa, terreno, apartamento e
/// lote, 05-02): iguais a `CHAVES_CASA` etc. de `VitrineAllowlistExataTests`.
/// O bloco da natureza do imóvel vem preenchido e os outros três vêm `null`.
const _chavesCasa = {
  'area_terreno',
  'area_construida',
  'area_livre',
  'quartos',
  'suites',
  'banheiros',
  'salas',
  'vagas',
  'pavimentos',
  'ano_construcao',
  'piscina',
  'quintal',
  'churrasqueira',
  'mobiliada',
};

const _chavesTerreno = {
  'area_total',
  'frente',
  'fundo',
  'lateral_esquerda',
  'lateral_direita',
  'topografia',
  'murado',
  'esquina',
  'uso_permitido',
};

const _chavesApartamento = {
  'predio',
  'andar',
  'area_privativa',
  'area_total',
  'quartos',
  'suites',
  'banheiros',
  'vagas',
  'varanda',
  'posicao_solar',
};

const _chavesPredio = {
  'nome',
  'andares',
  'ano_construcao',
  'elevadores',
  'portaria_24h',
  'piscina',
  'academia',
  'salao_de_festas',
  'playground',
};

const _chavesLote = {
  'numero',
  'area',
  'frente',
  'fundo',
  'entrada_minima',
  'parcelas_maximas',
  'condicoes_parcelamento',
  'quadra',
};

const _chavesQuadra = {'identificacao', 'loteamento'};

const _chavesLoteamento = {
  'nome',
  'incorporadora',
  'asfalto',
  'agua',
  'energia',
  'esgoto',
  'iluminacao',
  'areas_de_lazer',
};

/// Natureza do wire -> (chave do bloco, chaves exatas do bloco).
const _blocoPorNatureza = <String, (String, Set<String>)>{
  'CASA': ('casa', _chavesCasa),
  'TERRENO': ('terreno', _chavesTerreno),
  'APARTAMENTO': ('apartamento', _chavesApartamento),
  'LOTE': ('lote', _chavesLote),
};

/// Confere que as chaves de [objeto] são EXATAMENTE as de [esperadas];
/// [rotulo] identifica o objeto na mensagem de falha.
void _exigirChavesExatas(
  Object? objeto,
  Set<String> esperadas,
  String rotulo,
) {
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

/// Aplica o conjunto exato de cada objeto público a um detalhe em forma de
/// wire.
void _exigirContrato(Map<String, Object?> detalhe, String rotulo) {
  _exigirChavesExatas(detalhe, _chavesDetalhe, rotulo);

  final endereco = detalhe['endereco'];
  if (endereco != null) {
    _exigirChavesExatas(endereco, _chavesEndereco, '$rotulo.endereco');
    final cidade = (endereco as Map<String, Object?>)['cidade'];
    if (cidade != null) {
      _exigirChavesExatas(cidade, _chavesCidade, '$rotulo.endereco.cidade');
    }
  }
  for (final foto in detalhe['fotos']! as List<Object?>) {
    _exigirChavesExatas(foto, _chavesFoto, '$rotulo.fotos[]');
  }
  for (final item in detalhe['caracteristicas']! as List<Object?>) {
    _exigirChavesExatas(
      item,
      _chavesCaracteristica,
      '$rotulo.caracteristicas[]',
    );
  }
  final corretor = detalhe['corretor_responsavel'];
  if (corretor != null) {
    _exigirChavesExatas(corretor, _chavesCorretor, '$rotulo.corretor');
  }
  _exigirBlocosDaNatureza(detalhe, rotulo);
}

/// Exatamente o bloco da `natureza` vem preenchido, com as chaves exatas do
/// servidor; os outros três vêm `null`. Apartamento confere o prédio e lote
/// confere quadra e loteamento.
void _exigirBlocosDaNatureza(Map<String, Object?> detalhe, String rotulo) {
  final natureza = detalhe['natureza'];
  final (chaveBloco, chavesBloco) = _blocoPorNatureza[natureza]!;

  for (final chave in _blocoPorNatureza.values.map((b) => b.$1)) {
    if (chave == chaveBloco) continue;
    expect(
      detalhe[chave],
      isNull,
      reason: '$rotulo ($natureza) deveria ter $chave nulo',
    );
  }

  final bloco = detalhe[chaveBloco];
  expect(bloco, isNotNull, reason: '$rotulo ($natureza) sem bloco $chaveBloco');
  _exigirChavesExatas(bloco, chavesBloco, '$rotulo.$chaveBloco');

  final mapa = bloco! as Map<String, Object?>;
  if (natureza == 'APARTAMENTO') {
    final predio = mapa['predio'];
    if (predio != null) {
      _exigirChavesExatas(predio, _chavesPredio, '$rotulo.apartamento.predio');
    }
  }
  if (natureza == 'LOTE') {
    final quadra = mapa['quadra'];
    if (quadra != null) {
      _exigirChavesExatas(quadra, _chavesQuadra, '$rotulo.lote.quadra');
      final loteamento = (quadra as Map<String, Object?>)['loteamento'];
      if (loteamento != null) {
        _exigirChavesExatas(
          loteamento,
          _chavesLoteamento,
          '$rotulo.lote.quadra.loteamento',
        );
      }
    }
  }
}

void main() {
  /// Nome de arquivo -> JSON de cada `detalhe_*.json` capturado.
  final capturados = <String, Map<String, Object?>>{
    for (final arquivo
        in Directory('test/fixtures/api').listSync().whereType<File>())
      if (arquivo.uri.pathSegments.last.startsWith('detalhe_') &&
          arquivo.uri.pathSegments.last.endsWith('.json'))
        arquivo.uri.pathSegments.last:
            lerFixtureApi(arquivo.uri.pathSegments.last)!
                as Map<String, Object?>,
  };

  test('há detalhes capturados (o contrato não passa vazio)', () {
    expect(capturados.length, greaterThanOrEqualTo(6));
    expect(
      capturados.keys,
      containsAll([
        'detalhe_casa.json',
        'detalhe_apartamento.json',
        'detalhe_terreno.json',
        'detalhe_lote.json',
        'detalhe_sem_fotos.json',
        'detalhe_sem_corretor.json',
      ]),
    );
  });

  group('cada detalhe capturado', () {
    for (final entrada in capturados.entries) {
      test('${entrada.key} tem exatamente as chaves públicas', () {
        _exigirContrato(entrada.value, entrada.key);
      });

      test('${entrada.key} parseia pelo Model do app', () {
        final detalhe = DetalheImovelModel.fromJson(
          entrada.value,
        ).paraEntidade();

        expect(detalhe.id, entrada.value['id']);
        expect(detalhe.titulo, entrada.value['titulo']);
      });
    }

    test('a captura cobre fotos, características e corretor de verdade', () {
      bool algum(bool Function(Map<String, Object?> detalhe) condicao) =>
          capturados.values.any(condicao);

      expect(
        algum((d) => (d['fotos']! as List<Object?>).isNotEmpty),
        isTrue,
      );
      expect(
        algum((d) => (d['caracteristicas']! as List<Object?>).isNotEmpty),
        isTrue,
      );
      expect(algum((d) => d['corretor_responsavel'] != null), isTrue);
      expect(algum((d) => d['corretor_responsavel'] == null), isTrue);
      expect(algum((d) => (d['fotos']! as List<Object?>).isEmpty), isTrue);
    });
  });

  group('exemplo do contrato == resposta capturada', () {
    const pasta =
        '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
        'contrato';
    const pares = {
      'imovel_detalhe.example.json': 'detalhe_apartamento.json',
      'imovel_detalhe_lote.example.json': 'detalhe_lote.json',
    };

    for (final par in pares.entries) {
      test('${par.key} é cópia exata de ${par.value}', () {
        final exemplo = File('$pasta/${par.key}').readAsStringSync();
        final fixture = File(
          'test/fixtures/api/${par.value}',
        ).readAsStringSync();

        // Byte a byte (D-02: o exemplo nunca é editado à mão) e igualdade
        // profunda do JSON decodificado.
        expect(exemplo, fixture);
        expect(jsonDecode(exemplo), equals(capturados[par.value]));
      });

      test('${par.key} tem as chaves públicas e parseia pelo Model', () {
        final exemplo =
            jsonDecode(File('$pasta/${par.key}').readAsStringSync())!
                as Map<String, Object?>;

        _exigirContrato(exemplo, par.key);
        final detalhe = DetalheImovelModel.fromJson(exemplo).paraEntidade();
        expect(detalhe.id, exemplo['id']);
      });
    }
  });

  group('blocos de natureza: cada natureza tem o conjunto exato de chaves', () {
    test('as quatro naturezas estão capturadas, com o bloco certo', () {
      final porNatureza = {
        for (final d in capturados.values) d['natureza']! as String: d,
      };

      expect(
        porNatureza.keys,
        containsAll(['CASA', 'APARTAMENTO', 'TERRENO', 'LOTE']),
      );
      for (final natureza in _blocoPorNatureza.keys) {
        _exigirBlocosDaNatureza(porNatureza[natureza]!, natureza);
      }
    });

    test('apartamento traz o prédio e o lote traz quadra e loteamento', () {
      final apartamento =
          capturados['detalhe_apartamento.json']!['apartamento']!
              as Map<String, Object?>;
      final lote =
          capturados['detalhe_lote.json']!['lote']! as Map<String, Object?>;

      expect(apartamento['predio'], isNotNull);
      expect(lote['quadra'], isNotNull);
      expect(
        (lote['quadra']! as Map<String, Object?>)['loteamento'],
        isNotNull,
      );
    });

    test('lote não tem preço próprio nem unidade; apartamento não tem número', () {
      final lote = capturados['detalhe_lote.json']!['lote']!
          as Map<String, Object?>;
      final apartamento =
          capturados['detalhe_apartamento.json']!['apartamento']!
              as Map<String, Object?>;

      expect(lote.keys, isNot(contains('preco')));
      expect(lote.keys, isNot(contains('vendido')));
      expect(apartamento.keys, isNot(contains('numero')));
      expect(
        (apartamento['predio']! as Map<String, Object?>).keys,
        isNot(contains('unidades_por_andar')),
      );
    });
  });

  group('o Model não guarda o contato do corretor (D-16)', () {
    test('contato e empresa_id do wire não chegam à entidade', () {
      final detalhe = DetalheImovelModel.fromJson(
        capturados['detalhe_casa.json']!,
      ).paraEntidade();

      expect(
        detalhe.corretor.toString(),
        isNot(contains('example.com')),
      );
      expect(detalhe.corretor.toString(), isNot(contains('12345-F')));
      expect(detalhe.corretor.toString(), isNot(contains('19988887777')));
    });
  });

  group('canais_contato capturado (D-01)', () {
    // Ordem fixa do servidor (canais_disponiveis da W11): o app só nomeia.
    const ordem = ['WHATSAPP', 'TELEFONE', 'EMAIL'];

    test('é lista só de nomes de canal, na ordem fixa e sem repetição', () {
      for (final entrada in capturados.entries) {
        final canais = entrada.value['canais_contato'];

        expect(canais, isA<List<Object?>>(), reason: entrada.key);
        final nomes = (canais! as List<Object?>).cast<String>();
        expect(nomes, everyElement(isIn(ordem)), reason: entrada.key);
        expect(nomes.toSet().length, nomes.length, reason: entrada.key);
        final posicoes = nomes.map(ordem.indexOf).toList();
        expect(
          posicoes,
          orderedEquals([...posicoes]..sort()),
          reason: '${entrada.key} fora da ordem fixa',
        );
      }
    });

    test('a captura cobre os três canais de uma vez', () {
      expect(
        capturados.values.any(
          (d) => (d['canais_contato']! as List<Object?>).length == 3,
        ),
        isTrue,
      );
    });

    test('sem corretor ainda tem canal (fallback da empresa, no servidor)', () {
      final canais =
          capturados['detalhe_sem_corretor.json']!['canais_contato']!
              as List<Object?>;

      expect(canais, isNotEmpty);
    });

    test('canais_contato faltando na raiz é detectado', () {
      final semCanais = Map<String, Object?>.of(
        capturados['detalhe_casa.json']!,
      )..remove('canais_contato');

      expect(() => _exigirContrato(semCanais, 'sem'), throwsA(anything));
    });
  });

  group('guarda do contrato (prova de que o teste morde)', () {
    Map<String, Object?> casa() => Map<String, Object?>.of(
      capturados['detalhe_casa.json']!,
    );

    test('chave extra na raiz é detectada', () {
      final suja = casa()..['proprietario'] = 'Fulano';

      expect(() => _exigirContrato(suja, 'sujo'), throwsA(anything));
    });

    test('chave faltando na raiz é detectada', () {
      final incompleta = casa()..remove('descricao');

      expect(() => _exigirContrato(incompleta, 'incompleto'), throwsA(anything));
    });

    test('chave extra em objeto aninhado é detectada', () {
      final enderecoSujo = casa()
        ..['endereco'] = {
          ...(casa()['endereco']! as Map<String, Object?>),
          'complemento': 'ap 3',
        };
      expect(() => _exigirContrato(enderecoSujo, 'sujo'), throwsA(anything));

      final corretorSujo = casa()
        ..['corretor_responsavel'] = {
          ...(casa()['corretor_responsavel']! as Map<String, Object?>),
          'cpf': '000',
        };
      expect(() => _exigirContrato(corretorSujo, 'sujo'), throwsA(anything));
    });

    test('chave faltando em endereco é detectada', () {
      final endereco = Map<String, Object?>.of(
        casa()['endereco']! as Map<String, Object?>,
      )..remove('cep');
      final incompleto = casa()..['endereco'] = endereco;

      expect(() => _exigirContrato(incompleto, 'incompleto'), throwsA(anything));
    });

    test('chave extra ou faltando no bloco da natureza é detectada', () {
      final casaSuja = casa()
        ..['casa'] = {
          ...(casa()['casa']! as Map<String, Object?>),
          'valor_venal': '1',
        };
      expect(() => _exigirContrato(casaSuja, 'sujo'), throwsA(anything));

      final casaIncompleta = casa()
        ..['casa'] = (Map<String, Object?>.of(
          casa()['casa']! as Map<String, Object?>,
        )..remove('piscina'));
      expect(
        () => _exigirContrato(casaIncompleta, 'incompleto'),
        throwsA(anything),
      );
    });

    test('bloco de outra natureza preenchido é detectado', () {
      final dupla = casa()..['lote'] = <String, Object?>{};

      expect(() => _exigirContrato(dupla, 'dupla'), throwsA(anything));
    });

    test('chave extra no loteamento é detectada', () {
      final lote = Map<String, Object?>.of(capturados['detalhe_lote.json']!);
      final bloco = Map<String, Object?>.of(lote['lote']! as Map<String, Object?>);
      final quadra = Map<String, Object?>.of(
        bloco['quadra']! as Map<String, Object?>,
      );
      quadra['loteamento'] = {
        ...(quadra['loteamento']! as Map<String, Object?>),
        'cnpj': '00',
      };
      bloco['quadra'] = quadra;
      lote['lote'] = bloco;

      expect(() => _exigirContrato(lote, 'sujo'), throwsA(anything));
    });

    test('a captura sem alteração passa', () {
      expect(() => _exigirContrato(casa(), 'limpo'), returnsNormally);
    });
  });
}
