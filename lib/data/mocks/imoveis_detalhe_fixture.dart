/// Id do último card de Vinhedo sob 'Mais recentes': o servidor simulado
/// sempre responde 404 para ele (imóvel despublicado, D-17). Determinístico
/// (D-15 da Fase 2) — dá para provar o fluxo "não está mais disponível" à mão.
const int idDetalheDespublicadoMock = 339;

/// Id do penúltimo card de Vinhedo sob 'Mais recentes': o detalhe existe no
/// servidor simulado, mas o mock sempre falha ao buscá-lo (D-17) — dá para
/// provar o fluxo de erro com "Tentar de novo" à mão.
const int idDetalheFalhaMock = 338;

/// Fixture do mock do detalhe do imóvel — servidor simulado em memória. Os
/// mapas ficam em forma de wire (snake_case), exatamente como chegariam de
/// `GET /api/publico/imoveis/{id}/`, para que `ImovelDetalheMockDataSource`
/// exercite o parsing real via `DetalheImovelModel.fromJson`.
///
/// Cada chamada devolve mapas novos, então nenhum teste muta o acervo de
/// outro.
///
/// O detalhe do id 42 concorda com a linha 42 verbatim de
/// `linhasAcervoFixture()` (título, finalidade, preço, descrição, bairro,
/// cidade e características) — a capa da lista é a primeira foto do detalhe.
Map<int, Map<String, Object?>> detalhesAcervoFixture() {
  const urlBase = 'https://api.imoveisaqui.exemplo.com/media/imoveis';
  return {
    42: {
      'id': 42,
      'titulo': 'Apartamento 2 quartos no Cambuí',
      'finalidade': 'VENDA',
      'preco_venda': '450000.00',
      'preco_aluguel': null,
      'preco_condominio': '850.00',
      'preco_iptu': '1200.00',
      'descricao':
          'Apartamento reformado, próximo ao centro, com varanda gourmet.',
      'bairro': 'Cambuí',
      'cidade': {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
      'latitude': '-22.894100',
      'longitude': '-47.052300',
      'fotos': [
        {'url': '$urlBase/fotos/capa-42.jpg', 'capa': true, 'ordem': 0},
        {'url': '$urlBase/fotos/sala-42.jpg', 'capa': false, 'ordem': 1},
        {'url': '$urlBase/fotos/varanda-42.jpg', 'capa': false, 'ordem': 2},
      ],
      'caracteristicas': [
        'Portão eletrônico',
        'Ar-condicionado',
        'Varanda gourmet',
      ],
      'corretor': {
        'id': 7,
        'nome': 'Marina Lopes',
        'foto': '$urlBase/corretores/marina-lopes.jpg',
        'slug': 'marina-lopes',
      },
      'natureza': 'APARTAMENTO',
      'casa': null,
      'terreno': null,
      'lote': null,
      'apartamento': {
        'andar': 8,
        'numero': '82',
        'area_privativa': '68.50',
        'area_total': '92.00',
        'quartos': 2,
        'suites': 1,
        'banheiros': 2,
        'vagas': 1,
        'varanda': true,
        'posicao_solar': 'Nascente',
        'predio': {
          'nome': 'Edifício Jequitibá',
          'andares': 15,
          'unidades_por_andar': 4,
          'ano': 2012,
          'elevadores': 2,
          'portaria_24h': true,
          'piscina': true,
          'academia': true,
          'salao_de_festas': true,
          'playground': false,
        },
      },
    },
  };
}
