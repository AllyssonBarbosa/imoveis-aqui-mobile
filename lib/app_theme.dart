import 'package:flutter/material.dart';

/// Tema do app — Material 3, paleta Verde e Branco via [ColorScheme.fromSeed].
///
/// A cor semente abaixo (`Color(0xFF2E7D32)`, Material Green 800) é o valor
/// padrão proposto pela pesquisa (UI-SPEC §Color) — ainda não é uma decisão
/// travada pelo usuário. Pode ser trocada aqui sem impacto em outros pontos
/// do app, já que todo o restante do tema deriva algoritmicamente da semente.
class AppTheme {
  AppTheme._();

  static const Color corSemente = Color(0xFF2E7D32);

  static ThemeData get tema => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: corSemente,
      brightness: Brightness.light,
    ),
  );
}
