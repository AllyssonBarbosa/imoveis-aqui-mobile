import '../../core/result.dart';
import '../entities/foto_imovel.dart';

/// Falha de uma escrita de fotos quando o servidor recusa o pedido (400 ou
/// 403): arquivo que não é imagem, acima de 5 MB, teto de 30 fotos, lista de
/// ordem inválida. Carrega a mensagem do próprio servidor, já em português,
/// só para exibir: nunca é usada para decidir nada (D-18). Molde:
/// `MudancaSituacaoRecusadaException`.
class FotoRecusadaException implements Exception {
  const FotoRecusadaException(this.mensagem);

  /// Texto do servidor, achatado e limitado (`mensagemDeRecusa`).
  final String mensagem;

  /// Sem a [mensagem], para o texto do servidor não ir parar em log por engano.
  @override
  String toString() => 'Pedido de foto recusado pelo servidor.';
}

/// Avisado durante o envio com a fração já enviada (0..1), ou `null` quando o
/// tamanho total não é conhecido (barra indeterminada).
typedef AoProgredirEnvio = void Function(double? fracao);

/// Fotos de um imóvel do acervo (APP 11, §19 do contrato). O app pede e o
/// servidor decide: nenhuma operação muda a ordem ou a capa no aparelho, e as
/// escritas de ordem, capa e exclusão devolvem a lista relida do servidor.
///
/// Falhas tipadas de todas as operações: `SessaoExpiradaException` (401),
/// `ImovelNaoEncontradoException` (404: imóvel inexistente, de outra empresa
/// ou foto de outro imóvel), [FotoRecusadaException] (400/403 com texto do
/// servidor) e `FalhaDeConexaoException` (rede, tempo esgotado, 5xx, corpo
/// malformado, recusa sem texto). Nenhuma nova tentativa automática.
abstract class FotosImovelRepository {
  /// Fotos do imóvel [imovelId], na ordem do servidor (`ordem, id`).
  Future<Result<List<FotoImovel>>> listar(int imovelId);

  /// Envia UMA foto já preparada ([foto], JPEG reduzido) para o imóvel
  /// [imovelId] (`POST .../fotos/`, multipart). [aoProgredir] recebe o
  /// progresso do envio. Devolve a foto criada pelo servidor (ordem e capa
  /// decididas lá). Um envio que esgotou o tempo pode ter gravado: quem chama
  /// relê a lista.
  Future<Result<FotoImovel>> enviar(
    int imovelId,
    FotoEscolhida foto, {
    AoProgredirEnvio? aoProgredir,
  });

  /// Pede a ordem nova: [ids] com todas as fotos do imóvel, na sequência
  /// desejada (`PUT .../fotos/ordem/`). Devolve a lista relida.
  Future<Result<List<FotoImovel>>> reordenar(int imovelId, List<int> ids);

  /// Pede que [fotoId] vire a capa (`POST .../fotos/{fotoId}/capa/`). Devolve
  /// a lista relida.
  Future<Result<List<FotoImovel>>> definirCapa(int imovelId, int fotoId);

  /// Apaga [fotoId] (`DELETE .../fotos/{fotoId}/`). O servidor renumera e, se
  /// era a capa, promove outra. Devolve a lista relida.
  Future<Result<List<FotoImovel>>> apagar(int imovelId, int fotoId);
}
