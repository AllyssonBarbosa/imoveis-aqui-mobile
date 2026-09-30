import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/imovel.dart';

/// Rascunho do sheet de filtros (D-08) — Cubit de vida curta, criado pelo
/// próprio `showModalBottomSheet` (via `BlocProvider` inline) e descartado
/// ao fechar; NÃO é registrado no `get_it`/`injectable`. Semeado a partir
/// dos filtros já APLICADOS (tocar no corpo de um chip reabre o sheet com o
/// rascunho igual aos filtros aplicados, D-17); mexer nos controles do
/// rascunho nunca dispara consulta — "Ver imóveis" é quem aplica tudo de
/// uma vez (D-08).
class RascunhoFiltrosCubit extends Cubit<FiltrosVitrine> {
  RascunhoFiltrosCubit(super.filtrosAplicados);

  /// Troca a finalidade do rascunho. Trocar a finalidade limpa a faixa de
  /// preço do rascunho na MESMA emissão (D-13): sem finalidade não há como
  /// saber se `precoMin`/`precoMax` comparam com `preco_venda` ou
  /// `preco_aluguel` (D-03). Reselecionar a MESMA finalidade não emite nada
  /// (idempotência, mesma disciplina do restante do app).
  void definirFinalidade(FinalidadeFiltro? finalidade) {
    if (finalidade == state.finalidade) return;
    emit(
      state.copyWith(finalidade: finalidade, precoMin: null, precoMax: null),
    );
  }

  /// "Limpar" do rodapé do sheet (D-18) — zera só o RASCUNHO; o visitante
  /// ainda precisa tocar "Ver imóveis" para aplicar (nunca mexe nos filtros
  /// já aplicados, que ficam em `VitrineState`).
  void limpar() => emit(const FiltrosVitrine());

  /// Marca/desmarca uma natureza no rascunho (FIL-02, D-05, D-11) — multi-
  /// seleção, OU entre valores resolvido pelo servidor simulado; nenhum
  /// outro campo do rascunho é tocado.
  void alternarNatureza(NaturezaImovel natureza, {required bool marcada}) {
    final naturezas = Set<NaturezaImovel>.of(state.naturezas);
    if (marcada) {
      naturezas.add(natureza);
    } else {
      naturezas.remove(natureza);
    }
    emit(state.copyWith(naturezas: naturezas));
  }

  /// Define o mínimo de quartos do rascunho — "N ou mais" (D-01, D-10);
  /// `null` volta para "Qualquer".
  void definirQuartosMin(int? minimo) =>
      emit(state.copyWith(quartosMin: minimo));

  /// Define o mínimo de suítes do rascunho — mesma semântica de
  /// [definirQuartosMin].
  void definirSuitesMin(int? minimo) =>
      emit(state.copyWith(suitesMin: minimo));

  /// Define o mínimo de vagas do rascunho — mesma semântica de
  /// [definirQuartosMin].
  void definirVagasMin(int? minimo) =>
      emit(state.copyWith(vagasMin: minimo));
}
