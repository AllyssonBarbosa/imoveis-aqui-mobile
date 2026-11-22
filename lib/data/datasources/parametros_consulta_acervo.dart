import '../../domain/entities/consulta_acervo.dart';
import '../../domain/entities/situacao_imovel.dart';

// Único lugar do app que conhece os nomes dos parâmetros de consulta do
// acervo do corretor (D-08, D-09): traduz [ConsultaAcervo] para o que vai na
// URL e nada mais. Não há inverso nem filtro local — buscar e filtrar por
// situação é trabalho do servidor (FIL-05).

/// Mapeia [ConsultaAcervo] para os query params de `GET /api/imoveis/`:
/// `busca` só quando não vazia depois do `trim`, e `situacao` só quando há
/// uma situação escolhida ("Todas" é situação nula e não gera chave, D-09).
Map<String, String> parametrosDaConsultaAcervo(ConsultaAcervo consulta) {
  final params = <String, String>{};
  final busca = consulta.busca.trim();
  if (busca.isNotEmpty) params['busca'] = busca;
  final situacao = consulta.situacao;
  if (situacao != null) params['situacao'] = codigoDaSituacao(situacao);
  return params;
}

/// Código de `situacao` do Django para cada [SituacaoImovel] (`switch`
/// exaustivo: uma situação nova no enum quebra a compilação aqui).
String codigoDaSituacao(SituacaoImovel situacao) => switch (situacao) {
  SituacaoImovel.disponivel => 'DISPONIVEL',
  SituacaoImovel.reservado => 'RESERVADO',
  SituacaoImovel.vendido => 'VENDIDO',
  SituacaoImovel.alugado => 'ALUGADO',
};
