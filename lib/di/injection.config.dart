// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:imoveis_aqui/data/datasources/acervo_datasource.dart' as _i744;
import 'package:imoveis_aqui/data/datasources/acervo_remote_datasource.dart'
    as _i659;
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart'
    as _i288;
import 'package:imoveis_aqui/data/datasources/armazenamento_token_seguro.dart'
    as _i179;
import 'package:imoveis_aqui/data/datasources/autenticacao_datasource.dart'
    as _i887;
import 'package:imoveis_aqui/data/datasources/autenticacao_remote_datasource.dart'
    as _i652;
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart'
    as _i94;
import 'package:imoveis_aqui/data/datasources/cidade_remote_datasource.dart'
    as _i320;
import 'package:imoveis_aqui/data/datasources/imovel_datasource.dart' as _i326;
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart'
    as _i631;
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_remote_datasource.dart'
    as _i601;
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart'
    as _i877;
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_datasource.dart'
    as _i585;
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart'
    as _i429;
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart' as _i185;
import 'package:imoveis_aqui/data/datasources/perfil_remote_datasource.dart'
    as _i879;
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_datasource.dart'
    as _i736;
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_remote_datasource.dart'
    as _i461;
import 'package:imoveis_aqui/data/gateways/geocoding_gateway_impl.dart'
    as _i506;
import 'package:imoveis_aqui/data/gateways/geolocator_gateway_impl.dart'
    as _i777;
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart' as _i668;
import 'package:imoveis_aqui/data/repositories/acervo_repository_impl.dart'
    as _i443;
import 'package:imoveis_aqui/data/repositories/autenticacao_repository_impl.dart'
    as _i214;
import 'package:imoveis_aqui/data/repositories/cidade_repository_impl.dart'
    as _i912;
import 'package:imoveis_aqui/data/repositories/imovel_detalhe_repository_impl.dart'
    as _i109;
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart'
    as _i1051;
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart'
    as _i375;
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart'
    as _i890;
import 'package:imoveis_aqui/data/repositories/vitrine_anunciante_repository_impl.dart'
    as _i477;
import 'package:imoveis_aqui/di/modulo_rede.dart' as _i497;
import 'package:imoveis_aqui/domain/gateways/geocoding_gateway.dart' as _i881;
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart' as _i246;
import 'package:imoveis_aqui/domain/repositories/acervo_repository.dart'
    as _i268;
import 'package:imoveis_aqui/domain/repositories/autenticacao_repository.dart'
    as _i550;
import 'package:imoveis_aqui/domain/repositories/cidade_repository.dart'
    as _i146;
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart'
    as _i977;
import 'package:imoveis_aqui/domain/repositories/imovel_repository.dart'
    as _i970;
import 'package:imoveis_aqui/domain/repositories/opcoes_filtro_repository.dart'
    as _i987;
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart'
    as _i195;
import 'package:imoveis_aqui/domain/repositories/vitrine_anunciante_repository.dart'
    as _i868;
import 'package:imoveis_aqui/domain/usecases/buscar_acervo_usecase.dart'
    as _i89;
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart'
    as _i427;
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart'
    as _i213;
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart'
    as _i502;
import 'package:imoveis_aqui/domain/usecases/entrar_usecase.dart' as _i411;
import 'package:imoveis_aqui/domain/usecases/ler_sessao_usecase.dart' as _i560;
import 'package:imoveis_aqui/domain/usecases/obter_bairros_usecase.dart'
    as _i20;
import 'package:imoveis_aqui/domain/usecases/obter_caracteristicas_usecase.dart'
    as _i441;
import 'package:imoveis_aqui/domain/usecases/obter_cidade_salva_usecase.dart'
    as _i1060;
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart'
    as _i54;
import 'package:imoveis_aqui/domain/usecases/obter_detalhe_imovel_usecase.dart'
    as _i990;
import 'package:imoveis_aqui/domain/usecases/obter_papel_usecase.dart' as _i396;
import 'package:imoveis_aqui/domain/usecases/obter_perfil_corretor_usecase.dart'
    as _i741;
import 'package:imoveis_aqui/domain/usecases/obter_perfil_empresa_usecase.dart'
    as _i370;
import 'package:imoveis_aqui/domain/usecases/sair_usecase.dart' as _i986;
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart'
    as _i589;
import 'package:imoveis_aqui/domain/usecases/validar_cidade_atendida_usecase.dart'
    as _i14;
import 'package:imoveis_aqui/presentation/acervo/acervo_cubit.dart' as _i587;
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart'
    as _i765;
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart'
    as _i331;
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart'
    as _i194;
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart'
    as _i723;
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart'
    as _i325;
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart' as _i231;
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart'
    as _i1002;
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart'
    as _i59;
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart' as _i486;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final moduloRede = _$ModuloRede();
    gh.lazySingleton<_i94.CidadePrefsDataSource>(
      () => _i94.CidadePrefsDataSource(),
    );
    gh.lazySingleton<_i361.Dio>(() => moduloRede.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => moduloRede.armazenamentoSeguro,
    );
    gh.lazySingleton<_i59.SessaoFiltrosVitrine>(
      () => _i59.SessaoFiltrosVitrine(),
    );
    gh.lazySingleton<_i326.ImovelDataSource>(
      () => _i877.ImovelRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i736.VitrineAnuncianteDataSource>(
      () => _i461.VitrineAnuncianteRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i881.GeocodingGateway>(
      () => _i506.GeocodingGatewayImpl(),
    );
    gh.lazySingleton<_i246.GeolocatorGateway>(
      () => _i777.GeolocatorGatewayImpl(),
    );
    gh.lazySingleton<_i585.OpcoesFiltroDataSource>(
      () => _i429.OpcoesFiltroRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i631.ImovelDetalheDataSource>(
      () => _i601.ImovelDetalheRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i185.PerfilDataSource>(
      () => _i879.PerfilRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i970.ImovelRepository>(
      () => _i1051.ImovelRepositoryImpl(gh<_i326.ImovelDataSource>()),
    );
    gh.lazySingleton<_i320.CidadeRemoteDataSource>(
      () => _i320.CidadeRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i868.VitrineAnuncianteRepository>(
      () => _i477.VitrineAnuncianteRepositoryImpl(
        gh<_i736.VitrineAnuncianteDataSource>(),
      ),
    );
    gh.lazySingleton<_i195.PerfilRepository>(
      () => _i890.PerfilRepositoryImpl(gh<_i185.PerfilDataSource>()),
    );
    gh.factory<_i741.ObterPerfilCorretorUseCase>(
      () => _i741.ObterPerfilCorretorUseCase(gh<_i195.PerfilRepository>()),
    );
    gh.factory<_i370.ObterPerfilEmpresaUseCase>(
      () => _i370.ObterPerfilEmpresaUseCase(gh<_i195.PerfilRepository>()),
    );
    gh.factory<_i213.BuscarImoveisUseCase>(
      () => _i213.BuscarImoveisUseCase(gh<_i970.ImovelRepository>()),
    );
    gh.lazySingleton<_i288.ArmazenamentoToken>(
      () => _i179.ArmazenamentoTokenSeguro(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i987.OpcoesFiltroRepository>(
      () =>
          _i375.OpcoesFiltroRepositoryImpl(gh<_i585.OpcoesFiltroDataSource>()),
    );
    gh.lazySingleton<_i977.ImovelDetalheRepository>(
      () => _i109.ImovelDetalheRepositoryImpl(
        gh<_i631.ImovelDetalheDataSource>(),
      ),
    );
    gh.factory<_i427.BuscarImoveisDoAnuncianteUseCase>(
      () => _i427.BuscarImoveisDoAnuncianteUseCase(
        gh<_i868.VitrineAnuncianteRepository>(),
      ),
    );
    gh.factory<_i194.PerfilCorretorCubit>(
      () => _i194.PerfilCorretorCubit(gh<_i741.ObterPerfilCorretorUseCase>()),
    );
    gh.factory<_i990.ObterDetalheImovelUseCase>(
      () =>
          _i990.ObterDetalheImovelUseCase(gh<_i977.ImovelDetalheRepository>()),
    );
    gh.lazySingleton<_i146.CidadeRepository>(
      () => _i912.CidadeRepositoryImpl(
        gh<_i320.CidadeRemoteDataSource>(),
        gh<_i94.CidadePrefsDataSource>(),
      ),
    );
    gh.factory<_i502.DetectarCidadeUseCase>(
      () => _i502.DetectarCidadeUseCase(
        gh<_i246.GeolocatorGateway>(),
        gh<_i881.GeocodingGateway>(),
        gh<_i146.CidadeRepository>(),
      ),
    );
    gh.factory<_i486.VitrineCubit>(
      () => _i486.VitrineCubit(
        gh<_i213.BuscarImoveisUseCase>(),
        gh<_i59.SessaoFiltrosVitrine>(),
      ),
    );
    gh.factory<_i723.PerfilEmpresaCubit>(
      () => _i723.PerfilEmpresaCubit(gh<_i370.ObterPerfilEmpresaUseCase>()),
    );
    gh.factory<_i20.ObterBairrosUseCase>(
      () => _i20.ObterBairrosUseCase(gh<_i987.OpcoesFiltroRepository>()),
    );
    gh.factory<_i441.ObterCaracteristicasUseCase>(
      () =>
          _i441.ObterCaracteristicasUseCase(gh<_i987.OpcoesFiltroRepository>()),
    );
    gh.factory<_i668.InterceptadorSessao>(
      () => _i668.InterceptadorSessao(gh<_i288.ArmazenamentoToken>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => moduloRede.dioAutenticado(gh<_i668.InterceptadorSessao>()),
      instanceName: 'autenticado',
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
    gh.factory<_i1002.OpcoesFiltroCubit>(
      () => _i1002.OpcoesFiltroCubit(
        gh<_i20.ObterBairrosUseCase>(),
        gh<_i441.ObterCaracteristicasUseCase>(),
      ),
    );
    gh.factory<_i325.VitrineAnuncianteCubit>(
      () => _i325.VitrineAnuncianteCubit(
        gh<_i427.BuscarImoveisDoAnuncianteUseCase>(),
      ),
    );
    gh.factory<_i331.DetalheImovelCubit>(
      () => _i331.DetalheImovelCubit(gh<_i990.ObterDetalheImovelUseCase>()),
    );
    gh.lazySingleton<_i887.AutenticacaoDataSource>(
      () => _i652.AutenticacaoRemoteDataSource(
        gh<_i361.Dio>(),
        gh<_i361.Dio>(instanceName: 'autenticado'),
      ),
    );
    gh.lazySingleton<_i744.AcervoDataSource>(
      () => _i659.AcervoRemoteDataSource(
        gh<_i361.Dio>(instanceName: 'autenticado'),
      ),
    );
    gh.factory<_i14.ValidarCidadeAtendidaUseCase>(
      () => _i14.ValidarCidadeAtendidaUseCase(
        gh<_i54.ObterCidadesAtendidasUseCase>(),
      ),
    );
    gh.lazySingleton<_i268.AcervoRepository>(
      () => _i443.AcervoRepositoryImpl(gh<_i744.AcervoDataSource>()),
    );
    gh.lazySingleton<_i550.AutenticacaoRepository>(
      () => _i214.AutenticacaoRepositoryImpl(
        gh<_i887.AutenticacaoDataSource>(),
        gh<_i288.ArmazenamentoToken>(),
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
    gh.factory<_i89.BuscarAcervoUseCase>(
      () => _i89.BuscarAcervoUseCase(gh<_i268.AcervoRepository>()),
    );
    gh.factory<_i587.AcervoCubit>(
      () => _i587.AcervoCubit(gh<_i89.BuscarAcervoUseCase>()),
    );
    gh.factory<_i411.EntrarUseCase>(
      () => _i411.EntrarUseCase(gh<_i550.AutenticacaoRepository>()),
    );
    gh.factory<_i560.LerSessaoUseCase>(
      () => _i560.LerSessaoUseCase(gh<_i550.AutenticacaoRepository>()),
    );
    gh.factory<_i396.ObterPapelUseCase>(
      () => _i396.ObterPapelUseCase(gh<_i550.AutenticacaoRepository>()),
    );
    gh.factory<_i986.SairUseCase>(
      () => _i986.SairUseCase(gh<_i550.AutenticacaoRepository>()),
    );
    gh.lazySingleton<_i231.SessaoCubit>(
      () => _i231.SessaoCubit(
        gh<_i560.LerSessaoUseCase>(),
        gh<_i986.SairUseCase>(),
      ),
    );
    return this;
  }
}

class _$ModuloRede extends _i497.ModuloRede {}
