import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../gateways/seletor_de_fotos_gateway.dart';

/// Abre o seletor de fotos da galeria com várias fotos (D-16). Lista vazia
/// quando o corretor cancela; o app não limita a quantidade (D-06).
@injectable
class EscolherFotosDaGaleriaUseCase {
  EscolherFotosDaGaleriaUseCase(this._seletor);

  final SeletorDeFotosGateway _seletor;

  Future<Result<List<FotoEscolhida>>> call() => _seletor.escolherDaGaleria();
}
