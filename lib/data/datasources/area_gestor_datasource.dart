import '../../domain/entities/periodo_contatos.dart';
import '../models/acervo_por_corretor_model.dart';
import '../models/contatos_por_corretor_model.dart';
import '../models/mudancas_recentes_model.dart';
import '../models/totais_por_situacao_model.dart';

/// Fonte da Área do gestor (`/api/relatorios/...`). Interface trocável: a
/// implementação remota usa o `Dio` autenticado, e quem está acima só enxerga
/// Models tipados. A regra e a conta são do servidor; o app só lê (D-15, D-19):
/// nenhuma leitura leva filtro de imóvel nem janela de dias.
abstract class AreaGestorDataSource {
  /// Totais do acervo da empresa por situação (`GET /api/relatorios/acervo/`).
  Future<TotaisPorSituacaoModel> obterTotaisPorSituacao();

  /// Acervo por corretor (`GET /api/relatorios/acervo-por-corretor/`), na
  /// ordem do servidor.
  Future<AcervoPorCorretorModel> obterAcervoPorCorretor();

  /// Contatos por corretor (`GET /api/relatorios/contatos/`). Só [periodo] vai
  /// ao servidor (`de`/`ate`); sem ele é todo o período (D-16).
  Future<ContatosPorCorretorModel> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]);

  /// Mudanças de situação recentes
  /// (`GET /api/relatorios/mudancas-situacao/`). Sem parâmetro: a janela de
  /// dias é do servidor (D-19).
  Future<MudancasRecentesModel> obterMudancasRecentes();
}
