---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 03
subsystem: data
tags: [flutter, dart, models, mapeamento, situacao, finalidade, tdd]

requires:
  - phase: 08-login-e-area-do-corretor-o-acervo
    provides: ImovelAcervoModel com mapas privados de finalidade e situação; codigoDaSituacao (sentido enum → código)
provides:
  - "finalidadeDoCodigo e situacaoDoCodigo: único mapa código do Django → enum do domínio, em lib/data/models/codigos_imovel_api.dart"
  - "ImovelAcervoModel.paraEntidade() lendo pelo mapa único, sem mapa privado"
  - "teste de ida e volta entre o mapa de leitura e codigoDaSituacao (trava de drift)"
affects: [09-04 imóvel de gestão, 09-06 histórico, 09-07 tela de gestão]

actuals:
  tokens: 2600
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Mapa código → enum em funções de topo com switch expressão (Dart 3), em data/models/, fora das classes dos Models"
    - "Situação desconhecida ou nula vira null; finalidade desconhecida lança FormatException"

key-files:
  created:
    - lib/data/models/codigos_imovel_api.dart
    - test/data/codigos_imovel_api_test.dart
  modified:
    - lib/data/models/imovel_acervo_model.dart

key-decisions:
  - "Os Models novos da fase (gestão 09-04, histórico 09-06) devem ler situação e finalidade por codigos_imovel_api.dart, nunca por mapa próprio"
  - "O mapa de leitura fica em data/models e o de envio (codigoDaSituacao) continua em data/datasources; a ida e volta é travada por teste, não por unificação de arquivo"

patterns-established:
  - "Um só lugar para traduzir código do servidor em enum: gate de grep garante que só codigos_imovel_api.dart mapeia 'RESERVADO' em lib/data/models"

requirements-completed: [SIT-07, SIT-03]

coverage:
  - id: D1
    description: "Mapa único código → enum (finalidadeDoCodigo e situacaoDoCodigo) com os 3 + 4 códigos, desconhecido, nulo, minúsculas e ida e volta com codigoDaSituacao"
    requirement: "SIT-07"
    verification:
      - kind: unit
        ref: "test/data/codigos_imovel_api_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Meu acervo da Phase 8 segue igual: ImovelAcervoModel usa o mapa único e os testes do acervo passam sem nenhuma expectativa alterada"
    requirement: "SIT-03"
    verification:
      - kind: unit
        ref: "test/data/imovel_acervo_model_test.dart, test/data/acervo_repository_impl_test.dart, test/data/acervo_remote_datasource_test.dart"
        status: pass
    human_judgment: false

duration: 5 min
completed: 2026-11-22
plan_head_before: c10a67cde01887f0d6e657d02401c43ceeaa96f9
commits: 2
status: complete
---

# Phase 9 Plan 03: Mapa único código → enum Summary

**`finalidadeDoCodigo` e `situacaoDoCodigo` como único mapa dos códigos do Django para os enums do app, usado pelo acervo e pronto para a gestão e o histórico, com ida e volta provada contra `codigoDaSituacao`**

## Performance

- **Duration:** 5 min
- **Completed:** 2026-11-22T15:35:20Z
- **Tasks:** 2
- **Files modified:** 3 (2 criados, 1 alterado)

## Accomplishments

- Novo `lib/data/models/codigos_imovel_api.dart` com duas funções de topo (`switch` expressão): `finalidadeDoCodigo` (VENDA, ALUGUEL, VENDA_E_ALUGUEL; outro código lança `FormatException('finalidade desconhecida: <código>')`, mesma mensagem do acervo) e `situacaoDoCodigo` (DISPONIVEL, RESERVADO, VENDIDO, ALUGADO; desconhecido ou nulo vira `null`, T-09-10).
- Teste próprio `test/data/codigos_imovel_api_test.dart` (11 casos): os 3 + 4 códigos, `'PERMUTA'` e `''` lançando `FormatException`, `'EM_OBRA'`, `null` e `'reservado'` (minúsculas) virando `null`, e `situacaoDoCodigo(codigoDaSituacao(s)) == s` para toda `SituacaoImovel` (T-09-14).
- `ImovelAcervoModel.paraEntidade()` passou a usar o mapa único; os dois métodos estáticos privados foram apagados (-33 linhas, +5) e dois imports ficaram sem uso e saíram. Meu acervo continua igual: `imovel_acervo_model_test.dart` passa sem nenhuma linha alterada e os gerados (`.freezed.dart` e `.g.dart`) ficaram idênticos, sem `build_runner`.

## Task Commits

1. **Task 1: Mapa único código → enum com teste próprio e ida e volta** - `3029942` (feat; TDD, RED por arquivo inexistente e GREEN no mesmo commit, como o plano pede um commit por task)
2. **Task 2: O acervo passa a usar o mapa único** - `ba6169d` (refactor)

**Plan metadata:** commit docs(09-03) logo após este SUMMARY.

## Files Created/Modified

- `lib/data/models/codigos_imovel_api.dart` - único lugar que traduz códigos de finalidade e situação do Django para os enums do domínio
- `test/data/codigos_imovel_api_test.dart` - trava dos códigos, do desconhecido, do nulo, das minúsculas e da ida e volta com `codigoDaSituacao`
- `lib/data/models/imovel_acervo_model.dart` - `paraEntidade()` chama o mapa único; mapas privados removidos

## Decisions Made

- Os Models da gestão (09-04) e do histórico (09-06) leem situação e finalidade por `codigos_imovel_api.dart`. Assim chip do acervo, situação da tela de gestão e histórico não discordam sobre o mesmo código (D-03, D-11).
- O sentido enum → código (`codigoDaSituacao`) continua em `data/datasources/parametros_consulta_acervo.dart`, como o plano manda; a coerência entre os dois sentidos é garantida pelo teste de ida e volta, não por mover arquivos.
- Os Models da vitrine pública (`imovel_model.dart`, `detalhe_imovel_model.dart`) não foram tocados (proibição do plano).

## Deviations from Plan

None - plan executed exactly as written.

O único ajuste de execução: o `.claude/skills/flutter-frontend/SKILL.md` citado na leitura obrigatória não existe com esse nome (o arquivo do skill é `.claude/skills/flutter-frontend/skill`); as regras dele (`const`, pattern matching do Dart 3, sem `!`, desacoplamento) já eram atendidas pelo código novo.

## Issues Encountered

None

## Verificação

- `flutter test test/data/codigos_imovel_api_test.dart`: 11 testes verdes.
- `flutter test` dos quatro arquivos do acervo e do mapa: 41 verdes.
- `flutter analyze lib`: No issues found.
- `flutter test` inteiro: **1232 verdes** (linha de base 1194 no plano; os testes novos desta fase somam o restante).
- Gates por grep da Task 1 e da Task 2 passaram: assinaturas e mensagem da `FormatException`; Model sem `_mapearSituacao`/`_mapearFinalidade`; só `codigos_imovel_api.dart` contém `'RESERVADO'` em `lib/data/models` (fora dos gerados); gerados do acervo e teste do acervo sem diff.

## Threat Flags

None - nenhuma superfície nova; o mapa só traduz dado não confiável (T-09-10, T-09-14 mitigados por teste; T-09-SC: nenhum pacote novo).

## Known Stubs

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 09-04 (imóvel de gestão) e 09-06 (histórico) já podem importar `finalidadeDoCodigo`/`situacaoDoCodigo` de `codigos_imovel_api.dart`.
- Nenhum push feito; commits locais em `feat/APP09`.

## Self-Check: PASSED

- `lib/data/models/codigos_imovel_api.dart`, `test/data/codigos_imovel_api_test.dart`: existem.
- Commits `3029942` e `ba6169d` existem em `feat/APP09`; `git rev-list --count c10a67c..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
