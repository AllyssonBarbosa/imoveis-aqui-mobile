import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/pagina_contatos.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_caixa_contatos.dart';
import 'package:imoveis_aqui/domain/usecases/anotar_retorno_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_contatos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/listar_imoveis_dos_contatos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_sem_retorno_usecase.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_cubit.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_state.dart';
import 'package:mocktail/mocktail.dart';

class _BuscarContatosFalso extends Mock implements BuscarContatosUseCase {}

class _ObterSemRetornoFalso extends Mock implements ObterSemRetornoUseCase {}

class _ListarImoveisFalso extends Mock
    implements ListarImoveisDosContatosUseCase {}

class _AnotarRetornoFalso extends Mock implements AnotarRetornoUseCase {}

ContatoRecebido _contato(
  int id, {
  RetornoContato retorno = RetornoContato.pendente,
  DateTime? retornoEm,
}) => ContatoRecebido(
  id: id,
  imovelCodigo: 'DEV-$id',
  imovelTitulo: 'Imóvel $id',
  canal: CanalContato.whatsapp,
  criadoEm: DateTime(2026, 11, 20, 9, 30),
  retorno: retorno,
  retornoEm: retornoEm,
);

void main() {
  late _BuscarContatosFalso buscar;
  late _ObterSemRetornoFalso obterSemRetorno;
  late _ListarImoveisFalso listarImoveis;
  late _AnotarRetornoFalso anotarRetorno;

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
    registerFallbackValue(RetornoContato.falei);
  });

  setUp(() {
    buscar = _BuscarContatosFalso();
    obterSemRetorno = _ObterSemRetornoFalso();
    listarImoveis = _ListarImoveisFalso();
    anotarRetorno = _AnotarRetornoFalso();
  });

  CaixaContatosCubit construir() =>
      CaixaContatosCubit(buscar, obterSemRetorno, listarImoveis, anotarRetorno);

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

  group('filtros (D-05, D-18, D-19, D-20)', () {
    const imovelA = ImovelComContato(id: 7, codigo: 'DEV-7', titulo: 'Casa 7');
    const imovelB = ImovelComContato(id: 8, codigo: 'DEV-8', titulo: 'Casa 8');

    /// Cubit já com a lista carregada e o número 25, sem chamadas pendentes
    /// nos falsos (o histórico de chamadas é zerado).
    Future<CaixaContatosCubit> carregado({PaginaContatos? pagina}) async {
      listaResponde(pagina ?? pagina1);
      resumoResponde(25);
      final cubit = construir()..carregar();
      await assentar();
      clearInteractions(buscar);
      clearInteractions(obterSemRetorno);
      return cubit;
    }

    test('aplicarImovel reinicia a lista com o imóvel na consulta', () async {
      final cubit = await carregado();

      await cubit.aplicarImovel(imovelA);

      expect(cubit.state.consulta, const ConsultaContatos(imovel: imovelA));
      verify(() => buscar(const ConsultaContatos(imovel: imovelA))).called(1);
      await cubit.close();
    });

    test('aplicar o mesmo imóvel de novo não chama a API', () async {
      final cubit = await carregado();
      await cubit.aplicarImovel(imovelA);
      clearInteractions(buscar);

      await cubit.aplicarImovel(imovelA);

      verifyNever(() => buscar(any()));
      await cubit.close();
    });

    test('aplicarPeriodo com imóvel já aplicado busca com os dois', () async {
      final cubit = await carregado();
      await cubit.aplicarImovel(imovelA);

      await cubit.aplicarPeriodo(periodo);

      expect(
        cubit.state.consulta,
        ConsultaContatos(imovel: imovelA, periodo: periodo),
      );
      verify(() => buscar(ConsultaContatos(imovel: imovelA, periodo: periodo)))
          .called(1);
      await cubit.close();
    });

    test('aplicar outro imóvel troca só o imóvel e mantém o período', () async {
      final cubit = await carregado();
      await cubit.aplicarImovel(imovelA);
      await cubit.aplicarPeriodo(periodo);

      await cubit.aplicarImovel(imovelB);

      expect(
        cubit.state.consulta,
        ConsultaContatos(imovel: imovelB, periodo: periodo),
      );
      await cubit.close();
    });

    test('limparImovel mantém o período', () async {
      final cubit = await carregado();
      await cubit.aplicarImovel(imovelA);
      await cubit.aplicarPeriodo(periodo);
      clearInteractions(buscar);

      await cubit.limparImovel();

      expect(cubit.state.consulta, ConsultaContatos(periodo: periodo));
      verify(() => buscar(ConsultaContatos(periodo: periodo))).called(1);
      await cubit.close();
    });

    test('limparPeriodo mantém o imóvel', () async {
      final cubit = await carregado();
      await cubit.aplicarImovel(imovelA);
      await cubit.aplicarPeriodo(periodo);
      clearInteractions(buscar);

      await cubit.limparPeriodo();

      expect(cubit.state.consulta, const ConsultaContatos(imovel: imovelA));
      verify(() => buscar(const ConsultaContatos(imovel: imovelA))).called(1);
      await cubit.close();
    });

    test('limpar o que já está vazio não chama a API', () async {
      final cubit = await carregado();

      await cubit.limparImovel();
      await cubit.limparPeriodo();

      verifyNever(() => buscar(any()));
      await cubit.close();
    });

    test('resultado vazio com filtro emite semResultado', () async {
      final cubit = await carregado();
      listaResponde(paginaVazia);

      await cubit.aplicarImovel(imovelA);

      expect(cubit.state.conteudo, const ConteudoCaixa.semResultado());
      await cubit.close();
    });

    test('limpar todos os filtros e vir vazio emite vazia', () async {
      final cubit = await carregado();
      listaResponde(paginaVazia);
      await cubit.aplicarImovel(imovelA);

      await cubit.limparImovel();

      expect(cubit.state.conteudo, const ConteudoCaixa.vazio());
      await cubit.close();
    });

    test(
      'trocar ou limpar filtro não pede o resumo e mantém o número',
      () async {
        final cubit = await carregado();

        await cubit.aplicarImovel(imovelA);
        await cubit.aplicarPeriodo(periodo);
        await cubit.limparImovel();
        await cubit.limparPeriodo();

        verifyNever(() => obterSemRetorno());
        expect(cubit.state.semRetorno, 25);
        await cubit.close();
      },
    );

    test(
      'trocar de filtro emite carregando uma vez e depois a lista',
      () async {
        final cubit = await carregado();
        final estados = <CaixaContatosState>[];
        final inscricao = cubit.stream.listen(estados.add);

        await cubit.aplicarImovel(imovelA);
        await assentar();
        await inscricao.cancel();

        expect(estados.map((e) => e.conteudo), [
          const ConteudoCaixa.carregando(),
          ConteudoCaixa.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        ]);
        expect(estados.every((e) => e.semRetorno == 25), isTrue);
        await cubit.close();
      },
    );

    test('resposta de antes da troca de filtro é descartada', () async {
      final antiga = Completer<Result<PaginaContatos>>();
      final cubit = await carregado();
      when(() => buscar(const ConsultaContatos(imovel: imovelA)))
          .thenAnswer((_) => antiga.future);
      when(() => buscar(const ConsultaContatos(imovel: imovelB)))
          .thenAnswer((_) async => Result.success(pagina2));

      final primeira = cubit.aplicarImovel(imovelA);
      await cubit.aplicarImovel(imovelB);
      antiga.complete(Result.success(pagina1));
      await primeira;
      await assentar();

      expect(cubit.state.consulta, const ConsultaContatos(imovel: imovelB));
      expect(
        cubit.state.conteudo,
        ConteudoCaixa.carregada(itens: pagina2.itens),
      );
      await cubit.close();
    });

    test('a sessão expirada na lista filtrada segue terminal', () async {
      final cubit = await carregado();
      when(() => buscar(any())).thenAnswer(
        (_) async => Result.failure(const SessaoExpiradaException()),
      );

      await cubit.aplicarPeriodo(periodo);

      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      await cubit.close();
    });
  });

  group('carregarOpcoesDeImovel (D-19, D-23)', () {
    const opcoes = [
      ImovelComContato(id: 7, codigo: 'DEV-7', titulo: 'Casa 7'),
      ImovelComContato(id: 3, codigo: 'DEV-3', titulo: 'Casa 3'),
    ];

    test('estado inicial: opções não carregadas', () {
      expect(
        construir().state.opcoesDeImovel,
        const OpcoesDeImovel.naoCarregadas(),
      );
    });

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'emite carregando e depois carregadas, na ordem do servidor',
      build: construir,
      setUp: () {
        when(() => listarImoveis())
            .thenAnswer((_) async => Result.success(opcoes));
      },
      act: (cubit) => cubit.carregarOpcoesDeImovel(),
      expect: () => [
        const CaixaContatosState(opcoesDeImovel: OpcoesDeImovel.carregando()),
        const CaixaContatosState(
          opcoesDeImovel: OpcoesDeImovel.carregadas(opcoes),
        ),
      ],
    );

    blocTest<CaixaContatosCubit, CaixaContatosState>(
      'falha genérica emite erro',
      build: construir,
      setUp: () {
        when(() => listarImoveis())
            .thenAnswer((_) async => Result.failure(Exception('rede')));
      },
      act: (cubit) => cubit.carregarOpcoesDeImovel(),
      expect: () => [
        const CaixaContatosState(opcoesDeImovel: OpcoesDeImovel.carregando()),
        const CaixaContatosState(opcoesDeImovel: OpcoesDeImovel.erro()),
      ],
    );

    test('sessão expirada leva a sessaoExpirada', () async {
      when(() => listarImoveis()).thenAnswer(
        (_) async => Result.failure(const SessaoExpiradaException()),
      );
      final cubit = construir();

      await cubit.carregarOpcoesDeImovel();

      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      await cubit.close();
    });

    test('chamar de novo recarrega com nova requisição', () async {
      when(() => listarImoveis())
          .thenAnswer((_) async => Result.success(opcoes));
      final cubit = construir();

      await cubit.carregarOpcoesDeImovel();
      await cubit.carregarOpcoesDeImovel();

      verify(() => listarImoveis()).called(2);
      expect(
        cubit.state.opcoesDeImovel,
        const OpcoesDeImovel.carregadas(opcoes),
      );
      await cubit.close();
    });

    test('depois de um erro, chamar de novo tenta outra vez', () async {
      var chamadas = 0;
      when(() => listarImoveis()).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : Result.success(opcoes);
      });
      final cubit = construir();

      await cubit.carregarOpcoesDeImovel();
      expect(cubit.state.opcoesDeImovel, const OpcoesDeImovel.erro());
      await cubit.carregarOpcoesDeImovel();

      expect(
        cubit.state.opcoesDeImovel,
        const OpcoesDeImovel.carregadas(opcoes),
      );
      await cubit.close();
    });

    test('enquanto carrega, uma segunda chamada é ignorada', () async {
      final resposta = Completer<Result<List<ImovelComContato>>>();
      when(() => listarImoveis()).thenAnswer((_) => resposta.future);
      final cubit = construir();

      final primeira = cubit.carregarOpcoesDeImovel();
      await cubit.carregarOpcoesDeImovel();
      resposta.complete(Result.success(opcoes));
      await primeira;

      verify(() => listarImoveis()).called(1);
      await cubit.close();
    });

    test('nenhum emit depois de close()', () async {
      final resposta = Completer<Result<List<ImovelComContato>>>();
      when(() => listarImoveis()).thenAnswer((_) => resposta.future);
      final cubit = construir();

      final pendente = cubit.carregarOpcoesDeImovel();
      await cubit.close();
      resposta.complete(Result.success(opcoes));
      await pendente;

      expect(cubit.isClosed, isTrue);
    });

    test('não mexe na lista nem no número', () async {
      when(() => listarImoveis())
          .thenAnswer((_) async => Result.success(opcoes));
      final cubit = construir();

      await cubit.carregarOpcoesDeImovel();

      verifyNever(() => buscar(any()));
      verifyNever(() => obterSemRetorno());
      expect(cubit.state.conteudo, const ConteudoCaixa.carregando());
      await cubit.close();
    });
  });

  group('anotarRetorno (D-06, D-15, D-16, D-17, D-23)', () {
    final anotadoEm = DateTime(2026, 11, 21, 10, 15);
    final item1Anotado = _contato(
      1,
      retorno: RetornoContato.falei,
      retornoEm: anotadoEm,
    );

    /// Cubit com a lista (itens 1 e 2, pendentes) e o número 25 carregados,
    /// sem chamadas pendentes nos falsos.
    Future<CaixaContatosCubit> carregado() async {
      listaResponde(pagina1);
      resumoResponde(25);
      final cubit = construir()..carregar();
      await assentar();
      clearInteractions(buscar);
      clearInteractions(obterSemRetorno);
      return cubit;
    }

    void patchResponde(Result<ContatoRecebido> resultado) {
      when(() => anotarRetorno(any(), any()))
          .thenAnswer((_) async => resultado);
    }

    CaixaCarregada lista(CaixaContatosCubit cubit) =>
        cubit.state.conteudo as CaixaCarregada;

    test(
      'sucesso: item em voo, troca pelo do servidor e número novo',
      () async {
        final cubit = await carregado();
        patchResponde(Result.success(item1Anotado));
        resumoResponde(24);
        final estados = <CaixaContatosState>[];
        final inscricao = cubit.stream.listen(estados.add);

        await cubit.anotarRetorno(1, RetornoContato.falei);
        await assentar();
        await inscricao.cancel();

        expect(lista(cubit).itens, [item1Anotado, _contato(2)]);
        expect(lista(cubit).anotando, isEmpty);
        expect(cubit.state.semRetorno, 24);
        expect(cubit.state.aviso, isNull);
        expect((estados.first.conteudo as CaixaCarregada).anotando, {1});
        expect(estados.first.aviso, isNull);
        verify(() => anotarRetorno(1, RetornoContato.falei)).called(1);
        verify(() => obterSemRetorno()).called(1);
        await cubit.close();
      },
    );

    test(
      'sem otimismo: enquanto o PATCH não volta, o retorno não muda',
      () async {
        final resposta = Completer<Result<ContatoRecebido>>();
        when(() => anotarRetorno(any(), any()))
            .thenAnswer((_) => resposta.future);
        final cubit = await carregado();
        final estados = <CaixaContatosState>[];
        final inscricao = cubit.stream.listen(estados.add);

        final pendente = cubit.anotarRetorno(1, RetornoContato.falei);
        await assentar();

        expect(lista(cubit).itens.first.retorno, RetornoContato.pendente);
        expect(lista(cubit).anotando, {1});
        expect(cubit.state.semRetorno, 25);

        resposta.complete(Result.success(item1Anotado));
        await pendente;
        await assentar();
        await inscricao.cancel();

        final retornosEmitidos = estados
            .map((e) => e.conteudo)
            .whereType<CaixaCarregada>()
            .map((c) => c.itens.first.retorno)
            .toList();
        expect(retornosEmitidos.first, RetornoContato.pendente);
        expect(retornosEmitidos.last, RetornoContato.falei);
        await cubit.close();
      },
    );

    test('segundo toque no mesmo item em voo não chama o use case', () async {
      final resposta = Completer<Result<ContatoRecebido>>();
      when(() => anotarRetorno(any(), any()))
          .thenAnswer((_) => resposta.future);
      final cubit = await carregado();

      final primeira = cubit.anotarRetorno(1, RetornoContato.falei);
      await cubit.anotarRetorno(1, RetornoContato.descartado);
      resposta.complete(Result.success(item1Anotado));
      await primeira;

      verify(() => anotarRetorno(any(), any())).called(1);
      await cubit.close();
    });

    test('a opção igual à atual não chama o use case (A6)', () async {
      listaResponde(
        PaginaContatos(itens: [_contato(1, retorno: RetornoContato.falei)]),
      );
      resumoResponde(25);
      final cubit = construir()..carregar();
      await assentar();

      await cubit.anotarRetorno(1, RetornoContato.falei);

      verifyNever(() => anotarRetorno(any(), any()));
      expect(lista(cubit).anotando, isEmpty);
      await cubit.close();
    });

    test('um contato já anotado aceita outra opção (D-15)', () async {
      listaResponde(
        PaginaContatos(itens: [_contato(1, retorno: RetornoContato.falei)]),
      );
      resumoResponde(25);
      final cubit = construir()..carregar();
      await assentar();
      final trocado = _contato(
        1,
        retorno: RetornoContato.visitaAgendada,
        retornoEm: anotadoEm,
      );
      patchResponde(Result.success(trocado));

      await cubit.anotarRetorno(1, RetornoContato.visitaAgendada);

      expect(lista(cubit).itens, [trocado]);
      await cubit.close();
    });

    test(
      'id fora da lista, PENDENTE e estado sem lista não chamam a API',
      () async {
        final cubit = await carregado();

        await cubit.anotarRetorno(99, RetornoContato.falei);
        await cubit.anotarRetorno(1, RetornoContato.pendente);

        final semLista = construir();
        await semLista.anotarRetorno(1, RetornoContato.falei);

        verifyNever(() => anotarRetorno(any(), any()));
        await cubit.close();
        await semLista.close();
      },
    );

    test(
      'falha genérica: o item fica igual e o aviso é falhouAoAnotar',
      () async {
        final cubit = await carregado();
        patchResponde(Result.failure(Exception('rede')));

        await cubit.anotarRetorno(1, RetornoContato.falei);

        expect(lista(cubit).itens, itensPagina1);
        expect(lista(cubit).anotando, isEmpty);
        expect(cubit.state.aviso, AvisoCaixa.falhouAoAnotar);
        expect(cubit.state.semRetorno, 25);
        await cubit.close();
      },
    );

    test('FormatException também vira falhouAoAnotar', () async {
      final cubit = await carregado();
      patchResponde(Result.failure(const FormatException('corpo')));

      await cubit.anotarRetorno(1, RetornoContato.falei);

      expect(cubit.state.aviso, AvisoCaixa.falhouAoAnotar);
      await cubit.close();
    });

    test('duas falhas seguidas emitem o aviso duas vezes (Pitfall 6)', () async {
      final cubit = await carregado();
      patchResponde(Result.failure(Exception('rede')));
      final estados = <CaixaContatosState>[];
      final inscricao = cubit.stream.listen(estados.add);

      await cubit.anotarRetorno(1, RetornoContato.falei);
      await cubit.anotarRetorno(1, RetornoContato.falei);
      await assentar();
      await inscricao.cancel();

      final comAviso = estados
          .where((e) => e.aviso == AvisoCaixa.falhouAoAnotar)
          .toList();
      expect(comAviso, hasLength(2));
      // Entre as duas há um estado sem aviso: a segunda não é igual à primeira.
      final indices = [
        for (var i = 0; i < estados.length; i++)
          if (estados[i].aviso != null) i,
      ];
      expect(
        estados
            .sublist(indices.first, indices.last)
            .any((e) => e.aviso == null),
        isTrue,
      );
      await cubit.close();
    });

    test(
      '404: aviso contatoSumiu, lista recarregada e número de novo',
      () async {
        final cubit = await carregado();
        patchResponde(Result.failure(const ContatoNaoEncontradoException()));
        resumoResponde(24);

        await cubit.anotarRetorno(1, RetornoContato.falei);
        await assentar();

        expect(cubit.state.aviso, AvisoCaixa.contatoSumiu);
        verify(() => buscar(const ConsultaContatos())).called(1);
        verify(() => obterSemRetorno()).called(1);
        expect(cubit.state.semRetorno, 24);
        expect(lista(cubit).anotando, isEmpty);
        await cubit.close();
      },
    );

    test('401 leva a sessaoExpirada, terminal', () async {
      final cubit = await carregado();
      patchResponde(Result.failure(const SessaoExpiradaException()));

      await cubit.anotarRetorno(1, RetornoContato.falei);
      await assentar();

      expect(cubit.state.conteudo, const ConteudoCaixa.sessaoExpirada());
      await cubit.close();
    });

    test('filtro trocado com o PATCH em voo: não reabre a lista antiga, '
        'mas pede o número', () async {
      final resposta = Completer<Result<ContatoRecebido>>();
      when(() => anotarRetorno(any(), any()))
          .thenAnswer((_) => resposta.future);
      final cubit = await carregado();
      const imovel = ImovelComContato(id: 7, codigo: 'DEV-7', titulo: 'Casa 7');
      when(() => buscar(const ConsultaContatos(imovel: imovel)))
          .thenAnswer((_) async => Result.success(pagina2));
      resumoResponde(24);

      final pendente = cubit.anotarRetorno(1, RetornoContato.falei);
      await cubit.aplicarImovel(imovel);
      resposta.complete(Result.success(item1Anotado));
      await pendente;
      await assentar();

      expect(lista(cubit).itens, pagina2.itens);
      expect(cubit.state.consulta, const ConsultaContatos(imovel: imovel));
      expect(cubit.state.semRetorno, 24);
      verify(() => obterSemRetorno()).called(1);
      await cubit.close();
    });

    test('nenhum emit depois de close() com o PATCH em voo', () async {
      final resposta = Completer<Result<ContatoRecebido>>();
      when(() => anotarRetorno(any(), any()))
          .thenAnswer((_) => resposta.future);
      final cubit = await carregado();

      final pendente = cubit.anotarRetorno(1, RetornoContato.falei);
      await cubit.close();
      resposta.complete(Result.success(item1Anotado));
      await pendente;
      await assentar();

      expect(cubit.isClosed, isTrue);
    });
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
