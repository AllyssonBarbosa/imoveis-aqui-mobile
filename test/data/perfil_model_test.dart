import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';
import 'package:imoveis_aqui/data/models/perfil_empresa_model.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/perfil_empresa.dart';

const _caminhoExemploEmpresa =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato/perfil_empresa.example.json';

/// Wire mínimo da empresa da WEB 02 (sem a lista de corretores), base dos
/// casos do grupo 'empresa'.
Map<String, Object?> _wireEmpresa([Map<String, Object?> extras = const {}]) => {
  'id': 3,
  'tipo': 'IMOBILIARIA',
  'razao_social_ou_nome': 'Imobiliária Jequitibá',
  'creci': 'J-1234',
  'telefone': '(19) 3333-0000',
  'whatsapp': '19988880000',
  'email': 'contato@jequitiba.exemplo.com',
  'descricao': 'Imobiliária com 20 anos de atuação.',
  'logomarca': 'https://picsum.photos/seed/empresa-3/300/300',
  'cidades_atuacao': [
    {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
  ],
  ...extras,
};

/// Wire completo do corretor da WEB 02 (9 chaves), base dos casos abaixo.
Map<String, Object?> _wireCorretor([Map<String, Object?> extras = const {}]) =>
    {
      'id': 7,
      'empresa_id': 3,
      'foto': 'https://picsum.photos/seed/corretor-7/200/200',
      'nome': 'Marina Lopes',
      'email': 'marina.lopes@jequitiba.exemplo.com',
      'creci': '12345-F',
      'telefone': '(19) 3333-4444',
      'whatsapp': '19999998888',
      'apresentacao': 'Corretora há 10 anos.',
      ...extras,
    };

void main() {
  group('corretor', () {
    test('o wire completo parseia e vira a entidade como veio', () {
      final perfil = PerfilCorretorModel.fromJson(_wireCorretor())
          .paraEntidade();

      expect(perfil.id, 7);
      expect(perfil.empresaId, 3);
      expect(perfil.nome, 'Marina Lopes');
      expect(perfil.email, 'marina.lopes@jequitiba.exemplo.com');
      expect(perfil.creci, '12345-F');
      expect(perfil.telefone, '(19) 3333-4444');
      expect(perfil.whatsapp, '19999998888');
      expect(perfil.apresentacao, 'Corretora há 10 anos.');
      expect(perfil.foto, 'https://picsum.photos/seed/corretor-7/200/200');
    });

    test('textos opcionais vazios ou em branco viram null', () {
      final perfil = PerfilCorretorModel.fromJson(
        _wireCorretor({
          'email': '',
          'creci': '   ',
          'telefone': '',
          'whatsapp': '  ',
          'apresentacao': '',
        }),
      ).paraEntidade();

      expect(perfil.email, isNull);
      expect(perfil.creci, isNull);
      expect(perfil.telefone, isNull);
      expect(perfil.whatsapp, isNull);
      expect(perfil.apresentacao, isNull);
      expect(perfil.nome, 'Marina Lopes');
    });

    for (final foto in [
      'javascript:alert(1)',
      'file:///x.jpg',
      '/media/x.jpg',
    ]) {
      test('foto não-http "$foto" vira null', () {
        final perfil = PerfilCorretorModel.fromJson(
          _wireCorretor({'foto': foto}),
        ).paraEntidade();

        expect(perfil.foto, isNull);
      });
    }

    test('foto https é mantida', () {
      final perfil = PerfilCorretorModel.fromJson(
        _wireCorretor({'foto': 'https://exemplo.com/f.jpg'}),
      ).paraEntidade();

      expect(perfil.foto, 'https://exemplo.com/f.jpg');
    });

    test('empresa_id nulo é tolerado', () {
      final perfil = PerfilCorretorModel.fromJson(
        _wireCorretor({'empresa_id': null}),
      ).paraEntidade();

      expect(perfil.empresaId, isNull);
    });

    test('chave extra (cpf) é ignorada e não reaparece no toJson', () {
      final modelo = PerfilCorretorModel.fromJson(
        _wireCorretor({'cpf': '000.000.000-00'}),
      );

      expect(modelo.toJson().containsKey('cpf'), isFalse);
    });

    test('mapa sem nome faz fromJson lançar TypeError', () {
      final semNome = _wireCorretor()..remove('nome');

      expect(
        () => PerfilCorretorModel.fromJson(semNome),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('empresa', () {
    test('o exemplo do §12 parseia com nome, tipo, creci e 3 cidades', () {
      final exemplo = jsonDecode(
        File(_caminhoExemploEmpresa).readAsStringSync(),
      ) as Map<String, Object?>;

      final empresa = PerfilEmpresaModel.fromJson(exemplo).paraEntidade();

      expect(empresa.id, 3);
      expect(empresa.nome, 'Imobiliária Jequitibá');
      expect(empresa.tipo, TipoEmpresa.imobiliaria);
      expect(empresa.creci, 'J-1234');
      expect(empresa.cidadesAtuacao, const [
        Cidade(nome: 'Campinas', uf: 'SP'),
        Cidade(nome: 'Valinhos', uf: 'SP'),
        Cidade(nome: 'Vinhedo', uf: 'SP'),
      ]);
    });

    test('AUTONOMO vira TipoEmpresa.autonomo', () {
      final empresa = PerfilEmpresaModel.fromJson(
        _wireEmpresa({'tipo': 'AUTONOMO'}),
      ).paraEntidade();

      expect(empresa.tipo, TipoEmpresa.autonomo);
    });

    test('tipo desconhecido ou ausente vira null sem lançar', () {
      final desconhecido = PerfilEmpresaModel.fromJson(
        _wireEmpresa({'tipo': 'OUTRO'}),
      ).paraEntidade();
      final ausente = PerfilEmpresaModel.fromJson(
        _wireEmpresa()..remove('tipo'),
      ).paraEntidade();

      expect(desconhecido.tipo, isNull);
      expect(ausente.tipo, isNull);
    });

    test('textos vazios ou em branco viram null', () {
      final empresa = PerfilEmpresaModel.fromJson(
        _wireEmpresa({
          'creci': '',
          'telefone': '   ',
          'whatsapp': '',
          'email': '  ',
          'descricao': '',
        }),
      ).paraEntidade();

      expect(empresa.creci, isNull);
      expect(empresa.telefone, isNull);
      expect(empresa.whatsapp, isNull);
      expect(empresa.email, isNull);
      expect(empresa.descricao, isNull);
      expect(empresa.nome, 'Imobiliária Jequitibá');
    });

    for (final logo in ['javascript:alert(1)', '/media/logo.png']) {
      test('logomarca não-http "$logo" vira null', () {
        final empresa = PerfilEmpresaModel.fromJson(
          _wireEmpresa({'logomarca': logo}),
        ).paraEntidade();

        expect(empresa.logomarca, isNull);
      });
    }

    test('logomarca https é mantida', () {
      final empresa = PerfilEmpresaModel.fromJson(_wireEmpresa())
          .paraEntidade();

      expect(empresa.logomarca, 'https://picsum.photos/seed/empresa-3/300/300');
    });

    test('cidades_atuacao ausente vira lista vazia', () {
      final empresa = PerfilEmpresaModel.fromJson(
        _wireEmpresa()..remove('cidades_atuacao'),
      ).paraEntidade();

      expect(empresa.cidadesAtuacao, isEmpty);
    });

    test('toJson não carrega a chave corretores_ativos', () {
      final modelo = PerfilEmpresaModel.fromJson(
        _wireEmpresa({
          'corretores_ativos': [_wireCorretor()],
        }),
      );

      expect(modelo.toJson().containsKey('corretores_ativos'), isFalse);
    });

    test('mapa sem razao_social_ou_nome faz fromJson lançar TypeError', () {
      final semNome = _wireEmpresa()..remove('razao_social_ou_nome');

      expect(
        () => PerfilEmpresaModel.fromJson(semNome),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
