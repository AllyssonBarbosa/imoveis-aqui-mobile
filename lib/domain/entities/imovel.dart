import 'cidade.dart';

/// Finalidade comercial do imóvel — espelha o enum `finalidade` do contrato
/// (`VENDA` | `ALUGUEL` | `VENDA_E_ALUGUEL`, §3.1).
enum FinalidadeImovel { venda, aluguel, vendaEAluguel }

/// Natureza do imóvel — campo PENDENTE E2 do contrato (§3.2); `null` até o
/// backend confirmar o campo real.
enum NaturezaImovel { casa, apartamento, terreno, lote }

/// Entidade de domínio: um imóvel do acervo (VIT-01/VIT-02).
///
/// Imutável, sem serialização — isso é papel de `ImovelModel` em `data/`.
/// Preços chegam prontos como strings decimais do servidor; o domínio nunca
/// os parseia/formata (D-03) — a apresentação fica em
/// `presentation/vitrine/apresentacao_imovel.dart`.
class Imovel {
  const Imovel({
    required this.id,
    required this.titulo,
    required this.finalidade,
    this.precoVenda,
    this.precoAluguel,
    required this.bairro,
    required this.cidade,
    this.fotoCapa,
    this.natureza,
    this.quartos,
  });

  final int id;
  final String titulo;
  final FinalidadeImovel finalidade;

  /// String decimal vinda do servidor, nullable quando a finalidade não
  /// inclui venda. Nunca parseada aqui (D-03).
  final String? precoVenda;

  /// String decimal vinda do servidor, nullable quando a finalidade não
  /// inclui aluguel. Nunca parseada aqui (D-03).
  final String? precoAluguel;

  final String bairro;
  final Cidade cidade;

  /// URL da foto de capa, nullable — placeholder é decisão de `presentation/`
  /// (D-04).
  final String? fotoCapa;

  /// PENDENTE E2 — `null` até o campo existir de fato no backend real.
  final NaturezaImovel? natureza;

  /// PENDENTE E2 — `null` até o campo existir de fato no backend real.
  final int? quartos;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Imovel &&
          other.id == id &&
          other.titulo == titulo &&
          other.finalidade == finalidade &&
          other.precoVenda == precoVenda &&
          other.precoAluguel == precoAluguel &&
          other.bairro == bairro &&
          other.cidade == cidade &&
          other.fotoCapa == fotoCapa &&
          other.natureza == natureza &&
          other.quartos == quartos);

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    finalidade,
    precoVenda,
    precoAluguel,
    bairro,
    cidade,
    fotoCapa,
    natureza,
    quartos,
  );

  @override
  String toString() =>
      'Imovel(id: $id, titulo: $titulo, finalidade: $finalidade, '
      'bairro: $bairro, cidade: $cidade)';
}
