import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/mudancas_recentes.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/entities/totais_por_situacao.dart';
import 'package:imoveis_aqui/presentation/area_gestor/apresentacao_area_gestor.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/apresentacao_gestao.dart';

MudancaRecente _mudanca({String alteradoPor = 'Ana Gestora'}) => MudancaRecente(
  id: 1,
  imovelId: 10,
  imovelCodigo: 'DEV-10',
  imovelTitulo: 'Casa no centro',
  situacaoAnterior: SituacaoImovel.disponivel,
  situacaoNova: SituacaoImovel.reservado,
  alteradoPor: alteradoPor,
  alteradoEm: DateTime(2026, 11, 20, 14, 5),
  observacao: '',
);

void main() {
  group('constantes fixas (D-06, D-10, D-17)', () {
    test('títulos e textos fixos', () {
      expect(tituloAreaGestor, 'Área do gestor');
      expect(tituloSecaoTotais, 'Totais da empresa por situação');
      expect(tituloSecaoAcervo, 'Acervo por corretor');
      expect(tituloSecaoContatos, 'Contatos por corretor');
      expect(textoNenhumCorretor, 'Nenhum corretor cadastrado.');
      expect(textoLinhaDaEmpresa, 'Empresa (corretor desativado no clique)');
      expect(rotuloTentarDeNovoSecao, 'Tentar de novo');
    });
  });

  group('textoDaFalha (D-23)', () {
    test('semPermissao tem texto próprio', () {
      expect(
        textoDaFalha(FalhaDaSecao.semPermissao),
        'Só o gestor da imobiliária pode ver estes números.',
      );
    });

    test('indisponivel é o texto genérico', () {
      expect(
        textoDaFalha(FalhaDaSecao.indisponivel),
        'Não foi possível carregar.',
      );
    });
  });

  group('totais e acervo (D-10, D-14)', () {
    test('textoTotalImoveis', () {
      expect(textoTotalImoveis(12), 'Total: 12 imóveis');
      expect(textoTotalImoveis(1), 'Total: 1 imóvel');
      expect(textoTotalImoveis(0), 'Total: 0 imóveis');
    });

    test('textoImoveisDoCorretor', () {
      expect(textoImoveisDoCorretor(0), 'Nenhum imóvel');
      expect(textoImoveisDoCorretor(1), '1 imóvel');
      expect(textoImoveisDoCorretor(5), '5 imóveis');
    });

    test('nomeDoCorretor marca só o desativado', () {
      expect(nomeDoCorretor('Ana', ativo: false), 'Ana (desativado)');
      expect(nomeDoCorretor('Ana', ativo: true), 'Ana');
      expect(nomeDoCorretor('Ana', ativo: null), 'Ana');
    });
  });

  group('contatos e período (D-16, D-17)', () {
    test('textoContatosDoCorretor', () {
      expect(
        textoContatosDoCorretor(3, 2),
        '3 contatos · 2 aguardando retorno',
      );
      expect(textoContatosDoCorretor(1, 0), '1 contato · 0 aguardando retorno');
    });

    test('textoTotalContatos', () {
      expect(
        textoTotalContatos(4, 3),
        'Total: 4 contatos · 3 aguardando retorno',
      );
    });

    test('textoDoPeriodo: todo o período ou as duas datas', () {
      expect(textoDoPeriodo(null), 'Todo o período.');
      expect(
        textoDoPeriodo(
          PeriodoContatos(
            de: DateTime(2026, 11, 1),
            ate: DateTime(2026, 11, 25),
          ),
        ),
        'Período: 01/11/2026 a 25/11/2026.',
      );
    });
  });

  group('mudanças recentes (D-19, D-21)', () {
    test('tituloSecaoMudancas', () {
      expect(tituloSecaoMudancas(7), 'Mudanças de situação — últimos 7 dias');
      expect(tituloSecaoMudancas(1), 'Mudanças de situação — último dia');
      expect(tituloSecaoMudancas(null), 'Mudanças de situação');
    });

    test('textoNenhumaMudanca', () {
      expect(
        textoNenhumaMudanca(7),
        'Nenhuma mudança de situação nos últimos 7 dias.',
      );
      expect(
        textoNenhumaMudanca(1),
        'Nenhuma mudança de situação no último dia.',
      );
    });

    test('rotuloImovelDaMudanca: "código — título"', () {
      expect(rotuloImovelDaMudanca(_mudanca()), 'DEV-10 — Casa no centro');
    });

    test('textoDeParaMudanca usa os rótulos de situação', () {
      expect(textoDeParaMudanca(_mudanca()), 'Disponível → Reservado');
    });

    test('textoQuandoEQuemMudanca: data e hora, e o nome quando houver', () {
      final quando = formatarDataHora(DateTime(2026, 11, 20, 14, 5));
      expect(textoQuandoEQuemMudanca(_mudanca()), '$quando · Ana Gestora');
      expect(textoQuandoEQuemMudanca(_mudanca(alteradoPor: '')), quando);
    });
  });

  group('estado inicial (D-07, D-16, D-22)', () {
    test('começa com as 4 seções carregando, todo o período e sessão viva', () {
      const estado = AreaGestorState();
      expect(estado.totais, isA<SecaoCarregando<TotaisPorSituacao>>());
      expect(estado.acervo, isA<SecaoCarregando>());
      expect(estado.contatos, isA<SecaoCarregando>());
      expect(estado.mudancas, isA<SecaoCarregando>());
      expect(estado.periodo, isNull);
      expect(estado.sessaoExpirada, isFalse);
    });

    test('EstadoSecao tem igualdade por valor', () {
      expect(
        const EstadoSecao<int>.carregada(3),
        const EstadoSecao<int>.carregada(3),
      );
      expect(
        const EstadoSecao<int>.comFalha(FalhaDaSecao.indisponivel),
        isNot(const EstadoSecao<int>.comFalha(FalhaDaSecao.semPermissao)),
      );
    });
  });
}
