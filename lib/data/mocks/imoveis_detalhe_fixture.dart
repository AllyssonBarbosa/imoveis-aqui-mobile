import 'imoveis_fixture.dart';

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
/// O detalhe do id 42 é o exemplo do §11 verbatim e concorda com a linha 42
/// de `linhasAcervoFixture()` (título, finalidade, preço, descrição, bairro,
/// cidade e características) — a capa da lista é a primeira foto do detalhe.
/// Todas as demais linhas da lista, exceto [idDetalheDespublicadoMock],
/// ganham um detalhe gerado por `_detalheGerado`, de modo que todo card da
/// vitrine abre uma página real. Dados do servidor simulado (dev-only: saem
/// junto com o mock na Fase 5).
Map<int, Map<String, Object?>> detalhesAcervoFixture() {
  const urlBase = 'https://api.imoveisaqui.exemplo.com/media/imoveis';
  final detalhes = <int, Map<String, Object?>>{
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
  for (final linha in linhasAcervoFixture()) {
    final id = linha['id']! as int;
    if (id == idDetalheDespublicadoMock || detalhes.containsKey(id)) continue;
    detalhes[id] = _detalheGerado(linha);
  }
  return detalhes;
}

/// Corretores fixos do servidor simulado, escolhidos por `id % 3`. O terceiro
/// não tem foto nem slug: o slug é PENDENTE E2 e o app precisa tolerá-lo
/// ausente (D-19 a).
const List<Map<String, Object?>> _corretoresMock = [
  {
    'id': 7,
    'nome': 'Marina Lopes',
    'foto': '$urlBaseFotosMock/corretor-7/200/200',
    'slug': 'marina-lopes',
  },
  {
    'id': 8,
    'nome': 'Rafael Prado',
    'foto': '$urlBaseFotosMock/corretor-8/200/200',
    'slug': 'rafael-prado',
  },
  {'id': 9, 'nome': 'Camila Duarte', 'foto': null, 'slug': null},
];

/// Centro aproximado de cada cidade atendida (latitude, longitude), por id.
const Map<int, (double, double)> _centroDaCidade = {
  1: (-22.9056, -47.0608),
  2: (-22.9707, -46.9958),
  3: (-23.0297, -46.9753),
};

/// Monta, a partir de uma linha da lista, o detalhe em forma de wire. Os
/// campos comuns são copiados da linha (nunca de uma lista paralela, A8) e só
/// o que a lista não tem é acrescentado — tudo derivado do `id`, nada
/// aleatório e nada lido do relógio (D-15 da Fase 2). Sem blocos de natureza.
Map<String, Object?> _detalheGerado(Map<String, Object?> linha) {
  final id = linha['id']! as int;
  final natureza = linha['natureza'] as String?;
  final cidade = Map<String, Object?>.of(
    linha['cidade']! as Map<String, Object?>,
  );
  final fotoCapa = linha['foto_capa'] as String?;

  // `id % 10 == 9`: o caso "campos nulos" (sem condomínio, IPTU, coordenadas
  // nem corretor).
  final camposNulos = id % 10 == 9;

  final temCondominio =
      natureza == 'APARTAMENTO' || (natureza == 'CASA' && id % 3 == 0);
  final precoCondominio = camposNulos || !temCondominio
      ? null
      : (300 + (id % 17) * 25).toStringAsFixed(2);
  final precoIptu = camposNulos
      ? null
      : (600 + (id % 23) * 40).toStringAsFixed(2);

  final centro = _centroDaCidade[cidade['id']];
  final deslocamento = (id % 50) * 0.0004;
  final latitude = camposNulos || centro == null
      ? null
      : (centro.$1 + deslocamento).toStringAsFixed(6);
  final longitude = camposNulos || centro == null
      ? null
      : (centro.$2 + deslocamento).toStringAsFixed(6);

  final corretor = camposNulos
      ? null
      : Map<String, Object?>.of(_corretoresMock[id % _corretoresMock.length]);

  return {
    'id': id,
    'titulo': linha['titulo'],
    'finalidade': linha['finalidade'],
    'preco_venda': linha['preco_venda'],
    'preco_aluguel': linha['preco_aluguel'],
    'preco_condominio': precoCondominio,
    'preco_iptu': precoIptu,
    'descricao': linha['descricao'],
    'bairro': linha['bairro'],
    'cidade': cidade,
    'latitude': latitude,
    'longitude': longitude,
    'fotos': _fotosGeradas(id, fotoCapa),
    'caracteristicas': List<Object?>.of(
      linha['caracteristicas']! as List<Object?>,
    ),
    'corretor': corretor,
    'natureza': natureza,
  };
}

/// Fotos da galeria: vazia quando o card não tem capa; senão a capa do card
/// (ordem 0) seguida de `id % 4` fotos extras.
List<Map<String, Object?>> _fotosGeradas(int id, String? fotoCapa) {
  if (fotoCapa == null) return <Map<String, Object?>>[];
  return [
    {'url': fotoCapa, 'capa': true, 'ordem': 0},
    for (var n = 1; n <= id % 4; n++)
      {
        'url': '$urlBaseFotosMock/imovel-$id-$n/1200/800',
        'capa': false,
        'ordem': n,
      },
  ];
}
