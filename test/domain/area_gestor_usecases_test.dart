import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/acervo_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/contatos_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/mudancas_recentes.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/entities/totais_por_situacao.dart';
import 'package:imoveis_aqui/domain/repositories/area_gestor_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/obter_acervo_por_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_contatos_por_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_mudancas_recentes_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_totais_por_situacao_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _RepositorioFalso extends Mock implements AreaGestorRepository {}

TotaisPorSituacao _totais() => TotaisPorSituacao(
  porSituacao: {
    SituacaoImovel.disponivel: 35,
    SituacaoImovel.reservado: 1,
    SituacaoImovel.vendido: 2,
    SituacaoImovel.alugado: 3,
  },
  total: 41,
);

final _periodo = PeriodoContatos(
  de: DateTime(2026, 11, 1),
  ate: DateTime(2026, 11, 30),
);

void main() {
  late _RepositorioFalso repositorio;

  setUp(() {
    repositorio = _RepositorioFalso();
  });

  group('ObterTotaisPorSituacaoUseCase', () {
    test('call devolve o mesmo Result de sucesso, uma vez', () async {
      final esperado = Result<TotaisPorSituacao>.success(_totais());
      when(() => repositorio.obterTotaisPorSituacao())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterTotaisPorSituacaoUseCase(repositorio)();

      expect(resultado, same(esperado));
      verify(() => repositorio.obterTotaisPorSituacao()).called(1);
    });

    test('a SessaoExpiradaException passa como está', () async {
      final esperado = Result<TotaisPorSituacao>.failure(
        const SessaoExpiradaException(),
      );
      when(() => repositorio.obterTotaisPorSituacao())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterTotaisPorSituacaoUseCase(repositorio)();

      expect(resultado, same(esperado));
    });

    test('a SemPermissaoException passa como está', () async {
      final esperado = Result<TotaisPorSituacao>.failure(
        const SemPermissaoException(),
      );
      when(() => repositorio.obterTotaisPorSituacao())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterTotaisPorSituacaoUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });

  group('ObterAcervoPorCorretorUseCase', () {
    test('call devolve o mesmo Result de sucesso, uma vez', () async {
      final esperado = Result<AcervoPorCorretor>.success(
        AcervoPorCorretor(linhas: const [], total: 0),
      );
      when(() => repositorio.obterAcervoPorCorretor())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterAcervoPorCorretorUseCase(repositorio)();

      expect(resultado, same(esperado));
      verify(() => repositorio.obterAcervoPorCorretor()).called(1);
    });

    test('a SessaoExpiradaException passa como está', () async {
      final esperado = Result<AcervoPorCorretor>.failure(
        const SessaoExpiradaException(),
      );
      when(() => repositorio.obterAcervoPorCorretor())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterAcervoPorCorretorUseCase(repositorio)();

      expect(resultado, same(esperado));
    });

    test('a SemPermissaoException passa como está', () async {
      final esperado = Result<AcervoPorCorretor>.failure(
        const SemPermissaoException(),
      );
      when(() => repositorio.obterAcervoPorCorretor())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterAcervoPorCorretorUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });

  group('ObterContatosPorCorretorUseCase', () {
    test('sem período repassa null e devolve o mesmo Result', () async {
      final esperado = Result<ContatosPorCorretor>.success(
        ContatosPorCorretor(linhas: const [], total: 0, pendentes: 0),
      );
      when(() => repositorio.obterContatosPorCorretor(null))
          .thenAnswer((_) async => esperado);

      final resultado = await ObterContatosPorCorretorUseCase(repositorio)();

      expect(resultado, same(esperado));
      verify(() => repositorio.obterContatosPorCorretor(null)).called(1);
    });

    test('com período repassa o mesmo PeriodoContatos', () async {
      final esperado = Result<ContatosPorCorretor>.success(
        ContatosPorCorretor(linhas: const [], total: 0, pendentes: 0),
      );
      when(() => repositorio.obterContatosPorCorretor(_periodo))
          .thenAnswer((_) async => esperado);

      final resultado = await ObterContatosPorCorretorUseCase(repositorio)(
        _periodo,
      );

      expect(resultado, same(esperado));
      verify(() => repositorio.obterContatosPorCorretor(_periodo)).called(1);
    });

    test('a SessaoExpiradaException passa como está', () async {
      final esperado = Result<ContatosPorCorretor>.failure(
        const SessaoExpiradaException(),
      );
      when(() => repositorio.obterContatosPorCorretor(_periodo))
          .thenAnswer((_) async => esperado);

      final resultado = await ObterContatosPorCorretorUseCase(repositorio)(
        _periodo,
      );

      expect(resultado, same(esperado));
    });

    test('a SemPermissaoException passa como está', () async {
      final esperado = Result<ContatosPorCorretor>.failure(
        const SemPermissaoException(),
      );
      when(() => repositorio.obterContatosPorCorretor(null))
          .thenAnswer((_) async => esperado);

      final resultado = await ObterContatosPorCorretorUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });

  group('ObterMudancasRecentesUseCase', () {
    test('call devolve o mesmo Result de sucesso, uma vez', () async {
      final esperado = Result<MudancasRecentes>.success(
        MudancasRecentes(dias: 30, mudancas: const []),
      );
      when(() => repositorio.obterMudancasRecentes())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterMudancasRecentesUseCase(repositorio)();

      expect(resultado, same(esperado));
      verify(() => repositorio.obterMudancasRecentes()).called(1);
    });

    test('a SessaoExpiradaException passa como está', () async {
      final esperado = Result<MudancasRecentes>.failure(
        const SessaoExpiradaException(),
      );
      when(() => repositorio.obterMudancasRecentes())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterMudancasRecentesUseCase(repositorio)();

      expect(resultado, same(esperado));
    });

    test('a SemPermissaoException passa como está', () async {
      final esperado = Result<MudancasRecentes>.failure(
        const SemPermissaoException(),
      );
      when(() => repositorio.obterMudancasRecentes())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterMudancasRecentesUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });
}
