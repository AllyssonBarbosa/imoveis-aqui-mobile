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

  /// Define o preço mínimo do rascunho (D-09) — IGNORADO enquanto
  /// `finalidade` é `null` (D-03): sem finalidade não há como saber se o
  /// valor compara com `preco_venda` ou `preco_aluguel` (o campo também
  /// fica desabilitado no sheet, defesa em profundidade com a validação
  /// server-side de 03-03/Task 1).
  void definirPrecoMin(int? valor) {
    if (state.finalidade == null) return;
    emit(state.copyWith(precoMin: valor));
  }

  /// Define o preço máximo do rascunho — mesma semântica de
  /// [definirPrecoMin].
  void definirPrecoMax(int? valor) {
    if (state.finalidade == null) return;
    emit(state.copyWith(precoMax: valor));
  }

  /// Define a área mínima do rascunho (D-09) — SEMPRE aplica, independente
  /// da finalidade (área não depende da escala preço_venda/preco_aluguel).
  void definirAreaMin(int? valor) => emit(state.copyWith(areaMin: valor));

  /// Define a área máxima do rascunho — mesma semântica de
  /// [definirAreaMin].
  void definirAreaMax(int? valor) => emit(state.copyWith(areaMax: valor));
}

/// Validação de FORMULÁRIO do rascunho de filtros (D-12) — nunca uma regra
/// de negócio: o servidor simulado revalida sozinho, independentemente desta
/// extensão (03-03/Task 1, `filtrosDosParametros`). Mínimo maior que máximo
/// mostra erro inline e desabilita "Ver imóveis"; mínimo IGUAL ao máximo é
/// válido (faixa de um único valor).
extension ValidacaoRascunho on FiltrosVitrine {
  /// Erro de formulário da faixa de preço, ou `null` se válida.
  String? get erroFaixaPreco => _erroDeFaixa(precoMin, precoMax);

  /// Erro de formulário da faixa de área, ou `null` se válida.
  String? get erroFaixaArea => _erroDeFaixa(areaMin, areaMax);

  /// `false` enquanto QUALQUER faixa (preço OU área) tiver erro de
  /// formulário — é o que desabilita "Ver imóveis" no rodapé do sheet
  /// (D-12).
  bool get podeAplicar => erroFaixaPreco == null && erroFaixaArea == null;
}

String? _erroDeFaixa(int? minimo, int? maximo) {
  if (minimo != null && maximo != null && minimo > maximo) {
    return 'O mínimo não pode ser maior que o máximo';
  }
  return null;
}
