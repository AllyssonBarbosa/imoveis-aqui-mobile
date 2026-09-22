import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/geocoding_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/validar_cidade_atendida_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterCidadesAtendidasUseCaseFalso extends Mock
    implements ObterCidadesAtendidasUseCase {}

// Dublês nunca conectados ao caso de uso (que não depende de nenhum dos
// dois) — instanciados apenas para provar, com verifyZeroInteractions, que
// revalidar a cidade salva (D-08/A2) não passa nem de longe pelo GPS ou
// reverse geocoding.
class _GeolocatorGatewayFalso extends Mock implements GeolocatorGateway {}

class _GeocodingGatewayFalso extends Mock implements GeocodingGateway {}

void main() {
  late _ObterCidadesAtendidasUseCaseFalso obterCidadesAtendidas;
  late _GeolocatorGatewayFalso geolocator;
  late _GeocodingGatewayFalso geocoding;
  late ValidarCidadeAtendidaUseCase caso;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const listaAtendida = [campinas, valinhos];

  setUp(() {
    obterCidadesAtendidas = _ObterCidadesAtendidasUseCaseFalso();
    geolocator = _GeolocatorGatewayFalso();
    geocoding = _GeocodingGatewayFalso();
    caso = ValidarCidadeAtendidaUseCase(obterCidadesAtendidas);
  });

  test(
    'cidade salva AINDA está na lista atendida (chaveNatural) → '
    'autorizadaEAtendida, sem GPS/geocodificação (D-08)',
    () async {
      // Variação de caixa/acentos na cidade salva para provar que o
      // casamento usa chaveNatural normalizada (D-09), não igualdade
      // exata de string.
      const cidadeSalva = Cidade(nome: 'campinas', uf: 'sp');
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));

      final estado = await caso(cidadeSalva);

      expect(estado, const CidadeSelecaoState.autorizadaEAtendida(campinas));
      verifyZeroInteractions(geolocator);
      verifyZeroInteractions(geocoding);
    },
  );

  test(
    'cidade salva NÃO está mais na lista atendida → autorizadaNaoAtendida '
    'com a lista atual (RESEARCH Pitfall 5/A2, nunca uma cidade fantasma)',
    () async {
      const cidadeSalva = Cidade(nome: 'Sorocaba', uf: 'SP');
      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));

      final estado = await caso(cidadeSalva);

      expect(
        estado,
        const CidadeSelecaoState.autorizadaNaoAtendida(
          'Sorocaba',
          listaAtendida,
        ),
      );
      verifyZeroInteractions(geolocator);
      verifyZeroInteractions(geocoding);
    },
  );

  test(
    'falha ao carregar a lista atendida → erroCarregarCidades, nunca uma '
    'tela fatal (LOC-06)',
    () async {
      const cidadeSalva = campinas;
      when(() => obterCidadesAtendidas()).thenAnswer(
        (_) async => Result.failure(Exception('parse falhou')),
      );

      final estado = await caso(cidadeSalva);

      expect(estado, const CidadeSelecaoState.erroCarregarCidades());
      verifyZeroInteractions(geolocator);
      verifyZeroInteractions(geocoding);
    },
  );
}
