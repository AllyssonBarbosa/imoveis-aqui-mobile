import 'imoveis_fixture.dart' show urlBaseFotosMock;

/// Id do corretor reservado e desativado: o servidor simulado SEMPRE responde
/// 404 para ele (D-15, PERF-05), mesmo que um mapa de teste o contenha. Fica
/// FORA de [corretoresPerfisFixture]. É alcançável à mão pelo imóvel
/// `idDetalheCorretorDesativadoMock` (antepenúltimo card de Vinhedo sob 'Mais
/// recentes'), cujo detalhe carrega este corretor — o perfil abre com a prévia
/// e troca para "Este corretor não está mais disponível".
const int idCorretorDesativadoMock = 99;

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

/// Perfis públicos das empresas no wire exato da WEB 02
/// (`GET /api/publico/empresas/{id}/`, `EmpresaPublicaSerializer`), por id.
/// Dev-only: a empresa 3 (IMOBILIARIA) é o `perfil_empresa.example.json` do
/// §12 do contrato e a empresa 4 (AUTONOMO) é a da corretora 9 — coerente com
/// a herança que o servidor faz para o autônomo, em que telefone e descrição
/// em branco chegam em branco. O app não completa nada.
///
/// Os `corretores_ativos` são montados a partir de [corretoresPerfisFixture]
/// (os corretores da fixture com aquela `empresa_id`, em ordem de id), nunca
/// copiados à mão, para não divergirem dos perfis dos corretores.
///
/// Devolve mapas NOVOS a cada chamada, para que nenhum teste mute os dados de
/// outro. Toda entrada traz exatamente as onze chaves do wire.
Map<int, Map<String, Object?>> empresasPerfisFixture() {
  final corretores = corretoresPerfisFixture();
  List<Map<String, Object?>> ativosDa(int empresaId) {
    final ids = [
      for (final entrada in corretores.entries)
        if (entrada.value['empresa_id'] == empresaId) entrada.key,
    ]..sort();
    return [for (final id in ids) corretores[id]!];
  }

  return {
    3: {
      'id': 3,
      'tipo': 'IMOBILIARIA',
      'razao_social_ou_nome': 'Imobiliária Jequitibá',
      'creci': 'J-1234',
      'telefone': '(19) 3333-0000',
      'whatsapp': '19988880000',
      'email': 'contato@jequitiba.exemplo.com',
      'descricao':
          'Imobiliária com 20 anos de atuação em Campinas, Valinhos e Vinhedo.',
      'logomarca': '$urlBaseFotosMock/empresa-3/300/300',
      'cidades_atuacao': [
        {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
        {'id': 2, 'nome': 'Valinhos', 'uf': 'SP'},
        {'id': 3, 'nome': 'Vinhedo', 'uf': 'SP'},
      ],
      'corretores_ativos': ativosDa(3),
    },
    // Autônoma: a empresa é a própria Camila; telefone e descrição vazios
    // porque o perfil dela também os tem vazios (herança resolvida no servidor).
    4: {
      'id': 4,
      'tipo': 'AUTONOMO',
      'razao_social_ou_nome': 'Camila Duarte',
      'creci': '34567-F',
      'telefone': '',
      'whatsapp': '19977776666',
      'email': 'contato@camiladuarte.exemplo.com',
      'descricao': '',
      'logomarca': null,
      'cidades_atuacao': [
        {'id': 3, 'nome': 'Vinhedo', 'uf': 'SP'},
      ],
      'corretores_ativos': ativosDa(4),
    },
  };
}
