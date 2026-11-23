import 'package:flutter/material.dart';

import '../../../domain/entities/periodo_contatos.dart';

/// Abre o seletor de período e devolve o intervalo escolhido, ou `null` se o
/// usuário fechou o diálogo. É um `typedef` para a tela (10-09) receber a
/// função por parâmetro e os testes de widget trocarem o seletor por um falso.
typedef EscolherPeriodo = Future<PeriodoContatos?> Function(
  BuildContext context,
  PeriodoContatos? atual,
);

/// Primeiro dia que o seletor deixa escolher (decisão pós-pesquisa, D-20): o
/// site e a caixa não têm contatos anteriores a 2024.
final DateTime primeiraDataDoSeletor = DateTime(2024);

/// `showDateRangePicker` de "hoje" para trás, nos textos do Material em pt-BR
/// ("Selecione o intervalo", "Salvar" — sem `helpText`/`saveText` próprios) e
/// sem atalhos de período (D-20).
///
/// As datas são inclusivas e só o dia importa: o servidor as lê como dias de
/// São Paulo (§16.7), então o app não converte fuso nem recalcula nada.
Future<PeriodoContatos?> escolherPeriodoComSeletor(
  BuildContext context,
  PeriodoContatos? atual,
) async {
  final escolhido = await showDateRangePicker(
    context: context,
    firstDate: primeiraDataDoSeletor,
    lastDate: DateUtils.dateOnly(DateTime.now()),
    initialDateRange: atual == null
        ? null
        : DateTimeRange(start: atual.de, end: atual.ate),
  );
  if (escolhido == null) return null;
  return PeriodoContatos(de: escolhido.start, ate: escolhido.end);
}
