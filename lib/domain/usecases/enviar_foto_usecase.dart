import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../gateways/preparador_de_foto_gateway.dart';
import '../repositories/fotos_imovel_repository.dart';

/// Envia UMA foto já preparada (D-18) e, se o servidor a aceitou, apaga o JPEG
/// temporário do aparelho. Em falha o arquivo fica, para o "Tentar de novo"
/// reenviar o mesmo arquivo sem preparar de novo.
@injectable
class EnviarFotoUseCase {
  EnviarFotoUseCase(this._repositorio, this._preparador);

  final FotosImovelRepository _repositorio;
  final PreparadorDeFotoGateway _preparador;

  Future<Result<FotoImovel>> call(
    int imovelId,
    FotoEscolhida preparada, {
    AoProgredirEnvio? aoProgredir,
  }) async {
    final resultado = await _repositorio.enviar(
      imovelId,
      preparada,
      aoProgredir: aoProgredir,
    );
    if (resultado is Success<FotoImovel>) {
      await _preparador.descartar(preparada);
    }
    return resultado;
  }
}
