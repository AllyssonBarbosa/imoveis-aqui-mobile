---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 11
subsystem: presentation/perfis
tags: [flutter, cubit, perfil-empresa, navegacao, e2e]
status: complete
requires:
  - phase: 07-09
    provides: buscarEmpresa (PerfilDataSource/mock/remote/PerfilRepository), empresasPerfisFixture
  - phase: 07-10
    provides: CorpoPerfilComVitrine, abrirPerfilCorretor com MultiBlocProvider
provides:
  - ObterPerfilEmpresaUseCase e PerfilEmpresaCubit (carregar, tentarNovamente, 404 por tipo)
  - abrirPerfilEmpresa (unico ponto do DI da empresa) e PerfilEmpresaScreen (logomarca, nome, tipo, CRECI)
  - CartaoEmpresa 'Ver página do anunciante' no perfil do corretor, depois do contato
  - rotuloTipoEmpresa (so na pagina da empresa)
affects: [07-12 desfechos, apresentacao, contato, cidades e vitrine da empresa]
tech-stack:
  added: []
  patterns:
    - Cubit da empresa como copia do Cubit do corretor sobre PerfilState<T> generico
    - rotulo neutro unico no cartao do corretor; tipo so onde a API da empresa o informa
key-files:
  created:
    - lib/domain/usecases/obter_perfil_empresa_usecase.dart
    - lib/presentation/perfis/perfil_empresa_cubit.dart
    - lib/presentation/perfis/perfil_empresa_screen.dart
    - lib/presentation/perfis/widgets/cartao_empresa.dart
    - test/presentation/perfil_empresa_screen_test.dart
  modified:
    - lib/presentation/perfis/apresentacao_perfil.dart
    - lib/presentation/perfis/perfil_corretor_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/di/injection_perfis_test.dart
key-decisions:
  - "Cartao do corretor com rotulo unico 'Ver página do anunciante': o perfil do corretor so tem empresa_id, entao 'Imobiliária'/'Corretor autônomo' aparece apenas na pagina da empresa (rotuloTipoEmpresa)"
  - "getIt so em abrirPerfilCorretor e abrirPerfilEmpresa (guarda de contagem: 1 uso em perfil_empresa_screen.dart)"
  - "Pagina da empresa sem previa: spinner centrado ate a API responder, pois so o id e conhecido"
requirements-completed: [PERF-01, PERF-06, PERF-04]
plan_head_before: ea3612e4a5b2f27c554996041f32d90980890444
plan_head_after: 3bdefcff2524ded583069f3f36bbfb1c6f739b9f
commits: 2
actuals:
  tokens: 16000
  tasks: 2
  commits: 2
coverage:
  - deliverable: "Do perfil do corretor (Marina) o cartao 'Ver página do anunciante' abre a pagina da empresa com spinner e depois Imobiliária Jequitibá, Imobiliária e CRECI J-1234; voltar devolve o perfil carregado"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo (vitrine -> ... -> pagina da Imobiliária Jequitibá)", status: pass}
    human_judgment: false
  - deliverable: "Cabecalho da empresa para imobiliaria (logomarca, nome headlineSmall, tipo, CRECI) e autonomo (Corretor autônomo, icone de predio, sem CRECI); 404 e falha; abrir/voltar"
    verification:
      - {kind: test, ref: "test/presentation/perfil_empresa_screen_test.dart", status: pass}
    human_judgment: false
  - deliverable: "PerfilEmpresaCubit e ObterPerfilEmpresaUseCase resolvem no DI de producao; guardas de getIt e de camada"
    verification:
      - {kind: test, ref: "test/di/injection_perfis_test.dart", status: pass}
    human_judgment: false
  - deliverable: "Rotulo neutro do cartao e adequacao visual do cartao depois do contato"
    human_judgment: true
    rationale: "Assuncao A7 da pesquisa: confirmar no human-check do 07-12 que 'Ver página do anunciante' atende o visitante"
---

# Phase 7 Plan 11: Pagina da empresa alcancada pelo perfil do corretor Summary

**Do perfil do corretor, o cartao 'Ver página do anunciante' abre a pagina da empresa (Navigator.push, Cubit resolvido no DI so no toque) com logomarca, nome, tipo e CRECI vindos da API de perfis, provado por e2e com a pilha real Cubit -> use case -> repositorio -> mock.**

## Accomplishments

- `ObterPerfilEmpresaUseCase` (so delega a `buscarEmpresa`) e `PerfilEmpresaCubit` (`PerfilState<PerfilEmpresa>`, guardas de `tentarNovamente`, 404 decidido por `PerfilNaoEncontradoException`, `isClosed` antes de cada `emit`).
- `abrirPerfilEmpresa` + `PerfilEmpresaScreen` ('Anunciante'): spinner enquanto carrega (sem previa), `_CabecalhoEmpresa` (logomarca 96 com placeholder `apartment_outlined`, nome em `headlineSmall`, tipo em `labelLarge`/primary, 'CRECI ...'), 404 ('Esta página não está mais disponível') e falha ('Tentar de novo') reaproveitando `AvisoPerfil`/`ErroPerfil`; switch exaustivo sem `default`.
- `CartaoEmpresa` no molde do `CartaoCorretor` e `AoAbrirEmpresa` injetavel em `abrirPerfilCorretor`/`PerfilCorretorScreen`; ordem D-08: cabecalho, apresentacao, contato, cartao, vitrine. Aparece so quando `empresaId` existe.
- `rotuloTipoEmpresa` em `apresentacao_perfil.dart` (usado so na pagina da empresa).
- Testes: e2e Marina -> empresa 3 -> volta; 7 testes de tela com MockCubit (entidades montadas no teste); 2 canarios de DI. Suite completa: 771 testes verdes; `flutter analyze` limpo; guardas de `getIt` (1 uso na tela da empresa), de camada e de cor passam.

## Task Commits

1. Task 1: `720d0a3` feat(07-11) pagina da empresa alcancada pelo cartao no perfil do corretor
2. Task 2: `3bdefcf` test(07-11) cabecalho da empresa (imobiliaria e autonomo) e DI de producao

## Deviations from Plan

None - plan executed exactly as written, with two small execution notes (no behavior change):

- O cartao fica em `Padding(fromLTRB(16, 24, 16, 0))` em vez de so `top: 24`, para alinhar ao respiro horizontal de 16 que as secoes do perfil ja tem (`SecaoDetalhe`).
- No e2e, a transicao de 400 ms cobre a latencia de 300 ms da empresa; o spinner e verificado no primeiro frame depois do toque e o conteudo depois de 400 ms.

O `build_runner` reescreveu varios `*.freezed.dart`/`*.g.dart` so com diferenca de fim de linha (CRLF); foram restaurados com `git checkout` e apenas `lib/di/injection.config.dart` foi commitado.

## Known Stubs

None. `CorpoPerfilComVitrine` na pagina da empresa recebe `vitrine: null` de proposito: a vitrine, as cidades de atuacao, a apresentacao e o contato da empresa entram no 07-12.

## Threat Flags

None. Mitigacoes T-07-30 (getIt so nos dois `abrir*`, guarda de contagem) e T-07-31 (rotulo neutro no cartao; tipo so na pagina da empresa) aplicadas e cobertas por teste/guarda.

## Self-Check: PASSED

- Arquivos criados existem em disco (use case, cubit, screen, cartao, teste da tela).
- Commits `720d0a3` e `3bdefcf` presentes no historico do worktree.
