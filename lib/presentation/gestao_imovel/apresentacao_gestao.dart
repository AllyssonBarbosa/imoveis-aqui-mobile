// Textos fixos e formatação da tela de gestão do imóvel — a tela e os widgets
// só apresentam, nunca decidem nada de negócio (mesmo molde de
// `apresentacao_acervo.dart`).

import 'package:intl/intl.dart';

/// Falha ao ler o imóvel na primeira carga; nunca mostra o corpo do erro do
/// servidor (T-09-05).
const String textoErroGestao = 'Não foi possível carregar o imóvel.';

/// Rótulo do botão que repete a leitura.
const String rotuloTentarDeNovo = 'Tentar de novo';

/// Título da seção que mostra a situação atual do imóvel.
const String tituloSecaoSituacao = 'Situação';

/// Atalho para a página pública do imóvel (só com `na_vitrine` do servidor).
const String rotuloVerNaVitrine = 'Ver na vitrine';

/// Data e hora de um instante do servidor, `dd/MM/yyyy HH:mm`, no fuso do
/// aparelho (D-05, A3 da pesquisa). Sem locale de propósito: com locale seria
/// preciso inicializar os dados de data antes (RESEARCH, Pitfall 8).
String formatarDataHora(DateTime momento) =>
    DateFormat('dd/MM/yyyy HH:mm').format(momento.toLocal());

/// "desde dd/MM/yyyy HH:mm" — quando o imóvel entrou na situação atual, sempre
/// a data que o servidor mandou (D-05).
String textoDesde(DateTime momento) => 'desde ${formatarDataHora(momento)}';
