// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:imoveis_aqui/data/datasources/cidade_local_datasource.dart'
    as _i736;
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart'
    as _i94;
import 'package:imoveis_aqui/data/datasources/imovel_datasource.dart' as _i326;
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart'
    as _i609;
import 'package:imoveis_aqui/data/gateways/geocoding_gateway_impl.dart'
    as _i506;
import 'package:imoveis_aqui/data/gateways/geolocator_gateway_impl.dart'
    as _i777;
import 'package:imoveis_aqui/data/repositories/cidade_repository_impl.dart'
    as _i912;
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart'
    as _i1051;
import 'package:imoveis_aqui/domain/gateways/geocoding_gateway.dart' as _i881;
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart' as _i246;
import 'package:imoveis_aqui/domain/repositories/cidade_repository.dart'
    as _i146;
import 'package:imoveis_aqui/domain/repositories/imovel_repository.dart'
    as _i970;
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart'
    as _i213;
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart'
    as _i502;
import 'package:imoveis_aqui/domain/usecases/obter_cidade_salva_usecase.dart'
    as _i1060;
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart'
    as _i54;
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart'
    as _i589;
import 'package:imoveis_aqui/domain/usecases/validar_cidade_atendida_usecase.dart'
    as _i14;
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart'
    as _i765;
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart' as _i486;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i736.CidadeLocalDataSource>(
      () => _i736.CidadeLocalDataSource(),
    );
    gh.lazySingleton<_i94.CidadePrefsDataSource>(
      () => _i94.CidadePrefsDataSource(),
    );
    gh.lazySingleton<_i881.GeocodingGateway>(
      () => _i506.GeocodingGatewayImpl(),
    );
    gh.lazySingleton<_i246.GeolocatorGateway>(
      () => _i777.GeolocatorGatewayImpl(),
    );
    gh.lazySingleton<_i146.CidadeRepository>(
      () => _i912.CidadeRepositoryImpl(
        gh<_i736.CidadeLocalDataSource>(),
        gh<_i94.CidadePrefsDataSource>(),
      ),
    );
    gh.lazySingleton<_i326.ImovelDataSource>(
      () => _i609.ImovelMockDataSource(),
    );
    gh.factory<_i502.DetectarCidadeUseCase>(
      () => _i502.DetectarCidadeUseCase(
        gh<_i246.GeolocatorGateway>(),
        gh<_i881.GeocodingGateway>(),
        gh<_i146.CidadeRepository>(),
      ),
    );
    gh.lazySingleton<_i970.ImovelRepository>(
      () => _i1051.ImovelRepositoryImpl(gh<_i326.ImovelDataSource>()),
    );
    gh.factory<_i213.BuscarImoveisUseCase>(
      () => _i213.BuscarImoveisUseCase(gh<_i970.ImovelRepository>()),
    );
    gh.factory<_i1060.ObterCidadeSalvaUseCase>(
      () => _i1060.ObterCidadeSalvaUseCase(gh<_i146.CidadeRepository>()),
    );
    gh.factory<_i54.ObterCidadesAtendidasUseCase>(
      () => _i54.ObterCidadesAtendidasUseCase(gh<_i146.CidadeRepository>()),
    );
    gh.factory<_i589.SalvarCidadeUseCase>(
      () => _i589.SalvarCidadeUseCase(gh<_i146.CidadeRepository>()),
    );
    gh.factory<_i486.VitrineCubit>(
      () => _i486.VitrineCubit(gh<_i213.BuscarImoveisUseCase>()),
    );
    gh.factory<_i14.ValidarCidadeAtendidaUseCase>(
      () => _i14.ValidarCidadeAtendidaUseCase(
        gh<_i54.ObterCidadesAtendidasUseCase>(),
      ),
    );
    gh.factory<_i765.CidadeSelecaoCubit>(
      () => _i765.CidadeSelecaoCubit(
        gh<_i246.GeolocatorGateway>(),
        gh<_i54.ObterCidadesAtendidasUseCase>(),
        gh<_i502.DetectarCidadeUseCase>(),
        gh<_i14.ValidarCidadeAtendidaUseCase>(),
      ),
    );
    return this;
  }
}
