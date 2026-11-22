import 'situacao_imovel.dart';

/// Parâmetros de uma consulta ao acervo do corretor (busca + situação) — a
/// única entrada que atravessa UseCase -> Repository -> DataSource. Nunca
/// carrega cursor de paginação. "Todas" é [situacao] nula (D-09); o filtro e a
/// busca são resolvidos no servidor.
class ConsultaAcervo {
  const ConsultaAcervo({this.busca = '', this.situacao});

  final String busca;
  final SituacaoImovel? situacao;

  /// Cópia com campos trocados. Como `situacao: null` significa "não mudar",
  /// [limparSituacao] volta para "Todas".
  ConsultaAcervo copyWith({
    String? busca,
    SituacaoImovel? situacao,
    bool limparSituacao = false,
  }) {
    return ConsultaAcervo(
      busca: busca ?? this.busca,
      situacao: limparSituacao ? null : (situacao ?? this.situacao),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsultaAcervo &&
          other.busca == busca &&
          other.situacao == situacao);

  @override
  int get hashCode => Object.hash(busca, situacao);

  @override
  String toString() => 'ConsultaAcervo(busca: $busca, situacao: $situacao)';
}
