import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// Wrapper sobre `getIt.init()` gerado pelo `injectable` — chamado uma única
/// vez em `main()` (registra [CidadeRepository] apoiada em
/// `CidadeRemoteDataSource`, VIT-06/D-16, e o módulo de `Dio` de
/// `modulo_rede.dart`, D-17).
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
