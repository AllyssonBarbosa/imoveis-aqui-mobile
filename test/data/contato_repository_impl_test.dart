import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/contato_datasource.dart';
import 'package:imoveis_aqui/data/datasources/contato_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/contato_registrado_model.dart';
import 'package:imoveis_aqui/data/repositories/contato_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/repositories/contato_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _ContatoDataSourceFalso extends Mock implements ContatoDataSource {}

/// O repositório entrega ao domínio um `Uri` provado seguro para o canal ou uma
/// falha tipada (D-14), sem nunca reconstruir nem expor o link do servidor.
void main() {
  late _ContatoDataSourceFalso dataSource;
  late ContatoRepositoryImpl repositorio;

  final idCasa =
      (lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>)['id']!
          as int;

  setUpAll(() {
    registerFallbackValue(CanalContato.whatsapp);
  });

  setUp(() {
    dataSource = _ContatoDataSourceFalso();
    repositorio = ContatoRepositoryImpl(dataSource);
  });

  DioException dioException(int? status) {
    final opcoes = RequestOptions(path: caminhoContatoImovelPublico(idCasa));
    return DioException(
      requestOptions: opcoes,
      type: status == null
          ? DioExceptionType.connectionTimeout
          : DioExceptionType.badResponse,
      response: status == null
          ? null
          : Response<Object?>(requestOptions: opcoes, statusCode: status),
    );
  }

  Exception erroDe(Result<Uri> resultado) {
    expect(resultado, isA<Failure<Uri>>());
    return (resultado as Failure<Uri>).erro;
  }

  void datasourceResponde(String canal, String link) {
    when(
      () => dataSource.registrar(any(), any()),
    ).thenAnswer((_) async => ContatoRegistradoModel(canal: canal, link: link));
  }

  group('cadeia real: ContatoRemoteDataSource sobre a ApiFalsa', () {
    late ApiFalsa apiFalsa;

    setUp(() {
      apiFalsa = ApiFalsa();
      repositorio = ContatoRepositoryImpl(
        ContatoRemoteDataSource(apiFalsa.criarDio()),
      );
    });

    for (final canal in CanalContato.values) {
      test(
        '${canal.name}: Success com o link capturado, byte a byte',
        () async {
          final capturado =
              lerFixtureApi('contato_201_${canal.name}.json')!
                  as Map<String, Object?>;

          final resultado = await repositorio.registrarContato(idCasa, canal);

          expect(resultado, isA<Success<Uri>>());
          expect(
            (resultado as Success<Uri>).data.toString(),
            capturado['link'],
          );
        },
      );
    }

    test('404 da API real vira ImovelNaoEncontradoException', () async {
      final resultado = await repositorio.registrarContato(
        999999,
        CanalContato.whatsapp,
      );

      expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
    });
  });

  group('falhas do datasource (D-14)', () {
    test('400 vira CanalIndisponivelException', () async {
      when(() => dataSource.registrar(any(), any()))
          .thenThrow(dioException(400));

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.email,
      );

      expect(erroDe(resultado), isA<CanalIndisponivelException>());
    });

    test('404 vira ImovelNaoEncontradoException', () async {
      when(() => dataSource.registrar(any(), any()))
          .thenThrow(dioException(404));

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.email,
      );

      expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
    });

    test('429 vira ContatoLimiteExcedidoException', () async {
      when(() => dataSource.registrar(any(), any()))
          .thenThrow(dioException(429));

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.telefone,
      );

      expect(erroDe(resultado), isA<ContatoLimiteExcedidoException>());
    });

    test('500 vira Failure com a própria DioException', () async {
      final erro = dioException(500);
      when(() => dataSource.registrar(any(), any())).thenThrow(erro);

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      expect(erroDe(resultado), same(erro));
    });

    test(
      'timeout sem resposta vira Failure com a própria DioException',
      () async {
        final erro = dioException(null);
        when(() => dataSource.registrar(any(), any())).thenThrow(erro);

        final resultado = await repositorio.registrarContato(
          idCasa,
          CanalContato.whatsapp,
        );

        expect(erroDe(resultado), same(erro));
      },
    );

    test('TypeError do parse vira FormatException', () async {
      when(() => dataSource.registrar(any(), any()))
          .thenAnswer((_) async => throw TypeError());

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      expect(erroDe(resultado), isA<FormatException>());
    });

    test('FormatException do datasource segue como Failure', () async {
      when(() => dataSource.registrar(any(), any()))
          .thenThrow(const FormatException('corpo'));

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      expect(erroDe(resultado), isA<FormatException>());
    });
  });

  group('link validado por canal (T-06-05-01)', () {
    const whatsappValido = 'https://wa.me/5519988887777?text=Ol%C3%A1%20x';

    test('WhatsApp https wa.me é aceito e fica intacto', () async {
      datasourceResponde('WHATSAPP', whatsappValido);

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      expect((resultado as Success<Uri>).data.toString(), whatsappValido);
    });

    const invalidosWhatsapp = [
      'http://wa.me/5519988887777',
      'https://evil.com/?text=x',
      'https://wa.me.evil.com/x',
      'javascript:alert(1)',
      'intent://x#Intent;end',
    ];
    for (final link in invalidosWhatsapp) {
      test('WhatsApp com $link vira LinkContatoInvalidoException', () async {
        datasourceResponde('WHATSAPP', link);

        final resultado = await repositorio.registrarContato(
          idCasa,
          CanalContato.whatsapp,
        );

        expect(erroDe(resultado), isA<LinkContatoInvalidoException>());
      });
    }

    test('Telefone com link do WhatsApp vira LinkContatoInvalido', () async {
      datasourceResponde('TELEFONE', whatsappValido);

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.telefone,
      );

      expect(erroDe(resultado), isA<LinkContatoInvalidoException>());
    });

    test('E-mail com link tel vira LinkContatoInvalido', () async {
      datasourceResponde('EMAIL', 'tel:+5519988887777');

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.email,
      );

      expect(erroDe(resultado), isA<LinkContatoInvalidoException>());
    });

    test(
      'canal da resposta diferente do pedido vira LinkContatoInvalido',
      () async {
        datasourceResponde('EMAIL', 'tel:+5519988887777');

        final resultado = await repositorio.registrarContato(
          idCasa,
          CanalContato.telefone,
        );

        expect(erroDe(resultado), isA<LinkContatoInvalidoException>());
      },
    );

    test('link que o Uri.tryParse rejeita vira LinkContatoInvalido', () async {
      expect(Uri.tryParse('https://wa.me:abc/x'), isNull);
      datasourceResponde('WHATSAPP', 'https://wa.me:abc/x');

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      expect(erroDe(resultado), isA<LinkContatoInvalidoException>());
    });

    test('tel e mailto válidos passam', () async {
      datasourceResponde('TELEFONE', 'tel:+5519988887777');
      final tel = await repositorio.registrarContato(
        idCasa,
        CanalContato.telefone,
      );
      datasourceResponde('EMAIL', 'mailto:a@b.com?subject=Im%C3%B3vel%20X');
      final email = await repositorio.registrarContato(
        idCasa,
        CanalContato.email,
      );

      expect((tel as Success<Uri>).data.scheme, 'tel');
      expect((email as Success<Uri>).data.scheme, 'mailto');
    });
  });

  group('exceções não vazam o link', () {
    test('LinkContatoInvalidoException.toString nunca contém o link', () async {
      const link = 'https://evil.com/?text=segredo-DEV-CAMPINAS-21';
      datasourceResponde('WHATSAPP', link);

      final resultado = await repositorio.registrarContato(
        idCasa,
        CanalContato.whatsapp,
      );

      final texto = erroDe(resultado).toString();
      expect(texto, isNot(contains('evil.com')));
      expect(texto, isNot(contains('segredo')));
      expect(const LinkContatoInvalidoException().toString(), isNotEmpty);
    });

    test('as três exceções de domínio têm mensagem própria sem link', () {
      for (final erro in <Exception>[
        const CanalIndisponivelException(),
        const ContatoLimiteExcedidoException(),
        const LinkContatoInvalidoException(),
      ]) {
        expect(erro.toString(), isNot(contains('http')));
        expect(erro.toString(), isNotEmpty);
      }
    });
  });
}
