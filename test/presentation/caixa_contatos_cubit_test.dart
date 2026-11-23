import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/pagina_contatos.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_contatos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_sem_retorno_usecase.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_cubit.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_state.dart';
import 'package:mocktail/mocktail.dart';

class _BuscarContatosFalso extends Mock implements BuscarContatosUseCase {}

class _ObterSemRetornoFalso extends Mock implements ObterSemRetornoUseCase {}

ContatoRecebido _contato(int id) => ContatoRecebido(
  id: id,
  imovelCodigo: 'DEV-$id',
  imovelTitulo: 'Imóvel $id',
  canal: CanalContato.whatsapp,
  criadoEm: DateTime(2026, 11, 20, 9, 30),
  retorno: RetornoContato.pendente,
);

void main() {
  late _BuscarContatosFalso buscar;
  late _ObterSemRetornoFalso obterSemRetorno;

  final itensPagina1 = [_contato(1), _contato(2)];
  final pagina1 = PaginaContatos(
    itens: itensPagina1,
    proximaPagina: 'pagina-2',
  );
  final pagina2 = PaginaContatos(itens: [_contato(2), _contato(3)]);
  final paginaVazia = PaginaContatos(itens: const []);
  final periodo = PeriodoContatos(
    de: DateTime(2026, 11, 1),
    ate: DateTime(2026, 11, 20),
  );

  setUpAll(() {
    registerFallbackValue(const ConsultaContatos());
  });

  setUp(() {
    buscar = _BuscarContatosFalso();
    obterSemRetorno = _ObterSemRetornoFalso();
  });

  CaixaContatosCubit construir() => CaixaContatosCubit(buscar, obterSemRetorno);

  void listaResponde(PaginaContatos pagina) {
    when(() => buscar(any())).thenAnswer((_) async => Result.success(pagina));
  }

  void resumoResponde(int numero) {
    when(() => obterSemRetorno())
        .thenAnswer((_) async => Result.success(numero));
  }

  /// Deixa a fila de microtarefas esvaziar (as respostas dos falsos são
  /// `async`).
  Future<void> assentar() => Future<void>.delayed(Duration.zero);

  test('estado inicial: sem filtro, sem número e carregando', () {
    final estado = construir().state;
    expect(estado.consulta, const ConsultaContatos());
    expect(estado.semRetorno, isNull);
    expect(estado.conteudo, const ConteudoCaixa.carregando());
  });

  group('carregar', () {
    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'com itens e resumo 25 emite carregando, a lista e depois o número',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        resumoResponde(25);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      expect: () => [
        const CaixaContatosState(),
        CaixaContatosState(
          conteudo: ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        ),
        CaixaContatosState(
          semRetorno: 25,
          conteudo: ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        ),
      ],
      verify: (_) {
        verify(() => buscar(const ConsultaContatos())).called(1);
        verify(() => obterSemRetorno()).called(1);
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'lista vazia sem filtro emite vazio',
      build: construir,
      setUp: () {
        listaResponde(paginaVazia);
        resumoResponde(0);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.vazio());
        expect(cubit.state.semRetorno, 0);
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'lista vazia com filtro na consulta emite semResultado',
      build: construir,
      seed: () =>
          CaixaContatosState(consulta: ConsultaContatos(periodo: periodo)),
      setUp: () {
        listaResponde(paginaVazia);
        resumoResponde(4);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.semResultado());
        verify(() => buscar(ConsultaContatos(periodo: periodo))).called(1);
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'falha genérica da lista emite erro',
      build: construir,
      setUp: () {
        when(() => buscar(any()))
            .thenAnswer((_) async => Result.failure(Exception('rede')));
        resumoResponde(3);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.erro());
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'o resumo que falha deixa semRetorno nulo e a lista carregada (D-22)',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        when(() => obterSemRetorno())
            .thenAnswer((_) async => Result.failure(Exception('500')));
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.semRetorno, isNull);
        expect(
          cubit.state.conteudo,
          ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        );
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'o resumo com sessão expirada leva a sessaoExpirada (D-23)',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        when(() => obterSemRetorno()).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'a lista com sessão expirada leva a sessaoExpirada',
      build: construir,
      setUp: () {
        when(() => buscar(any())).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
        resumoResponde(1);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      },
    );

    test('sessaoExpirada é terminal: lista tardia não a desfaz', () async {
      final lista = Completer<Result<PaginaContatos>>();
      when(() => buscar(any())).thenAnswer((_) => lista.future);
      when(() => obterSemRetorno()).thenAnswer(
        (_) async => Result.failure(const SessaoExpiradaException()),
      );
      final cubit = construir()..carregar();
      await assentar();
      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());

      lista.complete(Result.success(pagina1));
      await assentar();

      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      await cubit.close();
    });

    test('sessaoExpirada é terminal: resumo tardio não a desfaz', () async {
      final resumo = Completer<Result<int>>();
      when(() => buscar(any())).thenAnswer(
        (_) async => Result.failure(const SessaoExpiradaException()),
      );
      when(() => obterSemRetorno()).thenAnswer((_) => resumo.future);
      final cubit = construir()..carregar();
      await assentar();
      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());

      resumo.complete(Result.success(9));
      await assentar();

      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      expect(cubit.state.semRetorno, isNull);
      await cubit.close();
    });

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'a troca de consulta não apaga o número do servidor (D-05)',
      build: construir,
      seed: () => const CaixaContatosState(semRetorno: 7),
      setUp: () {
        listaResponde(pagina1);
        // O resumo nunca responde: o número de antes tem de continuar na tela.
        when(() => obterSemRetorno())
            .thenAnswer((_) => Completer<Result<int>>().future);
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
      },
      verify: (cubit) {
        expect(cubit.state.semRetorno, 7);
        expect(cubit.state.conteudo, isA<CaixaCarregada>());
      },
    );
  });

  group('versões', () {
    test('a resposta da lista de uma consulta antiga é descartada', () async {
      final antiga = Completer<Result<PaginaContatos>>();
      final nova = Completer<Result<PaginaContatos>>();
      var chamadas = 0;
      when(() => buscar(any()))
          .thenAnswer((_) => ++chamadas == 1 ? antiga.future : nova.future);
      resumoResponde(2);
      final cubit = construir();

      cubit.carregar();
      cubit.carregar();
      nova.complete(Result.success(PaginaContatos(itens: [_contato(9)])));
      await assentar();
      antiga.complete(Result.success(pagina1));
      await assentar();

      expect(
        cubit.state.conteudo,
        ConteudoCaixa.carregada(itens: [_contato(9)]),
      );
      await cubit.close();
    });

    test('o resumo antigo não sobrescreve um resumo mais novo', () async {
      final antigo = Completer<Result<int>>();
      final novo = Completer<Result<int>>();
      var chamadas = 0;
      listaResponde(pagina1);
      when(() => obterSemRetorno())
          .thenAnswer((_) => ++chamadas == 1 ? antigo.future : novo.future);
      final cubit = construir();

      cubit.carregar();
      cubit.carregar();
      novo.complete(Result.success(10));
      await assentar();
      antigo.complete(Result.success(99));
      await assentar();

      expect(cubit.state.semRetorno, 10);
      await cubit.close();
    });
  });

  group('carregarMais (D-12)', () {
    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'anexa a página seguinte pelo seguir, sem repetir id já listado',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        resumoResponde(5);
        when(() => buscar.seguir('pagina-2'))
            .thenAnswer((_) async => Result.success(pagina2));
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
        await cubit.carregarMais();
      },
      verify: (cubit) {
        verify(() => buscar.seguir('pagina-2')).called(1);
        expect(
          cubit.state.conteudo,
          ConteudoCaixa.carregada(
            itens: [_contato(1), _contato(2), _contato(3)],
          ),
        );
        expect(cubit.state.semRetorno, 5);
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'ignora sem próxima página, fora de carregada e já carregando',
      build: construir,
      setUp: () {
        listaResponde(PaginaContatos(itens: [_contato(1)]));
        resumoResponde(1);
      },
      act: (cubit) async {
        await cubit.carregarMais(); // carregando: ignorado
        cubit.carregar();
        await assentar();
        await cubit.carregarMais(); // sem próxima página: ignorado
      },
      verify: (_) => verifyNever(() => buscar.seguir(any())),
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'falha mantém os itens com erroAoCarregarMais e não repete sozinha',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        resumoResponde(5);
        when(() => buscar.seguir('pagina-2'))
            .thenAnswer((_) async => Result.failure(Exception('rede')));
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
        await cubit.carregarMais();
        await cubit.carregarMais(); // ignorado: erroAoCarregarMais
      },
      verify: (cubit) {
        verify(() => buscar.seguir('pagina-2')).called(1);
        expect(
          cubit.state.conteudo,
          ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
            erroAoCarregarMais: true,
          ),
        );
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'sessão expirada na página seguinte vira sessaoExpirada',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        resumoResponde(5);
        when(() => buscar.seguir('pagina-2')).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
        await cubit.carregarMais();
      },
      verify: (cubit) {
        expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      },
    );
  });

  group('tentarNovamente (D-22)', () {
    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'em erro repete a consulta E pede o resumo de novo',
      build: construir,
      setUp: () {
        var chamadasLista = 0;
        when(() => buscar(any())).thenAnswer((_) async {
          chamadasLista++;
          return chamadasLista == 1
              ? Result.failure(Exception('rede'))
              : Result.success(pagina1);
        });
        var chamadasResumo = 0;
        when(() => obterSemRetorno()).thenAnswer((_) async {
          chamadasResumo++;
          return chamadasResumo == 1
              ? Result.failure(Exception('rede'))
              : Result.success(12);
        });
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
        expect(cubit.state.conteudo, const ConteudoCaixa.erro());
        expect(cubit.state.semRetorno, isNull);
        await cubit.tentarNovamente();
        await assentar();
      },
      verify: (cubit) {
        verify(() => buscar(const ConsultaContatos())).called(2);
        verify(() => obterSemRetorno()).called(2);
        expect(cubit.state.semRetorno, 12);
        expect(
          cubit.state.conteudo,
          ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        );
      },
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'em erroAoCarregarMais repete só a mesma página, sem pedir o resumo',
      build: construir,
      setUp: () {
        listaResponde(pagina1);
        resumoResponde(5);
        var chamadas = 0;
        when(() => buscar.seguir('pagina-2')).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.failure(Exception('rede'))
              : Result.success(pagina2);
        });
      },
      act: (cubit) async {
        cubit.carregar();
        await assentar();
        await cubit.carregarMais();
        await cubit.tentarNovamente();
      },
      verify: (cubit) {
        verify(() => buscar.seguir('pagina-2')).called(2);
        verify(() => buscar(any())).called(1);
        verify(() => obterSemRetorno()).called(1);
        expect(
          cubit.state.conteudo,
          ConteudoCaixa.carregada(
            itens: [_contato(1), _contato(2), _contato(3)],
          ),
        );
      },
    );
  });

  test('nenhum emit depois de close()', () async {
    final lista = Completer<Result<PaginaContatos>>();
    final resumo = Completer<Result<int>>();
    when(() => buscar(any())).thenAnswer((_) => lista.future);
    when(() => obterSemRetorno()).thenAnswer((_) => resumo.future);
    final cubit = construir()..carregar();
    await cubit.close();

    lista.complete(Result.success(pagina1));
    resumo.complete(Result.success(3));
    await assentar();

    expect(cubit.isClosed, isTrue);
  });
}
