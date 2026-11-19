---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 21
subsystem: api
tags: [django, drf, throttling, rate-limit, dos, anon-throttle]
gap_closure: true

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-20: teto de 20 ids e subconsulta única no filtro de características; suíte de 347 testes"
provides:
  - "ThrottleVitrinePublica(AnonRateThrottle), scope vitrine_publica, em core/throttles.py"
  - "DEFAULT_THROTTLE_RATES vitrine_publica (VITRINE_TAXA_ANONIMA, padrão 120/min) e NUM_PROXIES (padrão 0) no settings"
  - "throttle_classes = [ThrottleVitrinePublica] nas 5 views públicas que o app consome (balde único por IP, 429 + Retry-After)"
  - "6 testes novos em VitrineLimiteDeTaxaTests; cache.clear() em 3 setUp para a suíte não ficar instável"
affects: [05-22]

plan_head_before: 0592176
actuals:
  tokens: 5200
  tasks: 2
  commits: 0

tech-stack:
  added: []
  patterns:
    - "Throttle escopado view a view (nunca DEFAULT_THROTTLE_CLASSES global) para não limitar a API autenticada"
    - "Teste de taxa com mock.patch.object(Classe, 'rate', 'N/min', create=True), pois DEFAULT_THROTTLE_RATES do DRF é ligado na importação e override_settings não o alcança"
    - "cache.clear() no início do setUp de toda base de teste que chama rota pública"

key-files:
  created:
    - ../imoveis-aqui/Web/core/throttles.py
  modified:
    - ../imoveis-aqui/Web/config/settings.py
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/localizacao/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py
    - ../imoveis-aqui/Web/empresas/tests.py
    - ../imoveis-aqui/Web/.env.example

key-decisions:
  - "Balde único (scope vitrine_publica) para as 5 rotas: a cota é por IP, não por rota"
  - "NUM_PROXIES = 0 por padrão: o DRF usa REMOTE_ADDR e ignora o X-Forwarded-For forjável"
  - "Sem DEFAULT_THROTTLE_CLASSES: a API autenticada do painel nunca é limitada"

patterns-established:
  - "Rotas públicas novas da vitrine devem declarar throttle_classes = [ThrottleVitrinePublica]"

requirements-completed: [API-03, API-07]

coverage:
  - id: D1
    description: "Visitante anônimo que passa da taxa na lista da vitrine recebe 429 com Retry-After e corpo {detail} (WR-02)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_visitante_anonimo_passa_do_limite_e_recebe_429"
        status: pass
    human_judgment: false
  - id: D2
    description: "Taxa padrão vem de DEFAULT_THROTTLE_RATES['vitrine_publica'] (VITRINE_TAXA_ANONIMA, padrão 120/min), ajustável sem código"
    requirement: API-07
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_taxa_padrao_vem_do_settings"
        status: pass
    human_judgment: false
  - id: D3
    description: "As cinco rotas públicas (cidades, imóveis da cidade, bairros, características, detalhe) têm o throttle e dividem um só balde por IP"
    requirement: API-07
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_todas_as_rotas_publicas_da_vitrine_tem_o_limite"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_as_rotas_publicas_dividem_o_mesmo_balde"
        status: pass
    human_judgment: false
  - id: D4
    description: "X-Forwarded-For forjado não reinicia a contagem (NUM_PROXIES = 0)"
    requirement: API-07
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_x_forwarded_for_forjado_nao_reinicia_a_contagem"
        status: pass
    human_judgment: false
  - id: D5
    description: "API autenticada do painel não é limitada (sem lista global de throttles); suíte inteira estável em duas rodadas seguidas"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLimiteDeTaxaTests.test_api_autenticada_do_painel_nao_tem_limite"
        status: pass
      - kind: integration
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput (2x, 353 testes OK)"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-11-16
status: complete
---

# Phase 5 Plan 21: Limite de taxa anônimo nas rotas públicas da vitrine (WR-02) Summary

**As cinco rotas públicas sem token que o app consome ganham `ThrottleVitrinePublica` (balde único por IP, 120/min por padrão via `VITRINE_TAXA_ANONIMA`, `NUM_PROXIES = 0` contra X-Forwarded-For forjado): passou da taxa vira 429 com `Retry-After`; a API autenticada do painel segue sem limite e a suíte fica estável.**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-11-16
- **Tasks:** 2 (tracer + auto, ambas TDD)
- **Files modified:** 7 (6 modificados + 1 novo, todos no repo da API, sem commit)

## Accomplishments

- **WR-02 fechado.** `core/throttles.py` define `ThrottleVitrinePublica(AnonRateThrottle)` com `scope = "vitrine_publica"`. `throttle_classes = [ThrottleVitrinePublica]` entra em `VitrineCidadeAPIView`, `BairrosDaCidadeAPIView`, `CaracteristicasPublicasAPIView`, `ImovelVitrineDetalheAPIView` (4 ocorrências em `imoveis/api/views.py`) e `CidadeAtendidaAPIView` (1 em `localizacao/api/views.py`). `permission_classes = [AllowAny]` e `authentication_classes = []` ficam como estavam (D-08).
- **Taxa configurável.** `REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {'vitrine_publica': env('VITRINE_TAXA_ANONIMA', default='120/min')}` e `'NUM_PROXIES': env.int('NUM_PROXIES', default=0)`. `.env.example` ganhou `VITRINE_TAXA_ANONIMA=120/min` e `NUM_PROXIES=0` com comentários em português. `Web/.env` não foi lido nem editado.
- **API autenticada intocada.** Não há `DEFAULT_THROTTLE_CLASSES` (`api_settings.DEFAULT_THROTTLE_CLASSES == []`, checado por teste e por script); o teste com corretor autenticado faz 3 GET em `imovel-list` com taxa de "1/min" e recebe 200 nas três.
- **Suíte estável.** `cache.clear()` na primeira linha de `VitrineBase.setUp`, `VitrinePublicaTests.setUp` e `SemearVitrineDevTests.setUp`. Suíte inteira rodada duas vezes seguidas: **353 testes OK nas duas rodadas** (347 do fim do 05-20 + 6 novos). `makemigrations --check --dry-run`: "No changes detected".

## Task Commits

**Nenhum commit de código foi feito, por decisão do usuário (opcao-a do 05-01-SUMMARY.md).** As mudanças ficam no working tree da `feat/APP05` do repo da API (HEAD continua `0592176`, nada enviado por push); `Web/core/throttles.py` aparece como não rastreado.

1. **Task 1: Tracer — 429 com Retry-After na lista da vitrine (WR-02)** — sem commit. RED: `ImportError` (o módulo `core.throttles` não existia); GREEN: `ThrottleVitrinePublica`, settings e `throttle_classes` em `VitrineCidadeAPIView`. `VitrineLimiteDeTaxaTests` + `VitrineBuscaTests` = 38 testes OK. Gate do tracer (auto mode): verificado de ponta a ponta antes de expandir.
2. **Task 2: Limite nas 5 rotas, API autenticada intocada, XFF inofensivo (WR-02, API-07)** — sem commit. Throttle nas outras 4 views, `cache.clear()` nos 3 `setUp`, `.env.example`. `VitrineLimiteDeTaxaTests` (6) + `VitrinePublicaTests` + `SemearVitrineDevTests` = 22 OK; suíte inteira 353 OK duas vezes.

**Plan metadata:** commit `docs(05-21)` no repo do app (somente `.planning/`).

## Files Created/Modified

- `../imoveis-aqui/Web/core/throttles.py` (novo) — `ThrottleVitrinePublica`.
- `../imoveis-aqui/Web/config/settings.py` — `DEFAULT_THROTTLE_RATES` (`vitrine_publica`) e `NUM_PROXIES`.
- `../imoveis-aqui/Web/imoveis/api/views.py` — import e `throttle_classes` nas 4 views públicas.
- `../imoveis-aqui/Web/localizacao/api/views.py` — import e `throttle_classes` em `CidadeAtendidaAPIView`.
- `../imoveis-aqui/Web/imoveis/tests.py` — imports; `cache.clear()` em `VitrineBase.setUp` e `VitrinePublicaTests.setUp`; classe `VitrineLimiteDeTaxaTests` (6 testes).
- `../imoveis-aqui/Web/empresas/tests.py` — `cache.clear()` em `SemearVitrineDevTests.setUp`.
- `../imoveis-aqui/Web/.env.example` — `VITRINE_TAXA_ANONIMA` e `NUM_PROXIES`.

## Decisions Made

- Um só balde por IP para as cinco rotas (o plano pede; o teste de balde compartilhado trava isso).
- `NUM_PROXIES = 0` por padrão; atrás de proxy reverso o deploy precisa configurar (item para o 05-22 registrar no contrato e no README).
- Taxa de 120/min por IP, bem acima da navegação normal do app (~4 requisições ao abrir a vitrine, 1 por página/busca/detalhe).

## Deviations from Plan

None - plan executed exactly as written.

Observação registrada conforme o plano: o teste `test_x_forwarded_for_forjado_nao_reinicia_a_contagem` não ficou vermelho de forma independente, porque `NUM_PROXIES = 0` já veio da Task 1 (as duas tarefas foram escritas juntas e o RED real foi o `ImportError` do módulo ausente). Ele trava a configuração (`NUM_PROXIES`), não código novo de view.

## Issues Encountered

None.

## Riscos aceitos e itens de deploy (para o 05-22 registrar no contrato/README)

- **CGNAT:** muitos aparelhos num IP podem bater juntos nos 120/min; ajustável por `VITRINE_TAXA_ANONIMA` (T-05-21-04).
- **LocMemCache por processo:** com vários workers o limite efetivo multiplica; cache compartilhado é item de deploy (T-05-21-05, ASVS nível 1).
- **Proxy reverso:** sem `NUM_PROXIES` configurado, todos os visitantes aparecem com o IP do proxy.
- **Fora do escopo (T-05-21-07):** `CorretorPublicoAPIView` (`corretores/<id>/`), `EmpresaPublicaAPIView` (`empresas/<id>/`) e `LoginAPIView` ficam sem limite; são rotas da frente web que o app não consome.
- **App:** o app não tem tratamento especial para 429; ele cai no mesmo estado de erro com "Tentar de novo" (D-14). Nenhuma mudança em `lib/` (prova no 05-22).

## Known Stubs

None.

## Threat Flags

None. O plano só reduz superfície existente (T-05-21-01..03 e 06 mitigados por teste).

## User Setup Required

None - nenhuma configuração externa obrigatória. Opcionais: `VITRINE_TAXA_ANONIMA` e `NUM_PROXIES` no `Web/.env` do ambiente (padrões já funcionam).

## Next Phase Readiness

- 05-22 (contrato §5/§8 e gates finais) pode seguir. Deve registrar: 429 + `Retry-After` nas 5 rotas públicas, a taxa e `NUM_PROXIES` como itens de deploy, os riscos aceitos acima e a lista de rotas web fora do limite.
- Pendência do usuário: as mudanças deste plano (e as anteriores da opcao-a) continuam só no working tree de `../imoveis-aqui` (feat/APP05, HEAD 0592176); o commit no repo da API fica para o usuário decidir.
- REQUIREMENTS.md: API-03/API-07 NÃO marcados como completos aqui (aguardam o 05-22).

## Self-Check: PASSED

- `core/throttles.py` com `class ThrottleVitrinePublica(AnonRateThrottle)`; `settings.py` com `vitrine_publica`, `VITRINE_TAXA_ANONIMA`, `120/min`, `NUM_PROXIES`; `grep -c` de `throttle_classes = [ThrottleVitrinePublica]`: 4 em `imoveis/api/views.py`, 1 em `localizacao/api/views.py`.
- Suíte inteira: 353 testes OK duas vezes seguidas; `makemigrations --check`: sem mudanças; `DEFAULT_THROTTLE_CLASSES == []`; HEAD da API ainda `0592176`.

---
*Phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final*
*Completed: 2026-11-16*
