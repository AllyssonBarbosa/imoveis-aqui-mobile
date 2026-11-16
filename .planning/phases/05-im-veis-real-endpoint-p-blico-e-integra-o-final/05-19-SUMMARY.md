---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 19
subsystem: api
tags: [django, drf, validation, input-hardening, decimal, postgres-nul]
gap_closure: true

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-18: lista pública da vitrine com filtros server-side (W09) e suíte de 331 testes"
provides:
  - "_numero com allowlist ASCII, is_finite(), negativo e teto da própria coluna (preço 9999999999.99, área 99999999.99, inteiro 32767)"
  - "_texto (NUL + teto de caracteres) e _bairros_do_filtro (NUL, 20 itens, 100 caracteres por item)"
  - "10 testes de entrada hostil em VitrineBuscaTests"
affects: [05-20, 05-21, 05-22]

plan_head_before: 0592176
actuals:
  tokens: 14500
  tasks: 2
  commits: 0

tech-stack:
  added: []
  patterns:
    - "Validação por formato permitido (allowlist) antes de converter, nunca por captura de exceção da conversão"
    - "Cada filtro numérico leva o teto da própria coluna (tupla lookup+teto no dicionário faixas)"
    - "NUL recusado em Python (independe do banco), para o 400 valer em SQLite e em Postgres"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py

key-decisions:
  - "Preço e área têm tetos separados (MAXIMO_FILTRO_PRECO 12 dígitos; MAXIMO_FILTRO_AREA 10 dígitos): um teto decimal único era o erro a corrigir"
  - "Regex com [0-9] e fullmatch, nunca \\d: dígito não ASCII e '_' que int()/Decimal() aceitam viram 400"
  - "Teto da busca (200), de bairros (20) e de caracteres por bairro (100) como constantes locais reversíveis; risco aceito no app (SearchBar sem maxLength; 21+ bairros; área >= 100.000.000 m²), registrado no contrato pelo 05-22"

patterns-established:
  - "Helpers de leitura de parâmetro (_numero, _texto, _bairros_do_filtro) lançam ValidationError({campo: mensagem}) — mesmo corpo 400 do contrato"

requirements-completed: [API-03]

duration: 12min
completed: 2026-11-16
status: complete

coverage:
  - id: D1
    description: "preco_*/area_* com NaN, sNaN, Infinity, -Infinity, inf, 1e400, 1e3, 1_0, espaço ou dígito não ASCII respondem 400 {campo: 'Informe um número válido.'}, nunca 500 (CR-02)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_numero_nao_finito_ou_fora_do_formato_da_400"
        status: pass
    human_judgment: false
  - id: D2
    description: "quartos/suites/vagas fora do formato inteiro ASCII, negativos e acima de 32767 respondem 400 com a mensagem do campo"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_numero_inteiro_fora_do_formato_da_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_numero_negativo_da_400_com_mensagem"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_numero_acima_do_teto_da_400_e_no_teto_passa"
        status: pass
    human_judgment: false
  - id: D3
    description: "preço acima de 9999999999.99 e área acima de 99999999.99 dão 400 'O valor passa do máximo permitido.'; valores no teto e decimais com fração continuam filtrando"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_area_tem_o_teto_da_coluna"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_decimal_com_fracao_continua_aceito"
        status: pass
    human_judgment: false
  - id: D4
    description: "busca/bairro com byte NUL respondem 400 em qualquer banco e nenhum parâmetro da lista com %00 dá 500 (WR-01)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_byte_nul_em_busca_e_bairro_da_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_byte_nul_em_qualquer_parametro_nunca_da_500"
        status: pass
    human_judgment: false
  - id: D5
    description: "busca > 200 caracteres, bairro > 20 itens e item de bairro > 100 caracteres respondem 400; entrada válida se comporta como antes (WR-02, D-07)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_busca_acima_do_teto_da_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_bairro_com_itens_demais_ou_longo_demais_da_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineMultiSelecaoTests (suite, sem edição)"
        status: pass
    human_judgment: false
---

# Phase 5 Plan 19: Endurecimento da entrada da lista pública (CR-02 + WR-01 + tetos do WR-02) Summary

**`_numero` por allowlist ASCII com finitude, negativo e teto da própria coluna (preço 12 dígitos, área 10 dígitos, inteiro 32767), mais `_texto`/`_bairros_do_filtro` que recusam NUL e tamanho excessivo: todo valor hostil na lista pública vira 400 `{campo: mensagem}`, nunca 500.**

## Performance

- **Duration:** ~12 min
- **Completed:** 2026-11-16T17:22Z
- **Tasks:** 2 (tracer + auto, ambas TDD)
- **Files modified:** 2 (ambos no repo da API, sem commit)

## Accomplishments

- **CR-02 fechado.** `preco_min=NaN` (antes `decimal.InvalidOperation`), `Infinity` (antes `ValidationError` do Django) e `1e400` deixam de dar 500: o texto cru precisa casar por inteiro com `[0-9]+(\.[0-9]+)?` (decimal) ou `[0-9]+` (inteiro), o decimal convertido precisa passar em `is_finite()`, e só então vêm o negativo e o teto. `1_0`, `1e3`, espaço e dígito arábico-índico também dão 400.
- **Teto por coluna.** Preço usa `MAXIMO_FILTRO_PRECO = 9999999999.99`; área usa `MAXIMO_FILTRO_AREA = 99999999.99` (max_digits=10, `area_anuncio` é um Case sobre quatro colunas de área); quartos/suítes/vagas usam `MAXIMO_FILTRO_INTEIRO = 32767`. O dicionário `faixas` agora é `nome -> (lookup, teto)` e `_numero` exige o teto como argumento.
- **WR-01 fechado.** `_texto` e `_bairros_do_filtro` recusam NUL em Python antes da consulta, então o 400 vale em SQLite (testes) e em Postgres (produção). Teste varre busca, bairro, natureza, finalidade, ordenar, preco_min, area_max, quartos e caracteristicas com `\x00`.
- **Tetos do WR-02 (busca/bairro).** busca até 200 caracteres depois do trim; bairro até 20 itens e 100 caracteres por item. Trim, vazio ignorado e OU de `iexact` ficam idênticos (D-07).
- Suíte Django inteira: **341 testes OK** (331 da linha de base + 10 novos). `makemigrations --check --dry-run`: "No changes detected".

## Task Commits

**Nenhum commit de código foi feito, por decisão do usuário (opcao-a do 05-01-SUMMARY.md).** As mudanças de `views.py` e `tests.py` ficam no working tree da `feat/APP05` do repo da API, cujo HEAD continua `0592176`; nada foi enviado por push.

1. **Task 1: Tracer — número hostil vira 400 (CR-02)** — sem commit (working tree da API). RED: 47 falhas + 16 erros nos testes novos; GREEN: `VitrineBuscaTests` verde.
2. **Task 2: NUL e tetos de busca/bairro (WR-01, WR-02)** — sem commit (working tree da API). RED confirmado junto da Task 1 (testes escritos antes da implementação); GREEN: 36 testes de `VitrineBuscaTests` + `VitrineMultiSelecaoTests` OK, suíte inteira OK.

**Plan metadata:** commit `docs(05-19)` no repo do app (somente `.planning/`).

## Files Created/Modified

- `../imoveis-aqui/Web/imoveis/api/views.py` — `import re`; `_FORMATO_DECIMAL`/`_FORMATO_INTEIRO`; constantes `MAXIMO_*`; `_numero(params, nome, maximo, tipo=Decimal)` reescrito; novos `_texto` e `_bairros_do_filtro`; `get_queryset` usa os helpers e o teto por faixa.
- `../imoveis-aqui/Web/imoveis/tests.py` — 10 testes novos em `VitrineBuscaTests`: `test_numero_nao_finito_ou_fora_do_formato_da_400`, `test_numero_inteiro_fora_do_formato_da_400`, `test_numero_negativo_da_400_com_mensagem`, `test_numero_acima_do_teto_da_400_e_no_teto_passa`, `test_area_tem_o_teto_da_coluna`, `test_decimal_com_fracao_continua_aceito`, `test_byte_nul_em_busca_e_bairro_da_400`, `test_byte_nul_em_qualquer_parametro_nunca_da_500`, `test_busca_acima_do_teto_da_400`, `test_bairro_com_itens_demais_ou_longo_demais_da_400`.

## Decisions Made

- Allowlist por `fullmatch` com `[0-9]` (nunca `\d`) em vez de confiar em `Decimal()`/`int()`: ambos aceitam NaN/Infinity/expoente/`_`/dígito não ASCII. O `except (InvalidOperation, ValueError)` e o `is_finite()` ficam como defesa em profundidade.
- Teto de área separado do de preço (10 vs 12 dígitos): conferido no plano que o SQLite aceita 100000000, então o teto da área é defesa em profundidade para backend/driver que ajuste o parâmetro ao (10,2).
- Riscos aceitos, a registrar no contrato pelo 05-22 (lib/ não muda, D-01): área de 100.000.000 m² ou mais (máscara do app aceita 9 dígitos), 21+ bairros marcados e busca com mais de 200 caracteres viram o estado de erro com "Tentar de novo".
- Fora de escopo (adiados pelo usuário): WR-03..WR-06 e IN-01..IN-09 do 05-REVIEW.

## Deviations from Plan

None - plan executed exactly as written.

O plano descreve o RED das duas tasks separadamente; os 10 testes foram escritos em um único passo antes de qualquer mudança em `views.py` (RED único: 47 falhas + 16 erros), e o GREEN foi aplicado em uma única edição de `views.py` cobrindo as duas tasks. Mesmo resultado final, sem alteração de escopo.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None. Nenhuma superfície nova: o plano só reduz a existente (T-05-19-01..05 mitigados por teste).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-20 (CR-01), 05-21 (limite de taxa do WR-02) e 05-22 (contrato §5/§8 e gates finais) seguem.
- Pendência do usuário: as mudanças deste plano (e as anteriores da opcao-a) continuam só no working tree de `../imoveis-aqui` (feat/APP05, HEAD 0592176); o commit no repo da API fica para o usuário decidir.
- O 05-22 deve listar no contrato as mensagens novas: "O valor passa do máximo permitido.", "O texto tem um caractere inválido.", "Use no máximo 200 caracteres.", "Escolha no máximo 20 bairros.", "Cada bairro tem no máximo 100 caracteres.".

## Self-Check: PASSED

- `views.py` e `tests.py` modificados e verificados por grep (is_finite, 3 constantes de teto, 4 entradas de `faixas`, `_numero(... MAXIMO_FILTRO_INTEIRO, tipo=int)`, `_texto`, `_bairros_do_filtro`, 3 constantes de texto, mensagem de NUL).
- Suíte inteira: 341 testes OK; `makemigrations --check`: sem mudanças; HEAD da API ainda `0592176`.

---
*Phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final*
*Completed: 2026-11-16*
