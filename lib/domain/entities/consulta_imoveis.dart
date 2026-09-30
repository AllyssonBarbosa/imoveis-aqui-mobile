import 'cidade.dart';
import 'filtros_vitrine.dart';
import 'ordenacao_vitrine.dart';

/// Parâmetros de uma consulta à vitrine (cidade + busca + ordenação +
/// filtros) — a única entrada que atravessa UseCase -> Repository ->
/// DataSource (D-14). Nunca carrega cursor/paginação (isso é opaco, tratado
/// à parte na Fase 3).
class ConsultaImoveis {
  const ConsultaImoveis({
    required this.cidade,
    this.busca,
    this.ordenacao = OrdenacaoVitrine.maisRecentes,
    this.filtros = const FiltrosVitrine(),
  });

  final Cidade cidade;
  final String? busca;
  final OrdenacaoVitrine ordenacao;
  final FiltrosVitrine filtros;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsultaImoveis &&
          other.cidade == cidade &&
          other.busca == busca &&
          other.ordenacao == ordenacao &&
          other.filtros == filtros);

  @override
  int get hashCode => Object.hash(cidade, busca, ordenacao, filtros);

  @override
  String toString() =>
      'ConsultaImoveis(cidade: $cidade, busca: $busca, ordenacao: '
      '$ordenacao, filtros: $filtros)';
}
