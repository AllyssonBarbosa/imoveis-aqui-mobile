import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/geocoding_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/cidade_repository.dart';
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:mocktail/mocktail.dart';

class _GeolocatorGatewayFalso extends Mock implements GeolocatorGateway {}

class _GeocodingGatewayFalso extends Mock implements GeocodingGateway {}

class _CidadeRepositoryFalso extends Mock implements CidadeRepository {}

void main() {
  late _GeolocatorGatewayFalso geolocator;
  late _GeocodingGatewayFalso geocoding;
  late _CidadeRepositoryFalso repositorio;
  late DetectarCidadeUseCase caso;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const listaAtendida = [campinas, valinhos];
  const posicao = GatewayPosicao(latitude: -22.9, longitude: -47.06);

  setUp(() {
    geolocator = _GeolocatorGatewayFalso();
    geocoding = _GeocodingGatewayFalso();
    repositorio = _CidadeRepositoryFalso();
    caso = DetectarCidadeUseCase(geolocator, geocoding, repositorio);
  });

  test(
    'asset de cidades falha ao carregar → erroCarregarCidades',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => Result.failure(Exception('parse falhou')));

      final estado = await caso();

      expect(estado, const CidadeSelecaoState.erroCarregarCidades());
      verifyNever(() => geolocator.obterPosicaoAtual());
    },
  );

  test(
    'GPS falha → falhaGeocodificacao com a lista atendida carregada',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(
        () => geolocator.obterPosicaoAtual(),
      ).thenAnswer((_) async => Result.failure(Exception('GPS indisponível')));

      final estado = await caso();

      expect(
        estado,
        const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
      );
    },
  );

  test(
    'reverse geocoding falha (sem resultado/MissingPluginException) → falhaGeocodificacao',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(
        () => geolocator.obterPosicaoAtual(),
      ).thenAnswer((_) async => const Result.success(posicao));
      when(
        () => geocoding.cidadeDeCoordenadas(any(), any()),
      ).thenAnswer((_) async => Result.failure(Exception('sem resultado')));

      final estado = await caso();

      expect(
        estado,
        const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
      );
    },
  );

  test(
    'cidade detectada ESTÁ na lista atendida (nome+uf normalizado) → autorizadaEAtendida',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(
        () => geolocator.obterPosicaoAtual(),
      ).thenAnswer((_) async => const Result.success(posicao));
      when(() => geocoding.cidadeDeCoordenadas(any(), any())).thenAnswer(
        (_) async => const Result.success(
          GatewayLugar(localidade: 'Campinas', administrativeArea: 'São Paulo'),
        ),
      );

      final estado = await caso();

      expect(estado, const CidadeSelecaoState.autorizadaEAtendida(campinas));
    },
  );

  test(
    'cidade detectada NÃO está na lista atendida → autorizadaNaoAtendida com nome + lista',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(
        () => geolocator.obterPosicaoAtual(),
      ).thenAnswer((_) async => const Result.success(posicao));
      when(() => geocoding.cidadeDeCoordenadas(any(), any())).thenAnswer(
        (_) async => const Result.success(
          GatewayLugar(localidade: 'Sorocaba', administrativeArea: 'SP'),
        ),
      );

      final estado = await caso();

      expect(
        estado,
        const CidadeSelecaoState.autorizadaNaoAtendida(
          'Sorocaba',
          listaAtendida,
        ),
      );
    },
  );

  test(
    'localidade nula no reverse geocoding → falhaGeocodificacao (sem resultado utilizável)',
    () async {
      when(
        () => repositorio.obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(
        () => geolocator.obterPosicaoAtual(),
      ).thenAnswer((_) async => const Result.success(posicao));
      when(() => geocoding.cidadeDeCoordenadas(any(), any())).thenAnswer(
        (_) async =>
            const Result.success(GatewayLugar(localidade: null, administrativeArea: 'SP')),
      );

      final estado = await caso();

      expect(
        estado,
        const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
      );
    },
  );
}
