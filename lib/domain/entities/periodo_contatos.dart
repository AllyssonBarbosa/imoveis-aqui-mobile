/// Intervalo de dias do filtro por período da caixa (D-19).
///
/// As datas são inclusivas e só o dia importa: [de] e [ate] vão ao servidor
/// como datas (sem hora). Quem decide em que dia um contato cai é o servidor,
/// com os dias de São Paulo (§16.7 do contrato) — o app não recalcula.
class PeriodoContatos {
  const PeriodoContatos({required this.de, required this.ate});

  final DateTime de;
  final DateTime ate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodoContatos && other.de == de && other.ate == ate);

  @override
  int get hashCode => Object.hash(de, ate);

  @override
  String toString() => 'PeriodoContatos(de: $de, ate: $ate)';
}
