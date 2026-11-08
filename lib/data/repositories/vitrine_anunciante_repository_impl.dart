import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/anunciante_ref.dart';
import '../../domain/entities/pagina_imoveis.dart';
import '../../domain/repositories/vitrine_anunciante_repository.dart';
import '../datasources/vitrine_anunciante_datasource.dart';
import '../models/imoveis_envelope_model.dart';

/// Impl de [VitrineAnuncianteRepository] — injeta a interface trocável
/// [VitrineAnuncianteDataSource], nunca o mock diretamente. Só repassa a
/// página na ordem recebida: não filtra nem reordena (§12.9).
@LazySingleton(as: VitrineAnuncianteRepository)
class VitrineAnuncianteRepositoryImpl implements VitrineAnuncianteRepository {
  VitrineAnuncianteRepositoryImpl(this._dataSource);

  final VitrineAnuncianteDataSource _dataSource;

  @override
  Future<Result<PaginaImoveis>> buscarPrimeiraPagina(
    AnuncianteRef anunciante,
  ) => _executar(() => _dataSource.buscar(anunciante));

  @override
  Future<Result<PaginaImoveis>> buscarProximaPagina(String proximaPagina) =>
      _executar(() => _dataSource.seguir(proximaPagina));

  /// Tradução única de erros: JSON malformado ([TypeError], que é um `Error`,
  /// não uma `Exception`) vira [FormatException]; qualquer `Exception` vira
  /// falha tipada.
  Future<Result<PaginaImoveis>> _executar(
    Future<ImoveisEnvelopeModel> Function() acao,
  ) async {
    try {
      final envelope = await acao();
      return Result.success(envelope.paraPagina());
    } on TypeError catch (erro) {
      return Result.failure(FormatException('vitrine malformada: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
