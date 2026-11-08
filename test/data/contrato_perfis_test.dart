import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/mocks/perfis_fixture.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';

/// Teste de contrato dos perfis públicos (API-08, PERF-04): garante que os
/// exemplos de wire do §12 do contrato, a fixture do mock e o Model falam a
/// mesma língua, e que nada fora da allowlist da WEB 02 aparece no wire.
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova `perfil_corretor.example.json` e `perfil_empresa.example.json`
/// e corrija os caminhos abaixo.
const _caminhoExemploCorretor =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato/perfil_corretor.example.json';

const _caminhoExemploEmpresa =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato/perfil_empresa.example.json';

// --- Allowlists do §12.1, uma constante por objeto -----------------------
// Espelham os serializers da WEB 02 (`CorretorPublicoSerializer` e
// `EmpresaPublicaSerializer`); chave nova exige mudança explícita do contrato.

const _camposCorretor = {
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

const _camposEmpresa = {
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

const _camposCidade = {'id', 'nome', 'uf'};

/// Confere que as chaves de [objeto] são exatamente as de [permitidas];
/// [rotulo] identifica o objeto na mensagem de falha. Falha tanto por chave
/// extra (vazamento) quanto por chave faltando (contrato incompleto).
void _exigirChavesExatas(
  Map<String, Object?> objeto,
  Set<String> permitidas,
  String rotulo,
) {
  final chaves = objeto.keys.toSet();
  expect(
    chaves.difference(permitidas),
    isEmpty,
    reason: '$rotulo tem chaves fora da allowlist',
  );
  expect(
    permitidas.difference(chaves),
    isEmpty,
    reason: '$rotulo não traz todas as chaves do contrato',
  );
}

/// Aplica as allowlists do §12.1 a um perfil de empresa em forma de wire.
void _exigirAllowlistEmpresa(Map<String, Object?> empresa, String rotulo) {
  _exigirChavesExatas(empresa, _camposEmpresa, rotulo);
  for (final cidade in empresa['cidades_atuacao']! as List<Object?>) {
    _exigirChavesExatas(
      cidade! as Map<String, Object?>,
      _camposCidade,
      '$rotulo.cidades_atuacao[]',
    );
  }
  for (final corretor in empresa['corretores_ativos']! as List<Object?>) {
    _exigirChavesExatas(
      corretor! as Map<String, Object?>,
      _camposCorretor,
      '$rotulo.corretores_ativos[]',
    );
  }
}

void main() {
  late Map<String, Object?> exemploCorretor;
  late Map<String, Object?> exemploEmpresa;

  setUpAll(() {
    exemploCorretor = jsonDecode(
      File(_caminhoExemploCorretor).readAsStringSync(),
    ) as Map<String, Object?>;
    exemploEmpresa = jsonDecode(
      File(_caminhoExemploEmpresa).readAsStringSync(),
    ) as Map<String, Object?>;
  });

  group('perfil_corretor.example.json (§12.1)', () {
    test('respeita a allowlist de 9 chaves do corretor', () {
      _exigirChavesExatas(exemploCorretor, _camposCorretor, 'exemploCorretor');
    });

    test('parseia pelo Model do app e vira a entidade esperada', () {
      final perfil = PerfilCorretorModel.fromJson(exemploCorretor)
          .paraEntidade();

      expect(perfil.id, 7);
      expect(perfil.nome, 'Marina Lopes');
      expect(perfil.creci, '12345-F');
      expect(perfil.empresaId, 3);
    });

    test('é idêntico ao corretor 7 que o mock serve', () {
      expect(exemploCorretor, equals(corretoresPerfisFixture()[7]));
    });
  });

  group('perfil_empresa.example.json (§12.1)', () {    test('respeita a allowlist de 11 chaves da empresa', () {
      _exigirAllowlistEmpresa(exemploEmpresa, 'exemploEmpresa');
    });

    test('os corretores ativos são os corretores 7, 8 e 10 da fixture', () {
      final fixture = corretoresPerfisFixture();
      expect(
        exemploEmpresa['corretores_ativos'],
        equals([fixture[7], fixture[8], fixture[10]]),
      );
    });

    test('todo corretor ativo pertence à empresa do exemplo', () {
      final ativos = exemploEmpresa['corretores_ativos']! as List<Object?>;
      for (final corretor in ativos) {
        expect(
          (corretor! as Map<String, Object?>)['empresa_id'],
          exemploEmpresa['id'],
        );
      }
    });
  });

  group('fixture dos perfis de corretor', () {
    test('toda entrada tem exatamente as 9 chaves da allowlist', () {
      final fixture = corretoresPerfisFixture();
      expect(fixture, isNotEmpty);
      for (final entrada in fixture.entries) {
        _exigirChavesExatas(
          entrada.value,
          _camposCorretor,
          'fixture[${entrada.key}]',
        );
      }
    });
  });

  group('fixture dos perfis de empresa', () {
    test('a empresa 3 é profundamente igual a perfil_empresa.example.json', () {
      expect(empresasPerfisFixture()[3], equals(exemploEmpresa));
    });

    test('toda empresa tem exatamente as 11 chaves e cidades {id, nome, uf}', () {
      final fixture = empresasPerfisFixture();
      expect(fixture.keys, containsAll([3, 4]));
      for (final entrada in fixture.entries) {
        _exigirAllowlistEmpresa(entrada.value, 'empresa[${entrada.key}]');
        expect(entrada.value['id'], entrada.key);
      }
    });

    test('todo empresa_id dos corretores existe nas empresas', () {
      final empresas = empresasPerfisFixture();
      for (final corretor in corretoresPerfisFixture().values) {
        expect(
          empresas.containsKey(corretor['empresa_id']),
          isTrue,
          reason: 'corretor ${corretor['id']} aponta para empresa inexistente',
        );
      }
    });

    test('corretores_ativos são os corretores da fixture da empresa, por id', () {
      final corretores = corretoresPerfisFixture();
      final empresas = empresasPerfisFixture();
      for (final empresa in empresas.entries) {
        final esperados = [
          for (final id in (corretores.keys.toList()..sort()))
            if (corretores[id]!['empresa_id'] == empresa.key) corretores[id],
        ];
        expect(
          empresa.value['corretores_ativos'],
          equals(esperados),
          reason: 'empresa ${empresa.key}',
        );
      }
      expect(
        [
          for (final c
              in empresas[3]!['corretores_ativos']! as List<Object?>)
            (c! as Map<String, Object?>)['id'],
        ],
        [7, 8, 10],
      );
      expect(
        [
          for (final c
              in empresas[4]!['corretores_ativos']! as List<Object?>)
            (c! as Map<String, Object?>)['id'],
        ],
        [9],
      );
    });

    test('a empresa 4 é autônoma, com campos em branco como o servidor manda', () {
      final autonomo = empresasPerfisFixture()[4]!;

      expect(autonomo['tipo'], 'AUTONOMO');
      expect(autonomo['razao_social_ou_nome'], 'Camila Duarte');
      expect(autonomo['telefone'], '');
      expect(autonomo['descricao'], '');
      expect(autonomo['logomarca'], isNull);
    });
  });

  group('guarda da allowlist', () {
    test('uma chave fora da allowlist (cpf) faz o helper falhar', () {
      final sujo = {...exemploCorretor, 'cpf': '000.000.000-00'};

      expect(
        () => _exigirChavesExatas(sujo, _camposCorretor, 'sujo'),
        throwsA(isA<TestFailure>()),
      );
    });

    test('uma chave faltando também faz o helper falhar', () {
      final incompleto = {...exemploCorretor}..remove('creci');

      expect(
        () => _exigirChavesExatas(incompleto, _camposCorretor, 'incompleto'),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
