import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/papel.dart';

part 'entrada_area_state.freezed.dart';

/// Estado da entrada em "Meu acervo": o app pergunta o papel ao servidor e só
/// depois decide a tela (D-02, D-B). Nenhum estado guarda token nem dado do
/// usuário além do [Papel] devolvido.
@freezed
sealed class EntradaAreaState with _$EntradaAreaState {
  /// Pergunta ao servidor em curso.
  const factory EntradaAreaState.carregando() = EntradaAreaCarregando;

  /// O servidor respondeu o [papel]; a tela troca de rota por ele.
  const factory EntradaAreaState.papel(Papel papel) = EntradaAreaPapel;

  /// Falha que repetir pode resolver (rede, servidor, formato).
  const factory EntradaAreaState.erro() = EntradaAreaErro;

  /// O servidor recusou o token (401): a sessão não vale mais.
  const factory EntradaAreaState.sessaoExpirada() = EntradaAreaSessaoExpirada;
}
