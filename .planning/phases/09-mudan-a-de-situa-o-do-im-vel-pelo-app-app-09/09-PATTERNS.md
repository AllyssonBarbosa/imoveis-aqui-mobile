# Phase 9: Mudança de Situação do Imóvel pelo App (APP 09) - Pattern Map

**Mapped:** 2026-11-22
**Files analyzed:** 33 (novos) + 7 (existentes tocados), app + web (condicional)
**Analogs found:** 31 / 33
**Nota:** todos os analogs são arquivos rastreados (`git ls-files` conferido em `lib/` e `test/`). Os de Django foram lidos em `origin/main` do repo `../imoveis-aqui` (clone local está na `feat/APP06`, sem as rotas). Não há espelho gitignored.

## Arquivos EXISTENTES que a fase toca

| Arquivo existente | Mudança | Risco |
|---|---|---|
| `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` | `InkWell` passa a valer para TODO cartão (hoje só `imovel.naVitrine && aoTocar != null`, linhas 43-45) | baixo (atualizar `test/presentation/cartao_imovel_acervo_test.dart`) |
| `lib/presentation/acervo/acervo_screen.dart` | `aoAbrirImovel`/`abrirDetalheImovel` vira `aoAbrirGestao`/`abrirGestaoImovel`; se devolver `true`, chama `recarregar()` (linhas 33, 246-249) | médio |
| `lib/presentation/acervo/acervo_cubit.dart` | + `recarregar()` = `_aplicarConsulta(state.termoBusca, state.situacao)` | baixo |
| `lib/domain/repositories/falhas_autenticacao.dart` | + `MudancaSituacaoRecusadaException(mensagem)` | baixo |
| `lib/di/injection.config.dart`, `*.freezed.dart`, `*.g.dart` | regenerados (`build_runner`); restaurar os que só mudam CRLF com `git checkout --` (D-16) | alto (ponto quente) |
| `test/support/api_falsa.dart` | + 3 rotas (GET detalhe, GET histórico, POST situação) em `_atender` | médio |
| `tool/capturar_fixtures_api.py` | + grupo `situacao` em `GRUPOS` (linha 470) | baixo |
| `.planning/.../01-CONTRATO-API.md`, `REQUIREMENTS.md`, `ROADMAP.md` | §16 e IDs SIT-01..07, API-11 (D-13, D-14) | baixo (doc) |

## File Classification

### App (Flutter), caminhos relativos à raiz do app

| Arquivo novo | Role | Data Flow | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `lib/data/models/imovel_gestao_model.dart` (+ `.freezed/.g`) | model | transform | `lib/data/models/imovel_acervo_model.dart` | exact |
| `lib/data/models/mudanca_situacao_model.dart` (+ `.freezed/.g`) | model | transform | `lib/data/models/imovel_acervo_model.dart` (`_mapearSituacao`) | exact |
| `lib/data/datasources/gestao_imovel_datasource.dart` (iface) | datasource | request-response | `lib/data/datasources/acervo_datasource.dart` | exact |
| `lib/data/datasources/gestao_imovel_remote_datasource.dart` | datasource (Dio autenticado, 1o POST) | request-response | `lib/data/datasources/acervo_remote_datasource.dart` | exact (POST é novo) |
| `lib/data/repositories/gestao_imovel_repository_impl.dart` | repository impl | request-response | `lib/data/repositories/acervo_repository_impl.dart` | exact |
| `lib/domain/repositories/gestao_imovel_repository.dart` | repository (iface) | request-response | `lib/domain/repositories/acervo_repository.dart` | exact |
| `lib/domain/entities/imovel_gestao.dart`, `mudanca_situacao.dart` | entidade | transform | `lib/domain/entities/imovel_acervo.dart` | exact |
| `lib/domain/usecases/obter_imovel_gestao_usecase.dart`, `obter_historico_situacao_usecase.dart`, `mudar_situacao_usecase.dart` | usecase | request-response | `lib/domain/usecases/buscar_acervo_usecase.dart` | exact |
| `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart` + `_state.dart` | cubit (carga paralela + versão) | request-response | `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart` | role-match |
| `lib/presentation/gestao_imovel/mudar_situacao_cubit.dart` + `_state.dart` | cubit (envio, motivo de falha) | request-response | `lib/presentation/contato/contato_cubit.dart` + `contato_state.dart` | exact |
| `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` (+ `abrirGestaoImovel`) | screen | request-response | `lib/presentation/acervo/acervo_screen.dart` (sessão expirada) + `detalhe_imovel_screen.dart` (`abrir...`) | role-match |
| `lib/presentation/gestao_imovel/apresentacao_gestao.dart` | utilitário (textos, data) | transform | `lib/presentation/acervo/apresentacao_acervo.dart` | exact |
| `lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart` | component (bottom sheet) | event-driven | `lib/presentation/contato/widgets/contato_bottom_sheet.dart` | role-match |
| `lib/presentation/gestao_imovel/widgets/cabecalho_gestao.dart` | component | transform | `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` | role-match |
| `lib/presentation/gestao_imovel/widgets/secao_situacao.dart`, `historico_situacao.dart` | component | transform | `cartao_imovel_acervo.dart` (`_MarcaDoCartao`) + `chips_situacao.dart` | role-match |
| `test/data/gestao_imovel_remote_datasource_test.dart`, `..._repository_impl_test.dart`, `contrato_gestao_test.dart`, `imovel_gestao_model_test.dart` | test | request-response | `test/data/acervo_remote_datasource_test.dart`, `acervo_repository_impl_test.dart`, `contrato_acervo_test.dart`, `imovel_acervo_model_test.dart` | exact |
| `test/presentation/gestao_imovel_cubit_test.dart`, `mudar_situacao_cubit_test.dart` | test | — | `test/presentation/contato_cubit_test.dart`, `acervo_cubit_test.dart` | exact |
| `test/presentation/gestao_imovel_screen_test.dart`, `mudar_situacao_sheet_test.dart`, `gestao_fluxo_test.dart` | test | — | `test/presentation/acervo_screen_test.dart`, `acervo_fluxo_test.dart` | exact |
| `test/fixtures/api/imovel_gestao_*.json`, `situacao_200.json`, `historico_*.json`, `erro_400_*.json`, `erro_403_situacao.json`, `erro_404_imovel.json` | fixture | — | `test/fixtures/api/acervo_p1.json`, `erro_403_acervo.json` | exact (capturadas, não à mão) |

### Web (Django, `origin/main`, só se D-08 confirmar lacuna)

| Arquivo | Role | Data Flow | Analog | Qualidade |
|---|---|---|---|---|
| `Web/imoveis/tests.py` + `AppSituacaoApiTests` (L1-L7) | test | request-response | `CorretorMudaSituacaoTests` (`tests.py:3345`) | exact |

## Pattern Assignments

### `gestao_imovel_remote_datasource.dart` (datasource, request-response)

**Analog:** `lib/data/datasources/acervo_remote_datasource.dart`

**Imports + injeção** (linhas 1-22): `Dio` com `@Named('autenticado')`, `@LazySingleton(as: ...)`, fina, não captura `DioException`.
```dart
@LazySingleton(as: AcervoDataSource)
class AcervoRemoteDataSource implements AcervoDataSource {
  AcervoRemoteDataSource(@Named('autenticado') this._dio);
  final Dio _dio;
```

**Core GET + guarda de corpo** (linhas 24-31, 48-53): copiar `_dio.get<Object?>` + `if (corpo is! Map<String, dynamic>) throw const FormatException(...)`. Para o histórico o corpo é `List` (sem envelope): `if (corpo is! List<Object?>) throw FormatException`.
```dart
final resposta = await _dio.get<Object?>('/api/imoveis/$id/');
```
Rota com `id` inteiro e barra final obrigatória (`followRedirects: false`).

**POST (sem analog no app, usar o de RESEARCH Pattern 1):** reusar `codigoDaSituacao` de `lib/data/datasources/parametros_consulta_acervo.dart:23-28` (não duplicar o mapa); omitir `observacao` quando vazia; nunca mandar `null`.
```dart
await _dio.post<Object?>('/api/imoveis/$id/situacao/', data: {
  'situacao': codigoDaSituacao(nova),
  if (observacao.trim().isNotEmpty) 'observacao': observacao.trim(),
});
```

---

### `gestao_imovel_repository_impl.dart` (repository impl, request-response)

**Analog:** `lib/data/repositories/acervo_repository_impl.dart` (linhas 17-58)

**Cadeia de tradução** (linhas 37-58): copiar a ordem (SessaoExpirada direta, `DioException` com `erro.error is SessaoExpiradaException`, status, `TypeError`, `Exception`). Acrescentar os ramos por status:
```dart
} on DioException catch (erro) {
  if (erro.error is SessaoExpiradaException) {
    return Result.failure(const SessaoExpiradaException());
  }
  if (erro.response?.statusCode == 403) {          // aqui: 400 e 403 -> recusa com mensagem
    return Result.failure(const SemPermissaoException());
  }
  return Result.failure(erro);
```
Mudar para: 400/403 -> `MudancaSituacaoRecusadaException(mensagem achatada)` (achatar `detail` String + toda `List<String>` de qualquer chave, `trim`, cortar tamanho; vazio -> `FalhaDeConexaoException`); 404 -> `ImovelNaoEncontradoException` (`lib/domain/repositories/imovel_detalhe_repository.dart:7`, já existe; texto do servidor é inglês, nunca exibir); demais -> `FalhaDeConexaoException`. `_executar` genérico em `T` (o acervo é fixo em `PaginaAcervo`; ver `perfil_repository_impl` da Phase 8, `_executar<T>`). `@LazySingleton(as: GestaoImovelRepository)`.

---

### `gestao_imovel_cubit.dart` + `gestao_imovel_state.dart` (cubit, request-response)

**Analog:** `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart`

**Cubit** (linhas 21-27, 171-213): `@injectable`, token de versão e `isClosed`, `switch` sobre `Result` com `Success/Failure/Loading`, `SessaoExpiradaException` vira estado próprio:
```dart
final minhaVersao = ++_versaoConsulta;
...
if (minhaVersao != _versaoConsulta || isClosed) return;
switch (resultado) {
  case Success(:final data): ...
  case Failure(:final erro):
    emit(state.copyWith(conteudo: erro is SessaoExpiradaException
        ? const ConteudoAcervo.sessaoExpirada() : const ConteudoAcervo.erro()));
  case Loading(): break;
}
```
Diferenças: duas seções (imóvel e histórico) com `Future.wait`; recarga pós-sucesso mantém conteúdo visível; campo `mudou` vira `true` no 200 do POST mesmo que a recarga falhe; `naVitrineConhecido=false` após mudança (Pitfall 2).

**Estado** (`acervo_state.dart:11-52`): `@freezed abstract class` com campos persistentes + `@freezed sealed class` união de desfechos (`carregando | carregado | erro | naoEncontrado | sessaoExpirada`).

---

### `mudar_situacao_cubit.dart` + `mudar_situacao_state.dart` (cubit, request-response)

**Analog:** `lib/presentation/contato/contato_cubit.dart` + `contato_state.dart`

**Guarda de toque duplo + motivo pelo tipo** (contato_cubit.dart:25-47):
```dart
Future<void> contatar(int imovelId, CanalContato canal) async {
  if (isClosed || state is ContatoEnviando) return;
  emit(ContatoState.enviando(canal));
  final resultado = await _contatar(imovelId, canal);
  if (isClosed) return;
  switch (resultado) {
    case Success(): emit(const ContatoState.ocioso());
    case Failure(:final erro): emit(ContatoState.falhou(_motivoDe(erro)));
    case Loading(): emit(const ContatoState.ocioso());
  }
}
MotivoFalhaContato _motivoDe(Exception erro) => switch (erro) {
  CanalIndisponivelException() => MotivoFalhaContato.canalIndisponivel,
  _ => MotivoFalhaContato.generico,
};
```
Aqui: estados `ocioso(escolhida?) | enviando | recusada(mensagem) | falhou(rede) | sessaoExpirada | sucesso(situacao)`; `recusada` carrega a mensagem do servidor (texto, não lógica); `sessaoExpirada` por `SessaoExpiradaException`. Estado de `contato_state.dart:22-32` é o molde freezed (`@freezed sealed class` com `const factory X.nome() = Classe`).

---

### `gestao_imovel_screen.dart` e `abrirGestaoImovel` (screen, request-response)

**Analogs:** `acervo_screen.dart` (sessão expirada) e `detalhe_imovel_screen.dart:31-45` (`abrir...`).

**Sessão expirada** (acervo_screen.dart:96-109, 138-142): copiar, de preferência extraindo helper compartilhado (RESEARCH "Don't Hand-Roll"):
```dart
Future<void> _aoSessaoExpirar() async {
  final navegador = Navigator.of(context);
  await context.read<SessaoCubit>().encerrarPorExpiracao();
  if (!mounted) return;
  navegador.pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const LoginScreen(aviso: avisoSessaoTerminou)),
    eRotaDaVitrine,
  );
}
// BlocListener com listenWhen: anterior is! X && atual is X -> unawaited(_aoSessaoExpirar())
```
**Abridor** (detalhe_imovel_screen.dart:31-45): `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BlocProvider(... create: (_) => criar()..carregar(id))))`, `getIt` só no toque, `criarCubit` injetável para teste. Diferença: devolve `Future<bool>` lendo `cubit.state.mudou` depois do `await push` (RESEARCH Pattern 5), pois o botão voltar do sistema não passa resultado pelo `pop`. "Ver na vitrine" chama `abrirDetalheImovel(context, imovel.paraPrevia())` (`imovel_acervo.dart`) só se `naVitrine`.

**Mensagem central + "Tentar de novo"** (acervo_screen.dart:265-299, `_MensagemDoAcervo`): copiar para erro da primeira carga.

---

### `mudar_situacao_sheet.dart` (component, event-driven)

**Analog:** `lib/presentation/contato/widgets/contato_bottom_sheet.dart` (linhas 15-55)

`showModalBottomSheet<void>` com `showDragHandle: true`, `SafeArea` + `SingleChildScrollView` + `Column(mainAxisSize: min)`. O arquivo documenta (linhas 11-14): a rota do modal fica fora do `BlocProvider`, então o handler vem capturado da TELA (`context.read`) antes de abrir; aqui isso vira `BlocProvider.value(value: cubit)` dentro do `builder` (RESEARCH Pattern 3). Acrescentar `isScrollControlled: true`, `enableDrag: false` e `PopScope(canPop: !enviando)`. Chips: `ChoiceChip` como em `lib/presentation/acervo/widgets/chips_situacao.dart`, iterando as 4 situações (não `opcoesDeSituacao`, que inclui `null` = Todas) com rótulos de `rotuloSituacao` (`apresentacao_acervo.dart:29-34`); a atual com `onSelected: null`. `TextEditingController` no `State` da folha (sobrevive à recusa); `TextField(maxLength: ...)`; erro em `colorScheme.error` com `Text` simples. Sucesso: `BlocListener` fecha a folha com `Navigator.pop`.

---

### `cabecalho_gestao.dart`, `secao_situacao.dart`, `historico_situacao.dart` (components)

**Analog:** `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart`

Reuso direto (linhas 70-103): `ImagemRede(url: fotoCapa, construirImagemDeRede: ...)`, `linhasDePrecoPorFinalidade({finalidade, precoVenda, precoAluguel})`, cores só de `Theme.of(context).colorScheme`, texto só de `textTheme`, `construirImagemDeRede` como ponto de extensão de teste. `_MarcaDoCartao` (linhas 136-163) é o molde da marca de situação. Foto de capa vem do `ImovelAcervo` do cartão (não parsear `fotos` do `ImovelSerializer`). Data: `DateFormat('dd/MM/yyyy HH:mm')` SEM locale sobre `DateTime.parse(...).toLocal()` (locale `pt_BR` lança `LocaleDataException`).

---

### `apresentacao_gestao.dart` (utilitário)

**Analog:** `lib/presentation/acervo/apresentacao_acervo.dart` (linhas 1-47): `const String` de textos fixos no topo e funções puras. Colocar aqui: "Mudar situação", "Confirmar", "Data: hoje", dica da observação, "Situação alterada para <situação>." (situação em minúsculas via `rotuloSituacao(s).toLowerCase()`), "Não foi possível mudar a situação agora. Tente de novo.", "Nenhuma mudança ainda — disponível desde o cadastro.", "Ver na vitrine", `formatarDataHora`.

---

### `AcervoScreen` / `CartaoImovelAcervo` / `AcervoCubit` (modificações)

- Cartão (cartao_imovel_acervo.dart:41-46): trocar a condição por `aoTocar != null`; atualizar o comentário de classe (D-07 da Phase 8 deixa de valer) e `cartao_imovel_acervo_test.dart`.
- Tela (acervo_screen.dart:246-249): `aoTocar: () async { final mudou = await widget.aoAbrirGestao(context, imovel); if (mudou && context.mounted) context.read<AcervoCubit>().recarregar(); }`. Parâmetro injetável como o atual `aoAbrirImovel` (linhas 33, 42).
- Cubit: `void recarregar() => unawaited(_aplicarConsulta(state.termoBusca, state.situacao));` (linhas 35-37 são o molde).

---

### Testes de dados e contrato

**Analog:** `test/data/acervo_remote_datasource_test.dart` (linhas 1-50): `ApiFalsa()`, `lerFixtureApi`, `criarDioAutenticado(InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')))`, `api.requisicoesGravadas.single` (`.metodo`, `.uri.path`, `.cabecalho('Authorization')`); para o POST, `api.chamadas` guarda `corpo` (`ChamadaApiFalsa.corpo`, api_falsa.dart:~205). Erros com `api.responder((uri) => ..., status: 400, fixture: 'erro_400_...json')` (linhas 160-172) e `api.falharProximas('/api/imoveis', status: 500)`. Contrato: `test/data/contrato_acervo_test.dart` (travar o conjunto de chaves das fixtures capturadas).

### `test/support/api_falsa.dart` (estender)

**Analog:** `_atender` (linhas 200+) e os `RegExp` de rota (linhas 356-437): `RegExp(r'^/api/imoveis/(\d+)/$')`, `.../situacao/$`, `.../historico/$`, método por `opcoes.method`. A API falsa precisa aceitar POST e devolver `situacao_200.json`.

### `tool/capturar_fixtures_api.py` (+ grupo `situacao`)

**Analog:** `capturar_acervo` (linha 395) e helpers `obter`/`postar(url, corpo, token, status_esperado)` (linhas 93-117), `_entrar`, `_credencial` (credenciais por variável de ambiente), registro em `GRUPOS` (linha 470) e a docstring de uso (linhas 9, 22). `postar` já existe e aceita `status_esperado=400/403/404`. Capturar contra a `origin/main` extraída com `git archive` em pasta temporária, nunca do clone em `feat/APP06`.

### Web: `AppSituacaoApiTests` (condicional, D-08)

**Analog:** `Web/imoveis/tests.py::CorretorMudaSituacaoTests` (`tests.py:3345`), `APITestCase` com `setUp` de `empresa/corretor/colega/gestor/proprietario/imovel` + `de_fora`; casos:
```python
self.client.force_authenticate(self.colega)
response = self.client.post(reverse("imovel-situacao", args=[self.imovel.pk]), {"situacao": "VENDIDO"}, format="json")
self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
```
Cobrir L1-L7 da RESEARCH (mesma situação, contrato assinado, inválida/ausente, 401, histórico de outra empresa 404, ordem e `alterado_por`, colega + corpo inválido = 403). View de referência: `Web/imoveis/api/views.py` `situacao` (403 -> `get_object` 404 -> serializer 400 -> `mudar_situacao` 400 `{"situacao": erro.messages}` -> 200) e `historico` (lista sem paginação).

## Shared Patterns

### Falhas tipadas por tipo, traduzidas no repositório
**Fonte:** `lib/domain/repositories/falhas_autenticacao.dart` (classes `const ... implements Exception` com `toString`) e `acervo_repository_impl.dart:37-58`.
**Aplicar a:** `gestao_imovel_repository_impl`, os dois cubits. A UI decide só por `switch` no tipo; nunca por status nem texto.

### Cubit com `Result`, `isClosed` e versão
**Fonte:** `acervo_cubit.dart:171-213`, `contato_cubit.dart:25-38`. **Aplicar a:** ambos os cubits novos.

### Sessão expirada (401) volta ao login
**Fonte:** `acervo_screen.dart:96-109`. **Aplicar a:** tela de gestão (carga e envio da folha). Preferir extrair helper.

### DI por injectable
**Fonte:** `@LazySingleton(as: X)` nas impls, `@injectable` em usecases e cubits, `@Named('autenticado')` no `Dio`. Rodar `dart run build_runner build --delete-conflicting-outputs` e restaurar CRLF-only (D-16).

### Material 3 / sem `buildX()`
**Fonte:** `cartao_imovel_acervo.dart`. Classes `StatelessWidget` extraídas, `const`, cores do `ColorScheme`, texto do `textTheme`, português.

### Isolamento no servidor (AC-6)
Decide o Django: `EhCorretor` + queryset da empresa (404) + `pode_mudar_situacao` (403). O app só lê `pode_mudar_situacao` e `na_vitrine`; nunca olha `publicado`/`situacao`/perfil.

## No Analog Found

| Arquivo | Role | Data Flow | Motivo |
|---|---|---|---|
| POST em `gestao_imovel_remote_datasource.dart` | datasource | request-response (escrita) | O app só tinha GET autenticado (e POST público de contato em `contato_remote_datasource.dart`, sem token); usar RESEARCH Pattern 1, com o POST de contato como referência de forma |
| `TextField` com `TextEditingController` em folha de formulário | component | event-driven | Só há `SearchBar` e o formulário do login (`lib/presentation/login/`); usar RESEARCH Pattern 3 |

## Metadata

**Analog search scope:** `lib/data`, `lib/domain`, `lib/presentation/{acervo,contato,detalhe_imovel,sessao}`, `test/data`, `test/presentation`, `test/support`, `tool/`; Django em `origin/main` (`Web/imoveis/api/views.py`, `serializers.py`, `tests.py`).
**Files scanned:** ~30 listados/lidos.
**Pattern extraction date:** 2026-11-22
