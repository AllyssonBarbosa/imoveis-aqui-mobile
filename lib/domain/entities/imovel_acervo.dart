import 'imovel.dart';
import 'situacao_imovel.dart';

/// Entidade de domínio: um imóvel da lista do acervo do corretor (ACV-01).
///
/// Imutável, sem serialização — isso é papel de `ImovelAcervoModel` em
/// `data/`. [meuImovel] e [naVitrine] são calculados NO SERVIDOR (D-06, D-07):
/// o app só os lê e nunca os deduz (não compara ids, não olha publicado nem
/// situação). Preços chegam prontos como strings decimais do servidor e nunca
/// são parseados aqui. [situacao] é anulável porque um valor desconhecido do
/// servidor vira `null` (sem chip), nunca quebra a lista.
class ImovelAcervo {
  const ImovelAcervo({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.finalidade,
    this.precoVenda,
    this.precoAluguel,
    this.fotoCapa,
    this.situacao,
    required this.meuImovel,
    required this.naVitrine,
  });

  final int id;
  final String codigo;
  final String titulo;
  final FinalidadeImovel finalidade;

  /// String decimal do servidor; nula quando a finalidade não inclui venda.
  final String? precoVenda;

  /// String decimal do servidor; nula quando a finalidade não inclui aluguel.
  final String? precoAluguel;

  /// URL http(s) da capa, ou `null` (placeholder é da apresentação).
  final String? fotoCapa;

  /// `null` quando o servidor mandou uma situação que o app não conhece.
  final SituacaoImovel? situacao;

  /// Marca "Seu" — decidida pelo servidor (D-06).
  final bool meuImovel;

  /// Marca "está na vitrine" — decidida pelo servidor (D-07).
  final bool naVitrine;

  /// Prévia para abrir a página pública do imóvel (`abrirDetalheImovel`). A
  /// lista do acervo não manda bairro, natureza nem quartos; a página pública
  /// completa os dados pelo detalhe.
  Imovel paraPrevia() {
    return Imovel(
      id: id,
      titulo: titulo,
      finalidade: finalidade,
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      bairro: '',
      fotoCapa: fotoCapa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImovelAcervo &&
          other.id == id &&
          other.codigo == codigo &&
          other.titulo == titulo &&
          other.finalidade == finalidade &&
          other.precoVenda == precoVenda &&
          other.precoAluguel == precoAluguel &&
          other.fotoCapa == fotoCapa &&
          other.situacao == situacao &&
          other.meuImovel == meuImovel &&
          other.naVitrine == naVitrine);

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    titulo,
    finalidade,
    precoVenda,
    precoAluguel,
    fotoCapa,
    situacao,
    meuImovel,
    naVitrine,
  );

  @override
  String toString() =>
      'ImovelAcervo(id: $id, codigo: $codigo, situacao: $situacao, '
      'meuImovel: $meuImovel, naVitrine: $naVitrine)';
}
