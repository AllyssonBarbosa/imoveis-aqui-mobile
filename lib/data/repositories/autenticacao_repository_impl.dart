import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/papel.dart';
import '../../domain/repositories/autenticacao_repository.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../datasources/armazenamento_token.dart';
import '../datasources/autenticacao_datasource.dart';

/// Maior espera aceita do `Retry-After`: um valor hostil (enorme) não vira uma
/// [Duration] estourada nem um texto de dias na tela (T-08-29).
const Duration _esperaMaxima = Duration(days: 1);

/// Maior espera do pedido de Sair ao servidor (inclui conectar, enviar e
/// receber). O `connectTimeout` do `Dio` autenticado é de 10 s e não pode ser
/// reduzido por pedido, então o limite é imposto aqui, na [Future] inteira.
const Duration esperaMaximaSair = Duration(seconds: 5);

/// Lê o `Retry-After` (em segundos) de uma resposta 429. Nulo se o cabeçalho
/// falta, não é um inteiro ou é negativo; limitado a 24 h.
Duration? esperaDoLimite(DioException erro) {
  final valores = erro.response?.headers['retry-after'];
  if (valores == null || valores.isEmpty) return null;
  final segundos = int.tryParse(valores.first.trim());
  if (segundos == null || segundos < 0) return null;
  if (segundos > _esperaMaxima.inSeconds) return _esperaMaxima;
  return Duration(seconds: segundos);
}

/// Impl de [AutenticacaoRepository]: traduz o status da API em falhas tipadas
/// (D-03, D-04) e é o único lugar por onde o token entra e sai do aparelho.
///
/// Nenhuma falha carrega o corpo da resposta (AC-3, T-08-24) e e-mail e senha
/// nunca vão ao armazenamento: só o token da resposta é guardado (T-08-25).
@LazySingleton(as: AutenticacaoRepository)
class AutenticacaoRepositoryImpl implements AutenticacaoRepository {
  AutenticacaoRepositoryImpl(this._dataSource, this._armazenamento);

  final AutenticacaoDataSource _dataSource;
  final ArmazenamentoToken _armazenamento;

  @override
  Future<Result<void>> entrar({required String email, required String senha}) =>
      _executar<void>(() async {
        final token = await _dataSource.entrar(email: email, senha: senha);
        await _armazenamento.salvar(token);
      });

  @override
  Future<Result<Papel>> obterPapel() =>
      _executar(() async => (await _dataSource.obterEu()).paraPapel());

  @override
  Future<void> sair() async {
    try {
      await _dataSource.sair().timeout(esperaMaximaSair);
    } on Exception {
      // Melhor esforço: o servidor pode estar fora do ar, lento além de
      // [esperaMaximaSair] (`TimeoutException` também é `Exception`) ou já ter
      // revogado o token (401). A saída local acontece de qualquer jeito, no
      // `finally`.
    } finally {
      await _apagarTokenLocal();
    }
  }

  @override
  Future<bool> temSessaoGuardada() async {
    final token = await _armazenamento.ler();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> descartarSessaoLocal() => _apagarTokenLocal();

  /// Apaga o token do aparelho sem nunca lançar.
  Future<void> _apagarTokenLocal() async {
    try {
      await _armazenamento.apagar();
    } on Exception {
      // O `apagar()` seguro pode lançar `PlatformException` (Keychain/Keystore).
      // A remoção foi tentada e o estado em memória termina anônimo no
      // `SessaoCubit`; isto é a camada de dados, não UI, e não loga nada.
    }
  }

  /// Cadeia única de tradução de erros. A ordem importa: a exceção de sessão
  /// vem antes, depois o `DioException` por status, o [TypeError] (que é um
  /// `Error`, não uma `Exception`) e por fim as demais `Exception`.
  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      return Result.failure(switch (erro.response?.statusCode) {
        400 => const CredenciaisInvalidasException(),
        429 => LimiteTentativasException(aguardar: esperaDoLimite(erro)),
        403 => const SemPermissaoException(),
        _ => const FalhaDeConexaoException(),
      });
    } on TypeError catch (erro) {
      return Result.failure(FormatException('resposta malformada: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
