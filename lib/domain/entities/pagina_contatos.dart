import 'contato_recebido.dart';

/// Uma página da caixa de contatos (envelope cursor já mapeado) — guarda só o
/// que chega, na ordem do servidor (D-08). `proximaPagina` é o cursor opaco
/// (`next` do envelope), nunca interpretado fora da camada `data/`. A lista de
/// itens é imutável.
class PaginaContatos {
  PaginaContatos({required List<ContatoRecebido> itens, this.proximaPagina})
    : itens = List.unmodifiable(itens);

  final List<ContatoRecebido> itens;
  final String? proximaPagina;

  /// `true` quando não há próxima página (`proximaPagina == null`).
  bool get ehUltima => proximaPagina == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginaContatos) return false;
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
      'PaginaContatos(itens: ${itens.length}, proximaPagina: $proximaPagina)';
}
