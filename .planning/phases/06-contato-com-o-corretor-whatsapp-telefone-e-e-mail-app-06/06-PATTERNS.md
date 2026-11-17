# Phase 6: Contato com o Corretor (APP 06) - Pattern Map

**Mapped:** 2026-11-16
**Files analyzed:** 27 (app e API)
**Analogs found:** 26 / 27

Caminhos relativos ao app (`imovies-aqui-mobile`) salvo quando marcados `API:` (repo `../imoveis-aqui/Web`). O app nao e repo git (sem gate de tracked-source); na API todos os analogos citados sao da `main` ou de `origin/WEB-11` (tracked).

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match |
|---|---|---|---|---|
| `lib/domain/entities/canal_contato.dart` (enum) | model | transform | `lib/domain/entities/ordenacao_vitrine.dart` | role-match |
| `lib/domain/entities/contato_do_imovel.dart` (freezed: id, titulo, canais) | model | transform | `DetalheImovel` em `lib/domain/entities/detalhe_imovel.dart` | role-match |
| `lib/domain/entities/detalhe_imovel.dart` (+canaisContato) | model | transform | mesmo arquivo (`caracteristicas` com `@Default`) | exact |
| `lib/domain/gateways/link_launcher_gateway.dart` | gateway | request-response | `lib/domain/gateways/geocoding_gateway.dart` | exact |
| `lib/data/gateways/url_launcher_gateway_impl.dart` | gateway | request-response | `lib/data/gateways/geocoding_gateway_impl.dart` | exact |
| `lib/domain/repositories/contato_repository.dart` (+falhas tipadas) | repository | request-response | `lib/domain/repositories/imovel_detalhe_repository.dart` | exact |
| `lib/data/repositories/contato_repository_impl.dart` | repository | request-response | `lib/data/repositories/imovel_detalhe_repository_impl.dart` | exact |
| `lib/data/datasources/contato_datasource.dart` + `contato_remote_datasource.dart` | datasource | CRUD (POST) | `imovel_detalhe_datasource.dart` + `imovel_detalhe_remote_datasource.dart` | exact (GET->POST) |
| `lib/data/models/contato_registrado_model.dart` | model | transform | `lib/data/models/detalhe_imovel_model.dart` | role-match |
| `lib/data/models/detalhe_imovel_model.dart` (+canais_contato, paraEntidade) | model | transform | mesmo arquivo | exact |
| `lib/domain/usecases/contatar_corretor_usecase.dart` | usecase | request-response | `detectar_cidade_usecase.dart` (orquestra gateways); casca: `obter_detalhe_imovel_usecase.dart` | role-match |
| `lib/presentation/contato/contato_cubit.dart` + `contato_state.dart` | cubit/state | request-response | `detalhe_imovel_cubit.dart` + `detalhe_imovel_state.dart` | exact |
| `lib/presentation/contato/rotulos_contato.dart` | utility | transform | extension `RotuloOrdenacaoVitrine` em `vitrine/widgets/ordenacao_bottom_sheet.dart` | exact |
| `lib/presentation/contato/widgets/barra_contato.dart` | component | event-driven | `detalhe_imovel_screen.dart` (BlocBuilder) + `ordenacao_bottom_sheet.dart` | role-match |
| `lib/presentation/contato/widgets/contato_bottom_sheet.dart` | component | event-driven | `vitrine/widgets/ordenacao_bottom_sheet.dart` | exact |
| `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` (mod) | component | request-response | mesmo arquivo | exact |
| `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` (mod) | component | request-response | mesmo arquivo | exact |
| `pubspec.yaml`, `lib/di/injection.config.dart` (gerado) | config | - | build_runner | n/a |
| `tool/capturar_fixtures_api.py` (grupo `contato`) | utility | batch | mesmo arquivo (grupo `detalhe`) | exact |
| `test/support/api_falsa.dart` (POST) | test util | request-response | mesmo arquivo | exact |
| `test/data/contrato_detalhe_test.dart` (+`canais_contato`) | test | transform | mesmo arquivo (`_chavesDetalhe`) | exact |
| `test/data/contato_*_test.dart`, `url_launcher_gateway_impl_test.dart` | test | request-response | `test/data/imovel_detalhe_repository_impl_test.dart`, `imovel_detalhe_remote_datasource_test.dart` | exact |
| `test/presentation/contato_cubit_test.dart` | test | event-driven | `test/presentation/detalhe_imovel_cubit_test.dart` | exact |
| `test/presentation/barra_contato_test.dart`, ajustes em `detalhe_imovel_screen_test`, `perfil_corretor_screen_test`, `detalhe_navegacao_test` | test | event-driven | testes existentes homonimos | exact |
| API: `Web/imoveis/api/serializers.py` (+`canais_contato`) | serializer | transform | `ImovelVitrineDetalheSerializer` (SerializerMethodField `corretor_responsavel`) | exact |
| API: `Web/core/throttles.py` (+`ThrottleContatoPublico`) | middleware | request-response | `ThrottleVitrinePublica` (mesmo arquivo) | exact |
| API: `Web/config/settings.py` (+rate `contato_publico`, `CONTATO_TAXA_ANONIMA`) | config | - | bloco `VITRINE_TAXA_ANONIMA` | exact |
| API: `Web/contatos/api/views.py` (+throttle_classes) e testes `imoveis/tests.py`/`contatos/tests.py` | view/test | request-response | `VitrineLimiteDeTaxaTests`, `VitrineAllowlistExataTests` | exact |

## Pattern Assignments

### Gateway: `link_launcher_gateway.dart` + `url_launcher_gateway_impl.dart`
**Analog:** `lib/domain/gateways/geocoding_gateway.dart` / `lib/data/gateways/geocoding_gateway_impl.dart`

Impl (geocoding_gateway_impl.dart 1-8, 14-15, 40-50): `@LazySingleton(as: Interface)`, captura toda falha e normaliza, nunca lanca:
```dart
import 'package:injectable/injectable.dart';
@LazySingleton(as: GeocodingGateway)
class GeocodingGatewayImpl implements GeocodingGateway {
  ...
    } on Exception catch (erro) {
      return Result.failure(erro);
    } on Error catch (erro) {
      return Result.failure(Exception(erro.toString()));
    }
```
Para o link: `Future<bool> abrir(Uri)`, `launchUrl(link, mode: LaunchMode.externalApplication)` em try, `on Exception` -> `false` (Android lanca `ACTIVITY_NOT_FOUND`). Comentario de dartdoc na interface explica "nunca lanca para o chamador" (geocoding_gateway.dart 7-12).

### DataSource: `contato_datasource.dart` + `contato_remote_datasource.dart`
**Analog:** `lib/data/datasources/imovel_detalhe_datasource.dart` e `imovel_detalhe_remote_datasource.dart`

```dart
String caminhoDetalheImovelPublico(int id) => '/api/publico/imoveis/$id/';   // datasource.dart:5
abstract class ImovelDetalheDataSource { Future<DetalheImovelModel> buscarDetalhe(int id); }

@LazySingleton(as: ImovelDetalheDataSource)
class ImovelDetalheRemoteDataSource implements ImovelDetalheDataSource {
  ImovelDetalheRemoteDataSource(this._dio);
  final Dio _dio;
  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    final resposta = await _dio.get<Object?>(caminhoDetalheImovelPublico(id));
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do detalhe do imóvel não é um objeto JSON.');
    }
    return DetalheImovelModel.fromJson(corpo);
  }
}
```
Adaptar: `_dio.post<Object?>('/api/publico/imoveis/$id/contato/', data: {'canal': canal.nomeNaApi})`; DioException sobe tal e qual (o repo traduz). Caminho `/contato/` com id inteiro.

### Repository: `contato_repository.dart` + `contato_repository_impl.dart`
**Analog:** `imovel_detalhe_repository(_impl).dart`

Interface define excecoes tipadas no mesmo arquivo (imovel_detalhe_repository.dart 5-12): 
```dart
class ImovelNaoEncontradoException implements Exception {
  const ImovelNaoEncontradoException();
  @override String toString() => 'Imóvel não encontrado ou não publicado.';
}
```
Reusar `ImovelNaoEncontradoException` para 404; novas: `CanalIndisponivelException` (400), `ContatoLimiteExcedidoException` (429), `LinkContatoInvalidoException`, `ContatoSemAplicativoException`.

Impl (imovel_detalhe_repository_impl.dart 18-41), copiar a ordem de catch (DioException, TypeError->FormatException, Exception):
```dart
@LazySingleton(as: ImovelDetalheRepository)
class ImovelDetalheRepositoryImpl implements ImovelDetalheRepository {
  ImovelDetalheRepositoryImpl(this._dataSource);
  ...
    } on DioException catch (erro) {
      if (erro.response?.statusCode == 404) {
        return Result.failure(const ImovelNaoEncontradoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      return Result.failure(FormatException('detalhe malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
```
Trocar o `if 404` pelo `switch` 400/404/429/default do RESEARCH Pattern 3. Nota: 400/429 NAO estao tipados hoje em `lib/` (CONTEXT esta errado, confirmado: so 404). Validar link por canal (https+host wa.me | tel | mailto) usando `Uri.parse`; ver `lib/data/models/url_segura.dart` (`urlHttpOuNula`) como precedente de defesa na fronteira.

### UseCase: `contatar_corretor_usecase.dart`
**Analog:** `obter_detalhe_imovel_usecase.dart` (casca) e `detectar_cidade_usecase.dart` (orquestra gateways)
```dart
@injectable
class ObterDetalheImovelUseCase {
  ObterDetalheImovelUseCase(this._repositorio);
  final ImovelDetalheRepository _repositorio;
  Future<Result<DetalheImovel>> call(int id) => _repositorio.buscarDetalhe(id);
}
```
Corpo: RESEARCH Pattern 4 (switch exaustivo sobre `Success/Failure/Loading` de `lib/core/result.dart`).

### Cubit/State: `contato_cubit.dart`, `contato_state.dart`
**Analog:** `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` e `detalhe_imovel_state.dart`

State (detalhe_imovel_state.dart 1-12): `part '...freezed.dart'`, `@freezed sealed class X with _$X { const factory X.carregando() = DetalheCarregando; ... }`. Aqui: `ocioso`, `enviando(CanalContato)`, `falhou(MotivoFalhaContato)`.

Cubit (detalhe_imovel_cubit.dart 12-55): `@injectable`, construtor `: super(const ...)`, guard `if (isClosed || state is DetalheCarregando) return;`, `if (isClosed) return;` apos await, decisao so por tipo:
```dart
switch (resultado) {
  case Success(:final data): ...
  case Failure(:final erro):
    emit(erro is ImovelNaoEncontradoException ? ... : ...);
  case Loading(): break;
}
```
Adaptar: `contatar(int imovelId, CanalContato canal)` com guard `state is ContatoEnviando`; mapear `erro is CanalIndisponivelException` etc. para `MotivoFalhaContato`.

### Rotulos: `rotulos_contato.dart`
**Analog:** `ordenacao_bottom_sheet.dart` 6-17
```dart
extension RotuloOrdenacaoVitrine on OrdenacaoVitrine {
  String get rotulo => switch (this) { OrdenacaoVitrine.maisRecentes => 'Mais recentes', ... };
}
```
Extension em `CanalContato` com `rotulo`, `icone` e extension em `MotivoFalhaContato` com `mensagem` (textos D-14/D-15).

### Bottom sheet: `contato_bottom_sheet.dart`
**Analog:** `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` 27-50
```dart
Future<void> mostrarOrdenacaoBottomSheet(BuildContext context, {required ..., required ValueChanged<OrdenacaoVitrine> aoEscolher}) {
  return showModalBottomSheet<void>(
    context: context, showDragHandle: true,
    builder: (contextDoSheet) {
      return SafeArea(child: ... Navigator.of(contextDoSheet).pop(); aoEscolher(valor);
```
Regra: `aoEscolher` capturado do contexto da TELA (`context.read<ContatoCubit>().contatar`) antes de abrir; a rota do modal fica fora do BlocProvider. Usar `ListTile`s (Ligar / Enviar e-mail) em vez de RadioGroup.

### Barra: `barra_contato.dart`
Sem analogo exato de barra fixa; usar `BlocConsumer/BlocListener<ContatoCubit, ContatoState>` (padrao `BlocBuilder` de `detalhe_imovel_screen.dart` 66-67) com SnackBar em `ContatoFalhou`, `FilledButton.icon`, `IconButton` para o sheet; props `imovelId`, `canais`, `legenda`. Texto de preco (D-07): reutilizar `linhasDePrecoPorFinalidade(...)` (usada em `detalhe_imovel_screen.dart` 124-128), o mesmo texto do cabecalho: todas as linhas empilhadas quando cada uma cabe na largura da legenda (medida com `LayoutBuilder` + `TextPainter`); em VENDA_E_ALUGUEL longo demais, so a linha principal (a primeira) e o resto fica no topo; cada `Text` com `maxLines: 1` + ellipsis. Perfil: `Text('Sobre: ${titulo}')`.

### Screen: `detalhe_imovel_screen.dart` (modificacao)
Hoje `Scaffold(body: BlocBuilder<...>)` (linha ~66). Mover o `BlocBuilder` para envolver o `Scaffold` e acrescentar:
```dart
bottomNavigationBar: switch (state) {
  DetalheCarregado(:final detalhe) when detalhe.canaisContato.isNotEmpty => BarraContato(...),
  _ => null,
},
```
DI so no toque (linhas 28-43): estender `abrirDetalheImovel` com `criarContatoCubit` e trocar `BlocProvider` por `MultiBlocProvider`:
```dart
final criar = criarCubit ?? () => getIt<DetalheImovelCubit>();
... BlocProvider<DetalheImovelCubit>(create: (_) => criar()..carregar(previa.id), child: DetalheImovelScreen(previa: previa))
```
`abrirPerfilCorretor` e chamado em linha 166 (`aoTocar: () => abrirPerfilCorretor(context, corretor, construirImagemDeRede: ...)`): passar `contato: ContatoDoImovel(id, titulo, canais)`. Barra nao depende de `detalhe.corretor != null` (empresa pode ser o destino). Atencao ao `SliverPadding` final (linha ~176, `paddingOf(context).bottom + 24`).

### Screen: `perfil_corretor_screen.dart` (modificacao)
Hoje funcao `abrirPerfilCorretor(context, corretor, {construirImagemDeRede})` com `Navigator.push(MaterialPageRoute(builder: (_) => PerfilCorretorScreen(...)))` e `Scaffold(appBar:..., body:...)`. Acrescentar parametros nomeados opcionais `contato` e `criarContatoCubit`; so envolver em `BlocProvider<ContatoCubit>` e preencher `bottomNavigationBar` quando `contato != null` (a rota nova nao herda o provider do detalhe). O docstring que diz "nenhum campo de contato" deve ser atualizado.

### Models: `detalhe_imovel_model.dart`
Campo novo no `factory` (padrao com `@Default` e `@JsonKey`):
```dart
@Default(<CaracteristicaModel>[]) List<CaracteristicaModel> caracteristicas,
@JsonKey(name: 'corretor_responsavel') CorretorModel? corretor,
```
Adicionar `@JsonKey(name: 'canais_contato') @Default(<String>[]) List<String> canaisContato` e mapear em `paraEntidade()` ignorando nomes desconhecidos (tolerante) para `List<CanalContato>`. `contato_registrado_model.dart`: freezed + `part '.g.dart'` + `fromJson(Map<String, Object?>)` como acima.

### Tools/tests do app
- `tool/capturar_fixtures_api.py`: adicionar grupo `contato` (docstring 1-36 define grupos e procedimento com SQLite temporario e `semear_vitrine_dev`); fixtures de wire nunca a mao (F5/D-18). Recapturar `detalhe_*.json` com `canais_contato`.
- `test/support/api_falsa.dart`: hoje GET por rota (`_Sobrescrita`, `_Falha`, `lerFixtureApi`); acrescentar rota POST `/api/publico/imoveis/<id>/contato/` servindo `contato_201_*.json` / `erro_400_canal_contato.json`.
- `test/data/contrato_detalhe_test.dart` 18-36: adicionar `'canais_contato'` a `_chavesDetalhe` (allowlist exata).
- Teste de repo: copiar `imovel_detalhe_repository_impl_test.dart` (mock `Mock implements DataSource`, helper `dioException(int? status)` linhas 31-40, `setUp`).
- Teste de cubit: copiar `detalhe_imovel_cubit_test.dart` (`blocTest`, `class _X extends Mock implements UseCase`, `when(() => uc(...)).thenAnswer((_) async => Result.failure(const ...))`).
- Teste do gateway: `UrlLauncherPlatform` fake com `MockPlatformInterfaceMixin` (precedente `shared_preferences_platform_interface` em dev_dependencies).

### API: `canais_contato` (serializer)
**Analog:** `Web/imoveis/api/serializers.py` 552-596 (`ImovelVitrineDetalheSerializer`)
```python
corretor_responsavel = serializers.SerializerMethodField()
class Meta:
    model = Imovel
    fields = [..., "fotos", "corretor_responsavel"]
def get_corretor_responsavel(self, imovel): ...
```
Adicionar `canais_contato = serializers.SerializerMethodField()`, `"canais_contato"` ao fim de `fields`, `def get_canais_contato(self, imovel): return canais_disponiveis(imovel)` (`from contatos.servicos import canais_disponiveis`, existe so em WEB-11; import local se ciclo). Testes: atualizar `VitrineAllowlistExataTests` (`Web/imoveis/tests.py` ~2201) e deny-list de vazamento (nenhum telefone/whatsapp/email no JSON); caso corretor desativado -> canais da empresa.

### API: throttle
**Analog:** `Web/core/throttles.py` (main):
```python
class ThrottleVitrinePublica(AnonRateThrottle):
    scope = "vitrine_publica"
```
Novo: `class ThrottleContatoPublico(ThrottleVitrinePublica): scope = "contato_publico"` (decisao do usuario, 10/min). Settings (`config/settings.py` 139-165): copiar `VITRINE_TAXA_ANONIMA = env(..., default='120/min')` + validacao `re.fullmatch(r'[0-9]+/[smhd][a-z]*', ...)` -> `CONTATO_TAXA_ANONIMA` default `'10/min'`, e `'contato_publico': CONTATO_TAXA_ANONIMA` em `DEFAULT_THROTTLE_RATES`. View (`origin/WEB-11:Web/contatos/api/views.py`, `ContatoPublicoAPIView` com `permission_classes = [AllowAny]`, `authentication_classes = []`): `throttle_classes = [ThrottleContatoPublico]`. Nota: `ThrottleVitrinePublica` nao existe em `origin/WEB-11`; so apos o merge com a main. Testes (`imoveis/tests.py` 54-63 e 1180-1207): subclasse herda o `rate` fixado por `fixar_taxa_alta` (patch de atributo de classe no pai); teste de 429 com `mock.patch.object(ThrottleContatoPublico, "rate", "2/min", create=True)`, checar `Retry-After`, `detail`, `scope`, `get_rate()` vs settings.

## Shared Patterns

- **Result sealed + falha tipada**: `lib/core/result.dart` (`Result.success/failure/loading`); decidir so por tipo de excecao, nunca por mensagem ou status fora do repo.
- **DI**: `@injectable` (cubit, usecase), `@LazySingleton(as: Interface)` (repo, datasource, gateway); rodar `dart run build_runner build -d`; `getIt` resolvido so em `abrirDetalheImovel`/`abrirPerfilCorretor`, nunca em `build`.
- **Freezed estados/models**: `part 'x.freezed.dart'`, `@freezed sealed class` para unions, `abstract class` para modelos.
- **Guard de ciclo de vida do Cubit**: `if (isClosed) return;` antes de cada emit pos-await.
- **Sem dados sensiveis**: nunca logar/exibir/guardar o `link` do POST; nada de numero/e-mail no dominio (F5/D-16).
- **Fixtures**: capturadas da API real via `tool/capturar_fixtures_api.py`, nunca a mao.
- **Idioma**: nomes e comentarios em portugues.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `barra_contato.dart` (barra fixa em `bottomNavigationBar`) | component | event-driven | Nenhuma barra inferior fixa existe (F4/D-12 adiou); usar Material 3 + padroes acima |

Observacao: nao ha chamadas POST hoje em `lib/` (so GET); o POST segue o mesmo molde do datasource GET.

## Metadata

**Analog search scope:** `lib/`, `test/`, `tool/` do app; `Web/imoveis`, `Web/core`, `Web/config`, `origin/WEB-11:Web/contatos` da API.
**Pattern extraction date:** 2026-11-16
