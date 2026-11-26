import '../../core/result.dart';
import '../entities/foto_imovel.dart';

/// Lado maior, em pixels, da foto que sai do aparelho (D-07).
const int ladoMaximoDaFoto = 1920;

/// Qualidade do JPEG que sai do aparelho (D-07).
const int qualidadeJpegDaFoto = 85;

/// Wrapper mockável sobre a compressão no aparelho (`flutter_image_compress`,
/// D-17): reduz a foto para no máximo [ladoMaximoDaFoto] px no lado maior, sem
/// aumentar foto menor, em JPEG [qualidadeJpegDaFoto], desvirada pelo EXIF e
/// SEM EXIF na saída (a localização GPS não sai do aparelho).
///
/// Não é regra de negócio: é só o formato do arquivo enviado. Quem aceita ou
/// recusa a foto (tipo, tamanho, teto) é o servidor.
abstract class PreparadorDeFotoGateway {
  /// Gera o JPEG reduzido de [original] num arquivo temporário novo.
  /// `Result.failure` quando a imagem não pôde ser lida ou gravada — nunca
  /// lança para o chamador.
  Future<Result<FotoEscolhida>> preparar(FotoEscolhida original);

  /// Apaga o arquivo temporário [preparada] (depois do envio aceito ou quando
  /// o corretor tira a foto da fila). Falha ao apagar é ignorada: o sistema
  /// limpa o cache do app.
  Future<void> descartar(FotoEscolhida preparada);
}

/// A foto escolhida não pôde ser lida ou reduzida no aparelho (arquivo
/// corrompido, formato que o sistema não decodifica, sem espaço). A foto entra
/// na fila já com erro e "Tentar de novo" (D-17).
class FalhaAoPrepararFotoException implements Exception {
  const FalhaAoPrepararFotoException();

  @override
  String toString() => 'Não foi possível preparar a foto.';
}
