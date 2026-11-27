import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../gateways/seletor_de_fotos_gateway.dart';

/// Abre a câmera do sistema para UMA foto (D-16). `Success(null)` quando o
/// corretor cancela.
@injectable
class TirarFotoUseCase {
  TirarFotoUseCase(this._seletor);

  final SeletorDeFotosGateway _seletor;

  Future<Result<FotoEscolhida?>> call() => _seletor.tirarFoto();
}
