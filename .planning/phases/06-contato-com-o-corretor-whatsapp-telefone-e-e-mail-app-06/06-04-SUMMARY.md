---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 04
subsystem: dominio
tags: [canais_contato, CanalContato, freezed, contrato, contato, whatsapp, tolerancia]

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "fixtures capturadas com canais_contato e POST de contato (06-03); canais_contato e POST no Django (06-01, 06-02)"
provides:
  - "enum CanalContato { whatsapp, telefone, email } no domínio (ordem = prioridade do botão principal)"
  - "extension CanalContatoNaApi.valorApi: único lugar dos nomes WHATSAPP/TELEFONE/EMAIL"
  - "DetalheImovel.canaisContato: List<CanalContato> tolerante (ausente/nulo/desconhecido/repetido)"
  - "contrato_contato_test.dart travando o POST de contato sobre as fixtures capturadas"
  - "01-CONTRATO-API.md com canais_contato e seção 13 (POST de contato); README com 19 fixtures e grupo contato"
affects: [06-05, 06-06, 06-07, 06-08, 06-09]

plan_head_before: bd088171907ca3a107053ed3695737246bd64dca
actuals:
  tokens: 5500   # chars/4 sobre código e testes alterados (enum, extension, model, entidade, dois testes)
  tasks: 3
  commits: 3     # MEDIDO: git rev-list --count bd08817..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Nomes do wire num único extension em data/; o domínio só vê o enum"
    - "Mapeamento tolerante por CanalContato.values.where(contains): ordem do enum, sem duplicata, desconhecidos descartados"

key-files:
  created:
    - lib/domain/entities/canal_contato.dart
    - lib/data/models/canal_contato_api.dart
    - test/data/contrato_contato_test.dart
  modified:
    - lib/domain/entities/detalhe_imovel.dart
    - lib/domain/entities/detalhe_imovel.freezed.dart
    - lib/data/models/detalhe_imovel_model.dart
    - lib/data/models/detalhe_imovel_model.freezed.dart
    - lib/data/models/detalhe_imovel_model.g.dart
    - test/data/detalhe_imovel_model_test.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - README.md

key-decisions:
  - "O caso nulo de canais_contato não precisou de mudança no model: o @Default do freezed vira defaultValue no json_serializable e cobre o null explícito"
  - "CorretorModel e CorretorResponsavel ficaram intactos (D-02): o app nunca deduz canal dos dados do corretor"

requirements-completed: [APP06-API-1, APP06-C2, APP06-C3]

coverage:
  - id: D1
    description: "canais_contato dos detalhes capturados vira List<CanalContato> tipada, na ordem fixa"
    requirement: APP06-API-1
    verification:
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart grupo 'canais_contato capturado -> entidade (D-01)'"
        status: pass
    human_judgment: false
  - id: D2
    description: "Parse tolerante: ausente, nulo, desconhecido, repetido/fora de ordem e vazio nunca derrubam o detalhe"
    requirement: APP06-API-1
    verification:
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart grupo 'canais_contato (D-01, D-03)'"
        status: pass
    human_judgment: false
  - id: D3
    description: "POST de contato travado sobre as respostas reais: chaves {canal, link}, esquema por canal, %20 sem '+', round-trip do link"
    requirement: APP06-C3
    verification:
      - kind: unit
        ref: "test/data/contrato_contato_test.dart"
        status: pass
    human_judgment: false
---

# Phase 6 Plan 04: Canais de contato no domínio e contrato do POST Summary

**`canais_contato` do detalhe capturado vira `DetalheImovel.canaisContato: List<CanalContato>` (enum tipado, ordem fixa, tolerante), e o contrato do POST de contato fica travado por teste sobre as fixtures reais e documentado.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-11-16
- **Tasks:** 3 (1 tracer, 2 auto)
- **Files modified:** 11 (3 criados, 8 modificados, incluindo os 3 gerados pelo build_runner)

## Accomplishments

- Domínio: `CanalContato` com a ordem de declaração como prioridade do botão principal (D-06) e `CanalContatoNaApi.valorApi` como único lugar dos nomes do wire.
- `DetalheImovelModel` lê `canais_contato` (`List<String>` com default) e `paraEntidade()` mapeia por `CanalContato.values` filtrado: ordem do enum, sem duplicatas, nomes desconhecidos descartados, nunca lança.
- Cinco testes de tolerância sobre cópias do `detalhe_casa.json` capturado (ausente, nulo, `["SMS","EMAIL","FAX"]`, `["EMAIL","WHATSAPP","EMAIL"]`, `[]`).
- `contrato_contato_test.dart` trava, sobre as quatro fixtures de 06-03, as chaves exatas `{canal, link}`, https+`wa.me` com `text` não vazio, `%20` e nenhum `+`, `tel`, `mailto` com `subject` e `body`, e `Uri.parse(link).toString() == link`.
- Contrato (`01-CONTRATO-API.md`): `canais_contato` em §6 e §11.2, balde `contato_publico` em "Erros 429", fixtures do contato em §12 e nova seção "13. POST contato" (201/400/404/405/429, `%20`, comportamento do app D-13/D-14/D-15).
- README: `--grupo todos` recaptura 19 fixtures (medido: `ls test/fixtures/api/*.json | wc -l` = 19, igual ao esperado) e o grupo `contato` está descrito, com POSTs só no SQLite temporário.

## `canaisContato` mapeado por detalhe capturado

| Fixture | Entidade |
|---|---|
| detalhe_casa | `[whatsapp, telefone, email]` |
| detalhe_apartamento | `[whatsapp, telefone, email]` |
| detalhe_terreno | `[whatsapp, telefone, email]` |
| detalhe_lote | `[whatsapp, telefone, email]` |
| detalhe_sem_fotos | `[whatsapp, telefone, email]` |
| detalhe_sem_corretor | `[whatsapp, email]` (corretor `null`; canais da empresa) |

O caso nulo (`canais_contato: null`) **não** precisou de mudança no model: o `@Default(<String>[])` do freezed chega ao `json_serializable` como valor padrão e cobre o `null` explícito.

## Task Commits

1. **Task 1 (tracer): CanalContato no domínio e canais_contato no detalhe** - `7b2cbd4` (feat)
2. **Task 2: parse tolerante de canais_contato** - `991e497` (test)
3. **Task 3: contrato do POST de contato e documentação** - `3524bbc` (test)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificação

- `dart run build_runner build -d`: sem SEVERE, 9 saídas escritas.
- Grupo 'canais_contato capturado': 8 testes passaram; 'canais_contato (D-01, D-03)': 5 passaram.
- `flutter test test/data/`: 198 passaram. `flutter test` (suíte inteira): 614 passaram. `flutter analyze`: sem issues.
- `CorretorModel` e `CorretorResponsavel` sem nenhuma linha alterada.
- Verifies de documentação: seção 13, `canais_contato`, `contato_201_whatsapp.json` e `contato_publico` presentes no contrato; README com "recaptura as 19 fixtures" e "grupo contato".

## Deviations from Plan

None - plano executado como escrito. Observação sem desvio: o arquivo do skill do projeto estava em `.claude/skills/flutter-frontend/skill` (arquivo, não `SKILL.md`); foi lido e seguido (const, null safety, camadas separadas).

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova além das cobertas pelo threat model do plano.

## Issues Encountered

None.

## Next Phase Readiness

06-05 pode escrever a camada de dados do POST sobre o contrato travado: o domínio já expõe `CanalContato` e `canaisContato`, e `valorApi` fornece o nome do canal para o corpo da requisição.

## Self-Check: PASSED

- Arquivos criados existem (`canal_contato.dart`, `canal_contato_api.dart`, `contrato_contato_test.dart`); commits `7b2cbd4`, `991e497` e `3524bbc` presentes em `git log`.
