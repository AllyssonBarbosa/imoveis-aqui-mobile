---
phase: 02-vitrine-lista-busca-e-ordena-o
plan: 01
subsystem: ui
tags: [flutter, freezed, bloc_test, mocktail, intl, cached_network_image, clean-architecture]

# Dependency graph
requires:
  - phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
    provides: "CidadeSelecaoScreen/Cubit, Result<T> selado, contrato GET /imoveis (01-CONTRATO-API.md), fixture imoveis.example.json"
provides:
  - "Stack completa de imóveis: Imovel/ConsultaImoveis/PaginaImoveis (domain), ImovelModel/ImoveisEnvelopeModel (data), ImovelRepository/ImovelDataSource (interfaces trocáveis, API-04)"
  - "ImovelMockDataSource — servidor simulado em memória, filtra por cidade (chave natural), latência configurável, gatilho determinístico de cidade vazia (D-15)"
  - "VitrineCubit com token de versão (D-13) e guarda de isClosed — nunca emite resposta obsoleta ou pós-close"
  - "VitrineScreen hospedada por CidadeSelecaoScreen no desfecho autorizadaEAtendida (substitui o placeholder)"
  - "ImovelCard completo: foto 16:9 com placeholder consistente, preço(s) BRL, natureza · bairro · quartos (VIT-02)"
affects: ["02-02", "02-03", "02-04", "02-05", "04 (troca da DataSource mock pela real)"]

# Actuals (#2632)
actuals:
  tokens: 36819
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: ["intl ^0.20.3", "cached_network_image ^4.0.2", "fake_async ^1.3.3 (dev)"]
  patterns:
    - "Estado de sucesso achatado (ConteudoVitrine.carregada com flags) em vez de sealed-por-página — falha ao carregar mais nunca derruba a lista visível (aplicado só à forma; scroll infinito chega em 02-03)"
    - "Token de versão (_versaoConsulta) no Cubit para descartar respostas assíncronas obsoletas (D-13)"
    - "DataSource mock como servidor simulado em memória, parseando a própria forma de wire via fromJson — exercita o mesmo parsing que a Fase 4 vai usar"
    - "AspectRatio único cobrindo placeholder/carregando/erro de imagem, para altura de card consistente (D-04)"
    - "@visibleForTesting construirImagemDeRede em FotoCapaImovel — ponto de extensão só de teste, produção sempre usa CachedNetworkImage"

key-files:
  created:
    - lib/domain/entities/imovel.dart
    - lib/domain/entities/ordenacao_vitrine.dart
    - lib/domain/entities/consulta_imoveis.dart
    - lib/domain/entities/pagina_imoveis.dart
    - lib/domain/repositories/imovel_repository.dart
    - lib/domain/usecases/buscar_imoveis_usecase.dart
    - lib/data/models/imovel_model.dart
    - lib/data/models/imoveis_envelope_model.dart
    - lib/data/datasources/imovel_datasource.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/data/mocks/imoveis_fixture.dart
    - lib/data/repositories/imovel_repository_impl.dart
    - lib/presentation/vitrine/vitrine_state.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - lib/presentation/vitrine/apresentacao_imovel.dart
    - lib/presentation/vitrine/widgets/imovel_card.dart
    - lib/presentation/vitrine/widgets/foto_capa_imovel.dart
    - test/presentation/vitrine_fluxo_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/data/imovel_repository_impl_test.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/imovel_card_test.dart
    - test/presentation/apresentacao_imovel_test.dart
  modified:
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - lib/di/injection.config.dart
    - pubspec.yaml
    - pubspec.lock
    - test/presentation/cidade_selecao_screen_test.dart
    - test/presentation/seletor_cidade_topo_test.dart
    - test/main_launch_routing_test.dart

key-decisions:
  - "Filtro cidade->linhas no ImovelMockDataSource opera sobre os mapas de wire (snake_case) e só parseia via ImoveisEnvelopeModel.fromJson no final — exercita o parsing real sem duplicar lógica de comparação de cidade fora de Cidade.chaveNatural."
  - "ImovelMockDataSource.seguir() lança FormatException deliberada (paginação é escopo do plano 02-03) — não é um placeholder esquecido, é a fronteira explícita desta fatia."
  - "Card completo (Task 2) trocou o ImovelCard mínimo do tracer (Task 1) no mesmo arquivo, sem novo nome de classe — VitrineScreen/testes não precisaram mudar."

requirements-completed: [VIT-01, VIT-02, API-04]

coverage:
  - id: D1
    description: "Visitante que entra numa cidade atendida com imóveis vê a vitrine dessa cidade (header + cards), pela pilha real Cubit->UseCase->Repository->DataSource"
    requirement: "VIT-01"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: cabeçalho \"Campinas, SP\" + cards só de Campinas..."
        status: pass
    human_judgment: false
  - id: D2
    description: "Cidade atendida sem imóveis na fixture mostra o estado vazio próprio, distinto de erro (D-15)"
    requirement: "VIT-01"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Indaiatuba (atendida, sem imóveis na fixture)..."
        status: pass
    human_judgment: false
  - id: D3
    description: "Falha da DataSource vira estado de erro com Tentar de novo; retry re-executa a mesma consulta; respostas obsoletas nunca são emitidas; close() em voo não lança (D-13)"
    requirement: "VIT-01"
    verification:
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart (7 casos: sucesso/vazio/erro/retry/stale/close)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Card completo: foto 16:9 com placeholder consistente, preço(s) BRL formatados fora do widget, natureza · bairro · quartos, mesma ordem em todos os cards (VIT-02)"
    requirement: "VIT-02"
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_imovel_test.dart (12 casos de formatação)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/imovel_card_test.dart (4 casos: layout, VENDA_E_ALUGUEL, placeholder, altura consistente)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Visual real do card (fotos carregando de verdade, altura consistente, paleta) em dispositivo/emulador — depende do servidor Django (plano 02-02) rodando"
    verification: []
    human_judgment: true
    rationale: "Requer o dev server Django do plano 02-02 (ainda não existe nesta fase) e um emulador Android/iOS real — flutter test não carrega imagens de rede de verdade. Human-check já embutido no <verify> da Task 2; consolidado no UAT de fim de fase por human_verify_mode=end-of-phase."
  - id: D6
    description: "ImovelRepositoryImpl nunca nomeia a classe mock; trocar por real na Fase 4 é mudar só a anotação de DI (API-04)"
    requirement: "API-04"
    verification:
      - kind: other
        ref: "grep -rln ImovelMockDataSource lib/presentation lib/domain lib/data/repositories (vazio)"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-09-25
status: complete
---

# Phase 2 Plan 1: Tracer da Vitrine + Card Completo do Imóvel Summary

**Vitrine ponta a ponta sobre um servidor mock em memória (Cubit->UseCase->Repository->DataSource), hospedada dentro de CidadeSelecaoScreen, com o card completo do VIT-02 (foto 16:9, preço BRL, natureza · bairro · quartos).**

## Performance

- **Duration:** 25 min
- **Started:** 2026-09-25T19:36:00Z
- **Completed:** 2026-09-25T20:00:40Z
- **Tasks:** 2
- **Files modified:** 36 (lib/ + test/, incluindo gerados `.freezed.dart`/`.g.dart`)

## Accomplishments
- Stack completa de imóveis (domain/data/presentation) construída do zero sobre um `ImovelMockDataSource` que simula o servidor Django em memória (D-14), atrás da interface trocável `ImovelDataSource` (API-04)
- `VitrineCubit` com token de versão (D-13) e guarda de `isClosed`, provado por 7 testes cobrindo sucesso/vazio/erro/retry/resposta-obsoleta/close-em-voo
- `VitrineScreen` substitui o antigo placeholder `_CorpoCidadeEntrada` dentro de `CidadeSelecaoScreen`, com `SeletorCidadeTopo` movido para dentro dela
- `ImovelCard` completo (VIT-02): foto de capa 16:9 com placeholder consistente em qualquer estado (D-04), preço(s) BRL formatados fora do widget (D-02/D-03), linha de natureza · bairro · quartos
- Teste ponta a ponta (`vitrine_fluxo_test.dart`) exercitando a pilha real desde `CidadeSelecaoScreen` até os `ImovelCard`s renderizados

## Task Commits

Cada task foi commitada atomicamente:

1. **Task 1: Tracer — vitrine da cidade escolhida ponta a ponta sobre a DataSource mock (VIT-01, API-04)** - `d1af4b8` (feat)
2. **Task 2: Card completo do imóvel — foto 16:9, preços BRL, natureza, bairro, quartos (VIT-02)** - `5e75cf9` (feat)

## Files Created/Modified
- `lib/domain/entities/imovel.dart` - Entidade `Imovel` + enums `FinalidadeImovel`/`NaturezaImovel`, sem parsing de preço (D-03)
- `lib/domain/entities/ordenacao_vitrine.dart` - Enum `OrdenacaoVitrine` com `valorApi` (D-11, valores de trabalho)
- `lib/domain/entities/consulta_imoveis.dart` - `ConsultaImoveis` (cidade+busca+ordenação), único parâmetro que atravessa as camadas
- `lib/domain/entities/pagina_imoveis.dart` - `PaginaImoveis` (itens + cursor opaco `proximaPagina`)
- `lib/domain/repositories/imovel_repository.dart` / `usecases/buscar_imoveis_usecase.dart` - Interface trocável + delegação sem lógica
- `lib/data/models/imovel_model.dart` / `imoveis_envelope_model.dart` - freezed+json_serializable, forma exata do contrato §3.1/§3.2, `paraEntidade()`/`paraPagina()`
- `lib/data/mocks/imoveis_fixture.dart` - Fixture em wire shape (3 linhas: 2 Campinas, 1 Valinhos; Indaiatuba sem linhas, D-15)
- `lib/data/datasources/imovel_datasource.dart` / `imovel_mock_datasource.dart` - Interface trocável + servidor simulado (filtro por `Cidade.chaveNatural`, ordenação `criado_em` desc, latência configurável)
- `lib/data/repositories/imovel_repository_impl.dart` - `Result`/try-catch wrapping, nunca nomeia o mock
- `lib/presentation/vitrine/vitrine_state.dart` / `vitrine_cubit.dart` / `vitrine_screen.dart` - Estado "achatado" selado, Cubit com token de versão, tela hospedada
- `lib/presentation/vitrine/apresentacao_imovel.dart` - `formatarPrecoBrl`/`linhasDePreco`/`rotuloNatureza`/`rotuloQuartos`, puros, fora do widget
- `lib/presentation/vitrine/widgets/foto_capa_imovel.dart` / `imovel_card.dart` - Foto com `AspectRatio` único + card completo (VIT-02)
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` - `_CorpoVitrine` substitui `_CorpoCidadeEntrada`, novo param `criarVitrineCubit`
- `pubspec.yaml`/`pubspec.lock` - `+intl`, `+cached_network_image`, `+fake_async` (dev)
- Testes: `vitrine_fluxo_test.dart`, `vitrine_cubit_test.dart`, `imovel_repository_impl_test.dart`, `imovel_mock_datasource_test.dart`, `apresentacao_imovel_test.dart`, `imovel_card_test.dart` (novos); `cidade_selecao_screen_test.dart`, `seletor_cidade_topo_test.dart`, `main_launch_routing_test.dart` (atualizados com `criarVitrineCubit`/fake `VitrineCubit`)

## Decisions Made
- `ImovelMockDataSource` filtra/ordena sobre os mapas de wire (snake_case) e só then constrói o envelope via `ImoveisEnvelopeModel.fromJson` — garante que o parsing exercitado nos testes é idêntico ao que a Fase 4 vai usar contra o endpoint real.
- `seguir()` lança `FormatException` deliberada (paginação é escopo do plano 02-03) — fronteira explícita, não uma lacuna esquecida.
- O `ImovelCard` completo (Task 2) substituiu o card mínimo do tracer (Task 1) no MESMO arquivo/classe — nenhum outro arquivo precisou saber da mudança.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Viewport de `vitrine_fluxo_test.dart` insuficiente para o card completo**
- **Found during:** Task 2 (após completar o `ImovelCard`)
- **Issue:** O card mínimo da Task 1 (2 linhas de texto) cabia inteiro na tela padrão de teste; o card completo (foto 16:9 + textos) é bem mais alto, e o `ListView.builder` só materializa itens dentro do cache extent — o teste de Campinas passou a encontrar 1 `ImovelCard` em vez de 2.
- **Fix:** `tester.view.physicalSize`/`devicePixelRatio` ajustados para uma viewport alta o bastante (400x2400) antes de montar a árvore, com `addTearDown` para restaurar.
- **Files modified:** test/presentation/vitrine_fluxo_test.dart
- **Verification:** `flutter test test/presentation/vitrine_fluxo_test.dart` — 2/2 passando; suíte completa (88 testes) verde.
- **Committed in:** 5e75cf9 (Task 2 commit)

**2. [Rule 1 - Bug] Lint `prefer_initializing_formals` nas construções com parâmetro público/campo privado**
- **Found during:** Task 1 (após escrever `ImovelMockDataSource.paraTeste` e o novo ctor de `CidadeSelecaoScreen`)
- **Issue:** `flutter analyze` reportava 3 infos ("issues found" torna o build fatal, per convenção do projeto) — o parâmetro nomeado não pode usar `this._campoPrivado` porque um formal de inicialização privado não é chamável de fora da library (confirmado experimentalmente), então a forma correta (parâmetro público, atribuição explícita no initializer) precisa do `// ignore` já usado em `CidadeLocalDataSource.comBundle`.
- **Fix:** `// ignore: prefer_initializing_formals` adicionado antes de cada linha de atribuição afetada, mesma convenção já presente no arquivo (`cidade_selecao_screen.dart`).
- **Files modified:** lib/data/datasources/imovel_mock_datasource.dart, lib/presentation/cidade_selecao/cidade_selecao_screen.dart
- **Verification:** `flutter analyze` — "No issues found!"
- **Committed in:** d1af4b8 (Task 1 commit)

**3. [Rule 1 - Bug] Comentário pré-existente continha a substring "catch" (verify negativo do próprio plano)**
- **Found during:** Task 1 (ao tocar `cidade_selecao_screen.dart` para a integração da vitrine)
- **Issue:** O plano adiciona o verify `! grep -rn "catch" lib/presentation`; um comentário já existente ("nunca um `default`/catch-all") já violava essa checagem antes mesmo desta task.
- **Fix:** Reescrito para "nunca um ramo abrangente/coringa" (mesmo sentido, sem a substring).
- **Files modified:** lib/presentation/cidade_selecao/cidade_selecao_screen.dart
- **Verification:** `grep -rn "catch" lib/presentation` — vazio.
- **Committed in:** d1af4b8 (Task 1 commit)

---

**Total deviations:** 3 auto-fixed (2 bugs de teste/lint introduzidos pelo próprio trabalho desta plan, 1 correção de um comentário pré-existente que violava um verify novo do plano).
**Impact on plan:** Nenhum scope creep — todas as correções foram necessárias para o próprio plano passar em seus verifies declarados.

## Issues Encountered
None.

## User Setup Required
None - nenhuma configuração de serviço externo necessária (o mock roda inteiramente em memória).

## Next Phase Readiness
- VIT-01/VIT-02/API-04 completos e testados (unit + widget + e2e); base pronta para paginação (02-03), cidades via API real (02-04), e busca/ordenação (02-05).
- O human-check do Task 2 <verify> (visual real em emulador Android/iOS, fotos carregando de verdade) depende do dev server Django do plano 02-02, que ainda não existe nesta fase — fica para o UAT consolidado de fim de fase (`human_verify_mode: end-of-phase`).
- `ImovelMockDataSource.seguir()` lança `FormatException` deliberada — plano 02-03 implementa paginação de verdade sem mudar a interface `ImovelDataSource`.

---
*Phase: 02-vitrine-lista-busca-e-ordena-o*
*Completed: 2026-09-25*

## Self-Check: PASSED

- All 24 created files verified present on disk (`[ -f ]`).
- Both task commits (`d1af4b8`, `5e75cf9`) verified present in `git log`.
- `flutter test` (full suite, 88 tests), `flutter analyze` (clean), and all three plan-level negative greps re-run and passing at SUMMARY time.
