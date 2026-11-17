import '../../core/result.dart';
import '../entities/canal_contato.dart';

/// O servidor recusou o canal para este imóvel (400): ele não está em
/// `canais_contato`. Nunca carrega o link nem a resposta do servidor.
class CanalIndisponivelException implements Exception {
  const CanalIndisponivelException();

  @override
  String toString() => 'Canal de contato indisponível para este imóvel.';
}

/// O servidor limitou os contatos do visitante (429). O app só avisa para
/// tentar mais tarde.
class ContatoLimiteExcedidoException implements Exception {
  const ContatoLimiteExcedidoException();

  @override
  String toString() => 'Limite de contatos excedido. Tente mais tarde.';
}

/// O link devolvido pelo servidor está fora da lista permitida do canal
/// (esquema ou host inesperado, canal diferente do pedido, link ilegível).
/// A mensagem nunca inclui o link recebido (ele leva o código interno do
/// imóvel e a mensagem do visitante).
class LinkContatoInvalidoException implements Exception {
  const LinkContatoInvalidoException();

  @override
  String toString() => 'O link de contato recebido não é válido.';
}

/// Fronteira de domínio do contato com o responsável pelo imóvel (C4).
abstract class ContatoRepository {
  /// Registra o contato pelo [canal] com o imóvel [imovelId] e devolve o link
  /// já validado para o canal.
  ///
  /// Sucesso significa que o contato JÁ está registrado no servidor: o app
  /// nunca o desfaz, mesmo que abrir o link falhe depois (D-15). Falhas:
  /// [CanalIndisponivelException] (400), `ImovelNaoEncontradoException` (404,
  /// reaproveitada de `imovel_detalhe_repository.dart`),
  /// [ContatoLimiteExcedidoException] (429), [LinkContatoInvalidoException],
  /// `FormatException` (JSON malformado) ou a `DioException` (rede, timeout,
  /// 5xx).
  Future<Result<Uri>> registrarContato(int imovelId, CanalContato canal);
}
