import '../models/foto_imovel_model.dart';

/// Avisado durante o upload com os bytes já enviados e o total (`-1` quando o
/// total não é conhecido), como o `onSendProgress` do Dio.
typedef AoEnviarBytes = void Function(int enviados, int total);

/// Fonte das fotos do imóvel (APP 11, §19). Interface trocável: a implementação
/// real fala com o Django pelo `Dio` autenticado; os testes usam a `ApiFalsa`.
abstract class FotosImovelDataSource {
  /// `GET /api/imoveis/{imovelId}/fotos/`.
  Future<List<FotoImovelModel>> listar(int imovelId);

  /// `POST /api/imoveis/{imovelId}/fotos/` com UM arquivo ([caminho]) no campo
  /// `imagem`. Cada chamada monta um corpo novo (um `FormData` não pode ser
  /// reenviado), então o "Tentar de novo" chama de novo com o mesmo caminho.
  Future<FotoImovelModel> enviar(
    int imovelId,
    String caminho, {
    AoEnviarBytes? aoEnviar,
  });

  /// `PUT /api/imoveis/{imovelId}/fotos/ordem/` com `{"ids": [...]}`.
  Future<List<FotoImovelModel>> reordenar(int imovelId, List<int> ids);

  /// `POST /api/imoveis/{imovelId}/fotos/{fotoId}/capa/`.
  Future<List<FotoImovelModel>> definirCapa(int imovelId, int fotoId);

  /// `DELETE /api/imoveis/{imovelId}/fotos/{fotoId}/`.
  Future<List<FotoImovelModel>> apagar(int imovelId, int fotoId);
}
