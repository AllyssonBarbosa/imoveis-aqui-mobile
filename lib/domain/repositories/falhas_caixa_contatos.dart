/// O PATCH do retorno respondeu 404: o contato saiu da caixa ou é de outro
/// corretor/empresa (D-17). Quem está acima decide só pelo tipo — sem
/// `try/catch` genérico na UI.
class ContatoNaoEncontradoException implements Exception {
  const ContatoNaoEncontradoException();

  @override
  String toString() => 'Contato não encontrado na caixa.';
}
