---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 04
subsystem: domain
tags: [dominio, caixa-contatos, wire, enum, clean-architecture]

requires:
  - phase: 10-03
    provides: "§17 do contrato congelando o wire da caixa de contatos"
provides:
  - "Domínio da caixa sem valor do wire: RetornoContato (com anotaveis), ContatoRecebido, ImovelComContato, PeriodoContatos, ConsultaContatos, PaginaContatos"
  - "Interface CaixaContatosRepository (buscar, seguir, contarSemRetorno, listarImoveis, anotarRetorno) e ContatoNaoEncontradoException"
  - "canalContatoDaApi e retornoContatoDaApi/RetornoContatoNaApi.valorApi em data/models, com FormatException para valor desconhecido"
affects: [10-05, 10-06, 10-07, 10-08, 10-09, 10-10]

commits: 4
plan_head_before: 2933e841711268bb80746ef458f2abc1389073b6
plan_head_after: 57b59d5191de40664b7a8bcf7a8cc6904e7f8ed9

estimate_actuals_note: "tokens = chars/4 sobre o diff do app 2933e84..57b59d5 (23949 chars, inclui os dois arquivos de teste)"
actuals:
  tokens: 5987
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "entidades imutáveis manuais com const/==/hashCode/toString no estilo do acervo"
    - "wire só em data/: extension valorApi + função DaApi com FormatException para desconhecido"

key-files:
  created:
    - lib/domain/entities/retorno_contato.dart
    - lib/domain/entities/contato_recebido.dart
    - lib/domain/entities/imovel_com_contato.dart
    - lib/domain/entities/periodo_contatos.dart
    - lib/domain/entities/consulta_contatos.dart
    - lib/domain/entities/pagina_contatos.dart
    - lib/domain/repositories/caixa_contatos_repository.dart
    - lib/domain/repositories/falhas_caixa_contatos.dart
    - lib/data/models/retorno_contato_api.dart
    - test/domain/entidades_caixa_contatos_test.dart
    - test/data/canal_e_retorno_api_test.dart
  modified:
    - lib/data/models/canal_contato_api.dart

key-decisions:
  - "Canal/retorno desconhecido vira FormatException (padrão finalidade do acervo); o repositório do 10-06 converte em falha"
  - "Nomes com prefixo CaixaContatos* na interface para não colidir com o Contato* da Phase 6"
  - "ContatoRecebido não guarda imovel (id), corretor nem dados do visitante: o app não os usa"

requirements-completed: []

coverage:
  - id: D1
    description: "Domínio da caixa (entidades, consulta combinável, página imutável, interface e falha 404) sem valor do wire"
    requirement: "CXA-01"
    verification:
      - kind: test
        ref: "test/domain/entidades_caixa_contatos_test.dart"
        status: pass
      - kind: command
        ref: "grep dos valores do wire em lib/domain = vazio"
        status: pass
    human_judgment: false
  - id: D2
    description: "Wire de canal e retorno lido e escrito só em data/, ida e volta e FormatException para desconhecido"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/data/canal_e_retorno_api_test.dart"
        status: pass
    human_judgment: false

duration: 5min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 04: Domínio da caixa e wire de canal/retorno Summary

**Domínio da caixa de contatos (RetornoContato com 4 anotáveis, ConsultaContatos com imóvel e período combináveis, PaginaContatos imutável, CaixaContatosRepository e ContatoNaoEncontradoException) mais o mapeamento wire e enum de canal e retorno só em data/, com FormatException para valor desconhecido.**

## Performance

- **Duration:** ~5 min (2026-11-23T22:58:03Z em diante)
- **Tasks:** 2 (TDD: RED e GREEN commitados separados em cada uma)
- **Files:** 12 (11 criados, 1 modificado)

## Accomplishments

- 6 entidades e a interface `CaixaContatosRepository` em `lib/domain/`, sem import de Flutter nem de `data/`; `RetornoContato.anotaveis` é uma lista const sem `pendente` (D-14); `ConsultaContatos.copyWith` tem `limparImovel`/`limparPeriodo` e `temFiltro`.
- `ContatoNaoEncontradoException` (404 do PATCH) no estilo de `falhas_autenticacao.dart`.
- `canalContatoDaApi` e `retornoContatoDaApi` + `RetornoContatoNaApi.valorApi` em `lib/data/models/`; nenhum literal do wire em `lib/domain/`.
- 21 testes de domínio e 7 de wire.

## Task Commits

1. **Task 1 (RED)** - `d7afcd6` (test)
2. **Task 1 (GREEN)** - `15a70a2` (feat)
3. **Task 2 (RED)** - `1f840bb` (test)
4. **Task 2 (GREEN)** - `57b59d5` (feat)

**Plan metadata:** commit `docs(10-04)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test test/domain/entidades_caixa_contatos_test.dart test/data/canal_e_retorno_api_test.dart test/domain/imovel_acervo_test.dart`: verde.
- Gate da onda 4 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 erros/warnings, 0 infos fora dos 41 `deprecated_member_use` de `material.dart`; `flutter test` inteiro: **1258 verdes** (1230 + 28 novos).
- Os greps dos dois `<automated>` das tarefas passaram.

## Deviations from Plan

None - plan executed exactly as written. (Detalhe de execução: `dart format` reformatou 3 arquivos não relacionados de `lib/domain`; foram revertidos com `git checkout --` e não entraram em commit.)

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None - T-10-11 mitigado (FormatException testada para valor desconhecido de canal e retorno); T-10-SC sem pacote novo.

## Next Phase Readiness

Pronto para o 10-05 (Models da caixa, que usam `canalContatoDaApi`/`retornoContatoDaApi`) e para o repositório do 10-06, que converte `FormatException` em falha. Nenhum `git push`.

## Self-Check: PASSED

- Os 11 arquivos criados existem; commits `d7afcd6`, `15a70a2`, `1f840bb` e `57b59d5` presentes na `feat/APP10`; `git rev-list --count 2933e84..HEAD` = 4.
