---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 01
subsystem: ui
tags: [flutter, flutter_bloc, freezed, json_serializable, injectable, get_it, material3, tracer]

# Dependency graph
requires:
  - phase: 03-filtros-da-vitrine
    provides: "vitrine com ImovelCard, VitrineScreen, FotoCapaImovel, apresentacao_imovel, linhasAcervoFixture e o padrao de mock trocavel (DataSource + .paraTeste)"
provides:
  - "Pilha completa do detalhe do imovel sobre mock: DetalheImovel/FotoImovel/CorretorResponsavel, ImovelDetalheRepository, ObterDetalheImovelUseCase, DetalheImovelModel.fromJson, ImovelDetalheDataSource (+ mock), DetalheImovelCubit"
  - "abrirDetalheImovel + DetalheImovelScreen (SliverAppBar fixo, cabecalho da previa, secao Descricao, erro com Tentar de novo)"
  - "Toque no ImovelCard da vitrine abre a pagina (ImovelCard.onTap, VitrineScreen.aoAbrirImovel)"
affects: [04-02, 04-03, 04-04, 04-05, 04-06, 04-07, 04-08]

# Actuals (#2632) — chars/4 over files actually changed (hand-written files only, generated outputs excluded)
actuals:
  tokens: 8000
  tasks: 2
  commits: 3
plan_head_before: 4813cf50869e1bbd18a242d46d500dd6d01fc2be

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Navigator.push + MaterialPageRoute com BlocProvider criado no toque; getIt resolvido so dentro de abrirDetalheImovel"
    - "Mock do detalhe serve mapas de wire parseados pelo mesmo Model.fromJson que o remoto usara"
    - "Cabecalho alimentado pela previa Imovel da vitrine para nao pular quando o detalhe chega"
    - "switch exaustivo sem default sobre estado freezed selado, dentro de CustomScrollView"

key-files:
  created:
    - lib/domain/entities/detalhe_imovel.dart
    - lib/domain/repositories/imovel_detalhe_repository.dart
    - lib/domain/usecases/obter_detalhe_imovel_usecase.dart
    - lib/data/models/detalhe_imovel_model.dart
    - lib/data/datasources/imovel_detalhe_datasource.dart
    - lib/data/datasources/imovel_detalhe_mock_datasource.dart
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - lib/data/repositories/imovel_detalhe_repository_impl.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_state.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/detalhe_navegacao_test.dart
  modified:
    - lib/presentation/vitrine/widgets/imovel_card.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - lib/di/injection.config.dart

key-decisions:
  - "abrirDetalheImovel e o unico ponto que resolve DetalheImovelCubit no DI (no toque); VitrineScreen recebe aoAbrirImovel (default abrirDetalheImovel) para os testes da vitrine nao dependerem do DI"
  - "O mock do detalhe devolve ImovelNaoEncontradoException para id ausente, simulando o 404 (D-01); a traducao de DioException 404/TypeError fica para o plano 04-03"
  - "Task 1 nao guarda o id no Cubit (campo sem uso geraria warning no analyze); o id passa a ser guardado em Task 2, quando tentarNovamente o consome"

patterns-established:
  - "Detalhe do imovel: Entity freezed (strings decimais, sem parse no dominio) <- Model.paraEntidade() <- DataSource trocavel"
  - "Teste e2e de navegacao: monta CidadeSelecaoScreen com Cubit falso + pilha real, registra a factory do Cubit no getIt e usa find.descendant(of: DetalheImovelScreen) porque a vitrine segue montada por baixo"

requirements-completed: []  # DET-01 e DET-05 declarados por este plano; REQUIREMENTS.md so os formaliza no 04-02 e planos irmaos ainda os declaram (requirements.ready-ids: 0/2) — nao marcados como completos aqui

coverage:
  - id: D1
    description: "Tocar num card da vitrine abre a pagina do imovel por Navigator.push mostrando na hora capa, titulo, 'bairro · cidade, UF' e preco da previa com indicador de carregamento"
    requirement: DET-01
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#tracer tocar no card 42 mostra a previa com spinner na hora, depois a Descricao do detalhe do mock, e voltar devolve a vitrine"
        status: pass
    human_judgment: false
  - id: D2
    description: "Quando o detalhe chega, a secao Descricao aparece com o texto do detalhe vindo do mock por toda a pilha, e voltar devolve a vitrine com o card ainda na tela"
    requirement: DET-01
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#tracer tocar no card 42 mostra a previa com spinner na hora, depois a Descricao do detalhe do mock, e voltar devolve a vitrine"
        status: pass
    human_judgment: false
  - id: D3
    description: "Falha ao buscar o detalhe mostra 'Nao foi possivel carregar este imovel.' com 'Tentar de novo', que repete a busca e mostra o detalhe quando da certo"
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#retry falha ao abrir mostra a mensagem com Tentar de novo"
        status: pass
    human_judgment: false
  - id: D4
    description: "O detalhe vem de ImovelDetalheDataSource trocavel resolvida pelo DI; nada e montado na UI"
    requirement: DET-05
    verification:
      - kind: integration
        ref: "test/presentation/detalhe_navegacao_test.dart#DI real resolve DetalheImovelCubit e a DataSource do detalhe (mock)"
        status: pass
      - kind: other
        ref: "grep gate: nenhum Mock*DataSource/detalhesAcervoFixture em lib/presentation ou lib/domain; getIt< uma unica vez em detalhe_imovel_screen.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "Aparencia da pagina (SliverAppBar fixo com capa, botao voltar translucido, hierarquia tipografica do cabecalho) e adequada visualmente em dispositivo real"
    verification: []
    human_judgment: true
    rationale: "Adequacao visual e de usabilidade da tela nao e afirmada por teste automatizado; fica para o human-check de fim de fase"

# Metrics
duration: 25min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 01: Pagina do Imovel — Tracer Summary

**Tracer da pagina do imovel: toque no card abre `DetalheImovelScreen` com a previa na hora e a descricao do detalhe servida pelo mock por Cubit -> UseCase -> Repository -> DataSource -> `DetalheImovelModel.fromJson`, com 'Tentar de novo' na falha**

## Performance

- **Duration:** ~25 min (aproximado; o horario de inicio nao foi registrado)
- **Started:** n/a
- **Completed:** 2026-10-12T05:20:00Z
- **Tasks:** 2 (Task 1 tracer: 1 commit; Task 2 TDD: RED + GREEN)
- **Files modified:** 24 (12 novos escritos a mao + 3 modificados + 9 saidas de build_runner)

## Accomplishments

- Pilha completa do detalhe sobre mock: entidades freezed, interface de repositorio com `ImovelNaoEncontradoException`, use case, Model com `fromJson`/`paraEntidade`, DataSource trocavel + mock com fixture do id 42 (500 ms de latencia), repositorio com `Result`, Cubit/State e registro no DI.
- `abrirDetalheImovel` (Navigator.push, sem pacote de rotas) e `DetalheImovelScreen`: `SliverAppBar` fixo com botao voltar, cabecalho da previa que nao pula, secao 'Descricao' e erro com 'Tentar de novo'; sem barra inferior fixa.
- `ImovelCard.onTap` (InkWell dentro do Card) e `VitrineScreen.aoAbrirImovel`; vitrine continua montada por baixo, entao rolagem e filtros sobrevivem ao voltar.
- Suite completa verde (385 testes) e `flutter analyze` sem issues.

## Task Commits

1. **Task 1: Tracer — card -> pagina com previa -> descricao do detalhe do mock** - `eb261cc` (feat)
2. **Task 2: 'Tentar de novo' na falha (TDD)**
   - RED: `4ea9ce8` (test)
   - GREEN: `1380b3d` (feat)

**Plan metadata:** commit `docs(04-01)` seguinte a este arquivo

## TDD Gate Compliance

Task 2 (`tdd="true"`) seguiu RED -> GREEN; nao houve REFACTOR (nada a limpar).

- **RED** (`4ea9ce8`): `flutter test test/presentation/detalhe_navegacao_test.dart` saiu com codigo 1; o teste alvo `retry falha ao abrir mostra a mensagem com "Tentar de novo"...` falhou na assercao `naPagina(find.text('Tentar de novo')) findsOneWidget` (0 encontrados) DEPOIS de a mensagem de erro ter sido encontrada; os outros 2 testes do arquivo passaram (+2 -1). Nao e falha de compilacao nem de fixture.
- **GREEN** (`1380b3d`): mesmo comando, 3/3 passando; suite completa 385/385.
- A ferramenta `gsd_run check tdd-red-evidence` classifica saida TAP do `node --test`, formato que `flutter test` nao produz; a evidencia RED acima foi registrada manualmente. O plano e `type: execute` (nao `type: tdd`), entao o gate de plano nao se aplica; a Task 1 e `type="tracer"` (um commit).

## Files Created/Modified

- `lib/domain/entities/detalhe_imovel.dart` - `DetalheImovel`, `FotoImovel`, `CorretorResponsavel` (freezed, precos como string decimal)
- `lib/domain/repositories/imovel_detalhe_repository.dart` - interface + `ImovelNaoEncontradoException`
- `lib/domain/usecases/obter_detalhe_imovel_usecase.dart` - delega ao repositorio
- `lib/data/models/detalhe_imovel_model.dart` - Models de transporte com `@JsonKey` snake_case, finalidade estrita, natureza tolerante, fotos na ordem recebida
- `lib/data/datasources/imovel_detalhe_datasource.dart` - `caminhoDetalheImovelPublico` e interface trocavel
- `lib/data/datasources/imovel_detalhe_mock_datasource.dart` - servidor simulado (`@LazySingleton(as: ImovelDetalheDataSource)`, `.paraTeste`)
- `lib/data/mocks/imoveis_detalhe_fixture.dart` - `detalhesAcervoFixture()` com o detalhe 42
- `lib/data/repositories/imovel_detalhe_repository_impl.dart` - `Result.success`/`Result.failure`
- `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart` / `_cubit.dart` / `_screen.dart` - estado selado, Cubit (carregar/tentarNovamente) e tela + `abrirDetalheImovel`
- `lib/presentation/vitrine/widgets/imovel_card.dart` - `onTap` opcional com `InkWell`
- `lib/presentation/vitrine/vitrine_screen.dart` - `aoAbrirImovel` (default `abrirDetalheImovel`)
- `lib/di/injection.config.dart` e `*.freezed.dart`/`*.g.dart` - saidas do build_runner (nao editadas a mao)
- `test/presentation/detalhe_navegacao_test.dart` - tracer e2e, retry e2e, DI real

## Decisions Made

- `getIt` so e tocado dentro de `abrirDetalheImovel`, no toque; `VitrineScreen.aoAbrirImovel` permite injetar um falso nos testes (T-04-01-04).
- Task 1 nao guarda o id no Cubit para nao deixar um campo sem uso (warning no `flutter analyze`); o id e guardado em Task 2, quando `tentarNovamente` o usa. Comportamento final identico ao descrito no plano.
- Teste de retorno usa tres `pump`s (toque + 2x 400 ms) porque `Navigator.maybePop` e assincrono e a transicao de saida precisa de mais um quadro.

## Deviations from Plan

Nenhuma de regra 1-4. Dois ajustes de execucao, sem mudanca de escopo:

- O campo `_id` do Cubit foi movido da Task 1 para a Task 2 (ver Decisions Made) para manter `flutter analyze` limpo apos a Task 1.
- O helper de montagem da vitrine e o `tearDown` do `getIt` foram elevados ao escopo de `main()` no arquivo de teste para serem compartilhados pelos grupos `tracer` e `retry`.

**Total deviations:** 0 auto-fixed. **Impact:** nenhum.

## Known Stubs

- `lib/data/mocks/imoveis_detalhe_fixture.dart`: `detalhesAcervoFixture()` serve so o id 42 (decisao do plano: "ONE wire entry"). Tocar em qualquer outro card hoje leva ao estado de erro 'Nao foi possivel carregar este imovel.' (o mock lanca `ImovelNaoEncontradoException`). Planos 04-02/04-04/04-05 ampliam a fixture e o contrato. Intencional e resolvido nos planos seguintes desta fase.

## Issues Encountered

- Disco com 3,2 GiB livres (99% de uso): acima do minimo de 2 GiB da precondicao; build_runner e `flutter test` rodaram sem problema.
- Os arquivos `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` ja estavam modificados antes do plano (orquestrador) e nao foram incluidos nos commits de codigo.

## Threat Flags

Nenhuma superficie nova fora do `<threat_model>` do plano. `DetalheImovelModel` declara so os campos publicos do D-06 (T-04-01-01); o teste de allowlist chega no 04-02.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Esqueleto pronto para os planos seguintes expandirem: galeria, precos/condominio/IPTU, natureza, corretor, tratamento de 404/TypeError (04-03) e contrato (04-02).
- Pendencia de bookkeeping: DET-01/DET-05 nao foram marcados como completos em REQUIREMENTS.md (nao existem la ate o 04-02 e os planos irmaos ainda os declaram).

## Self-Check: PASSED

- Arquivos criados conferidos no disco; commits `eb261cc`, `4ea9ce8`, `1380b3d` presentes em `git log`.
- `flutter test` (385 testes) e `flutter analyze` verdes; grep gates do plano verdes (sem `Mock*DataSource` em presentation/domain, `getIt<` uma vez, sem barra inferior, sem `default:`).

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
