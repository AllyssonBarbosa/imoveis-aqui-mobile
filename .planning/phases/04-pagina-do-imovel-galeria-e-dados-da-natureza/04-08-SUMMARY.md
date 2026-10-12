---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 08
subsystem: ui
tags: [flutter, material3, presentation, cabecalho, precos, chips, corretor, tdd, dart]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "DetalheImovelScreen com galeria e secoes da natureza (04-03, 04-06, 04-07), DetalheImovel com precoCondominio/precoIptu/caracteristicas/corretor (04-04), ImagemRede compartilhada (04-07), harness e2e detalhe_navegacao_test (04-03)"
provides:
  - "linhasDePrecoPorFinalidade, rotuloLocalizacao e linhasDeCustos: funcoes puras de apresentacao (so formatam, nunca calculam); linhasDePreco(Imovel) delega sem mudar saidas"
  - "Cabecalho da pagina alimentado pelo detalhe no mesmo widget e lugar da previa (sem pulo): titulo, 'bairro · cidade, UF', preco(s) e linhas 'Condominio R$ X/mes' e 'IPTU R$ Y' (IPTU sem periodo)"
  - "SecaoCaracteristicas: um Chip por caracteristica, some quando a lista vem vazia"
  - "AvatarCorretor e CartaoCorretor tocavel; PerfilCorretorScreen + abrirPerfilCorretor (so nome e foto ja em memoria, sem rede e sem contato)"
  - "Ordem final da pagina D-11: cabecalho -> natureza -> descricao -> caracteristicas -> corretor, sem barra inferior fixa"
affects: [fase-05 endpoint real do detalhe, APP 05 mapa/favoritar, APP 06 contato WhatsApp, APP 07 perfil completo do corretor]

actuals:
  tokens: 8064
  tasks: 2
  commits: 4

plan_head_before: 08b5e5ba8f7c75acd890863e3dc65fcb35295ed3

tech-stack:
  added: []
  patterns:
    - "Cabecalho unico (_Cabecalho) recebe strings prontas (titulo, localizacao, linhasPreco, linhasCustos); a origem (previa ou detalhe) e decidida por um switch no ponto de uso, mantendo a posicao fixa (Pitfall 8)"
    - "Funcoes puras de apresentacao compartilhadas entre vitrine e detalhe em apresentacao_imovel.dart; nenhuma aritmetica monetaria"
    - "Gancho de teste construirImagemDeRede repassado ate a folha; @visibleForTesting so nas pontas (telas) para o analyzer ficar limpo (mesma regra do 04-07)"
    - "PerfilCorretorScreen recebe o objeto CorretorResponsavel ja carregado, nunca id/slug (slug PENDENTE E2)"

key-files:
  created:
    - lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart
    - lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
    - test/presentation/cartao_corretor_test.dart
    - test/presentation/perfil_corretor_screen_test.dart
  modified:
    - lib/presentation/vitrine/apresentacao_imovel.dart
    - lib/presentation/detalhe_imovel/widgets/secoes_detalhe.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/apresentacao_imovel_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
    - test/presentation/detalhe_navegacao_test.dart

key-decisions:
  - "IPTU sem sufixo de periodo ('IPTU R$ 1.200') ate o E2 decidir (D-19 c, §11 PENDENTE c); condominio e mensal por natureza e leva '/mes'"
  - "Cabecalho de qualquer natureza, lote inclusive, usa preco_venda/preco_aluguel da parte comum; lote.preco so aparece como 'Preco do lote' na secao da natureza (D-19 d)"
  - "PerfilCorretorScreen abre com o CorretorResponsavel em memoria (nome + foto), sem rede e sem campo de contato (D-15, T-04-08-01); corretor.slug nao entra em nenhuma URL (D-19 a)"
  - "Secao do corretor omitida por inteiro quando corretor == null (D-14)"

patterns-established:
  - "Pure presentation functions first, widgets consume ready strings"
  - "Telas nao-testaveis por plugin recebem o gancho de imagem so na ponta"

requirements-completed: [DET-03, DET-05]

coverage:
  - id: D1
    description: "Cabecalho alimentado pelo detalhe no mesmo lugar da previa, com preco(s) de venda/aluguel, 'Condominio R$ X/mes' e 'IPTU R$ Y' exatamente como vieram da API (so formatados), linha ausente omitida"
    requirement: DET-03
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_imovel_test.dart#linhasDeCustos / linhasDePrecoPorFinalidade / rotuloLocalizacao"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#cabeçalho do detalhe, preços e características (DET-03, D-11)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Caracteristicas como chips apos a descricao, secao some quando vazia; ordem natureza < Descricao < Caracteristicas"
    requirement: DET-05
    verification:
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#ordem vertical: natureza < Descrição < Características"
        status: pass
    human_judgment: false
  - id: D3
    description: "Corretor responsavel com foto (ou avatar padrao) e nome num cartao tocavel que abre a tela de perfil com nome e foto do detalhe; sem corretor a secao some; perfil sem nenhum dado de contato"
    requirement: DET-05
    verification:
      - kind: unit
        ref: "test/presentation/cartao_corretor_test.dart"
        status: pass
      - kind: unit
        ref: "test/presentation/perfil_corretor_screen_test.dart#não mostra nenhum dado de contato (T-04-08-01)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#corretor responsável (DET-05, D-15)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Fluxo de ponta a ponta sobre o mock: vitrine -> detalhe completo -> perfil do corretor -> volta ao detalhe -> volta a vitrine intacta, sem barra inferior fixa"
    requirement: DET-05
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo (DET-01..05, D-12, D-15)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Fidelidade visual Material 3 verde/branco, escolha de icones e rotulos, latencia percebida de abertura e layout em 360 dp (sem UI-SPEC, D-20)"
    verification: []
    human_judgment: true
    rationale: "Sem UI-SPEC para a fase (D-20); so o usuario confirma icones/rotulos, a percepcao de latencia e o layout em aparelho real. Checklist completo no <human-check> da Task 2 do plano."

duration: 5min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 08: Cabecalho completo, caracteristicas e corretor Summary

**Cabecalho do detalhe alimentado pelo proprio detalhe sem pulo (preco venda/aluguel, 'Condominio R$ X/mes', 'IPTU R$ Y' so formatados), caracteristicas em chips, e corretor responsavel num cartao tocavel que abre uma tela de perfil com nome e foto, sem rede nem contato**

## Performance

- **Duration:** 5 min
- **Started:** 2026-10-12T14:40:02Z
- **Completed:** 2026-10-12T14:45:00Z
- **Tasks:** 2
- **Files modified:** 10 (4 criados, 6 alterados)

## Accomplishments

- `apresentacao_imovel.dart` ganhou `linhasDePrecoPorFinalidade` (regras antigas extraidas; `linhasDePreco(Imovel)` delega com saidas identicas), `rotuloLocalizacao` e `linhasDeCustos`. Tudo so formata via `formatarPrecoBrl`: nenhuma soma nem conversao de periodo.
- O `_Cabecalho` da pagina agora recebe strings prontas e e alimentado pela previa enquanto carrega e pelo detalhe depois, no mesmo widget e na mesma posicao (teste compara a posicao do titulo e do preco entre `carregando` e `carregado`). Condominio e IPTU aparecem abaixo dos precos; IPTU nunca leva '/mes' nem '/ano'.
- `SecaoCaracteristicas` (um `Chip` por item, some quando vazia) apos a descricao; ordem D-11 provada por teste: natureza < Descricao < Caracteristicas < Corretor responsavel.
- `AvatarCorretor`, `CartaoCorretor` (Card.outlined + InkWell, `Semantics` 'Ver perfil de <nome>') e `PerfilCorretorScreen`/`abrirPerfilCorretor` (so nome e foto ja em memoria, AppBar 'Corretor'); teste varre todos os `Text` e garante que nao ha '@', WhatsApp, telefone, CRECI nem e-mail.
- E2E sobre a pilha real do mock: vitrine -> card 42 -> detalhe completo (R$ 450.000, Condominio R$ 850/mes, IPTU R$ 1.200, 3 chips) -> rola ate 'Marina Lopes' -> perfil -> volta ao detalhe -> volta a vitrine com o card 42, sem barra inferior.
- Gates da fase: `flutter analyze` sem issues; `flutter test` com 587 testes passando; todos os gates de grep passaram (nenhum acesso da apresentacao/dominio ao mock, `getIt<` uma unica vez no detalhe, sem barra inferior fixa, sem pacote de rotas/galeria no pubspec, sem `try {` na UI, zero campos de contato no perfil).

## Task Commits

Plano executado em TDD (RED -> GREEN por tarefa):

1. **Task 1 RED:** `235ddc3` (test) - testes que falham para custos, localizacao, cabecalho sem pulo e chips
2. **Task 1 GREEN:** `a1b01fc` (feat) - funcoes de apresentacao, cabecalho alimentado pelo detalhe e `SecaoCaracteristicas`
3. **Task 2 RED:** `f459df9` (test) - testes que falham para cartao do corretor, perfil e fluxo completo
4. **Task 2 GREEN:** `40a9926` (feat) - `AvatarCorretor`, `CartaoCorretor`, `PerfilCorretorScreen` e secao do corretor na pagina

**Plan metadata:** commit `docs(04-08)` deste SUMMARY, seguido do commit de STATE/ROADMAP/REQUIREMENTS.

## Files Created/Modified

- `lib/presentation/vitrine/apresentacao_imovel.dart` - `linhasDePrecoPorFinalidade`, `rotuloLocalizacao`, `linhasDeCustos`
- `lib/presentation/detalhe_imovel/widgets/secoes_detalhe.dart` - `SecaoCaracteristicas` (chips)
- `lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart` - `AvatarCorretor` e `CartaoCorretor` (novo)
- `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` - `abrirPerfilCorretor` e `PerfilCorretorScreen` (novo)
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` - `_Cabecalho` generico, alimentado por previa ou detalhe; secoes caracteristicas e corretor
- `test/presentation/cartao_corretor_test.dart`, `test/presentation/perfil_corretor_screen_test.dart` - novos
- `test/presentation/apresentacao_imovel_test.dart`, `detalhe_imovel_screen_test.dart`, `detalhe_navegacao_test.dart` - estendidos

## Decisions Made

- IPTU sem periodo ate o E2 decidir (D-19 c); condominio '/mes' por ser mensal por natureza.
- Cabecalho usa `preco_venda`/`preco_aluguel` da parte comum para todas as naturezas, lote incluido; `lote.preco` so na linha 'Preco do lote' da natureza (D-19 d), coberto por teste.
- Perfil do corretor abre com o objeto em memoria, nunca com id/slug (D-15, D-19 a); corretor sem foto e sem slug abre igual (teste).
- Gancho `construirImagemDeRede` mantido com `@visibleForTesting` apenas nas telas (`DetalheImovelScreen`, `PerfilCorretorScreen`); `AvatarCorretor`/`CartaoCorretor` so repassam, como no 04-07.

## TDD Gate Compliance

Gates RED e GREEN presentes nas duas tarefas (`test(04-08)` antes de cada `feat(04-08)`). Como no 04-07, o plano e `type: execute`, entao os registros formais de `check tdd-red-evidence` nao foram gerados. Os commits RED incluem esqueletos que apenas compilam (funcoes retornando listas vazias / `SizedBox.shrink` / `Scaffold` vazio) para que os testes falhem em asserções do comportamento planejado (lookups de texto/icone/chave sem resultado, `Expected: <1> Actual: <0>`), e nao por erro de compilacao. Alguns testes de guarda (ex.: 'características vazias fazem a seção sumir', 'sem corretor a seção some') ja passavam no RED por natureza: protegem regressao, nao comportamento novo.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] @visibleForTesting em AvatarCorretor/CartaoCorretor gerava warnings do analyzer**
- **Found during:** Task 2 (GREEN)
- **Issue:** seguindo o contrato do plano (`@visibleForTesting construirImagemDeRede` em `AvatarCorretor` e `CartaoCorretor`), `flutter analyze` reportou 2 `invalid_use_of_visible_for_testing_member` ao repassar o gancho da tela para o cartao e de `PerfilCorretorScreen` para o avatar; o criterio de sucesso exige analyzer limpo.
- **Fix:** anotacao mantida apenas nas pontas (`DetalheImovelScreen`, `PerfilCorretorScreen`) e removida de `AvatarCorretor`/`CartaoCorretor`, com comentario — mesma solucao ja adotada no 04-07.
- **Files modified:** lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart
- **Verification:** `flutter analyze` sem issues; testes verdes.
- **Committed in:** 40a9926 (commit da Task 2 GREEN)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Nenhum aumento de escopo; as assinaturas publicas listadas em "Artifacts" continuam validas, so sem a anotacao nos intermediarios.

## Issues Encountered

- Disco com 3,5 GiB livres (acima do minimo de 2 GiB da precondicao); nenhuma falha de espaco durante `flutter test`.

## Known Stubs

Nenhum. Os esqueletos dos commits RED foram todos substituidos pela implementacao real nos commits GREEN. A tela de perfil e propositalmente enxuta (so nome e foto): o perfil completo e o APP 07 e o contato e o APP 06 (documentado no doc comment e nos Flagged assumptions do plano), nao um stub escondido.

## Threat Flags

Nenhuma superficie nova alem do modelo de ameacas do plano. Mitigacoes aplicadas: T-04-08-01 (perfil so com nome e foto, teste varre os `Text` por e-mail/telefone/WhatsApp/CRECI), T-04-08-02 (so `formatarPrecoBrl`, testes fixam as strings exatas), T-04-08-03 (foto ja filtrada http/https na camada de dados; `ImagemRede` cai no avatar padrao em erro), T-04-08-SC (gate de pubspec sem pacote de rotas/galeria passou). T-04-08-04 (exposicao publica do corretor, LGPD) segue transferido para o E2 (§11 item g).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Fase 4 sem planos pendentes; resta o `/gsd-verify-work` da fase.
- **Human-check de fim de fase PENDENTE** (nao executado por este agente; exige emulador/simulador): roteiro completo no `<human-check>` da Task 2 do `04-08-PLAN.md` e o pendente do 04-07 (pinch real, arrasto da foto ampliada, legibilidade do botao voltar sobre fotos claras/escuras nos imoveis 103 e 104). Pontos a confirmar pelo usuario: abertura sem pulo do cabecalho no card 42, ordem das secoes, perfil do corretor (nome + avatar apenas) e volta a vitrine na mesma posicao, casos 57/103/109/63, erro e 404 em Vinhedo, filtros intactos ao voltar, icones e rotulos em portugues, 'IPTU' sem '/mes' nem '/ano', layout em 360 dp.
- Riscos abertos herdados: arbitragem real de gestos zoom x swipe (A1, 04-07) so se confirma em aparelho; E2 decide periodo do IPTU, `slug` do corretor, `lote.preco` vs `preco_venda` e a exposicao LGPD do corretor.

## Self-Check: PASSED

- Arquivos criados presentes: cartao_corretor.dart, perfil_corretor_screen.dart, cartao_corretor_test.dart, perfil_corretor_screen_test.dart.
- Commits 235ddc3, a1b01fc, f459df9 e 40a9926 existem na branch feat/APP04 (`git rev-list --count` desde o ledger = 4).
- `flutter analyze`: sem issues. `flutter test`: 587 testes passando. Todos os gates de grep do plano passaram.

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
