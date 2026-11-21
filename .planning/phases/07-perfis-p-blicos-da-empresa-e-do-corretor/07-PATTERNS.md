# Phase 7: Perfis Públicos da Empresa e do Corretor - Pattern Map

**Mapped:** 2026-11-08
**Files analyzed:** 38 (novos) + 7 (existentes tocados)
**Analogs found:** 36 / 38 (2 parciais)
**Nota:** todos os analogs são arquivos rastreados em `lib/` e `test/` (nenhum espelho/gerado ignorado). Caminhos relativos a `C:/projetos/imoveis-aqui-mobile/`. Trabalho paralelo da Phase 5 (DataSources/DI) em outra branch: ver a seção "Arquivos EXISTENTES tocados" e a lista "NÃO TOCAR".

## ATENÇÃO — arquivos EXISTENTES que esta fase toca (risco de merge com a Phase 5)

| Arquivo existente | Mudança | Risco |
|---|---|---|
| `lib/di/injection.config.dart` | **regenerado** por `dart run build_runner build --delete-conflicting-outputs`; nunca editar à mão. No merge com a Phase 5: resolver **regenerando** | ALTO (ponto quente) |
| `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` | vira `export '../perfis/perfil_corretor_screen.dart';` (mantém `abrirPerfilCorretor` com assinatura compatível; `detalhe_imovel_screen.dart:12` continua importando daqui) | baixo |
| `.planning/phases/01-.../01-CONTRATO-API.md` | novo §12 (rascunho no RESEARCH) | baixo (doc) |
| `.planning/phases/01-.../contrato/` | 2 exemplos novos (`perfil_corretor.example.json`, `perfil_empresa.example.json`) | baixo |
| `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` | IDs PERF-01..06 e API-08 (D-17) | baixo (doc) |
| `test/presentation/perfil_corretor_screen_test.dart` | reescrever (stub D-15 da F4 deixa de existir) | baixo |
| `test/presentation/detalhe_imovel_screen_test.dart` (1 teste) e `detalhe_navegacao_test.dart` (grupo "fluxo completo") | estender com Cubits/DI falsos | baixo |

### NÃO TOCAR (lista do RESEARCH, mantida visível)
`lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart`, `lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart`, `lib/presentation/vitrine/*` (incl. `vitrine_screen.dart`, `imovel_card.dart`, `apresentacao_imovel.dart`), `lib/data/datasources/imovel_*_datasource.dart`, `lib/data/repositories/imovel_*_repository*`, `lib/di/modulo_rede.dart`, `lib/data/mocks/imoveis_*_fixture.dart`. Também: `pubspec.yaml`/`pubspec.lock` (sem dependência nova; `git diff --exit-code` ao final).
Consequência: tudo que a fase precisa deles é obtido por **reuso/leitura** (ex.: `detalhesAcervoFixture()` e `linhasAcervoFixture()` são apenas chamadas) ou por **cópia para arquivo novo** (ex.: rodapé de paginação, que é privado em `vitrine_screen.dart`).

## File Classification

| Arquivo novo | Role | Data Flow | Analog mais próximo | Qualidade |
|---|---|---|---|---|
| `lib/domain/entities/perfil_corretor.dart`, `perfil_empresa.dart` (+ `TipoEmpresa`), `anunciante_ref.dart` | entidade (freezed) | transform | `lib/domain/entities/detalhe_imovel.dart` (`CorretorResponsavel`) | role-match |
| `lib/domain/repositories/perfil_repository.dart` (+ `PerfilNaoEncontradoException`) | repository (iface) | request-response | `lib/domain/repositories/imovel_detalhe_repository.dart` (`ImovelNaoEncontradoException` na linha 7) | exact |
| `lib/domain/repositories/vitrine_anunciante_repository.dart` | repository (iface) | request-response | `lib/domain/repositories/imovel_repository.dart` | exact |
| `lib/domain/usecases/obter_perfil_corretor_usecase.dart`, `obter_perfil_empresa_usecase.dart`, `buscar_imoveis_do_anunciante_usecase.dart` | usecase | request-response | `lib/domain/usecases/obter_detalhe_imovel_usecase.dart` | exact |
| `lib/data/models/perfil_corretor_model.dart`, `perfil_empresa_model.dart` | model (freezed+json) | transform | `lib/data/models/detalhe_imovel_model.dart` / `imovel_model.dart` | exact |
| `lib/data/models/texto_opcional.dart` | utility | transform | `lib/data/models/url_segura.dart` | exact |
| `lib/data/datasources/perfil_datasource.dart` (iface) | datasource (iface) | request-response | `lib/data/datasources/imovel_detalhe_datasource.dart` | exact |
| `lib/data/datasources/perfil_remote_datasource.dart` | datasource (Dio) | request-response | `lib/data/datasources/cidade_remote_datasource.dart` | role-match |
| `lib/data/datasources/perfil_mock_datasource.dart` | datasource (mock) | request-response | `lib/data/datasources/imovel_detalhe_mock_datasource.dart` | exact |
| `lib/data/datasources/vitrine_anunciante_datasource.dart` (iface + `parametrosDoAnunciante`) | datasource (iface) | request-response | `lib/data/datasources/imovel_datasource.dart` + `parametros_consulta_imoveis.dart` | exact |
| `lib/data/datasources/vitrine_anunciante_mock_datasource.dart` | datasource (mock, paginado por cursor) | request-response | `lib/data/datasources/imovel_mock_datasource.dart` | exact |
| `lib/data/mocks/perfis_fixture.dart` | fixture | batch | `lib/data/mocks/imoveis_detalhe_fixture.dart` | exact |
| `lib/data/repositories/perfil_repository_impl.dart` | repository impl | request-response | `lib/data/repositories/imovel_detalhe_repository_impl.dart` | exact |
| `lib/data/repositories/vitrine_anunciante_repository_impl.dart` | repository impl | request-response | `lib/data/repositories/imovel_repository_impl.dart` | exact |
| `lib/presentation/perfis/perfil_state.dart` | state (freezed) | event-driven | `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart` | exact |
| `lib/presentation/perfis/perfil_corretor_cubit.dart`, `perfil_empresa_cubit.dart` | cubit | request-response | `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` | exact |
| `lib/presentation/perfis/vitrine_anunciante_cubit.dart` + `_state.dart` | cubit (paginado) | request-response | `lib/presentation/vitrine/vitrine_cubit.dart` (acumula páginas, `carregarMais`) | role-match |
| `lib/presentation/perfis/perfil_corretor_screen.dart` (`abrirPerfilCorretor`) | screen + navegação | request-response | `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:31-45` (`abrirDetalheImovel`) + stub atual | exact |
| `lib/presentation/perfis/perfil_empresa_screen.dart` (`abrirPerfilEmpresa`) | screen + navegação | request-response | idem | exact |
| `lib/presentation/perfis/apresentacao_perfil.dart` | utility (funções puras) | transform | `lib/presentation/detalhe_imovel/apresentacao_natureza.dart` | exact |
| `lib/presentation/perfis/widgets/corpo_perfil_com_vitrine.dart` | component (ScrollController + paginação) | event-driven | `lib/presentation/vitrine/vitrine_screen.dart:55-133` (`_aoRolar`, `_agendarCarregarMais...`) | role-match |
| `.../widgets/rodape_paginacao_lista.dart` | component | event-driven | `_RodapePaginacao` em `vitrine_screen.dart:371-434` (privado: **copiar**, não editar) | exact |
| `.../widgets/sliver_imoveis_anunciante.dart` | component (sliver) | request-response | `vitrine_screen.dart` (lista) + `lib/presentation/vitrine/widgets/imovel_card.dart` | role-match |
| `.../widgets/cabecalho_corretor.dart`, `cabecalho_empresa.dart` | component | transform | `PerfilCorretorScreen` atual (`perfil_corretor_screen.dart:53-73`) | role-match |
| `.../widgets/cartao_empresa.dart` | component | event-driven | `CartaoCorretor` (`cartao_corretor.dart:56-92`) | exact |
| `.../widgets/secao_contato.dart`, `chips_cidades_atuacao.dart`, `aviso_perfil.dart` | component | transform | `lib/presentation/detalhe_imovel/widgets/secao_natureza.dart` / `secoes_detalhe.dart` (Wrap+Chip, omitir vazio) | role-match |
| `test/data/perfil_*_test.dart`, `contrato_perfil_test.dart` | test | — | `test/data/cidade_remote_datasource_test.dart` (adaptador falso), `contrato_detalhe_test.dart` | exact |
| `test/presentation/perfil_*_cubit_test.dart` | test | — | `test/presentation/detalhe_imovel_cubit_test.dart` | exact |
| `test/presentation/perfil_*_screen_test.dart` | test | — | `test/presentation/detalhe_imovel_screen_test.dart` | exact |

## Pattern Assignments

### `lib/data/repositories/perfil_repository_impl.dart` (repository impl, request-response)
**Analog:** `lib/data/repositories/imovel_detalhe_repository_impl.dart` (linhas 1-45)

**Imports + injeção** (linhas 1-22):
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/imovel_detalhe_datasource.dart';

@LazySingleton(as: ImovelDetalheRepository)
class ImovelDetalheRepositoryImpl implements ImovelDetalheRepository {
  ImovelDetalheRepositoryImpl(this._dataSource);
  final ImovelDetalheDataSource _dataSource;
```
**Core / erro** (linhas 25-44) — copiar a cadeia de `catch` exatamente nesta ordem:
```dart
try {
  final modelo = await _dataSource.buscarDetalhe(id);
  return Result.success(modelo.paraEntidade());
} on ImovelNaoEncontradoException catch (erro) {
  return Result.failure(erro);
} on DioException catch (erro) {
  if (erro.response?.statusCode == 404) {
    return Result.failure(const ImovelNaoEncontradoException());
  }
  return Result.failure(erro);
} on TypeError catch (erro) {
  // fromJson gerado faz `as` e lança TypeError (Error, não Exception)
  return Result.failure(FormatException('detalhe malformado: $erro'));
} on Exception catch (erro) {
  return Result.failure(erro);
}
```
Adaptar: `PerfilNaoEncontradoException`; um `_executar<T>` genérico serve `buscarCorretor` e `buscarEmpresa` (RESEARCH Pattern 2). O corpo do 404 do DRF é ignorado; decide só por `statusCode == 404`.

### `lib/data/datasources/perfil_remote_datasource.dart` (Dio, request-response)
**Analog:** `lib/data/datasources/cidade_remote_datasource.dart`

**Registro SEM `as:`** (linhas 17-21) — o mock é quem leva `as: PerfilDataSource` enquanto a Phase 5 não troca:
```dart
@lazySingleton
class CidadeRemoteDataSource {
  CidadeRemoteDataSource(this._dio);
  final Dio _dio;
  static const String caminhoCidades = '/api/publico/cidades/';
```
**GET + validação do corpo** (linhas 41-47):
```dart
final resposta = await _dio.get<Object?>(proximaUrl);
final envelope = resposta.data;
if (envelope is! Map<String, dynamic>) {
  throw const FormatException(
    'Corpo de GET /api/publico/cidades/ não é um objeto JSON.',
  );
}
```
Diferença: perfil é objeto único, sem paginação nem `next`; não deixar `DioException` ser capturada aqui (o repositório traduz o 404). Sem `LogInterceptor`.

### `lib/data/datasources/perfil_mock_datasource.dart` (mock, request-response)
**Analog:** `lib/data/datasources/imovel_detalhe_mock_datasource.dart` (linhas 16-51)
```dart
@LazySingleton(as: ImovelDetalheDataSource)
class ImovelDetalheMockDataSource implements ImovelDetalheDataSource {
  ImovelDetalheMockDataSource()
    : _detalhes = detalhesAcervoFixture(),
      _latencia = const Duration(milliseconds: 500);

  @visibleForTesting
  ImovelDetalheMockDataSource.paraTeste({
    required Map<int, Map<String, Object?>> detalhes,
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _detalhes = detalhes,
       // ignore: prefer_initializing_formals
       _latencia = latencia;
  ...
  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    if (_latencia > Duration.zero) await Future<void>.delayed(_latencia);
    if (id == idDetalheFalhaMock) throw const FalhaSimuladaDoMock();
    final mapa = _detalhes[id];
    if (mapa == null) throw const ImovelNaoEncontradoException();
    return DetalheImovelModel.fromJson(mapa);
  }
```
Reusar `FalhaSimuladaDoMock` via `import '...imovel_mock_datasource.dart' show FalhaSimuladaDoMock;` (só import, sem editar). Id desativado: constante pública `idCorretorDesativadoMock = 8` em `perfis_fixture.dart` (serve 404 por `PerfilNaoEncontradoException`). Fixtures por RESEARCH "Fixtures coerentes": corretor 7 completo (`empresa_id: 3`), 8 desativado, 9 com campos vazios (`empresa_id: 4`), empresas 3 (IMOBILIARIA) e 4 (AUTONOMO). Ler `detalhesAcervoFixture()` apenas por chamada, nunca editar `imoveis_detalhe_fixture.dart`.

### `lib/data/models/perfil_corretor_model.dart` / `perfil_empresa_model.dart` (model, transform)
**Analog:** `lib/data/models/imovel_model.dart` (freezed + `@JsonKey`) e `detalhe_imovel_model.dart` (`paraEntidade()` defensivo)
```dart
@freezed
abstract class ImovelModel with _$ImovelModel {
  const ImovelModel._();
  const factory ImovelModel({
    required int id,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    ...
  }) = _ImovelModel;

  factory ImovelModel.fromJson(Map<String, Object?> json) =>
      _$ImovelModelFromJson(json);
```
Aplicar RESEARCH Pattern 1: `@JsonKey(name: 'empresa_id') int? empresaId`, `@JsonKey(name: 'razao_social_ou_nome')`, `@JsonKey(name: 'cidades_atuacao')` com `@Default(<CidadeModel>[])`; **não declarar** `corretores_ativos`. `paraEntidade()` passa fotos/logomarca por `urlHttpOuNula` e textos por `textoOuNulo`. `tipo` desconhecido -> `null` (tolerante, como `_mapearNatureza`); nunca lançar por enum.

### `lib/data/models/texto_opcional.dart` (utility)
**Analog:** `lib/data/models/url_segura.dart` (linhas 8-17) — função pura que nunca lança:
```dart
String? urlHttpOuNula(String? valor) {
  final texto = valor?.trim();
  if (texto == null || texto.isEmpty) return null;
  ...
}
```
`textoOuNulo` segue o mesmo esqueleto (`trim`, vazio -> `null`).

### `lib/presentation/perfis/perfil_state.dart` + cubits (state/cubit, request-response)
**Analog state:** `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart` (linhas 9-21)
```dart
@freezed
sealed class DetalheImovelState with _$DetalheImovelState {
  const factory DetalheImovelState.carregando() = DetalheCarregando;
  const factory DetalheImovelState.carregado(DetalheImovel detalhe) = DetalheCarregado;
  const factory DetalheImovelState.erro() = DetalheErro;
  const factory DetalheImovelState.naoEncontrado() = DetalheNaoEncontrado;
}
```
Recomendado `PerfilState<T>` genérico (RESEARCH) com os mesmos 4 ramos; a tela faz `switch` exaustivo sem ramo abrangente.

**Analog cubit:** `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` (linhas 13-55)
```dart
@injectable
class DetalheImovelCubit extends Cubit<DetalheImovelState> {
  DetalheImovelCubit(this._obterDetalhe) : super(const DetalheImovelState.carregando());
  int? _id;
  Future<void> carregar(int id) { _id = id; return _buscar(id); }
  Future<void> tentarNovamente() async {
    final id = _id;
    if (isClosed || id == null || state is DetalheCarregando) return;
    emit(const DetalheImovelState.carregando());
    await _buscar(id);
  }
  Future<void> _buscar(int id) async {
    final resultado = await _obterDetalhe(id);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data): emit(DetalheImovelState.carregado(data));
      case Failure(:final erro):
        emit(erro is ImovelNaoEncontradoException
            ? const DetalheImovelState.naoEncontrado()
            : const DetalheImovelState.erro());
      case Loading(): break;
    }
  }
}
```
Atenção: com `@injectable` em classe genérica/`Cubit<PerfilState<PerfilCorretor>>` (um cubit por tipo, sem generics no construtor) o gerador funciona; manter `PerfilCorretorCubit` e `PerfilEmpresaCubit` como classes concretas separadas.

### `lib/presentation/perfis/perfil_corretor_screen.dart` e `perfil_empresa_screen.dart` (screen + abertura)
**Analog:** `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` (linhas 19-45)
```dart
typedef AoAbrirImovel = Future<void> Function(BuildContext context, Imovel imovel);

Future<void> abrirDetalheImovel(
  BuildContext context,
  Imovel previa, {
  DetalheImovelCubit Function()? criarCubit,
}) {
  final criar = criarCubit ?? () => getIt<DetalheImovelCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DetalheImovelCubit>(
        create: (_) => criar()..carregar(previa.id),
        child: DetalheImovelScreen(previa: previa),
      ),
    ),
  );
}
```
Único ponto que toca `getIt`; fábricas opcionais só para teste. Importar `AoAbrirImovel`/`abrirDetalheImovel` de `../detalhe_imovel/detalhe_imovel_screen.dart` (D-07). Código completo proposto: RESEARCH Pattern 5 (`MultiBlocProvider` com Cubit de perfil + Cubit da vitrine; **assinatura de `abrirPerfilCorretor(context, CorretorResponsavel, {...})` permanece compatível** com o stub atual de `perfil_corretor_screen.dart:9-13`, por isso `detalhe_imovel_screen.dart` não é editado).

**Prévia (D-05)** — reaproveitar o corpo do stub atual (`perfil_corretor_screen.dart:53-73`) para o estado `carregando`:
```dart
Center(child: AvatarCorretor(foto: corretor.foto, raio: 56, construirImagemDeRede: construirImagemDeRede)),
const SizedBox(height: 16),
Text(corretor.nome, style: textTheme.headlineSmall, textAlign: TextAlign.center),
```
Gancho de teste a repassar até as pontas: `@visibleForTesting final Widget Function(String url)? construirImagemDeRede;` (mesmo comentário/anotação do stub, linhas 37-40).

### `.../widgets/cartao_empresa.dart` (component, event-driven)
**Analog:** `CartaoCorretor` (`lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart:70-91`)
```dart
return Semantics(
  button: true,
  label: 'Ver perfil de ${corretor.nome}',
  child: Card.outlined(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: aoTocar,
      child: ListTile(
        leading: AvatarCorretor(...),
        title: Text(corretor.nome),
        subtitle: const Text('Ver perfil do corretor'),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  ),
);
```
Rótulo único e neutro "Ver página do anunciante" (o perfil do corretor não traz `tipo` da empresa; achado 1 do RESEARCH). Oculto quando `empresaId == null` (D-11). Importar `AvatarCorretor` de `cartao_corretor.dart` (sem editá-lo).

### `.../widgets/corpo_perfil_com_vitrine.dart` + `rodape_paginacao_lista.dart` + `sliver_imoveis_anunciante.dart`
**Analog:** `lib/presentation/vitrine/vitrine_screen.dart`

**Rolagem e paginação** (linhas 61-74, 109-133):
```dart
@override
void initState() { super.initState(); _controleDeRolagem.addListener(_aoRolar); }
@override
void dispose() { _controleDeRolagem..removeListener(_aoRolar)..dispose(); super.dispose(); }

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
Trocar `VitrineCubit` por `VitrineAnuncianteCubit`; guarda extra: só `carregarMais` com o perfil carregado.

**Rodapé (copiar para arquivo novo, parametrizado por `aoTentarDeNovo`)** (linhas 371-434): três ramos mutuamente exclusivos — `carregandoMais` (`CircularProgressIndicator(strokeWidth: 2)` 24x24), `erroAoCarregarMais` ("Não foi possível carregar mais imóveis" + `TextButton` "Tentar de novo"), `!temProximaPagina` ("Você chegou ao fim da lista", `onSurfaceVariant`), senão `SizedBox.shrink()`. Trocar `context.read<VitrineCubit>().tentarNovamente()` por callback.

Vazio: "Nenhum imóvel anunciado no momento." Itens: `ImovelCard` com `onTap` -> `aoAbrirImovel(context, imovel)`. `BlocProvider` NUNCA dentro de `CustomScrollView.slivers`.

### `lib/data/datasources/vitrine_anunciante_datasource.dart` + `_mock_datasource.dart`
**Analogs:** `lib/data/datasources/imovel_datasource.dart` (interface com `buscar` / `seguir(String proximaPagina)`, linhas 7-12), `imovel_mock_datasource.dart` (cursor `base64Url('o=<offset>')`, página de 10, `next` com host `mock.imoveisaqui.local`, `paraTeste`, `_compararPorRecenciaDesc`) e `parametros_consulta_imoveis.dart` (`parametrosDaConsulta` <-> `filtrosDosParametros` simétricos). Parse com `ImoveisEnvelopeModel.fromJson`. Não estender `ImovelMockDataSource` nem `ImovelDataSource` (NÃO TOCAR). Ler os detalhes por `detalhesAcervoFixture()` (fonte única; não duplicar `id % 3`).

### `lib/di` (registro)
**Analog:** `lib/di/injection.config.dart:100-117` — mock com `as:` e remoto sem interface:
```dart
gh.lazySingleton<_i631.ImovelDetalheDataSource>(...)
gh.lazySingleton<_i326.ImovelDataSource>(() => _i609.ImovelMockDataSource())
gh.lazySingleton<_i320.CidadeRemoteDataSource>(() => _i320.CidadeRemoteDataSource(gh<_i361.Dio>()))
```
Só anotações nos arquivos novos + regeneração. Canário: teste "DI real" no molde de `detalhe_navegacao_test.dart:436-453` (`getIt<PerfilDataSource>()` é `PerfilMockDataSource`). A troca da Phase 5 = mover `as: PerfilDataSource` para o remoto + regenerar.

## Shared Patterns

### Erro tipado só em `data/`, UI decide pelo tipo
**Source:** `imovel_detalhe_repository_impl.dart:29-43` e `detalhe_imovel_cubit.dart:44-50`
**Apply to:** `PerfilRepositoryImpl`, `VitrineAnuncianteRepositoryImpl`, os 3 Cubits. Nunca `try/catch` na UI nem decisão por mensagem/status.

### Parse defensivo de campo não confiável
**Source:** `lib/data/models/url_segura.dart:8-17`
**Apply to:** todo `paraEntidade()` (foto, logomarca); `textoOuNulo` para todo texto opcional. Telefone/WhatsApp mostrados como vêm (sem formatar).

### Gancho de teste de imagem
**Source:** `perfil_corretor_screen.dart:37-40` / `cartao_corretor.dart:20-24`
**Apply to:** todas as telas/widgets de perfil que mostram foto/logomarca (via `ImagemRede` de `lib/presentation/comum/imagem_rede.dart`).

### Abertura de tela com Cubit resolvido num ponto só
**Source:** `detalhe_imovel_screen.dart:31-45`
**Apply to:** `abrirPerfilCorretor`, `abrirPerfilEmpresa`.

### Material 3, sem cor fixa, sem função que retorna Widget
`Theme.of(context).colorScheme/textTheme`, `Card.outlined`, `Wrap`+`Chip`, `SelectableText` para contato (D-10, sem `url_launcher`); extrair `StatelessWidget` em vez de métodos `_build...`.

### Testes
- Cubit: `test/presentation/detalhe_imovel_cubit_test.dart` (`bloc_test` + `mocktail`, sem mockito).
- HTTP falso: `HttpClientAdapter` escrito à mão como em `test/data/cidade_remote_datasource_test.dart` (inclui 404).
- Contrato: ler exemplos de `.planning/phases/01-.../contrato/` como `test/data/contrato_detalhe_test.dart:16-24`.
- Telas: `MockCubit` + `construirImagemDeRede` determinístico.

## No Analog Found

| Arquivo | Role | Data Flow | Motivo |
|---|---|---|---|
| `lib/presentation/perfis/widgets/corpo_perfil_com_vitrine.dart` (parte: `CustomScrollView` compartilhado por duas telas, cabeçalho em slivers + lista em sliver) | component | event-driven | A vitrine atual usa `ListView`/lista própria; nenhum `CustomScrollView` com slivers mistos existe. Usar RESEARCH Pattern 6 + lógica de rolagem de `vitrine_screen.dart` |
| `lib/presentation/perfis/widgets/sliver_imoveis_anunciante.dart` (parte sliver) | component | request-response | Nenhum `SliverList.builder` no código; usar RESEARCH Pattern 6 e `ImovelCard` existente |

## Metadata

**Analog search scope:** `lib/data`, `lib/domain`, `lib/presentation`, `lib/di`, `test/`
**Files scanned:** ~25 lidos/greppados
**Pattern extraction date:** 2026-11-08
