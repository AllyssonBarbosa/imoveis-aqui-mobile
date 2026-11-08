import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel.dart';

part 'vitrine_anunciante_state.freezed.dart';

/// Estado da vitrine de imóveis de UM anunciante (corretor ou empresa) —
/// união selada dos desfechos de carregamento. Sucesso é um estado
/// "achatado" único (`carregada`): uma falha ao carregar mais itens não pode
/// derrubar a lista já visível.
@freezed
sealed class VitrineAnuncianteState with _$VitrineAnuncianteState {
  /// Primeira página em voo.
  const factory VitrineAnuncianteState.carregando() =
      VitrineAnuncianteCarregando;

  /// Anunciante válido sem nenhum imóvel anunciado (§12.5) — não é erro.
  const factory VitrineAnuncianteState.vazia() = VitrineAnuncianteVazia;

  /// Falha da DataSource na primeira página — "Tentar de novo" repete a busca.
  const factory VitrineAnuncianteState.erro() = VitrineAnuncianteErro;

  /// Sucesso — itens na ordem recebida do servidor. `carregandoMais` e
  /// `erroAoCarregarMais` só passam a ser usados na paginação; até lá ficam
  /// `false`.
  const factory VitrineAnuncianteState.carregada({
    required List<Imovel> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
  }) = VitrineAnuncianteCarregada;
}
