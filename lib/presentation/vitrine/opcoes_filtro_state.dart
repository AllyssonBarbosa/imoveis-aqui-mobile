import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/caracteristica.dart';

part 'opcoes_filtro_state.freezed.dart';

/// Estado de [OpcoesFiltroCubit] (D-20) — duas dimensões independentes
/// (bairros/características), cada uma com seu próprio ciclo de
/// carregamento/falha/retry.
@freezed
abstract class OpcoesFiltroState with _$OpcoesFiltroState {
  const factory OpcoesFiltroState({
    @Default(CarregamentoOpcoes<String>.carregando())
    CarregamentoOpcoes<String> bairros,
    @Default(CarregamentoOpcoes<Caracteristica>.carregando())
    CarregamentoOpcoes<Caracteristica> caracteristicas,
  }) = _OpcoesFiltroState;
}

/// União selada do desfecho de carregamento de uma dimensão de opções.
@freezed
sealed class CarregamentoOpcoes<T> with _$CarregamentoOpcoes<T> {
  const factory CarregamentoOpcoes.carregando() = OpcoesCarregando<T>;

  /// Ordem preservada EXATAMENTE como veio do use case (o app nunca
  /// re-ordena, contrato §10 item 8).
  const factory CarregamentoOpcoes.carregadas(List<T> opcoes) =
      OpcoesCarregadas<T>;

  const factory CarregamentoOpcoes.falha() = OpcoesFalha<T>;
}
