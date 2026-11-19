import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/dados_natureza.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/apresentacao_natureza.dart';

void main() {
  /// Valores de [Destaque] de uma natureza, na ordem, como `(valor, rótulo)`.
  List<(String, String)> destaquesComo(DadosNatureza dados) => [
    for (final destaque in destaquesDe(dados))
      (destaque.valor, destaque.rotulo),
  ];

  /// Linhas de [LinhaDado] de uma natureza, na ordem, como `(rótulo, valor)`.
  List<(String, String)> linhasComo(DadosNatureza dados) => [
    for (final linha in linhasDe(dados)) (linha.rotulo, linha.valor),
  ];

  group('formatarAreaM2', () {
    test('inteiro sem casas: "180.00" vira "180 m²"', () {
      expect(formatarAreaM2('180.00'), '180 m²');
    });

    test('vírgula decimal pt_BR: "68.50" vira "68,5 m²"', () {
      expect(formatarAreaM2('68.50'), '68,5 m²');
    });

    test('milhar pt_BR: "1234.56" vira "1.234,56 m²"', () {
      expect(formatarAreaM2('1234.56'), '1.234,56 m²');
    });

    test('texto não-parseável volta sem alteração, nunca lança', () {
      expect(formatarAreaM2('abc'), 'abc');
    });
  });

  group('formatarMedidaM', () {
    test('"12.00" vira "12 m"', () {
      expect(formatarMedidaM('12.00'), '12 m');
    });

    test('"10.50" vira "10,5 m"', () {
      expect(formatarMedidaM('10.50'), '10,5 m');
    });

    test('texto não-parseável volta sem alteração, nunca lança', () {
      expect(formatarMedidaM('xyz'), 'xyz');
    });
  });

  group('rótulos simples', () {
    test('rotuloTopografia em PT', () {
      expect(rotuloTopografia(Topografia.plano), 'Plano');
      expect(rotuloTopografia(Topografia.aclive), 'Aclive');
      expect(rotuloTopografia(Topografia.declive), 'Declive');
    });

    test('rotuloSimNao', () {
      expect(rotuloSimNao(true), 'Sim');
      expect(rotuloSimNao(false), 'Não');
    });

    test('tituloSecaoNatureza por variante', () {
      expect(tituloSecaoNatureza(const DadosNatureza.casa()), 'Sobre a casa');
      expect(
        tituloSecaoNatureza(const DadosNatureza.apartamento()),
        'Sobre o apartamento',
      );
      expect(
        tituloSecaoNatureza(const DadosNatureza.terreno()),
        'Sobre o terreno',
      );
      expect(tituloSecaoNatureza(const DadosNatureza.lote()), 'Sobre o lote');
    });
  });

  group('casa (imóvel 57)', () {
    const casa57 = DadosNatureza.casa(
      areaTerreno: '300.00',
      areaConstruida: '180.00',
      areaLivre: '100.00',
      quartos: 3,
      suites: 0,
      banheiros: 2,
      vagas: 2,
    );

    test('área livre chega como o servidor mandou (100 m²), nunca calculada (120 m²)', () {
      final linhas = linhasComo(casa57);

      expect(linhas, contains(('Área do terreno', '300 m²')));
      expect(linhas, contains(('Área construída', '180 m²')));
      expect(linhas, contains(('Área livre', '100 m²')));
      expect(
        linhasDe(casa57).where((linha) => linha.valor == '120 m²'),
        isEmpty,
        reason: 'o app não calcula 300 - 180 (D-04)',
      );
    });

    test('destaques: quartos, banheiros e vagas; suítes 0 é omitida', () {
      final destaques = destaquesComo(casa57);

      expect(destaques, contains(('3', 'quartos')));
      expect(destaques, contains(('2', 'banheiros')));
      expect(destaques, contains(('2', 'vagas')));
      expect(destaques.where((d) => d.$2.startsWith('suíte')), isEmpty);
    });

    test('rótulos no singular para 1', () {
      final destaques = destaquesComo(
        const DadosNatureza.casa(quartos: 1, suites: 1, banheiros: 1, vagas: 1),
      );

      expect(
        destaques,
        containsAll([
          ('1', 'quarto'),
          ('1', 'suíte'),
          ('1', 'banheiro'),
          ('1', 'vaga'),
        ]),
      );
    });

    test('linhas na ordem do plano, cada uma omitida quando nula', () {
      const completa = DadosNatureza.casa(
        areaTerreno: '300.00',
        areaConstruida: '180.00',
        areaLivre: '100.00',
        salas: 2,
        pavimentos: 2,
        anoConstrucao: 2015,
        piscina: true,
        quintal: true,
        churrasqueira: false,
        mobiliada: false,
      );

      expect(linhasDe(completa).map((linha) => linha.rotulo), [
        'Área do terreno',
        'Área construída',
        'Área livre',
        'Salas',
        'Pavimentos',
        'Ano de construção',
        'Piscina',
        'Quintal',
        'Churrasqueira',
        'Mobiliada',
      ]);
      expect(linhasComo(completa), contains(('Ano de construção', '2015')));
      expect(linhasComo(completa), contains(('Piscina', 'Sim')));
      expect(linhasComo(completa), contains(('Churrasqueira', 'Não')));
    });

    test('tudo nulo: sem destaques e sem linhas', () {
      const vazia = DadosNatureza.casa();

      expect(destaquesDe(vazia), isEmpty);
      expect(linhasDe(vazia), isEmpty);
    });
  });

  test('rotuloPosicaoSolar e rotuloUsoPermitido traduzem os códigos da API', () {
    expect(rotuloPosicaoSolar('NASCENTE'), 'Nascente');
    expect(rotuloPosicaoSolar('SUL'), 'Sul');
    expect(rotuloPosicaoSolar('OESTE'), 'OESTE');
    expect(rotuloUsoPermitido('MISTO'), 'Misto');
    expect(rotuloUsoPermitido('RURAL'), 'Rural');
    expect(rotuloUsoPermitido('XPTO'), 'XPTO');
  });

  group('terreno (imóvel 63)', () {
    const terreno63 = DadosNatureza.terreno(
      areaTotal: '300.00',
      frente: '12.00',
      fundo: '25.00',
      lateralEsquerda: '25.00',
      lateralDireita: '24.50',
      topografia: Topografia.aclive,
      murado: true,
      esquina: false,
      usoPermitido: 'RESIDENCIAL',
    );

    test('destaques: área, frente e fundo formatados', () {
      expect(destaquesComo(terreno63), [
        ('300 m²', 'área'),
        ('12 m', 'frente'),
        ('25 m', 'fundo'),
      ]);
    });

    test('linhas: duas laterais, topografia em PT, murado, esquina, uso', () {
      final linhas = linhasComo(terreno63);

      expect(linhas, contains(('Lateral esquerda', '25 m')));
      expect(linhas, contains(('Lateral direita', '24,5 m')));
      expect(linhas.map((linha) => linha.$1), isNot(contains('Laterais')));
      expect(linhas, contains(('Topografia', 'Aclive')));
      expect(linhas, contains(('Murado', 'Sim')));
      expect(linhas, contains(('Esquina', 'Não')));
      expect(linhas, contains(('Uso permitido', 'Residencial')));
    });

    test('lateral nula omite só a sua linha; nada é somado', () {
      expect(
        linhasComo(const DadosNatureza.terreno(lateralDireita: '25.00')),
        [('Lateral direita', '25 m')],
      );
      expect(
        linhasComo(const DadosNatureza.terreno(lateralEsquerda: '25.00')),
        [('Lateral esquerda', '25 m')],
      );
    });

    test('uso permitido: código vira rótulo, desconhecido sai como veio, '
        'nulo e em branco omitem a linha (A-04)', () {
      List<(String, String)> usoCom(String? codigo) => linhasComo(
        DadosNatureza.terreno(usoPermitido: codigo),
      );

      expect(usoCom('RESIDENCIAL'), [('Uso permitido', 'Residencial')]);
      expect(usoCom('COMERCIAL'), [('Uso permitido', 'Comercial')]);
      expect(usoCom('MISTO'), [('Uso permitido', 'Misto')]);
      expect(usoCom('INDUSTRIAL'), [('Uso permitido', 'Industrial')]);
      expect(usoCom('RURAL'), [('Uso permitido', 'Rural')]);
      expect(usoCom('XPTO'), [('Uso permitido', 'XPTO')]);
      expect(usoCom(''), isEmpty);
      expect(usoCom('   '), isEmpty);
      expect(usoCom(null), isEmpty);
    });

    test('tudo nulo: sem destaques e sem linhas', () {
      const vazio = DadosNatureza.terreno();

      expect(destaquesDe(vazio), isEmpty);
      expect(linhasDe(vazio), isEmpty);
    });
  });

  group('apartamento (imóvel 42)', () {
    const apto42 = DadosNatureza.apartamento(
      andar: 8,
      areaPrivativa: '68.50',
      areaTotal: '92.00',
      quartos: 2,
      suites: 1,
      banheiros: 2,
      vagas: 1,
      varanda: true,
      posicaoSolar: 'NASCENTE',
    );

    test('destaques: quartos, suíte, banheiros e vaga', () {
      expect(destaquesComo(apto42), [
        ('2', 'quartos'),
        ('1', 'suíte'),
        ('2', 'banheiros'),
        ('1', 'vaga'),
      ]);
    });

    test('linhas: andar, áreas, varanda e posição solar, sem "Unidade"', () {
      final linhas = linhasComo(apto42);

      expect(linhas, contains(('Andar', '8º')));
      expect(linhas.map((linha) => linha.$1), isNot(contains('Unidade')));
      expect(linhas, contains(('Área privativa', '68,5 m²')));
      expect(linhas, contains(('Área total', '92 m²')));
      expect(linhas, contains(('Varanda', 'Sim')));
      expect(linhas, contains(('Posição solar', 'Nascente')));
    });

    test('posição solar: código vira rótulo, desconhecido sai como veio, '
        'vazio omite a linha (A-04)', () {
      List<(String, String)> solCom(String? codigo) =>
          linhasComo(DadosNatureza.apartamento(posicaoSolar: codigo));

      expect(solCom('NASCENTE'), [('Posição solar', 'Nascente')]);
      expect(solCom('POENTE'), [('Posição solar', 'Poente')]);
      expect(solCom('NORTE'), [('Posição solar', 'Norte')]);
      expect(solCom('SUL'), [('Posição solar', 'Sul')]);
      expect(solCom('Sol da manhã'), [('Posição solar', 'Sol da manhã')]);
      expect(solCom(''), isEmpty);
      expect(solCom('  '), isEmpty);
    });

    test('posição solar nula não gera linha', () {
      expect(
        linhasDe(const DadosNatureza.apartamento())
            .where((linha) => linha.rotulo == 'Posição solar'),
        isEmpty,
      );
    });

    test('tudo nulo: sem destaques e sem linhas', () {
      const vazio = DadosNatureza.apartamento();

      expect(destaquesDe(vazio), isEmpty);
      expect(linhasDe(vazio), isEmpty);
    });
  });

  group('lote', () {
    test('linhas: número, entrada mínima em moeda, parcelas e condições', () {
      const lote = DadosNatureza.lote(
        numero: '12',
        area: '250.00',
        frente: '10.00',
        fundo: '25.00',
        entradaMinima: '23500.00',
        parcelasMaximas: 120,
        condicoesParcelamento: 'Entrada de 20% e 120 parcelas',
      );

      expect(destaquesComo(lote), [
        ('250 m²', 'área'),
        ('10 m', 'frente'),
        ('25 m', 'fundo'),
      ]);
      expect(linhasDe(lote).map((linha) => linha.rotulo), [
        'Número do lote',
        'Entrada mínima',
        'Parcelas máximas',
        'Condições de parcelamento',
      ]);
      expect(linhasComo(lote), contains(('Número do lote', '12')));
      expect(
        linhasComo(lote),
        contains(('Entrada mínima', 'R\$\u00A023.500')),
      );
      expect(linhasComo(lote), contains(('Parcelas máximas', '120')));
      expect(
        linhasComo(lote),
        contains((
          'Condições de parcelamento',
          'Entrada de 20% e 120 parcelas',
        )),
      );
    });

    test('a linha "Preço do lote" não existe mais (§11.5 d)', () {
      const lote = DadosNatureza.lote(
        numero: '7',
        area: '300.00',
        entradaMinima: '1000.00',
        parcelasMaximas: 12,
      );

      expect(
        linhasDe(lote).where((linha) => linha.rotulo == 'Preço do lote'),
        isEmpty,
      );
    });

    test('campos de parcelamento nulos não geram linha', () {
      const lote = DadosNatureza.lote(numero: '7', area: '300.00');

      expect(linhasComo(lote), [('Número do lote', '7')]);
    });

    test('tudo nulo: sem destaques e sem linhas', () {
      const vazio = DadosNatureza.lote();

      expect(destaquesDe(vazio), isEmpty);
      expect(linhasDe(vazio), isEmpty);
    });
  });

  group('linhasDoPredio', () {
    test('ordem do plano, booleanos como Sim/Não', () {
      const predio = DadosPredio(
        nome: 'Edifício Jequitibá',
        andares: 12,
        anoConstrucao: 2018,
        elevadores: 2,
        portaria24h: true,
        piscina: false,
        academia: true,
        salaoDeFestas: true,
        playground: false,
      );

      expect(linhasDoPredio(predio).map((linha) => linha.rotulo), [
        'Nome',
        'Andares',
        'Ano de construção',
        'Elevadores',
        'Portaria 24h',
        'Piscina',
        'Academia',
        'Salão de festas',
        'Playground',
      ]);
      final linhas = [
        for (final linha in linhasDoPredio(predio)) (linha.rotulo, linha.valor),
      ];
      expect(linhas, contains(('Nome', 'Edifício Jequitibá')));
      expect(linhas, contains(('Ano de construção', '2018')));
      expect(linhas.map((linha) => linha.$1), isNot(contains('Unidades por andar')));
      expect(linhas, contains(('Portaria 24h', 'Sim')));
      expect(linhas, contains(('Piscina', 'Não')));
    });

    test('campos nulos não geram linha; tudo nulo resulta em lista vazia', () {
      expect(linhasDoPredio(const DadosPredio(nome: 'Torre Norte')), [
        (rotulo: 'Nome', valor: 'Torre Norte'),
      ]);
      expect(linhasDoPredio(const DadosPredio()), isEmpty);
    });
  });

  group('linhasDaQuadra', () {
    test('quadra, loteamento e incorporadora, nulos omitidos', () {
      const quadra = DadosQuadra(
        identificacao: 'Quadra B',
        loteamento: DadosLoteamento(
          nome: 'Residencial Parque das Flores',
          incorporadora: 'Flores Urbanismo',
        ),
      );

      expect(linhasDaQuadra(quadra), [
        (rotulo: 'Quadra', valor: 'Quadra B'),
        (rotulo: 'Loteamento', valor: 'Residencial Parque das Flores'),
        (rotulo: 'Incorporadora', valor: 'Flores Urbanismo'),
      ]);
      expect(linhasDaQuadra(const DadosQuadra(identificacao: 'Quadra C')), [
        (rotulo: 'Quadra', valor: 'Quadra C'),
      ]);
      expect(linhasDaQuadra(const DadosQuadra()), isEmpty);
    });
  });

  group('quadraTemConteudo', () {
    test('vazio quando não há linha, infraestrutura nem áreas de lazer', () {
      expect(quadraTemConteudo(const DadosQuadra()), isFalse);
      expect(
        quadraTemConteudo(const DadosQuadra(loteamento: DadosLoteamento())),
        isFalse,
      );
    });

    test('uma linha basta', () {
      expect(
        quadraTemConteudo(const DadosQuadra(identificacao: 'B')),
        isTrue,
      );
    });

    test('só infraestrutura basta', () {
      expect(
        quadraTemConteudo(
          const DadosQuadra(
            loteamento: DadosLoteamento(infraestrutura: ['Asfalto']),
          ),
        ),
        isTrue,
      );
    });

    test('só áreas de lazer bastam', () {
      expect(
        quadraTemConteudo(
          const DadosQuadra(
            loteamento: DadosLoteamento(areasDeLazer: 'Praça central.'),
          ),
        ),
        isTrue,
      );
    });
  });

  test('ícones dos destaques são os combinados', () {
    final casa = destaquesDe(
      const DadosNatureza.casa(quartos: 1, suites: 1, banheiros: 1, vagas: 1),
    );
    expect(casa.map((d) => d.icone), [
      Icons.bed_outlined,
      Icons.king_bed_outlined,
      Icons.bathtub_outlined,
      Icons.directions_car_outlined,
    ]);

    final terreno = destaquesDe(
      const DadosNatureza.terreno(areaTotal: '1', frente: '1', fundo: '1'),
    );
    expect(terreno.map((d) => d.icone), [
      Icons.square_foot,
      Icons.straighten,
      Icons.straighten,
    ]);
  });
}
