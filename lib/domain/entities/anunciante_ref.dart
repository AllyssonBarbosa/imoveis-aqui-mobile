import 'package:freezed_annotation/freezed_annotation.dart';

part 'anunciante_ref.freezed.dart';

/// Quem anuncia uma vitrine de imóveis: um corretor ou uma empresa. O app só
/// envia o id — quem recorta os imóveis do anunciante, ordena e pagina é o
/// servidor (contrato §12); nada disso é decidido no aparelho.
@freezed
sealed class AnuncianteRef with _$AnuncianteRef {
  /// Vitrine dos imóveis em que o corretor [id] é o responsável.
  const factory AnuncianteRef.corretor(int id) = AnuncianteCorretor;

  /// Vitrine dos imóveis de todos os corretores da empresa [id].
  const factory AnuncianteRef.empresa(int id) = AnuncianteEmpresa;
}
