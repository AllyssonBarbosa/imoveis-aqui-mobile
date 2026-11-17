---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 03
subsystem: testing
tags: [fixtures, contrato, captura, canais_contato, contato, whatsapp, allowlist]

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "canais_contato no detalhe e POST de contato (06-01), limite 429 e %20 no WhatsApp (06-02), política de git app-a"
provides:
  - "Seis detalhe_*.json recapturados da API real com canais_contato (só essa chave e o sufixo das mídias mudaram)"
  - "contato_201_whatsapp/telefone/email.json e erro_400_canal_contato.json capturados do POST real"
  - "tool/capturar_fixtures_api.py com postar() e grupo contato (recusa link do WhatsApp com '+')"
  - "contrato_detalhe_test com 'canais_contato' em _chavesDetalhe e grupo 'canais_contato capturado (D-01)'"
affects: [06-04, 06-05, 06-07, 06-08, 06-09]

plan_head_before: b9f233ed117af4aa002cf5c8b589d992840292c8
actuals:
  tokens: 6500   # chars/4 sobre os arquivos de código/teste alterados (script, teste); fixtures capturadas pelo script (JSON de detalhe ~ +1 chave cada)
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count b9f233e..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Fixture de wire só pelo script de captura contra SQLite temporário; guarda no script recusa servidor sem a correção do %20"
    - "Allowlist exata do detalhe espelhada nos dois repositórios (_chavesDetalhe == CHAVES_DETALHE do Django)"

key-files:
  created:
    - test/fixtures/api/contato_201_whatsapp.json
    - test/fixtures/api/contato_201_telefone.json
    - test/fixtures/api/contato_201_email.json
    - test/fixtures/api/erro_400_canal_contato.json
  modified:
    - tool/capturar_fixtures_api.py
    - test/data/contrato_detalhe_test.dart
    - test/fixtures/api/detalhe_casa.json
    - test/fixtures/api/detalhe_apartamento.json
    - test/fixtures/api/detalhe_terreno.json
    - test/fixtures/api/detalhe_lote.json
    - test/fixtures/api/detalhe_sem_fotos.json
    - test/fixtures/api/detalhe_sem_corretor.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe_lote.example.json

key-decisions:
  - "O teste do grupo canais_contato itera todos os detalhe_*.json capturados (lista, só nomes, ordem fixa WHATSAPP/TELEFONE/EMAIL, sem repetição), exige ao menos uma captura com os três canais e canais não vazio no sem corretor"
  - "capturar_contato usa a primeira CASA com foto_capa da p1 de Campinas (mesma regra de capturar_detalhe) e exige canais_contato == [WHATSAPP, TELEFONE, EMAIL] antes de postar"

requirements-completed: [APP06-API-1, APP06-C2, APP06-C3, APP06-C4]

coverage:
  - id: D1
    description: "Detalhes recapturados diferem da main só em canais_contato e sufixo de mídia; 404 idêntico; exemplos do contrato são cópias byte a byte"
    requirement: APP06-API-1
    verification:
      - kind: integration
        ref: "verify do Task 1 (python3 comparando com git show main:, git diff --quiet main -- erro_404_detalhe.json, cmp dos exemplos)"
        status: pass
    human_judgment: false
  - id: D2
    description: "canais_contato travado na allowlist exata do app e validado nos JSON capturados (D-01, D-04)"
    requirement: APP06-C3
    verification:
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart grupo 'canais_contato capturado (D-01)' + _chavesDetalhe"
        status: pass
    human_judgment: false
  - id: D3
    description: "Respostas reais do POST de contato capturadas; link do WhatsApp com %20 e sem '+'"
    requirement: APP06-C4
    verification:
      - kind: integration
        ref: "tool/capturar_fixtures_api.py --grupo contato contra feat/APP06 (SQLite temporário) + verify do Task 2 sobre os arquivos salvos"
        status: pass
    human_judgment: false
---

# Phase 6 Plan 03: Captura do contrato novo (canais_contato e POST de contato) Summary

**Fixtures do detalhe recapturadas da API real com `canais_contato`, allowlist exata do app em dia e o script de captura com o grupo `contato` (POST real, com a guarda do `+` do WhatsApp).**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-11-16
- **Tasks:** 2
- **Files modified:** 14 (10 modificados, 4 criados), nenhum em `lib/`

## Accomplishments

- Os seis `detalhe_*.json` vieram de um servidor temporário da `feat/APP06` (SQLite semeado, nunca o banco do `Web/.env`) e diferem da `main` só em `canais_contato` e no sufixo aleatório das mídias; `erro_404_detalhe.json` reescrito pela mesma captura ficou idêntico ao da `main`.
- `_chavesDetalhe` ganhou `'canais_contato'` e o grupo `'canais_contato capturado (D-01)'` confere lista, nomes válidos, ordem fixa, ausência de repetição, ao menos uma captura com três canais e canais não vazio no "sem corretor" (fallback da empresa).
- O script ganhou `postar()` e `capturar_contato()`; `todos` = lista, detalhe, contato. Recusa (`ErroCaptura`) um link do WhatsApp com `+` ou sem `%20`.

## Dados reais capturados

| Fixture | Id | `canais_contato` |
|---|---|---|
| detalhe_casa | 21 | `["WHATSAPP", "TELEFONE", "EMAIL"]` |
| detalhe_apartamento | 22 | `["WHATSAPP", "TELEFONE", "EMAIL"]` |
| detalhe_terreno | 23 | `["WHATSAPP", "TELEFONE", "EMAIL"]` |
| detalhe_lote | 24 | `["WHATSAPP", "TELEFONE", "EMAIL"]` |
| detalhe_sem_fotos | 11 | `["WHATSAPP", "TELEFONE", "EMAIL"]` |
| detalhe_sem_corretor | 14 | `["WHATSAPP", "EMAIL"]` (fallback da empresa, como previsto) |

- Casa usada no POST de contato: id 21.
- `erro_404_detalhe.json` idêntico ao da `main`.
- Link do WhatsApp capturado: `https://wa.me/5519988887777?text=Ol%C3%A1%21%20Vi%20no%20Im%C3%B3veis%20Aqui%20o%20im%C3%B3vel%20%22Casa%20no%20bairro%20Cambu%C3%AD%22%20%28c%C3%B3digo%20DEV-CAMPINAS-21%29%20e%20gostaria%20de%20mais%20informa%C3%A7%C3%B5es.%20http%3A%2F%2F127.0.0.1%3A8000%2Fimovel%2F21%2F` (`%20` entre as palavras, nenhum `+`).
- Telefone: `tel:+5519988887777`; e-mail: `mailto:corretor.vitrine.demo@example.com?subject=...&body=...` (com `%20`).
- 400 de canal inválido: `{"canal": ["\"SMS\" não é uma escolha válida."]}`.

## Task Commits

1. **Task 1 (tracer): recaptura do detalhe com canais_contato** - `bd13add` (test)
2. **Task 2: captura real do POST de contato** - `b742bdf` (test)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificação

- Verify do Task 1: `[True x6]`, 404 idêntico à `main`, `cmp` dos dois exemplos silencioso.
- Verify do Task 2: fixtures de contato com chaves exatas `canal`/`link`, esquema certo, `%20` e sem `+`; função/grupo presentes no script.
- `flutter test test/data/`: 185 testes passaram. `flutter test` (suíte inteira): 592 testes passaram.
- `git diff --name-only b9f233e HEAD -- lib` vazio (nenhum código de `lib/` mudou).
- Servidor temporário parado pelo PID e SQLite apagado nas duas rodadas; porta 8000 livre.

## Deviations from Plan

None - plano executado como escrito. Observações sem desvio:
- O cabeçalho do teste não dizia que as chaves terminavam em `corretor_responsavel`, então não precisou de ajuste.
- Acrescentei ao grupo do teste uma guarda extra ("canais_contato faltando na raiz é detectado"), coerente com o padrão do grupo "guarda do contrato".

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova além das já cobertas pelo threat model do plano.

## Issues Encountered

None.

## Next Phase Readiness

06-04 já pode mapear `canais_contato` para o enum do domínio e travar o contrato do POST sobre as quatro fixtures capturadas.

## Self-Check: PASSED

- Fixtures de contato e arquivos modificados existem; commits `bd13add` e `b742bdf` presentes em `git log`.
