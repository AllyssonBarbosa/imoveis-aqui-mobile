import '../../core/texto_normalizado.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/entities/ordenacao_vitrine.dart';

// Único lugar do app que conhece os nomes dos parâmetros de consulta da
// lista pública (W09, D-12): traduz [ConsultaImoveis] para o que vai na URL
// e nada mais. Não há inverso — filtrar, ordenar e paginar é trabalho do
// servidor (FIL-05); o app só envia a consulta e mostra a resposta.

/// Caminho da lista pública de imóveis de uma cidade (W09): a cidade vai no
/// caminho, pelo id da API, nunca como query param (D-12, A-01).
String caminhoImoveisDaCidade(int cidadeId) =>
    '/api/publico/cidades/$cidadeId/imoveis/';

/// Mapeia [ConsultaImoveis] para os query params da API real (W09, D-12).
/// `ordenar` sempre; `busca` só quando não vazia após `trim`; cada filtro de
/// [FiltrosVitrine] só aparece quando o campo está ativo (Set vazio e campo
/// nulo não geram chave). Não há `cidade`: o id já vai em
/// [caminhoImoveisDaCidade]. `caracteristicas` viaja por id, nunca por nome
/// (D-13): CSV dos ids em ordem crescente.
Map<String, String> parametrosDaApi(ConsultaImoveis consulta) {
  final params = <String, String>{
    'ordenar': _valorOrdenar(consulta.ordenacao),
  };
  final busca = consulta.busca?.trim();
  if (busca != null && busca.isNotEmpty) {
    params['busca'] = busca;
  }
  final filtros = consulta.filtros;
  final finalidade = filtros.finalidade;
  if (finalidade != null) {
    params['finalidade'] = switch (finalidade) {
      FinalidadeFiltro.venda => 'VENDA',
      FinalidadeFiltro.aluguel => 'ALUGUEL',
    };
  }
  if (filtros.naturezas.isNotEmpty) {
    // Ordem do ENUM, nunca a ordem de iteração do Set — a mesma escolha
    // sempre gera a mesma URL (D-07).
    params['natureza'] = NaturezaImovel.values
        .where(filtros.naturezas.contains)
        .map(_valorWireDaNatureza)
        .join(',');
  }
  final quartosMin = filtros.quartosMin;
  if (quartosMin != null) params['quartos'] = '$quartosMin';
  final suitesMin = filtros.suitesMin;
  if (suitesMin != null) params['suites'] = '$suitesMin';
  final vagasMin = filtros.vagasMin;
  if (vagasMin != null) params['vagas'] = '$vagasMin';
  if (filtros.bairros.isNotEmpty) {
    params['bairro'] = _paraCsvOrdenado(filtros.bairros);
  }
  if (filtros.caracteristicas.isNotEmpty) {
    // Só `int` de entidades já parseadas; ordem crescente para a mesma
    // seleção gerar sempre a mesma URL (D-07, D-13).
    final ids = [for (final c in filtros.caracteristicas) c.id]..sort();
    params['caracteristicas'] = ids.join(',');
  }
  final precoMin = filtros.precoMin;
  if (precoMin != null) params['preco_min'] = '$precoMin';
  final precoMax = filtros.precoMax;
  if (precoMax != null) params['preco_max'] = '$precoMax';
  final areaMin = filtros.areaMin;
  if (areaMin != null) params['area_min'] = '$areaMin';
  final areaMax = filtros.areaMax;
  if (areaMax != null) params['area_max'] = '$areaMax';
  return params;
}

/// Valor de `ordenar` da W09 para cada [OrdenacaoVitrine] (os rótulos da UI
/// não mudam).
String _valorOrdenar(OrdenacaoVitrine ordenacao) => switch (ordenacao) {
  OrdenacaoVitrine.maisRecentes => 'recentes',
  OrdenacaoVitrine.precoAsc => 'preco',
  OrdenacaoVitrine.precoDesc => '-preco',
  OrdenacaoVitrine.areaAsc => 'area',
  OrdenacaoVitrine.areaDesc => '-area',
};

/// Junta um `Set<String>` num CSV ordenado por [normalizarTexto] (nunca pela
/// ordem de iteração do `Set`), para o filtro de bairro (D-07) — a mesma
/// seleção sempre produz a mesma URL.
///
/// RISCO REGISTRADO (A-05, 05-04): uma vírgula dentro de um nome de bairro
/// quebraria o split feito pelo servidor; os dados reais não têm vírgula nos
/// nomes, mas um nome com vírgula precisaria de escape ou de um id.
String _paraCsvOrdenado(Set<String> valores) {
  final ordenados = valores.toList()
    ..sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
  return ordenados.join(',');
}

/// Valor de `natureza` da W09 de uma [NaturezaImovel] — tabela privada a
/// este arquivo, mesma disciplina de `ImovelModel._mapearNatureza` (cada
/// arquivo de `data/` guarda sua própria tradução wire<->domínio, nunca uma
/// tabela compartilhada entre camadas).
String _valorWireDaNatureza(NaturezaImovel natureza) => switch (natureza) {
  NaturezaImovel.casa => 'CASA',
  NaturezaImovel.apartamento => 'APARTAMENTO',
  NaturezaImovel.terreno => 'TERRENO',
  NaturezaImovel.lote => 'LOTE',
};
