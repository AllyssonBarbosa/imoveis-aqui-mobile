import '../../core/result.dart';
import '../entities/acervo_por_corretor.dart';
import '../entities/contatos_por_corretor.dart';
import '../entities/mudancas_recentes.dart';
import '../entities/periodo_contatos.dart';
import '../entities/totais_por_situacao.dart';

/// Área do gestor (GES-01..GES-05): as 4 leituras de acompanhamento da
/// empresa. Nada é contado, somado, filtrado ou reordenado no aparelho
/// (critério 5): os números, a ordem e quem aparece vêm do servidor.
///
/// Falhas tipadas comuns a todos os métodos: `SessaoExpiradaException` (401),
/// `SemPermissaoException` (403) e as demais como `Failure` genérica.
abstract class AreaGestorRepository {
  /// Totais do acervo da empresa por situação (D-09, D-10).
  Future<Result<TotaisPorSituacao>> obterTotaisPorSituacao();

  /// Acervo por corretor, na ordem do servidor (D-13).
  Future<Result<AcervoPorCorretor>> obterAcervoPorCorretor();

  /// Contatos por corretor, só por período (D-15), nunca por imóvel.
  /// `obterContatosPorCorretor([PeriodoContatos? periodo])`: sem [periodo] =
  /// todo o período (D-16).
  Future<Result<ContatosPorCorretor>> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]);

  /// Mudanças de situação recentes. Sem parâmetro de janela: a janela é do
  /// servidor e volta em `dias` (D-19).
  Future<Result<MudancasRecentes>> obterMudancasRecentes();
}
