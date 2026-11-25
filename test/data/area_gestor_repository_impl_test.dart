import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/area_gestor_datasource.dart';
import 'package:imoveis_aqui/data/models/acervo_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/contatos_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/mudancas_recentes_model.dart';
import 'package:imoveis_aqui/data/models/totais_por_situacao_model.dart';
import 'package:imoveis_aqui/data/repositories/area_gestor_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/area_gestor_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _FonteFalsa extends Mock implements AreaGestorDataSource {}

RequestOptions _opcoes() => RequestOptions(path: '/api/relatorios/acervo/');

DioException _erroDio({int? status, Object? erro, DioExceptionType? tipo}) =>
    DioException(
      requestOptions: _opcoes(),
      response: status == null
          ? null
          : Response<Object?>(requestOptions: _opcoes(), statusCode: status),
      type:
          tipo ??
          (status == null
              ? DioExceptionType.connectionTimeout
              : DioExceptionType.badResponse),
      error: erro,
    );

Map<String, Object?> _json(String arquivo) =>
    lerFixtureApi(arquivo)! as Map<String, Object?>;

TotaisPorSituacaoModel _totais() =>
    TotaisPorSituacaoModel.fromJson(_json('relatorio_acervo.json'));

AcervoPorCorretorModel _acervo() => AcervoPorCorretorModel.fromJson(
  _json('relatorio_acervo_por_corretor.json'),
);

ContatosPorCorretorModel _contatos([
  String arquivo = 'relatorio_contatos.json',
]) => ContatosPorCorretorModel.fromJson(_json(arquivo));

MudancasRecentesModel _mudancas() =>
    MudancasRecentesModel.fromJson(_json('relatorio_mudancas.json'));

Exception? _falhaDe<T>(Result<T> resultado) => switch (resultado) {
  Failure<T>(:final erro) => erro,
  _ => null,
};

T _dadoDe<T>(Result<T> resultado) => switch (resultado) {
  Success<T>(:final data) => data,
  _ => throw StateError('esperava Success, veio $resultado'),
};

void main() {
  setUpAll(() {
    registerFallbackValue(
      PeriodoContatos(de: DateTime(2026, 11, 1), ate: DateTime(2026, 11, 25)),
    );
  });

  group('AreaGestorRepositoryImpl', () {
    late _FonteFalsa fonte;
    late AreaGestorRepository repositorio;

    setUp(() {
      fonte = _FonteFalsa();
      repositorio = AreaGestorRepositoryImpl(fonte);
    });

    group('sucesso', () {
      test(
        'obterTotaisPorSituacao devolve a entidade com os números do wire',
        () async {
          when(
            () => fonte.obterTotaisPorSituacao(),
          ).thenAnswer((_) async => _totais());

          final totais = _dadoDe(await repositorio.obterTotaisPorSituacao());

          final wire = _json('relatorio_acervo.json');
          expect(totais.total, wire['total']);
          final porCodigo = wire['totais']! as Map<String, Object?>;
          expect(
            totais.porSituacao[SituacaoImovel.disponivel],
            porCodigo['DISPONIVEL'],
          );
          expect(
            totais.porSituacao[SituacaoImovel.reservado],
            porCodigo['RESERVADO'],
          );
        },
      );

      test(
        'obterAcervoPorCorretor devolve as linhas na ordem do servidor',
        () async {
          when(
            () => fonte.obterAcervoPorCorretor(),
          ).thenAnswer((_) async => _acervo());

          final acervo = _dadoDe(await repositorio.obterAcervoPorCorretor());

          final wire = _json('relatorio_acervo_por_corretor.json');
          final linhas = (wire['linhas']! as List).cast<Map<String, Object?>>();
          expect(acervo.total, wire['total']);
          expect(acervo.linhas.map((l) => l.corretorId), [
            for (final l in linhas) l['corretor_id'],
          ]);
        },
      );

      test(
        'obterContatosPorCorretor sem período repassa nulo à DataSource',
        () async {
          when(
            () => fonte.obterContatosPorCorretor(any()),
          ).thenAnswer((_) async => _contatos());

          final contatos = _dadoDe(await repositorio.obterContatosPorCorretor());

          final wire = _json('relatorio_contatos.json');
          expect(contatos.total, wire['total']);
          expect(contatos.pendentes, wire['pendentes']);
          verify(() => fonte.obterContatosPorCorretor(null)).called(1);
        },
      );

      test(
        'obterContatosPorCorretor repassa o mesmo período à DataSource',
        () async {
          final periodo = PeriodoContatos(
            de: DateTime(2026, 11, 1),
            ate: DateTime(2026, 11, 25),
          );
          when(() => fonte.obterContatosPorCorretor(any())).thenAnswer(
            (_) async => _contatos('relatorio_contatos_periodo.json'),
          );

          final contatos = _dadoDe(
            await repositorio.obterContatosPorCorretor(periodo),
          );

          expect(
            contatos.total,
            _json('relatorio_contatos_periodo.json')['total'],
          );
          verify(() => fonte.obterContatosPorCorretor(periodo)).called(1);
        },
      );

      test(
        'obterMudancasRecentes devolve a janela e as mudanças do servidor',
        () async {
          when(
            () => fonte.obterMudancasRecentes(),
          ).thenAnswer((_) async => _mudancas());

          final mudancas = _dadoDe(await repositorio.obterMudancasRecentes());

          final wire = _json('relatorio_mudancas.json');
          expect(mudancas.dias, wire['dias']);
          expect(
            mudancas.mudancas,
            hasLength((wire['mudancas']! as List).length),
          );
        },
      );
    });

    group('401 vira SessaoExpiradaException', () {
      test('DioException com status 401', () async {
        when(
          () => fonte.obterTotaisPorSituacao(),
        ).thenThrow(_erroDio(status: 401));

        final resultado = await repositorio.obterTotaisPorSituacao();

        expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
      });

      test(
        'DioException com SessaoExpiradaException no error (interceptador)',
        () async {
          when(
            () => fonte.obterAcervoPorCorretor(),
          ).thenThrow(_erroDio(erro: const SessaoExpiradaException()));

          final resultado = await repositorio.obterAcervoPorCorretor();

          expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
        },
      );

      test('a própria SessaoExpiradaException', () async {
        when(
          () => fonte.obterMudancasRecentes(),
        ).thenThrow(const SessaoExpiradaException());

        final resultado = await repositorio.obterMudancasRecentes();

        expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
      });
    });

    group('403 vira SemPermissaoException', () {
      test('em cada uma das 4 leituras', () async {
        when(
          () => fonte.obterTotaisPorSituacao(),
        ).thenThrow(_erroDio(status: 403));
        when(
          () => fonte.obterAcervoPorCorretor(),
        ).thenThrow(_erroDio(status: 403));
        when(
          () => fonte.obterContatosPorCorretor(any()),
        ).thenThrow(_erroDio(status: 403));
        when(
          () => fonte.obterMudancasRecentes(),
        ).thenThrow(_erroDio(status: 403));

        expect(
          _falhaDe(await repositorio.obterTotaisPorSituacao()),
          isA<SemPermissaoException>(),
        );
        expect(
          _falhaDe(await repositorio.obterAcervoPorCorretor()),
          isA<SemPermissaoException>(),
        );
        expect(
          _falhaDe(await repositorio.obterContatosPorCorretor()),
          isA<SemPermissaoException>(),
        );
        expect(
          _falhaDe(await repositorio.obterMudancasRecentes()),
          isA<SemPermissaoException>(),
        );
      });
    });

    group('o resto vira falha genérica', () {
      for (final status in [400, 404, 500]) {
        test('DioException $status sai como veio, nunca tipada', () async {
          final erro = _erroDio(status: status);
          when(() => fonte.obterContatosPorCorretor(any())).thenThrow(erro);

          final resultado = await repositorio.obterContatosPorCorretor();

          expect(_falhaDe(resultado), same(erro));
          expect(_falhaDe(resultado), isNot(isA<SessaoExpiradaException>()));
          expect(_falhaDe(resultado), isNot(isA<SemPermissaoException>()));
        });
      }

      for (final tipo in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        test('DioException de rede ($tipo) sai como veio', () async {
          final erro = _erroDio(tipo: tipo);
          when(() => fonte.obterMudancasRecentes()).thenThrow(erro);

          final resultado = await repositorio.obterMudancasRecentes();

          expect(_falhaDe(resultado), same(erro));
        });
      }
    });

    group('wire malformado vira FormatException, sem lançar', () {
      test('situação desconhecida (EM_OBRA) nos totais', () async {
        final wire = Map<String, Object?>.of(_json('relatorio_acervo.json'));
        final totais = Map<String, Object?>.of(
          wire['totais']! as Map<String, Object?>,
        );
        totais['EM_OBRA'] = totais.remove('ALUGADO');
        wire['totais'] = totais;
        when(
          () => fonte.obterTotaisPorSituacao(),
        ).thenAnswer((_) async => TotaisPorSituacaoModel.fromJson(wire));

        final resultado = await repositorio.obterTotaisPorSituacao();

        expect(_falhaDe(resultado), isA<FormatException>());
      });

      test('situação desconhecida numa mudança recente', () async {
        final wire = Map<String, Object?>.of(_json('relatorio_mudancas.json'));
        final mudancas = (wire['mudancas']! as List)
            .cast<Map<String, Object?>>()
            .map(Map<String, Object?>.of)
            .toList();
        mudancas.first['situacao_nova'] = 'EM_OBRA';
        wire['mudancas'] = mudancas;
        when(
          () => fonte.obterMudancasRecentes(),
        ).thenAnswer((_) async => MudancasRecentesModel.fromJson(wire));

        final resultado = await repositorio.obterMudancasRecentes();

        expect(_falhaDe(resultado), isA<FormatException>());
      });

      test('TypeError (chave faltando) vira FormatException', () async {
        when(
          () => fonte.obterAcervoPorCorretor(),
        ).thenAnswer((_) async => throw TypeError());

        final resultado = await repositorio.obterAcervoPorCorretor();

        expect(_falhaDe(resultado), isA<FormatException>());
      });

      test('FormatException da DataSource passa como está', () async {
        const erro = FormatException('corpo não é objeto');
        when(() => fonte.obterContatosPorCorretor(any())).thenThrow(erro);

        final resultado = await repositorio.obterContatosPorCorretor();

        expect(_falhaDe(resultado), same(erro));
      });
    });
  });
}
