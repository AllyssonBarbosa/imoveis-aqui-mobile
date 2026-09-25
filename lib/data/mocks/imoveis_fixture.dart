/// Fixture do mock de imóveis (D-14) — servidor simulado em memória. As
/// linhas ficam em forma de wire (snake_case), exatamente como chegariam de
/// `GET /imoveis`, para que `ImovelMockDataSource` exercite o parsing real
/// via `ImoveisEnvelopeModel.fromJson`.
///
/// As 4 cidades espelham `contrato/cidades.example.json`. Indaiatuba fica
/// intencionalmente sem nenhuma linha no acervo (D-15) — exercita o estado
/// vazio determinístico, nunca aleatório.
const List<Map<String, Object?>> cidadesDoFixture = [
  {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
  {'id': 2, 'nome': 'Valinhos', 'uf': 'SP'},
  {'id': 3, 'nome': 'Vinhedo', 'uf': 'SP'},
  {'id': 4, 'nome': 'Indaiatuba', 'uf': 'SP'},
];

/// Base das URLs de foto de capa geradas (dev-only, D-14) — uma única
/// constante trocável em uma linha; removida por inteiro na Fase 4 junto com
/// o resto do mock.
const String urlBaseFotosMock = 'https://picsum.photos/seed';

/// As 3 linhas verbatim de `contrato/imoveis.example.json` (ids 42 e 57 em
/// Campinas; 63 em Valinhos) — nunca alteradas pela expansão do acervo.
const List<Map<String, Object?>> _linhasVerbatimDoContrato = [
  {
    'id': 42,
    'titulo': 'Apartamento 2 quartos no Cambuí',
    'finalidade': 'VENDA',
    'preco_venda': '450000.00',
    'preco_aluguel': null,
    'descricao':
        'Apartamento reformado, próximo ao centro, com varanda gourmet.',
    'bairro': 'Cambuí',
    'cidade': {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
    'foto_capa':
        'https://api.imoveisaqui.exemplo.com/media/imoveis/fotos/capa-42.jpg',
    'caracteristicas': [
      'Portão eletrônico',
      'Ar-condicionado',
      'Varanda gourmet',
    ],
    'criado_em': '2026-08-14T10:32:00Z',
    'natureza': 'APARTAMENTO',
    'quartos': 2,
    'suites': 1,
    'vagas': 1,
    'area': '68.50',
  },
  {
    'id': 57,
    'titulo': 'Casa térrea 3 quartos no Taquaral',
    'finalidade': 'ALUGUEL',
    'preco_venda': null,
    'preco_aluguel': '3200.00',
    'descricao':
        'Casa térrea com quintal amplo, próxima à Lagoa do Taquaral.',
    'bairro': 'Taquaral',
    'cidade': {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
    'foto_capa':
        'https://api.imoveisaqui.exemplo.com/media/imoveis/fotos/capa-57.jpg',
    'caracteristicas': ['Quintal', 'Churrasqueira'],
    'criado_em': '2026-08-10T09:15:00Z',
    'natureza': 'CASA',
    'quartos': 3,
    'suites': 0,
    'vagas': 2,
    'area': '180.00',
  },
  {
    'id': 63,
    'titulo': 'Terreno no Loteamento Jardim das Palmeiras',
    'finalidade': 'VENDA_E_ALUGUEL',
    'preco_venda': '220000.00',
    'preco_aluguel': '1500.00',
    'descricao':
        'Terreno plano, pronto para construir, em condomínio fechado.',
    'bairro': 'Jardim das Palmeiras',
    'cidade': {'id': 2, 'nome': 'Valinhos', 'uf': 'SP'},
    'foto_capa': null,
    'caracteristicas': <String>[],
    'criado_em': '2026-07-30T16:40:00Z',
    'natureza': 'TERRENO',
    'quartos': 0,
    'suites': 0,
    'vagas': 0,
    'area': '300.00',
  },
];

const List<String> _bairrosCampinas = [
  'Cambuí',
  'Taquaral',
  'Barão Geraldo',
  'Centro',
  'Guanabara',
  'Nova Campinas',
  'Castelo',
  'Jardim Proença',
];

const List<String> _bairrosValinhos = [
  'Centro',
  'Jardim das Palmeiras',
  'Vila Santana',
  'Chácaras Alpina',
  'Jardim Pinheiros',
];

const List<String> _bairrosVinhedo = [
  'Centro',
  'Santa Rosa',
  'Jardim Nova Vinhedo',
  'Capela',
  'Vista Alegre',
];

const List<String> _naturezas = ['APARTAMENTO', 'CASA', 'TERRENO', 'LOTE'];

const List<String> _finalidades = ['VENDA', 'ALUGUEL', 'VENDA_E_ALUGUEL'];

const Map<String, String> _rotuloNatureza = {
  'APARTAMENTO': 'Apartamento',
  'CASA': 'Casa',
  'TERRENO': 'Terreno',
  'LOTE': 'Lote',
};

const List<String> _caracteristicasDisponiveis = [
  'Portão eletrônico',
  'Ar-condicionado',
  'Varanda gourmet',
  'Quintal',
  'Churrasqueira',
  'Piscina',
  'Elevador',
  'Área de serviço',
  'Armários planejados',
  'Vista para o parque',
];

const String _descricaoFixa =
    'Imóvel bem cuidado, pronto para morar, com ótima localização na '
    'região.';

/// Total de linhas por cidade ATENDIDA (Campinas/Valinhos/Vinhedo, D-14) —
/// Indaiatuba fica sem nenhuma (D-15).
const int _totalPorCidadeAtendida = 40;

/// Instante-base fixo (nunca lido do relógio do sistema, D-15) — anterior a
/// TODAS as datas das linhas verbatim (a mais antiga é
/// `2026-07-30T16:40:00Z`, id 63), para que as linhas verbatim sempre fiquem
/// à frente das geradas na ordenação por recência (`criado_em` desc) dentro
/// de cada cidade.
final DateTime _baseCriadoEm = DateTime.utc(2026, 7, 20);

/// Linhas do acervo — 40 imóveis para cada cidade atendida (Campinas id 1,
/// Valinhos id 2, Vinhedo id 3), nenhuma para Indaiatuba id 4 (D-15). As 3
/// linhas verbatim de `contrato/imoveis.example.json` são preservadas
/// exatamente e completadas por linhas geradas deterministicamente — nada
/// sorteado, nem lido do relógio do sistema (D-15). Determinístico: duas
/// chamadas produzem listas profundamente iguais.
List<Map<String, Object?>> linhasAcervoFixture() {
  // c=0 Campinas (id 1, 2 linhas verbatim: 42, 57)
  // c=1 Valinhos (id 2, 1 linha verbatim: 63)
  // c=2 Vinhedo (id 3, nenhuma linha verbatim)
  final verbatimPorCidade = <int, List<Map<String, Object?>>>{
    0: [_linhasVerbatimDoContrato[0], _linhasVerbatimDoContrato[1]],
    1: [_linhasVerbatimDoContrato[2]],
    2: <Map<String, Object?>>[],
  };

  final linhas = <Map<String, Object?>>[];
  for (var c = 0; c < 3; c++) {
    final verbatim = verbatimPorCidade[c]!;
    linhas.addAll(verbatim);
    final quantidadeGerada = _totalPorCidadeAtendida - verbatim.length;
    for (var k = 0; k < quantidadeGerada; k++) {
      linhas.add(_gerarLinha(cidadeIndice: c, indiceLocal: k));
    }
  }
  return linhas;
}

/// Gera uma linha determinística (id 100*(c+1)+k — nunca colide com 42/57/63,
/// que ficam abaixo de 100) para a cidade de índice `c` (0=Campinas,
/// 1=Valinhos, 2=Vinhedo) e índice local `k` dentro do conjunto gerado.
Map<String, Object?> _gerarLinha({
  required int cidadeIndice,
  required int indiceLocal,
}) {
  final k = indiceLocal;
  final id = 100 * (cidadeIndice + 1) + k;

  final natureza = _naturezas[k % _naturezas.length];
  final finalidade = _finalidades[k % _finalidades.length];
  final ehTerrenoOuLote = natureza == 'TERRENO' || natureza == 'LOTE';
  final quartos = ehTerrenoOuLote ? 0 : 1 + k % 4;
  final suites = quartos == 0 ? 0 : k % (quartos + 1);
  final vagas = k % 3;
  final area = k % 10 == 9 ? null : (50 + k * 3.25).toStringAsFixed(2);
  final fotoCapa = k % 5 == 4
      ? null
      : '$urlBaseFotosMock/imovel-$id/800/450';

  final bairros = switch (cidadeIndice) {
    0 => _bairrosCampinas,
    1 => _bairrosValinhos,
    _ => _bairrosVinhedo,
  };
  final bairro = bairros[k % bairros.length];

  final precoVenda = finalidade == 'ALUGUEL'
      ? null
      : _precoComCentavos(base: 200000, incremento: 3500, k: k);
  final precoAluguel = finalidade == 'VENDA'
      ? null
      : _precoComCentavos(base: 1200, incremento: 45, k: k);

  final rotulo = _rotuloNatureza[natureza]!;
  final titulo = quartos == 0
      ? '$rotulo no $bairro'
      : '$rotulo $quartos quartos no $bairro';

  final caracteristicas = _caracteristicasDisponiveis.sublist(
    0,
    1 + k % _caracteristicasDisponiveis.length,
  );

  final cidade = cidadesDoFixture[cidadeIndice];
  final criadoEm = _baseCriadoEm
      .subtract(Duration(hours: (cidadeIndice * 40 + k) * 5))
      .toIso8601String()
      .replaceFirst('.000Z', 'Z');

  return {
    'id': id,
    'titulo': titulo,
    'finalidade': finalidade,
    'preco_venda': precoVenda,
    'preco_aluguel': precoAluguel,
    'descricao': _descricaoFixa,
    'bairro': bairro,
    'cidade': cidade,
    'foto_capa': fotoCapa,
    'caracteristicas': caracteristicas,
    'criado_em': criadoEm,
    'natureza': natureza,
    'quartos': quartos,
    'suites': suites,
    'vagas': vagas,
    'area': area,
  };
}

/// Formata um valor decimal crescente com `k`; toda linha com `k % 7 == 3`
/// ganha 50 centavos (cobertura de "cents não-zero" exigida pelas regras de
/// comportamento da Task 1 do plano).
String _precoComCentavos({
  required int base,
  required int incremento,
  required int k,
}) {
  final valor = base + incremento * k;
  final centavos = k % 7 == 3 ? '50' : '00';
  return '$valor.$centavos';
}
