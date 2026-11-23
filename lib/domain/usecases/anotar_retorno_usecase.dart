import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/contato_recebido.dart';
import '../entities/retorno_contato.dart';
import '../repositories/caixa_contatos_repository.dart';

/// Anota o retorno de um contato. Repasse puro: o app não decide regra — quem
/// garante que `PENDENTE` nunca é enviado é a folha de opções
/// (`RetornoContato.anotaveis`) e, de qualquer forma, a API recusa; a anotação
/// só vale depois que o servidor aceita (D-16).
@injectable
class AnotarRetornoUseCase {
  AnotarRetornoUseCase(this._repositorio);

  final CaixaContatosRepository _repositorio;

  Future<Result<ContatoRecebido>> call(int id, RetornoContato retorno) =>
      _repositorio.anotarRetorno(id, retorno);
}
