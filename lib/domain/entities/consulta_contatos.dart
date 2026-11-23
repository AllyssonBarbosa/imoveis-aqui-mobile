import 'imovel_com_contato.dart';
import 'periodo_contatos.dart';

/// Parâmetros de uma consulta à caixa de contatos do corretor — a única
/// entrada que atravessa UseCase -> Repository -> DataSource. Nunca carrega
/// cursor de paginação. O imóvel e o período se combinam (D-18, D-19, D-20) e
/// o filtro é resolvido no servidor: o app só carrega o que vai na consulta
/// (D-13).
class ConsultaContatos {
  const ConsultaContatos({this.imovel, this.periodo});

  final ImovelComContato? imovel;
  final PeriodoContatos? periodo;

  /// `true` quando há imóvel ou período escolhido.
  bool get temFiltro => imovel != null || periodo != null;

  /// Cópia com campos trocados. Como `null` significa "não mudar",
  /// [limparImovel] e [limparPeriodo] voltam o filtro a "sem filtro".
  ConsultaContatos copyWith({
    ImovelComContato? imovel,
    PeriodoContatos? periodo,
    bool limparImovel = false,
    bool limparPeriodo = false,
  }) {
    return ConsultaContatos(
      imovel: limparImovel ? null : (imovel ?? this.imovel),
      periodo: limparPeriodo ? null : (periodo ?? this.periodo),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsultaContatos &&
          other.imovel == imovel &&
          other.periodo == periodo);

  @override
  int get hashCode => Object.hash(imovel, periodo);

  @override
  String toString() => 'ConsultaContatos(imovel: $imovel, periodo: $periodo)';
}
