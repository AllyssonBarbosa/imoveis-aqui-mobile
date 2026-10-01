import '../../core/texto_normalizado.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/imovel.dart';
import '../../domain/entities/ordenacao_vitrine.dart';

/// Caminho do endpoint público de imóveis (contrato §3, §5) — reaproveitado
/// tal e qual pela Fase 4 quando a DataSource remota substituir o mock
/// (API-04).
const String caminhoImoveisPublico = '/api/publico/imoveis/';

/// Mapeia [ConsultaImoveis] para os query params exatos do contrato (§5,
/// D-04 snake_case). `cidade` usa a chave natural `nome-uf` (§7.2 do
/// contrato, recomendação provisória — isolada aqui para trocar fácil se o
/// E2 decidir por `id`, CONTEXT discretion). `busca` só aparece quando a
/// consulta tem um termo não-vazio após `trim`. Params de filtro (D-01..D-06,
/// adendo ao contrato) só aparecem quando o respectivo campo de
/// [FiltrosVitrine] está ativo — cada filtro novo precisa estender esta
/// função e [filtrosDosParametros] simetricamente (o inverso exato).
Map<String, String> parametrosDaConsulta(ConsultaImoveis consulta) {
  final params = <String, String>{
    'cidade': '${consulta.cidade.nome}-${consulta.cidade.uf}',
    'ordenacao': consulta.ordenacao.valorApi,
  };
  final busca = consulta.busca?.trim();
  if (busca != null && busca.isNotEmpty) {
    params['busca'] = busca;
  }
  final finalidade = consulta.filtros.finalidade;
  if (finalidade != null) {
    params['finalidade'] = switch (finalidade) {
      FinalidadeFiltro.venda => 'VENDA',
      FinalidadeFiltro.aluguel => 'ALUGUEL',
    };
  }
  final naturezas = consulta.filtros.naturezas;
  if (naturezas.isNotEmpty) {
    // Ordem do ENUM, nunca a ordem de iteração do Set — a mesma escolha
    // sempre gera a mesma URL/cursor.
    params['natureza'] = NaturezaImovel.values
        .where(naturezas.contains)
        .map(valorWireDaNatureza)
        .join(',');
  }
  final quartosMin = consulta.filtros.quartosMin;
  if (quartosMin != null) params['quartos_min'] = '$quartosMin';
  final suitesMin = consulta.filtros.suitesMin;
  if (suitesMin != null) params['suites_min'] = '$suitesMin';
  final vagasMin = consulta.filtros.vagasMin;
  if (vagasMin != null) params['vagas_min'] = '$vagasMin';
  final bairros = consulta.filtros.bairros;
  if (bairros.isNotEmpty) params['bairro'] = _paraCsvOrdenado(bairros);
  final caracteristicas = consulta.filtros.caracteristicas;
  if (caracteristicas.isNotEmpty) {
    params['caracteristicas'] = _paraCsvOrdenado(caracteristicas);
  }
  final precoMin = consulta.filtros.precoMin;
  if (precoMin != null) params['preco_min'] = '$precoMin';
  final precoMax = consulta.filtros.precoMax;
  if (precoMax != null) params['preco_max'] = '$precoMax';
  final areaMin = consulta.filtros.areaMin;
  if (areaMin != null) params['area_min'] = '$areaMin';
  final areaMax = consulta.filtros.areaMax;
  if (areaMax != null) params['area_max'] = '$areaMax';
  return params;
}

/// Junta um `Set<String>` num CSV ordenado por [normalizarTexto] (nunca pela
/// ordem de iteração do `Set`), para bairro/características (D-06) — a
/// mesma seleção sempre produz a mesma URL/cursor.
///
/// RISCO REGISTRADO PARA O E2 (D-06, adendo §10 do contrato): uma vírgula
/// dentro de um nome de bairro ou característica quebraria este split — a
/// fixture desta fase garante que nenhum valor contém vírgula, mas dados
/// reais precisarão de escape ou de um identificador em vez do nome cru.
String _paraCsvOrdenado(Set<String> valores) {
  final ordenados = valores.toList()
    ..sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
  return ordenados.join(',');
}

/// Valor de wire (D-06) de uma [NaturezaImovel] — tabela PRIVADA a este
/// arquivo, mesma disciplina de `ImovelModel._mapearNatureza` (cada
/// arquivo de `data/` guarda sua própria tradução wire<->domínio, nunca uma
/// tabela compartilhada entre camadas). Exposta (não `_`-prefixada) só para
/// que [ImovelMockDataSource] compare a linha de wire contra o Set de
/// domínio sem duplicar esta tabela numa segunda cópia.
String valorWireDaNatureza(NaturezaImovel natureza) => switch (natureza) {
  NaturezaImovel.casa => 'CASA',
  NaturezaImovel.apartamento => 'APARTAMENTO',
  NaturezaImovel.terreno => 'TERRENO',
  NaturezaImovel.lote => 'LOTE',
};

/// Interpreta de volta o valor do param `cidade` (`nome-uf`) — quebra na
/// ÚLTIMA ocorrência de `-`, porque nomes de cidade podem conter hífen.
/// Lança [FormatException] para um valor sem separador (simula o 400 do
/// servidor para um param mal formado).
Cidade cidadeDoParametro(String valor) {
  final indice = valor.lastIndexOf('-');
  if (indice <= 0 || indice == valor.length - 1) {
    throw FormatException('parâmetro cidade inválido: $valor');
  }
  return Cidade(
    nome: valor.substring(0, indice),
    uf: valor.substring(indice + 1),
  );
}

/// Interpreta de volta o valor do param `ordenacao` — lança
/// [FormatException] para um valor desconhecido, simulando o 400 do
/// servidor (mesma disciplina de [cidadeDoParametro]).
OrdenacaoVitrine ordenacaoDoParametro(String valor) {
  for (final opcao in OrdenacaoVitrine.values) {
    if (opcao.valorApi == valor) return opcao;
  }
  throw FormatException('ordenacao desconhecida: $valor');
}

/// Interpreta de volta o valor do param `finalidade` — só aceita `VENDA` e
/// `ALUGUEL` (a UI do filtro nunca oferece `VENDA_E_ALUGUEL`, D-02); lança
/// [FormatException] para qualquer outro valor, incluindo `VENDA_E_ALUGUEL`
/// (mesma disciplina de [ordenacaoDoParametro]).
FinalidadeFiltro finalidadeDoParametro(String valor) {
  switch (valor) {
    case 'VENDA':
      return FinalidadeFiltro.venda;
    case 'ALUGUEL':
      return FinalidadeFiltro.aluguel;
    default:
      throw FormatException('finalidade de filtro desconhecida: $valor');
  }
}

/// Interpreta de volta o param `natureza` (CSV, D-06) — cada item precisa
/// bater com um dos 4 valores de wire conhecidos ([valorWireDaNatureza]);
/// item vazio (`'CASA,'`) ou valor desconhecido (`'CHALE'`) lança
/// [FormatException] (D-12, simulando o 400 do servidor), mesma disciplina
/// de [ordenacaoDoParametro].
Set<NaturezaImovel> naturezasDoParametro(String valor) {
  return listaDoParametro(valor).map((item) {
    for (final natureza in NaturezaImovel.values) {
      if (valorWireDaNatureza(natureza) == item) return natureza;
    }
    throw FormatException('natureza de filtro desconhecida: $item');
  }).toSet();
}

/// Interpreta de volta um param CSV genérico (`bairro`/`caracteristicas`,
/// D-06) — cada item recebe `trim`; item vazio (`'Cambuí,'`) ou o CSV
/// totalmente vazio (`''`) lança [FormatException] (D-12, simulando o 400 do
/// servidor). RISCO REGISTRADO PARA O E2 (adendo §10): uma vírgula dentro de
/// um nome quebraria este split — ver [_paraCsvOrdenado].
Set<String> listaDoParametro(String valor) {
  final itens = valor.split(',').map((item) => item.trim()).toList();
  if (itens.any((item) => item.isEmpty)) {
    throw FormatException('item vazio na lista de filtro: $valor');
  }
  return itens.toSet();
}

/// Núcleo compartilhado entre [minimoDoParametro] (limiar "N ou mais") e
/// [inteiroNaoNegativoDoParametro] (faixas de preço/área) — só aceita
/// inteiro não-negativo; lança [FormatException] para negativo, decimal ou
/// valor não-numérico (D-12, simulando o 400 do servidor). [rotulo] só muda
/// a mensagem da exceção.
int _inteiroNaoNegativo(String valor, String rotulo) {
  final numero = int.tryParse(valor);
  if (numero == null || numero < 0) {
    throw FormatException('$rotulo inválido: $valor');
  }
  return numero;
}

/// Interpreta de volta um param de limiar "N ou mais" (D-01,
/// `quartos_min`/`suites_min`/`vagas_min`) — ver [_inteiroNaoNegativo].
int minimoDoParametro(String valor) =>
    _inteiroNaoNegativo(valor, 'mínimo de filtro');

/// Interpreta de volta um param de faixa (D-09, `preco_min`/`preco_max`/
/// `area_min`/`area_max`) — valores inteiros não-negativos (reais/m² inteiros,
/// contrato §10 item 6); ver [_inteiroNaoNegativo].
int inteiroNaoNegativoDoParametro(String valor) =>
    _inteiroNaoNegativo(valor, 'valor de faixa de filtro');

/// Interpreta de volta os params de filtro do mapa de query params — inverso
/// exato da parte de filtros de [parametrosDaConsulta]. Cada filtro novo
/// precisa estender ESTA função e [parametrosDaConsulta] simetricamente
/// (RESEARCH Pattern 1), nunca só um dos dois.
///
/// Validações server-side desta fase (D-03, D-12, simulando o 400 real):
/// qualquer bound de preço (`preco_min`/`preco_max`) sem `finalidade` lança
/// [FormatException] — sem finalidade não há como saber se o bound compara
/// com `preco_venda` ou `preco_aluguel` (D-03); mínimo maior que máximo,
/// tanto em preço quanto em área, também lança (mínimo IGUAL ao máximo é
/// aceito — faixa de um único valor).
FiltrosVitrine filtrosDosParametros(Map<String, String> params) {
  final finalidadeParam = params['finalidade'];
  final naturezaParam = params['natureza'];
  final quartosMinParam = params['quartos_min'];
  final suitesMinParam = params['suites_min'];
  final vagasMinParam = params['vagas_min'];
  final bairroParam = params['bairro'];
  final caracteristicasParam = params['caracteristicas'];
  final precoMinParam = params['preco_min'];
  final precoMaxParam = params['preco_max'];
  final areaMinParam = params['area_min'];
  final areaMaxParam = params['area_max'];

  final precoMin = precoMinParam == null
      ? null
      : inteiroNaoNegativoDoParametro(precoMinParam);
  final precoMax = precoMaxParam == null
      ? null
      : inteiroNaoNegativoDoParametro(precoMaxParam);
  final areaMin = areaMinParam == null
      ? null
      : inteiroNaoNegativoDoParametro(areaMinParam);
  final areaMax = areaMaxParam == null
      ? null
      : inteiroNaoNegativoDoParametro(areaMaxParam);

  if ((precoMin != null || precoMax != null) && finalidadeParam == null) {
    throw const FormatException(
      'faixa de preço exige finalidade (D-03): preco_min/preco_max sem '
      'finalidade',
    );
  }
  if (precoMin != null && precoMax != null && precoMin > precoMax) {
    throw FormatException(
      'faixa de preço invertida: preco_min=$precoMin > preco_max=$precoMax',
    );
  }
  if (areaMin != null && areaMax != null && areaMin > areaMax) {
    throw FormatException(
      'faixa de área invertida: area_min=$areaMin > area_max=$areaMax',
    );
  }

  return FiltrosVitrine(
    finalidade: finalidadeParam == null
        ? null
        : finalidadeDoParametro(finalidadeParam),
    naturezas: naturezaParam == null
        ? const {}
        : naturezasDoParametro(naturezaParam),
    precoMin: precoMin,
    precoMax: precoMax,
    quartosMin: quartosMinParam == null
        ? null
        : minimoDoParametro(quartosMinParam),
    suitesMin: suitesMinParam == null
        ? null
        : minimoDoParametro(suitesMinParam),
    vagasMin: vagasMinParam == null ? null : minimoDoParametro(vagasMinParam),
    bairros: bairroParam == null ? const {} : listaDoParametro(bairroParam),
    areaMin: areaMin,
    areaMax: areaMax,
    caracteristicas: caracteristicasParam == null
        ? const {}
        : listaDoParametro(caracteristicasParam),
  );
}
