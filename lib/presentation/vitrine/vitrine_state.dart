import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel.dart';
import '../../domain/entities/ordenacao_vitrine.dart';

part 'vitrine_state.freezed.dart';

/// Estado de tela da vitrine (VIT-01) — `ordenacao`/`termoBusca` persistem
/// através de qualquer transição de [conteudo] (controles chegam na Fase 3);
/// [conteudo] é a união selada dos desfechos de carregamento.
@freezed
abstract class VitrineState with _$VitrineState {
  const factory VitrineState({
    @Default(OrdenacaoVitrine.maisRecentes) OrdenacaoVitrine ordenacao,
    String? termoBusca,
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
