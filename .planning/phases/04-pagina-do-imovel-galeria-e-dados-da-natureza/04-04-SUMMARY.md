---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 04
subsystem: data
tags: [flutter, mock-server, fixture, url-safety, tdd, dart]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "ImovelDetalheMockDataSource, detalhesAcervoFixture (entrada 42), contrato_detalhe_test, harness e2e do detalhe (planos 04-01..04-03)"
provides:
  - "Detalhe determinístico para toda linha da lista (exceto o id 339), derivado de linhasAcervoFixture() e coerente com o card"
  - "Ids reservados idDetalheDespublicadoMock = 339 (404) e idDetalheFalhaMock = 338 (FalhaSimuladaDoMock), alcançáveis à mão nos dois últimos cards de Vinhedo"
  - "urlHttpOuNula: só URLs http/https chegam à tela (fotos, capa da lista, foto do corretor)"
  - "Testes de consistência lista <-> detalhe, e2e de outros cards/404 e de entrada (ImovelCard.onTap, VitrineScreen.aoAbrirImovel)"
affects: [04-05, 04-06, 04-07, 04-08, fase-05-api-real]

plan_head_before: 514a588676dd975ecb1c63f267b7d2d5ff15d1ca
actuals:
  tokens: 7900
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Fixture derivada: cada detalhe gerado parte da linha da lista, nunca de uma lista paralela (A8)"
    - "Valores gerados só a partir do id: nada de Random nem relógio (D-15 da Fase 2)"
    - "Filtro de esquema de URL na camada de dados (paraEntidade), mantendo a ordem recebida"

key-files:
  created:
    - lib/data/models/url_segura.dart
    - test/data/imovel_detalhe_mock_datasource_test.dart
  modified:
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - lib/data/datasources/imovel_detalhe_mock_datasource.dart
    - lib/data/models/detalhe_imovel_model.dart
    - lib/data/models/imovel_model.dart
    - test/data/detalhe_imovel_model_test.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/presentation/imovel_card_test.dart
    - test/presentation/vitrine_screen_test.dart

key-decisions:
  - "Linhas com id % 10 == 9 são o caso 'campos nulos' (sem condomínio, IPTU, coordenadas nem corretor); fotos extras = id % 4; corretores rotativos por id % 3 (ids 7, 8, 9, o último sem foto e sem slug)"
  - "A fixture gerada não preenche blocos de natureza (casa/apartamento/terreno/lote): ficam para o plano 04-05"
  - "Coordenadas geradas = centro da cidade + deslocamento (id % 50) * 0.0004, formatadas com 6 casas"
  - "urlHttpOuNula também apara espaços e exige host não vazio, além de esquema http/https"

patterns-established:
  - "FalhaSimuladaDoMock da Fase 2 reaproveitada no mock do detalhe (import show), sem editar o arquivo original"
  - "Teste de consistência itera linhasAcervoFixture() em vez de assumir ids"

requirements-completed: [DET-01, DET-02, API-06]

coverage:
  - id: D1
    description: "Todo card da vitrine (exceto o id reservado 339) abre um detalhe com título, finalidade, preços, descrição, bairro, cidade, características e natureza iguais aos do card; fotos vazias exatamente quando o card não tem capa e, quando existem, a primeira é a capa do card"
    requirement: DET-01
    verification:
      - kind: unit
        ref: "test/data/imovel_detalhe_mock_datasource_test.dart#consistência lista <-> detalhe (DET-01, DET-02)"
        status: pass
      - kind: integration
        ref: "test/data/contrato_detalhe_test.dart#fixture do detalhe"
        status: pass
    human_judgment: false
  - id: D2
    description: "Servidor simulado determinístico: 339 sempre 404, 338 sempre falha, duas chamadas da fixture são profundamente iguais, entrada 42 intacta"
    requirement: API-06
    verification:
      - kind: unit
        ref: "test/data/imovel_detalhe_mock_datasource_test.dart#ids reservados (D-15 da Fase 2, D-17)"
        status: pass
      - kind: unit
        ref: "test/data/imovel_detalhe_mock_datasource_test.dart#determinismo (D-15 da Fase 2)"
        status: pass
      - kind: command
        ref: "! grep -nE 'Random\\(|DateTime\\.now\\(' lib/data/mocks/imoveis_detalhe_fixture.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Toque no card abre o detalhe do próprio card (e2e com card 57), um imóvel ausente do servidor termina em 'Este imóvel não está mais disponível' com 'Voltar à vitrine'; ImovelCard.onTap e VitrineScreen.aoAbrirImovel funcionam, e card sem ação não quebra"
    requirement: DET-01
    verification:
      - kind: automated_ui
        ref: "test/presentation/detalhe_navegacao_test.dart#outros cards da vitrine (DET-01, API-06)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/imovel_card_test.dart#toque no card (DET-01, D-18)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/vitrine_screen_test.dart#abrir o imóvel (DET-01, D-18)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Só URLs http/https chegam à tela: fotos, capa da lista e foto do corretor com javascript:, file:, ftp:, data: ou relativas são descartadas sem reordenar as demais"
    requirement: DET-02
    verification:
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart#URLs seguras (DET-02, segurança V12/V13)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Dar para provar os fluxos de 404 e de falha à mão a partir dos dois últimos cards de Vinhedo no app rodando"
    requirement: DET-01
    verification: []
    human_judgment: true
    rationale: "Verificação manual no app rodando (Vinhedo, 'Mais recentes', últimos dois cards); os testes automatizados provam os ids no mock, não a experiência na tela"

duration: 9min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 04: Todo card abre um detalhe e só URLs http(s) chegam à tela Summary

**Servidor simulado gera um detalhe determinístico e coerente para cada card da vitrine (ids 338/339 reservados para falha e 404), e `urlHttpOuNula` barra fotos, capa e foto de corretor fora de http/https na camada de dados**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-12T05:25:00Z (aproximado; o horário de início não foi registrado no começo da execução)
- **Completed:** 2026-10-12T05:35:00Z
- **Tasks:** 2
- **Files modified:** 10 (2 criados, 8 modificados)

## Accomplishments

- `detalhesAcervoFixture()` agora devolve um detalhe para cada linha de `linhasAcervoFixture()` exceto o id 339; a entrada 42 (exemplo do §11) continua verbatim e o `contrato_detalhe_test.dart` valida a allowlist sobre todas as entradas geradas.
- Os campos comuns são copiados da linha da lista; o que a lista não tem (fotos, condomínio, IPTU, coordenadas, corretor) é derivado só do `id`, sem `Random` e sem relógio. Cobre: sem fotos, uma foto, várias fotos, sem corretor, corretor sem foto e sem slug, condomínio/IPTU nulos e uma de cada natureza.
- `ImovelDetalheMockDataSource` lança `FalhaSimuladaDoMock` para o 338 (mesmo existindo entrada no servidor) e `ImovelNaoEncontradoException` para 339 e ids desconhecidos.
- `urlHttpOuNula` aplicada em `DetalheImovelModel.paraEntidade()` (fotos e foto do corretor) e `ImovelModel.paraEntidade()` (capa), sem mudar anotações nem regenerar código.
- Testes de entrada: `ImovelCard.onTap` (uma chamada por toque; sem ação não lança) e `VitrineScreen.aoAbrirImovel` recebendo o `Imovel` tocado; e2e com o card 57 e com servidor sem a entrada 42 (404 e volta à vitrine).

## Task Commits

Cada tarefa seguiu RED -> GREEN:

1. **Task 1: Todo card abre um detalhe coerente, com ids reservados** - `e2a9c83` (test, RED) e `5702fcf` (feat, GREEN)
2. **Task 2: Só URLs http(s) chegam à tela** - `4039378` (test, RED) e `10f61e4` (feat, GREEN)

**Plan metadata:** commit `docs(04-04)` deste SUMMARY (e STATE/ROADMAP/REQUIREMENTS no commit seguinte).

## TDD Gate Compliance

- **RED:** os dois ciclos têm commit `test(04-04)` antes do `feat(04-04)`. Para o RED ser uma falha de asserção (e não erro de compilação por símbolo ausente), o commit RED da Task 1 já trouxe as duas constantes (`idDetalheDespublicadoMock`, `idDetalheFalhaMock`) e o da Task 2 um `urlHttpOuNula` provisório que devolve o valor sem filtrar. Resultado do RED da Task 1: 11 testes falharam por asserção (fixture sem detalhes gerados, 338 sem entrada, e2e do card 57 caindo em 404). RED da Task 2: 5 testes falharam por asserção (esquemas inseguros passando).
- **Verificação formal:** `gsd_run check tdd-red-evidence` espera saída TAP do `node --test`, formato que `flutter test` não produz; a evidência RED ficou registrada nos commits e nesta seção.
- **Verdes inesperados no RED:** os testes de entrada de `ImovelCard.onTap` e `VitrineScreen.aoAbrirImovel` passaram já no RED, porque o comportamento foi entregue no plano 04-01; entram como testes de regressão da cobertura que este plano pede.
- **REFACTOR:** não houve; nenhum commit `refactor`.

## Files Created/Modified

- `lib/data/mocks/imoveis_detalhe_fixture.dart` - constantes de ids reservados, geração `_detalheGerado`/`_fotosGeradas`, corretores fixos e centros das cidades
- `lib/data/datasources/imovel_detalhe_mock_datasource.dart` - 338 lança `FalhaSimuladaDoMock`
- `lib/data/models/url_segura.dart` - `urlHttpOuNula`
- `lib/data/models/detalhe_imovel_model.dart`, `lib/data/models/imovel_model.dart` - filtro de URL em `paraEntidade()`
- `test/data/imovel_detalhe_mock_datasource_test.dart` - consistência lista <-> detalhe, ids reservados, determinismo, cobertura
- `test/data/detalhe_imovel_model_test.dart` - grupo "URLs seguras"
- `test/presentation/detalhe_navegacao_test.dart`, `imovel_card_test.dart`, `vitrine_screen_test.dart` - e2e e entradas

## Decisions Made

- Caso "campos nulos" = `id % 10 == 9`; fotos extras = `id % 4`; corretor rotativo por `id % 3` (ids 7, 8, 9, o terceiro sem foto e sem slug, tolerando o slug PENDENTE E2).
- Blocos de natureza (casa, apartamento, terreno, lote) não são gerados aqui; o plano 04-05 os acrescenta.
- `urlHttpOuNula` apara espaços e exige host, além do esquema, para que `https://` sozinho seja rejeitado.

## Deviations from Plan

None - plan executed exactly as written.

Observação: o `dart format` foi aplicado só aos arquivos tocados; no `vitrine_screen_test.dart` e no `imovel_card_test.dart` ele reformatava código antigo, então reverti e reapliquei as edições à mão para manter o diff restrito ao que o plano pede.

**Total deviations:** 0
**Impact on plan:** nenhum.

## Issues Encountered

- Espaço em disco no limite do pré-requisito (2,2 GiB livres, exigido >= 2 GiB): atendido, nenhum teste falhou por espaço.

## Known Stubs

Nenhum stub de UI. A fixture do detalhe é dado de servidor simulado, dev-only, e sai junto com o mock na Fase 5 (documentado no doc comment).

## Threat Flags

Nenhum. T-04-04-01 (URLs não confiáveis) mitigado por `urlHttpOuNula` e testes por esquema; T-04-04-02 (vazamento de chaves) coberto pela allowlist de `contrato_detalhe_test.dart` sobre todas as entradas geradas.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Pronto para o plano 04-05: a fixture gerada já tem natureza em todo detalhe e chaves dentro da allowlist; falta só preencher os blocos por natureza.
- Verificação manual pendente (end-of-phase): em Vinhedo, 'Mais recentes', o último card deve mostrar "Este imóvel não está mais disponível" e o penúltimo "Tentar de novo".

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*

## Self-Check: PASSED

- Arquivos criados presentes: `lib/data/models/url_segura.dart`, `test/data/imovel_detalhe_mock_datasource_test.dart`.
- Commits presentes: `e2a9c83`, `5702fcf`, `4039378`, `10f61e4`.
- Critérios de aceitação: fixture contém `idDetalheDespublicadoMock = 339`, `idDetalheFalhaMock = 338`, `linhasAcervoFixture`, `_detalheGerado`, `urlBaseFotosMock`; mock contém `FalhaSimuladaDoMock` e `idDetalheFalhaMock`; `urlHttpOuNula` usada nos dois models.
- Verificação do plano: `flutter test` (suíte completa) passou, `flutter analyze` sem problemas, grep de `Random(`/`DateTime.now(` na fixture sem ocorrências.
