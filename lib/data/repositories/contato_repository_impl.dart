import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/canal_contato.dart';
import '../../domain/repositories/contato_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/contato_datasource.dart';
import '../models/canal_contato_api.dart';
import '../models/contato_registrado_model.dart';

/// Impl de [ContatoRepository] — injeta a interface [ContatoDataSource], nunca
/// a classe remota diretamente.
///
/// Traduz toda falha da DataSource em `Result.failure` tipado (D-14): 400 vira
/// [CanalIndisponivelException], 404 reaproveita [ImovelNaoEncontradoException],
/// 429 vira [ContatoLimiteExcedidoException]; rede, timeout e 5xx seguem como a
/// própria `DioException` e JSON malformado vira [FormatException]. No sucesso,
/// o link do servidor só passa se for permitido para o canal pedido (defesa em
/// profundidade): é usado exatamente como veio, sem reconstruir, reencodar nem
/// registrar em log.
@LazySingleton(as: ContatoRepository)
class ContatoRepositoryImpl implements ContatoRepository {
  ContatoRepositoryImpl(this._dataSource);

  final ContatoDataSource _dataSource;

  @override
  Future<Result<Uri>> registrarContato(int imovelId, CanalContato canal) async {
    try {
      final modelo = await _dataSource.registrar(imovelId, canal);
      return _linkSeguro(modelo, canal);
    } on DioException catch (erro) {
      return Result.failure(switch (erro.response?.statusCode) {
        400 => const CanalIndisponivelException(),
        404 => const ImovelNaoEncontradoException(),
        429 => const ContatoLimiteExcedidoException(),
        _ => erro,
      });
    } on TypeError catch (erro) {
      // Campo obrigatório ausente no JSON: o `fromJson` gerado faz `as` e
      // lança TypeError, que é um Error (não Exception). O texto não leva o
      // corpo da resposta, só o tipo do erro.
      return Result.failure(FormatException('contato malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }

  /// O [Uri] do link só quando o canal da resposta é o pedido e o esquema (e o
  /// host, no WhatsApp) é o esperado para ele; senão
  /// [LinkContatoInvalidoException].
  Result<Uri> _linkSeguro(ContatoRegistradoModel modelo, CanalContato canal) {
    if (modelo.canal != canal.valorApi) {
      return Result.failure(const LinkContatoInvalidoException());
    }
    final uri = Uri.tryParse(modelo.link);
    if (uri == null) {
      return Result.failure(const LinkContatoInvalidoException());
    }
    final permitido = switch (canal) {
      CanalContato.whatsapp => uri.scheme == 'https' && uri.host == 'wa.me',
      CanalContato.telefone => uri.scheme == 'tel',
      CanalContato.email => uri.scheme == 'mailto',
    };
    return permitido
        ? Result.success(uri)
        : Result.failure(const LinkContatoInvalidoException());
  }
}
