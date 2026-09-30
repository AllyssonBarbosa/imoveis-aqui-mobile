import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/filtros_vitrine.dart';
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
  return params;
}

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

/// Interpreta de volta os params de filtro do mapa de query params — inverso
/// exato da parte de filtros de [parametrosDaConsulta]. Hoje só `finalidade`
/// (D-02); cada filtro novo precisa estender ESTA função e
/// [parametrosDaConsulta] simetricamente (RESEARCH Pattern 1), nunca só um
/// dos dois.
FiltrosVitrine filtrosDosParametros(Map<String, String> params) {
  final finalidadeParam = params['finalidade'];
  return FiltrosVitrine(
    finalidade: finalidadeParam == null
        ? null
        : finalidadeDoParametro(finalidadeParam),
  );
}
