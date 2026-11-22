/// Onde mora o token da API entre uma abertura do app e outra (AUTH-02).
///
/// Só o token da API é guardado — nunca e-mail nem senha (D-D). A única
/// implementação de produção é a segura, sobre o Keychain/Keystore do
/// aparelho ([ArmazenamentoTokenSeguro]); os testes usam um fake em memória.
abstract class ArmazenamentoToken {
  /// O token guardado, ou `null` se não há sessão (ou se ela não pôde ser lida).
  Future<String?> ler();

  /// Guarda [token], substituindo o anterior.
  Future<void> salvar(String token);

  /// Remove o token guardado; sem token, não faz nada.
  Future<void> apagar();
}
