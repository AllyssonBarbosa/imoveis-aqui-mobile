import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

/// Teste de contrato do detalhe do imóvel (API-06): garante que o exemplo do
/// §11 do contrato, a fixture do mock e o Model falam a mesma língua, e que
/// nada fora da allowlist pública (§6 + §11) aparece no wire.
///
/// O exemplo vive no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova `imovel_detalhe.example.json` e corrija o caminho abaixo.
const _caminhoExemplo =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato/imovel_detalhe.example.json';

// --- Allowlists do §11, uma constante por objeto -------------------------
// Os planos seguintes ampliam a fixture; as entradas novas são checadas
// automaticamente contra estes conjuntos.

const _camposComuns = {
  'id',
  'titulo',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'preco_condominio',
  'preco_iptu',
  'descricao',
  'bairro',
  'cidade',
  'latitude',
  'longitude',
  'fotos',
  'caracteristicas',
  'corretor',
  'natureza',
  'casa',
  'apartamento',
  'terreno',
  'lote',
};

const _camposCidade = {'id', 'nome', 'uf'};
const _camposFoto = {'url', 'capa', 'ordem'};
const _camposCorretor = {'id', 'nome', 'foto', 'slug'};

const _camposCasa = {
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

const _camposTerreno = {
  'area_total',
  'frente',
  'fundo',
  'laterais',
  'topografia',
  'murado',
  'esquina',
  'uso_permitido',
};

const _camposApartamento = {
  'andar',
  'numero',
  'area_privativa',
  'area_total',
  'quartos',
  'suites',
  'banheiros',
  'vagas',
  'varanda',
  'posicao_solar',
  'predio',
};

const _camposPredio = {
  'nome',
  'andares',
  'unidades_por_andar',
  'ano',
  'elevadores',
  'portaria_24h',
  'piscina',
  'academia',
  'salao_de_festas',
  'playground',
};

const _camposLote = {
  'numero',
  'area',
  'frente',
  'fundo',
  'preco',
  'condicoes_parcelamento',
  'quadra',
};

const _camposQuadra = {'identificacao', 'loteamento'};

const _camposLoteamento = {
  'nome',
  'incorporadora',
  'infraestrutura',
  'areas_lazer',
};

/// Chaves que NUNCA podem aparecer em nenhum nível do detalhe público (§6).
const _chavesProibidas = {
  'proprietario',
  'corretor_responsavel',
  'email',
  'telefone',
  'whatsapp',
  'creci',
  'empresa',
  'logradouro',
  'cep',
  'cpf',
  'cnpj',
  'documento',
};

/// Todas as chaves de [valor], em qualquer profundidade (mapas e listas).
Set<String> _todasAsChaves(Object? valor) {
  final chaves = <String>{};
  if (valor is Map) {
    for (final entrada in valor.entries) {
      chaves.add(entrada.key as String);
      chaves.addAll(_todasAsChaves(entrada.value));
    }
  } else if (valor is List) {
    for (final item in valor) {
      chaves.addAll(_todasAsChaves(item));
    }
  }
  return chaves;
}

/// Confere que as chaves do mapa [objeto] (se não for nulo) estão em
/// [permitidas]; [rotulo] identifica o objeto na mensagem de falha.
void _exigirChavesPermitidas(
  Object? objeto,
  Set<String> permitidas,
  String rotulo,
) {
  if (objeto == null) return;
  final mapa = objeto as Map<String, Object?>;
  final extras = mapa.keys.toSet().difference(permitidas);
  expect(extras, isEmpty, reason: '$rotulo tem chaves fora da allowlist');
}

/// Aplica a allowlist de cada objeto do §11 a um detalhe em forma de wire.
void _exigirAllowlist(Map<String, Object?> detalhe, String rotulo) {
  _exigirChavesPermitidas(detalhe, _camposComuns, '$rotulo (raiz)');
  _exigirChavesPermitidas(detalhe['cidade'], _camposCidade, '$rotulo.cidade');
  for (final foto in (detalhe['fotos'] as List<Object?>? ?? const [])) {
    _exigirChavesPermitidas(foto, _camposFoto, '$rotulo.fotos[]');
  }
  _exigirChavesPermitidas(
    detalhe['corretor'],
    _camposCorretor,
    '$rotulo.corretor',
  );
  _exigirChavesPermitidas(detalhe['casa'], _camposCasa, '$rotulo.casa');
  _exigirChavesPermitidas(
    detalhe['terreno'],
    _camposTerreno,
    '$rotulo.terreno',
  );

  final apartamento = detalhe['apartamento'] as Map<String, Object?>?;
  _exigirChavesPermitidas(
    apartamento,
    _camposApartamento,
    '$rotulo.apartamento',
  );
  _exigirChavesPermitidas(
    apartamento?['predio'],
    _camposPredio,
    '$rotulo.apartamento.predio',
  );

  final lote = detalhe['lote'] as Map<String, Object?>?;
  _exigirChavesPermitidas(lote, _camposLote, '$rotulo.lote');
  final quadra = lote?['quadra'] as Map<String, Object?>?;
  _exigirChavesPermitidas(quadra, _camposQuadra, '$rotulo.lote.quadra');
  _exigirChavesPermitidas(
    quadra?['loteamento'],
    _camposLoteamento,
    '$rotulo.lote.quadra.loteamento',
  );

  expect(
    _todasAsChaves(detalhe).intersection(_chavesProibidas),
    isEmpty,
    reason: '$rotulo expõe chave proibida pelo §6',
  );
}

void main() {
  late Map<String, Object?> exemplo;

  setUpAll(() {
    exemplo =
        jsonDecode(File(_caminhoExemplo).readAsStringSync())
            as Map<String, Object?>;
  });

  group('imovel_detalhe.example.json (§11)', () {
    test('parseia pelo Model do app e vira a entidade esperada', () {
      final detalhe = DetalheImovelModel.fromJson(exemplo).paraEntidade();

      expect(detalhe.id, 42);
      expect(detalhe.finalidade, FinalidadeImovel.venda);
      expect(detalhe.natureza, NaturezaImovel.apartamento);
      expect(detalhe.fotos, hasLength(3));
      expect(detalhe.fotos.first.capa, isTrue);
      expect(detalhe.corretor?.nome, 'Marina Lopes');
    });

    test('é idêntico ao detalhe 42 que o mock serve', () {
      expect(exemplo, equals(detalhesAcervoFixture()[42]));
    });

    test('respeita a allowlist de cada objeto e não vaza chave proibida', () {
      _exigirAllowlist(exemplo, 'exemplo');
    });
  });

  group('fixture do detalhe', () {
    test('toda entrada respeita a allowlist e não vaza chave proibida', () {
      final fixture = detalhesAcervoFixture();
      expect(fixture, isNotEmpty);
      for (final entrada in fixture.entries) {
        _exigirAllowlist(entrada.value, 'fixture[${entrada.key}]');
      }
    });

    test('exatamente um bloco de natureza preenchido, coerente com natureza',
        () {
      const blocoPorNatureza = {
        'CASA': 'casa',
        'APARTAMENTO': 'apartamento',
        'TERRENO': 'terreno',
        'LOTE': 'lote',
      };
      for (final entrada in detalhesAcervoFixture().entries) {
        final detalhe = entrada.value;
        final natureza = detalhe['natureza'] as String?;
        final preenchidos = blocoPorNatureza.values
            .where((bloco) => detalhe[bloco] != null)
            .toList();
        if (natureza == null) {
          expect(
            preenchidos,
            isEmpty,
            reason: 'fixture[${entrada.key}] sem natureza não tem bloco',
          );
        } else {
          expect(
            preenchidos.length <= 1,
            isTrue,
            reason: 'fixture[${entrada.key}] tem mais de um bloco preenchido',
          );
          for (final bloco in preenchidos) {
            expect(
              bloco,
              blocoPorNatureza[natureza],
              reason: 'fixture[${entrada.key}] bloco incoerente com natureza',
            );
          }
        }
      }
    });
  });

  group('guarda da allowlist (prova de que o teste falha ao vazar)', () {
    test('chave fora da allowlist é detectada na raiz e em objeto aninhado', () {
      final raizSuja = {...exemplo, 'proprietario': 'Fulano'};
      expect(() => _exigirAllowlist(raizSuja, 'sujo'), throwsA(anything));

      final corretorSujo = {
        ...exemplo,
        'corretor': {
          ...(exemplo['corretor']! as Map<String, Object?>),
          'telefone': '19999999999',
        },
      };
      expect(() => _exigirAllowlist(corretorSujo, 'sujo'), throwsA(anything));
    });

    test('a varredura recursiva acha chave proibida dentro de lista', () {
      final chaves = _todasAsChaves({
        'fotos': [
          {'url': 'x', 'cep': '13000-000'},
        ],
      });
      expect(chaves.intersection(_chavesProibidas), {'cep'});
    });
  });
}
