import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

/// Wrapper sobre `getIt.init()` gerado pelo `injectable` — chamado uma única
/// vez em `main()` (D-14: registra a impl local de [CidadeRepository]; a
/// Fase 2 troca por uma remota sem tocar `domain/`/`presentation/`).
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
