import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/pagina_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/caixa_contatos_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/anotar_retorno_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_contatos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/listar_imoveis_dos_contatos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_sem_retorno_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _RepositorioFalso extends Mock implements CaixaContatosRepository {}

void main() {
  late _RepositorioFalso repositorio;

  setUp(() {
    repositorio = _RepositorioFalso();
  });

  group('BuscarContatosUseCase', () {
    test('call repassa a consulta e devolve o mesmo Result', () async {
      final esperado = Result<PaginaContatos>.success(
        PaginaContatos(itens: []),
      );
      const consulta = ConsultaContatos();
      when(() => repositorio.buscar(consulta))
          .thenAnswer((_) async => esperado);

      final resultado = await BuscarContatosUseCase(repositorio)(consulta);

      expect(resultado, same(esperado));
      verify(() => repositorio.buscar(consulta)).called(1);
    });

    test('seguir repassa o cursor e devolve o mesmo Result', () async {
      final esperado = Result<PaginaContatos>.failure(
        const SessaoExpiradaException(),
      );
      when(
        () => repositorio.seguir('http://127.0.0.1:8000/api/contatos/?page=2'),
      ).thenAnswer((_) async => esperado);

      final resultado = await BuscarContatosUseCase(repositorio)
          .seguir('http://127.0.0.1:8000/api/contatos/?page=2');

      expect(resultado, same(esperado));
    });
  });

  group('ObterSemRetornoUseCase', () {
    test('call devolve o Result do repositório', () async {
      const esperado = Result<int>.success(25);
      when(() => repositorio.contarSemRetorno())
          .thenAnswer((_) async => esperado);

      final resultado = await ObterSemRetornoUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });

  group('ListarImoveisDosContatosUseCase', () {
    test('call devolve o Result do repositório', () async {
      final esperado = Result<List<ImovelComContato>>.success(const []);
      when(() => repositorio.listarImoveis()).thenAnswer((_) async => esperado);

      final resultado = await ListarImoveisDosContatosUseCase(repositorio)();

      expect(resultado, same(esperado));
    });
  });

  group('AnotarRetornoUseCase', () {
    test('call repassa id e retorno e devolve o mesmo Result', () async {
      final esperado = Result<ContatoRecebido>.failure(
        const SemPermissaoException(),
      );
      when(() => repositorio.anotarRetorno(26, RetornoContato.visitaAgendada))
          .thenAnswer((_) async => esperado);

      final resultado = await AnotarRetornoUseCase(repositorio)(
        26,
        RetornoContato.visitaAgendada,
      );

      expect(resultado, same(esperado));
      verify(() => repositorio.anotarRetorno(26, RetornoContato.visitaAgendada))
          .called(1);
    });
  });
}
