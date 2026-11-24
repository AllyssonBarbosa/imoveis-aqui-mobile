import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/retorno_contato.dart';
import '../models/contato_recebido_model.dart';
import '../models/contatos_envelope_model.dart';
import '../models/imovel_com_contato_model.dart';
import '../models/resumo_contatos_model.dart';

/// Fonte da caixa de contatos do corretor (`/api/contatos/...`). Interface
/// trocável: a implementação remota usa o `Dio` autenticado, e quem está acima
/// só enxerga Models tipados. Filtro, ordem e contagem são do servidor.
abstract class CaixaContatosDataSource {
  /// Primeira página da caixa para [consulta] (imóvel e período vão ao
  /// servidor, nunca são aplicados no aparelho).
  Future<ContatosEnvelopeModel> buscar(ConsultaContatos consulta);

  /// Página seguinte: [proximaPagina] é o `next` absoluto da resposta
  /// anterior, seguido tal e qual e só se for da mesma origem da API.
  Future<ContatosEnvelopeModel> seguir(String proximaPagina);

  /// Quantos contatos estão sem retorno (`GET /api/contatos/resumo/`).
  Future<ResumoContatosModel> contarSemRetorno();

  /// Opções do filtro por imóvel (`GET /api/contatos/imoveis/`), na ordem do
  /// servidor.
  Future<List<ImovelComContatoModel>> listarImoveis();

  /// Anota [retorno] no contato [id] (`PATCH /api/contatos/<id>/`) e devolve o
  /// contato como o servidor o gravou.
  Future<ContatoRecebidoModel> anotarRetorno(int id, RetornoContato retorno);
}
