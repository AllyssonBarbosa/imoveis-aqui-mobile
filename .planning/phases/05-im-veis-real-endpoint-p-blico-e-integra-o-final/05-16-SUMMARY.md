---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 16
subsystem: presentation
tags: [detalhe-imovel, corretor, bordas, apifalsa, 404, 500, isclosed]
status: complete

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-14: ImovelDetalheRemoteDataSource, DetalheImovelModel no wire da W09, ApiFalsa servindo o detalhe"
provides:
  - "CorretorResponsavel({required int id, required String nome, String? foto}) sem slug (D-17)"
  - "Testes da ImovelDetalheRemoteDataSource: rota, 404 e corpo nao-objeto"
  - "Testes de navegacao nas bordas do detalhe real: sem corretor, perfil sem rede, sem fotos, 404, 500 e pagina fechada em voo"
affects: [05-17]

plan_head_before: 06148404bd80b5cfca6ef95bfdc3604706351cbe
actuals:
  tokens: 6400    # chars/4 sobre o diff realizado (inclui o .freezed.dart regenerado)
  tasks: 2
  commits: 2      # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Card abaixo da dobra da vitrine: scrollUntilVisible + ensureVisible + pump antes do tap (helper tocarNoCard)"
    - "Teste de 'fechada em voo' com latencia maior que o tempo de fechar a rota, validado por mutacao (sem a guarda isClosed o teste falha)"

key-files:
  created:
    - test/data/imovel_detalhe_remote_datasource_test.dart
  modified:
    - lib/domain/entities/detalhe_imovel.dart
    - lib/domain/entities/detalhe_imovel.freezed.dart
    - lib/data/datasources/imovel_detalhe_datasource.dart
    - lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
    - test/presentation/cartao_corretor_test.dart
    - test/presentation/perfil_corretor_screen_test.dart

key-decisions:
  - "Nenhuma mudanca de codigo de producao alem do slug e das docs: o 05-14 ja entregou o mapeamento null-safe do endereco, o filtro urlHttpOuNula, os estados 404/500 e as guardas isClosed; este plano os prova com testes."

patterns-established:
  - "Borda da API = teste de navegacao sobre a ApiFalsa com fixture capturada (detalhe_sem_corretor, detalhe_sem_fotos, erro_404_detalhe), nunca JSON escrito a mao"

requirements-completed: []

duration: 25min
completed: 2026-11-01
---

# Phase 5 Plan 16: Detalhe real nas bordas e corretor sem slug Summary

**CorretorResponsavel sem slug (a W09 nao o manda) e o detalhe real provado ponta a ponta em corretor ausente, perfil sem rede, sem fotos, 404, 500 e pagina fechada com a requisicao em voo.**

## Performance

- **Tasks:** 2 (1 tracer + 1 auto/tdd)
- **Files modified:** 9 (1 criado)

## Accomplishments

- `CorretorResponsavel` perdeu o `slug`; build_runner regenerado; docs do `ImovelDetalheDataSource` (so o remoto) e do `perfil_corretor_screen.dart` (abre com nome e foto em memoria) atualizadas; os tres testes que passavam `slug:` ajustados.
- Navegacao: imovel 14 (corretor desativado) abre sem a secao "Corretor responsavel"; o perfil do corretor do imovel 21 abre com nome e avatar, sem e-mail, e a `ApiFalsa` nao registra nenhuma requisicao a `/api/publico/corretores/` (D-16, T-05-16-02).
- Novo `imovel_detalhe_remote_datasource_test.dart`: rota `/api/publico/imoveis/<id>/`, 404 como `DioException` e corpo nao-objeto como `FormatException`.
- Navegacao nas bordas: imovel 11 sem fotos mostra `ImagemPadraoImovel` sem contador `N/M` nem `PageView`; 404 mostra "Este imovel nao esta mais disponivel" sem dado velho; 500 (agora com `status: 500` explicito) mostra "Tentar de novo"; pagina fechada em voo nao emite nada e nao lanca.

## Task Commits

1. **Task 1 (tracer): corretor sem slug e pagina sem corretor** - `5705c26` (refactor)
2. **Task 2: bordas do detalhe real** - `1c7e865` (test)

## Files Created/Modified

Ver frontmatter. Nenhum arquivo do repo da API foi tocado; fixtures de `test/fixtures/api/` intactas.

## Verificacao

- `dart run build_runner build --delete-conflicting-outputs`: ok (baseline limpo antes das edicoes; sem SEVERE depois).
- `flutter analyze`: No issues found.
- `flutter test --timeout 60s` (suite completa): 539 testes, All tests passed.
- `grep -w slug` em detalhe_imovel.dart / perfil_corretor_screen.dart / detalhe_imovel_model.dart: vazio. `try {` em `lib/presentation/detalhe_imovel`: vazio.

## Decisions Made

- Nenhuma mudanca de producao na Task 2: os comportamentos do `<behavior>` (endereco nulo, foto `javascript:`, `fotos` vazio, 404/500, guarda `isClosed`) ja estavam implementados pelo 05-14, e os testes de modelo correspondentes ja existiam em `detalhe_imovel_model_test.dart` (linhas "endereco nulo vira bairro vazio e cidade nula", "descarta fotos inseguras", "fotos [] vira lista vazia"). Nao foram duplicados.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug de teste] Teste "fechada em voo" era vacuo na primeira versao**
- **Found during:** Task 2 (mutacao: removi temporariamente `if (isClosed) return;` do cubit)
- **Issue:** com latencia de 1 s a resposta chegava antes de o Cubit ser fechado (a transicao de volta consome ~800 ms), entao o teste passava mesmo sem a guarda.
- **Fix:** latencia de 2 s; reconfirmado por mutacao que sem a guarda o teste falha e com ela passa. Cubit restaurado byte a byte (copia no scratchpad); `git status` sem diff em `detalhe_imovel_cubit.dart`.
- **Files modified:** test/presentation/detalhe_navegacao_test.dart
- **Commit:** 1c7e865

**2. [Rule 3 - Bloqueio] Cards 14 e 11 ficam abaixo da dobra da vitrine**
- **Found during:** Task 1/2
- **Fix:** helper `tocarNoCard` (scrollUntilVisible + ensureVisible + pump + tap) no teste de navegacao.

### Notas de processo

- **TDD (Task 2, tdd="true"):** nao ha fase RED honesta, pois o comportamento ja existia desde o 05-14; os testes entraram como prova do contrato (um deles validado por mutacao, ver acima). Task 2 teve um unico commit `test(...)`.
- **Ledger de commits:** o arquivo `gsd-plan-head-before-05-16` foi gravado logo apos o primeiro commit com `HEAD~1` (0614840, que e o HEAD anterior ao plano), nao antes; o valor medido e o mesmo.

**Total deviations:** 2 auto-fixes de teste. **Impact:** nenhum no escopo.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. Mitigacoes T-05-16-01..04 cobertas: `urlHttpOuNula` (teste do `javascript:` ja existente), perfil sem rede (teste novo), mesma mensagem para todo 404 (teste novo), guarda `isClosed` (teste novo validado por mutacao).

## Issues Encountered

Nenhum alem dos itens em Deviations.

## Self-Check: PASSED

- FOUND: test/data/imovel_detalhe_remote_datasource_test.dart
- FOUND commits 5705c26 e 1c7e865 em feat/APP05
