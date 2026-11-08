/// Normaliza um texto opcional vindo da API (D-01).
///
/// Os campos opcionais do Django são `blank=True`, então chegam como `""` em
/// vez de ausentes. Aqui o valor é aparado e, se sobrar vazio, vira `null`:
/// o visitante nunca vê uma linha vazia. Nunca lança.
String? textoOuNulo(String? valor) {
  final texto = valor?.trim();
  if (texto == null || texto.isEmpty) return null;
  return texto;
}
