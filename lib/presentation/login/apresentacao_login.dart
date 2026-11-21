import '../../domain/repositories/falhas_autenticacao.dart';

/// Textos fixos e funções puras da tela de login. Toda mensagem mostrada é do
/// app, escolhida só pelo tipo da falha — nunca o texto do servidor e nada que
/// revele se o e-mail existe (D-03, AC-3).

/// Credencial recusada: a mesma frase vale para e-mail inexistente e senha
/// errada (D-03).
const String mensagemCredenciaisInvalidas = 'E-mail ou senha inválidos.';

/// Rede, tempo esgotado, 5xx ou qualquer outra falha inesperada (D-03).
const String mensagemFalhaAoEntrar =
    'Não foi possível entrar agora. Tente de novo.';

/// Aviso no topo do login quando o servidor recusou o token do acervo.
const String avisoSessaoTerminou = 'Sua sessão terminou. Entre de novo.';

/// Texto do limite de tentativas (429, D-04). Os minutos são os segundos do
/// `Retry-After` arredondados para cima, com mínimo de 1; sem o cabeçalho o
/// texto não promete prazo.
String textoLimiteDeTentativas(Duration? aguardar) {
  if (aguardar == null) {
    return 'Muitas tentativas. Tente de novo em alguns minutos.';
  }
  final segundos = aguardar.inSeconds;
  final minutos = segundos <= 0 ? 1 : (segundos + 59) ~/ 60;
  final unidade = minutos == 1 ? 'minuto' : 'minutos';
  return 'Muitas tentativas. Tente de novo em $minutos $unidade.';
}

/// Mensagem do login para uma falha do domínio, decidida só pelo tipo.
String mensagemDeFalhaDoLogin(Exception erro) => switch (erro) {
  CredenciaisInvalidasException() => mensagemCredenciaisInvalidas,
  LimiteTentativasException(:final aguardar) => textoLimiteDeTentativas(
    aguardar,
  ),
  _ => mensagemFalhaAoEntrar,
};
