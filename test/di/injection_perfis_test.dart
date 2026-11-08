import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_mock_datasource.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_corretor_usecase.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';

/// Canário do DI dos perfis públicos: prova que o app de verdade resolve o
/// Cubit e o use case do corretor e que a DataSource ativa é o servidor
/// simulado (D-03). Estendido pelos planos seguintes da Fase 7.
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  test('resolve PerfilCorretorCubit pelo DI de produção', () async {
    await configureDependencies();

    expect(getIt<PerfilCorretorCubit>(), isA<PerfilCorretorCubit>());
  });

  test('resolve ObterPerfilCorretorUseCase pelo DI de produção', () async {
    await configureDependencies();

    expect(
      getIt<ObterPerfilCorretorUseCase>(),
      isA<ObterPerfilCorretorUseCase>(),
    );
  });

  test('a PerfilDataSource ativa é a PerfilMockDataSource', () async {
    await configureDependencies();

    expect(getIt<PerfilDataSource>(), isA<PerfilMockDataSource>());
  });
}
