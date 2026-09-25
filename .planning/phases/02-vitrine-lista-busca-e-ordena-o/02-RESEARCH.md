# Phase 2: Vitrine — Lista, Busca e Ordenação - Research

**Researched:** 2026-09-25
**Domain:** Flutter Clean Architecture — paginated list UI (cursor scroll infinito), server-side search/sort, Dio-backed remote DataSource, DRF public endpoint groundwork
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Layout = lista vertical, um card por linha, foto de capa larga em cima e informações
  embaixo (título, preço, natureza, bairro, quartos). `Card` do Material 3.
- **D-02:** `finalidade == VENDA_E_ALUGUEL` → card mostra os dois preços empilhados ("Venda R$
  450.000" / "Aluguel R$ 2.500/mês"). `VENDA` só venda, `ALUGUEL` só aluguel (com "/mês").
- **D-03:** Preço = moeda BRL completa, sem centavos quando forem zero ("R$ 450.000"), aluguel
  com sufixo "/mês", via `intl` em `pt_BR`. Conversão string→número/format fica fora do widget
  (model/presenter), nunca é regra de negócio recalculada.
- **D-04:** `foto_capa` null ou falha de carregamento → placeholder verde claro com ícone de
  casa, mesma proporção da foto, para altura de card consistente. `cached_network_image`
  (placeholder/errorWidget).
- **D-05:** Param de busca em `GET /imoveis` = `busca` (`?busca=cambuí`). Django: `SearchFilter`
  com `search_param = "busca"`. Adendo ao contrato — registrar em `01-CONTRATO-API.md §5`.
- **D-06:** Servidor busca em título + bairro (`titulo`, `endereco__bairro`), case/acento-
  insensível no que o backend permitir. Descrição fica de fora. O mock replica exatamente essa
  semântica.
- **D-07:** Barra de busca = `SearchBar` Material 3, fixa logo abaixo do seletor de cidade no
  topo. A lista atualiza no lugar, sem trocar de tela.
- **D-08:** Debounce de 400ms, disparo a partir de 2 caracteres. Campo vazio volta imediatamente
  à lista completa, sem esperar o debounce. Com 1 caractere, nada é disparado. Debounce vive no
  Cubit (`Timer` próprio, sem `easy_debounce`).
- **D-09:** Estado "nenhum resultado" da busca é distinto de "cidade sem imóveis": o primeiro
  menciona o termo buscado e oferece limpar a busca.
- **D-10:** Controle de ordenação = botão "Ordenar: <opção atual>" ao lado da busca, abre bottom
  sheet com `RadioListTile`. Espaço reservado ao lado para o botão de filtros da Fase 3.
- **D-11:** Opções = `mais_recentes` (padrão), `preco_asc`, `preco_desc`, `area_asc`,
  `area_desc` (proposta §7.4 do contrato, ainda sujeita a aval do E2). Rótulos em PT na UI,
  valores no enum do domínio. `mais_recentes` equivale a `-criado_em`.
- **D-12:** Ordenar por preço usa `preco_venda`; imóveis só-aluguel vão para o fim (nulls last),
  sem misturar escalas venda/aluguel. Fase 3 troca para `preco_aluguel` quando
  `finalidade=ALUGUEL`. Regra do servidor (e do mock), nunca do app. Adendo ao contrato.
  `area_*` com `area` null também usa nulls last.
- **D-13:** Trocar ordenação ou busca reinicia a lista do topo (descarta cursor, limpa itens,
  loading, scroll ao início). Respostas atrasadas de consulta anterior são descartadas (token/id
  de requisição no estado do Cubit) — zero cards duplicados/embaralhados. Próxima página só via
  `next` do envelope cursor; `next == null` → fim-da-lista.
- **D-14:** DataSource mock de imóveis = servidor simulado: fixture ~40 imóveis por cidade
  atendida (forma exata de `contrato/imoveis.example.json`, incluindo campos PENDENTE E2),
  aplica `cidade` + `busca` + `ordenacao` + `cursor`, devolve envelope `{next, previous,
  results}` com latência ~500ms. Camada `data/` simulando o Django; sai inteira na Fase 4. UI/
  Cubit/domain nunca veem o acervo inteiro.
- **D-15:** Gatilhos determinísticos no mock: busca "erro" falha a chamada (erro/retry); pelo
  menos uma cidade atendida fica sem imóveis na fixture (vazio). Nada aleatório.
- **D-16:** Se `GET /api/publico/cidades/` falhar → erro com "Tentar de novo" (reusa
  `erroCarregarCidades`). `assets/cidades.json` e `CidadeLocalDataSource` são **removidos**,
  fonte única da verdade. Quem já tem cidade salva entra direto sem depender da lista.
  Reversível — asset/DataSource local seguem no git.
- **D-17:** Base URL via `--dart-define=API_BASE_URL=...`, padrão `http://10.0.2.2:8000`
  (emulador Android → localhost do Mac). Documentar no README.

### Claude's Discretion

- Navegação seleção de cidade → vitrine: a vitrine substitui o `_CorpoCidadeEntrada` placeholder
  (estado `AutorizadaEAtendida`); estrutura exata de rotas/telas fica com o planner.
- Indicador de loading (skeleton ou spinner), tamanho de página do cursor, layout visual fino do
  card (Material 3 + verde/branco + UI-SPEC se a fase gerar um).
- Como alternar mock/real no DI (ex.: `@Environment` do injectable ou registro condicional),
  desde que seja troca de uma linha na Fase 4.
- Implementação do endpoint Django de cidades (view `AllowAny` + `CidadeSerializer` reaproveitado
  + `CursorPagination` ordering `["nome", "uf"]`, queryset `Cidade.objects.filter(
  empresas_atuantes__ativa=True).distinct()`), testes DRF, e se o app percorre todas as páginas
  de `/cidades` (provável: sim, conjunto pequeno).
- Representação do param `cidade` no mock: segue recomendação provisória do contrato §7.2 (chave
  natural nome+uf), isolada na DataSource para trocar fácil se o E2 decidir por id.

### Deferred Ideas (OUT OF SCOPE)

- Filtros, chips ativos e ordenação por `preco_aluguel` quando `finalidade=ALUGUEL`: Fase 3.
- Endpoint real `GET /imoveis` e troca da DataSource mock pela real: Fase 4.
- Cache offline da lista de cidades (`shared_preferences`): descartado agora (D-16); reavaliar se
  uso offline virar requisito.
- Busca também na descrição: descartada por ruído (D-06); reavaliar com dados reais.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VIT-01 | Vitrine mostra lista de imóveis da cidade escolhida | Pattern 1 (Vitrine State/Cubit), `ImovelMockDataSource` §Standard Stack, Code Example 1 |
| VIT-02 | Card com foto/título/preço/natureza/bairro/quartos, formato consistente | Pattern 2 (Card + placeholder consistente), Pitfall 6 |
| VIT-03 | Busca por texto com debounce + "nenhum resultado" | Pattern 3 (debounce + token de requisição), Pitfall 1, Code Example 3 |
| VIT-04 | Ordenar por preço/área/mais recentes | Pattern 1 (`OrdenacaoVitrine` enum), Pitfall 3 (nulls-last no CursorPagination) |
| VIT-05 | Scroll infinito com loading/vazio/erro-retry/fim-de-lista, sem duplicar/embaralhar | Pattern 1 e 4 (estado único de lista + guarda de scroll), Pitfall 1 e 2 |
| VIT-06 | Lista de cidades vem de `GET /cidades` real | Pattern 5 (`CidadeRemoteDataSource` via Dio), Pitfall 4, Runtime State Inventory |
| API-02 | `GET /api/publico/cidades/` público sem token | §Django — Endpoint de Cidades, Code Example 5 |
| API-04 | Camada de dados trocável (mock hoje, real depois via DI) | Pattern 6 (fronteira de repositório single-impl hoje) |
</phase_requirements>

## Summary

Esta fase é, arquiteturalmente, duas construções relativamente independentes que se encontram
apenas no `CidadeRepository`: (1) trocar a fonte de cidades de um asset local para o endpoint
público real `GET /api/publico/cidades/` (que precisa nascer no repo irmão Django), e (2)
construir do zero a vitrine de imóveis — lista, busca, ordenação, scroll infinito — inteiramente
sobre uma `DataSource` mock que **é** o contrato da Fase 1 em memória, sem nenhum imóvel real.
Nenhuma dessas duas construções tem sobreposição de responsabilidade: cidades sempre foram
"trocável por DI" desde a Fase 1 (`CidadeRepositoryImpl` já isola a `DataSource`); imóveis nunca
tiveram implementação nenhuma até agora.

A complexidade real da fase não está no Flutter em si (o padrão `ScrollController` + Cubit +
cursor já está documentado no próprio CLAUDE.md/RESEARCH da Fase 1 — é o tutorial oficial
`bloclibrary.dev/tutorials/flutter-infinite-list`), mas em três acoplamentos que o critério de
sucesso 4 ("sem cards duplicados ou embaralhados") torna não-negociáveis: (a) debounce + latência
artificial do mock (400ms + 500ms) empilham duas fontes assíncronas concorrentes que exigem um
token de requisição no estado do Cubit; (b) o listener do `ScrollController` pode disparar
múltiplas vezes antes da primeira página resolver, exigindo uma flag de "já carregando"; e (c) a
regra de negócio de D-12 (nulls-last na ordenação por preço/área) **não é suportada nativamente**
pelo `CursorPagination` do DRF — a documentação oficial exige explicitamente que o campo de
`ordering` seja "non-nullable". Isso não bloqueia esta fase (o mock em Dart implementa nulls-last
trivialmente), mas é um achado que precisa ir para o adendo do contrato que o E2 vai revisar,
porque vai bloquear a Fase 4 se não for resolvido antes (ver Pitfall 3 / Open Questions).

**Primary recommendation:** Construir `VitrineCubit` com um único estado de sucesso "achatado"
(itens + cursor + flags `carregandoMais`/`atingiuFim`/`erroAoCarregarMais`, não uma união selada
por página) para que uma falha ao carregar a *próxima* página nunca descarte a lista já visível;
reservar estados sealed inteiramente distintos só para os desfechos de página inicial (loading /
vazio-cidade / sem-resultado-busca / erro-inicial / sucesso). Usar `dio` + Dio module do
`injectable` para o `CidadeRemoteDataSource`; manter o `ImovelMockDataSource` inteiramente dentro
de `data/`, nunca vazando o acervo completo para `domain/`/`presentation/`.

## Architectural Responsibility Map

> Adaptado à Clean Architecture do projeto (não há tiers web/CDN aqui — mobile-only, Android/iOS).
> Tiers usados: **Presentation** (Widgets/Cubit), **Domain** (Entities/UseCases/interfaces),
> **Data** (Repositories/DataSources — mock ou remoto via `dio`), **Django API** (fora desta fase
> para imóveis; nesta fase para cidades).

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Renderização do card (foto/preço/natureza/bairro/quartos) | Presentation (Widget) | Data (formata string decimal) | Widget só desenha; parsing/format do preço vive fora do Widget (D-03) |
| Debounce da busca (400ms, 2+ chars) | Presentation (Cubit) | — | É concern de UX do cliente, não regra de negócio — vive no Cubit local, nunca no servidor/mock |
| Execução da busca/ordenação/filtro em si | Data (mock hoje) | Django API (Fase 4) | Regra de negócio "nada é recalculado no aparelho" — servidor decide o que entra na lista |
| Scroll infinito / gatilho de "carregar mais" | Presentation (Cubit + ScrollController) | Data (cursor opaco) | Cliente decide *quando* pedir mais; servidor decide *o quê* (cursor opaco, nunca interpretado pelo app) |
| Lista de cidades atendidas | Data (`CidadeRemoteDataSource`, Dio) | Django API (`GET /api/publico/cidades/`) | Fonte única passa a ser o endpoint real (D-16); Data só orquestra a paginação até `next == null` |
| Regra "cidade atendida" (tem empresa ativa atuando) | Django API | — | Regra de negócio do marketplace, decidida no queryset do backend, nunca replicada no app |
| Cache/persistência da cidade escolhida | Data (`shared_preferences`) | — | Sem mudança nesta fase — já existe desde a Fase 1 |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `dio` | ^5.11.1 | Cliente HTTP para `GET /api/publico/cidades/` | Já mandatado pelo CLAUDE.md; interceptor chain cobre base URL (D-17) e timeout num só lugar |
| `intl` | ^0.20.3 [VERIFIED: pub.dev registry, fetched 2026-09-25] | `NumberFormat.currency` para formatar preço BRL (D-03) | Pacote oficial `dart.dev`, `flutter-favorite`, zero dependência extra — já citado no CLAUDE.md como parte do stack mandatado, faltando apenas no `pubspec.yaml` |
| `cached_network_image` | ^4.0.2 [VERIFIED: pub.dev registry, fetched 2026-09-25] | Foto de capa do card com cache em disco + placeholder/errorWidget (D-04) | Já mandatado pelo CLAUDE.md; publisher `baseflow.com`, 3.4M downloads/30d |
| `flutter_bloc` (já em `pubspec.yaml`) | ^9.1.1 | `VitrineCubit` | Já instalado desde a Fase 1 |
| `freezed`/`json_serializable` (já em `pubspec.yaml`) | ^4.0.2 / ^6.14.1 | `ImovelModel`, `ImoveisEnvelopeModel`, `VitrineState` | Já instalado; ver Pitfall 5 sobre evitar envelope genérico |
| `get_it`/`injectable` (já em `pubspec.yaml`) | ^9.3.0 / ^3.0.0 | DI de `VitrineCubit`, `ImovelRepository`, `CidadeRemoteDataSource`, módulo de `Dio` | Já instalado |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `fake_async` | ^1.3.3 [VERIFIED: pub.dev registry, fetched 2026-09-25] (dev dependency) | Testar o `Timer` de debounce (D-08) sem esperar 400ms reais por teste | Sempre que um `bloc_test` precisa avançar tempo virtual para validar o debounce sem deixar a suíte lenta/flaky. Publisher `dart.dev`, 8.2M downloads/30d — pacote oficial do time Dart para isso |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Estado único "achatado" para a lista (itens + flags) | Estado sealed por página/transição (`CarregandoPagina`, `PaginaCarregada`, `ErroPagina`, ...) | O sealed-por-página é mais "puro" no espírito freezed do projeto, mas obriga a UI a reconstruir a lista inteira a cada transição e torna trivial o bug "erro ao carregar mais apaga a lista visível" (exatamente o que o critério de sucesso 4 proíbe). Estado achatado com flags é a escolha recomendada aqui — ver Pattern 1 |
| `dio.get(envelope.next)` direto (URL absoluta) | Reconstruir a URL manualmente a partir do valor de `cursor` | Reconstruir manualmente exige reimplementar a serialização de query params que o Django já fez; usar a URL absoluta do `next` é mais simples e é o padrão do próprio DRF (cursor é opaco por design, ver §4 do contrato) |
| `real Timer` de 400ms nos testes (esperar de verdade) | `fake_async` (tempo virtual) | Esperar 400ms reais por teste de debounce multiplica o tempo da suíte a cada caso e é uma fonte clássica de flakiness em CI; `fake_async` é o padrão oficial do time Dart para isso |

**Installation:**
```bash
flutter pub add intl cached_network_image
flutter pub add --dev fake_async
```

**Version verification:** `intl`, `cached_network_image` e `fake_async` foram confirmados
diretamente via `https://pub.dev/api/packages/<nome>` nesta sessão (2026-09-25) — ver tabela
acima. `dio`, `flutter_bloc`, `freezed`, `json_serializable`, `get_it`, `injectable` já estão
instalados em `pubspec.yaml` (Fase 1) nas versões citadas no `CLAUDE.md`, não foram re-verificados
nesta sessão por já serem dependências resolvidas no lockfile do projeto.

## Package Legitimacy Audit

| Package | Registry | Age/Publisher | Downloads (30d) | Source Repo | Verdict | Disposition |
|---------|----------|----------------|------------------|--------------|---------|-------------|
| `intl` | pub.dev | publisher `dart.dev` (Flutter-favorite) | 11,002,545 | github.com/dart-lang/i18n | OK | Approved |
| `cached_network_image` | pub.dev | publisher `baseflow.com` | 3,413,544 | github.com/Baseflow/flutter_cached_network_image | OK | Approved |
| `fake_async` | pub.dev | publisher `dart.dev` | 8,226,700 | github.com/dart-lang/tools | OK | Approved |

**Packages removed due to [SLOP] verdict:** none.
**Packages flagged as suspicious [SUS]:** none.

*Nenhum pacote novo desta fase precisou de `gsd_run query package-legitimacy check` (ecossistema
pub/Dart não está entre `npm|pypi|crates`) — a verificação foi feita manualmente contra a API
pública do registro `pub.dev` (`GET /api/packages/<nome>` e `GET /api/packages/<nome>/score`),
que é a fonte oficial de metadados de publisher/downloads/pontuação do ecossistema Dart, e conta
como `[VERIFIED: pub.dev registry]` para nome de pacote + versão, já que todos os três nomes
também já constam do `CLAUDE.md` do projeto (fonte prévia, não uma alucinação desta sessão).*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ VitrineScreen (Presentation)                                         │
│  SeletorCidadeTopo (D-07, já existe) ──> SearchBar (D-07) ──>        │
│  "Ordenar: X" (D-10, bottom sheet) ──> ListView.builder + ScrollCtrl │
└───────────────┬────────────────────────────────────────────────────┘
                 │ eventos (buscar/ordenar/carregarMais)
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ VitrineCubit (Presentation)                                          │
│  Timer? _debounce (D-08)     int _tokenRequisicao (guarda D-13)      │
│  emit(VitrineState.sucesso(itens, cursor, carregandoMais, ...))      │
└───────────────┬────────────────────────────────────────────────────┘
                 │ chama
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ BuscarImoveisUseCase (Domain) ──> ImovelRepository (interface, Domain)│
└───────────────┬────────────────────────────────────────────────────┘
                 │ impl
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│ ImovelRepositoryImpl (Data) ──> ImovelMockDataSource (Data, D-14)     │
│   aplica cidade+busca+ordenacao+cursor sobre fixture em memória      │
│   (Future.delayed 500ms) ──> devolve ImoveisEnvelopeModel             │
│   [Fase 4: troca por ImovelRemoteDataSource ──> GET /api/publico/    │
│    imoveis/ — fora de escopo aqui]                                   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ CidadeRepositoryImpl (Data, já existe) ──> CidadeRemoteDataSource     │
│   (Data, NOVO) ──dio──> GET /api/publico/cidades/ (Django, NOVO)     │
│   percorre páginas até next == null (discretion note)                │
└─────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── data/
│   ├── datasources/
│   │   ├── cidade_remote_datasource.dart     # NOVO — dio, GET /cidades
│   │   └── imovel_mock_datasource.dart       # NOVO — fixture + filtros (D-14)
│   ├── models/
│   │   ├── imovel_model.dart                 # NOVO — freezed + json_serializable
│   │   └── imoveis_envelope_model.dart       # NOVO — {next, previous, results}, não-genérico (Pitfall 5)
│   ├── mocks/
│   │   └── imoveis_fixture.json              # NOVO — asset com ~40 imóveis/cidade atendida
│   └── repositories/
│       ├── cidade_repository_impl.dart       # ALTERADO — DataSource local → remota
│       └── imovel_repository_impl.dart       # NOVO
├── domain/
│   ├── entities/
│   │   ├── imovel.dart                       # NOVO — classe plain, segue padrão de Cidade
│   │   ├── ordenacao_vitrine.dart            # NOVO — enum com valorApi (D-11)
│   │   └── pagina_imoveis.dart               # NOVO — {itens, proximoCursor}
│   ├── repositories/
│   │   └── imovel_repository.dart            # NOVO — interface
│   └── usecases/
│       └── buscar_imoveis_usecase.dart       # NOVO
└── presentation/
    └── vitrine/
        ├── vitrine_cubit.dart                # NOVO
        ├── vitrine_state.dart                # NOVO — freezed sealed (ver Pattern 1)
        ├── vitrine_screen.dart                # NOVO
        └── widgets/
            ├── imovel_card.dart               # NOVO (D-01..D-04)
            └── ordenacao_bottom_sheet.dart     # NOVO (D-10)
```

### Pattern 1: Estado de lista "achatado" (não sealed-por-página)
**What:** Um único estado `sucesso` no `VitrineState` que carrega `List<Imovel> itens`,
`String? proximoCursor`, `bool carregandoMais`, `bool atingiuFim`, `bool erroAoCarregarMais` —
em vez de estados sealed distintos para "carregando página 2" / "erro na página 2". Os
**outros** desfechos (carregando página 1, vazio-cidade, sem-resultado-busca, erro na página 1)
continuam sendo variantes sealed próprias, porque aí sim são telas cheias distintas.
**When to use:** Sempre que uma falha em "carregar mais" **não** deve derrubar a lista já
visível na tela (VIT-05 critério 4: "sem cards duplicados ou embaralhados" implica também "sem
perder o que já carregou").
**Example:**
```dart
// Fora do widget — projeto segue o padrão de `cidade_selecao_state.dart` (freezed sealed)
@freezed
sealed class VitrineState with _$VitrineState {
  const factory VitrineState.carregandoInicial() = _CarregandoInicial;
  const factory VitrineState.vazioNaCidade() = _VazioNaCidade;
  const factory VitrineState.semResultadoBusca(String termoBuscado) = _SemResultadoBusca;
  const factory VitrineState.erroInicial() = _ErroInicial;
  const factory VitrineState.sucesso({
    required List<Imovel> itens,
    required String? proximoCursor,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
  }) = _Sucesso;
}
// atingiuFim == (proximoCursor == null) — não precisa de campo próprio.
```

### Pattern 2: Token de requisição para descartar respostas atrasadas (D-13)
**What:** Um contador (`int _versaoConsulta`) incrementado em toda mudança de busca/ordenação/
reload; cada `Future` assíncrono captura a versão vigente no momento do disparo e só faz `emit`
se ainda for a versão atual quando a resposta chegar.
**When to use:** Toda vez que o debounce (400ms) e/ou a latência artificial do mock (500ms)
tornam possível que duas requisições estejam em voo ao mesmo tempo — exatamente o caso aqui, e
é o mecanismo que o próprio D-13 pede ("token/id de requisição no estado do Cubit").
**Example:**
```dart
// Fonte: padrão consagrado (nenhuma lib resolve isso — é lógica do Cubit)
int _versaoConsulta = 0;

Future<void> _buscarPrimeiraPagina() async {
  final minhaVersao = ++_versaoConsulta;
  emit(const VitrineState.carregandoInicial());
  final resultado = await _buscarImoveis(cidade: _cidade, busca: _termo, ordenacao: _ordenacao);
  if (minhaVersao != _versaoConsulta) return; // resposta obsoleta — descarta (D-13)
  switch (resultado) {
    case Success(:final data) when data.itens.isEmpty && _termo != null:
      emit(VitrineState.semResultadoBusca(_termo!));
    case Success(:final data) when data.itens.isEmpty:
      emit(const VitrineState.vazioNaCidade());
    case Success(:final data):
      emit(VitrineState.sucesso(itens: data.itens, proximoCursor: data.proximoCursor));
    case Failure():
      emit(const VitrineState.erroInicial());
    case Loading():
      break;
  }
}
```

### Pattern 3: Debounce com limpar-imediato e limiar de 2 caracteres (D-08)
**What:** `Timer` próprio no Cubit (sem `easy_debounce`, decisão já travada no CLAUDE.md);
campo vazio cancela o timer pendente e recarrega na hora; 1 caractere não dispara nada.
**Example:**
```dart
Timer? _debounce;

void buscar(String texto) {
  _debounce?.cancel();
  final termo = texto.trim();
  if (termo.isEmpty) {
    _termo = null;
    _buscarPrimeiraPagina(); // volta à lista completa imediatamente (D-08)
    return;
  }
  if (termo.length < 2) return; // 1 caractere: nada dispara, lista atual continua (D-08)
  _debounce = Timer(const Duration(milliseconds: 400), () {
    _termo = termo;
    _buscarPrimeiraPagina();
  });
}

@override
Future<void> close() {
  _debounce?.cancel();
  return super.close();
}
```

### Pattern 4: Guarda de scroll infinito (evita disparos duplicados)
**What:** O listener do `ScrollController` (padrão oficial `bloclibrary.dev/tutorials/
flutter-infinite-list` — limiar de 90% do `maxScrollExtent`) só chama `carregarMais()` se o
estado atual for `sucesso`, `!carregandoMais` e `proximoCursor != null`. Sem essa guarda, o
listener pode disparar várias vezes entre o primeiro scroll e a primeira resposta assíncrona,
gerando páginas duplicadas.
**Example:**
```dart
// Source: bloclibrary.dev/tutorials/flutter-infinite-list (adaptado de evento para método de Cubit)
_scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent * 0.9) {
    context.read<VitrineCubit>().carregarMais();
  }
});

// Dentro do Cubit:
Future<void> carregarMais() async {
  final estadoAtual = state;
  if (estadoAtual is! _Sucesso) return;
  if (estadoAtual.carregandoMais || estadoAtual.proximoCursor == null) return;
  emit(estadoAtual.copyWith(carregandoMais: true, erroAoCarregarMais: false));
  final minhaVersao = _versaoConsulta; // mesma guarda de D-13 para "carregar mais"
  final resultado = await _buscarImoveis(cursor: estadoAtual.proximoCursor);
  if (minhaVersao != _versaoConsulta) return;
  switch (resultado) {
    case Success(:final data):
      emit(estadoAtual.copyWith(
        itens: [...estadoAtual.itens, ...data.itens],
        proximoCursor: data.proximoCursor,
        carregandoMais: false,
      ));
    case Failure():
      emit(estadoAtual.copyWith(carregandoMais: false, erroAoCarregarMais: true));
    case Loading():
      break;
  }
}
```

### Pattern 5: `CidadeRemoteDataSource` — segue o `next` como URL absoluta
**What:** O envelope de `GET /cidades` devolve `next` como uma URL completa (ver §4 do contrato
e o próprio `contrato/imoveis.example.json`, mesma forma), não um token de `cursor` isolado. O
datasource deve passar essa URL diretamente para `dio.get(url)` (Dio aceita URL absoluta,
ignorando o `baseUrl` configurado) em vez de tentar extrair/recompor o parâmetro `cursor`.
**When to use:** Sempre que consumir um endpoint `CursorPagination` do DRF — é o padrão do
próprio framework (cursor opaco por design, §4 do contrato: "Sem pulo de página — só
próxima/anterior").
**Example:**
```dart
@lazySingleton
class CidadeRemoteDataSource {
  CidadeRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<CidadeModel>> obterCidades() async {
    final cidades = <CidadeModel>[];
    String? proximaUrl = '/api/publico/cidades/';
    while (proximaUrl != null) {
      final resposta = await _dio.get<Map<String, dynamic>>(proximaUrl);
      final envelope = resposta.data!;
      final linhas = (envelope['results'] as List).cast<Map<String, dynamic>>();
      cidades.addAll(linhas.map(CidadeModel.fromJson));
      proximaUrl = envelope['next'] as String?; // URL absoluta — dio.get aceita direto
    }
    return cidades;
  }
}
```

### Pattern 6: Fronteira de repositório de imóveis pronta para DI, sem `@Environment` ainda
**What:** Nesta fase existe **só** uma implementação de `ImovelRepository`
(`ImovelRepositoryImpl` → `ImovelMockDataSource`), registrada com `@LazySingleton(as:
ImovelRepository)` normal — sem `@Environment`/flavors ainda, porque não há segunda
implementação para escolher entre. A Fase 4 é quem introduz a implementação remota e, só então,
decide o mecanismo de troca (discretion note já cobre isso). Registrar `@Environment` prematuro
sem um segundo registro correspondente não tem efeito e adiciona complexidade sem necessidade
agora.
**When to use:** Sempre que "preparar para trocar depois" significa isolar atrás de uma
interface — não significa introduzir o mecanismo de seleção antes de existir o que selecionar.

### Anti-Patterns to Avoid
- **Sealed state por página:** um `case` para "carregando página 2", outro para "erro na página
  2" etc. — força a UI a decidir manualmente como não perder a lista renderizada; ver Pattern 1.
- **Parsear/reconstruir a URL de `next`:** extrair o `cursor` manualmente do envelope e remontar
  a query string — reimplementa o que o Django já fez; ver Pattern 5.
- **`@Environment` sem segunda implementação:** decoração de DI sem efeito nesta fase — adiciona
  ruído de revisão sem benefício (ver Pattern 6).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Formatação de moeda BRL | Concatenação manual de "R$" + separador de milhar | `intl`'s `NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')` | Separador de milhar/decimal pt-BR tem regras (ponto vs vírgula) fáceis de errar à mão; `intl` já resolve — mas **atenção**: por padrão sempre emite 2 casas decimais, então o "sem centavos quando forem zero" de D-03 ainda precisa de um branch manual (ver Pitfall 7) |
| Normalização de texto para busca (acento/caixa) no mock | Reimplementar remoção de acento do zero para `Imovel.titulo`/`bairro` | Extrair `Cidade._normalizar` (já existe, `lib/domain/entities/cidade.dart:17-27`) para um util compartilhado, ex. `core/texto_normalizado.dart` | O projeto já resolveu esse problema uma vez (F1) — duplicar a lógica arrisca as duas implementações divergirem silenciosamente (o mesmo tipo de bug que o Pitfall 4 da Fase 1 já documentou para cidades) |
| Envelope de paginação genérico (`Envelope<T>`) | `@freezed` genérico com `json_serializable` (`genericArgumentFactories: true` + `fromJsonT` manual em cada call site) | Duas classes concretas não-genéricas: `ImoveisEnvelopeModel` e (se precisar) `CidadesEnvelopeModel` | Freezed genérico + json_serializable exige passar funções de conversão manualmente em cada `fromJson`/`toJson` — mais boilerplate do que duplicar uma classe de 3 campos duas vezes, para um projeto com só dois envelopes no total nesta fase |
| Scroll infinito / debounce | `infinite_scroll_pagination` / `easy_debounce` | `ScrollController` + `Cubit` hand-rolled / `Timer` hand-rolled | Já decidido no CLAUDE.md (`§Alternatives Considered`) — mantido aqui por completude, não é uma decisão nova desta fase |

**Key insight:** Nesta fase, os problemas "hand-roll" genuínos não são bibliotecas faltando — são
lógica que **já foi resolvida uma vez no próprio repo** (normalização de texto) ou que **parece**
precisar de codegen genérico mas não precisa (envelope de paginação). O risco maior é duplicar/
divergir, não reinventar uma roda de terceiros.

## Runtime State Inventory

> Esta fase remove `assets/cidades.json` e `CidadeLocalDataSource` (D-16) — trigger de
> rename/refactor/migração.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Nenhum dado de servidor/banco armazenado sob a chave "cidades locais" — o asset é só um arquivo estático empacotado no app, não um datastore externo. **Nenhuma migração de dado** necessária. | Nenhuma |
| Live service config | N/A — não há serviço externo configurado hoje para cidades (o endpoint real é criado *nesta mesma fase*, não existia antes) | Nenhuma |
| OS-registered state | Nenhum — sem Task Scheduler/launchd/pm2 envolvidos neste app mobile | Nenhuma |
| Secrets/env vars | **Novo** (não renomeado): `API_BASE_URL` via `--dart-define`, D-17. Não existia antes; é uma adição, então não há "chave antiga" para migrar — só documentar no README (D-17 pede isso explicitamente) | Code edit (novo, não migração) |
| Build artifacts | `pubspec.yaml` declara `assets: - assets/cidades.json` (linha confirmada em `pubspec.yaml`, seção `flutter:`). **Se o arquivo for apagado sem remover essa linha, `flutter run`/`flutter build` falha** com "No file or variants found for asset" [CITED: relatos consolidados de GitHub Issues flutter/flutter #119388, #18820 e comunidade — erro bem documentado, bloqueia build]. Remover a entrada do `pubspec.yaml` **no mesmo commit/task** que remove o arquivo. Também: `test/data/cidade_local_datasource_test.dart` fica órfão e deve ser apagado junto com `CidadeLocalDataSource`. | Code edit — remover as 3 peças juntas (arquivo, entrada em pubspec.yaml, teste) na mesma task |

**Nada encontrado em "Stored data" / "Live service config" / "OS-registered state"** — verificado
por leitura direta de `lib/data/datasources/cidade_local_datasource.dart` (lê só um asset
embarcado, sem I/O externo) e por não haver nenhum serviço de infraestrutura fora do app+API
Django neste projeto (mobile-only, sem processos de sistema operacional gerenciando o app).

## Common Pitfalls

### Pitfall 1: Corrida entre debounce (400ms) e latência artificial do mock (500ms)
**What goes wrong:** Sem um token de versão (Pattern 2), digitar rápido e depois apagar/trocar a
busca pode fazer uma resposta antiga (ainda "em voo" por causa dos 500ms de latência simulada)
chegar **depois** de uma resposta mais nova e sobrescrever a lista com dados obsoletos — exatamente
o "cards duplicados ou embaralhados" que o critério de sucesso 4 proíbe.
**Why it happens:** D-08 (debounce) e D-14 (latência artificial de 500ms) são duas fontes de
atraso assíncrono independentes empilhadas uma sobre a outra — o teste manual "feliz" (digitar
devagar) não expõe o bug; só digitar rápido + apagar + trocar ordenação em sequência expõe.
**How to avoid:** Pattern 2 (token de requisição), aplicado tanto à primeira página quanto ao
"carregar mais" (Pattern 4).
**Warning signs:** Lista "pisca" para um conteúdo antigo depois de aparecer o novo; testes
manuais alternando busca rapidamente mostram resultado da busca anterior brevemente.

### Pitfall 2: Scroll listener disparando `carregarMais()` várias vezes
**What goes wrong:** O evento de scroll dispara a cada frame perto do fim da lista; sem guarda,
múltiplas chamadas a `carregarMais()` partem antes da primeira resolver, cada uma pedindo a
"próxima página" com o mesmo cursor (porque o estado só atualiza o cursor depois que a primeira
resposta chega) → itens duplicados na lista.
**Why it happens:** `ScrollController` não tem debounce embutido; o padrão oficial do
`bloclibrary.dev` já assume esse cuidado ("carregando" como flag de estado), mas é fácil esquecer
ao adaptar de evento (Bloc) para método direto (Cubit).
**How to avoid:** Pattern 4 — checar `!carregandoMais` antes de disparar, e emitir
`carregandoMais: true` de forma síncrona (antes do primeiro `await`).
**Warning signs:** Mesmo `id` de imóvel aparecendo duas vezes ao rolar rápido.

### Pitfall 3: `CursorPagination` do DRF não suporta ordenação com nulls-last
**What goes wrong:** D-12 pede que a ordenação por preço/área trate nulos como "vão para o fim"
(nulls last) no **servidor**. A documentação oficial do DRF é explícita: o campo de `ordering` do
`CursorPagination` "should be a non-nullable value that can be coerced to a string" [CITED:
django-rest-framework.org/api-guide/pagination/, seção CursorPagination, lida diretamente nesta
sessão]. Um discussion do próprio repositório do DRF confirma que mesmo sobrescrever a ordenação
via `OrderingFilter` custom não resolve, porque o `CursorPagination` reaplica sua própria
ordenação por cima [CITED: github.com/encode/django-rest-framework/discussions/9456].
**Why it happens:** `preco_venda`/`preco_aluguel`/`area` são `nullable=True` no model Django
(`Imovel.preco_venda`, confirmado em `imoveis/models.py` — `null=True, blank=True`); D-12 não foi
escrita sabendo dessa limitação de framework.
**How to avoid:** **Não bloqueia esta fase** — o `ImovelMockDataSource` é Dart puro e implementa
nulls-last com um `Comparator` trivial (`compareTo` tratando `null` como "maior que qualquer
valor" na ordem ascendente, e o oposto na descendente). **Mas** é um achado que precisa entrar no
adendo do contrato (`01-CONTRATO-API.md §7`) para o E2 decidir antes da Fase 4 — as opções
plausíveis são: anotar o queryset com `Coalesce(F('preco_venda'), Value(<sentinela>))` para
transformar o null num valor real e ordenável (workaround comum, mas exige escolher uma
sentinela segura), ou trocar `CursorPagination` por `PageNumberPagination` só para as ordenações
por preço/área (quebra a garantia "sem cards duplicados/embaralhados" do próprio D-01 do
contrato — provavelmente pior). Registrar como risco aberto, não como decisão tomada por esta
pesquisa.
**Warning signs:** Nenhum nesta fase (mock não tem essa limitação); vira warning sign na Fase 4
se a ordenação por preço no endpoint real omitir silenciosamente os imóveis com preço nulo em vez
de colocá-los no fim.

### Pitfall 4: Regra "cidade atendida" divergindo entre o mock de imóveis e o endpoint real de cidades
**What goes wrong:** O `ImovelMockDataSource` fixa uma lista de ~4 cidades atendidas (mesmas do
`contrato/cidades.example.json`: Campinas, Valinhos, Vinhedo, Indaiatuba). Se o endpoint real
`GET /api/publico/cidades/` (criado nesta mesma fase) aplicar a regra de `Empresa.cidades_atuacao`
(§2.3 do contrato) e o conjunto resultante não bater exatamente com o hardcoded do mock de
imóveis, o app pode mostrar uma cidade no seletor que a vitrine mock não conhece (tela vazia
silenciosa) — o mesmo tipo de drift que o Pitfall 4 do RESEARCH da Fase 1 já advertia para o
asset antigo.
**Why it happens:** Duas fontes de verdade hardcoded (fixture de cidades no endpoint real via
seed de banco, fixture de imóveis no mock Dart) que não são geradas a partir da mesma lista.
**How to avoid:** Ao popular o banco Django de desenvolvimento com as `Empresa`s ativas/cidades
de atuação para satisfazer §2.3, usar exatamente as mesmas 4 cidades do
`contrato/cidades.example.json` — e documentar essa constância no README ou nos fixtures/seeds
Django, para não divergir silenciosamente do `ImovelMockDataSource`.
**Warning signs:** Selecionar uma cidade na lista (agora vinda do endpoint real) e a vitrine cair
no estado "vazio" para uma cidade que deveria ter os ~40 imóveis da fixture.

### Pitfall 5: Freezed genérico + json_serializable — boilerplate inesperado
**What goes wrong:** Modelar `Envelope<T>` como uma única classe `@freezed` genérica reutilizável
para cidades e imóveis parece DRY, mas `json_serializable` exige `genericArgumentFactories: true`
e então **cada** call site de `fromJson` precisa passar manualmente a função de conversão do tipo
interno (`Envelope<CidadeModel>.fromJson(json, (j) => CidadeModel.fromJson(j as Map<String,
dynamic>))`) — build_runner não resolve isso sozinho.
**Why it happens:** A combinação `freezed` + `json_serializable` com genéricos é um padrão
conhecido mas verboso do ecossistema; não é óbvio até se tentar.
**How to avoid:** Ver Don't Hand-Roll — duas classes concretas (`ImoveisEnvelopeModel`,
`CidadesEnvelopeModel` se necessário) em vez de um genérico.
**Warning signs:** Build do `build_runner` passando mas o `fromJson` gerado pedindo um parâmetro
extra de função que não estava no plano original.

### Pitfall 6: Card com altura inconsistente quando a imagem falha
**What goes wrong:** `cached_network_image`'s `placeholder`/`errorWidget`/imagem carregada com
sucesso podem, cada um, renderizar em uma altura diferente se não estiverem todos dentro do
**mesmo** container de altura fixa/`AspectRatio` — quebrando D-04 ("mesma proporção da foto,
para que todos os cards tenham a mesma altura").
**Why it happens:** É comum escrever `placeholder: (ctx, url) => CircularProgressIndicator()`
sem envolver num container do mesmo tamanho da imagem final — o `CircularProgressIndicator` sozinho
tem tamanho intrínseco pequeno, diferente da foto.
**How to avoid:** Envolver o `CachedNetworkImage` inteiro (incluindo `placeholder` e
`errorWidget`) num único `AspectRatio` (mesma razão de aspecto em todos os 3 estados) — nunca
depender do tamanho intrínseco de cada widget filho.
**Warning signs:** Cards "pulando" de altura enquanto a lista rola e as imagens terminam de
carregar.

### Pitfall 7: `NumberFormat.currency` sempre emite 2 casas decimais por padrão
**What goes wrong:** D-03 pede "R$ 450.000" (sem ",00") quando os centavos são zero, mas
`NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')` por padrão sempre formata com
`decimalDigits: 2` — sem tratamento extra, todo preço aparece como "R$ 450.000,00".
**Why it happens:** É o comportamento padrão documentado do construtor `NumberFormat.currency`;
não há flag "esconder zero" embutida.
**How to avoid:** Checar se o valor é inteiro (`valor == valor.truncateToDouble()` ou `valor % 1
== 0`) e escolher `decimalDigits: 0` nesse caso, `decimalDigits: 2` caso contrário — mantendo essa
lógica fora do widget, junto com o parsing (D-03: "conversão... fica fora do widget"), por
exemplo num método `Imovel.precoVendaFormatado` ou numa função presenter dedicada.
**Warning signs:** QA reportando que todo preço mostra ",00" mesmo quando o valor é redondo.

## Code Examples

### `ImovelModel` (freezed + json_serializable, forma exata do contrato §3.1+§3.2)
```dart
// Source: forma verbatim de contrato/imoveis.example.json (lido nesta sessão) +
// 01-CONTRATO-API.md §3.1/§3.2
@freezed
abstract class ImovelModel with _$ImovelModel {
  const ImovelModel._();

  const factory ImovelModel({
    required int id,
    required String titulo,
    required String finalidade, // "VENDA" | "ALUGUEL" | "VENDA_E_ALUGUEL"
    String? precoVenda,   // string decimal nullable — nunca parseado na UI
    String? precoAluguel, // string decimal nullable
    required String descricao,
    required String bairro,
    required CidadeModel cidade,
    String? fotoCapa,
    required List<String> caracteristicas,
    required String criadoEm, // ISO 8601 — parse só se precisar ordenar/exibir data
    String? natureza,  // PENDENTE E2 — nullable até o campo existir de fato no backend
    int? quartos,      // PENDENTE E2
    int? suites,        // PENDENTE E2
    int? vagas,          // PENDENTE E2
    String? area,        // PENDENTE E2 — string decimal
  }) = _ImovelModel;

  factory ImovelModel.fromJson(Map<String, Object?> json) =>
      _$ImovelModelFromJson(json);
}
```
*Nota: os campos PENDENTE E2 (`natureza`, `quartos`, `suites`, `vagas`, `area`) já constam do
`contrato/imoveis.example.json` de exemplo e por isso são exigidos no `ImovelModel` para
compilar a UI (VIT-02 pede "natureza"/"quartos" no card); no mock eles sempre virão preenchidos
pela fixture. No dia em que o E2 confirmar o campo real, só o backend muda — o parsing já bate
(mesma razão de D-02 do contrato).*

### `ImoveisEnvelopeModel` (não-genérico, ver Pitfall 5)
```dart
@freezed
abstract class ImoveisEnvelopeModel with _$ImoveisEnvelopeModel {
  const factory ImoveisEnvelopeModel({
    String? next,
    String? previous,
    required List<ImovelModel> results,
  }) = _ImoveisEnvelopeModel;

  factory ImoveisEnvelopeModel.fromJson(Map<String, Object?> json) =>
      _$ImoveisEnvelopeModelFromJson(json);
}
```

### Django — endpoint público de cidades (API-02, orientação, discretion do planner)
```python
# Source: precedente já existente em empresas/api/views.py (EmpresaPublicaAPIView) +
# 01-CONTRATO-API.md §2.3, lido diretamente em empresas/api/serializers.py e
# localizacao/models.py nesta sessão.
from rest_framework import generics
from rest_framework.pagination import CursorPagination
from rest_framework.permissions import AllowAny

from localizacao.models import Cidade
from empresas.api.serializers import CidadeSerializer  # já existe, reaproveitável


class CidadeCursorPagination(CursorPagination):
    ordering = ("nome", "uf")  # mesmo Meta.ordering de Cidade — estável e não-nulo


class CidadesPublicasAPIView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = CidadeSerializer
    pagination_class = CidadeCursorPagination
    queryset = Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()
```
*Registrar em `empresas/api/urls_publico.py` (já roteado em `config/urls.py` sob `api/publico/`)
como `path("cidades/", CidadesPublicasAPIView.as_view(), name="publico-cidades")`.*

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `assets/cidades.json` fixo empacotado no app (Fase 1, D-13 daquela fase) | `GET /api/publico/cidades/` real via Dio | Nesta fase (D-16) | Fonte única da verdade; remove drift entre asset e regra "atendida" real do backend — mas introduz a necessidade de tratar falha de rede (D-16 já cobre: `erroCarregarCidades` + "Tentar de novo") |
| N/A (não existia paginação de imóveis) | `CursorPagination` simulada no mock, mesma forma do futuro endpoint real | Nesta fase (D-01 da Fase 1, D-14 desta fase) | Estabelece o contrato de scroll infinito que a Fase 4 só troca de implementação, não de forma |

**Deprecated/outdated:**
- `CidadeLocalDataSource` + `assets/cidades.json`: removidos nesta fase (D-16) — reversível via
  git se necessário (ver Runtime State Inventory).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|-----------------|
| A1 | O `ImovelMockDataSource` deve usar um asset JSON (`assets/mocks/imoveis_fixture.json`) em vez de uma lista Dart hardcoded para os ~40 imóveis/cidade | Recommended Project Structure | Baixo — é só uma escolha de onde os dados moram; troca fácil (a interface `ImovelMockDataSource.obterImoveis(...)` não muda). A alternativa (lista Dart const) evita adicionar mais uma entrada a `pubspec.yaml assets:` (relevante depois do Pitfall/Runtime-State sobre asset ausente) — vale decidir explicitamente no plano, não うassumir |
| A2 | `next`/`previous` de `GET /cidades` seguem exatamente a mesma forma de URL absoluta observada no exemplo de `/imoveis` (o exemplo de `cidades.example.json` só tem `"next": null`, nunca mostra um `next` populado) | Pattern 5 | Médio — se o endpoint real (criado nesta fase, ainda não implementado) devolver o `next` em outro formato (ex.: só o cursor, sem URL completa), o loop de paginação de `CidadeRemoteDataSource` precisa ajustar; como quem implementa o endpoint é o mesmo time desta fase, mitigar testando manualmente contra o próprio endpoint recém-criado antes de considerar VIT-06 fechado |
| A3 | As 4 cidades do `contrato/cidades.example.json` (Campinas, Valinhos, Vinhedo, Indaiatuba) são as que devem ser semeadas no banco Django de desenvolvimento para satisfazer a regra "atendida" (§2.3) e baterem com o `ImovelMockDataSource` | Pitfall 4 | Médio — se o seed de dev usar outras cidades, a vitrine mostra "vazio" para cidades reais que a fixture do mock não cobre; mitigado documentando a lista compartilhada num único lugar (seed script ou fixture Django) |

**Se esta tabela parecer curta:** a maior parte das decisões de forma de dado já veio travada do
contrato congelado na Fase 1 (`01-CONTRATO-API.md`) e das decisões `D-01`..`D-17` do
`02-CONTEXT.md` — o que resta em aberto é principalmente onde/como popular os dados de
desenvolvimento (fixture Dart vs asset, seed Django), não a forma dos dados em si.

## Open Questions

1. **Nulls-last em `CursorPagination` (Pitfall 3) — como o endpoint real da Fase 4 vai resolver?**
   - What we know: DRF documenta que o campo de `ordering` deve ser non-nullable; um workaround
     comum é `Coalesce` numa sentinela.
   - What's unclear: qual sentinela é segura para `preco_venda`/`preco_aluguel`/`area` sem
     colidir com um valor real, e se o E2 vai preferir resolver isso ou usar
     `PageNumberPagination` só para essas duas ordenações.
   - Recommendation: registrar como item aberto no adendo do contrato (D-12) para o E2 decidir
     antes da Fase 4; não bloqueia esta fase porque o mock é Dart puro.

2. **A `ImovelMockDataSource` deve ler de um asset JSON ou de uma constante Dart?** (ver A1)
   - What we know: D-14 pede "fixture com cerca de 40 imóveis por cidade atendida, forma exata
     de `contrato/imoveis.example.json`".
   - What's unclear: se deve ser um arquivo de asset (mais fácil de editar/revisar como JSON
     puro, mas soma mais uma entrada a `pubspec.yaml assets:`) ou uma lista Dart const (zero
     I/O, mas ~160 objetos hardcoded no código-fonte).
   - Recommendation: o planner decide; qualquer uma satisfaz D-14 — só documentar a escolha.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|--------------|------------|---------|-----------|
| Flutter SDK | Todo o app | ✓ | 3.47.5 (stable) [VERIFIED: `flutter --version` executado nesta sessão] | — |
| Dart SDK | Codegen/build_runner | ✓ | 3.13.4 (bundled) | — |
| Repo irmão `../imoveis-aqui/Web` (Django) | API-02 (endpoint real de cidades) | ✓ | Django 5.2.17, DRF 3.18.1 [VERIFIED: `requirements.txt` lido nesta sessão] | — |
| Emulador Android / dispositivo físico | Testar `--dart-define=API_BASE_URL` (D-17) | Não verificável neste ambiente (sessão sem emulador ativo) | — | Documentar os dois valores de `API_BASE_URL` (emulador `10.0.2.2`, físico = IP da rede local) no README, como D-17 já pede — não bloqueia o desenvolvimento/testes unitários |

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** verificação em dispositivo real fica para checkpoint
manual de UAT, não bloqueia o plano.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled) + `bloc_test` ^10.0.0 + `mocktail` ^1.0.5 — já instalados desde a Fase 1 |
| Config file | nenhum `dart_test.yaml` dedicado — padrão do `flutter test` |
| Quick run command | `flutter test test/presentation/vitrine_cubit_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|---------------------|--------------|
| VIT-01 | `VitrineCubit.carregar(cidade)` emite `sucesso` com itens do mock | unit (`blocTest`) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ Wave 0 |
| VIT-02 | `ImovelCard` renderiza foto/título/preço/natureza/bairro/quartos; placeholder quando `fotoCapa == null` | widget | `flutter test test/presentation/imovel_card_test.dart` | ❌ Wave 0 |
| VIT-03 | Busca com 1 char não dispara; 2+ chars dispara após 400ms virtuais (`fake_async`); campo vazio recarrega na hora; "erro" dispara falha determinística (D-15) | unit (`blocTest` + `fake_async`) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ Wave 0 |
| VIT-04 | `ordenarPor(...)` reinicia a lista do topo com a nova ordenação | unit (`blocTest`) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ Wave 0 |
| VIT-05 | `carregarMais()` respeita `carregandoMais`/`proximoCursor==null`; respostas atrasadas descartadas (token de versão) | unit (`blocTest`) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ Wave 0 |
| VIT-06 | `CidadeRemoteDataSource` percorre páginas até `next == null`; falha de rede propaga para `erroCarregarCidades` | unit (mocktail no `Dio`/`DioAdapter`, ou mock direto do datasource na camada de repositório) | `flutter test test/data/cidade_remote_datasource_test.dart` | ❌ Wave 0 |
| API-02 | `GET /api/publico/cidades/` responde 200 sem token, só cidades atendidas | manual-only (Django, fora do runner Flutter) — justificativa: suíte de teste automatizada é responsabilidade do repo irmão, fora do escopo de `flutter test` deste repositório | `curl http://localhost:8000/api/publico/cidades/` (manual) | — |
| API-04 | `ImovelRepositoryImpl` delega a `ImovelMockDataSource` sem vazar o acervo completo para o Cubit | unit (`blocTest`/mock de repositório) | `flutter test test/data/imovel_repository_impl_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/presentation/vitrine_cubit_test.dart` (e o arquivo de
  teste específico da task em questão)
- **Per wave merge:** `flutter test` (suíte completa)
- **Phase gate:** Suíte completa verde antes de `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/presentation/vitrine_cubit_test.dart` — cobre VIT-01, VIT-03, VIT-04, VIT-05
- [ ] `test/presentation/imovel_card_test.dart` — cobre VIT-02
- [ ] `test/data/cidade_remote_datasource_test.dart` — cobre VIT-06
- [ ] `test/data/imovel_repository_impl_test.dart` — cobre API-04
- [ ] `test/data/imovel_mock_datasource_test.dart` — cobre D-14/D-15 (gatilhos determinísticos de
  erro/vazio, ordenação nulls-last, filtro busca título+bairro)
- [ ] Instalar `fake_async` (dev dependency) — necessário para testar o debounce de D-08 sem
  tempo real de execução (`flutter pub add --dev fake_async`)

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|---------------------|
| V2 Authentication | não | Endpoint público `AllowAny` por design (vitrine sem login) — mesmo padrão já auditado em `EmpresaPublicaAPIView` |
| V3 Session Management | não | Sem sessão/token nesta fase |
| V4 Access Control | sim | Queryset de cidades **deve** filtrar `empresas_atuantes__ativa=True` no nível do banco (§2.3 do contrato), nunca confiar em parâmetro de request — mesmo padrão do `EmpresaScopedQuerySetMixin` já usado no `ImovelViewSet` autenticado |
| V5 Input Validation | sim | `busca`/`ordenacao`/`cursor` tratados como strings opacas no lado do app (nunca interpretados/validados no cliente); no backend (fora desta fase para imóveis, mas relevante para o endpoint de cidades desta fase), DRF já valida tipos via serializer |
| V6 Cryptography | não | Nada de criptografia nova nesta fase — `dio` sobre HTTP(S) padrão, sem token para guardar |

### Known Threat Patterns for {Flutter app consumindo API pública Django/DRF}

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|-------------------------|
| Endpoint público vazando cidades não-atendidas (sem filtro de `Empresa.ativa`) | Information Disclosure | Queryset `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` obrigatório no nível do banco (Code Example 5) — nunca confiar em filtro de query param para decidir o que é público |
| Cliente tentando manipular `cursor`/`busca`/`ordenacao` para causar erro 500 ou consulta cara no backend | Denial of Service (leve) | Fora do escopo desta fase (mock não tem banco real), mas o adendo do contrato (Pitfall 3) já sinaliza que o backend real precisa validar `ordenacao` contra um enum fechado, não aceitar string arbitrária — relevante para quando a Fase 4 implementar o endpoint real |
| App confiando cegamente em `next` do envelope sem validar que é do mesmo host/base (SSRF client-side improvável, mas `dio.get(url_absoluta)` segue redirecionamentos por padrão) | Tampering (baixo risco, canal já é o próprio backend confiável) | Como o `next` vem sempre do próprio backend confiável (HTTPS/base URL configurada), risco é baixo nesta fase; não introduzir lógica que aceite uma `next` vinda de fonte não-confiável no futuro |

## Sources

### Primary (HIGH confidence)
- `pub.dev/api/packages/{intl,cached_network_image,fake_async}` (+ `/score`) — fetched diretamente
  nesta sessão (2026-09-25) — versão, publisher, downloads/30d
- `django-rest-framework.org/api-guide/pagination/` — seção CursorPagination, lida diretamente
  nesta sessão — requisito "non-nullable" do campo de ordering
- `django-rest-framework.org/api-guide/filtering/` — seções SearchFilter e OrderingFilter, lidas
  diretamente nesta sessão — `search_param`/`SEARCH_PARAM`, `ordering_fields`, `ORDERING_PARAM`
- Leitura direta de código nesta sessão: `../imoveis-aqui/Web/localizacao/models.py`,
  `empresas/models.py`, `empresas/api/serializers.py`, `empresas/api/views.py`,
  `empresas/api/urls_publico.py`, `config/urls.py`, `config/settings.py`, `imoveis/models.py`,
  `requirements.txt`
- Leitura direta de código nesta sessão: `lib/core/result.dart`,
  `lib/data/repositories/cidade_repository_impl.dart`,
  `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart`,
  `lib/presentation/cidade_selecao/cidade_selecao_state.dart`,
  `lib/presentation/cidade_selecao/cidade_selecao_screen.dart`,
  `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart`,
  `lib/data/models/cidade_model.dart`, `lib/domain/entities/cidade.dart`,
  `lib/data/datasources/cidade_local_datasource.dart`, `lib/di/injection.dart`,
  `lib/domain/repositories/cidade_repository.dart`,
  `lib/domain/usecases/obter_cidades_atendidas_usecase.dart`, `lib/main.dart`,
  `lib/app_theme.dart`, `pubspec.yaml`, `analysis_options.yaml`,
  `test/presentation/cidade_selecao_cubit_test.dart`
- `.planning/phases/01-.../01-CONTRATO-API.md`, `contrato/imoveis.example.json`,
  `contrato/cidades.example.json`, `01-UI-SPEC.md` — documentos congelados da Fase 1, lidos
  diretamente nesta sessão

### Secondary (MEDIUM confidence)
- `bloclibrary.dev/tutorials/flutter-infinite-list/` — padrão oficial de `ScrollController` +
  Bloc/Cubit para scroll infinito (já citado no CLAUDE.md; confirmado via WebSearch nesta sessão)
- GitHub `encode/django-rest-framework` discussion #9456 — confirma que `CursorPagination`
  reaplica sua própria ordenação por cima de qualquer `OrderingFilter` custom com nulls-last
- GitHub issues `flutter/flutter` #119388, #18820 — erro "No file or variants found for asset"
  quando `pubspec.yaml` referencia um asset ausente

### Tertiary (LOW confidence)
- Nenhuma claim desta pesquisa ficou apoiada só em busca não-cruzada — todas as claims de
  bibliotecas/framework foram verificadas contra pub.dev ou docs oficiais do DRF; claims de
  código foram verificadas por leitura direta.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — todas as versões novas (`intl`, `cached_network_image`, `fake_async`)
  verificadas diretamente via API do pub.dev nesta sessão; o resto já estava travado desde a Fase 1
- Architecture: HIGH — grounded na estrutura de código já existente do próprio repo (mesmo padrão
  de `cidade_selecao_*` reaplicado a `vitrine_*`)
- Pitfalls: HIGH para os pitfalls 1/2/4/6/7 (lógica própria do domínio, sem dependência externa
  incerta); MEDIUM para o Pitfall 3 (depende de decisão futura do E2 na Fase 4, não bloqueia esta
  fase)

**Research date:** 2026-09-25
**Valid until:** 2026-10-25 (30 dias — stack Flutter/DRF estável, mas o contrato tem itens
PENDENTE E2 que podem mudar por decisão de negócio antes disso)
