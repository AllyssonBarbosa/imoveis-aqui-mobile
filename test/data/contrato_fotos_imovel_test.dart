import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato das fotos do imóvel (API-18, §19 de `01-CONTRATO-API.md`):
/// os exemplos do contrato (`contrato/*.example.json`) são cópias EXATAS das
/// respostas capturadas do Django da `feat/APP11` da web
/// (`test/fixtures/api/`, nenhum wire escrito à mão), e cada foto tem
/// exatamente as chaves do `FotoDoImovelSerializer`. Chave nova ou perdida no
/// Django quebra este teste: sem drift silencioso entre os dois repositórios.
///
/// Também trava no wire as regras que o app só exibe e nunca decide: ordens
/// `0..n-1`, uma capa só, a primeira foto como capa, a ordem pedida no PUT e a
/// promoção da capa ao apagar. Ainda sem Model: o plano 11-06 testa o Model
/// contra estas mesmas fixtures.
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

/// As 4 chaves de cada foto (§19.2).
const _chavesDaFoto = {'id', 'imagem', 'ordem', 'capa'};

String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

List<Map<String, Object?>> _lista(String nome) => [
  for (final item in lerFixtureApi(nome)! as List<Object?>)
    item! as Map<String, Object?>,
];

void _exigirFoto(Map<String, Object?> foto, String rotulo) {
  expect(foto.keys.toSet(), _chavesDaFoto, reason: '$rotulo: chaves da foto');
  expect(foto['id'], isA<int>(), reason: '$rotulo: id');
  expect(foto['ordem'], isA<int>(), reason: '$rotulo: ordem');
  expect(foto['capa'], isA<bool>(), reason: '$rotulo: capa');
  final imagem = foto['imagem'];
  expect(imagem, isA<String>(), reason: '$rotulo: imagem');
  final uri = Uri.parse(imagem! as String);
  expect(uri.isAbsolute, isTrue, reason: '$rotulo: imagem é URL absoluta');
  expect(uri.path, startsWith('/media/imoveis/fotos/'), reason: rotulo);
}

/// Confere as regras de uma lista devolvida pelo servidor (§19.2) e devolve
/// os ids na ordem recebida.
List<int> _exigirLista(String nome, {required int quantidade}) {
  final lista = _lista(nome);
  expect(lista, hasLength(quantidade), reason: nome);
  for (final foto in lista) {
    _exigirFoto(foto, nome);
  }
  expect(
    [for (final foto in lista) foto['ordem']],
    List.generate(quantidade, (indice) => indice),
    reason: '$nome: ordens 0..n-1 na ordem recebida',
  );
  expect(
    lista.where((foto) => foto['capa'] == true),
    hasLength(quantidade == 0 ? 0 : 1),
    reason: '$nome: exatamente uma capa quando há foto',
  );
  return [for (final foto in lista) foto['id']! as int];
}

int _idDaCapa(String nome) =>
    _lista(nome).singleWhere((foto) => foto['capa'] == true)['id']! as int;

/// Corpo de um 400 com só a chave [campo] e uma lista de textos não vazios.
void _exigirErroDeCampo(String nome, String campo) {
  final corpo = lerFixtureApi(nome)! as Map<String, Object?>;
  expect(corpo.keys.toSet(), {campo}, reason: nome);
  final mensagens = corpo[campo]! as List<Object?>;
  expect(mensagens, isNotEmpty, reason: nome);
  for (final mensagem in mensagens) {
    expect(mensagem, isA<String>(), reason: nome);
    expect((mensagem! as String).trim(), isNotEmpty, reason: nome);
  }
}

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'fotos_lista.example.json': 'fotos_lista.json',
      'foto_enviada.example.json': 'foto_enviada.json',
      'fotos_apos_apagar_capa.example.json': 'fotos_apos_apagar_capa.json',
    };

    for (final par in pares.entries) {
      test('${par.key} é cópia exata de ${par.value}', () {
        expect(_textoDoExemplo(par.key), _textoDaFixture(par.value));
        expect(
          jsonDecode(_textoDoExemplo(par.key)),
          equals(lerFixtureApi(par.value)),
        );
      });
    }
  });

  group('lista e envio (§19.2, §19.3)', () {
    test('imóvel sem foto devolve lista vazia', () {
      _exigirLista('fotos_lista_vazia.json', quantidade: 0);
    });

    test('o 201 do envio é uma foto; a primeira entra com ordem 0 e capa', () {
      final foto = lerFixtureApi('foto_enviada.json')! as Map<String, Object?>;
      _exigirFoto(foto, 'foto_enviada');
      expect(foto['ordem'], 0);
      expect(foto['capa'], isTrue);
    });

    test('a lista vem na ordem de envio, com a primeira como capa', () {
      final ids = _exigirLista('fotos_lista.json', quantidade: 3);
      final enviada =
          lerFixtureApi('foto_enviada.json')! as Map<String, Object?>;
      expect(ids.first, enviada['id']);
      expect(_idDaCapa('fotos_lista.json'), enviada['id']);
    });
  });

  group('escritas devolvem a lista relida (§19.4–§19.6)', () {
    test('reordenar devolve a ordem pedida (a invertida)', () {
      final antes = _exigirLista('fotos_lista.json', quantidade: 3);
      final depois = _exigirLista('fotos_reordenadas.json', quantidade: 3);
      expect(depois, antes.reversed.toList());
    });

    test('definir capa deixa uma só, na foto do meio', () {
      final ids = _exigirLista('fotos_capa_definida.json', quantidade: 3);
      expect(_idDaCapa('fotos_capa_definida.json'), ids[1]);
    });

    test('apagar a capa renumera e promove a primeira restante', () {
      final antes = _exigirLista('fotos_capa_definida.json', quantidade: 3);
      final depois = _exigirLista('fotos_apos_apagar_capa.json', quantidade: 2);
      final capaApagada = _idDaCapa('fotos_capa_definida.json');
      expect(depois, [
        for (final id in antes)
          if (id != capaApagada) id,
      ]);
      expect(_idDaCapa('fotos_apos_apagar_capa.json'), depois.first);
    });
  });

  group('recusas (§19.1, §19.3, §19.4)', () {
    test('os 400 do envio trazem só a chave imagem', () {
      for (final nome in [
        'erro_400_foto_tipo.json',
        'erro_400_foto_tamanho.json',
        'erro_400_foto_quantidade.json',
        'erro_400_foto_limite.json',
      ]) {
        _exigirErroDeCampo(nome, 'imagem');
      }
    });

    test('o 400 do teto tem a mensagem dos 30', () {
      expect(lerFixtureApi('erro_400_foto_limite.json'), {
        'imagem': ['Este imóvel já tem 30 fotos, o máximo permitido.'],
      });
    });

    test('o 400 da ordem traz só a chave ids', () {
      _exigirErroDeCampo('erro_400_fotos_ordem.json', 'ids');
    });

    test('404 de outra empresa e 403 do gestor trazem só detail', () {
      for (final nome in [
        'erro_404_fotos_outra_empresa.json',
        'erro_403_fotos_gestor.json',
      ]) {
        final corpo = lerFixtureApi(nome)! as Map<String, Object?>;
        expect(corpo.keys.toSet(), {'detail'}, reason: nome);
        expect(corpo['detail'], isA<String>(), reason: nome);
      }
    });
  });
}
