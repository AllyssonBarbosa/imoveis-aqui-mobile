import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_datasource.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';

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
}
