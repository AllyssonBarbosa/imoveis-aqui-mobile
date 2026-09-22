import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../presentation/cidade_selecao/cidade_selecao_state.dart';
import '../entities/cidade.dart';
import 'obter_cidades_atendidas_usecase.dart';

/// Revalida uma cidade salva no aparelho contra a lista atendida ATUAL antes
/// de confiar nela na reabertura do app (D-08 + RESEARCH Pitfall 5/A2) — uma
/// cidade que deixou de ser atendida entre sessões nunca deve entrar direto
/// numa vitrine fantasma sem imóveis.
///
/// Casamento por `chaveNatural` (nome+uf normalizado, D-09), reaproveitando a
/// mesma regra do Plano 01-03. Segue o mesmo padrão de
/// [lib/domain/usecases/detectar_cidade_usecase.dart]: retorna o
/// [CidadeSelecaoState] resultante diretamente (não um DTO mais estreito),
/// já que seu único trabalho é mapear "a cidade salva ainda é atendida?"
/// para o desfecho de UI correspondente — mantém o Cubit um orquestrador
/// fino.
@injectable
class ValidarCidadeAtendidaUseCase {
  ValidarCidadeAtendidaUseCase(this._obterCidadesAtendidas);

  final ObterCidadesAtendidasUseCase _obterCidadesAtendidas;

  Future<CidadeSelecaoState> call(Cidade cidadeSalva) async {
    final resultado = await _obterCidadesAtendidas();
    switch (resultado) {
      case Success(:final data):
        for (final cidade in data) {
          if (cidade.chaveNatural == cidadeSalva.chaveNatural) {
            return CidadeSelecaoState.autorizadaEAtendida(cidade);
          }
        }
        // Cidade salva não está mais na lista atendida (A2/Pitfall 5) — cai
        // na lista em vez de entrar numa cidade fantasma sem imóveis, nunca
        // um beco.
        return CidadeSelecaoState.autorizadaNaoAtendida(
          cidadeSalva.nome,
          data,
        );
      case Failure():
      case Loading():
        return const CidadeSelecaoState.erroCarregarCidades();
    }
  }
}
