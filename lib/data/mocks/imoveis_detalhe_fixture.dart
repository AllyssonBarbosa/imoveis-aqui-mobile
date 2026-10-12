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
/// aleatório e nada lido do relógio (D-15 da Fase 2). Sempre traz as quatro
/// chaves de bloco de natureza, só a da natureza do card preenchida.
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

  final blocos = _blocosDeNatureza(linha, camposNulos: camposNulos);

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
    ...blocos,
  };
}

/// Blocos curados (sobrepostos ao gerado) que provam casos que a geração
/// por fórmula não cobre; cada chamada devolve mapas novos.
///
/// - 57: `area_livre` de 100,00 com terreno de 300,00 e construída de
///   180,00 — deliberadamente NÃO a diferença (120,00) — prova que o app
///   nunca calcula a área livre (D-04).
/// - 63: terreno aclive de 12 x 25.
/// - 103: o único lote com `preco` (a mesma string do `preco_venda` do card,
///   copiada aqui como valor do servidor simulado: nada a deriva em runtime,
///   D-19 d) e com condições de parcelamento, para exercitar o caminho
///   "mostra só se vier"; traz também a quadra B do Residencial Parque das
///   Flores.
Map<String, Object?>? _blocoCurado(int id) {
  return switch (id) {
    57 => {
      'area_terreno': '300.00',
      'area_construida': '180.00',
      'area_livre': '100.00',
      'quartos': 3,
      'suites': 0,
      'banheiros': 2,
      'salas': 2,
      'vagas': 2,
      'pavimentos': 1,
      'ano_construcao': 1998,
      'piscina': false,
      'quintal': true,
      'churrasqueira': true,
      'mobiliada': false,
    },
    63 => {
      'area_total': '300.00',
      'frente': '12.00',
      'fundo': '25.00',
      'laterais': '25.00',
      'topografia': 'ACLIVE',
      'murado': true,
      'esquina': false,
      'uso_permitido': 'Residencial',
    },
    103 => {
      'preco': '210500.50',
      'condicoes_parcelamento': 'Entrada de 20% e saldo em até 120 meses',
      'quadra': {
        'identificacao': 'Quadra B',
        'loteamento': {
          'nome': 'Residencial Parque das Flores',
          'incorporadora': 'Flores Urbanismo',
          'infraestrutura': [
            'Asfalto',
            'Água encanada',
            'Rede de esgoto',
            'Energia elétrica',
            'Iluminação pública',
          ],
          'areas_lazer': ['Praça', 'Playground', 'Quadra poliesportiva'],
        },
      },
    },
    _ => null,
  };
}

/// Rótulos de posição solar como a API os manda: texto legível, não código de
/// enum (D-19 b).
const List<String> _posicoesSolares = ['Nascente', 'Poente', 'Norte', 'Sul'];

const List<String> _topografias = ['PLANO', 'ACLIVE', 'DECLIVE'];

const List<String> _usosPermitidos = ['Residencial', 'Comercial', 'Misto'];

const List<String> _nomesDePredio = [
  'Edifício Aurora',
  'Residencial Vila Verde',
  'Edifício Solar das Palmeiras',
  'Condomínio Mirante do Parque',
];

const List<String> _nomesDeLoteamento = [
  'Loteamento Vale Verde',
  'Residencial Recanto das Águas',
  'Jardim Primavera',
];

const List<String> _incorporadoras = [
  'Vale Urbanismo',
  'Águas Empreendimentos',
  'Primavera Desenvolvimento Imobiliário',
];

const List<String> _infraestruturasDeLoteamento = [
  'Asfalto',
  'Água encanada',
  'Rede de esgoto',
  'Energia elétrica',
  'Iluminação pública',
  'Galeria de águas pluviais',
];

const List<String> _areasDeLazerDeLoteamento = [
  'Praça',
  'Playground',
  'Quadra poliesportiva',
  'Pista de caminhada',
  'Salão comunitário',
];

/// `quantidade` itens de [lista] a partir de [inicio], dando a volta no fim:
/// a "janela" fixa que varia de lote para lote sem usar aleatoriedade.
List<String> _janela(List<String> lista, int inicio, int quantidade) => [
  for (var i = 0; i < quantidade; i++) lista[(inicio + i) % lista.length],
];

/// As quatro chaves de bloco, só a da natureza do card preenchida. Valores
/// derivados do `id` e da linha da lista (quartos/suítes/vagas e área do card
/// são os mesmos — A8); `camposNulos` mantém o bloco com todo campo nulo
/// (D-14). Aqui, e só aqui, o servidor simulado calcula áreas.
Map<String, Object?> _blocosDeNatureza(
  Map<String, Object?> linha, {
  required bool camposNulos,
}) {
  final id = linha['id']! as int;
  final natureza = linha['natureza'] as String?;
  // Os ids gerados andam de 4 em 4 por natureza, então `id % 4` seria
  // constante; `id ~/ 4` varia entre linhas vizinhas da mesma natureza.
  final variante = id ~/ 4;

  final gerado = switch (natureza) {
    'CASA' => _blocoCasa(linha, variante),
    'APARTAMENTO' => _blocoApartamento(linha, variante),
    'TERRENO' => _blocoTerreno(linha, variante),
    'LOTE' => _blocoLote(linha, variante),
    _ => null,
  };
  final bloco = gerado == null
      ? null
      : {
          for (final campo in gerado.entries)
            campo.key: camposNulos ? null : campo.value,
          ...?_blocoCurado(id),
        };

  return {
    'casa': natureza == 'CASA' ? bloco : null,
    'apartamento': natureza == 'APARTAMENTO' ? bloco : null,
    'terreno': natureza == 'TERRENO' ? bloco : null,
    'lote': natureza == 'LOTE' ? bloco : null,
  };
}

String? _decimal(double? valor) => valor?.toStringAsFixed(2);

Map<String, Object?> _blocoCasa(Map<String, Object?> linha, int variante) {
  final areaConstruida = _areaDoCard(linha);
  final pavimentos = 1 + variante % 3;
  final areaTerreno = areaConstruida == null ? null : areaConstruida * 1.8;
  // Área livre = terreno menos a projeção da construção (que ocupa só um
  // pavimento), calculada AQUI no servidor simulado.
  final areaLivre = areaTerreno == null
      ? null
      : areaTerreno - areaConstruida! / pavimentos;
  return {
    'area_terreno': _decimal(areaTerreno),
    'area_construida': linha['area'],
    'area_livre': _decimal(areaLivre),
    'quartos': linha['quartos'],
    'suites': linha['suites'],
    'banheiros': 1 + variante % 4,
    'salas': 1 + variante % 3,
    'vagas': linha['vagas'],
    'pavimentos': pavimentos,
    'ano_construcao': 1985 + variante % 40,
    'piscina': variante % 3 == 0,
    'quintal': variante % 2 == 0,
    'churrasqueira': variante % 5 < 2,
    'mobiliada': variante % 4 == 0,
  };
}

Map<String, Object?> _blocoApartamento(
  Map<String, Object?> linha,
  int variante,
) {
  final andar = 1 + variante % 20;
  final areaPrivativa = _areaDoCard(linha);
  return {
    'andar': andar,
    'numero': '${andar}0${1 + variante % 4}',
    'area_privativa': linha['area'],
    'area_total': _decimal(areaPrivativa == null ? null : areaPrivativa * 1.35),
    'quartos': linha['quartos'],
    'suites': linha['suites'],
    'banheiros': 1 + variante % 3,
    'vagas': linha['vagas'],
    'varanda': variante % 2 == 0,
    'posicao_solar': _posicoesSolares[variante % _posicoesSolares.length],
    'predio': _predioGerado(variante),
  };
}

/// Prédio do apartamento: nome de uma lista fixa de quatro, números e flags
/// derivados da variante. Os apartamentos gerados têm sempre id par, então
/// nunca caem no caso `id % 10 == 9` (bloco todo nulo): o prédio ausente é
/// provado pelo Model, não pela fixture.
Map<String, Object?> _predioGerado(int variante) {
  return {
    'nome': _nomesDePredio[variante % _nomesDePredio.length],
    'andares': 8 + variante % 12,
    'unidades_por_andar': 2 + variante % 4,
    'ano': 1995 + variante % 30,
    'elevadores': 1 + variante % 3,
    'portaria_24h': variante % 2 == 0,
    'piscina': variante % 3 == 0,
    'academia': variante % 4 < 2,
    'salao_de_festas': variante % 5 != 0,
    'playground': variante % 2 == 1,
  };
}

Map<String, Object?> _blocoTerreno(Map<String, Object?> linha, int variante) {
  final fundo = 20 + (variante % 6) * 2.5;
  return {
    'area_total': linha['area'],
    'frente': _decimal(8.0 + (variante % 5) * 2),
    'fundo': _decimal(fundo),
    'laterais': _decimal(fundo),
    'topografia': _topografias[variante % _topografias.length],
    'murado': variante % 2 == 0,
    'esquina': variante % 5 == 0,
    'uso_permitido': _usosPermitidos[variante % _usosPermitidos.length],
  };
}

/// O preço do lote vive na parte comum do detalhe (`preco_venda` /
/// `preco_aluguel`): `preco` e `condicoes_parcelamento` ficam nulos (D-19 d).
Map<String, Object?> _blocoLote(Map<String, Object?> linha, int variante) {
  return {
    'numero': '${1 + variante % 30}',
    'area': linha['area'],
    'frente': _decimal(10.0 + (variante % 4) * 2.5),
    'fundo': _decimal(25.0 + (variante % 3) * 5),
    'preco': null,
    'condicoes_parcelamento': null,
    'quadra': _quadraGerada(variante),
  };
}

/// Quadra e loteamento embutidos: nome e incorporadora das listas fixas por
/// `variante % 3`, infraestrutura e lazer como janelas das listas fixas.
Map<String, Object?> _quadraGerada(int variante) {
  return {
    'identificacao': 'Quadra ${'ABCDEF'[variante % 6]}',
    'loteamento': {
      'nome': _nomesDeLoteamento[variante % 3],
      'incorporadora': _incorporadoras[variante % 3],
      'infraestrutura': _janela(
        _infraestruturasDeLoteamento,
        variante % 6,
        3 + variante % 3,
      ),
      'areas_lazer': _janela(
        _areasDeLazerDeLoteamento,
        variante % 5,
        2 + variante % 2,
      ),
    },
  };
}

/// Área do card como número, só para o servidor simulado derivar outras
/// áreas; `null` quando o card não tem área.
double? _areaDoCard(Map<String, Object?> linha) {
  final area = linha['area'] as String?;
  return area == null ? null : double.parse(area);
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
