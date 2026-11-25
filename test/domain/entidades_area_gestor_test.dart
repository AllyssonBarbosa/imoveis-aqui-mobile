import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/acervo_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/contatos_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/mudancas_recentes.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/entities/totais_por_situacao.dart';

Map<SituacaoImovel, int> _situacoes({int disponivel = 35}) => {
  SituacaoImovel.disponivel: disponivel,
  SituacaoImovel.reservado: 1,
  SituacaoImovel.vendido: 2,
  SituacaoImovel.alugado: 3,
};

MudancaRecente _mudanca({int id = 7, String observacao = 'Fechou a venda'}) {
  return MudancaRecente(
    id: id,
    imovelId: 14,
    imovelCodigo: 'DEV-CAMPINAS-14',
    imovelTitulo: 'Apartamento no bairro Barão Geraldo',
    situacaoAnterior: SituacaoImovel.disponivel,
    situacaoNova: SituacaoImovel.vendido,
    alteradoPor: 'Maria Corretora',
    alteradoEm: DateTime.utc(2026, 11, 20, 15, 30),
    observacao: observacao,
  );
}

void main() {
  group('TotaisPorSituacao', () {
    test('guarda o mapa e o total como vieram, sem somar', () {
      // O total do servidor (99) difere da soma das situações (41) de
      // propósito: a entidade não confere nem recalcula (D-10).
      final totais = TotaisPorSituacao(porSituacao: _situacoes(), total: 99);

      expect(totais.porSituacao[SituacaoImovel.disponivel], 35);
      expect(totais.porSituacao[SituacaoImovel.alugado], 3);
      expect(totais.porSituacao, hasLength(4));
      expect(totais.total, 99);
    });

    test('o mapa é imutável e não acompanha o mapa de origem', () {
      final origem = _situacoes();
      final totais = TotaisPorSituacao(porSituacao: origem, total: 41);

      expect(
        () => totais.porSituacao[SituacaoImovel.vendido] = 50,
        throwsUnsupportedError,
      );

      origem[SituacaoImovel.vendido] = 50;
      expect(totais.porSituacao[SituacaoImovel.vendido], 2);
    });

    test('tem igualdade por valor e hashCode coerente', () {
      final a = TotaisPorSituacao(porSituacao: _situacoes(), total: 41);
      final b = TotaisPorSituacao(porSituacao: _situacoes(), total: 41);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          TotaisPorSituacao(porSituacao: _situacoes(disponivel: 1), total: 41),
        ),
      );
      expect(a, isNot(TotaisPorSituacao(porSituacao: _situacoes(), total: 42)));
      expect(a.toString(), startsWith('TotaisPorSituacao('));
    });
  });

  group('AcervoPorCorretor', () {
    const maria = AcervoDoCorretor(
      corretorId: 3,
      nome: 'Maria Corretora',
      ativo: true,
      total: 35,
    );
    const joao = AcervoDoCorretor(
      corretorId: 4,
      nome: 'João Corretor',
      ativo: false,
      total: 1,
    );

    test('guarda as linhas na ordem recebida, sem reordenar', () {
      // joao (1) antes de maria (35): a ordem é do servidor (D-13).
      final acervo = AcervoPorCorretor(linhas: const [joao, maria], total: 36);

      expect(acervo.linhas, [joao, maria]);
    });

    test('guarda o total como veio, mesmo diferente da soma das linhas', () {
      final acervo = AcervoPorCorretor(linhas: const [maria, joao], total: 100);

      expect(acervo.total, 100);
    });

    test('as linhas são imutáveis e não acompanham a lista de origem', () {
      final origem = [maria];
      final acervo = AcervoPorCorretor(linhas: origem, total: 35);

      expect(() => acervo.linhas.add(joao), throwsUnsupportedError);

      origem.add(joao);
      expect(acervo.linhas, hasLength(1));
    });

    test('tem igualdade por valor e hashCode coerente', () {
      final a = AcervoPorCorretor(linhas: const [maria, joao], total: 36);
      final b = AcervoPorCorretor(linhas: const [maria, joao], total: 36);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(AcervoPorCorretor(linhas: const [joao, maria], total: 36)),
      );
      expect(
        a,
        isNot(AcervoPorCorretor(linhas: const [maria, joao], total: 37)),
      );
      expect(maria, isNot(joao));
      expect(a.toString(), startsWith('AcervoPorCorretor('));
      expect(maria.toString(), startsWith('AcervoDoCorretor('));
    });
  });

  group('ContatosPorCorretor', () {
    const maria = ContatosDoCorretor(
      corretorId: 3,
      nome: 'Maria Corretora',
      ativo: true,
      total: 12,
      pendentes: 4,
    );
    const empresa = ContatosDoCorretor(total: 2, pendentes: 2);

    test('a linha sem corretor é a da empresa, sem nome nem ativo', () {
      expect(empresa.daEmpresa, isTrue);
      expect(empresa.corretorId, isNull);
      expect(empresa.nome, isNull);
      expect(empresa.ativo, isNull);
    });

    test('a linha com corretor não é a da empresa', () {
      expect(maria.daEmpresa, isFalse);
    });

    test('guarda as linhas na ordem recebida e os totais como vieram', () {
      // total 50 e pendentes 9 não batem com a soma das linhas (14 e 6)
      // de propósito: a entidade não recalcula (D-15).
      final contatos = ContatosPorCorretor(
        linhas: const [empresa, maria],
        total: 50,
        pendentes: 9,
      );

      expect(contatos.linhas, [empresa, maria]);
      expect(contatos.total, 50);
      expect(contatos.pendentes, 9);
    });

    test('as linhas são imutáveis e não acompanham a lista de origem', () {
      final origem = [maria];
      final contatos = ContatosPorCorretor(
        linhas: origem,
        total: 12,
        pendentes: 4,
      );

      expect(() => contatos.linhas.add(empresa), throwsUnsupportedError);

      origem.add(empresa);
      expect(contatos.linhas, hasLength(1));
    });

    test('tem igualdade por valor e hashCode coerente', () {
      final a = ContatosPorCorretor(
        linhas: const [maria, empresa],
        total: 14,
        pendentes: 6,
      );
      final b = ContatosPorCorretor(
        linhas: const [maria, empresa],
        total: 14,
        pendentes: 6,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          ContatosPorCorretor(
            linhas: const [empresa, maria],
            total: 14,
            pendentes: 6,
          ),
        ),
      );
      expect(
        a,
        isNot(
          ContatosPorCorretor(
            linhas: const [maria, empresa],
            total: 14,
            pendentes: 5,
          ),
        ),
      );
      expect(maria, isNot(empresa));
      expect(a.toString(), startsWith('ContatosPorCorretor('));
      expect(maria.toString(), startsWith('ContatosDoCorretor('));
    });
  });

  group('MudancasRecentes', () {
    test('guarda os dias do servidor e as mudanças na ordem recebida', () {
      final recentes = MudancasRecentes(
        dias: 30,
        mudancas: [_mudanca(id: 9), _mudanca(id: 7)],
      );

      expect(recentes.dias, 30);
      expect(recentes.mudancas.map((m) => m.id), [9, 7]);
    });

    test('as mudanças são imutáveis e não acompanham a lista de origem', () {
      final origem = [_mudanca()];
      final recentes = MudancasRecentes(dias: 30, mudancas: origem);

      expect(
        () => recentes.mudancas.add(_mudanca(id: 8)),
        throwsUnsupportedError,
      );

      origem.add(_mudanca(id: 8));
      expect(recentes.mudancas, hasLength(1));
    });

    test('tem igualdade por valor e hashCode coerente', () {
      final a = MudancasRecentes(dias: 30, mudancas: [_mudanca()]);
      final b = MudancasRecentes(dias: 30, mudancas: [_mudanca()]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(MudancasRecentes(dias: 7, mudancas: [_mudanca()])));
      expect(a, isNot(MudancasRecentes(dias: 30, mudancas: const [])));
      expect(a.toString(), startsWith('MudancasRecentes('));
    });
  });

  group('MudancaRecente', () {
    test('tem igualdade por valor e hashCode coerente', () {
      expect(_mudanca(), _mudanca());
      expect(_mudanca().hashCode, _mudanca().hashCode);
      expect(_mudanca(), isNot(_mudanca(id: 8)));
      expect(_mudanca(), isNot(_mudanca(observacao: '')));
    });

    test('toString não expõe quem mudou nem a observação (T-12-11)', () {
      final texto = _mudanca().toString();

      expect(texto, startsWith('MudancaRecente('));
      expect(texto, contains('DEV-CAMPINAS-14'));
      expect(texto, isNot(contains('Maria Corretora')));
      expect(texto, isNot(contains('Fechou a venda')));
    });
  });
}
