/// Filtro de esquema das URLs de imagem que vêm da API (segurança V12/V13).
///
/// Foto de galeria, capa da lista e foto do corretor são strings não
/// confiáveis: só `http` e `https` com host chegam à tela. Qualquer outra
/// coisa (`javascript:`, `file:`, `data:`, `ftp:`, caminho relativo, vazio)
/// vira `null` — a camada de dados descarta o valor e a UI mostra o
/// placeholder. Nunca lança.
String? urlHttpOuNula(String? valor) {
  final texto = valor?.trim();
  if (texto == null || texto.isEmpty) return null;
  final uri = Uri.tryParse(texto);
  if (uri == null) return null;
  final esquema = uri.scheme.toLowerCase();
  if (esquema != 'http' && esquema != 'https') return null;
  if (uri.host.isEmpty) return null;
  return texto;
}
