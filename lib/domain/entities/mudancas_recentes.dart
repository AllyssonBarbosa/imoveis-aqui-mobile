import 'situacao_imovel.dart';

/// Uma mudança de situação recente de um imóvel da empresa (GES-04, D-20,
/// D-21). Imutável e `const`-construível, sem serialização.
///
/// As situações não são anuláveis: um código desconhecido é falha de formato
/// na camada de dados (D-24), nunca chega aqui.
class MudancaRecente {
  const MudancaRecente({
    required this.id,
    required this.imovelId,
    required this.imovelCodigo,
    required this.imovelTitulo,
    required this.situacaoAnterior,
    required this.situacaoNova,
    required this.alteradoPor,
    required this.alteradoEm,
    required this.observacao,
  });

  final int id;
  final int imovelId;
  final String imovelCodigo;
  final String imovelTitulo;
  final SituacaoImovel situacaoAnterior;
  final SituacaoImovel situacaoNova;

  /// Nome de quem mudou, como o servidor mandou.
  final String alteradoPor;

  /// Instante da mudança, em UTC, como o servidor registrou.
  final DateTime alteradoEm;

  /// Texto como veio; vazio (`''`) quando não há observação.
  final String observacao;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MudancaRecente &&
          other.id == id &&
          other.imovelId == imovelId &&
          other.imovelCodigo == imovelCodigo &&
          other.imovelTitulo == imovelTitulo &&
          other.situacaoAnterior == situacaoAnterior &&
          other.situacaoNova == situacaoNova &&
          other.alteradoPor == alteradoPor &&
          other.alteradoEm == alteradoEm &&
          other.observacao == observacao);

  @override
  int get hashCode => Object.hash(
    id,
    imovelId,
    imovelCodigo,
    imovelTitulo,
    situacaoAnterior,
    situacaoNova,
    alteradoPor,
    alteradoEm,
    observacao,
  );

  // Sem nome nem observação no texto: podem trazer dado de cliente (T-12-11).
  @override
  String toString() =>
      'MudancaRecente(id: $id, imovel: $imovelCodigo, '
      '$situacaoAnterior -> $situacaoNova)';
}

/// Mudanças recentes da empresa (GES-04): [dias] é a janela que o SERVIDOR
/// usou (D-19, o app não a escolhe) e [mudancas] vem na ordem do servidor. A
/// lista é copiada com `List.unmodifiable`, então este objeto não é `const`.
class MudancasRecentes {
  MudancasRecentes({required this.dias, required List<MudancaRecente> mudancas})
    : mudancas = List.unmodifiable(mudancas);

  /// Janela, em dias, que o servidor aplicou.
  final int dias;

  final List<MudancaRecente> mudancas;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MudancasRecentes) return false;
    if (other.dias != dias) return false;
    if (other.mudancas.length != mudancas.length) return false;
    for (var indice = 0; indice < mudancas.length; indice++) {
      if (other.mudancas[indice] != mudancas[indice]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(dias, Object.hashAll(mudancas));

  @override
  String toString() =>
      'MudancasRecentes(dias: $dias, mudancas: ${mudancas.length})';
}
