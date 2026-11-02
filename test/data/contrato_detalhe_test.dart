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

    test('a captura sem alteração passa', () {
      expect(() => _exigirContrato(casa(), 'limpo'), returnsNormally);
    });
  });
}
