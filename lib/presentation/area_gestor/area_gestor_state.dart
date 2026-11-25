import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/acervo_por_corretor.dart';
import '../../domain/entities/contatos_por_corretor.dart';
import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/entities/totais_por_situacao.dart';

part 'area_gestor_state.freezed.dart';

/// Por que uma seção da Área do gestor não carregou. Guarda só o TIPO da
/// falha: a tela escolhe o texto fixo (D-23) e nada que o servidor escreveu
/// chega ao usuário.
enum FalhaDaSecao {
  /// 403: o papel de quem está logado não é o de gestor (D-23).
  semPermissao,

  /// Rede, timeout, 5xx, 400 ou resposta malformada (D-24).
  indisponivel,
}

/// As 4 seções da Área do gestor, na ordem da tela (D-06). Identifica qual
/// delas repetir em "Tentar de novo" (D-07).
enum SecaoDaAreaGestor { totais, acervo, contatos, mudancas }

/// Estado de UMA seção: cada uma carrega, falha e termina sozinha (D-07).
@freezed
sealed class EstadoSecao<T> with _$EstadoSecao<T> {
  /// Pedido em voo.
  const factory EstadoSecao.carregando() = SecaoCarregando<T>;

  /// O pedido falhou; [falha] é só o tipo (D-23, D-24).
  const factory EstadoSecao.comFalha(FalhaDaSecao falha) = SecaoComFalha<T>;

  /// Sucesso: [dados] é exatamente a entidade que o servidor devolveu — o app
  /// não soma, não conta e não filtra nada (critério 5).
  const factory EstadoSecao.carregada(T dados) = SecaoCarregada<T>;
}

/// Estado de tela da Área do gestor (GES-01..GES-06): um [EstadoSecao] por
/// relatório, mais o período aplicado aos contatos e o aviso terminal de
/// sessão.
@freezed
abstract class AreaGestorState with _$AreaGestorState {
  const factory AreaGestorState({
    /// Totais da empresa por situação (GES-01).
    @Default(EstadoSecao<TotaisPorSituacao>.carregando())
    EstadoSecao<TotaisPorSituacao> totais,

    /// Acervo por corretor (GES-02).
    @Default(EstadoSecao<AcervoPorCorretor>.carregando())
    EstadoSecao<AcervoPorCorretor> acervo,

    /// Contatos por corretor, no [periodo] aplicado (GES-03, GES-04).
    @Default(EstadoSecao<ContatosPorCorretor>.carregando())
    EstadoSecao<ContatosPorCorretor> contatos,

    /// Mudanças de situação dos últimos dias que o servidor definiu (GES-05).
    @Default(EstadoSecao<MudancasRecentes>.carregando())
    EstadoSecao<MudancasRecentes> mudancas,

    /// Período aplicado à seção de contatos; `null` = todo o período (D-16).
    PeriodoContatos? periodo,

    /// O servidor recusou o token (401) em qualquer seção: a sessão terminou
    /// (D-22). Estado terminal — depois dele nada mais é emitido.
    @Default(false) bool sessaoExpirada,
  }) = _AreaGestorState;
}
