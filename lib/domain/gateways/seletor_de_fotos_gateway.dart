import '../../core/result.dart';
import '../entities/foto_imovel.dart';

/// Wrapper mockável sobre o `image_picker` (APP 11, D-16): abre a câmera do
/// sistema ou o seletor de fotos da galeria. Os testes trocam por um falso; o
/// plugin real só roda no aparelho.
abstract class SeletorDeFotosGateway {
  /// Abre a câmera para UMA foto. `Result.success(null)` quando o corretor
  /// cancela; `Result.failure` quando a plataforma recusa (ex.: acesso à
  /// câmera negado no iOS) — nunca lança para o chamador.
  Future<Result<FotoEscolhida?>> tirarFoto();

  /// Abre o seletor da galeria com várias fotos. Lista vazia quando o corretor
  /// cancela. O app não limita a quantidade (o teto é do servidor, D-06).
  Future<Result<List<FotoEscolhida>>> escolherDaGaleria();
}
