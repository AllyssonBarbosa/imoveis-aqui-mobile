---
phase: 08
fixed_at: 2026-11-21T00:00:00Z
review_path: .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-REVIEW.md
iteration: 1
findings_in_scope: 3
fixed: 3
skipped: 0
status: all_fixed
---

# Phase 08: Code Review Fix Report

**Fixed at:** 2026-11-21
**Source review:** .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 3 (escopo restrito pelo orquestrador: WR-01, WR-02, WR-03 do app Flutter)
- Fixed: 3
- Skipped: 0

WR-04..WR-07 e os IN-xx ficaram fora do escopo e continuam no REVIEW.md. O repositório web não foi tocado.

## Fixed Issues

### WR-01: "Sair" e "sessão expirada" usam `isFirst` e levam ao priming no primeiro uso

**Files modified:** `lib/presentation/sessao/rota_vitrine.dart` (novo), `lib/presentation/sessao/dialogo_sair.dart`, `lib/presentation/acervo/acervo_screen.dart`, `lib/presentation/priming/priming_screen.dart`, `test/presentation/acervo_screen_test.dart`, `test/presentation/priming_screen_test.dart`
**Commit:** a378670
**Applied fix:** A rota que o `PrimingScreen` empurra (a vitrine) agora tem `RouteSettings(name: 'vitrine')`. `confirmarESair` e o 401 do acervo usam o predicado `eRotaDaVitrine` (rota nomeada ou, quando já há cidade salva e a vitrine é a `home`, a primeira rota). `EntradaAreaScreen` usa `pushReplacement` e não dependia de `isFirst`, então não mudou. Testes novos: pilha `[Priming, Vitrine, Acervo]` para Sair e para o 401, e a rota empurrada pelo CTA do priming é a nomeada. Status: fixed: requires human verification (lógica de navegação, coberta por testes de widget mas não exercitada em aparelho).

### WR-02: "Sair" pode ficar até 10 s sem feedback

**Files modified:** `lib/data/repositories/autenticacao_repository_impl.dart`, `lib/data/datasources/autenticacao_remote_datasource.dart`, `test/data/autenticacao_repository_impl_test.dart`
**Commit:** 1e59281
**Applied fix:** `AutenticacaoRepositoryImpl.sair` aplica `.timeout(esperaMaximaSair)` (5 s, constante pública) na chamada do datasource; `TimeoutException` já é `Exception` e cai no `catch` de melhor esforço, então o `finally` sempre apaga o token local e `sair()` continua sem lançar. O comentário do datasource foi corrigido para dizer que os `Options` cobrem só enviar/receber e onde o limite total é imposto. Teste novo com `fakeAsync`: pedido que nunca termina completa em exatamente 5 s e o token é apagado. Status: fixed: requires human verification (comportamento de tempo; o `connectTimeout` real do Dio não foi exercitado contra uma rede, apenas simulado).

### WR-03: A salvaguarda T-08-49 não existe no código

**Files modified:** `lib/domain/usecases/descartar_sessao_usecase.dart` (novo), `lib/presentation/sessao/sessao_cubit.dart`, `lib/presentation/acervo/acervo_screen.dart`, `lib/presentation/sessao/entrada_area_screen.dart`, `lib/data/network/interceptador_sessao.dart`, `lib/di/injection.config.dart` (regenerado), `test/presentation/sessao_cubit_test.dart`, `test/presentation/acervo_screen_test.dart`, `test/presentation/entrada_area_screen_test.dart`
**Commit:** 2c4587b
**Applied fix:** Optou-se por implementar a salvaguarda (em vez de só corrigir o comentário), pois só a implementação remove o ciclo descrito. Novo `DescartarSessaoUseCase` (chama `descartarSessaoLocal()`, que não lança por contrato) e `SessaoCubit.encerrarPorExpiracao()` (descarta o token local e termina anônimo, com `finally`). O acervo (401 na lista) e a entrada (`EntradaAreaSessaoExpirada`) chamam `encerrarPorExpiracao()` e só então navegam ao login. O comentário do interceptor agora descreve esse caminho real. `injection.config.dart` regenerado via `build_runner`; os `*.freezed.dart`/`*.g.dart` que diferiam só por CRLF foram restaurados com `git checkout --`. Testes novos: cubit (descarta e emite anônima; pilha real com `apagar()` lançando `PlatformException`) e as telas passam a verificar `encerrarPorExpiracao`. Status: fixed: requires human verification (muda o fluxo de sessão expirada; navegação agora ocorre após um `await` local curto).

## Verification

Executada no checkout principal (`workflow.use_worktrees=false`; sem worktree isolado), então os números são reproduzíveis a partir da árvore atual.

- `flutter test` completo: 1065 testes passando (linha de base 1059; +6 testes novos).
- `flutter analyze lib`: 38 issues, todos `info` `deprecated_member_use` (igual à linha de base; nenhum tipo novo).
- `dart format` aplicado apenas nos arquivos alterados (o formatador também reformatou trechos antigos de `test/presentation/priming_screen_test.dart`).

---

_Fixed: 2026-11-21_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
