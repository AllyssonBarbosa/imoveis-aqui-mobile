import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../gateways/preparador_de_foto_gateway.dart';

/// Reduz a foto escolhida para o JPEG que vai ao servidor (1920 px, qualidade
/// 85, sem EXIF — D-07, D-17). Só formato do arquivo: quem aceita ou recusa a
/// foto é o servidor.
@injectable
class PrepararFotoUseCase {
  PrepararFotoUseCase(this._preparador);

  final PreparadorDeFotoGateway _preparador;

  Future<Result<FotoEscolhida>> call(FotoEscolhida original) =>
      _preparador.preparar(original);
}
