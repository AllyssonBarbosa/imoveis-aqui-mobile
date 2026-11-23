import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/pagina_contatos.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_caixa_contatos.dart';

ContatoRecebido _contato({int id = 7, RetornoContato? retorno}) {
  return ContatoRecebido(
    id: id,
    imovelCodigo: 'DEV-CAMPINAS-14',
    imovelTitulo: 'Apartamento no bairro Barão Geraldo',
    canal: CanalContato.whatsapp,
    criadoEm: DateTime(2026, 1, 9, 22, 30),
    retorno: retorno ?? RetornoContato.pendente,
  );
}

const _imovel = ImovelComContato(
  id: 14,
  codigo: 'DEV-CAMPINAS-14',
  titulo: 'Apartamento no bairro Barão Geraldo',
);

final _periodo = PeriodoContatos(
  de: DateTime(2026, 1, 1),
  ate: DateTime(2026, 1, 31),
);

void main() {
  group('RetornoContato.anotaveis', () {
    test('é exatamente os 4 valores anotáveis, sem pendente', () {
      expect(RetornoContato.anotaveis, [
        RetornoContato.falei,
        RetornoContato.visitaAgendada,
        RetornoContato.semResposta,
        RetornoContato.descartado,
      ]);
      expect(
        RetornoContato.anotaveis,
        isNot(contains(RetornoContato.pendente)),
      );
    });

    test('não pode ser alterada', () {
      expect(
        () => RetornoContato.anotaveis.add(RetornoContato.pendente),
        throwsUnsupportedError,
      );
    });
  });

  group('ConsultaContatos', () {
    test('a consulta vazia não tem imóvel, período nem filtro', () {
      const consulta = ConsultaContatos();

      expect(consulta.imovel, isNull);
      expect(consulta.periodo, isNull);
      expect(consulta.temFiltro, isFalse);
    });

    test('com só o imóvel tem filtro', () {
      final consulta = const ConsultaContatos(imovel: _imovel);

      expect(consulta.temFiltro, isTrue);
    });

    test('com só o período tem filtro', () {
      final consulta = ConsultaContatos(periodo: _periodo);

      expect(consulta.temFiltro, isTrue);
    });

    test('imóvel e período se combinam', () {
      final consulta = ConsultaContatos(imovel: _imovel, periodo: _periodo);

      expect(consulta.imovel, _imovel);
      expect(consulta.periodo, _periodo);
      expect(consulta.temFiltro, isTrue);
    });

    test('copyWith(imovel) mantém o período', () {
      final consulta = ConsultaContatos(periodo: _periodo)
          .copyWith(imovel: _imovel);

      expect(consulta.imovel, _imovel);
      expect(consulta.periodo, _periodo);
    });

    test('copyWith(periodo) mantém o imóvel', () {
      final consulta = const ConsultaContatos(imovel: _imovel)
          .copyWith(periodo: _periodo);

      expect(consulta.imovel, _imovel);
      expect(consulta.periodo, _periodo);
    });

    test('copyWith(limparImovel) volta o imóvel a null e mantém o período', () {
      final consulta = ConsultaContatos(
        imovel: _imovel,
        periodo: _periodo,
      ).copyWith(limparImovel: true);

      expect(consulta.imovel, isNull);
      expect(consulta.periodo, _periodo);
    });

    test(
      'copyWith(limparPeriodo) volta o período a null e mantém o imóvel',
      () {
        final consulta = ConsultaContatos(
          imovel: _imovel,
          periodo: _periodo,
        ).copyWith(limparPeriodo: true);

        expect(consulta.imovel, _imovel);
        expect(consulta.periodo, isNull);
      },
    );

    test('copyWith sem argumentos não muda nada', () {
      final consulta = ConsultaContatos(imovel: _imovel, periodo: _periodo);

      expect(consulta.copyWith(), consulta);
    });

    test('tem igualdade por valor e toString', () {
      final a = ConsultaContatos(imovel: _imovel, periodo: _periodo);
      final b = ConsultaContatos(
        imovel: const ImovelComContato(
          id: 14,
          codigo: 'DEV-CAMPINAS-14',
          titulo: 'Apartamento no bairro Barão Geraldo',
        ),
        periodo: PeriodoContatos(
          de: DateTime(2026, 1, 1),
          ate: DateTime(2026, 1, 31),
        ),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const ConsultaContatos()));
      expect(a.toString(), startsWith('ConsultaContatos('));
    });
  });

  group('PeriodoContatos', () {
    test('tem igualdade por valor', () {
      final a = PeriodoContatos(
        de: DateTime(2026, 1, 1),
        ate: DateTime(2026, 1, 31),
      );
      final b = PeriodoContatos(
        de: DateTime(2026, 1, 1),
        ate: DateTime(2026, 1, 31),
      );
      final c = PeriodoContatos(
        de: DateTime(2026, 1, 2),
        ate: DateTime(2026, 1, 31),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), startsWith('PeriodoContatos('));
    });
  });

  group('ImovelComContato', () {
    test('tem igualdade por valor', () {
      const igual = ImovelComContato(
        id: 14,
        codigo: 'DEV-CAMPINAS-14',
        titulo: 'Apartamento no bairro Barão Geraldo',
      );
      const outro = ImovelComContato(
        id: 15,
        codigo: 'DEV-CAMPINAS-15',
        titulo: 'Casa',
      );

      expect(_imovel, igual);
      expect(_imovel.hashCode, igual.hashCode);
      expect(_imovel, isNot(outro));
      expect(_imovel.toString(), contains('DEV-CAMPINAS-14'));
    });
  });

  group('ContatoRecebido', () {
    test('tem igualdade por valor e hashCode coerente', () {
      expect(_contato(), _contato());
      expect(_contato().hashCode, _contato().hashCode);
      expect(_contato(), isNot(_contato(id: 8)));
      expect(_contato(), isNot(_contato(retorno: RetornoContato.falei)));
    });

    test('retornoEm entra na igualdade', () {
      final anotado = ContatoRecebido(
        id: 7,
        imovelCodigo: 'DEV-CAMPINAS-14',
        imovelTitulo: 'Apartamento no bairro Barão Geraldo',
        canal: CanalContato.whatsapp,
        criadoEm: DateTime(2026, 1, 9, 22, 30),
        retorno: RetornoContato.falei,
        retornoEm: DateTime(2026, 1, 10, 8),
      );

      expect(anotado, isNot(_contato(retorno: RetornoContato.falei)));
      expect(anotado.retornoEm, DateTime(2026, 1, 10, 8));
    });

    test('toString não expõe dado sensível do visitante', () {
      final texto = _contato().toString();

      expect(texto, startsWith('ContatoRecebido('));
      expect(texto, contains('DEV-CAMPINAS-14'));
      expect(texto.toLowerCase(), isNot(contains('telefone')));
      expect(texto.toLowerCase(), isNot(contains('@')));
    });
  });

  group('PaginaContatos', () {
    test('expõe itens imutáveis', () {
      final lista = [_contato()];
      final pagina = PaginaContatos(itens: lista);

      expect(pagina.itens, hasLength(1));
      expect(() => pagina.itens.add(_contato(id: 9)), throwsUnsupportedError);

      lista.add(_contato(id: 9));
      expect(pagina.itens, hasLength(1));
    });

    test('ehUltima é proximaPagina == null', () {
      expect(PaginaContatos(itens: const []).ehUltima, isTrue);
      expect(
        PaginaContatos(
          itens: const [],
          proximaPagina: 'http://127.0.0.1:8000/api/contatos/?page=2',
        ).ehUltima,
        isFalse,
      );
    });

    test('tem igualdade por valor', () {
      final a = PaginaContatos(itens: [_contato()], proximaPagina: 'p2');
      final b = PaginaContatos(itens: [_contato()], proximaPagina: 'p2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(PaginaContatos(itens: [_contato()])));
      expect(a, isNot(PaginaContatos(itens: const [], proximaPagina: 'p2')));
      expect(a.toString(), startsWith('PaginaContatos('));
    });
  });

  group('ContatoNaoEncontradoException', () {
    test('é const, é Exception e tem a mensagem fixa', () {
      const falha = ContatoNaoEncontradoException();

      expect(falha, isA<Exception>());
      expect(falha.toString(), 'Contato não encontrado na caixa.');
    });
  });
}
