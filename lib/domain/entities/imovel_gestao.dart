import 'imovel.dart';
import 'situacao_imovel.dart';

/// Entidade de domínio: o imóvel como a tela de gestão da situação o lê
/// (`GET /api/imoveis/{id}/`, SIT-07).
///
/// Imutável, sem serialização — isso é papel de `ImovelGestaoModel` em
/// `data/`. Tudo o que "vale" algo chega decidido pelo servidor: [situacao] e
/// [situacaoDesde] (D-05) e [podeMudarSituacao] (D-04) são só lidos, nunca
/// calculados no aparelho. Preços são strings decimais do servidor e nunca
/// são parseados aqui. [situacao] é anulável porque um valor desconhecido do
/// servidor vira `null` (sem chip), nunca quebra a tela.
class ImovelGestao {
  const ImovelGestao({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.finalidade,
    this.precoVenda,
    this.precoAluguel,
    this.situacao,
    required this.situacaoDesde,
    required this.podeMudarSituacao,
  });

  final int id;
  final String codigo;
  final String titulo;
  final FinalidadeImovel finalidade;

  /// String decimal do servidor; nula quando a finalidade não inclui venda.
  final String? precoVenda;

  /// String decimal do servidor; nula quando a finalidade não inclui aluguel.
  final String? precoAluguel;

  /// `null` quando o servidor mandou uma situação que o app não conhece.
  final SituacaoImovel? situacao;

  /// Instante (UTC) em que o imóvel entrou na situação atual — do servidor.
  final DateTime situacaoDesde;

  /// Se o usuário logado pode mudar a situação deste imóvel — decidido pelo
  /// Django (D-04); o app só esconde ou mostra a ação.
  final bool podeMudarSituacao;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImovelGestao &&
          other.id == id &&
          other.codigo == codigo &&
          other.titulo == titulo &&
          other.finalidade == finalidade &&
          other.precoVenda == precoVenda &&
          other.precoAluguel == precoAluguel &&
          other.situacao == situacao &&
          other.situacaoDesde == situacaoDesde &&
          other.podeMudarSituacao == podeMudarSituacao);

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    titulo,
    finalidade,
    precoVenda,
    precoAluguel,
    situacao,
    situacaoDesde,
    podeMudarSituacao,
  );

  @override
  String toString() =>
      'ImovelGestao(id: $id, codigo: $codigo, situacao: $situacao, '
      'podeMudarSituacao: $podeMudarSituacao)';
}
