import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/foto_imovel.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/fotos_imovel_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/fotos_imovel_datasource.dart';
import '../models/foto_imovel_model.dart';
import '../network/mensagem_de_recusa.dart';

/// Impl de [FotosImovelRepository] sobre a interface trocável
/// [FotosImovelDataSource]. Traduz as falhas em tipos de domínio: o Cubit
/// decide só pelo tipo, e o único texto do servidor que sobe é a mensagem de
/// recusa de um 400/403, para exibir (D-18).
@LazySingleton(as: FotosImovelRepository)
class FotosImovelRepositoryImpl implements FotosImovelRepository {
  FotosImovelRepositoryImpl(this._dataSource);

  final FotosImovelDataSource _dataSource;

  @override
  Future<Result<List<FotoImovel>>> listar(int imovelId) =>
      _executar(() async => _entidades(await _dataSource.listar(imovelId)));

  @override
  Future<Result<FotoImovel>> enviar(
    int imovelId,
    FotoEscolhida foto, {
    AoProgredirEnvio? aoProgredir,
  }) => _executar(
    // Sem nova tentativa automática: um POST com tempo esgotado pode ter
    // gravado, e quem decide reenviar é o corretor ("Tentar de novo").
    () async => (await _dataSource.enviar(
      imovelId,
      foto.caminho,
      aoEnviar: aoProgredir == null
          ? null
          : (enviados, total) => aoProgredir(fracaoEnviada(enviados, total)),
    )).paraEntidade(),
  );

  @override
  Future<Result<List<FotoImovel>>> reordenar(int imovelId, List<int> ids) =>
      _executar(
        () async => _entidades(await _dataSource.reordenar(imovelId, ids)),
      );

  @override
  Future<Result<List<FotoImovel>>> definirCapa(int imovelId, int fotoId) =>
      _executar(
        () async => _entidades(await _dataSource.definirCapa(imovelId, fotoId)),
      );

  @override
  Future<Result<List<FotoImovel>>> apagar(int imovelId, int fotoId) =>
      _executar(
        () async => _entidades(await _dataSource.apagar(imovelId, fotoId)),
      );

  /// Imutável e na ordem recebida: o Cubit não consegue reordenar nem editar
  /// o que veio do servidor (D-20).
  List<FotoImovel> _entidades(List<FotoImovelModel> modelos) =>
      List.unmodifiable([for (final modelo in modelos) modelo.paraEntidade()]);

  /// Cadeia única de tradução de erros (molde: `GestaoImovelRepositoryImpl`).
  /// A sessão expirada (direta ou dentro do `DioException.error`, posta pelo
  /// interceptor) vem antes do status; 400 e 403 com texto viram
  /// [FotoRecusadaException]; 404 vira [ImovelNaoEncontradoException] (o
  /// `detail` em inglês do Django nunca sobe); o resto — rede, tempo esgotado,
  /// 5xx, corpo malformado (`FormatException`/`TypeError`), arquivo local que
  /// sumiu — vira [FalhaDeConexaoException].
  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      final status = erro.response?.statusCode;
      if (status == 400 || status == 403) {
        final texto = mensagemDeRecusa(erro.response?.data);
        return Result.failure(
          texto == null
              ? const FalhaDeConexaoException()
              : FotoRecusadaException(texto),
        );
      }
      if (status == 404) {
        return Result.failure(const ImovelNaoEncontradoException());
      }
      return Result.failure(const FalhaDeConexaoException());
    } on TypeError {
      return Result.failure(const FalhaDeConexaoException());
    } on Exception {
      return Result.failure(const FalhaDeConexaoException());
    }
  }
}

/// Fração do upload (0..1) a partir dos bytes do `onSendProgress`; `null`
/// quando o total não é conhecido (barra indeterminada).
double? fracaoEnviada(int enviados, int total) {
  if (total <= 0) return null;
  return (enviados / total).clamp(0, 1).toDouble();
}
