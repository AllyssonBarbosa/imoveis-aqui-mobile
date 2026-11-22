import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/pagina_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

ImovelAcervo _imovel({bool meuImovel = true, bool naVitrine = true}) {
  return ImovelAcervo(
    id: 14,
    codigo: 'DEV-CAMPINAS-14',
    titulo: 'Apartamento no bairro Barão Geraldo',
    finalidade: FinalidadeImovel.vendaEAluguel,
    precoVenda: '350000.00',
    precoAluguel: '2550.00',
    fotoCapa: 'http://127.0.0.1:8000/media/capa.jpg',
    situacao: SituacaoImovel.disponivel,
    meuImovel: meuImovel,
    naVitrine: naVitrine,
  );
}

void main() {
  group('ImovelAcervo.paraPrevia', () {
    test('mantém id, título, finalidade, preços e capa do cartão', () {
      final previa = _imovel().paraPrevia();

      expect(previa.id, 14);
      expect(previa.titulo, 'Apartamento no bairro Barão Geraldo');
      expect(previa.finalidade, FinalidadeImovel.vendaEAluguel);
      expect(previa.precoVenda, '350000.00');
      expect(previa.precoAluguel, '2550.00');
      expect(previa.fotoCapa, 'http://127.0.0.1:8000/media/capa.jpg');
    });

    test('a lista do acervo não manda bairro, natureza nem quartos', () {
      final previa = _imovel().paraPrevia();

      expect(previa.bairro, '');
      expect(previa.natureza, isNull);
      expect(previa.quartos, isNull);
    });
  });

  group('ImovelAcervo igualdade', () {
    test('mesmos campos são iguais e têm o mesmo hashCode', () {
      expect(_imovel(), _imovel());
      expect(_imovel().hashCode, _imovel().hashCode);
    });

    test('mudar meuImovel ou naVitrine torna diferente', () {
      expect(_imovel(meuImovel: false), isNot(_imovel()));
      expect(_imovel(naVitrine: false), isNot(_imovel()));
    });
  });

  group('PaginaAcervo', () {
    test('páginas vazias iguais', () {
      expect(
        PaginaAcervo(itens: [], proximaPagina: null),
        PaginaAcervo(itens: [], proximaPagina: null),
      );
    });

    test('ehUltima deriva do cursor', () {
      expect(PaginaAcervo(itens: []).ehUltima, isTrue);
      expect(
        PaginaAcervo(itens: [], proximaPagina: 'http://x/?page=2').ehUltima,
        isFalse,
      );
    });

    test('a lista de itens não pode ser alterada por fora', () {
      final origem = [_imovel()];
      final pagina = PaginaAcervo(itens: origem);

      expect(() => pagina.itens.add(_imovel()), throwsUnsupportedError);
      origem.add(_imovel());
      expect(pagina.itens, hasLength(1));
    });

    test('igualdade compara itens e cursor', () {
      expect(
        PaginaAcervo(itens: [_imovel()], proximaPagina: 'a'),
        PaginaAcervo(itens: [_imovel()], proximaPagina: 'a'),
      );
      expect(
        PaginaAcervo(itens: [_imovel()], proximaPagina: 'a'),
        isNot(PaginaAcervo(itens: [_imovel()], proximaPagina: 'b')),
      );
      expect(
        PaginaAcervo(itens: [_imovel()]),
        isNot(PaginaAcervo(itens: [_imovel(naVitrine: false)])),
      );
    });
  });

  group('ConsultaAcervo (D-09)', () {
    test('o padrão é busca vazia e "Todas" (situação nula)', () {
      const consulta = ConsultaAcervo();

      expect(consulta.busca, '');
      expect(consulta.situacao, isNull);
    });

    test('igualdade por valor', () {
      expect(
        const ConsultaAcervo(busca: 'x', situacao: SituacaoImovel.vendido),
        const ConsultaAcervo(busca: 'x', situacao: SituacaoImovel.vendido),
      );
      expect(
        const ConsultaAcervo(busca: 'x', situacao: SituacaoImovel.vendido),
        isNot(
          const ConsultaAcervo(busca: 'x', situacao: SituacaoImovel.alugado),
        ),
      );
      expect(
        const ConsultaAcervo(busca: 'x').hashCode,
        const ConsultaAcervo(busca: 'x').hashCode,
      );
    });

    test('copyWith troca um campo e permite voltar a "Todas"', () {
      const consulta = ConsultaAcervo(
        busca: 'x',
        situacao: SituacaoImovel.reservado,
      );

      expect(consulta.copyWith(busca: 'y').situacao, SituacaoImovel.reservado);
      expect(consulta.copyWith(busca: 'y').busca, 'y');
      expect(consulta.copyWith(limparSituacao: true).situacao, isNull);
      expect(consulta.copyWith(limparSituacao: true).busca, 'x');
    });
  });
}
