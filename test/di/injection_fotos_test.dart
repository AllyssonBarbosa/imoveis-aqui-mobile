import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/fotos_imovel_datasource.dart';
import 'package:imoveis_aqui/data/datasources/fotos_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/gateways/preparador_de_foto_compressao.dart';
import 'package:imoveis_aqui/data/gateways/seletor_de_fotos_image_picker.dart';
import 'package:imoveis_aqui/data/repositories/fotos_imovel_repository_impl.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/gateways/preparador_de_foto_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/seletor_de_fotos_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/fotos_imovel_repository.dart';
import 'package:imoveis_aqui/domain/usecases/apagar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/definir_capa_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/descartar_foto_preparada_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/enviar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/listar_fotos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/preparar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/reordenar_fotos_usecase.dart';

/// Canário do DI das fotos do imóvel (APP 11): o app de verdade resolve os 7
/// use cases, e as implementações ativas são as reais — DataSource remota no
/// `Dio` autenticado, `image_picker` e `flutter_image_compress` (sem falso em
/// produção). Nenhum plugin é chamado: só os construtores rodam.
void main() {
  tearDown(() async => getIt.reset());

  test('resolve os 7 use cases das fotos pelo DI de produção', () async {
    await configureDependencies();

    expect(getIt<ListarFotosUseCase>(), isA<ListarFotosUseCase>());
    expect(getIt<PrepararFotoUseCase>(), isA<PrepararFotoUseCase>());
    expect(getIt<EnviarFotoUseCase>(), isA<EnviarFotoUseCase>());
    expect(
      getIt<DescartarFotoPreparadaUseCase>(),
      isA<DescartarFotoPreparadaUseCase>(),
    );
    expect(getIt<ReordenarFotosUseCase>(), isA<ReordenarFotosUseCase>());
    expect(getIt<DefinirCapaUseCase>(), isA<DefinirCapaUseCase>());
    expect(getIt<ApagarFotoUseCase>(), isA<ApagarFotoUseCase>());
  });

  test('as implementações ativas são as reais', () async {
    await configureDependencies();

    expect(getIt<FotosImovelDataSource>(), isA<FotosImovelRemoteDataSource>());
    expect(getIt<FotosImovelRepository>(), isA<FotosImovelRepositoryImpl>());
    expect(getIt<SeletorDeFotosGateway>(), isA<SeletorDeFotosImagePicker>());
    expect(getIt<PreparadorDeFotoGateway>(), isA<PreparadorDeFotoCompressao>());
  });
}
