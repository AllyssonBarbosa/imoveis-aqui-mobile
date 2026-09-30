import 'cidade.dart';
import 'ordenacao_vitrine.dart';

/// Parâmetros de uma consulta à vitrine (cidade + busca + ordenação) — a
/// única entrada que atravessa UseCase -> Repository -> DataSource (D-14).
/// Nunca carrega cursor/paginação (isso é opaco, tratado à parte na Fase 3).
class ConsultaImoveis {
  const ConsultaImoveis({
    required this.cidade,
    this.busca,
    this.ordenacao = OrdenacaoVitrine.maisRecentes,
  });

  final Cidade cidade;
  final String? busca;
  final OrdenacaoVitrine ordenacao;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsultaImoveis &&
          other.cidade == cidade &&
          other.busca == busca &&
          other.ordenacao == ordenacao);

  @override
  int get hashCode => Object.hash(cidade, busca, ordenacao);

  @override
  String toString() =>
      'ConsultaImoveis(cidade: $cidade, busca: $busca, ordenacao: $ordenacao)';
}
