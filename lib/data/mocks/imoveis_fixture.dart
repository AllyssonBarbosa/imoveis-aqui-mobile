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

/// Linhas do acervo, forma verbatim de `contrato/imoveis.example.json`
/// (ids 42 e 57 em Campinas; 63 em Valinhos). Indaiatuba sem linhas (D-15).
/// Plan 02-03 expande para ~40 linhas por cidade sem mudar esta assinatura.
List<Map<String, Object?>> linhasAcervoFixture() => [
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
