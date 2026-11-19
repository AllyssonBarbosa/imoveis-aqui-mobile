import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/imovel_detalhe_datasource.dart';

/// Impl de [ImovelDetalheRepository] — injeta a interface
/// [ImovelDetalheDataSource], nunca a classe remota diretamente (mesma
/// disciplina de `ImovelRepositoryImpl`).
///
/// Traduz toda falha da DataSource em `Result.failure` tipado (DET-06, D-01):
/// 404 vira [ImovelNaoEncontradoException] e JSON malformado ([TypeError] do
/// `fromJson`) vira [FormatException], então o Cubit decide só pelo tipo. A
/// DataSource remota apenas deixa a `DioException` subir.
@LazySingleton(as: ImovelDetalheRepository)
class ImovelDetalheRepositoryImpl implements ImovelDetalheRepository {
  ImovelDetalheRepositoryImpl(this._dataSource);

  final ImovelDetalheDataSource _dataSource;

  @override
  Future<Result<DetalheImovel>> buscarDetalhe(int id) async {
    try {
      final modelo = await _dataSource.buscarDetalhe(id);
      return Result.success(modelo.paraEntidade());
    } on DioException catch (erro) {
      // 404 = inexistente ou despublicado: repetir não resolve (D-17).
      if (erro.response?.statusCode == 404) {
        return Result.failure(const ImovelNaoEncontradoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      // Campo obrigatório ausente no JSON: o `fromJson` gerado faz `as` e
      // lança TypeError, que é um Error (não Exception) — Pitfall 1.
      return Result.failure(FormatException('detalhe malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
