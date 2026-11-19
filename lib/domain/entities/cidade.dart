import '../../core/texto_normalizado.dart';

/// Entidade de domínio: uma cidade atendida pelo marketplace.
///
/// Imutável, sem serialização (isso é papel de `CidadeModel` em `data/`).
class Cidade {
  const Cidade({this.id, required this.nome, required this.uf});

  /// Id da API, só para montar rotas (`/api/publico/cidades/<id>/...`) — a
  /// identidade continua nome+uf ([chaveNatural]); por isso fica fora de
  /// `==`/`hashCode`. Nulo quando a cidade vem de um valor salvo no formato
  /// antigo `nome|uf` (A-01).
  final int? id;
  final String nome;
  final String uf;

  /// Chave natural normalizada (minúsculas, sem espaços nas pontas, sem
  /// acentos) — usada para casar a cidade detectada por geocodificação com a
  /// lista de cidades atendidas (D-09) e como base da chave persistida
  /// (D-15), estável através da transição fixture → API real (a API não
  /// garante manter os mesmos `id`s da fixture). Normalização compartilhada
  /// com a busca da vitrine (`core/texto_normalizado.dart`, plan 02-05).
  String get chaveNatural => '${normalizarTexto(nome)}-${normalizarTexto(uf)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cidade && other.nome == nome && other.uf == uf);

  @override
  int get hashCode => Object.hash(nome, uf);

  @override
  String toString() => 'Cidade(id: $id, nome: $nome, uf: $uf)';
}
