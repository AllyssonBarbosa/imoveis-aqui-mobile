import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart';
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:mocktail/mocktail.dart';

class _GeolocatorGatewayFalso extends Mock implements GeolocatorGateway {}

class _ObterCidadesAtendidasUseCaseFalso extends Mock
    implements ObterCidadesAtendidasUseCase {}

class _DetectarCidadeUseCaseFalso extends Mock
    implements DetectarCidadeUseCase {}

void main() {
  late _GeolocatorGatewayFalso geolocator;
  late _ObterCidadesAtendidasUseCaseFalso obterCidadesAtendidas;
  late _DetectarCidadeUseCaseFalso detectarCidade;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const listaAtendida = [campinas, Cidade(nome: 'Valinhos', uf: 'SP')];

  setUp(() {
    geolocator = _GeolocatorGatewayFalso();
    obterCidadesAtendidas = _ObterCidadesAtendidasUseCaseFalso();
    detectarCidade = _DetectarCidadeUseCaseFalso();
  });

  CidadeSelecaoCubit construir() =>
      CidadeSelecaoCubit(geolocator, obterCidadesAtendidas, detectarCidade);

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'serviço de localização desligado → emite servicoDesligado com a lista',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => false);
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.servicoDesligado(listaAtendida),
    ],
    verify: (_) {
      verifyNever(() => geolocator.verificarPermissao());
    },
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'permissão negada e recusada novamente após solicitar → emite recusada '
    '(requestPermission chamado exatamente uma vez)',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.negada,
      );
      when(() => geolocator.solicitarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.negada,
      );
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.recusada(listaAtendida),
    ],
    verify: (_) {
      verify(() => geolocator.solicitarPermissao()).called(1);
    },
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'permissão bloqueada para sempre (sem chamar requestPermission) → '
    'emite bloqueadaParaSempre',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.negadaParaSempre,
      );
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.bloqueadaParaSempre(listaAtendida),
    ],
    verify: (_) {
      verifyNever(() => geolocator.solicitarPermissao());
    },
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'permissão indeterminada é tratada como recusada (sem requestPermission)',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.indeterminada,
      );
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.recusada(listaAtendida),
    ],
    verify: (_) {
      verifyNever(() => geolocator.solicitarPermissao());
    },
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'autorizado (whileInUse) → delega ao DetectarCidadeUseCase e emite '
    'autorizadaEAtendida',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.duranteUso,
      );
      when(
        () => detectarCidade(),
      ).thenAnswer((_) async => const CidadeSelecaoState.autorizadaEAtendida(campinas));
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.autorizadaEAtendida(campinas),
    ],
    verify: (_) {
      verifyNever(() => geolocator.solicitarPermissao());
    },
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'autorizado (always) + cidade não atendida → emite autorizadaNaoAtendida',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.sempre,
      );
      when(() => detectarCidade()).thenAnswer(
        (_) async => const CidadeSelecaoState.autorizadaNaoAtendida(
          'Sorocaba',
          listaAtendida,
        ),
      );
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.autorizadaNaoAtendida('Sorocaba', listaAtendida),
    ],
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'autorizado + geocodificação falha → emite falhaGeocodificacao (via '
    'DetectarCidadeUseCase)',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => true);
      when(() => geolocator.verificarPermissao()).thenAnswer(
        (_) async => GatewayPermissaoLocalizacao.duranteUso,
      );
      when(() => detectarCidade()).thenAnswer(
        (_) async => const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
      );
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
    ],
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'asset de cidades falha ao carregar durante o fallback → emite '
    'erroCarregarCidades, nunca uma tela fatal',
    build: construir,
    setUp: () {
      when(
        () => geolocator.isServicoHabilitado(),
      ).thenAnswer((_) async => false);
      when(() => obterCidadesAtendidas()).thenAnswer(
        (_) async => Result.failure(Exception('parse falhou')),
      );
    },
    act: (cubit) => cubit.detectarCidade(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.erroCarregarCidades(),
    ],
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'carregarLista() carrega a lista atendida e emite recusada',
    build: construir,
    setUp: () {
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
    },
    act: (cubit) => cubit.carregarLista(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.recusada(listaAtendida),
    ],
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'carregarLista() com falha no asset emite erroCarregarCidades ('
    '"Tentar de novo" nunca fica preso num beco)',
    build: construir,
    setUp: () {
      when(() => obterCidadesAtendidas()).thenAnswer(
        (_) async => Result.failure(Exception('parse falhou')),
      );
    },
    act: (cubit) => cubit.carregarLista(),
    expect: () => [
      const CidadeSelecaoState.localizando(),
      const CidadeSelecaoState.erroCarregarCidades(),
    ],
  );

  blocTest<CidadeSelecaoCubit, CidadeSelecaoState>(
    'entrarDireto(cidade) emite autorizadaEAtendida sem tocar GPS/permissão',
    build: construir,
    act: (cubit) => cubit.entrarDireto(campinas),
    expect: () => [const CidadeSelecaoState.autorizadaEAtendida(campinas)],
    verify: (_) {
      verifyNever(() => geolocator.isServicoHabilitado());
      verifyNever(() => geolocator.verificarPermissao());
      verifyNever(() => geolocator.solicitarPermissao());
    },
  );
}
