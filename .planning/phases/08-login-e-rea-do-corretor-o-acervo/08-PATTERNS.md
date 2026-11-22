# Phase 8: Login e Área do Corretor — o Acervo - Pattern Map

**Mapped:** 2026-11-20
**Files analyzed:** ~55 (novos) + ~12 (existentes tocados), nos dois repositórios
**Analogs found:** 50 / 55 (5 sem analog direto, ver "No Analog Found")
**Nota:** todos os analogs de `lib/`, `test/`, `tool/` são rastreados no repo do app (`C:/projetos/imoveis-aqui-mobile`). Os de `Web/...` vivem no **repo web** (`C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui`, pasta `Web` = Django, `main` @ `d9ddd8f`), confirmados com `git ls-files`. Nenhum espelho/gerado ignorado.

## Arquivos EXISTENTES que a fase toca

| Arquivo existente | Mudança | Risco |
|---|---|---|
| `lib/di/modulo_rede.dart` | + `Dio` `@Named('autenticado')` + `FlutterSecureStorage`; o `Dio` público **não muda** | médio |
| `lib/di/injection.config.dart`, `*.freezed.dart`, `*.g.dart` | regenerados por `dart run build_runner build -d`; restaurar com `git checkout --` os que mudaram só de CRLF (D-18) | alto (ponto quente) |
| `lib/main.dart` | `BlocProvider.value(SessaoCubit)` acima do `MaterialApp`; `_TelaInicial` passa `acaoSessao: const BotaoSessaoTopo()` | médio |
| `lib/presentation/cidade_selecao/cidade_selecao_screen.dart`, `lib/presentation/vitrine/vitrine_screen.dart` | slot opcional `Widget? acaoSessao` (default `null`) | baixo (testes antigos não mudam) |
| `lib/presentation/priming/priming_screen.dart` | repassa `acaoSessao` ao empurrar `CidadeSelecaoScreen` (linha 63) | baixo |
| `test/support/api_falsa.dart` | gravar cabeçalhos + rotas `eu`/`sair`/`login`/`acervo` | médio (Wave 0) |
| `test/main_launch_routing_test.dart` | registrar `SessaoCubit` falso no `getIt` | baixo |
| `android/app/src/main/AndroidManifest.xml`, `ios/Runner/*.entitlements` (novo) | `allowBackup="false"`; entitlement do Keychain (`checkpoint:human-verify` em Mac) | médio |
| `pubspec.yaml` / `pubspec.lock` | + `flutter_secure_storage ^11.2.0` | baixo |
| `Web/imoveis/api/views.py`, `serializers.py`; `Web/contas/api/views.py`, `urls.py`; `Web/core/throttles.py`; `Web/config/settings.py` | ver seção Web | médio |
| `Web/imoveis/tests.py::ImovelApiTests.test_lista_apenas_da_propria_empresa` (linha 363) | passa a ler `response.data["results"]`; README linha 171 atualizada | baixo |
| `.planning/.../01-CONTRATO-API.md` (+ `contrato/*.example.json`), `REQUIREMENTS.md`, `ROADMAP.md` | §14, IDs AUTH/ACV/API-09/API-10 (D-15/D-16) | baixo (doc) |

## File Classification

### App (Flutter) — caminhos relativos a `C:/projetos/imoveis-aqui-mobile/`

| Arquivo novo | Role | Data Flow | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `lib/data/datasources/armazenamento_token.dart` (iface) + `armazenamento_token_seguro.dart` | datasource (storage) | file-I/O | `lib/data/datasources/cidade_prefs_datasource.dart` | role-match |
| `lib/data/datasources/autenticacao_datasource.dart` (iface) + `autenticacao_remote_datasource.dart` | datasource (Dio) | request-response | `lib/data/datasources/perfil_datasource.dart` + `vitrine_anunciante_remote_datasource.dart` | exact |
| `lib/data/datasources/acervo_datasource.dart` (iface) + `acervo_remote_datasource.dart` | datasource (Dio, paginado) | request-response | `lib/data/datasources/vitrine_anunciante_remote_datasource.dart` (+ `vitrine_anunciante_datasource.dart`, `parametros_consulta_imoveis.dart`) | exact |
| `lib/data/network/interceptador_sessao.dart` | interceptor | request-response | nenhum no app (ver "No Analog Found"); estrutura de DI: `lib/di/modulo_rede.dart` | parcial |
| `lib/data/models/imovel_acervo_model.dart`, `acervo_envelope_model.dart`, `eu_model.dart` | model (freezed+json) | transform | `lib/data/models/imovel_model.dart`, `imoveis_envelope_model.dart` | exact |
| `lib/data/repositories/autenticacao_repository_impl.dart`, `acervo_repository_impl.dart` | repository impl | request-response | `lib/data/repositories/perfil_repository_impl.dart` | exact |
| `lib/domain/entities/papel.dart`, `situacao_imovel.dart`, `imovel_acervo.dart`, `pagina_acervo.dart`, `consulta_acervo.dart` | entidade | transform | `lib/domain/entities/pagina_imoveis.dart`, `consulta_imoveis.dart`, `imovel.dart` | exact |
| `lib/domain/repositories/autenticacao_repository.dart`, `acervo_repository.dart` (+ exceções tipadas) | repository (iface) | request-response | `lib/domain/repositories/perfil_repository.dart` (exceção na linha 9) | exact |
| `lib/domain/usecases/entrar_usecase.dart`, `obter_papel_usecase.dart`, `sair_usecase.dart`, `ler_sessao_usecase.dart`, `buscar_acervo_usecase.dart` | usecase | request-response | `lib/domain/usecases/obter_perfil_corretor_usecase.dart`, `buscar_imoveis_do_anunciante_usecase.dart` | exact |
| `lib/presentation/sessao/sessao_cubit.dart` + `sessao_state.dart` | cubit singleton | event-driven | `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` + `cidade_selecao_state.dart` | role-match |
| `lib/presentation/sessao/botao_sessao_topo.dart` | component | event-driven | `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart` | role-match |
| `lib/presentation/sessao/entrada_area_screen.dart`, `aviso_area_screen.dart` | screen | request-response | `lib/presentation/perfis/perfil_corretor_screen.dart` (+ `perfil_corretor_cubit.dart`) | role-match |
| `lib/presentation/login/login_cubit.dart`, `login_state.dart`, `login_screen.dart` | cubit + screen | request-response | `lib/presentation/perfis/perfil_corretor_cubit.dart` / `perfil_state.dart`; campo de texto: `vitrine_screen.dart` | role-match |
| `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart` | cubit (paginado + busca com debounce) | request-response | `lib/presentation/vitrine/vitrine_cubit.dart` (debounce/versão) + `lib/presentation/perfis/vitrine_anunciante_cubit.dart` (paginação) | exact (combinação) |
| `lib/presentation/acervo/acervo_screen.dart` | screen (scroll infinito + SearchBar) | event-driven | `lib/presentation/vitrine/vitrine_screen.dart` (linhas 105-135) | exact |
| `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` | component | transform | `lib/presentation/vitrine/widgets/imovel_card.dart` | role-match |
| `lib/presentation/acervo/widgets/chips_situacao.dart` | component | event-driven | `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` | role-match |
| `test/support/armazenamento_token_em_memoria.dart` | test support | — | `test/support/api_falsa.dart` (fake de infra) | role-match |
| `test/data/*_acervo_*_test.dart`, `autenticacao_*_test.dart`, `contrato_acervo_test.dart` | test | — | `test/data/vitrine_anunciante_remote_datasource_test.dart`, `contrato_perfis_test.dart` | exact |
| `test/presentation/acervo_cubit_test.dart`, `login_cubit_test.dart`, `sessao_cubit_test.dart` | test | — | `test/presentation/vitrine_anunciante_cubit_test.dart`, `vitrine_cubit_test.dart` | exact |
| `test/presentation/acervo_screen_test.dart`, `login_screen_test.dart`, ... | test | — | `test/presentation/perfil_corretor_screen_test.dart`, `vitrine_screen_test.dart` | exact |
| `tool/capturar_fixtures_api.py` (+ grupo `acervo`) | tool | batch | o próprio arquivo (grupos existentes) | exact |

### Web (Django) — caminhos prefixados `Web/`, **no repo web**

| Arquivo novo/modificado | Role | Data Flow | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `Web/core/throttles.py` (+ `ThrottleLoginPorEmail`, `ThrottleLoginPorIp`) | throttle | request-response | `Web/core/throttles.py::ThrottleVitrinePublica` | exact |
| `Web/config/settings.py` (+ `LOGIN_TAXA_POR_EMAIL/IP`) | config | — | `Web/config/settings.py` linhas 147-179 (`VITRINE_TAXA_ANONIMA`) | exact |
| `Web/contas/api/views.py` (`LoginAPIView` alterada, + `EuAPIView`, `SairAPIView`) | view | request-response | `Web/contas/api/views.py::LoginAPIView` | exact |
| `Web/contas/api/urls.py` (+ `auth/eu/`, `auth/sair/`) | route | — | `Web/contas/api/urls.py` linha 11 | exact |
| `Web/imoveis/api/views.py` (`ImovelViewSet` + `PaginacaoAcervo`) | viewset | CRUD (list) | `Web/imoveis/api/views.py::PaginacaoVitrine` (linha 333) e `ImovelViewSet` (linha 67) | exact |
| `Web/imoveis/api/serializers.py` (+ `ImovelAcervoSerializer`, `FotoCapaMixin`) | serializer | transform | `ImovelVitrineSerializer.get_foto_capa` (`serializers.py:549`) | exact |
| `Web/contas/tests.py` (login, eu, sair, throttle) | test | — | `Web/contas/tests.py::LoginApiTests` (linha 148) | exact |
| `Web/imoveis/tests.py` (acervo, isolamento, allowlist, N+1, throttle) | test | — | `ImovelApiTests` (343), `VitrineLimiteDeTaxaTests` (1182), `VitrineAllowlistExataTests` (2393) | exact |

## Pattern Assignments — App

### `lib/data/repositories/autenticacao_repository_impl.dart` e `acervo_repository_impl.dart` (repository impl, request-response)

**Analog:** `lib/data/repositories/perfil_repository_impl.dart` (linhas 1-58)

**Imports + injeção** (linhas 1-23):
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../datasources/perfil_datasource.dart';

@LazySingleton(as: PerfilRepository)
class PerfilRepositoryImpl implements PerfilRepository {
  PerfilRepositoryImpl(this._dataSource);
  final PerfilDataSource _dataSource;
```

**Cadeia de tradução de erros** (linhas 39-57) — copiar a ordem; acrescentar o ramo `SessaoExpiradaException` (via `erro.error is SessaoExpiradaException`) antes do 404, 400 → `CredenciaisInvalidasException`, 403 → `SemPermissaoException`, 429 → `LimiteTentativasException(aguardar: ...)` lendo `erro.response?.headers.value('retry-after')`:
```dart
Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
  try {
    return Result.success(await acao());
  } on PerfilNaoEncontradoException catch (erro) {
    return Result.failure(erro);
  } on DioException catch (erro) {
    if (erro.response?.statusCode == 404) {
      return Result.failure(const PerfilNaoEncontradoException());
    }
    return Result.failure(erro);
  } on TypeError catch (erro) {
    return Result.failure(FormatException('perfil malformado: $erro'));
  } on Exception catch (erro) {
    return Result.failure(erro);
  }
}
```
D-03: 400 do login vira falha tipada com **texto fixo** na presentation (nunca o corpo do servidor); rede/timeout/5xx = outra falha tipada.

### `lib/data/datasources/acervo_remote_datasource.dart` (datasource Dio, paginado)

**Analog:** `lib/data/datasources/vitrine_anunciante_remote_datasource.dart` (linhas 1-64)

Copiar inteiro: `@LazySingleton(as: AcervoDataSource)`, `buscar(consulta)` + `seguir(String proximaPagina)`, `_lerEnvelope` com `FormatException` se o corpo não é `Map<String, dynamic>`, e `_exigirMesmaOrigem` (linhas 48-63; é a terceira cópia, a pesquisa recomenda extrair função pura compartilhada). Diferença: o construtor recebe `@Named('autenticado') Dio`, e `buscar` manda `queryParameters` (`busca`, `situacao`) em vez de rota sem query:
```dart
@LazySingleton(as: VitrineAnuncianteDataSource)
class VitrineAnuncianteRemoteDataSource implements VitrineAnuncianteDataSource {
  VitrineAnuncianteRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) async {
    _exigirMesmaOrigem(proximaPagina);
    final resposta = await _dio.get<Object?>(proximaPagina);
    return _lerEnvelope(resposta.data);
  }
```
Montagem dos parâmetros: seguir `lib/data/datasources/parametros_consulta_imoveis.dart` (função pura testada em `test/data/parametros_consulta_imoveis_test.dart`); "Todas" não manda `situacao`.

### `lib/data/datasources/autenticacao_remote_datasource.dart` (login no Dio público; eu/sair no autenticado)

**Analog:** o mesmo arquivo acima + `lib/data/datasources/cidade_remote_datasource.dart` (POST/GET simples). Injeção por `@Named`:
```dart
// Source: 08-RESEARCH Pattern 6 (injectable @Named em parâmetro)
AutenticacaoRemoteDataSource(this._dioPublico, @Named('autenticado') this._dioAutenticado);
```
Login: `_dioPublico.post('/api/auth/login/', data: {'email': ..., 'password': ...})` sem `Authorization` (Pitfall 1). Corpo mal formado → `FormatException`. Fina de propósito: não captura `DioException`.

### `lib/di/modulo_rede.dart` (config, DI)

**Analog:** o próprio arquivo (linhas 21-32)
```dart
@module
abstract class ModuloRede {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: urlBaseApi,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );
}
```
Adicionar (sem tocar no `dio` público): `@Named('autenticado') @lazySingleton Dio dioAutenticado(InterceptadorSessao i)` com os mesmos `BaseOptions` + `followRedirects: false` + `..interceptors.add(i)`, e `@lazySingleton FlutterSecureStorage get armazenamentoSeguro => const FlutterSecureStorage();`. Código completo em 08-RESEARCH Pattern 6. Atualizar o doc-comment ("sem interceptors e sem autenticação") que passa a valer só para o `Dio` público.

### `lib/data/datasources/armazenamento_token_seguro.dart` (storage, file-I/O)

**Analog:** `lib/data/datasources/cidade_prefs_datasource.dart` (linhas 14-39): `@lazySingleton`, chave fixa, `ler/salvar/apagar`, valor corrompido vira `null` sem crash.
```dart
@lazySingleton
class CidadePrefsDataSource {
  static const _chave = 'cidade_selecionada';
  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();
  ...
  Future<(String nome, String uf, int?)?> obterSalva() async {
    final valor = await _preferencias.getString(_chave);
    if (valor == null) return null;
```
Diferenças: interface `ArmazenamentoToken` (`@LazySingleton(as: ArmazenamentoToken)` na impl segura), `FlutterSecureStorage` injetado, `ler()` captura `PlatformException` e devolve `null` (fail-closed, Pitfall 7). O comentário "não precisa de `flutter_secure_storage`" da linha 12 deixa de valer só para a cidade (D-D); não editar esse arquivo.

### `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart` (cubit paginado com busca e chips)

**Analogs:** `lib/presentation/vitrine/vitrine_cubit.dart` (debounce + versão) e `lib/presentation/perfis/vitrine_anunciante_cubit.dart` (paginação).

**Debounce** (`vitrine_cubit.dart:37-38, 81-91`):
```dart
Timer? _debounce;
...
_debounce = Timer(const Duration(milliseconds: 400), () {
  if (termo == state.termoBusca) return;
  unawaited(_aplicarConsulta(...));
});
```
No acervo a pesquisa recomenda mínimo de 1 caractere (a vitrine tem `if (termo.length < 2) return;` na linha 79). Cancelar o `Timer` em `close()`. Descarte de resposta obsoleta: `final minhaVersao = ++_versaoConsulta; ... if (minhaVersao != _versaoConsulta || isClosed) return;` (`vitrine_cubit.dart:292, 313`).

**Paginação e retry** (`vitrine_anunciante_cubit.dart:35-59, 66-102`): `carregarMais()` ignora se `carregandoMais || erroAoCarregarMais || proximaPagina == null`; `_carregarProximaPagina` emite `copyWith(carregandoMais: true, erroAoCarregarMais: false)`, depois filtra ids repetidos só por integridade da lista:
```dart
final idsListados = atualizado.itens.map((i) => i.id).toSet();
final novos = data.itens.where((i) => !idsListados.contains(i.id));
emit(atualizado.copyWith(itens: [...atualizado.itens, ...novos], proximaPagina: data.proximaPagina, carregandoMais: false));
```
**Estado** (`vitrine_anunciante_state.dart:11-32`): `@freezed sealed class` com `carregando`, `vazia`, `erro`, `carregada({itens, proximaPagina, @Default(false) carregandoMais, @Default(false) erroAoCarregarMais})`. No `AcervoState` acrescentar `termoBusca` e `situacao` (nulo = Todas) e distinguir "vazio sem filtro" de "nenhum resultado para a busca/filtro". Falha `SessaoExpiradaException` deve virar um estado próprio (`sessaoExpirada`) que a tela traduz em navegação para o login; `isClosed` antes de todo `emit`.

### `lib/presentation/acervo/acervo_screen.dart` (screen, event-driven)

**Analog:** `lib/presentation/vitrine/vitrine_screen.dart`

**Rolagem a 90%** (linhas 109-115) e **página extra se a primeira não enche a tela** (linhas 121-134):
```dart
void _aoRolar() {
  if (!_controleDeRolagem.hasClients) return;
  final posicao = _controleDeRolagem.position;
  if (posicao.pixels >= posicao.maxScrollExtent * 0.9) {
    context.read<VitrineCubit>().carregarMais();
  }
}
void _agendarCarregarMaisSeNaoPreencheATela(ConteudoVitrine conteudo) {
  if (conteudo is! VitrineCarregada) return;
  if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
  if (conteudo.proximaPagina == null) return;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    if (!_controleDeRolagem.hasClients) return;
    if (_controleDeRolagem.position.maxScrollExtent <= 0) {
      context.read<VitrineCubit>().carregarMais();
    }
  });
}
```
**SearchBar** (linhas 145-147): `SearchBar(controller: ..., hintText: 'Buscar por título ou bairro', trailing: [... "Limpar busca"])`; no acervo `hintText: 'Buscar por código ou título'`. **Rodapé:** usar direto `RodapePaginacaoLista(carregandoMais:, erroAoCarregarMais:, temProximaPagina:, aoTentarDeNovo:)` de `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart` (linhas 9-23) como último item da lista. Não há `buildX()`: extrair classes (skill do projeto). Sair na `AppBar` com `AlertDialog` de confirmação.

### `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` (component)

**Analog:** `lib/presentation/vitrine/widgets/imovel_card.dart` (Card Material 3, `ImagemRede`, `linhasDePreco`). Reuso direto: `ImagemRede(url:)` (`lib/presentation/comum/imagem_rede.dart`), `linhasDePreco(imovel)` / `linhasDePrecoPorFinalidade({finalidade, precoVenda, precoAluguel})` (`lib/presentation/vitrine/apresentacao_imovel.dart:29,40`). Toque: `onTap` só quando `naVitrine` for verdadeiro, senão sem `InkWell`/ripple (D-07), chamando `abrirDetalheImovel(context, imovel.paraPrevia())` (`lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:31-45`, assinatura `Future<void> abrirDetalheImovel(BuildContext, Imovel previa, {DetalheImovelCubit Function()? criarCubit})`). Cores só do `ColorScheme`, texto só do `textTheme`; marca "Seu" vem de `meuImovel`, nunca comparando ids.

### `lib/presentation/acervo/widgets/chips_situacao.dart` (component)

**Analog:** `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` (linha de chips). Usar `ChoiceChip` de escolha única: Todas, Disponível, Reservado, Vendido, Alugado; `switch` exaustivo sobre `SituacaoImovel`; valor desconhecido do servidor → sem chip, nunca quebra.

### `lib/presentation/sessao/sessao_cubit.dart` + `botao_sessao_topo.dart` + slot (cubit singleton, event-driven)

**Analog (cubit):** `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` + `cidade_selecao_state.dart` (união freezed; use cases injetados; `isClosed` antes de `emit`). Estados `verificando`, `anonima`, `autenticada`; `@lazySingleton` (singleton de DI). **Analog (slot):** `VitrineScreen.aoAbrirImovel` ("existe para que os testes de widget não dependam do DI"). `SeletorCidadeTopo` (`lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart`) passa a ser `Expanded` dentro de `Row`, com `if (acaoSessao != null) acaoSessao!`.

**Provider raiz** (modificar `lib/main.dart` linhas 28-39): `BlocProvider.value(value: getIt<SessaoCubit>()..carregar(), child: MaterialApp(...))`. `_TelaInicial` (`main.dart:49-99`) não espera a sessão (AC-6); padrão de `getIt<...>()` em campo `final` já existe nas linhas 57-58.

### `lib/presentation/login/login_screen.dart` + `login_cubit.dart`

**Analog:** `lib/presentation/perfis/perfil_corretor_cubit.dart` (+ `perfil_state.dart`, `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart`) para o cubit de desfechos explícitos; navegação `Navigator.push(MaterialPageRoute<void>(...))` como em `abrirDetalheImovel` e `lib/presentation/priming/priming_screen.dart:63`. Sequência (Pattern 8): `Entrar` (Dio público) → salvar token → `eu` (Dio autenticado); se `eu` falhar por rede/5xx, apagar o token (rollback). Sucesso: `BlocListener` faz `Navigator.pushReplacement` para `AcervoScreen`/`AvisoAreaScreen`. Mensagens fixas por tipo de falha (D-03/D-04); sem `try/catch` na UI.

### `test/support/api_falsa.dart` (estender) e `test/support/armazenamento_token_em_memoria.dart`

**Analog:** `test/support/api_falsa.dart` (linhas 51-292). Estender com os pontos abaixo.
- Gravar cabeçalhos: hoje `_AdaptadorApiFalsa.fetch` passa só `options.uri` (linha 287): `return _api._atender(options.uri);`. Trocar para passar `options` e guardar `cabecalhos` numa lista paralela a `_requisicoes` (os testes "token só nas rotas autenticadas" dependem disso).
- Novas rotas no `_atender` no estilo das existentes (`RegExp` + `lerFixtureApi`): `POST /api/auth/login/`, `GET /api/auth/eu/` (`eu_corretor.json`), `POST /api/auth/sair/` (204), `GET /api/imoveis/` (`acervo_p1/p2/busca/situacao.json`). 401/429 via `responder(...)`/`falharProximas(...)` já existentes (`falharProximas` precisa aceitar `headers` para `Retry-After`).
- `criarDio()` hoje cria um só `Dio`; adicionar `criarDioAutenticado(InterceptadorSessao)` que reaproveita o mesmo adaptador.

### `test/data/*` (DataSource/Repository/contrato)

**Analog:** `test/data/vitrine_anunciante_remote_datasource_test.dart` (linhas 11-40: `ApiFalsa`, `lerFixtureApi`, `setUp` com `VitrineAnuncianteRemoteDataSource(api.criarDio())`) e `test/data/contrato_perfis_test.dart` (comparar `contrato/*.example.json` × fixture, travar conjunto de chaves por objeto; `_pastaContrato` na linha 19). `contrato_acervo_test.dart` trava as 10 chaves exatas do item e as 4 do envelope. Sem fixture de 429: testar `Retry-After` com `Response` sintética no repositório.

### `test/presentation/*cubit_test.dart`

**Analog:** `test/presentation/vitrine_anunciante_cubit_test.dart` (linhas 1-45): `bloc_test` + `mocktail`, `class _XUseCaseFalso extends Mock implements XUseCase`, `registerFallbackValue` no `setUpAll`, fixtures `const` de domínio.

### `tool/capturar_fixtures_api.py` (+ grupo `acervo`)

**Analog:** o próprio arquivo (grupos existentes; SQLite temporário). Credenciais por variável de ambiente, nunca no repo; fixtures novas em `test/fixtures/api/`: `acervo_p1.json`, `acervo_p2.json`, `acervo_busca.json`, `acervo_situacao.json`, `eu_corretor.json`, `erro_400_login.json`, `erro_401.json`. Cópia byte a byte para `.planning/phases/01-.../contrato/*.example.json`.

## Pattern Assignments — Web (repo web, prefixo `Web/`)

### `Web/core/throttles.py` (throttle, request-response)

**Analog:** `Web/core/throttles.py` (arquivo inteiro)
```python
from rest_framework.throttling import AnonRateThrottle


class ThrottleVitrinePublica(AnonRateThrottle):
    """Limite por IP das rotas públicas da vitrine (sem token). ..."""

    scope = "vitrine_publica"
```
Novas: `ThrottleLoginPorEmail(SimpleRateThrottle)` (`scope = "login_email"`, chave = SHA-256 do e-mail normalizado; sem e-mail → `None`) e `ThrottleLoginPorIp` (`scope = "login_ip"`, `self.get_ident(request)`). Código completo em 08-RESEARCH Pattern 5. Importar `hashlib` e `SimpleRateThrottle`.

### `Web/config/settings.py`

**Analog:** linhas 147-179:
```python
VITRINE_TAXA_ANONIMA = env('VITRINE_TAXA_ANONIMA', default='120/min')
if not re.fullmatch(r'[0-9]+/[smhd][a-z]*', VITRINE_TAXA_ANONIMA):
    raise ImproperlyConfigured(
        f"VITRINE_TAXA_ANONIMA inválida: {VITRINE_TAXA_ANONIMA!r}. Use <número>/<período>, "
        "por exemplo 120/min."
    )
...
    'DEFAULT_THROTTLE_RATES': {
        'vitrine_publica': VITRINE_TAXA_ANONIMA,
    },
```
Replicar para `LOGIN_TAXA_POR_EMAIL` (default `10/hour`) e `LOGIN_TAXA_POR_IP` (`30/hour`), cada um com a mesma validação por regex, e acrescentar `'login_email'`/`'login_ip'` a `DEFAULT_THROTTLE_RATES`. Taxas são decisão de produto (A1 da pesquisa).

### `Web/contas/api/views.py` e `urls.py`

**Analog:** `Web/contas/api/views.py::LoginAPIView` e `urls.py:11`
```python
class LoginAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        usuario = serializer.validated_data["usuario"]
        token, _ = Token.objects.get_or_create(user=usuario)
        return Response({"token": token.key})
```
```python
path("auth/login/", LoginAPIView.as_view(), name="api-login"),
```
Alterar `LoginAPIView`: `authentication_classes = []` e `throttle_classes = [ThrottleLoginPorEmail, ThrottleLoginPorIp]` (a vitrine pública já usa `authentication_classes` vazio, `imoveis/api/views.py` ~340). Adicionar `EuAPIView` (`{"perfil": request.user.perfil}`) e `SairAPIView` (`Token.objects.filter(user=request.user).delete()` → 204), ambas com `authentication_classes = [TokenAuthentication]`; importar `TokenAuthentication` e `status`. Rotas: `path("auth/eu/", ..., name="api-eu")`, `path("auth/sair/", ..., name="api-sair")`. Não reutilizar `UsuarioSerializer`.

### `Web/imoveis/api/views.py` (`ImovelViewSet`) e `Web/imoveis/api/serializers.py`

**Analogs:** `ImovelViewSet` (linhas 67-71) e `PaginacaoVitrine` (linhas 333-334):
```python
class ImovelViewSet(EmpresaScopedQuerySetMixin, viewsets.ModelViewSet):
    serializer_class = ImovelSerializer
    permission_classes = [EhCorretor]
    queryset = IMOVEL_COM_DETALHES
```
```python
class PaginacaoVitrine(PageNumberPagination):
    page_size = IMOVEIS_POR_PAGINA
```
Mudanças (só em `list`; `retrieve/create/update/situacao` intactos): `pagination_class = PaginacaoAcervo`, `get_serializer_class` troca por `ImovelAcervoSerializer` se `self.action == "list"`, `get_queryset` aplica `FiltroImovelForm(self.request.query_params or None, empresa=request.user.empresa, campos=["busca", "situacao"])` **depois** do mixin (AC-5), `annotate(na_vitrine=Exists(Imovel.objects.na_vitrine().filter(pk=OuterRef("pk"))))`, `order_by("-criado_em", "-pk")`. Código completo em 08-RESEARCH Pattern 1. Importar `Exists`, `OuterRef` de `django.db.models` e `FiltroImovelForm` de `..forms`.

**Serializer:** extrair `get_foto_capa` (`imoveis/api/serializers.py:549-556`) para `FotoCapaMixin` compartilhado por `ImovelVitrineSerializer` e `ImovelAcervoSerializer`:
```python
def get_foto_capa(self, imovel):
    fotos = list(imovel.fotos.all())
    if not fotos:
        return None
    foto = next((f for f in fotos if f.capa), fotos[0])
    request = self.context.get("request")
    return request.build_absolute_uri(foto.imagem.url) if request else foto.imagem.url
```
Campos (10, congelados no §14): `id, codigo, titulo, finalidade, preco_venda, preco_aluguel, foto_capa, situacao, meu_imovel, na_vitrine` (`finalidade` é emenda ao D-13).

### Web: testes

**Login/eu/sair** — analog `Web/contas/tests.py::LoginApiTests` (linhas 148-168): `APITestCase`, `criar_empresa()`/`criar_corretor(...)`, `self.client.post(reverse("api-login"), {...})`, `assertEqual(response.status_code, status.HTTP_...)`; `force_authenticate` ou cabeçalho `HTTP_AUTHORIZATION="Token ..."` para eu/sair. Casos: token inválido no login não dá 401; sair apaga o token e novo login gera chave nova; sair idempotente; 401 sem token; gestor/admin em `eu` retornam o perfil.

**Throttle do login** — analog `Web/imoveis/tests.py::VitrineLimiteDeTaxaTests` (1182-1209): `mock.patch.object(Classe, "rate", "2/min", create=True)`, depois `assertEqual(status, 429)`, `assertIn("Retry-After", response)`, `assertIn("detail", response.data)`; `get_rate()` lido do settings; `assertEqual(View.throttle_classes, [...])`. `cache.clear()` no `setUp` e taxa alta fixa nos demais (molde `fixar_taxa_alta`, `imoveis/tests.py:59-68`, Pitfall 9).

**Isolamento e lista** — analog `Web/imoveis/tests.py::ImovelApiTests` (343-376), com `setUp` de duas empresas (`self.imovel_de_fora`) e `test_trocar_id_na_url_nao_abre_imovel_de_outra_empresa` (404). Estender: lista da empresa A não traz imóvel da B (nem com `busca`/`situacao`/`?empresa=<id>`/`?corretor=<id>`), gestor 403, sem token 401, "um campo inválido anula todos os filtros" (`busca` válida + `situacao=XXX`), `assertNumQueries` fixo para 3 vs 25 imóveis, e atualizar `test_lista_apenas_da_propria_empresa` para `response.data["results"]`.

**Allowlist** — analog `VitrineAllowlistExataTests` (`imoveis/tests.py:2393-2412`): conjunto `CHAVES_ITEM = {...}` com igualdade exata (`AcervoAllowlistExataTests` com as 10 chaves + deny-list: `proprietario`, `corretor_responsavel`, `empresa`, `descricao`, `fotos`, `endereco`, `publicado`, `pode_publicar`, `pendencias_para_publicar`, `criado_em`).

## Shared Patterns

### Falhas tipadas por status HTTP (traduzidas no repositório, decididas pelo tipo na UI)
**Fonte:** `lib/data/repositories/perfil_repository_impl.dart:39-57`; exceções em `lib/domain/repositories/perfil_repository.dart:9` (`class PerfilNaoEncontradoException implements Exception { const ...; toString }`).
**Aplicar a:** `autenticacao_repository(.impl)`, `acervo_repository(.impl)`, cubits de login/acervo/sessão. Novas exceções: `CredenciaisInvalidasException`, `LimiteTentativasException({Duration? aguardar})`, falha genérica de rede, `SessaoExpiradaException`, `SemPermissaoException`.

### Cubit com estado freezed, `isClosed` e `Result`
**Fonte:** `lib/presentation/perfis/vitrine_anunciante_cubit.dart:104-122` e `lib/presentation/perfis/vitrine_anunciante_state.dart:11-32`.
```dart
final resultado = await _buscarImoveis(anunciante);
if (isClosed) return;
switch (resultado) {
  case Success(:final data): emit(...);
  case Failure(): emit(const VitrineAnuncianteState.erro());
  case Loading(): break;
}
```
**Aplicar a:** todos os cubits novos. `Result` está em `lib/core/result.dart` (`sealed class Result<T>` com `Loading`/`Success`/`Failure`).

### DI por `injectable`
**Fonte:** `@LazySingleton(as: X)` nas impls (`perfil_repository_impl.dart:19`), `@injectable` em use cases/cubits (`obter_perfil_corretor_usecase.dart:8`, `vitrine_anunciante_cubit.dart:14`). Rodar `dart run build_runner build --delete-conflicting-outputs`. `SessaoCubit` e `ArmazenamentoToken` são `@lazySingleton`.

### Rolagem infinita + rodapé
**Fonte:** `vitrine_screen.dart:109-134` e `rodape_paginacao_lista.dart:9-23`. **Aplicar a:** `acervo_screen.dart`.

### Mesma origem em `next` (credencial nunca sai da origem da API)
**Fonte:** `vitrine_anunciante_remote_datasource.dart:48-63`. **Aplicar a:** `acervo_remote_datasource.dart` e ao `InterceptadorSessao` (anexa `Authorization` só se origem do pedido = base URL; Pattern 6 da pesquisa).

### Material 3, widgets sem `buildX()`
**Fonte:** skill `flutter-frontend` + regras do `CLAUDE.md` do app: construtores `const`, classes `StatelessWidget` extraídas, sem `!` quando evitável, cores do `ColorScheme`, texto do `textTheme`. **Aplicar a:** todo `presentation/`.

### Isolamento por empresa no servidor
**Fonte:** `Web/core/mixins.py::EmpresaScopedQuerySetMixin` (+ `Web/core/permissions.py::EhCorretor`, linha 19, `message = "Este recurso é restrito ao corretor."`). **Aplicar a:** o `ImovelViewSet` (já aplicado; o filtro do formulário vem **depois**).

### Gate por onda (D-18)
`flutter analyze lib` e `flutter test` à mão (linha de base: 774 testes verdes, analyze limpo); `python manage.py test` no repo web (linha de base: 695 testes OK).

## No Analog Found

| Arquivo | Role | Data Flow | Motivo / o que usar |
|---|---|---|---|
| `lib/data/network/interceptador_sessao.dart` | interceptor Dio | request-response | O app não tem interceptor (o `Dio` é público e sem interceptors). Usar o código de 08-RESEARCH Pattern 6 (`InterceptorsWrapper`, `RequestInterceptorHandler.next`, `ErrorInterceptorHandler.reject`, `DioException.copyWith`). |
| `lib/presentation/login/login_screen.dart` (formulário com autofill) | screen | request-response | Não há formulário com `TextField` de credencial; só a `SearchBar`. Usar `AutofillGroup` + `AutofillHints.email/password` (08-RESEARCH Pattern 8; A4 sem verificação). |
| `lib/presentation/sessao/entrada_area_screen.dart` (roteamento por papel) | screen | request-response | Sem tela que roteia por resultado de rede; combinar o padrão do `perfil_corretor_screen.dart` (carregando/erro/"Tentar de novo") com `Navigator.pushReplacement`. |
| `ios/Runner/DebugProfile.entitlements`, `Release.entitlements` | config nativa | — | Não existem `.entitlements` em `ios/Runner`; seguir o README do `flutter_secure_storage` (`keychain-access-groups` com `<array/>`) com `checkpoint:human-verify` em Mac. |
| `ThrottleLoginPorEmail` (chave por corpo da requisição) | throttle | request-response | `ThrottleVitrinePublica` só usa IP (`AnonRateThrottle`); usar `SimpleRateThrottle` conforme 08-RESEARCH Pattern 5. |

## Metadata

**Analog search scope:** `lib/**` e `test/**`, `tool/` do app; `Web/core`, `Web/contas`, `Web/imoveis`, `Web/config` do repo web.
**Files scanned:** ~35 lidos/inspecionados, ~190 listados por `git ls-files`.
**Pattern extraction date:** 2026-11-20
