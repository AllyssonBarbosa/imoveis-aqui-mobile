import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/filtros_vitrine.dart';

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
}
