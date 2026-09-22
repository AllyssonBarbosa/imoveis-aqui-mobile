import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/main.dart';

void main() {
  group('decidirDestinoInicial (D-08)', () {
    test('com cidade salva, a decisão é entrar direto', () {
      const cidade = Cidade(nome: 'Campinas', uf: 'SP');

      expect(decidirDestinoInicial(cidade), DestinoInicial.entraDireto);
    });

    test('sem cidade salva, a decisão é mostrar a lista', () {
      expect(decidirDestinoInicial(null), DestinoInicial.mostraLista);
    });
  });

  // O grupo "Fluxo do walking skeleton (CidadeSelecaoScreen)" do Plano 01-01
  // testava a tela mínima constructor-injetada diretamente com use cases
  // (obterCidadesAtendidas/salvarCidade). O Plano 01-03 expande
  // CidadeSelecaoScreen para uma projeção exaustiva do CidadeSelecaoCubit
  // (D-07) — o mesmo comportamento (listar cidades, tocar para persistir)
  // agora é coberto, através do Cubit, por
  // test/presentation/cidade_selecao_screen_test.dart e
  // test/presentation/cidade_selecao_cubit_test.dart. Removido aqui para
  // não duplicar cobertura de um constructor que não existe mais.
}
