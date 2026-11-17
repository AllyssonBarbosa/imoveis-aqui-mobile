import '../../domain/entities/canal_contato.dart';
import '../models/contato_registrado_model.dart';

/// Caminho do endpoint público de contato (o `id` é sempre um inteiro, nunca
/// texto do usuário).
String caminhoContatoImovelPublico(int id) =>
    '/api/publico/imoveis/$id/contato/';

/// Fronteira do registro de contato (W11). A única implementação é a remota
/// (`ContatoRemoteDataSource`, `dio` sobre a API pública); `domain/` e
/// `presentation/` só conhecem a interface do repositório.
abstract class ContatoDataSource {
  /// Registra no servidor o contato pelo [canal] com o imóvel [imovelId] e
  /// devolve o link para abrir. A própria chamada registra o contato (C4).
  /// Lança `DioException` em resposta não 2xx (400 canal indisponível, 404
  /// imóvel inexistente, 429 limite excedido).
  Future<ContatoRegistradoModel> registrar(int imovelId, CanalContato canal);
}
