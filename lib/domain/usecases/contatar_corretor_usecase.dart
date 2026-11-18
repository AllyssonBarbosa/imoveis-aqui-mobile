import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/canal_contato.dart';
import '../gateways/link_launcher_gateway.dart';
import '../repositories/contato_repository.dart';

/// Registra o contato do visitante com o responsável pelo imóvel e, só então,
/// abre o link devolvido pelo servidor em um aplicativo externo (C2, C3, C4).
///
/// Ordem fixa (D-14, D-15): primeiro o registro, depois a abertura.
/// - Falha no registro: nada é aberto e a falha tipada do repositório sobe.
/// - Registro ok e abertura `false`: devolve [ContatoSemAplicativoException];
///   o contato já está registrado e nunca é desfeito.
///
/// Decisão (RESEARCH Open Question 3): se o visitante sair da tela durante o
/// POST, o link ainda abre — o contato foi registrado e foi ele quem pediu.
/// O caso de uso não loga nem guarda o link.
@injectable
class ContatarCorretorUseCase {
  ContatarCorretorUseCase(this._repositorio, this._gateway);

  final ContatoRepository _repositorio;
  final LinkLauncherGateway _gateway;

  Future<Result<void>> call(int imovelId, CanalContato canal) async {
    final registro = await _repositorio.registrarContato(imovelId, canal);
    switch (registro) {
      case Success(:final data):
        final abriu = await _gateway.abrir(data);
        if (abriu) return const Result.success(null);
        // O contato já está registrado no servidor: nunca é desfeito (D-15).
        return const Result.failure(ContatoSemAplicativoException());
      case Failure(:final erro):
        return Result.failure(erro);
      case Loading():
        return const Result.loading();
    }
  }
}
