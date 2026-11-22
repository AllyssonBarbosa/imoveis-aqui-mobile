import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';

/// Fake em memória de [ArmazenamentoToken] para os testes: nenhum teste toca
/// o canal de plataforma do armazenamento seguro. O [token] é legível pelos
/// testes para conferir o que ficou guardado.
class ArmazenamentoTokenEmMemoria implements ArmazenamentoToken {
  ArmazenamentoTokenEmMemoria([this.token]);

  String? token;

  @override
  Future<String?> ler() async => token;

  @override
  Future<void> salvar(String token) async {
    this.token = token;
  }

  @override
  Future<void> apagar() async {
    token = null;
  }
}
