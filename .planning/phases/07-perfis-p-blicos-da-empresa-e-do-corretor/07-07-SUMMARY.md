---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 07
subsystem: perfis-mock
tags: [perfil-corretor, mock, fixtures, corretor-desativado, e2e, PERF-05]
status: complete
requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "PerfilMockDataSource, corretoresPerfisFixture, PerfilNaoEncontradoException, AvisoPerfil 'Este corretor não está mais disponível' (07-01, 07-02, 07-04)"
provides:
  - "idCorretorDesativadoMock = 99: corretor reservado, sempre 404 no servidor simulado"
  - "idDetalheCorretorDesativadoMock = 337: imóvel cujo detalhe carrega o corretor 99 (Paulo Teixeira)"
  - "Caminho reproduzível à mão até o aviso de corretor indisponível, provado por e2e"
affects: [07-06, fixtures da Phase 5]
tech-stack:
  added: []
  patterns:
    - "Id reservado com doc no molde de idDetalheDespublicadoMock/idDetalheFalhaMock"
key-files:
  created: []
  modified:
    - lib/data/mocks/perfis_fixture.dart
    - lib/data/datasources/perfil_mock_datasource.dart
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - test/data/perfil_mock_datasource_test.dart
    - test/presentation/detalhe_navegacao_test.dart
key-decisions:
  - "Corretor desativado usa o id reservado 99 via imóvel 337, não o corretor 8 (evita que ~1/3 do acervo abra o aviso)"
  - "O 404 do 99 é forçado no datasource ANTES de consultar o mapa, então nem um mapa de teste contendo o 99 vaza dados"
  - "Edição da fixture do detalhe compartilhada com a Phase 5 limitada a um import com show, uma constante e um ramo na expressão do corretor"
requirements-completed: [PERF-05]
plan_head_before: c18c3ed0e2492b060066dde98cb915c40f6e0fb3
plan_head_after: 7a738057961a38bdbb876ee03c62be52d570a504
commits: 3
actuals:
  tokens: 6000
  tasks: 2
  commits: 3
duration: 15 min
completed: 2026-11-08
---

# Phase 7 Plan 07: Corretor desativado reproduzível à mão Summary

**Corretor reservado 99 sempre "não encontrado" no servidor simulado, carregado pelo imóvel 337 (Paulo Teixeira), com e2e imóvel -> perfil -> aviso -> Voltar.**

## Accomplishments

- `idCorretorDesativadoMock = 99` em `perfis_fixture.dart`, fora de `corretoresPerfisFixture()`; `PerfilMockDataSource.buscarCorretor` lança `PerfilNaoEncontradoException` para ele após a latência, antes da busca no mapa (T-07-22).
- `idDetalheCorretorDesativadoMock = 337` em `imoveis_detalhe_fixture.dart`: o detalhe 337 carrega `{id: 99, nome: 'Paulo Teixeira', foto, slug: null}` (as 4 chaves da allowlist do §11). Demais ids seguem `id % 3` / `camposNulos` sem mudança; corretores 7, 8, 9 e 10 intactos.
- Testes de fixture/mock: 99 fora do acervo, 404 forçado mesmo com o id injetado no mapa, 7 segue devolvendo Marina Lopes, todo corretor dos detalhes (exceto 99) tem perfil, e só o 337 carrega o 99.
- E2E na pilha real (latência simulada): página-base -> `abrirDetalheImovel` com a prévia do 337 -> rola até 'Paulo Teixeira' -> prévia do perfil com spinner -> aviso 'Este corretor não está mais disponível' sem 'Paulo Teixeira' dentro de `PerfilCorretorScreen` -> 'Voltar' devolve o detalhe 337 ainda carregado.

## Task Commits

1. Task 1 RED: `be8c1cd` test(07-07): corretor desativado 99 sempre nao encontrado
2. Task 1 GREEN: `7a254af` feat(07-07): corretor reservado 99 sempre nao encontrado no servidor simulado
3. Task 2: `7a73805` feat(07-07): imovel 337 carrega o corretor desativado 99 (aviso a mao, PERF-05) (testes de coerência e e2e + edição da fixture; os testes foram escritos antes e falhavam na compilação/asserção até a fixture mudar)

## Verification

- `flutter test` completo: 672 testes passam, incluindo `imovel_detalhe_mock_datasource_test.dart`, `contrato_detalhe_test.dart` e o fluxo da Marina.
- `flutter analyze`: No issues found.
- Guarda de edição mínima: `git diff --numstat ba77b1e -- lib/data/mocks/imoveis_detalhe_fixture.dart` = 15 adições / 1 remoção (<= 4).
- Greps de aceitação: `const int idCorretorDesativadoMock = 99;` e uso no datasource presentes; fixture do detalhe contém `idDetalheCorretorDesativadoMock = 337`, `'Paulo Teixeira'` e `show idCorretorDesativadoMock`.

## Deviations from Plan

None - plan executed exactly as written. (Ajuste de teste apenas: no e2e a latência do perfil foi 1 s, não 300 ms, porque a transição de rota de 400 ms consumia a latência antes de a prévia ser observada; é o mesmo padrão do fluxo da Marina.)

**Total deviations:** 0.

## Known Stubs

None. (O corretor 99 é intencionalmente um fixture dev-only do servidor simulado.)

## Threat Flags

None.

## Notes for sibling plans

- 07-06 (vitrine do anunciante) fatia por `corretor.id` nos detalhes: o imóvel 337 deixa a vitrine do corretor 8 e passa ao 99; testes que calculam o esperado das fixtures em runtime não são afetados.
- `.planning/config.json` e `.gsd/dispatch-isolation-sentinel.json` não foram tocados; STATE.md/ROADMAP.md não foram modificados (worktree).

## Self-Check: PASSED

- Arquivos modificados existem; commits `be8c1cd`, `7a254af`, `7a73805` presentes na branch.
