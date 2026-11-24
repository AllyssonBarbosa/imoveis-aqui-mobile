# Phase 10: Contatos Recebidos e Retorno Anotado (APP 10) - Mapa de Padrões

**Mapeado:** 2026-11-22
**Arquivos analisados:** 47 (novos/modificados, app + web)
**Analogs encontrados:** 45 / 47 (2 sem analog direto)

Dois repos. **App:** `C:/projetos/imoveis-aqui-mobile` (branch `feat/APP10`). **Web:** `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` (main = `8bf4448`; `feat/APP10` nasce no primeiro plano que mexe no Django). Todos os analogs do app abaixo são arquivos versionados (`lib/`, `test/`, `tool/`). Nomes seguem a pesquisa: prefixo `CaixaContatos*` para não colidir com `Contato*` da Phase 6.

## Classificação dos Arquivos

### Web (Django + DRF)

| Arquivo novo/modificado | Papel | Fluxo | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `Web/contatos/api/views.py` (add `PaginacaoContatos`, `resumo`, `imoveis`) | controller (ViewSet) | request-response + CRUD | `Web/imoveis/api/views.py` (`PaginacaoAcervo`, `ImovelViewSet`) | exact |
| `Web/contatos/api/serializers.py` (add `validate`) | serializer | request-response | o próprio `ContatoSerializer` | exact |
| `Web/contatos/tests.py` (ajustar `ids_api`; novas classes) | test | request-response | `IsolamentoTests`, `CaixaDeContatosTests` no mesmo arquivo; `imoveis/tests.py:1410` (paginação) | exact |
| `Web/README.md` (linhas ~188-189) | doc | - | o próprio | exact |

### App: data

| Arquivo | Papel | Fluxo | Analog | Qualidade |
|---|---|---|---|---|
| `lib/data/datasources/caixa_contatos_datasource.dart` | interface datasource | request-response | `acervo_datasource.dart` | exact |
| `lib/data/datasources/caixa_contatos_remote_datasource.dart` | datasource | request-response (+ PATCH) | `acervo_remote_datasource.dart` | exact (+ PATCH novo) |
| `lib/data/datasources/parametros_consulta_contatos.dart` | utility (query params) | transform | `parametros_consulta_acervo.dart` | exact |
| `lib/data/models/contato_recebido_model.dart` | model freezed | transform | `imovel_acervo_model.dart` | exact |
| `lib/data/models/contatos_envelope_model.dart` | model freezed | transform | `acervo_envelope_model.dart` | exact |
| `lib/data/models/resumo_contatos_model.dart`, `imovel_com_contato_model.dart` | model freezed | transform | `acervo_envelope_model.dart` / `imovel_acervo_model.dart` | role-match |
| `lib/data/models/retorno_contato_api.dart` (+ inverso do canal) | utility (extension de wire) | transform | `lib/data/models/canal_contato_api.dart` | exact |
| `lib/data/repositories/caixa_contatos_repository_impl.dart` | repository | request-response | `acervo_repository_impl.dart` | exact (+ 404) |

### App: domain

| Arquivo | Papel | Fluxo | Analog | Qualidade |
|---|---|---|---|---|
| `lib/domain/entities/contato_recebido.dart`, `retorno_contato.dart`, `imovel_com_contato.dart` | entity | - | `imovel_acervo.dart`, `canal_contato.dart` | role-match |
| `lib/domain/entities/consulta_contatos.dart`, `periodo_contatos.dart` | entity (consulta) | - | `consulta_acervo.dart` | exact |
| `lib/domain/entities/pagina_contatos.dart` | entity | - | `pagina_acervo.dart` | exact |
| `lib/domain/repositories/caixa_contatos_repository.dart` | interface | request-response | `acervo_repository.dart` | exact |
| `lib/domain/repositories/falhas_caixa_contatos.dart` (`ContatoNaoEncontradoException`) | exception | - | `falhas_autenticacao.dart` | exact |
| `lib/domain/usecases/buscar_contatos_usecase.dart` | usecase | request-response | `buscar_acervo_usecase.dart` | exact |
| `obter_sem_retorno_usecase.dart`, `listar_imoveis_dos_contatos_usecase.dart`, `anotar_retorno_usecase.dart` | usecase | request-response | `buscar_acervo_usecase.dart` | role-match |

### App: presentation

| Arquivo | Papel | Fluxo | Analog | Qualidade |
|---|---|---|---|---|
| `lib/presentation/contatos/caixa_contatos_cubit.dart` | cubit | request-response + paginação | `lib/presentation/acervo/acervo_cubit.dart` | exact |
| `lib/presentation/contatos/caixa_contatos_state.dart` | state freezed | - | `acervo_state.dart` (+ `contato_state.dart` p/ one-shot) | exact |
| `lib/presentation/contatos/caixa_contatos_screen.dart` | screen | request-response | `acervo_screen.dart` | exact |
| `lib/presentation/contatos/apresentacao_contatos.dart` | utility (textos/rótulos/formato) | transform | `lib/presentation/contato/rotulos_contato.dart` + `acervo/apresentacao_acervo.dart` | role-match |
| `lib/presentation/contatos/widgets/item_contato.dart` | component | - | `acervo/widgets/cartao_imovel_acervo.dart` | role-match |
| `lib/presentation/contatos/widgets/folha_anotar_retorno.dart`, `folha_filtro_imovel.dart` | component (bottom sheet) | event-driven | `contato/widgets/contato_bottom_sheet.dart` | exact |
| `lib/presentation/contatos/widgets/chips_filtros_contatos.dart` | component | event-driven | `vitrine/widgets/chips_filtros_ativos.dart` | exact |
| `lib/presentation/acervo/acervo_screen.dart` (ícone na AppBar) | screen (modificar) | - | o próprio (`aoAbrirImovel` por callback) | exact |
| `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart` (add `mensagemErro`) | component (modificar) | - | o próprio | exact |
| `lib/app_localizacao.dart` + `lib/main.dart` + `pubspec.yaml` | config | - | `lib/main.dart:57-65` | role-match |
| `lib/di/injection.config.dart` | gerado | - | `build_runner` | gerado |

### App: testes e ferramentas

| Arquivo | Papel | Analog | Qualidade |
|---|---|---|---|
| `tool/capturar_fixtures_api.py` (grupo `contatos`) | tool | `capturar_acervo` (l. 395-467) + `capturar_contato` (l. 268) | exact |
| `test/support/api_falsa.dart` (rotas de contatos) | test support | bloco do acervo (l. 264-279) | exact |
| `test/data/contrato_contatos_test.dart` | test | `contrato_acervo_test.dart` | exact |
| `test/data/*caixa_contatos*`, `contato_recebido_model_test`, `parametros_consulta_contatos_test` | test | testes data do acervo | exact |
| `test/presentation/caixa_contatos_cubit_test.dart` | test | `acervo_cubit_test.dart` | exact |
| `test/presentation/caixa_contatos_screen_test.dart`, `caixa_contatos_fluxo_test.dart` | test | `acervo_screen_test.dart`, `acervo_fluxo_test.dart` | exact |
| `test/presentation/seletor_periodo_pt_br_test.dart` | test | - | sem analog (ver abaixo) |

## Atribuições de Padrão

### `Web/contatos/api/views.py` (controller, request-response)

**Analog:** `Web/imoveis/api/views.py` linhas 69-80.

```python
class PaginacaoAcervo(PageNumberPagination):
    """Acervo do corretor: 20 por página, como as vitrines, e o cliente não muda o tamanho (D-10)."""

    page_size = IMOVEIS_POR_PAGINA


class ImovelViewSet(EmpresaScopedQuerySetMixin, viewsets.ModelViewSet):
    ...
    # só `list` pagina: retrieve/create/update e as @action não chamam o paginador
    pagination_class = PaginacaoAcervo
```

**Estado atual a modificar** (`contatos/api/views.py`): `ContatoViewSet(EmpresaScopedQuerySetMixin, ListModelMixin, RetrieveModelMixin, UpdateModelMixin, GenericViewSet)` com `permission_classes = [PertenceAUmaEmpresa]`, `http_method_names = ["get","patch","head","options"]` e `get_queryset` que só aplica `filtrar_contatos` quando `self.action == "list"`. Acrescentar (imports: `action`, `PageNumberPagination`, `Imovel`, `contatos_visiveis_para` de `..servicos`):

```python
CONTATOS_POR_PAGINA = 20

class PaginacaoContatos(PageNumberPagination):
    page_size = CONTATOS_POR_PAGINA

# dentro de ContatoViewSet
pagination_class = PaginacaoContatos

@action(detail=False, methods=["get"])
def resumo(self, request):
    sem_retorno = contatos_visiveis_para(request.user).filter(retorno=Contato.Retorno.PENDENTE).count()
    return Response({"sem_retorno": sem_retorno})

@action(detail=False, methods=["get"])
def imoveis(self, request):
    imoveis = (Imovel.objects.filter(pk__in=contatos_visiveis_para(request.user).values("imovel"))
               .order_by("codigo").values("id", "codigo", "titulo"))
    return Response(list(imoveis))
```

Regra do seletor (mesma do site): `contatos/views.py:46-50`. `resumo`/`imoveis` NÃO chamam `filtrar_contatos` (ignoram `imovel/de/ate`). Rotas `contato-resumo` e `contato-imoveis` são registradas antes do `{pk}` (R2).

### `Web/contatos/api/serializers.py` (endurecimento do PATCH)

**Analog:** o próprio `ContatoSerializer` (l. 11-36; `update` faz `validated_data["retorno"]` e dá `KeyError` com `{}`). Adicionar dentro da classe:

```python
def validate(self, atributos):
    if "retorno" not in atributos:
        raise serializers.ValidationError({"retorno": ["Este campo é obrigatório."]})
    return atributos
```

### `Web/contatos/tests.py` (test)

**Analog:** `ContatoBase` (l. 17-80), `IsolamentoTests` (l. 312-392), `CaixaDeContatosTests` (l. 202), `imoveis/tests.py:1410`.

Helper que quebra com o envelope (l. 70-74): trocar `for item in response.data` por `response.data["results"]`:
```python
def ids_api(self, usuario, **filtros):
    self.client.force_login(usuario)
    response = self.client.get(reverse("contato-list"), filtros)
    self.assertEqual(response.status_code, status.HTTP_200_OK)
    return {item["id"] for item in response.data}   # -> response.data["results"]
```
Cenário de isolamento a copiar (l. 312-327): `setUp` cria `do_corretor1`, `do_corretor2`, `da_outra` (empresa B), `da_empresa` (corretor desativado) via `self.novo_contato(imovel)`. Teste de página pequena (padrão `imoveis/tests.py:1410`):
```python
with mock.patch.object(PaginacaoContatos, "page_size", 1):
    pagina1 = ...; pagina2 = ...
```
Padrão admin/anônimo (l. 378-392): `force_login(self.admin)` -> 403; sem login -> `(401, 403)`. Novas classes: `PaginacaoDaCaixaTests`, `ResumoSemRetornoTests`, `OpcoesDeImovelDaCaixaTests`; estender `AnotarRetornoTests` (PATCH `{}` -> 400) e `IsolamentoTests` (rotas novas).

---

### `lib/data/datasources/caixa_contatos_remote_datasource.dart` (datasource)

**Analog:** `lib/data/datasources/acervo_remote_datasource.dart` (linhas 1-54).

**Imports + classe + seguir** (copiar o desenho):
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/mesma_origem.dart';

@LazySingleton(as: AcervoDataSource)
class AcervoRemoteDataSource implements AcervoDataSource {
  AcervoRemoteDataSource(@Named('autenticado') this._dio);
  final Dio _dio;

  @override
  Future<AcervoEnvelopeModel> buscar(ConsultaAcervo consulta) async {
    final resposta = await _dio.get<Object?>(
      '/api/imoveis/',
      queryParameters: parametrosDaConsultaAcervo(consulta),
    );
    return _lerEnvelope(resposta.data);
  }

  @override
  Future<AcervoEnvelopeModel> seguir(String proximaPagina) async {
    if (!mesmaOrigem(Uri.parse(proximaPagina), Uri.parse(_dio.options.baseUrl))) {
      throw const FormatException('URL "next" ... outra origem ...');
    }
    final resposta = await _dio.get<Object?>(proximaPagina);
    return _lerEnvelope(resposta.data);
  }

  AcervoEnvelopeModel _lerEnvelope(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do acervo não é um objeto JSON.');
    }
    return AcervoEnvelopeModel.fromJson(corpo);
  }
}
```
Fino de propósito: não captura `DioException`, não loga. Novos métodos: `contarSemRetorno()` (`GET /api/contatos/resumo/`), `listarImoveis()` (`GET /api/contatos/imoveis/`, corpo é `List`, não `Map`), `anotarRetorno(id, retorno)` (`PATCH '/api/contatos/$id/'` com `data: {'retorno': valorApi}`; barra final obrigatória, `followRedirects:false`). Sem analog de PATCH no app: usar o exemplo de R7/Code Examples da pesquisa.

### `lib/data/datasources/parametros_consulta_contatos.dart` (utility)

**Analog:** `parametros_consulta_acervo.dart` (linhas 12-19):
```dart
Map<String, String> parametrosDaConsultaAcervo(ConsultaAcervo consulta) {
  final params = <String, String>{};
  final busca = consulta.busca.trim();
  if (busca.isNotEmpty) params['busca'] = busca;
  ...
  return params;
}
```
Aplicar: `imovel` (id) e `de`/`ate` (`AAAA-MM-DD` do `DateTime` local, sem `toUtc()`); vazio não gera chave.

### Models (`contato_recebido_model.dart`, `contatos_envelope_model.dart`, ...)

**Analog envelope:** `acervo_envelope_model.dart` (l. 1-31):
```dart
@freezed
abstract class AcervoEnvelopeModel with _$AcervoEnvelopeModel {
  const AcervoEnvelopeModel._();
  const factory AcervoEnvelopeModel({
    String? next, String? previous, required List<ImovelAcervoModel> results,
  }) = _AcervoEnvelopeModel;
  factory AcervoEnvelopeModel.fromJson(Map<String, Object?> json) => _$AcervoEnvelopeModelFromJson(json);
  PaginaAcervo paraPagina() => PaginaAcervo(itens: results.map((m) => m.paraEntidade()).toList(), proximaPagina: next);
}
```
**Analog item com enum** `imovel_acervo_model.dart` (l. 15-65): `@JsonKey(name: 'preco_venda')`, `paraEntidade()`, e enum obrigatório desconhecido -> `FormatException`:
```dart
static FinalidadeImovel _mapearFinalidade(String valor) {
  switch (valor) { case 'VENDA': return ...; default: throw FormatException('finalidade desconhecida: $valor'); }
}
```
Aplicar a `canal` (`WHATSAPP/TELEFONE/EMAIL`) e `retorno` (5 valores). `criado_em`/`retorno_em`: `DateTime.parse(...).toLocal()` num único ponto (`paraEntidade`). Item tem 12 chaves; o app lê `id`, `imovel_codigo`, `imovel_titulo`, `canal`, `criado_em`, `retorno`, `retorno_em` (chaves a mais são ignoradas). Resumo: `{sem_retorno:int}`; imóvel: `{id, codigo, titulo}`.

**Wire do enum** `canal_contato_api.dart` (l. 5-11) só tem enum -> wire:
```dart
extension CanalContatoNaApi on CanalContato {
  String get valorApi => switch (this) {
    CanalContato.whatsapp => 'WHATSAPP', CanalContato.telefone => 'TELEFONE', CanalContato.email => 'EMAIL',
  };
}
```
Criar o inverso (`deValorApi`) e `retorno_contato_api.dart` (`valorApi` + inverso) em `data/`, com `switch` exaustivo; os valores do wire só vivem em `data/`.

### `lib/data/repositories/caixa_contatos_repository_impl.dart` (repository)

**Analog:** `acervo_repository_impl.dart` (l. 37-58), cadeia única `_executar`:
```dart
try {
  final envelope = await acao();
  return Result.success(envelope.paraPagina());
} on SessaoExpiradaException {
  return Result.failure(const SessaoExpiradaException());
} on DioException catch (erro) {
  if (erro.error is SessaoExpiradaException) return Result.failure(const SessaoExpiradaException());
  if (erro.response?.statusCode == 403) return Result.failure(const SemPermissaoException());
  return Result.failure(erro);
} on TypeError catch (erro) {
  return Result.failure(FormatException('acervo malformado: $erro'));
} on Exception catch (erro) {
  return Result.failure(erro);
}
```
Tornar `_executar` genérico (`<T>`) para servir lista, resumo, imóveis e PATCH. Acrescentar `404 -> ContatoNaoEncontradoException` (criar em `falhas_caixa_contatos.dart` no estilo `falhas_autenticacao.dart`: `class X implements Exception { const X(); @override String toString() => '...'; }`). O 404 só vale para o PATCH (a `?page=` inválida na lista também dá 404, mas aí o app só segue `next` válido).

### Domain (interface, use cases, entidades)

**Interface** `acervo_repository.dart` (l. 8-17): métodos `Future<Result<PaginaAcervo>> buscar(ConsultaAcervo)` e `seguir(String)`. **Use case** `buscar_acervo_usecase.dart` (l. 10-21):
```dart
@injectable
class BuscarAcervoUseCase {
  BuscarAcervoUseCase(this._repositorio);
  final AcervoRepository _repositorio;
  Future<Result<PaginaAcervo>> call(ConsultaAcervo consulta) => _repositorio.buscar(consulta);
  Future<Result<PaginaAcervo>> seguir(String proximaPagina) => _repositorio.seguir(proximaPagina);
}
```
**Entidades:** `ConsultaContatos` copia `consulta_acervo.dart` (classe `const`, `copyWith` com flags `limparImovel`/`limparPeriodo`, `==`/`hashCode`/`toString` manuais); `PaginaContatos` copia `pagina_acervo.dart` (lista `List.unmodifiable`, `proximaPagina` opaco, `ehUltima`). `RetornoContato`: enum + `anotaveis` (4 sem `pendente`). `CanalContato` já existe em `lib/domain/entities/canal_contato.dart` (reusar).

### `lib/presentation/contatos/caixa_contatos_state.dart`

**Analog:** `acervo_state.dart` (l. 11-52): `@freezed abstract class AcervoState` com `@Default(ConteudoAcervo.carregando()) conteudo`, e `@freezed sealed class ConteudoAcervo` com `carregando/vazio/semResultado/erro/sessaoExpirada/carregada({itens, proximaPagina, carregandoMais, erroAoCarregarMais})`. Usar o esqueleto de R8 da pesquisa (`consulta`, `int? semRetorno`, `opcoesDeImovel`, `conteudo`, `AvisoCaixa? aviso`; `CaixaCarregada` ganha `Set<int> anotando`). One-shot de SnackBar: padrão `contato_state.dart` (`ContatoFalhou(motivo)`, enum de motivo com texto em `rotulos_contato.dart`).

### `lib/presentation/contatos/caixa_contatos_cubit.dart`

**Analog:** `acervo_cubit.dart`. Copiar: `@injectable`, `_versaoConsulta`, `isClosed` antes de todo `emit`, `unawaited(...)`, `carregarMais`/`tentarNovamente`/`_carregarProximaPagina`, dedupe por id.

Núcleo da próxima página (l. 109-162):
```dart
final minhaVersao = _versaoConsulta;
emit(state.copyWith(conteudo: conteudo.copyWith(carregandoMais: true, erroAoCarregarMais: false)));
final resultado = await _buscarAcervo.seguir(proximaPagina);
if (minhaVersao != _versaoConsulta || isClosed) return;
switch (resultado) {
  case Success(:final data):
    final idsListados = conteudoAtual.itens.map((i) => i.id).toSet();
    final novos = data.itens.where((i) => !idsListados.contains(i.id));
    emit(...itens: [...conteudoAtual.itens, ...novos]...);
  case Failure(:final erro):
    if (erro is SessaoExpiradaException) { emit(state.copyWith(conteudo: const ConteudoAcervo.sessaoExpirada())); }
    else { emit(... carregandoMais: false, erroAoCarregarMais: true ...); }
  case Loading(): break;
}
```
Reinício de consulta (l. 167-213): `final minhaVersao = ++_versaoConsulta; emit(AcervoState(... carregando)); ...; if (data.itens.isNotEmpty) carregada else if (filtro) semResultado else vazio`. Aplicar com `consulta.temFiltro`. Sem analog: `anotarRetorno` (set `anotando`, limpar `aviso`, 404 recarrega lista e resumo, sucesso sempre dispara `_recarregarResumo` com `_versaoResumo`). Seguir o fluxo de 6 passos de R8.

### `lib/presentation/contatos/caixa_contatos_screen.dart`

**Analog:** `acervo_screen.dart` (completo).

- Construtor com `criarCubit` para teste (l. 29-52): `final criar = criarCubit ?? () => getIt<AcervoCubit>(); BlocProvider(create: (_) => criar()..carregar(), child: _Corpo...)`.
- `_aoSessaoExpirar` (l. 99-109):
```dart
final navegador = Navigator.of(context);
await context.read<SessaoCubit>().encerrarPorExpiracao();
if (!mounted) return;
navegador.pushAndRemoveUntil(
  MaterialPageRoute<void>(builder: (_) => const LoginScreen(aviso: avisoSessaoTerminou)),
  eRotaDaVitrine,
);
```
- `BlocListener` com `listenWhen: anterior.conteudo is! X && atual.conteudo is X` (l. 138-142).
- `ScrollController(keepScrollOffset: false)`, `_aoRolar` a 90%, `_agendarCarregarMaisSeNaoPreencheATela` com `addPostFrameCallback` (l. 66-134), `jumpTo(0)` no listener quando `carregando` (l. 195-200).
- `switch (conteudo)` exaustivo com `ListView.builder(itemCount: itens.length + 1)` e `RodapePaginacaoLista` no último índice (l. 204-253); `_MensagemDoAcervo` (l. 267-299) para vazio/erro com `FilledButton('Tentar de novo')`.
- Em vez de `SearchBar`: linha "N contatos sem retorno" (D-07) + `ChipsFiltrosContatos`.
- Segundo `BlocListener` para SnackBar (`BarraContato`, `barra_contato.dart:47-58`): `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(...)))`. Preferir `if (state.aviso case final aviso?)` a `!`.
- Skill do projeto: sem métodos `Widget buildX()`; extrair `StatelessWidget`; sem `!`; `const` sempre.

**Entrada (modificar `AcervoScreen`):** `AppBar.actions` hoje só tem `IconButton(icon: const Icon(Icons.logout), tooltip: 'Sair', onPressed: () => confirmarESair(context))` (l. 146-152). Inserir antes dele um `IconButton(icon: Icon(Icons.inbox_outlined), tooltip: 'Meus contatos', ...)` com `Navigator.push(MaterialPageRoute)`. Injetar o destino por callback padrão, como `aoAbrirImovel = abrirDetalheImovel` (l. 33), para o teste do acervo não depender de DI.

### `lib/presentation/contatos/widgets/folha_anotar_retorno.dart` e `folha_filtro_imovel.dart`

**Analog:** `contato/widgets/contato_bottom_sheet.dart` (l. 15-55):
```dart
Future<void> mostrarContatoBottomSheet(
  BuildContext context, {required List<CanalContato> canais, required ValueChanged<CanalContato> aoEscolher}) {
  return showModalBottomSheet<void>(
    context: context, showDragHandle: true,
    builder: (contextDoSheet) => SafeArea(child: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('...', style: Theme.of(contextDoSheet).textTheme.titleLarge))),
        for (final canal in canais)
          ListTile(leading: Icon(canal.icone), title: Text(canal.rotulo),
            onTap: () { Navigator.of(contextDoSheet).pop(); aoEscolher(canal); }),
        const SizedBox(height: 8),
      ])));
  );
}
```
Regra: a rota do modal fica fora do `BlocProvider`: capturar callback/Cubit da TELA (`context.read`) antes de abrir e passar por valor. Folha de anotação: 4 `ListTile` com a atual marcada (`trailing: Icon(Icons.check)`); um toque já grava (sem Salvar). Folha de imóvel: "Todos os imóveis" + "código — título"; carga preguiçosa ao abrir (R3); erro/carregando como estados da folha (via `BlocBuilder` no `builder`).

### `lib/presentation/contatos/widgets/chips_filtros_contatos.dart`

**Analog:** `vitrine/widgets/chips_filtros_ativos.dart` (l. 31-54): `SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(...))` com
```dart
InputChip(
  label: Text(chip.rotulo),
  onPressed: aoTocar,
  onDeleted: () => aoRemover(chip.filtro),
  deleteButtonTooltipMessage: 'Remover filtro ${chip.rotulo}',
),
```
Diferença: os chips "Imóvel" e "Período" ficam sempre visíveis; sem valor, `onDeleted: null` e `selected: false`; com valor, `selected: true`. Seletor de período: `showDateRangePicker` (exemplo em R5; `firstDate: DateTime(2024)`, `lastDate` = hoje).

### `lib/presentation/contatos/apresentacao_contatos.dart` e `widgets/item_contato.dart`

**Analog:** `contato/rotulos_contato.dart` (l. 10-39): extensões sobre enum com `switch` exaustivo e textos fixos.
```dart
extension ApresentacaoCanalContato on CanalContato {
  String get rotulo => switch (this) { whatsapp => 'WhatsApp', telefone => 'Ligar', email => 'Enviar e-mail' };
  IconData get icone => switch (this) { whatsapp => Icons.chat, telefone => Icons.call, email => Icons.email_outlined };
}
```
Reusar só `.icone` (importar `rotulos_contato.dart`). O `.rotulo` é de ação e NÃO serve (D-09): criar extensão nova com nome de exibição ("WhatsApp", "Telefone", "E-mail"), rótulo de retorno (D-10), textos de estado (D-21), `switch` exaustivo sobre `AvisoCaixa` (D-17) e `DateFormat('dd/MM/yyyy HH:mm')` SEM locale (R5). Textos de tela como constantes de topo (padrão `tituloAcervo`, `textoAcervoVazio` em `apresentacao_acervo.dart`). Cores só de `Theme.of(context).colorScheme` (ex.: `secondaryContainer` para o chip "Aguardando retorno").

### `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart` (modificar)

Texto fixo na linha 47: `'Não foi possível carregar mais imóveis'`. Adicionar `this.mensagemErro = 'Não foi possível carregar mais imóveis'` ao construtor (l. 10-16) e usá-lo em `Text(mensagemErro, ...)`. O padrão preserva acervo e vitrine.

### `lib/main.dart` + `lib/app_localizacao.dart` + `pubspec.yaml`

**Analog (modificar):** `lib/main.dart` linhas 57-65:
```dart
return BlocProvider<SessaoCubit>.value(
  value: _sessao,
  child: MaterialApp(
    title: 'Imóveis Aqui',
    theme: AppTheme.tema,
    home: const _TelaInicial(),
  ),
);
```
Acrescentar `localizationsDelegates: delegatesDeLocalizacao` (= `GlobalMaterialLocalizations.delegates`) e `supportedLocales: localesSuportados` (= `const [Locale('pt', 'BR')]`) vindos de `lib/app_localizacao.dart`, para o teste do seletor usar a mesma configuração. `pubspec.yaml` -> `dependencies: flutter_localizations: sdk: flutter`.

### Testes e ferramentas do app

- **`test/support/api_falsa.dart`:** inserir antes do bloco do acervo (l. 264-279) rotas de contatos, no mesmo desenho (checar token, senão `erro_401.json`/401):
```dart
if (uri.path == '/api/imoveis/' && opcoes.method == 'GET') {
  if (!_temToken(opcoes)) return _corpoJson(lerFixtureApi('erro_401.json'), 401);
  final String fixture;
  if (uri.queryParameters['page'] == '2') { fixture = 'acervo_p2.json'; } ...
  return _corpoJson(lerFixtureApi(fixture), 200);
}
```
  Novas: `GET /api/contatos/` (p1; `page=2` -> p2; `imovel` -> filtrada; `de`/`ate` -> vazia), `GET /api/contatos/resumo/`, `GET /api/contatos/imoveis/`, `PATCH /api/contatos/<id>/` (fixture para o id capturado, 404 para outro; usar regex `^/api/contatos/(\d+)/$` como `_idDoContatoDeImovel`, l. 355-360). Atualizar o comentário de cabeçalho da classe (l. 96-125). `falharProximas('/api/contatos/', status: 500)` e `responder(...)` já cobrem falhas/401 nos testes.
- **`tool/capturar_fixtures_api.py`:** novo `capturar_contatos` no estilo `capturar_acervo` (l. 395-467): `_entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")`, `obter(url, token=...)`, `salvar(pasta, nome, dados)`, validações com `raise ErroCaptura(...)`, token nunca vai ao arquivo. Gera >= 21 contatos pelo `postar` público como `capturar_contato` (l. 268). Registrar em `GRUPOS` (l. 470) e no `choices` do argparse (l. 488: `["lista","detalhe","contato","perfis","anunciante","acervo","todos"]`). Não entra em `todos` sem nota.
- **`test/data/contrato_contatos_test.dart`:** copiar `contrato_acervo_test.dart` (l. 20-63): constante `_pastaContrato` apontando para `.planning/phases/01-.../contrato`, conjuntos de chaves exatas (`_chavesEnvelope`, aqui `_chavesItemContato` com 12), exemplos = cópia byte a byte da fixture, lista `_fixturesDeContatos`, grupo "Models leem toda fixture". Cubit: `bloc_test` + `mocktail` como `acervo_cubit_test.dart`; telas: `criarCubit` injetado, como `acervo_screen_test.dart`.
- Gerado: `dart run build_runner build -d` (`*.freezed.dart`, `*.g.dart`, `injection.config.dart`); restaurar com `git checkout --` o que mudar só CRLF (D-29).

## Padrões Compartilhados

### Sessão expirada (401) uniforme
**Fonte:** `acervo_repository_impl.dart:43-48` + `acervo_screen.dart:99-109` + `acervo_cubit.dart:147-149`. **Aplicar a:** repository (todas as 4 chamadas), Cubit (lista, resumo, imóveis, PATCH convergem em `ConteudoCaixa.sessaoExpirada`) e tela (um único `BlocListener`). Todas as rotas usam `@Named('autenticado')`.

### Result tipado e sem `try/catch` na UI
**Fonte:** `acervo_cubit.dart:133-161` (`switch (resultado) { case Success(:final data): ...; case Failure(:final erro): ...; case Loading(): break; }`). Cubit decide só pelo TIPO da falha.

### Texto fixo, nunca string do servidor
**Fonte:** `rotulos_contato.dart:26-39`, `apresentacao_acervo.dart`. **Aplicar a:** SnackBars (D-17), estados (D-21), rótulos de canal e retorno.

### Isolamento multitenant (web)
**Fonte:** `contatos/servicos.py` (`contatos_visiveis_para`, `restringir_ao_perfil`), `EmpresaScopedQuerySetMixin`, `PertenceAUmaEmpresa`. **Aplicar a:** `resumo`, `imoveis` e lista. Testes: padrão `IsolamentoTests` (admin 403, anônimo 401/403, outra empresa isolada).

### Injeção
**Fonte:** `@LazySingleton(as: Interface)` (datasource, repository), `@injectable` (use cases, Cubit); tela aceita `criarCubit`.

## Sem Analog Encontrado

| Arquivo | Papel | Fluxo | Motivo |
|---|---|---|---|
| `PATCH` no datasource + estado `anotando` por item no Cubit | datasource/cubit | request-response com estado por item | O acervo só tem GET e nenhum estado por item em voo. Usar R8 e os Code Examples da pesquisa; o one-shot de aviso segue `ContatoFalhou`/`BarraContato`. |
| `test/presentation/seletor_periodo_pt_br_test.dart` e `showDateRangePicker` | test/UI | event-driven | Nenhum seletor de data no app; nenhum teste usa `localizationsDelegates` (testes montam o próprio `MaterialApp`). Usar R5 (experimento com delegates de `app_localizacao.dart`). |

## Metadados

**Escopo de busca:** `lib/data`, `lib/domain`, `lib/presentation/{acervo,contato,perfis,vitrine,sessao}`, `lib/main.dart`, `test/support`, `test/data`, `tool/`; web `contatos/`, `imoveis/api/views.py`, `imoveis/tests.py`.
**Arquivos lidos:** ~25 (analogs); verificado que `acervo_screen.dart` e testes de acervo são rastreados no git (nenhum espelho gitignored citado).
**Data da extração:** 2026-11-22
