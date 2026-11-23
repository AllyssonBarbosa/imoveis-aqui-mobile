import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localização do app inteiro em português do Brasil para os widgets do
/// Material (D-20) — o seletor de datas da caixa de contatos, por exemplo,
/// mostra "Salvar" e "Selecione o intervalo". Fica num arquivo próprio para a
/// produção (`main.dart`) e os testes de widget usarem exatamente a mesma
/// configuração.
///
/// Não há `locale:` fixo no `MaterialApp`: um aparelho em outro idioma cai no
/// primeiro locale suportado.
///
/// O `GlobalMaterialLocalizations` do `flutter_localizations` está marcado
/// como obsoleto em favor do `material_ui`, pacote que o projeto não adota (a
/// mesma obsolescência já vale para o `material.dart` em todo o app); o
/// `ignore` mantém o analyze sem ruído novo até a migração do Material.
const List<LocalizationsDelegate<dynamic>> delegatesDeLocalizacao =
    // ignore: deprecated_member_use
    GlobalMaterialLocalizations.delegates;

/// Único idioma suportado pelo app.
const List<Locale> localesSuportados = [Locale('pt', 'BR')];
