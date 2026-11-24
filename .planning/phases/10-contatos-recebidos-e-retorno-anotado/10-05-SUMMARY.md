---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 05
subsystem: data
tags: [models, freezed, caixa-contatos, wire, antidrift]

requires:
  - phase: 10-04
    provides: "entidades da caixa e canalContatoDaApi/retornoContatoDaApi com FormatException"
provides:
  - "ContatoRecebidoModel com paraEntidade (toLocal num único ponto) e ContatosEnvelopeModel com paraPagina"
  - "ResumoContatosModel (sem_retorno) e ImovelComContatoModel com paraEntidade"
  - "Grupo 'Models leem toda fixture de contatos' no teste de contrato (parte do antidrift de API-13)"
affects: [10-06, 10-07, 10-08, 10-09, 10-10]

commits: 4
plan_head_before: bfda909595b9182b47ec7e71dc0a40f47542ee6a
plan_head_after: 41fb70ca68131db47efcea9521d0b10050afb376

estimate_actuals_note: "tokens = chars/4 sobre o diff do app bfda909..41fb70c (65122 chars, inclui os gerados .freezed/.g e os testes)"
actuals:
  tokens: 16280
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Models freezed com const X._(), @JsonKey(name:), fromJson(Map<String, Object?>) e paraEntidade()/paraPagina()"
    - "hora local por DateTime.parse(...).toLocal() só em ContatoRecebidoModel.paraEntidade"

key-files:
  created:
    - lib/data/models/contato_recebido_model.dart
    - lib/data/models/contato_recebido_model.freezed.dart
    - lib/data/models/contato_recebido_model.g.dart
    - lib/data/models/contatos_envelope_model.dart
    - lib/data/models/contatos_envelope_model.freezed.dart
    - lib/data/models/contatos_envelope_model.g.dart
    - lib/data/models/resumo_contatos_model.dart
    - lib/data/models/resumo_contatos_model.freezed.dart
    - lib/data/models/resumo_contatos_model.g.dart
    - lib/data/models/imovel_com_contato_model.dart
    - lib/data/models/imovel_com_contato_model.freezed.dart
    - lib/data/models/imovel_com_contato_model.g.dart
    - test/data/contato_recebido_model_test.dart
  modified:
    - test/data/contrato_contatos_test.dart

key-decisions:
  - "O Model não lê canal_exibicao, retorno_exibicao, corretor nem imovel (id): só o que a caixa exibe (D-09, D-10)"
  - "Datas viram hora local por toLocal() num único ponto, ContatoRecebidoModel.paraEntidade (Achado 7)"
  - "ResumoContatosModel sem const X._() porque não tem método de mapeamento (o número é lido direto)"

requirements-completed: []

coverage:
  - id: D1
    description: "Item e página da caixa lidos do wire real, com hora local num único ponto e FormatException para canal/retorno desconhecido"
    requirement: "CXA-01"
    verification:
      - kind: test
        ref: "test/data/contato_recebido_model_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Resumo (sem_retorno) e opções de imóvel lidos em Models tipados"
    requirement: "CXA-05"
    verification:
      - kind: test
        ref: "test/data/contato_recebido_model_test.dart#ResumoContatosModel"
        status: pass
    human_judgment: false
  - id: D3
    description: "Toda fixture capturada da caixa (inclusive a da outra empresa e o PATCH) é lida pelos Models"
    requirement: "API-13"
    verification:
      - kind: test
        ref: "test/data/contrato_contatos_test.dart#Models leem toda fixture de contatos"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 05: Models da caixa de contatos Summary

**Quatro Models freezed (item, envelope paginado, resumo e opção de imóvel) leem todo o wire capturado da caixa e o mapeiam para o domínio, com a hora local por `toLocal()` num único ponto e `FormatException` para canal/retorno desconhecido.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2 (TDD: RED e GREEN commitados separados em cada uma)
- **Files:** 14 (13 criados, 1 modificado)

## Accomplishments

- `ContatoRecebidoModel.paraEntidade` é o único lugar com `toLocal()` da caixa; ignora de propósito as chaves de exibição do servidor e as do corretor (D-09, D-10).
- `ContatosEnvelopeModel.paraPagina` guarda só o que chega e mantém `next` opaco (D-08).
- `ResumoContatosModel` e `ImovelComContatoModel` completam a leitura do wire da caixa.
- Grupo "Models leem toda fixture de contatos" em `contrato_contatos_test.dart`: toda fixture de lista (inclusive `contatos_outra_empresa`), o PATCH 200, os dois resumos e as opções são lidos sem erro. Mudança de formato no Django quebra um teste do app.

## Task Commits

1. **Task 1 (RED)** - `26ad1fa` (test)
2. **Task 1 (GREEN)** - `cb324a4` (feat)
3. **Task 2 (RED)** - `82c6210` (test)
4. **Task 2 (GREEN)** - `41fb70c` (feat)

**Plan metadata:** commit `docs(10-05)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test test/data/contato_recebido_model_test.dart test/data/contrato_contatos_test.dart`: 57 verdes.
- Gate da onda 5 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 errors/warnings, 0 infos fora dos 41 `deprecated_member_use` de `material.dart`; `flutter test` inteiro: **1279 verdes** (1258 + 21 novos).
- Greps dos `<automated>`: sem campo de exibição do servidor em `lib`, `toLocal()` e `canalContatoDaApi(` presentes, gerados não vazios e sem diff pendente, `lib/di/injection.config.dart` sem diff.

## Deviations from Plan

**1. [Rule 1 - Bug] Docstring do Model citava os nomes dos campos de exibição**
- **Found during:** Task 1 (gate de grep da verificação)
- **Issue:** o `grep -rqE "(retorno|canal)_exibicao" lib` do `<verify>` casou com o comentário que explicava a omissão, falhando o gate.
- **Fix:** o comentário passou a dizer "campos de exibição do servidor" sem os nomes literais.
- **Files modified:** `lib/data/models/contato_recebido_model.dart`
- **Commit:** incorporado ao `cb324a4` (amend do commit GREEN local, ainda sem push).

**Total deviations:** 1 auto-fixed (Rule 1). **Impact:** nenhum no comportamento.

Detalhe de execução: `dart run build_runner build -d` reescreveu com LF todos os gerados pré-existentes; foram restaurados com `git checkout --` (D-29) e os 12 gerados novos tiveram o CRLF restaurado antes do commit.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None - T-10-12 mitigado (nenhum Model lê campos de exibição nem `corretor_nome`; grep em `lib` vazio); T-10-SC sem pacote novo.

## Next Phase Readiness

Pronto para o 10-06 (data source e repositório da caixa, que usam estes Models e convertem `FormatException` em falha). Nenhum `git push`.

## Self-Check: PASSED

- Os 14 arquivos existem; commits `26ad1fa`, `cb324a4`, `82c6210` e `41fb70c` presentes na `feat/APP10`; `git rev-list --count bfda909..HEAD` = 4.
