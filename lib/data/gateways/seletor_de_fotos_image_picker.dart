import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/foto_imovel.dart';
import '../../domain/gateways/seletor_de_fotos_gateway.dart';

/// [SeletorDeFotosGateway] sobre o `image_picker` (D-16): câmera do sistema
/// para uma foto e o seletor de fotos do sistema para várias.
///
/// `requestFullMetadata: false`: o app não precisa dos metadados da galeria (e
/// no iOS isso evita pedir acesso à biblioteca inteira só para escolher). A
/// redução e a retirada do EXIF ficam no preparador.
///
/// Toda falha da plataforma (acesso negado, sem câmera, `MissingPluginException`
/// em `flutter test`) vira [FalhaAoEscolherFotoException]: o chamador só
/// precisa saber que não abriu. Nenhum caminho de arquivo é registrado em log.
@LazySingleton(as: SeletorDeFotosGateway)
class SeletorDeFotosImagePicker implements SeletorDeFotosGateway {
  SeletorDeFotosImagePicker() : _picker = ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Result<FotoEscolhida?>> tirarFoto() => _proteger(() async {
    final arquivo = await _picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    return arquivo == null ? null : FotoEscolhida(caminho: arquivo.path);
  });

  @override
  Future<Result<List<FotoEscolhida>>> escolherDaGaleria() => _proteger(
    () async {
      final arquivos = await _picker.pickMultiImage(requestFullMetadata: false);
      return List.unmodifiable([
        for (final arquivo in arquivos) FotoEscolhida(caminho: arquivo.path),
      ]);
    },
  );

  Future<Result<T>> _proteger<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on Exception {
      return Result.failure(const FalhaAoEscolherFotoException());
    } on Error {
      return Result.failure(const FalhaAoEscolherFotoException());
    }
  }
}
