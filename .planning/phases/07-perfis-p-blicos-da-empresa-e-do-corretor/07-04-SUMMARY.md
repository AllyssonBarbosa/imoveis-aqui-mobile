---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 04
subsystem: ui
tags: [flutter, cubit, freezed, perfil-corretor, material3]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "07-01 dominio/dados do perfil, 07-02 PerfilCorretorScreen/Cubit/abrirPerfilCorretor"
provides:
  - "PerfilState.naoEncontrado (404) separado de erro"
  - "PerfilCorretorCubit.tentarNovamente com id guardado e guardas de concorrencia"
  - "AvisoPerfil e ErroPerfil compartilhados com o perfil da empresa"
  - "LinhaContato/linhasDeContato, SecaoApresentacao e SecaoContato"
affects: [07-05, 07-07, 07-08, 07-11]

commits: 2
plan_head_before: 7455cb930434d0b9ffdcfaadf99b89bd65c8ed0d
plan_head_after: 0b03215723f5cb41fb5359d2ec2a010eb8549ad9

actuals:
  tokens: 14000
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "404 de dominio (PerfilNaoEncontradoException) decide o estado naoEncontrado, nunca mensagem/status"
    - "Funcoes puras de apresentacao em lib/presentation/perfis/apresentacao_perfil.dart"

key-files:
  created:
    - lib/presentation/perfis/widgets/aviso_perfil.dart
    - lib/presentation/perfis/widgets/secoes_perfil.dart
    - lib/presentation/perfis/apresentacao_perfil.dart
    - test/presentation/perfil_corretor_cubit_test.dart
    - test/presentation/apresentacao_perfil_test.dart
  modified:
    - lib/presentation/perfis/perfil_state.dart
    - lib/presentation/perfis/perfil_state.freezed.dart
    - lib/presentation/perfis/perfil_corretor_cubit.dart
    - lib/presentation/perfis/perfil_corretor_screen.dart
    - test/presentation/perfil_corretor_screen_test.dart

key-decisions:
  - "Contato do perfil e so SelectableText com icone; nenhuma acao (ligar/WhatsApp/e-mail e do APP 06)"
  - "404 renderiza apenas AvisoPerfil, sem a previa (nome/foto) do corretor"

requirements-completed: [PERF-02, PERF-05]

duration: 25min
completed: 2026-11-08
status: complete
---

# Phase 07 Plan 04: Apresentacao, contato e desfechos de erro do corretor Summary

**Pagina do corretor com Apresentacao e Contato como texto selecionavel, 404 como aviso "Este corretor nao esta mais disponivel" sem previa, e "Tentar de novo" nas demais falhas.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2
- **Files modified:** 10 (5 criados, 5 alterados)

## Accomplishments
- `PerfilState.naoEncontrado()` distinto de `erro()`; o Cubit decide pelo tipo `PerfilNaoEncontradoException`.
- `tentarNovamente()` guarda o id (carry-over do 07-02), ignora chamadas com Cubit fechado, durante `carregando` e em `naoEncontrado`; toque duplo faz uma unica busca.
- `AvisoPerfil` (icone + mensagem + "Voltar" via `Navigator.maybePop`) e `ErroPerfil` (mensagem + "Tentar de novo"), prontos para a empresa.
- Pagina carregada: cabecalho -> Apresentacao -> Contato (telefone, WhatsApp, e-mail); campos nulos omitem a linha e secoes vazias somem.

## Task Commits

1. **Task 1: 404 com estado e aviso proprios + Tentar de novo** - `2f3a79b` (feat)
2. **Task 2: Apresentacao e contato como texto selecionavel** - `0b03215` (feat)

## Decisions Made
- Sem `Padding` horizontal extra em volta das secoes: `SecaoDetalhe` ja aplica 16 px horizontais, e somar mais 16 dobraria o recuo (ver desvio).

## Deviations from Plan

**1. [Rule 1 - Bug evitado] Sem padding horizontal de 16 na Column das secoes**
- **Found during:** Task 2
- **Issue:** O plano pedia padding horizontal 16 no `SliverToBoxAdapter` das secoes, mas `SecaoDetalhe` ja inclui `fromLTRB(16, 24, 16, 0)`; os dois somados dariam 32 px de recuo, inconsistente com a pagina do imovel.
- **Fix:** `Column` sem padding externo.
- **Files modified:** lib/presentation/perfis/perfil_corretor_screen.dart
- **Committed in:** 0b03215

**2. [Processo] TDD sem commit RED separado** — testes e implementacao foram escritos juntos e commitados por tarefa (os testes de Cubit nem compilam sem a variante nova).

**Total deviations:** 1 ajuste visual + 1 de processo. Sem mudanca de escopo.

## Issues Encountered
- `build_runner` regenerou ~20 arquivos `.freezed.dart`/`.g.dart`/`injection.config.dart` com diferenca apenas de fim de linha; foram restaurados com `git checkout` e so `perfil_state.freezed.dart` foi commitado. `injection.config.dart` nao foi tocado.

## Verification
- `flutter test` completo: 631 testes passando.
- `flutter analyze`: sem problemas.
- Guardas: sem `try {` em `lib/presentation/perfis`, sem `url_launcher|launchUrl|tel:|mailto:|wa.me` em `lib`/`pubspec.yaml`, sem `Color(0x`/`Colors.` em `perfis`, 0 `InkWell|onTap` em `secoes_perfil.dart`, 0 `default:` na tela.

## Known Stubs
Nenhum.

## Threat Flags
Nenhum (mitigacoes T-07-07, T-07-08 e T-07-11 aplicadas e cobertas por teste/guarda).

## Next Phase Readiness
- `AvisoPerfil`/`ErroPerfil` prontos para o perfil da empresa (07-05+); o e2e do corretor desativado (corretor 99 via imovel 337) fica para o 07-07. Icones e rotulos seguem para o human-check do fim da fase (D-16).

## Self-Check: PASSED
Arquivos criados e commits `2f3a79b`, `0b03215` conferidos no historico.
