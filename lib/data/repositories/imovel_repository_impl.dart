import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/pagina_imoveis.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../datasources/imovel_datasource.dart';

/// Impl de [ImovelRepository] (API-04) — injeta a interface trocável
/// [ImovelDataSource], nunca a classe mock diretamente (mesma disciplina de
/// `CidadeRepositoryImpl`).
@LazySingleton(as: ImovelRepository)
class ImovelRepositoryImpl implements ImovelRepository {
  ImovelRepositoryImpl(this._dataSource);

  final ImovelDataSource _dataSource;

  @override
  Future<Result<PaginaImoveis>> buscarImoveis(
    ConsultaImoveis consulta,
  ) async {
    try {
      final envelope = await _dataSource.buscar(consulta);
      return Result.success(envelope.paraPagina());
    } on TypeError catch (erro) {
      // Campo obrigatório ausente ou de tipo errado: o `fromJson` gerado faz
      // `as` e lança TypeError, que é um Error (não Exception) — Pitfall 1.
      return Result.failure(
        FormatException('lista de imóveis malformada: $erro'),
      );
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }

  @override
  Future<Result<PaginaImoveis>> buscarProximaPagina(
    String proximaPagina,
  ) async {
    try {
      final envelope = await _dataSource.seguir(proximaPagina);
      return Result.success(envelope.paraPagina());
    } on TypeError catch (erro) {
      // Campo obrigatório ausente ou de tipo errado: o `fromJson` gerado faz
      // `as` e lança TypeError, que é um Error (não Exception) — Pitfall 1.
      return Result.failure(
        FormatException('lista de imóveis malformada: $erro'),
      );
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
