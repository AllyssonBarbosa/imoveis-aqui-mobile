import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/entities/ordenacao_vitrine.dart';

part 'vitrine_state.freezed.dart';

/// Estado de tela da vitrine (VIT-01) — `ordenacao`/`termoBusca`/`filtros`
/// persistem através de qualquer transição de [conteudo] (controles
/// chegaram nas Fases 2 e 3); [conteudo] é a união selada dos desfechos de
/// carregamento.
@freezed
abstract class VitrineState with _$VitrineState {
  const factory VitrineState({
    @Default(OrdenacaoVitrine.maisRecentes) OrdenacaoVitrine ordenacao,
    String? termoBusca,
    @Default(FiltrosVitrine()) FiltrosVitrine filtros,
    @Default(ConteudoVitrine.carregando()) ConteudoVitrine conteudo,
  }) = _VitrineState;
}

/// União selada dos desfechos de carregamento da vitrine — estado
/// "achatado" único de sucesso (`carregada`), nunca sealed-por-página
/// (RESEARCH anti-pattern): uma falha ao carregar mais itens não pode
/// derrubar a lista já visível.
@freezed
sealed class ConteudoVitrine with _$ConteudoVitrine {
  /// Primeira página em voo.
  const factory ConteudoVitrine.carregando() = VitrineCarregando;

  /// Cidade atendida sem nenhum imóvel na fixture (D-15) — distinto de
  /// "sem resultado de busca" (D-09).
  const factory ConteudoVitrine.vazioNaCidade() = VitrineVaziaNaCidade;

  /// Busca por texto sem resultado (D-09) — distinto do vazio da cidade.
  const factory ConteudoVitrine.semResultado(String termo) =
      VitrineSemResultado;

  /// Filtros ativos zeraram o resultado (D-22) — distinto de
  /// [ConteudoVitrine.vazioNaCidade] (cidade sem nenhum imóvel) e de
  /// [ConteudoVitrine.semResultado] (só busca, sem filtro ativo). `termo`
  /// não-nulo quando uma busca por texto TAMBÉM está ativa — a mensagem e o
  /// botão de limpar mudam conforme (D-22).
  const factory ConteudoVitrine.semResultadoComFiltros({String? termo}) =
      VitrineSemResultadoComFiltros;

  /// Falha da DataSource na primeira página (D-13) — "Tentar de novo" chama
  /// `VitrineCubit.tentarNovamente()`.
  const factory ConteudoVitrine.erro() = VitrineErro;

  /// Sucesso — lista carregada. `carregandoMais`/`erroAoCarregarMais` só
  /// passam a ser usados no scroll infinito (plan 02-03); aqui sempre
  /// `false`.
  const factory ConteudoVitrine.carregada({
    required List<Imovel> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
  }) = VitrineCarregada;
}
