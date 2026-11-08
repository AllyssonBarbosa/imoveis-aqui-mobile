import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';

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

    for (final foto in ['javascript:alert(1)', 'file:///x.jpg', '/media/x.jpg']) {
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
}
