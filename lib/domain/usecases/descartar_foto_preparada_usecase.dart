import 'package:injectable/injectable.dart';

import '../entities/foto_imovel.dart';
import '../gateways/preparador_de_foto_gateway.dart';

/// Apaga o JPEG temporário de uma foto que o corretor tirou da fila sem
/// reenviar ("Remover").
@injectable
class DescartarFotoPreparadaUseCase {
  DescartarFotoPreparadaUseCase(this._preparador);

  final PreparadorDeFotoGateway _preparador;

  Future<void> call(FotoEscolhida preparada) =>
      _preparador.descartar(preparada);
}
