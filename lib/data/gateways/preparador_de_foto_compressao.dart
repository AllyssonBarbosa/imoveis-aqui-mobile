import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/foto_imovel.dart';
import '../../domain/gateways/preparador_de_foto_gateway.dart';

/// [PreparadorDeFotoGateway] sobre o `flutter_image_compress` (D-07, D-17).
///
/// `minWidth`/`minHeight` funcionam como lado MÁXIMO (nome histórico do
/// pacote): a foto cabe num quadrado de [ladoMaximoDaFoto] px mantendo a
/// proporção, sem corte e sem aumentar foto menor. JPEG com
/// [qualidadeJpegDaFoto], desvirada pelo EXIF (`autoCorrectionAngle`) e com
/// `keepExif: false` (a localização GPS não sai do aparelho).
///
/// O JPEG vai para a pasta temporária do app (o cache, que o sistema limpa). O
/// plugin não roda em `flutter test`: esta classe fica coberta pelo UAT, e os
/// testes usam um falso do gateway.
@LazySingleton(as: PreparadorDeFotoGateway)
class PreparadorDeFotoCompressao implements PreparadorDeFotoGateway {
  int _sequencia = 0;

  @override
  Future<Result<FotoEscolhida>> preparar(FotoEscolhida original) async {
    // Nome único por foto: duas fotos preparadas no mesmo milissegundo não
    // podem cair no mesmo arquivo. A extensão .jpg precisa bater com o formato.
    final destino =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        'foto_imovel_${DateTime.now().microsecondsSinceEpoch}_${_sequencia++}.jpg';
    try {
      final resultado = await FlutterImageCompress.compressAndGetFile(
        original.caminho,
        destino,
        minWidth: ladoMaximoDaFoto,
        minHeight: ladoMaximoDaFoto,
        quality: qualidadeJpegDaFoto,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: false,
      );
      if (resultado == null) {
        return Result.failure(const FalhaAoPrepararFotoException());
      }
      return Result.success(FotoEscolhida(caminho: resultado.path));
    } on Exception {
      return Result.failure(const FalhaAoPrepararFotoException());
    } on Error {
      return Result.failure(const FalhaAoPrepararFotoException());
    }
  }

  @override
  Future<void> descartar(FotoEscolhida preparada) async {
    try {
      await File(preparada.caminho).delete();
    } on FileSystemException {
      // Já não existe ou não pôde ser apagado: o sistema limpa o cache do app.
    }
  }
}
