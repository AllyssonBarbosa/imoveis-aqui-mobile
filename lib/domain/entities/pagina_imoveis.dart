import 'imovel.dart';

/// Uma página do acervo de imóveis (envelope cursor já mapeado, F1/D-01) —
/// `proximaPagina` é o cursor opaco (`next` do envelope), nunca interpretado
/// fora da camada `data/` (D-13).
class PaginaImoveis {
  const PaginaImoveis({required this.itens, this.proximaPagina});

  final List<Imovel> itens;
  final String? proximaPagina;

  /// `true` quando não há próxima página (`proximaPagina == null`) — sem
  /// campo próprio, deriva direto do cursor (D-13).
  bool get ehUltima => proximaPagina == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginaImoveis) return false;
    if (other.proximaPagina != proximaPagina) return false;
    if (other.itens.length != itens.length) return false;
    for (var indice = 0; indice < itens.length; indice++) {
      if (other.itens[indice] != itens[indice]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(itens), proximaPagina);

  @override
  String toString() =>
      'PaginaImoveis(itens: ${itens.length}, proximaPagina: $proximaPagina)';
}
