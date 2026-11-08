import 'imoveis_fixture.dart' show urlBaseFotosMock;

/// Perfis públicos dos corretores no wire exato da WEB 02
/// (`GET /api/publico/corretores/{id}/`), por id. Dev-only: os ids batem com
/// os corretores do mock do detalhe do imóvel (7, 8 e 9, D-03), então nenhum
/// toque num corretor regular cai em "não encontrado".
///
/// Devolve mapas NOVOS a cada chamada, para que nenhum teste mute os dados de
/// outro. Toda entrada traz exatamente as nove chaves do wire; o que o
/// anunciante deixou em branco no site chega como `""` ou `null`, e a
/// normalização é do Model, nunca daqui.
Map<int, Map<String, Object?>> corretoresPerfisFixture() => {
  7: {
    'id': 7,
    'empresa_id': 3,
    'foto': '$urlBaseFotosMock/corretor-7/200/200',
    'nome': 'Marina Lopes',
    'email': 'marina.lopes@jequitiba.exemplo.com',
    'creci': '12345-F',
    'telefone': '(19) 3333-4444',
    'whatsapp': '19999998888',
    'apresentacao':
        'Corretora há 10 anos em Campinas, especialista em apartamentos no '
        'Cambuí e no Taquaral.',
  },
  8: {
    'id': 8,
    'empresa_id': 3,
    'foto': '$urlBaseFotosMock/corretor-8/200/200',
    'nome': 'Rafael Prado',
    'email': 'rafael.prado@jequitiba.exemplo.com',
    'creci': '23456-F',
    'telefone': '(19) 3333-5555',
    'whatsapp': '19988887777',
    'apresentacao': 'Atende Valinhos e Vinhedo, com foco em casas e terrenos.',
  },
  // Autônoma com campos vazios: a herança da empresa já foi resolvida pelo
  // servidor (Usuario.dados_perfil_publico); o app mostra só o que chegou.
  9: {
    'id': 9,
    'empresa_id': 4,
    'foto': null,
    'nome': 'Camila Duarte',
    'email': 'camila.duarte@exemplo.com',
    'creci': '34567-F',
    'telefone': '',
    'whatsapp': '19977776666',
    'apresentacao': '',
  },
  // Corretor válido sem nenhum imóvel no acervo (nenhum detalhe o carrega):
  // prova a vitrine vazia do anunciante (D-12) pela pilha real.
  10: {
    'id': 10,
    'empresa_id': 3,
    'foto': '$urlBaseFotosMock/corretor-10/200/200',
    'nome': 'Bruno Sales',
    'email': 'bruno.sales@jequitiba.exemplo.com',
    'creci': '45678-F',
    'telefone': '(19) 3333-6666',
    'whatsapp': '19966665555',
    'apresentacao':
        'Chegou à equipe da Jequitibá este mês; ainda sem imóveis anunciados.',
  },
};
