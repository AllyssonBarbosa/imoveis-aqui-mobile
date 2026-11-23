/// Um imóvel que já recebeu contato — a opção do filtro por imóvel da caixa
/// (D-18). Lido do servidor; o app não monta essa lista.
class ImovelComContato {
  const ImovelComContato({
    required this.id,
    required this.codigo,
    required this.titulo,
  });

  final int id;
  final String codigo;
  final String titulo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImovelComContato &&
          other.id == id &&
          other.codigo == codigo &&
          other.titulo == titulo);

  @override
  int get hashCode => Object.hash(id, codigo, titulo);

  @override
  String toString() => 'ImovelComContato(id: $id, codigo: $codigo)';
}
