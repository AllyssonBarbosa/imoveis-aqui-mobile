---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 04
subsystem: api
tags: [django, drf, vitrine, filtros, csv, opcoes-publicas]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-02: lote na vitrine, allowlist exata, VitrineBase/publicar_lote_da_vitrine nos testes"
provides:
  - "GET /api/publico/cidades/<id>/bairros/ (array de strings, ordenado, sem repetição, derivado de imoveis_da_vitrine())"
  - "GET /api/publico/caracteristicas/ (catálogo global [{id, nome}], sem paginação)"
  - "natureza=CASA,LOTE (natureza__in, 400 em valor fora de Imovel.Natureza)"
  - "bairro=Moema,Pinheiros (OR de bairro_anuncio__iexact, sem diferenciar maiúsculas)"
  - "README da API (seção Vitrine pública) com na_vitrine, LOTE, CSV, os dois endpoints e o risco da vírgula"
affects: [05-05, 05-11, 05-12, 05-15, 05-18]

plan_head_before: 82ca24dfe24b979cc6b9dc07d682a3156581234b
actuals:
  tokens: 14000
  tasks: 2
  commits: 0   # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): plano sem código no app. Repo da API: nenhum commit (opcao-a); mudanças no working tree.

tech-stack:
  added: []
  patterns:
    - "Opções de filtro derivadas da mesma imoveis_da_vitrine() da lista: opção oferecida nunca leva a busca vazia"
    - "CSV de filtro: _escolhas (allowlist, aparado, itens vazios descartados); bairro via OR de iexact (nunca __in)"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/api/urls_publico.py
    - ../imoveis-aqui/Web/imoveis/tests.py
    - ../imoveis-aqui/README.md

key-decisions:
  - "BairrosDaCidadeAPIView é APIView (não GenericAPIView): só devolve uma lista de strings, sem serializer nem paginação"
  - "Bairro com vírgula no nome fica fora do CSV: risco aceito A-05, travado por teste e documentado no README (contrato fica para 05-18)"

requirements-completed: []

coverage:
  - id: D1
    description: "Bairros da vitrine de uma cidade: ordenados, sem repetição, apartamento pelo prédio; rascunho/reservado/empresa inativa/outra cidade/bairro vazio ausentes; 404 em cidade inexistente, 405 em POST, token inválido ignorado; toda opção leva a busca não vazia"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineOpcoesTests"
        status: pass
    human_judgment: false
  - id: D2
    description: "Catálogo público de características: ordenado por nome, itens com exatamente id e nome, inclui as sem uso, sem paginação, 405 em POST"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineOpcoesTests.test_catalogo_de_caracteristicas_ordenado_por_nome_sem_token"
        status: pass
    human_judgment: false
  - id: D3
    description: "Multi-seleção CSV: natureza (OU, 400 com chave natureza, espaços, vírgula solta) e bairro (OU, case-insensitive, valor único, cidade respeitada, vírgula no nome não representável)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineMultiSelecaoTests"
        status: pass
    human_judgment: false
  - id: D4
    description: "Suíte Django inteira (319 testes) verde em SQLite em memória; makemigrations --check sem mudanças"
    verification:
      - kind: integration
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput; manage.py makemigrations --check --dry-run"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-10-30
status: complete
---

# Phase 5 Plan 04: Opções de filtro públicas e multi-seleção CSV Summary

**Bairros da cidade e catálogo de características como endpoints públicos sem token, mais OU por vírgula em `natureza` (allowlist, `__in`) e `bairro` (OR de `iexact`), tudo documentado no README da API; 319 testes Django verdes.**

## Git (política opcao-a + app-a de 05-01)

- API (`../imoveis-aqui`, `feat/APP05`): **nenhum commit**; as mudanças deste plano estão no working tree, em cima das de 05-02 (que permanecem intactas): `views.py`, `urls_publico.py`, `tests.py`, `README.md`. Nunca push.
- App: nenhum código; só este SUMMARY e STATE/ROADMAP (docs do GSD).
- Linhas do plano "commit ... (opcao-b)" ignoradas conforme a política.

## Accomplishments

- `views.py`: `BairrosDaCidadeAPIView` (`AllowAny`, `authentication_classes = []`; `imoveis_da_vitrine().filter(cidade_anuncio=...)` sem nulos/vazios, `order_by` + `distinct`), `_escolhas` (CSV aparado, itens vazios descartados, item fora das opções vira 400 `{natureza: "Opções válidas: ..."}`), `natureza__in`, bairro como `reduce(operator.or_, Q(bairro_anuncio__iexact=...))`, `CaracteristicasPublicasAPIView` (`pagination_class = None`, `CaracteristicaSerializer`, ordem do `Meta.ordering`).
- `urls_publico.py`: `publico-bairros-cidade` e `publico-caracteristicas`.
- `tests.py`: `VitrineOpcoesTests` (8) e `VitrineMultiSelecaoTests` (10).
- `README.md` (só a seção "Vitrine pública (API)"): regra `na_vitrine`, LOTE, CSV de natureza/bairro, risco da vírgula (A-05), área do lote, os dois endpoints e "a galeria começa pela capa".

## Task Commits

1. **Task 1 (tracer, tdd)** — bairros por cidade; RED (6 erros `NoReverseMatch`), depois GREEN (6 testes). Sem commit (opcao-a). Gate do tracer: modo `end-of-phase` com `<verify>` só automatizado, reexecutado e verde, seguiu para a Task 2.
2. **Task 2 (auto, tdd)** — CSV + catálogo + README; RED (7 falhas + 2 erros), depois GREEN (34 testes em Opções + Multi-seleção + Busca). Sem commit (opcao-a).

## Deviations from Plan

None - plano executado como escrito. Duas escolhas dentro da margem do plano: `APIView` simples para os bairros (o plano admitia `GenericAPIView` ou `APIView`) e a divisão do CSV de bairro feita inline (sem allowlist, pois bairro é texto livre).

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. Superfície nova (dois GET públicos) coberta por T-05-04-01/02/03: bairros derivados só de `imoveis_da_vitrine()` (testado: rascunho, reservado, empresa inativa, outra cidade, bairro vazio), natureza com allowlist e bairro só por ORM parametrizado, `AllowAny` + `authentication_classes = []` com teste de token inválido e 405 em POST. T-05-04-04/05 aceitos (vírgula no nome do bairro travada por teste e documentada no README; o contrato do app em 05-18 deve repeti-la).

## Verificação

- `VitrineOpcoesTests`, `VitrineMultiSelecaoTests`, `VitrineBuscaTests`: 34 testes OK.
- `manage.py test --noinput` (SQLite em memória): 319 testes OK; `makemigrations --check --dry-run`: sem mudanças.
- `grep` do README (`cidades/<id>/bairros/`, `caracteristicas/`, `na_vitrine`): OK.
- Banco de dev / `Web/.env` não tocados nem lidos; `.gitignore` intocado; nenhum formatador rodado.
- API-03 NÃO marcada em REQUIREMENTS.md (fecha em 05-18).

## Self-Check: PASSED

- `class BairrosDaCidadeAPIView`, `class CaracteristicasPublicasAPIView`, `def _escolhas(`, `natureza__in`, `bairro_anuncio__iexact` e `pagination_class = None` presentes em `Web/imoveis/api/views.py`; `publico-bairros-cidade` e `publico-caracteristicas` em `urls_publico.py`; `class VitrineOpcoesTests` e `class VitrineMultiSelecaoTests` em `tests.py`.
- Repo da API sem commits novos desde `0592176`.
