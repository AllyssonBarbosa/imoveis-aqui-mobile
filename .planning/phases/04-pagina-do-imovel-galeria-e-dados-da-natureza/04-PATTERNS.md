# Phase 4: Página do Imóvel — Galeria e Dados da Natureza - Pattern Map

**Mapped:** 2026-10-12
**Files analyzed:** 27 (novos) + 4 (modificados)
**Analogs found:** 29 / 31
**Nota:** o repo não é git (gate de arquivo rastreado não aplicável); todos os analogs estão em `lib/` e `test/`, nunca em espelhos. Caminhos abaixo relativos a `/Users/georgelucas/Documents/projeto-mobile/imovies-aqui-mobile/`.

## File Classification

| Arquivo novo/modificado | Role | Data Flow | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `.planning/phases/01-.../01-CONTRATO-API.md` (§11) + `contrato/imovel_detalhe.example.json` | config/doc | request-response | §9/§10 do mesmo contrato + `contrato/imoveis.example.json` | exact |
| `lib/domain/entities/detalhe_imovel.dart` | model (freezed) | transform | `lib/domain/entities/filtros_vitrine.dart` (freezed) / `imovel.dart` | role-match |
| `lib/domain/entities/dados_natureza.dart` | model (sealed) | transform | `lib/core/result.dart` / `CarregamentoOpcoes` em `opcoes_filtro_state.dart` | role-match |
| `lib/domain/failures/imovel_nao_encontrado_exception.dart` | utility | request-response | `FalhaSimuladaDoMock` em `lib/data/datasources/imovel_mock_datasource.dart:20-27` | role-match |
| `lib/domain/repositories/imovel_detalhe_repository.dart` | repository (iface) | request-response | `lib/domain/repositories/opcoes_filtro_repository.dart` | exact |
| `lib/domain/usecases/obter_detalhe_imovel_usecase.dart` | usecase | request-response | `lib/domain/usecases/obter_caracteristicas_usecase.dart` | exact |
| `lib/data/models/detalhe_imovel_model.dart` (+ sub-models) | model | transform | `lib/data/models/imovel_model.dart` | exact |
| `lib/data/datasources/imovel_detalhe_datasource.dart` | datasource (iface) | request-response | `lib/data/datasources/opcoes_filtro_datasource.dart` | exact |
| `lib/data/datasources/imovel_detalhe_mock_datasource.dart` | datasource (mock) | request-response | `lib/data/datasources/opcoes_filtro_mock_datasource.dart` | exact |
| `lib/data/mocks/imoveis_detalhe_fixture.dart` | fixture | batch | `lib/data/mocks/imoveis_fixture.dart` | exact |
| `lib/data/repositories/imovel_detalhe_repository_impl.dart` | repository impl | request-response | `lib/data/repositories/imovel_repository_impl.dart` | exact (+ catch de DioException/TypeError) |
| `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart` | state (freezed) | event-driven | `lib/presentation/vitrine/opcoes_filtro_state.dart` (`CarregamentoOpcoes`) | exact |
| `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` | cubit | request-response | `lib/presentation/vitrine/opcoes_filtro_cubit.dart` | exact |
| `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` | screen | request-response | `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` (switch exaustivo + factory opcional) | role-match |
| `lib/presentation/detalhe_imovel/abrir_detalhe_imovel.dart` | navegação | event-driven | `CidadeSelecaoScreen` (`getIt` só no uso) | partial |
| `lib/presentation/detalhe_imovel/apresentacao_natureza.dart` | utility (funções puras) | transform | `lib/presentation/vitrine/apresentacao_imovel.dart` | exact |
| `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` | screen (stub) | — | `lib/presentation/priming/priming_screen.dart` (Scaffold simples) | partial |
| `.../widgets/imagem_rede.dart` | component | file-I/O | `lib/presentation/vitrine/widgets/foto_capa_imovel.dart` | exact |
| `.../widgets/galeria_imovel.dart`, `visualizador_fotos.dart` | component | event-driven | nenhum (PageView/InteractiveViewer inéditos) | no analog |
| `.../widgets/secao_natureza.dart`, `secao_precos.dart`, `cartao_corretor.dart` | component | transform | `lib/presentation/vitrine/widgets/imovel_card.dart` | role-match |
| `lib/presentation/vitrine/widgets/imovel_card.dart` (MOD: `onTap`) | component | — | si mesmo | — |
| `lib/presentation/vitrine/vitrine_screen.dart` (MOD: `aoAbrirImovel`) | screen | — | `CidadeSelecaoScreen` params opcionais | — |
| `lib/presentation/vitrine/apresentacao_imovel.dart` (MOD: preço reutilizável) | utility | transform | si mesmo | — |
| `lib/presentation/vitrine/widgets/foto_capa_imovel.dart` (MOD: usar `ImagemRede`) | component | — | si mesmo | — |
| `lib/di/injection.config.dart` | config gerado | — | regenerar via `dart run build_runner build -d` | — |
| Testes: `test/data/imovel_detalhe_*_test.dart`, `test/domain/...`, `test/presentation/detalhe_imovel_*_test.dart`, `apresentacao_natureza_test.dart` | test | — | `test/data/opcoes_filtro_repository_impl_test.dart`, `opcoes_filtro_mock_datasource_test.dart`, `opcoes_filtro_cubit_test.dart`, `imovel_card_test.dart`, `apresentacao_imovel_test.dart`, `cidade_remote_datasource_test.dart` (HttpClientAdapter falso para 404) | exact |

## Pattern Assignments

### `lib/data/repositories/imovel_detalhe_repository_impl.dart` (repository impl)
**Analog:** `lib/data/repositories/imovel_repository_impl.dart`

**Imports + injeção** (linhas 1-16):
```dart
import 'package:injectable/injectable.dart';
import '../../core/result.dart';
import '../../domain/repositories/imovel_repository.dart';
import '../datasources/imovel_datasource.dart';

@LazySingleton(as: ImovelRepository)
class ImovelRepositoryImpl implements ImovelRepository {
  ImovelRepositoryImpl(this._dataSource);
  final ImovelDataSource _dataSource;
```
**Core / erro** (linhas 22-27):
```dart
try {
  final envelope = await _dataSource.buscar(consulta);
  return Result.success(envelope.paraPagina());
} on Exception catch (erro) {
  return Result.failure(erro);
}
```
Estender conforme RESEARCH Pattern 1: antes do `on Exception`, adicionar `on DioException` (404 -> `ImovelNaoEncontradoException`), `on ImovelNaoEncontradoException`, `on TypeError` -> `FormatException` (TypeError não é Exception; `Result.failure` exige `Exception`).

---

### `lib/data/datasources/imovel_detalhe_datasource.dart` e `..._mock_datasource.dart`
**Analogs:** `opcoes_filtro_datasource.dart` (interface abstrata com doc sobre a troca mock->real) e `opcoes_filtro_mock_datasource.dart`.

**Mock: construtor padrão + `.paraTeste`** (opcoes_filtro_mock_datasource.dart 16-32):
```dart
@LazySingleton(as: OpcoesFiltroDataSource)
class OpcoesFiltroMockDataSource implements OpcoesFiltroDataSource {
  OpcoesFiltroMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _latencia = const Duration(milliseconds: 300);

  @visibleForTesting
  OpcoesFiltroMockDataSource.paraTeste({
    required List<Map<String, Object?>> linhas,
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _linhas = linhas,
       // ignore: prefer_initializing_formals
       _latencia = latencia;
```
**Latência condicional** (linhas 36-38): `if (_latencia > Duration.zero) { await Future<void>.delayed(_latencia); }`.
**Falha determinística:** reutilizar `FalhaSimuladaDoMock` (`imovel_mock_datasource.dart:20-27`, `implements Exception`, `const`). Parse do mapa de wire pelo mesmo Model: `DetalheImovelModel.fromJson(mapa)`; id reservado sem detalhe lança `ImovelNaoEncontradoException`.

---

### `lib/data/models/detalhe_imovel_model.dart` (model)
**Analog:** `lib/data/models/imovel_model.dart`

**Padrão freezed + JsonKey snake_case** (linhas 1-47):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'imovel_model.freezed.dart';
part 'imovel_model.g.dart';

@freezed
abstract class ImovelModel with _$ImovelModel {
  const ImovelModel._();
  const factory ImovelModel({
    required int id,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    required CidadeModel cidade,
    @JsonKey(name: 'foto_capa') String? fotoCapa,
    required List<String> caracteristicas,
    String? natureza,
    int? quartos,
    String? area,
  }) = _ImovelModel;

  factory ImovelModel.fromJson(Map<String, Object?> json) =>
      _$ImovelModelFromJson(json);
```
**Mapeamento entidade com enum desconhecido** (linhas 58-84): `_mapearFinalidade` lança `FormatException` para valor desconhecido; `_mapearNatureza` devolve `null`. Copiar ambos: finalidade estrita, natureza/topografia tolerantes. Usar `@JsonKey(name:)` campo a campo (estilo do repo), não `fieldRename`. Natureza: 4 blocos nullable + `switch` (`_ => null`), não `unionKey`.

---

### `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` e `_state.dart`
**Analog:** `opcoes_filtro_cubit.dart` / `opcoes_filtro_state.dart`

**State selado freezed** (opcoes_filtro_state.dart 17-28):
```dart
@freezed
sealed class CarregamentoOpcoes with _$CarregamentoOpcoes {
  const factory CarregamentoOpcoes.carregando() = OpcoesCarregando;
  const factory CarregamentoOpcoes.carregadas(List<String> opcoes) = OpcoesCarregadas;
  const factory CarregamentoOpcoes.falha() = OpcoesFalha;
}
```
**Cubit** (opcoes_filtro_cubit.dart 16-19, 62-73):
```dart
@injectable
class OpcoesFiltroCubit extends Cubit<OpcoesFiltroState> {
  OpcoesFiltroCubit(this._obterBairros, ...) : super(const OpcoesFiltroState());
...
  final resultado = await _obterBairros(cidade);
  if (isClosed) return;
  switch (resultado) {
    case Success(:final data): emit(...);
    case Failure(): emit(...);
    case Loading(): break;
  }
```
No detalhe: `case Failure(:final erro)` -> `erro is ImovelNaoEncontradoException ? naoEncontrado : erro`. Imports: `flutter_bloc`, `injectable`, `../../core/result.dart`.

---

### `lib/domain/usecases/obter_detalhe_imovel_usecase.dart` / `repositories/imovel_detalhe_repository.dart`
**Analogs:** `obter_caracteristicas_usecase.dart` (1-16) e `opcoes_filtro_repository.dart`.
```dart
@injectable
class ObterCaracteristicasUseCase {
  ObterCaracteristicasUseCase(this._repositorio);
  final OpcoesFiltroRepository _repositorio;
  Future<Result<List<String>>> call() => _repositorio.caracteristicas();
}
```
Interface: `abstract class X { Future<Result<T>> metodo(...); }`.

---

### `lib/presentation/detalhe_imovel/apresentacao_natureza.dart` (funções puras)
**Analog:** `lib/presentation/vitrine/apresentacao_imovel.dart`

Imports `package:intl/intl.dart`. Política de formatação (linhas 13-25):
```dart
String formatarPrecoBrl(String valorDecimal) {
  final valor = double.tryParse(valorDecimal);
  if (valor == null) return valorDecimal;          // nunca lança
  final temCentavos = valor % 1 != 0;
  final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$',
      decimalDigits: temCentavos ? 2 : 0);
  return formatador.format(valor);
}
```
`formatarAreaM2` segue a mesma política (parse tolerante, valor cru se não parseável). `linhasDePreco(Imovel)` (linhas 27+, switch sobre `FinalidadeImovel`) deve delegar a função com parâmetros nomeados, mantendo a assinatura atual.

---

### `.../widgets/imagem_rede.dart` e MOD `foto_capa_imovel.dart`
**Analog:** `lib/presentation/vitrine/widgets/foto_capa_imovel.dart`

Gancho de teste a repetir (linhas 13-23, 31-39):
```dart
@visibleForTesting this.construirImagemDeRede,
...
@visibleForTesting
final Widget Function(String url)? construirImagemDeRede;
...
construirImagemDeRede?.call(url!) ??
  CachedNetworkImage(
    imageUrl: url!, fit: BoxFit.cover,
    placeholder: (context, _) => _PlaceholderCasa(colorScheme: ...),
    errorWidget: (context, _, _) => _PlaceholderCasa(colorScheme: ...),
  )
```
`_PlaceholderCasa` (linhas 44-62, privado: `ColoredBox(primaryContainer)` + `Icons.home_outlined` size 48) deve virar público/reutilizável. `AspectRatio(16/9)` fica só em `FotoCapaImovel`, não em `ImagemRede`.

---

### MOD `imovel_card.dart` + `vitrine_screen.dart` (navegação)
**Card:** `ImovelCard({super.key, required this.imovel})` (linha 13), `Card(clipBehavior: Clip.antiAlias, child: Column(...))` (28-30). Adicionar `final VoidCallback? onTap` (opcional) e envolver o `Column` em `InkWell(onTap: onTap, child: ...)` dentro do Card.

**Ponto de uso na vitrine** (vitrine_screen.dart 342-345):
```dart
return ImovelCard(
  key: ValueKey('imovel-${imovel.id}'),
  imovel: imovel,
);
```
Passar `onTap: () => aoAbrirImovel(context, imovel)`. `VitrineScreen` hoje é `const VitrineScreen({super.key, required this.cidade})` (linha 30): adicionar parâmetro opcional `aoAbrirImovel` com default `abrirDetalheImovel`.

**Padrão de factory opcional / getIt tardio** (cidade_selecao_screen.dart 19-41):
```dart
const CidadeSelecaoScreen({super.key, VitrineCubit Function()? criarVitrineCubit, ...})
  : _criarVitrineCubit = criarVitrineCubit;
...
final criarVitrineCubit = _criarVitrineCubit ?? () => getIt<VitrineCubit>();
```
Em `abrirDetalheImovel`, chamar `getIt<DetalheImovelCubit>()` só no toque, dentro de `Navigator.push(MaterialPageRoute(builder: (_) => BlocProvider(create: ..., child: DetalheImovelScreen(previa: ...))))`. `switch` exaustivo sem `default` na tela (cidade_selecao_screen.dart 44-52).

---

### `lib/data/mocks/imoveis_detalhe_fixture.dart`
**Analog:** `lib/data/mocks/imoveis_fixture.dart`: mapas de wire `const List<Map<String, Object?>>` snake_case (`{'id': 42, 'titulo': ..., 'preco_venda': '450000.00', 'preco_aluguel': null, ...}`), `urlBaseFotosMock = 'https://picsum.photos/seed'`, derivar de `linhasAcervoFixture()`. Ids: 42/57/63 verbatim, geradas `100*(c+1)+k`, `natureza = k % 4`. Reservar 339 (404) e 338 (`FalhaSimuladaDoMock`).

---

### Testes (padrão)
**Analog repo/datasource:** `test/data/opcoes_filtro_repository_impl_test.dart`
```dart
class _OpcoesFiltroDataSourceFalso extends Mock implements OpcoesFiltroDataSource {}
setUp(() { dataSource = _...Falso(); repositorio = ...Impl(dataSource); });
when(() => dataSource.bairros(any())).thenAnswer((_) async => [...]);
expect(resultado, isA<Success<List<String>>>());
```
Imports `package:imoveis_aqui/...`, `flutter_test`, `mocktail`. Cubit: ver `test/presentation/opcoes_filtro_cubit_test.dart` (bloc_test). 404 via DioException: ver `test/data/cidade_remote_datasource_test.dart`. Widgets: nunca `pumpAndSettle` com `CircularProgressIndicator`; usar `construirImagemDeRede`.

## Shared Patterns

### Result / erros sem try/catch na UI
**Fonte:** `lib/core/result.dart` — `Result.loading()/success(T)/failure(Exception)` (freezed sealed). Aplicar a repo impl, use case, cubit.

### DI injectable
`@LazySingleton(as: Interface)` para datasource mock/repo impl; `@injectable` para use case e Cubit. Após criar, rodar `dart run build_runner build -d` (regenera `lib/di/injection.config.dart`). **Disco ~99% cheio: não rodar build; checar `df -h` e pedir OK ao usuário antes.**

### Cubit: `if (isClosed) return;` antes de cada `emit` (opcoes_filtro_cubit.dart:64).

### Estilo
Código/comentários em português; Material 3 com `Theme.of(context).colorScheme/textTheme`; `withValues(alpha:)` (nunca `withOpacity`); imutabilidade via freezed.

## No Analog Found

| Arquivo | Role | Data Flow | Motivo |
|---|---|---|---|
| `widgets/galeria_imovel.dart` (PageView + contador + SliverAppBar) | component | event-driven | Nenhum PageView/Sliver no repo; usar RESEARCH Pattern 5 |
| `widgets/visualizador_fotos.dart` (InteractiveViewer) | component | event-driven | Inédito; RESEARCH Pattern 6 (physics condicionada ao scale, human-check) |

## Metadata

**Analog search scope:** `lib/` (data, domain, presentation, di, core), `test/`
**Files scanned:** ~100 listados, ~14 lidos
**Pattern extraction date:** 2026-10-12
