# Phase 4: Página do Imóvel — Galeria e Dados da Natureza - Research

**Researched:** 2026-10-12
**Domain:** Flutter (Material 3) — página de detalhe com galeria, união selada por natureza, DataSource mock sobre contrato de wire novo (`GET /api/publico/imoveis/{id}/`)
**Confidence:** HIGH para a arquitetura e padrões do repo (lidos nesta sessão); MEDIUM para os detalhes de UX de gestos (zoom dentro de PageView) e para o contrato do detalhe (depende de sign-off do E2)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Contrato do detalhe (adendo ao contrato da Fase 1)**
- **D-01:** Novo endpoint `GET /api/publico/imoveis/{id}/`, documentado como adendo (§11) em `01-CONTRATO-API.md`, para sign-off do E2. Responde 404 para imóvel inexistente ou não publicado. — **Reversibility:** costly — é contrato compartilhado com WEB 09; mudar depois mexe no serializer Django, no Model e no mock.
- **D-02:** Natureza em **bloco por tipo**: `natureza: "CASA"|"APARTAMENTO"|"TERRENO"|"LOTE"` e um único objeto preenchido entre `casa`, `apartamento`, `terreno`, `lote`. No Dart vira uma sealed class (`DadosNatureza` com 4 variantes). — **Reversibility:** costly — formato de wire compartilhado.
- **D-03:** Prédio e quadra/loteamento vêm **embutidos completos**: `apartamento.predio: {...}` e `lote.quadra: {identificacao, loteamento: {...}}`. Uma chamada só, sem endpoints extras.
- **D-04:** `area_livre` da casa **vem pronta da API** (calculada no Django, regra do WEB 05). O app nunca calcula.
- **D-05:** Campos de cada natureza (nomes snake_case, alinhados aos cards WEB):
  - casa: `area_terreno`, `area_construida`, `area_livre`, `quartos`, `suites`, `banheiros`, `salas`, `vagas`, `pavimentos`, `ano_construcao`, `piscina`, `quintal`, `churrasqueira`, `mobiliada`
  - terreno: `area_total`, `frente`, `fundo`, `laterais`, `topografia` (`PLANO|ACLIVE|DECLIVE`), `murado`, `esquina`, `uso_permitido`
  - apartamento: `andar`, `numero`, `area_privativa`, `area_total`, `quartos`, `suites`, `banheiros`, `vagas`, `varanda`, `posicao_solar`, `predio: {nome, andares, unidades_por_andar, ano, elevadores, portaria_24h, piscina, academia, salao_de_festas, playground}`
  - lote: `numero`, `area`, `frente`, `fundo`, `preco`, `condicoes_parcelamento`, `quadra: {identificacao, loteamento: {nome, incorporadora, infraestrutura: [..], areas_lazer: [..]}}`
  Áreas e valores monetários como **string decimal** (mesma regra F2/D-03).
- **D-06:** Parte comum do detalhe, além do que a lista já tem: `fotos: [{url, capa, ordem}]` (capa primeiro), `preco_condominio`, `preco_iptu`, `descricao`, `caracteristicas: [nome]`, `corretor: {id, nome, foto, slug}` e endereço público (`bairro`, `cidade`, `latitude`, `longitude`; lat/lng já pensando no APP 05). Allowlist pública: sem proprietário, documentos ou dados internos (§6 do contrato).

**Galeria**
- **D-07:** `PageView` com contador "1/N" no canto, capa primeiro.
- **D-08:** Toque abre visualizador em tela cheia com swipe e pinch-zoom (`InteractiveViewer`), sem dependência nova.
- **D-09:** Galeria dentro de `SliverAppBar` colapsável (`CustomScrollView`), botão voltar sempre visível.
- **D-10:** Sem fotos: placeholder já usado na vitrine (`foto_capa_imovel.dart`), sem contador.

**Layout**
- **D-11:** Ordem: título + bairro/cidade + preços → natureza → descrição → características → corretor.
- **D-12:** Sem barra inferior fixa nesta fase (o botão de WhatsApp é do APP 06).
- **D-13:** Natureza: linha de destaques com ícone (quartos, área, vagas, etc.) e depois lista rótulo/valor. Prédio e loteamento ficam num `Card` próprio.
- **D-14:** Campo nulo **omite a linha**. Seção vazia some inteira.

**Corretor e navegação**
- **D-15:** O card do corretor (foto + nome) é tocável e abre uma **tela stub de perfil do corretor** (nome + foto vindos do detalhe), que o APP 07 vai completar.
- **D-16:** A abertura mostra na hora a **prévia que a vitrine já tem** (capa, título, preço) e carrega o detalhe. As seções completas aparecem quando ele chega.
- **D-17:** Erros: 404 mostra "Este imóvel não está mais disponível" com voltar à vitrine; os outros erros mostram "Tentar de novo". Estados explícitos Loading/Success/Failure num Cubit próprio (`DetalheImovelCubit`).
- **D-18:** Navegação por `Navigator.push` + `MaterialPageRoute`, como no resto do app. Sem go_router. O `ImovelCard` ganha `onTap`.

### Claude's Discretion
- Ícones exatos, rótulos de topografia/posição solar, formato das áreas ("120 m²").
- Fixtures do mock: pelo menos um imóvel por natureza, mais um sem fotos e um com campos nulos. Ids batendo com os imóveis do fixture da vitrine.
- Estrutura de pastas em `presentation/detalhe_imovel/`.

### Deferred Ideas (OUT OF SCOPE)
- Barra inferior fixa com preço + botão WhatsApp: APP 06.
- Mapa do imóvel e favoritar: APP 05 (lat/lng já entram no contrato).
- Conteúdo real do perfil do corretor e da empresa: APP 07.
- Deep link e go_router: avaliar quando houver necessidade de links externos.
</user_constraints>

<phase_requirements>
## Phase Requirements

O ROADMAP referencia só `APP-04`, que **não existe** em `REQUIREMENTS.md` (o arquivo tem `DET-01` genérico em "v2"). Proposta de IDs para o planner adicionar a `REQUIREMENTS.md` (seção nova "Página do imóvel (APP04)" em v1; **remover `DET-01` de v2** para não duplicar) e à tabela de rastreabilidade:

| ID | Descrição proposta | Research Support |
|----|--------------------|------------------|
| DET-01 | Tocar num card da vitrine abre a página do imóvel; a abertura mostra de imediato a prévia que a vitrine já tem (capa, título, preço) e carrega o detalhe (D-16, D-18). | `ImovelCard.onTap` + `abrirDetalheImovel`; `DetalheImovelCubit`; seção "Architecture Patterns" |
| DET-02 | A galeria mostra todas as fotos do imóvel começando pela capa, com contador "N/M"; o toque abre visualizador em tela cheia com swipe e pinch-zoom; sem fotos mostra o placeholder, sem contador (D-07..D-10). | `SliverAppBar` + `PageView`; `VisualizadorFotos`; Pitfalls 3-4 |
| DET-03 | A página mostra os preços de venda e/ou aluguel, condomínio e IPTU exatamente como vieram da API (strings decimais formatadas, nunca calculadas). | `apresentacao_imovel.dart` (reuso); Pitfall 7 |
| DET-04 | A página mostra os dados da natureza: casa (terreno, área construída, área livre), terreno (frente, fundo, topografia), apartamento (dados do prédio), lote (quadra e loteamento); campo nulo omite a linha, seção vazia some (D-13, D-14). | `DadosNatureza` selada; `apresentacao_natureza.dart` |
| DET-05 | A página mostra descrição, características e o corretor responsável com foto; o card do corretor abre a tela stub de perfil (D-15). | `CartaoCorretor` + `PerfilCorretorScreen` stub |
| DET-06 | 404 mostra "Este imóvel não está mais disponível" com voltar à vitrine; outros erros mostram "Tentar de novo" (D-17). | `ImovelNaoEncontradoException`; repo impl mapeia 404; Pitfall 5 |
| API-06 | Contrato de `GET /api/publico/imoveis/{id}/` congelado por escrito como adendo §11 do `01-CONTRATO-API.md` + `imovel_detalhe.example.json`, e o app o consome por DataSource trocável (mock honrando o contrato) (D-01..D-06, API-04). | Seção "Contract Addendum §11" |
| API-07 | **Fase 5:** endpoint real `GET /api/publico/imoveis/{id}/` no repo irmão (público, só publicados, serializer com allowlist) + troca da DataSource por DI. | Notas DRF na seção §11; planner deve **acrescentar API-07 à Phase 5 no ROADMAP** (hoje Phase 5 só cita API-03) |
</phase_requirements>

## Summary

A fase constrói uma **fatia vertical completa** (contrato → data → domain → presentation) para o detalhe, espelhando exatamente a fatia da vitrine: `ImovelDataSource` abstrata + mock `@LazySingleton(as:)` sobre mapas de wire parseados pelo mesmo Model que o remoto usará, repositório que devolve `Result<T>`, use case que só delega, Cubit freezed e DI por `injectable`. Tudo o que é necessário já existe no `pubspec.yaml` (freezed 4.0.1, json_serializable 6.14.1, cached_network_image 4.0.2, flutter_bloc 9.1.1, bloc_test 10.0.0, mocktail 1.0.5, dio 5.11.1, intl 0.20.3): **nenhuma dependência nova** (D-08 exige isso). A baseline está verde: `flutter analyze` sem issues e `flutter test` com 382 testes passando em ~14 s (medidos nesta sessão).

Os três pontos de maior risco técnico/de contrato: (1) o **wire de natureza "bloco por tipo"** (`natureza` + um dos blocos `casa|apartamento|terreno|lote`) não é uma união interna-etiquetada, então `unionKey` do freezed **não serve** — o caminho certo é um `DetalheImovelModel` com os quatro blocos nullable e um `paraEntidade()` que faz `switch` em `natureza` e produz a `sealed class DadosNatureza` de domínio; (2) o **contrato do detalhe contradiz o §6 atual** (que proíbe `preco_condominio`/`preco_iptu` na allowlist) e o `corretor.slug` **não existe** no model Django (`Usuario` só tem `id`) — o §11 precisa amendar o §6 explicitamente e marcar `slug` como PENDENTE E2; (3) a galeria tem a armadilha de gestos **InteractiveViewer dentro de PageView** (zoom vs. swipe) e a de **`TypeError` do json_serializable não ser `Exception`** (o `on Exception catch` do repositório não pega).

Pontos de design recomendados que o CONTEXT deixou abertos: DataSource/Repository **separados** para o detalhe (precedente `OpcoesFiltro*`, zero churn nos arquivos/testes da vitrine); falha de rede/404 tipada por `ImovelNaoEncontradoException` (a camada `data/` traduz `DioException` 404 → essa exceção **já agora**, para a Fase 5 não mexer em nada acima); fixture de detalhe com ids curados + **detalhe gerado deterministicamente a partir da linha da lista** para que todo card da vitrine abra algo válido (e uma regra de id reservado para 404/erro, para o human-check ser possível).

**Primary recommendation:** Implementar na ordem contrato (§11 + `imovel_detalhe.example.json`) → domain/data (models, mock, repo, use case, DI) → `DetalheImovelCubit` → UI (galeria/visualizador → seções por natureza → corretor/stub), cada camada com seus testes; `DetalheImovelModel` com 4 blocos nullable + mapeamento para `DadosNatureza` selada; `ImovelNaoEncontradoException` mapeada na camada de dados; nenhuma dependência nova.

## Architectural Responsibility Map

App mobile (sem SSR/CDN próprios): as "tiers" relevantes são Cliente (Flutter), API/Backend (Django, fora deste repo) e Storage de mídia.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Conteúdo do detalhe (preços, natureza, fotos, corretor) | API / Backend | — | "Tudo vem do detalhe da API" (critério 6); app só apresenta |
| `area_livre`, ordem das fotos (capa primeiro), filtro "só publicado", 404 | API / Backend | — | Regra de negócio/decisão no Django (D-04, §6); o app **não** recalcula nem reordena |
| Parse/validação defensiva do JSON (tipos, enums desconhecidos, URLs) | Cliente — `data/` (Model + Repository) | — | Models imutáveis freezed + `fromJson`; erros viram `Result.failure` |
| Mapeamento 404 → "não disponível" | Cliente — `data/` traduz, `presentation/` apresenta | API devolve o status | `DioException`(404) → exceção de domínio; Cubit só vê o tipo |
| Mock do servidor (fixture + 404/erro determinísticos) | Cliente — `data/mocks` (dev-only) | — | Simula o Django; sai na Fase 5 por DI |
| Formatação (R$, "120 m²", rótulos PT) | Cliente — `presentation/` (funções puras) | — | Apresentação, não regra de negócio (padrão `apresentacao_imovel.dart`) |
| Galeria (PageView, contador, visualizador, zoom) | Cliente — `presentation/` | Storage/CDN de mídia (bytes da imagem) | Estado efêmero de UI (índice atual, zoom) fica no widget, não no Cubit |
| Cache de imagem | Cliente (`cached_network_image` → disco) | Servidor de mídia | Já usado na vitrine |
| Estado Loading/Success/NotFound/Error | Cliente — `DetalheImovelCubit` | — | Estado de tela imutável (freezed) |
| Navegação vitrine → detalhe → perfil stub | Cliente — `Navigator.push` | — | D-18 |

## Standard Stack

### Core (todos já no projeto — nenhuma instalação)

| Library | Version (pubspec.lock) | Purpose | Why Standard |
|---------|------------------------|---------|--------------|
| freezed / freezed_annotation | 4.0.1 / 3.1.0 | Models, `sealed class` de domínio (`DadosNatureza`), estado do Cubit | Já é o padrão do repo [VERIFIED: pubspec.lock] |
| json_serializable / json_annotation | 6.14.1 / 4.12.0 | `fromJson` do detalhe e dos blocos | Padrão do repo [VERIFIED: pubspec.lock] |
| flutter_bloc / bloc_test / mocktail | 9.1.1 / 10.0.0 / 1.0.5 | Cubit e testes | Padrão do repo [VERIFIED: pubspec.lock] |
| cached_network_image | 4.0.2 | Fotos da galeria/visualizador/corretor | Já usado em `foto_capa_imovel.dart` [VERIFIED: lib/presentation/vitrine/widgets/foto_capa_imovel.dart:1] |
| dio | 5.11.1 | `DioException` (tradução 404) e testes com `HttpClientAdapter` falso | Já no projeto; real só na Fase 5 [VERIFIED: pubspec.lock] |
| injectable / get_it | 3.0.0 / 9.3.0 | DI do mock, repo, use case, Cubit | Padrão do repo [VERIFIED: lib/di/injection.dart] |
| intl | 0.20.3 | Formatação pt_BR de moeda e m² | Já usado em `formatarPrecoBrl` [VERIFIED: lib/presentation/vitrine/apresentacao_imovel.dart:1-25] |

### Supporting
Nenhuma. `InteractiveViewer`, `PageView`, `SliverAppBar`, `CustomScrollView`, `Card`, `InkWell` são do SDK (Flutter 3.47.5 / Dart 3.13.4 [VERIFIED: `flutter --version`]).

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `InteractiveViewer` | `photo_view` / `extended_image` | **Proibido por D-08** (sem dependência nova). Dá swipe+zoom prontos, mas é pacote novo |
| Model com 4 blocos nullable + `switch` | `@Freezed(unionKey:)` / `JsonConverter` | O wire **não** é união etiquetada (ver Pattern 2); `unionKey` não casa com `natureza` + chave-irmã |
| Datasource separada para o detalhe | Adicionar `buscarDetalhe` a `ImovelDataSource` | Mexe em interface, mock, `paraTeste` e testes da vitrine; a separada espelha `OpcoesFiltro*` |

**Installation:** nenhuma. Após criar models/DI: `dart run build_runner build -d` (regenera `*.freezed.dart`, `*.g.dart` e `lib/di/injection.config.dart`).

**Version verification:** versões lidas de `pubspec.lock` nesta sessão (não do registry — nenhum pacote novo é recomendado, então o gate de legitimidade não se aplica).

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| *(nenhum pacote novo)* | — | — | — | — | — | — |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none
Esta fase não instala pacotes externos (D-08). Se o planner sentir vontade de adicionar `photo_view` & cia., isso viola D-08.

## Architecture Patterns

### System Architecture Diagram

```
Vitrine (VitrineScreen, lista de Imovel)
   │ toque no ImovelCard (onTap)
   ▼
abrirDetalheImovel(context, Imovel previa)         ← Navigator.push(MaterialPageRoute)
   │  BlocProvider(create: getIt<DetalheImovelCubit>()..carregar(previa.id))
   ▼
DetalheImovelScreen(previa)  ── BlocBuilder<DetalheImovelCubit, DetalheImovelState> ──┐
   │                                                                                   │
   │  carregando  → CustomScrollView: SliverAppBar(capa da prévia) + cabeçalho da      │
   │                prévia (título, bairro/cidade, preço) + indicador de progresso     │
   │  carregado   → SliverAppBar(Galeria PageView + "1/N")  ── toque ─► VisualizadorFotos
   │                cabeçalho + preços(venda/aluguel/cond./IPTU) + SecaoNatureza        │
   │                + descrição + características + CartaoCorretor ─ toque ─► PerfilCorretorScreen (stub)
   │  naoEncontrado → "Este imóvel não está mais disponível" + Voltar (pop)             │
   │  erro        → mensagem + "Tentar de novo" → cubit.tentarNovamente()               │
   ▼                                                                                   │
DetalheImovelCubit ──► ObterDetalheImovelUseCase ──► ImovelDetalheRepository (iface)   │
                                                         │                              │
                                       ImovelDetalheRepositoryImpl (data/)              │
                                         · try/catch: DioException 404 → ImovelNaoEncontradoException
                                         · TypeError → FormatException
                                         · Result.success(model.paraEntidade()) / Result.failure(e)
                                                         │
                                       ImovelDetalheDataSource (iface trocável)
                                         ├─ ImovelDetalheMockDataSource (esta fase; fixture de wire)
                                         └─ ImovelDetalheRemoteDataSource (Fase 5; dio GET /api/publico/imoveis/{id}/)
                                                         │
                              Map<String,Object?> de wire ─► DetalheImovelModel.fromJson
                                                         ▼
                              DetalheImovel (entidade) com DadosNatureza (sealed: Casa|Apartamento|Terreno|Lote)
```

### Recommended Project Structure
```
lib/
├── domain/
│   ├── entities/
│   │   ├── detalhe_imovel.dart          # DetalheImovel, FotoImovel, CorretorResponsavel (freezed)
│   │   └── dados_natureza.dart          # sealed DadosNatureza + DadosPredio, DadosQuadra, DadosLoteamento, Topografia
│   ├── failures/imovel_nao_encontrado_exception.dart   # implements Exception
│   ├── repositories/imovel_detalhe_repository.dart     # Future<Result<DetalheImovel>> buscarDetalhe(int id)
│   └── usecases/obter_detalhe_imovel_usecase.dart      # @injectable, só delega
├── data/
│   ├── models/detalhe_imovel_model.dart (+ foto/corretor/casa/apartamento/predio/terreno/lote/quadra/loteamento)
│   ├── datasources/imovel_detalhe_datasource.dart       # abstract: Future<DetalheImovelModel> buscarDetalhe(int id)
│   ├── datasources/imovel_detalhe_mock_datasource.dart  # @LazySingleton(as: ImovelDetalheDataSource) + .paraTeste
│   ├── mocks/imoveis_detalhe_fixture.dart               # curados + gerados a partir de linhasAcervoFixture()
│   └── repositories/imovel_detalhe_repository_impl.dart # @LazySingleton(as: ImovelDetalheRepository)
└── presentation/detalhe_imovel/
    ├── detalhe_imovel_cubit.dart / detalhe_imovel_state.dart (freezed sealed)
    ├── detalhe_imovel_screen.dart                       # CustomScrollView + switch exaustivo no estado
    ├── abrir_detalhe_imovel.dart                        # push + BlocProvider (usa getIt só no toque)
    ├── apresentacao_natureza.dart                       # funções puras: destaques/linhas por natureza
    ├── perfil_corretor_screen.dart                      # stub (APP 07 completa)
    └── widgets/ galeria_imovel.dart, visualizador_fotos.dart, imagem_rede.dart,
                 secao_natureza.dart, secao_precos.dart, cartao_corretor.dart, ...
```

### Pattern 1: Datasource/Repository separados, espelhando `OpcoesFiltro*`
**What:** `ImovelDetalheDataSource` (interface) + `ImovelDetalheMockDataSource` (`@LazySingleton(as:)`, construtor padrão com latência 500 ms e `.paraTeste({detalhes, latencia})`) + `ImovelDetalheRepositoryImpl` + `ObterDetalheImovelUseCase`.
**When to use:** sempre nesta fase — evita editar `ImovelDataSource`/`ImovelRepository`/mocks da vitrine.
**Example (forma do repositório — estende o padrão lido em `imovel_repository_impl.dart:18-28`):**
```dart
// Source: padrão do repo [VERIFIED: lib/data/repositories/imovel_repository_impl.dart:12-28]
@LazySingleton(as: ImovelDetalheRepository)
class ImovelDetalheRepositoryImpl implements ImovelDetalheRepository {
  ImovelDetalheRepositoryImpl(this._dataSource);
  final ImovelDetalheDataSource _dataSource;

  @override
  Future<Result<DetalheImovel>> buscarDetalhe(int id) async {
    try {
      final modelo = await _dataSource.buscarDetalhe(id);
      return Result.success(modelo.paraEntidade());
    } on DioException catch (erro) {
      if (erro.response?.statusCode == 404) {
        return Result.failure(const ImovelNaoEncontradoException());
      }
      return Result.failure(erro);          // DioException implements Exception
    } on ImovelNaoEncontradoException catch (erro) {
      return Result.failure(erro);          // lançada pelo mock
    } on TypeError catch (erro) {           // json_serializable usa `as` → TypeError NÃO é Exception
      return Result.failure(FormatException('detalhe malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
```

### Pattern 2: Natureza "bloco por tipo" → 4 blocos nullable + `switch` → `sealed class`
**What:** O wire é `{"natureza": "CASA", "casa": {...}, "apartamento": null, ...}`. Não há discriminador **dentro** do objeto que vira a variante; o discriminador (`natureza`) é irmão do bloco. `@Freezed(unionKey: 'natureza')` esperaria `{"natureza": "CASA", ...campos da casa no mesmo nível...}` [CITED: https://pub.dev/packages/freezed — "check the JSON response for a string element called runtimeType … customize key and value with `@Freezed` and `@FreezedUnionValue`"]. O README também não documenta tratamento de valor de união desconhecido (só `JsonConverter` customizado) [CITED: mesma página]. Logo: **não usar união freezed no Model**.
**Recomendado:**
```dart
// data/models/detalhe_imovel_model.dart  (esqueleto; nomes de campo em PT, snake_case no wire)
@freezed
abstract class DetalheImovelModel with _$DetalheImovelModel {
  const DetalheImovelModel._();
  @JsonSerializable(fieldRename: FieldRename.snake)   // alternativa: @JsonKey(name:) campo a campo
  const factory DetalheImovelModel({
    required int id,
    required String titulo,
    required String finalidade,
    String? precoVenda, String? precoAluguel, String? precoCondominio, String? precoIptu,
    required String descricao,
    required String bairro,
    required CidadeModel cidade,
    String? latitude, String? longitude,                 // string decimal (DRF DecimalField)
    @Default(<FotoImovelModel>[]) List<FotoImovelModel> fotos,
    @Default(<String>[]) List<String> caracteristicas,
    CorretorModel? corretor,
    String? natureza,
    CasaModel? casa, ApartamentoModel? apartamento, TerrenoModel? terreno, LoteModel? lote,
  }) = _DetalheImovelModel;

  factory DetalheImovelModel.fromJson(Map<String, Object?> json) => _$DetalheImovelModelFromJson(json);

  DetalheImovel paraEntidade() => DetalheImovel(
    /* … */
    dados: switch (natureza) {
      'CASA'        => casa?.paraEntidade(),          // DadosNatureza.casa(...)
      'APARTAMENTO' => apartamento?.paraEntidade(),
      'TERRENO'     => terreno?.paraEntidade(),
      'LOTE'        => lote?.paraEntidade(),
      _             => null,                           // desconhecida/ausente → seção some (D-14)
    },
  );
}
```
Entidade de domínio (freezed, igual ao `Result`/`FiltrosVitrine` que já usam freezed em `core/`/`domain/`): `sealed class DadosNatureza` com `DadosNatureza.casa(...)`, `.apartamento(...)`, `.terreno(...)`, `.lote(...)`; a UI faz `switch` **exaustivo** sem `default` (convenção de `CidadeSelecaoScreen`). `natureza` desconhecida ou bloco faltando → `dados == null` → seção omitida (forward-compatible, igual a `_mapearNatureza` que devolve `null` em `imovel_model.dart:71-84`). `finalidade` desconhecida continua lançando `FormatException` (igual `imovel_model.dart:58-69`).
`@JsonSerializable(...)` sobre o `factory` é a forma documentada de passar opções ao json_serializable [CITED: https://pub.dev/packages/freezed — "You can pass `@JsonSerializable` annotation by placing it over constructor"]; `fieldRename: FieldRename.snake` especificamente não está no README [ASSUMED] — se o gerador reclamar, usar `@JsonKey(name: 'area_terreno')` campo a campo (estilo atual do repo, `imovel_model.dart:22-29`).
Enums de wire (`topografia`) ficam `String?` no Model; o `paraEntidade()` mapeia para `enum Topografia { plano, aclive, declive }` com desconhecido → `null`.

### Pattern 3: Estado do Cubit — união selada de 4 desfechos
```dart
@freezed
sealed class DetalheImovelState with _$DetalheImovelState {
  const factory DetalheImovelState.carregando() = DetalheCarregando;
  const factory DetalheImovelState.carregado(DetalheImovel detalhe) = DetalheCarregado;
  const factory DetalheImovelState.naoEncontrado() = DetalheNaoEncontrado;   // 404 (D-17)
  const factory DetalheImovelState.erro() = DetalheErro;                      // "Tentar de novo"
}
```
Cubit `@injectable`, mesma disciplina de `VitrineCubit`/`OpcoesFiltroCubit`: `if (isClosed) return;` antes de cada `emit`; `switch (resultado)` com `Success`/`Failure`/`Loading` [VERIFIED: lib/presentation/vitrine/opcoes_filtro_cubit.dart:62-73]. `carregar(int id)` guarda `_id`; `tentarNovamente()` ignora se já `carregando`, emite `carregando` e repete. `Failure(:final erro)` → `erro is ImovelNaoEncontradoException ? naoEncontrado : erro`. Um Cubit por push (novo `getIt<DetalheImovelCubit>()` a cada abertura, `@injectable` = factory) ⇒ não precisa de token de versão de consulta como o `VitrineCubit`.

### Pattern 4: Navegação e testabilidade (padrão `criarXCubit` opcional do repo)
`ImovelCard` ganha `final VoidCallback? onTap` (opcional ⇒ os testes atuais de `imovel_card_test.dart`, que constroem `ImovelCard(imovel: ...)`, continuam válidos) e envolve o conteúdo em `InkWell` **dentro** do `Card` (o `Card` já tem `clipBehavior: Clip.antiAlias`, então o ripple é recortado) [VERIFIED: lib/presentation/vitrine/widgets/imovel_card.dart:28-30]. `VitrineScreen` passa `onTap: () => aoAbrirImovel(context, imovel)`; `aoAbrirImovel` é parâmetro **opcional** com default `abrirDetalheImovel` (que só chama `getIt` **no toque**) — assim os testes existentes de `VitrineScreen`, que não configuram o `getIt`, não quebram, e os novos testes injetam um fake. É o mesmo desenho de `CidadeSelecaoScreen(criarVitrineCubit: …)` [VERIFIED: lib/presentation/cidade_selecao/cidade_selecao_screen.dart:19-41].
O `BlocProvider` do detalhe é criado **dentro da rota empurrada** (a rota nova não herda os providers da vitrine, e não precisa deles). O `Navigator.pop` devolve à vitrine com scroll/filtros intactos (a rota de baixo permanece montada).

### Pattern 5: Galeria no `SliverAppBar`
- `CustomScrollView(slivers: [SliverAppBar(pinned: true, expandedHeight: largura * 9/16 (ou ~300), leading: botão voltar com fundo translúcido, flexibleSpace: FlexibleSpaceBar(background: Galeria)), SliverToBoxAdapter(...)…, SliverPadding(bottom: MediaQuery.padding.bottom + 24)])`. `pinned: true` garante barra (e voltar) sempre visível ao colapsar (D-09). `SliverAppBar.leading` existe [VERIFIED: SDK material/app_bar.dart:197].
- Botão voltar legível sobre qualquer foto: `IconButton.filled` com `backgroundColor: colorScheme.surface.withValues(alpha: 0.8)` (**não** `withOpacity`: `@Deprecated('Use .withValues() to avoid precision loss.')` [VERIFIED: SDK dart:ui painting.dart `withOpacity`]).
- Galeria = `StatefulWidget` com `PageController` e índice atual (estado **efêmero de UI**, não vai para o Cubit): `Stack([PageView.builder(...), Positioned(right: 12, bottom: 12, child: ContadorFotos('${i + 1}/$n'))])`. Contador só se `fotos.length > 0` (D-10: sem fotos, placeholder e **sem** contador). Com 1 foto, mostrar "1/1" (D-07 não diz esconder) — decisão a registrar; recomendado mostrar sempre que houver ≥1 foto.
- Slide = widget de imagem **sem** `AspectRatio` fixo, `fit: BoxFit.cover`. O `FotoCapaImovel` atual embute `AspectRatio(16/9)` [VERIFIED: foto_capa_imovel.dart:27-29]; dentro do `flexibleSpace` (restrições apertadas) isso é frágil. Recomendado extrair `ImagemRede` (url, fit, hook de teste `construirImagemDeRede`) e tornar o placeholder verde (`_PlaceholderCasa`, hoje privado) reutilizável; `FotoCapaImovel` passa a usar os mesmos. Mudança mínima e coberta pelos testes atuais do card.
- Gancho de teste: **`CachedNetworkImage` depende de plugins nativos indisponíveis em `flutter test`** — o repo resolve com `@visibleForTesting construirImagemDeRede` [VERIFIED: foto_capa_imovel.dart:16-23]. Repetir o mesmo gancho em `ImagemRede` e propagá-lo (galeria, visualizador, avatar do corretor).
- Acessibilidade: `Semantics(label: 'Foto ${i+1} de $n')` por slide.

### Pattern 6: Visualizador em tela cheia (sem dependência)
`Navigator.push(MaterialPageRoute(fullscreenDialog: true, builder: …))` → `Scaffold(backgroundColor: Colors.black)` com `PageView.builder` (começa em `indiceInicial`), cada página um `InteractiveViewer(minScale: 1.0, maxScale: 4.0, transformationController: …, child: ImagemRede(fit: BoxFit.contain))`, botão fechar e contador "N/M". Defaults do SDK são `minScale 0.8`/`maxScale 2.5` [VERIFIED: SDK widgets/interactive_viewer.dart:76-80]; sobrescrever (`minScale: 1.0`) para não permitir encolher a foto.
**Conflito swipe × pan:** quando ampliada, o arrasto horizontal deve mover a imagem, não trocar de página. Padrão: um `TransformationController` por página, ouvir `scale = controller.value.getMaxScaleOnAxis()` e, enquanto `scale > 1.0`, passar `physics: NeverScrollableScrollPhysics()` ao `PageView` (e `PageScrollPhysics` caso contrário). A documentação do `InteractiveViewer` não descreve a interação com `PageView` [CITED: https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html — a página não menciona PageView/gesture arena], então essa solução é [ASSUMED] (prática comum) e **deve entrar no human-check** (pinch real em aparelho/emulador). Resetar o zoom ao trocar de página (um `State` por página).

### Pattern 7: Seções por natureza como funções puras
`apresentacao_natureza.dart` (puro Dart, 100% testável sem widget):
- `List<Destaque> destaquesDe(DadosNatureza)` — casa: quartos, banheiros, vagas, área construída; apartamento: quartos, banheiros, vagas, área privativa; terreno: área total, frente, fundo; lote: área, frente, fundo. `Destaque{IconData icone, String valor, String rotulo}`.
- `List<LinhaDado> linhasDe(DadosNatureza)` — rótulo/valor; **campo nulo não gera linha** (D-14); bool `true` → "Sim", `false` → "Não", `null` → omitida (recomendado: `false` é informação).
- `List<LinhaDado> linhasDoPredio(DadosPredio)`; `linhasDoLoteamento(DadosQuadra)` + listas `infraestrutura`/`areas_lazer` (chips, omitidas se vazias).
- Casa **mostra os três**: `area_terreno`, `area_construida`, `area_livre` (critério 2). Terreno: `frente`, `fundo`, `topografia` (+ laterais, murado, esquina, uso_permitido). A UI chama as funções e só desenha; nenhum `if (natureza == …)` espalhado.
- Formatação: `formatarAreaM2(String)` → parse com `double.tryParse`, `NumberFormat` pt_BR sem zeros à direita ("180 m²", "68,5 m²"); valor não parseável volta cru (mesma política de `formatarPrecoBrl`, T-02-01-02). Medidas lineares (frente/fundo/laterais) com " m". `ano`, `andar`, `numero`: texto cru.
- Preços: refatorar `linhasDePreco(Imovel)` para delegar a uma função com parâmetros nomeados (`finalidade`, `precoVenda`, `precoAluguel`) reutilizável pelo detalhe, mantendo a assinatura atual (testes de `apresentacao_imovel_test.dart` seguem verdes). Condomínio: "Condomínio R$ 850/mês" (rótulo "/mês" — condomínio é mensal por natureza); **IPTU: sem sufixo de período** até o E2 definir (ver Open Questions).

### Anti-Patterns to Avoid
- **Calcular `area_livre` (ou qualquer total) no app** — viola D-04/regra do projeto. Teste anti-cálculo (ver Validation Architecture).
- **Reordenar `fotos` no app** pelo campo `ordem`/`capa`: o servidor já entrega em ordem de exibição (`FotoImovel.Meta.ordering = ["ordem","id"]` [VERIFIED: ../imoveis-aqui/Web/imoveis/models.py:132 `ordering = ["ordem", "id"]`]); o contrato §11 deve afirmar "capa primeiro, já ordenado". O app só renderiza na ordem recebida (critério 1 é verificado contra o mock).
- **Um `default:` no `switch` de `DadosNatureza`/`DetalheImovelState`** — perde a checagem de exaustividade.
- **`pumpAndSettle` com `CircularProgressIndicator` na tela** — nunca assenta (o repo já evita: "nunca pumpAndSettle" nos testes de card/vitrine). Usar `pump()` no estado `carregando`.
- **`Color.withOpacity`** (deprecado) — usar `withValues(alpha:)`.
- **`getIt` chamado no `build` de widgets cobertos por testes existentes** — só no toque (default de `aoAbrirImovel`).
- **Misturar estado efêmero de galeria no Cubit** — índice da página/zoom ficam no `State` do widget.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON → objetos tipados | `fromJson` manual com `as` espalhado | `freezed` + `json_serializable` (blocos aninhados nullable) | Constraint "nunca `dynamic`"; geração cobre 40+ campos sem typo |
| Igualdade/`copyWith` das entidades | `==`/`hashCode` à mão (como `Imovel`) | `@freezed` (já usado em `FiltrosVitrine`, `Result`) | `Imovel` é manual por história; novas entidades com ~15 campos + aninhadas não devem repetir |
| Formatação de moeda/área | Concatenar `"R$ "` e vírgulas | `intl` `NumberFormat` pt_BR via `formatarPrecoBrl` (+ `formatarAreaM2`) | Milhares, vírgula e centavos já resolvidos e testados |
| Cache/placeholder/erro de imagem | `Image.network` + estado manual | `CachedNetworkImage` (placeholder + errorWidget) com o gancho de teste existente | Disco, falha de rede e placeholder já padronizados |
| Zoom/pan de foto | Detector de gestos próprio | `InteractiveViewer` (SDK) | D-08; só falta a regra de physics do PageView |
| Tradução HTTP 404 | Checar texto de erro | `DioException.response?.statusCode == 404` na camada `data/` | Estável e testável com `HttpClientAdapter` falso (padrão de `cidade_remote_datasource_test.dart`) |
| Injeção de dependências | Registro manual em `main.dart` | `@injectable` / `@LazySingleton(as:)` + `build_runner` | Padrão do repo |

**Key insight:** o trabalho "difícil" desta fase é de **fronteira** (contrato de wire, 404/erros tipados, null-safety dos campos opcionais) e de **UX de gesto**, não de algoritmo — por isso a maior parte do valor está em Models/fixtures/testes de contrato bem feitos.

## Runtime State Inventory

*(Não é fase de rename/refactor/migração — omitida.)* Única observação de "estado": o `ImovelCard` e `VitrineScreen` são **editados** (não renomeados); nenhuma chave persistida (`shared_preferences`), nenhum dado armazenado muda.

## Contract Addendum §11 (conteúdo a escrever em `01-CONTRATO-API.md`)

Mesmo processo dos §9/§10: "Adendos da Fase 4 (aguardando sign-off do E2)", e **amenda explicitamente o §6** (hoje: "nunca … `preco_condominio`, `preco_iptu`" e a allowlist é "exatamente §3.1 + §3.2" [VERIFIED: 01-CONTRATO-API.md §6, linhas 229-236 lidas]). O §11 deve dizer: *"a allowlist do endpoint de detalhe é a deste §11; `preco_condominio`/`preco_iptu` passam a ser públicos **somente** no detalhe; `corretor` expõe apenas `id`, `nome`, `foto`, `slug`"*.

**Endpoint:** `GET /api/publico/imoveis/{id}/` — `AllowAny`, sem paginação, `id` inteiro (PK). **200** objeto abaixo. **404** (corpo DRF padrão `{"detail": "..."}`) para id inexistente **ou** `publicado=False` (mesma resposta — não permite enumerar rascunhos). Precedente no repo irmão: `EmpresaPublicaAPIView(generics.RetrieveAPIView)` com `AllowAny` e queryset filtrado [VERIFIED: ../imoveis-aqui/Web/empresas/api/views.py:11-16]. Queryset obrigatório `Imovel.objects.filter(publicado=True)`; `select_related("endereco__cidade", "corretor_responsavel")`, `prefetch_related("fotos", "caracteristicas")` [ASSUMED — boa prática, evita N+1; não é decisão do app].

**Campos comuns** (nomes snake_case, decimais como string — mesma regra da Fase 2/D-03):

| Campo | Tipo | Observação |
|-------|------|------------|
| `id`, `titulo`, `finalidade` | int, string, enum | iguais à lista (§3.1) |
| `preco_venda`, `preco_aluguel`, `preco_condominio`, `preco_iptu` | string decimal, nullable | `Imovel.preco_*` existem no model [VERIFIED: imoveis/models.py:50-51 `preco_condominio = models.DecimalField(...)`, `preco_iptu = …`] |
| `descricao` | string | pode ser vazia |
| `bairro`, `cidade{id,nome,uf}` | string, objeto | `Endereco.bairro` / `Endereco.cidade` |
| `latitude`, `longitude` | string decimal, nullable | `Endereco.latitude/longitude` são `DecimalField(max_digits=9, decimal_places=6)` [VERIFIED: core/models.py:20-21] — o DRF serializa `DecimalField` como string por padrão (COERCE_DECIMAL_TO_STRING) [ASSUMED]. **Sem** logradouro/número/CEP (endereço exato não é público) |
| `fotos` | lista `[{url, capa, ordem}]` | **já ordenada para exibição, capa primeiro**; vazia se sem fotos; `url` **absoluta** (`ImageField` só vira URL absoluta se o serializer receber `context={"request": request}` [ASSUMED]) |
| `caracteristicas` | lista de strings | igual à lista |
| `corretor` | `{id, nome, foto, slug}` ou `null` | `foto` nullable (o model faz fallback para `empresa.logomarca` em `dados_perfil_publico()` [VERIFIED: contas/models.py:99-106] — decisão do servidor; o app só exibe). **`slug` NÃO existe em `Usuario`** [VERIFIED: contas/models.py:36-72 — campos: nome, email, perfil, empresa, is_active, is_staff, criado_em, creci, foto, telefone, whatsapp, apresentacao] ⇒ **PENDENTE E2**, nullable no Dart. **Nunca** `email`, `telefone`, `whatsapp`, `creci`, `empresa` neste endpoint (WhatsApp é do APP 06 via mensagem do servidor) |
| `natureza` | enum | `CASA`\|`APARTAMENTO`\|`TERRENO`\|`LOTE` — **PENDENTE E2** (model ainda não tem natureza) |
| `casa` / `apartamento` / `terreno` / `lote` | objeto ou `null` | exatamente um preenchido, coerente com `natureza`; os outros vêm `null` (o app tolera `null` **ou** ausente) |

Blocos conforme D-05 (campos verbatim do CONTEXT). Tipos propostos: áreas/medidas/`preco` do lote = string decimal; contagens/`andar`/`pavimentos`/`ano*` = int; `piscina`, `quintal`, `churrasqueira`, `mobiliada`, `varanda`, `murado`, `esquina`, `portaria_24h`, `academia`, `salao_de_festas`, `playground` = bool; `topografia` enum `PLANO|ACLIVE|DECLIVE`; `infraestrutura`/`areas_lazer` = lista de string; todos os campos de bloco **nullable** (D-14).

**Itens PENDENTES de sign-off do E2 a listar no §11** (não decididos pelo app): (a) `corretor.slug` não existe no model; (b) enum de `posicao_solar` (D-05 não enumera); (c) semântica de período do `preco_iptu` (mensal vs anual); (d) `lote.preco` vs `preco_venda` comum (duplicidade); (e) regra de `area_livre` (WEB 05) e o que fazer quando `area_terreno` ou `area_construida` for nula (`area_livre` deve vir `null`, não 0); (f) `fotos[].url` absoluta; (g) corretor expor `nome`/`foto` publicamente (LGPD) — confirmar com produto.

**Arquivo de exemplo:** `contrato/imovel_detalhe.example.json` (um apartamento completo, ao lado de `imoveis.example.json`); recomendado também `imovel_detalhe_lote.example.json` ou um comentário-lista no §11 mostrando os outros 3 blocos, porque o lote é o mais aninhado (quadra → loteamento → listas).

## Fixtures do mock (Claude's Discretion — recomendação)

Fatos da fixture da lista (lidos): linhas verbatim `42` (APARTAMENTO, VENDA, Campinas), `57` (CASA, ALUGUEL, Campinas), `63` (TERRENO, VENDA_E_ALUGUEL, Valinhos, `foto_capa: null`); linhas geradas com `id = 100*(c+1)+k` (Campinas 100-137, Valinhos 200-238, Vinhedo 300-339), `natureza = k % 4` → 0 APARTAMENTO, 1 CASA, 2 TERRENO, 3 LOTE; `foto_capa == null` quando `k % 5 == 4`; `area == null` quando `k % 10 == 9` [VERIFIED: lib/data/mocks/imoveis_fixture.dart:161-263]. (Deduções: id `103` = LOTE com foto; `104` = APARTAMENTO sem foto; `109` = CASA sem foto e sem área; `119` = LOTE sem foto e sem área — o planner deve reconferir rodando a fixture.)

Recomendação de `imoveis_detalhe_fixture.dart`:
1. **Curados à mão** (mapas de wire completos): `42` apartamento (com `predio` completo, 3+ fotos, condomínio e IPTU), `57` casa (`area_livre` **diferente** de `area_terreno - area_construida`, p.ex. terreno `300.00`, construída `180.00`, livre `100.00` — prova que o app não calcula), `63` terreno (topografia `ACLIVE`, `laterais`), `103` lote (quadra + loteamento com `infraestrutura`/`areas_lazer`), um **sem fotos** (`104` ou `119`, `fotos: []`), um **com campos nulos** (bloco com vários `null`, `preco_condominio: null`, `corretor: null` ou `corretor.foto: null`).
2. **Gerados deterministicamente** para todos os outros ids da lista, a partir da própria linha (`titulo`, preços, `bairro`, `cidade`, `caracteristicas`, `descricao`, `natureza` iguais) + fotos derivadas de `foto_capa` + bloco da natureza com valores determinísticos. Racional: sem isso ~115 dos 120 cards da vitrine abririam 404, e o human-check de fim de fase ficaria inútil. Isso é "servidor simulado", não "dado montado no app" (critério 6): vive só em `data/mocks`.
3. **Ids reservados**: um id da lista (p.ex. `339`) **sem detalhe** ⇒ `ImovelNaoEncontradoException` (simula "despublicado entre a lista e o detalhe"); outro (p.ex. `338`) que sempre lança `FalhaSimuladaDoMock` ⇒ "Tentar de novo". Determinístico (D-15 da Fase 2: nada aleatório). Reutilizar `FalhaSimuladaDoMock` [VERIFIED: imovel_mock_datasource.dart:20-27].
4. Fotos extras: `https://picsum.photos/seed/imovel-<id>-<n>/1200/800` (mesmo host dev-only de `urlBaseFotosMock`); a **primeira** foto = `foto_capa` da lista e `capa: true`. Os ids 42/57 têm `foto_capa` em host fictício (`api.imoveisaqui.exemplo.com`) que não carrega ⇒ cairão no placeholder (aceitável; documentar para o human-check).

## Common Pitfalls

### Pitfall 1: `TypeError` do json_serializable não é `Exception`
**What goes wrong:** campo obrigatório ausente/nulo no wire (`json['titulo'] as String` com `null`) lança `TypeError`; o repositório atual só tem `on Exception catch` ⇒ erro escapa do `Result` e vira exceção não tratada no Cubit/zone.
**Why it happens:** o código gerado usa casts `as` [VERIFIED: lib/data/models/imovel_model.g.dart:11-27 — `titulo: json['titulo'] as String`, `(json['id'] as num).toInt()`]; `TypeError` é `Error`. Nenhum código do repo trata `TypeError` hoje (grep sem ocorrências em `lib`/`test`).
**How to avoid:** `on TypeError` → `FormatException` no `ImovelDetalheRepositoryImpl` (Pattern 1) + teste com JSON malformado. Idem para a Fase 5 (a lista também deveria, mas fora de escopo).
**Warning signs:** teste de "wire malformado" que falha com `TypeError` em vez de `Failure`.

### Pitfall 2: Modelar a natureza com `unionKey` / `default` no switch
**What goes wrong:** `unionKey` não casa com o wire "bloco por tipo"; um valor novo de `natureza` do servidor derruba o parse (freezed não tem fallback documentado).
**How to avoid:** Pattern 2 (blocos nullable + `switch` com `_ => null`); testar `natureza` desconhecida e bloco faltando ⇒ página abre sem a seção.

### Pitfall 3: Zoom do `InteractiveViewer` brigando com o swipe do `PageView`
**What goes wrong:** ampliado, o arrasto horizontal troca de foto em vez de mover a imagem (ou vice-versa).
**How to avoid:** Pattern 6 (physics condicionado ao `scale`); reset de zoom ao trocar de página; **human-check** em dispositivo/emulador com pinch. Testes de widget cobrem swipe e presença do `InteractiveViewer`, não o gesto de pinch real.

### Pitfall 4: Galeria no `flexibleSpace` com `AspectRatio` e botão voltar invisível
**What goes wrong:** `FotoCapaImovel` (AspectRatio 16:9) dentro de restrições apertadas distorce/ignora altura; seta de voltar branca sobre foto clara some.
**How to avoid:** `ImagemRede` sem AspectRatio + `fit: cover`; `leading` com fundo translúcido (`IconButton.filled`); `pinned: true`.

### Pitfall 5: 404 tratado como erro genérico (ou o contrário)
**What goes wrong:** o usuário vê "Tentar de novo" para um imóvel despublicado (repetir nunca resolve) ou "não disponível" para um 500.
**How to avoid:** exceção tipada `ImovelNaoEncontradoException` no domínio; **tradução na camada `data/` agora** (`DioException` com `response?.statusCode == 404`), mock lança a mesma exceção; Cubit só olha o tipo. Na Fase 5, o `RemoteDataSource` apenas deixa a `DioException` subir (dio lança por status ≥ 400 por padrão) e nada acima muda [ASSUMED — comportamento padrão do `validateStatus` do dio; confirmar no teste com `HttpClientAdapter` falso devolvendo 404].

### Pitfall 6: `pumpAndSettle` / `CachedNetworkImage` em teste de widget
**What goes wrong:** `CachedNetworkImage` precisa de plugins nativos; `CircularProgressIndicator` nunca assenta.
**How to avoid:** gancho `construirImagemDeRede` propagado até o `ImagemRede`; `pump()` no estado carregando; `pumpAndSettle` só em estados estáticos (carregado) após swipe.

### Pitfall 7: Preço/área formatados com perda
**What goes wrong:** `double` para `"450000.00"`/`"68.50"` e reformatar pode mostrar "68,5" vs "68,50" ou erro de ponto flutuante em valores grandes.
**How to avoid:** reaproveitar `formatarPrecoBrl` (decisão existente: sem centavos se inteiro); definir e testar `formatarAreaM2` (inteiro sem decimais, senão até 2 casas); valor não parseável volta cru. Nada de soma/subtração.

### Pitfall 8: Prévia (D-16) ≠ detalhe ⇒ "pulo" visual
**What goes wrong:** cabeçalho/preço da prévia muda de layout quando o detalhe chega.
**How to avoid:** mesmo `CustomScrollView` e mesmo widget de cabeçalho nos dois estados (alimentado por prévia ou por detalhe); só as seções abaixo aparecem depois. Teste: o texto do título está presente em `carregando` e em `carregado`.

### Pitfall 9: `build_runner` e disco
**What goes wrong:** durante esta pesquisa uma execução de `flutter test` falhou com `No space left on device` (volume de dados em 99%, 2.2 GiB livres; `build/` do projeto ocupa 1.9 GB) e uma execução anterior ficou sem saída; reexecutada, passou (382 testes). `build_runner build -d` também escreve em `.dart_tool`.
**How to avoid:** o executor deve checar `df -h` antes de rodar `build_runner`/suite completa; liberar espaço é decisão do usuário (não apagar nada sem OK).

### Pitfall 10: Regenerar `injection.config.dart`
**What goes wrong:** esquecer `build_runner` após adicionar `@LazySingleton`/`@injectable` ⇒ `getIt<DetalheImovelCubit>()` falha em runtime (não em compile) [VERIFIED: lib/di/injection.config.dart é arquivo gerado, ex. registra `OpcoesFiltroMockDataSource` nas linhas 85-86].
**How to avoid:** tarefa explícita "rodar `dart run build_runner build -d` e `flutter analyze`" em cada plano que cria anotações; teste de resolução do `getIt` (ou o e2e de navegação) cobre.

## Code Examples

### Estado → UI com `switch` exaustivo (padrão do repo)
```dart
// Source: convenção de CidadeSelecaoScreen [VERIFIED: lib/presentation/cidade_selecao/cidade_selecao_screen.dart:12-16, 44-52]
BlocBuilder<DetalheImovelCubit, DetalheImovelState>(
  builder: (context, state) => switch (state) {
    DetalheCarregando()                  => _Carregando(previa: previa),
    DetalheCarregado(:final detalhe)     => _Conteudo(detalhe: detalhe),
    DetalheNaoEncontrado()               => const _NaoDisponivel(),   // "Este imóvel não está mais disponível" + Voltar
    DetalheErro()                        => _Erro(onTentarDeNovo: context.read<DetalheImovelCubit>().tentarNovamente),
  },
);
```

### Teste de repositório para 404 (padrão `HttpClientAdapter` falso do repo)
```dart
// Source: padrão de test/data/cidade_remote_datasource_test.dart [VERIFIED: _HttpClientAdapterFalso, linhas 25-58]
// Para o 404 basta o dio lançar DioException(response: Response(statusCode: 404)) a partir do adaptador falso,
// ou construir DioException manualmente em um mock de ImovelDetalheDataSource:
when(() => dataSource.buscarDetalhe(any())).thenThrow(
  DioException(requestOptions: RequestOptions(path: '/x'),
               response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: 404)),
);
expect(await repo.buscarDetalhe(1), isA<Failure<DetalheImovel>>()
    .having((f) => f.erro, 'erro', isA<ImovelNaoEncontradoException>()));
```

### Teste anti-cálculo (critério 6 / D-04)
```dart
// wire: area_terreno 300.00, area_construida 180.00, area_livre 100.00  (300-180 = 120 ≠ 100)
expect(find.text('100 m²'), findsOneWidget);   // veio da API
expect(find.text('120 m²'), findsNothing);     // o app nunca calcula
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `Color.withOpacity(x)` | `Color.withValues(alpha: x)` | Flutter 3.27+ | `withOpacity` está `@Deprecated` no SDK 3.47.5 [VERIFIED: sky_engine painting.dart]; `flutter analyze` hoje está limpo — não introduzir infos |
| `@Freezed` união com `runtimeType` | `sealed class` + factories (freezed 3/4) | freezed 3.0 | Exemplos de união no README usam `sealed class … with _$X`; o repo já segue (`Result`, `ConteudoVitrine`) |
| `SharedPreferences.getInstance()` | `SharedPreferencesAsync` | — | irrelevante aqui (nada persistido) |

**Deprecated/outdated:** `withOpacity`; `photo_view`-style dependências (fora por D-08).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Alternar `PageView.physics` para `NeverScrollableScrollPhysics` enquanto `scale > 1` resolve o conflito zoom × swipe | Pattern 6 / Pitfall 3 | UX ruim no zoom; ajuste de gestos na execução. Mitigar com human-check |
| A2 | `@JsonSerializable(fieldRename: FieldRename.snake)` sobre o `factory` freezed funciona (README só documenta `@JsonSerializable(explicitToJson:)` no construtor) | Pattern 2 | Falha de geração; fallback `@JsonKey(name:)` campo a campo |
| A3 | DRF serializa `DecimalField` (lat/lng) como string por padrão | §11 | Se vier número, `latitude` `String?` quebra o parse; trocar para `num` |
| A4 | URL de `ImageField` só é absoluta com `context={"request": request}` | §11 / Pitfall (fotos) | Fotos relativas não carregariam na Fase 5; contrato deve exigir absoluta |
| A5 | dio lança `DioException` para status ≥ 400 por padrão (404 chega como exceção) | Pitfall 5 | Fase 5 precisaria checar status manualmente |
| A6 | `select_related`/`prefetch_related` sugeridos para o endpoint real | §11 | Só performance; decisão do E2 |
| A7 | Booleans: `true` → "Sim", `false` → "Não", `null` omite; contador "1/1" visível com 1 foto | Pattern 7 / Pattern 5 | Preferência de UX; Claude's Discretion — confirmar no UI-SPEC/human-check |
| A8 | IDs deduzidos da fixture (103 LOTE com foto, 104/109/119 sem foto etc.) | Fixtures | Planner deve reconferir rodando `linhasAcervoFixture()` |
| A9 | Não-publicado e inexistente devem ser indistinguíveis (404 igual) | §11 | Já é D-01; só reforço de segurança |

## Open Questions (RESOLVED)

1. **`corretor.slug` não existe no model Django.**
   - What we know: `Usuario` não tem `slug` (campos listados acima); D-06 pede `slug` no objeto; critério 5 pede "caminho para o perfil".
   - What's unclear: o E2 vai criar `slug` (WEB 09/perfil público) ou usar `id`?
   - Recommendation: `slug` nullable no wire e no Dart; a navegação do stub usa o objeto `CorretorResponsavel` já em memória (nem `id` nem `slug` entram em URL nesta fase). Registrar como PENDENTE E2 no §11.
   - **RESOLVED (2026-10-12, usuário): DEFERRED ao E2** (dono: frente web, WEB 09). O app trata defensivamente: `slug` é nullable no Model e na entidade, e a tela de perfil do corretor abre com o `CorretorResponsavel` já carregado pelo detalhe (nada de `id`/`slug` em URL). Registrado como D-19 no CONTEXT; planos 04-01 (entidade), 04-02 (§11 item a) e 04-08 (perfil).
2. **Enum de `posicao_solar`** (D-05 cita o campo, sem valores). Recomendação: tratar como `String?` no wire, mapear valores conhecidos (`NASCENTE`, `POENTE`, `NORTE`, `SUL` — proposta) para rótulos PT e, para valor desconhecido, exibir o texto cru capitalizado (nunca quebrar). Confirmar com o card WEB 06.
   - **RESOLVED (2026-10-12, usuário): DEFERRED ao E2** (dono: frente web, WEB 06). O app NÃO tem enum nem tabela de rótulos para `posicao_solar`: mostra exatamente o texto que a API manda (ex. 'Nascente'), linha omitida quando nulo. A recomendação de mapear valores acima fica descartada. Registrado como D-19; planos 04-02 (§11 item b + exemplo), 04-05 (fixture com rótulos) e 04-06 (exibição literal).
3. **Período do IPTU** (mensal ou anual?). Recomendação: rótulo "IPTU R$ X" **sem** "/mês" ou "/ano" até o E2 decidir; condomínio com "/mês".
   - **RESOLVED (2026-10-12, usuário): DEFERRED ao E2** (dono: frente web, WEB 09). O app mostra 'IPTU R$ X' sem sufixo de período até o E2 definir; condomínio com '/mês'. Registrado como D-19; planos 04-02 (§11 item c) e 04-08 (`linhasDeCustos`).
4. **`lote.preco` vs `preco_venda`.** Mostrar os dois é potencialmente confuso. Recomendação: renderizar `lote.preco` como linha "Preço do lote" quando não nulo e registrar a duplicidade como PENDENTE E2 (o app não decide qual vale — D-04 espírito).
   - **RESOLVED (2026-10-12, usuário): DEFERRED ao E2** (dono: frente web, WEB 07). O lote mostra no cabeçalho os preços da parte comum (`preco_venda`/`preco_aluguel`), como qualquer imóvel; `lote.preco` aparece como linha 'Preço do lote' só quando vier preenchido, nunca derivado de `preco_venda` nem o contrário. Registrado como D-19; planos 04-02 (§11 item d), 04-05 (fixture) e 04-06/04-08 (exibição).
5. **UI-SPEC.** `workflow.ui_phase: true` no config e não há `04-UI-SPEC.md`; as Fases 1 teve um. Sugestão ao orquestrador: considerar `/gsd-ui-phase 4` antes do plano (ícones, espaçamentos, contador) — ou aceitar as recomendações de discrição desta pesquisa.
   - **RESOLVED (2026-10-12, usuário): sem `/gsd-ui-phase`.** As decisões D-07..D-14 do CONTEXT são o contrato de UI desta fase; ícones e rótulos (discrição do Claude) são confirmados no human-check de fim de fase. Registrado como D-20; human-checks em 04-07 e 04-08.
6. **Mapeamento de requisitos/ROADMAP.** Substituir `APP-04` por DET-01..06 + API-06 no ROADMAP Phase 4, mover `DET-01` de v2 para v1, e acrescentar API-07 à Phase 5 (planner).
   - **RESOLVED (2026-10-12): coberto pelo plano 04-02 Task 2** (REQUIREMENTS.md com DET-01..06/API-06/API-07, rastreabilidade, remoção do DET-01 de v2, linhas `**Requirements**` das Phases 4 e 5 no ROADMAP).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | build, test, analyze | ✓ | 3.47.5 stable (Dart 3.13.4) | — |
| `dart run build_runner` (freezed/json/injectable) | models, estado, DI | ✓ (dev deps no lockfile) | build_runner 2.16.1 | — |
| Dispositivos para human-check | pinch-zoom/galeria | macOS desktop e Chrome apenas; **sem emulador Android/iOS listado** | — | `flutter run -d macos` (trackpad: pinch/scroll) para o human-check; pinch em toque real exige emulador/aparelho |
| Backend Django | — | não necessário (mock) | — | — |
| Espaço em disco | build_runner, `flutter test` | ⚠ 2.2 GiB livres (99%); 1 falha `ENOSPC` observada | — | Usuário libera espaço antes de executar (p.ex. `build/` do projeto, 1.9 GB — **não apagar sem autorização**) |

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** emulador/aparelho (usar macOS desktop; marcar pinch real como human-check de fim de fase, `human_verify_mode: end-of-phase`).

Baseline medida nesta sessão: `flutter analyze` → "No issues found!"; `flutter test` → 382 testes passando em ~14 s (a primeira tentativa de suite completa falhou por disco cheio, não por teste).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK) + `bloc_test ^10.0.0` + `mocktail ^1.0.5` [VERIFIED: pubspec.yaml dev_dependencies] |
| Config file | nenhum — convenção `test/**_test.dart` (`analysis_options.yaml` inclui `flutter_lints`) |
| Quick run command | `flutter test test/data/detalhe_imovel_model_test.dart test/presentation/detalhe_imovel_cubit_test.dart test/presentation/apresentacao_natureza_test.dart` |
| Full suite command | `flutter test && flutter analyze` |
| Codegen | `dart run build_runner build -d` (antes de rodar testes que dependem de `*.freezed.dart`/`*.g.dart`/DI) |

### Phase Requirements → Test Map

| Req ID | Critério (ROADMAP) | Behavior | Test Type | Automated Command | File Exists? |
|--------|--------------------|----------|-----------|-------------------|-------------|
| DET-02 | 1 | Fixture: `fotos[0].capa == true` e igual à `foto_capa` da lista; galeria renderiza fotos na ordem recebida; contador "1/N"; swipe → "2/N"; sem fotos → placeholder sem contador | unit (fixture) + widget | `flutter test test/data/imovel_detalhe_mock_datasource_test.dart test/presentation/galeria_imovel_test.dart` | ❌ Wave 0 |
| DET-02 | 1 | Toque na foto abre `VisualizadorFotos` (contém `InteractiveViewer`, começa no índice tocado, fecha com voltar) | widget | `flutter test test/presentation/visualizador_fotos_test.dart` | ❌ Wave 0 |
| DET-04 | 2 | Casa: linhas "Área do terreno", "Área construída", "Área livre" com os valores do wire; terreno: frente, fundo, topografia (rótulo PT) | unit (função pura) + widget | `flutter test test/presentation/apresentacao_natureza_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ❌ Wave 0 |
| DET-04 | 2 / 6 | **Anti-cálculo**: `area_livre` do wire ≠ terreno − construída aparece como veio | unit | idem | ❌ Wave 0 |
| DET-04 | 3 | Apartamento: `Card` do prédio com nome/andares/unidades/ano/elevadores/portaria/piscina/academia/salão/playground; lote: `Card` com quadra + loteamento (nome, incorporadora, infraestrutura, áreas de lazer) | unit + widget | idem | ❌ Wave 0 |
| DET-04 | (D-14) | Campo nulo omite a linha; bloco/seção vazia some; `natureza` desconhecida ou bloco faltando não derruba a página | unit (modelo+apresentação) | `flutter test test/data/detalhe_imovel_model_test.dart test/presentation/apresentacao_natureza_test.dart` | ❌ Wave 0 |
| DET-03 | 4 | Preços: VENDA, ALUGUEL ("/mês"), VENDA_E_ALUGUEL (2 linhas), condomínio, IPTU; ausentes omitidos; formatação BRL | unit (`apresentacao_imovel`) + widget | `flutter test test/presentation/apresentacao_imovel_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ⚠ arquivo 1 existe (estender); screen ❌ |
| DET-05 | 5 | Card do corretor com foto (ou avatar fallback) e nome; toque abre `PerfilCorretorScreen` com nome+foto do detalhe; `corretor == null` omite a seção | widget | `flutter test test/presentation/cartao_corretor_test.dart test/presentation/perfil_corretor_screen_test.dart` | ❌ Wave 0 |
| DET-01 | — | Toque no `ImovelCard` dispara `onTap`; `VitrineScreen` abre a rota do detalhe; prévia (título/preço) aparece em `carregando` e permanece em `carregado` | widget | `flutter test test/presentation/imovel_card_test.dart test/presentation/vitrine_screen_test.dart test/presentation/detalhe_navegacao_test.dart` | ⚠ 2 existem (estender); navegação ❌ |
| DET-06 | — | Cubit: `carregando → carregado`, `→ naoEncontrado` (404), `→ erro` (outro); `tentarNovamente` reabre `carregando`; sem `emit` após `close()`. UI: "Este imóvel não está mais disponível" + voltar; "Tentar de novo" | bloc_test + widget | `flutter test test/presentation/detalhe_imovel_cubit_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ❌ Wave 0 |
| DET-06 | — | Repo: `DioException` 404 → `ImovelNaoEncontradoException`; 500/timeout → `Failure` genérica; `TypeError` → `FormatException`; sucesso mapeia entidade | unit | `flutter test test/data/imovel_detalhe_repository_impl_test.dart` | ❌ Wave 0 |
| API-06 | 6 | **Teste de contrato**: `imovel_detalhe.example.json` parseia via `DetalheImovelModel.fromJson`→`paraEntidade()`; toda linha da fixture parseia; chaves de toda linha ⊆ allowlist do §11 (guarda de vazamento: sem `proprietario`, `corretor_responsavel`, `email`, `telefone`, `empresa`, `logradouro`…) | unit | `flutter test test/data/contrato_detalhe_test.dart` | ❌ Wave 0 |
| API-06 | 6 | Consistência lista↔detalhe: para todo id da lista (exceto o reservado de 404), o detalhe existe e `titulo`/preços/`bairro`/`cidade`/`natureza` batem; `fotos` vazia ⇔ `foto_capa == null`; 1 detalhe por natureza; ≥1 sem fotos; ≥1 com nulos; id reservado → `ImovelNaoEncontradoException`; id de falha → `FalhaSimuladaDoMock` | unit | `flutter test test/data/imovel_detalhe_mock_datasource_test.dart` | ❌ Wave 0 |
| (segurança) | — | URLs de foto com esquema ≠ http/https são descartadas | unit | `flutter test test/data/detalhe_imovel_model_test.dart` | ❌ Wave 0 |
| (DI) | — | `getIt<DetalheImovelCubit>()` resolve com a pilha mock após `configureDependencies()` | unit/widget | `flutter test test/di/injecao_detalhe_test.dart` (ou coberto pelo teste de navegação) | ❌ Wave 0 |

**Manual-only (human-check de fim de fase, justificados):** pinch-zoom real e conflito zoom×swipe (gesto de toque não reproduzível fielmente em widget test); aparência do `SliverAppBar` colapsando e legibilidade do botão voltar sobre fotos reais; fluxo vitrine → detalhe → 404 (id reservado) e "Tentar de novo" (id de falha) com a latência de 500 ms; confirmar rótulos/ícones escolhidos.

### Sampling Rate
- **Per task commit:** `flutter test <arquivos tocados pela task>` (< 30 s)
- **Per wave merge:** `flutter test && flutter analyze` (~15 s hoje + novos testes)
- **Phase gate:** suite completa verde e `flutter analyze` sem issues antes de `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/data/detalhe_imovel_model_test.dart` — parse, defaults, natureza desconhecida/bloco ausente, `TypeError` esperado em wire malformado, descarte de URL não-http(s)
- [ ] `test/data/imovel_detalhe_mock_datasource_test.dart` — fixture, consistência com a lista, ids reservados
- [ ] `test/data/imovel_detalhe_repository_impl_test.dart` — 404/erro/TypeError/sucesso
- [ ] `test/data/contrato_detalhe_test.dart` — exemplo JSON do contrato + guarda de allowlist (lê `.planning/phases/01-…/contrato/imovel_detalhe.example.json`; se o diretório for arquivado por `gsd-cleanup`, mover o exemplo para `test/` ou ajustar o caminho)
- [ ] `test/presentation/apresentacao_natureza_test.dart`, `detalhe_imovel_cubit_test.dart`, `detalhe_imovel_screen_test.dart`, `galeria_imovel_test.dart`, `visualizador_fotos_test.dart`, `cartao_corretor_test.dart`, `perfil_corretor_screen_test.dart`, `detalhe_navegacao_test.dart`
- [ ] Estender `imovel_card_test.dart` (onTap), `vitrine_screen_test.dart` (abre detalhe), `apresentacao_imovel_test.dart` (condomínio/IPTU)
- [ ] Framework install: nenhum — tudo já presente. Rodar `dart run build_runner build -d` antes dos testes

## Security Domain

`workflow.security_enforcement` = true, `security_asvs_level` = 1 [VERIFIED: .planning/config.json].

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | App sem login; endpoint `AllowAny` |
| V3 Session Management | no | Sem sessão |
| V4 Access Control | yes (servidor) | Queryset `publicado=True` obrigatório; 404 idêntico para inexistente/não publicado (D-01); o app não decide visibilidade |
| V5 Input Validation | yes | Models freezed tipados; enum desconhecido → `null`; `finalidade` inválida → `FormatException`; `TypeError` → `Failure`; `id` sempre `int` (nunca string concatenada na URL); descrição renderizada como `Text` (sem HTML/WebView) |
| V6 Cryptography | no | Nada a cifrar; **não** persistir nada |
| V8 Data Protection | yes | Allowlist do §11 (sem proprietário/email/telefone/documentos/endereço exato); app não loga o corpo do detalhe |
| V12/V13 (arquivos/API) | yes | URLs de foto vindas da API: aceitar só `http`/`https` (descartar `file:`/`javascript:`/outros); `CachedNetworkImage` com `errorWidget` (falha não derruba) |

### Known Threat Patterns for Flutter + API pública

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Vazamento de campo interno no serializer (`proprietario`, `corretor_responsavel`, e-mail/telefone do corretor) | Information Disclosure | Allowlist explícita no §11 + serializer dedicado + teste de guarda no mock (`chaves ⊆ allowlist`) |
| Enumeração de rascunhos por id | Information Disclosure | 404 uniforme, filtro `publicado=True` no queryset (não confiar no cliente) |
| JSON malformado/enum novo derrubando o app | Denial of Service | Parse defensivo + `Result.failure`; `natureza` desconhecida degrada para "sem seção" |
| URL de imagem maliciosa (`file://`, esquema exótico) | Tampering | Validar esquema http(s) no `paraEntidade()`; URL inválida ⇒ foto descartada |
| Lista de fotos muito grande (memória) | Denial of Service | `PageView.builder` (lazy) + `cached_network_image`; sem pré-carregar tudo |
| Dados pessoais do corretor (LGPD) | Information Disclosure | Expor só `id/nome/foto/slug` (D-06); confirmar com produto (Open Question g) |

## Sources

### Primary (HIGH confidence)
- Código do repo lido nesta sessão: `lib/data/models/imovel_model.dart` + `.g.dart`, `lib/data/datasources/imovel_mock_datasource.dart`, `lib/data/repositories/imovel_repository_impl.dart`, `lib/data/mocks/imoveis_fixture.dart`, `lib/presentation/vitrine/{vitrine_screen,vitrine_cubit,vitrine_state,opcoes_filtro_cubit,opcoes_filtro_state,apresentacao_imovel}.dart`, `widgets/{imovel_card,foto_capa_imovel}.dart`, `lib/presentation/cidade_selecao/cidade_selecao_screen.dart`, `lib/core/result.dart`, `lib/di/*`, `test/data/imovel_repository_impl_test.dart`, `test/data/cidade_remote_datasource_test.dart`, `test/presentation/{imovel_card,vitrine_cubit,vitrine_screen}_test.dart`, `pubspec.yaml`/`pubspec.lock`, `.planning/config.json`
- Contrato: `.planning/phases/01-…/01-CONTRATO-API.md` (§1-§10) e `contrato/imoveis.example.json`
- Repo irmão (somente leitura): `Web/imoveis/models.py`, `Web/contas/models.py`, `Web/core/models.py`, `Web/empresas/api/views.py`
- SDK Flutter 3.47.5 local: `dart:ui painting.dart` (`withOpacity` deprecado), `widgets/interactive_viewer.dart` (defaults), `material/app_bar.dart` (`leading`)
- Execuções locais: `flutter analyze`, `flutter test` (382 verdes), `flutter devices`, `df -h`

### Secondary (MEDIUM confidence)
- https://pub.dev/packages/freezed — união por `runtimeType`/`unionKey`, `@JsonSerializable` sobre o construtor, `explicitToJson` para listas aninhadas
- https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html — propriedades; sem menção a conflito com `PageView`

### Tertiary (LOW confidence)
- Comportamento do conflito zoom×swipe e solução por `physics` (A1) — prática comum, **não** verificada nesta sessão; exige human-check

## Project Constraints (from CLAUDE.md)

Fonte: `./.claude/CLAUDE.md` (config `claude_md_path`). Diretivas acionáveis, tratadas com a autoridade de decisões travadas:
- **Clean Architecture** `data/` (Models, Repositories, DataSources) / `domain/` (UseCases puros, interfaces) / `presentation/` (Widgets limpos, Cubits). **Nenhum widget faz lógica de negócio ou chamada de rede.** Não negociável.
- **Estado:** Cubit (flutter_bloc), **imutabilidade estrita** nos estados de tela (freezed).
- **Models de API:** todo JSON em Models imutáveis (`freezed`/`fromJson`); nunca `dynamic` onde a tipagem forte couber.
- **Erros:** `Result`/sealed classes com estados explícitos Loading/Success/Failure; **sem `try/catch` genérico na UI** (o `try/catch` fica no repositório).
- **UI:** Material 3 estrito, `ColorScheme.fromSeed`, widgets nativos (`Card`, `FilledButton`, …), tipografia via `Theme.of(context).textTheme`; **paleta Verde e Branco** (tema em `app_theme.dart`, semente `0xFF2E7D32`).
- **Regra de negócio:** nada que "valha dinheiro" ou mude estado é decidido no app — `area_livre`, ordem de fotos, preços vêm do servidor.
- **Idioma do código:** models, variáveis e comentários em **português**.
- **Branches:** `feat/<número do card>` (ex.: `feat/APP04`).
- **Libs proibidas/evitar:** `equatable` junto de freezed, `mockito` (usar `mocktail`), `Provider`, `http` puro, `dartz`; **sem `go_router`** (D-18); sem pacote novo de galeria/zoom (D-08).
- **Workflow GSD:** edições de arquivo só via comandos GSD (`/gsd-execute-phase` etc.). Esta pesquisa **não commita** (instrução do orquestrador) e só escreve este arquivo.
- Regra de memória do usuário: **nunca commitar código sem OK explícito**; explicar em PT.
- Sem skills de projeto utilizáveis: `.claude/skills/flutter-frontend` existe como diretório mas o CLAUDE.md afirma "No project skills found" (não foi encontrado `SKILL.md`).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — tudo já está no `pubspec.lock`; nenhuma dependência nova.
- Architecture: HIGH — espelha arquivos lidos nesta sessão (datasource/mock/repo/Cubit/DI/telas).
- Contract §11: MEDIUM — grounded nos models Django reais, mas a natureza e o `slug` não existem no backend e dependem do sign-off do E2.
- Pitfalls: HIGH para os verificados no código (TypeError, AspectRatio, withOpacity, disco); MEDIUM para o zoom×swipe (A1).

**Research date:** 2026-10-12
**Valid until:** 2026-11-11 (30 dias; stack estável — revalidar se freezed/Flutter subirem de major ou se o E2 fechar o contrato)
