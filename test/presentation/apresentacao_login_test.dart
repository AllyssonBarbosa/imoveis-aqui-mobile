import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/presentation/login/apresentacao_login.dart';

void main() {
  group('mensagemDeFalhaDoLogin', () {
    test('credencial inválida usa o texto fixo', () {
      expect(
        mensagemDeFalhaDoLogin(const CredenciaisInvalidasException()),
        'E-mail ou senha inválidos.',
      );
    });

    test('rede, formato, sessão, permissão e qualquer outra falha', () {
      const esperado = 'Não foi possível entrar agora. Tente de novo.';
      expect(mensagemDeFalhaDoLogin(const FalhaDeConexaoException()), esperado);
      expect(mensagemDeFalhaDoLogin(const FormatException('x')), esperado);
      expect(mensagemDeFalhaDoLogin(const SessaoExpiradaException()), esperado);
      expect(mensagemDeFalhaDoLogin(const SemPermissaoException()), esperado);
      expect(mensagemDeFalhaDoLogin(Exception('texto do servidor')), esperado);
    });

    test('nunca repete o texto da exceção', () {
      expect(
        mensagemDeFalhaDoLogin(Exception('usuario@x.com nao existe')),
        isNot(contains('usuario@x.com')),
      );
    });

    test('limite de tentativas usa os minutos do Retry-After', () {
      expect(
        mensagemDeFalhaDoLogin(
          const LimiteTentativasException(aguardar: Duration(seconds: 120)),
        ),
        'Muitas tentativas. Tente de novo em 2 minutos.',
      );
    });
  });

  group('textoLimiteDeTentativas', () {
    test('sem Retry-After', () {
      expect(
        textoLimiteDeTentativas(null),
        'Muitas tentativas. Tente de novo em alguns minutos.',
      );
    });

    test('arredonda para cima, mínimo 1 e singular', () {
      const um = 'Muitas tentativas. Tente de novo em 1 minuto.';
      expect(textoLimiteDeTentativas(const Duration(seconds: 1)), um);
      expect(textoLimiteDeTentativas(const Duration(seconds: 60)), um);
      expect(textoLimiteDeTentativas(Duration.zero), um);
      expect(
        textoLimiteDeTentativas(const Duration(seconds: 61)),
        'Muitas tentativas. Tente de novo em 2 minutos.',
      );
      expect(
        textoLimiteDeTentativas(const Duration(seconds: 3600)),
        'Muitas tentativas. Tente de novo em 60 minutos.',
      );
    });
  });
}
