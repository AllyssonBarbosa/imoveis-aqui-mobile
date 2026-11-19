---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 02
subsystem: api
tags: [django, drf, vitrine, lote, allowlist, fotos-capa]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-01: feat/APP05 da API com imoveis_da_vitrine() sobre na_vitrine() e W07/W08 (Loteamento, Quadra, Lote) mergeadas"
provides:
  - "natureza=LOTE na lista pública (area = lote.area, cidade/bairro do endereço do Imóvel)"
  - "bloco lote no detalhe público (LotePublicoSerializer -> QuadraPublicaSerializer -> LoteamentoPublicoSerializer, campos um a um)"
  - "allowlist exata (igualdade de conjunto de chaves) de todo objeto público + deny-list estendida"
  - "galeria do detalhe começa pela capa (regra da API, o app nunca reordena)"
affects: [05-04, 05-05, 05-14, 05-16, 05-17, 05-18]

plan_head_before: f4d8fc0b52d286fb9b33747e5c2cec9f4425f6e0
actuals:
  tokens: 28000
  tasks: 3
  commits: 0   # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): plano sem código no app. Repo da API: nenhum commit (opcao-a); mudanças no working tree.

tech-stack:
  added: []
  patterns:
    - "Serializer público por natureza com fields listados um a um, sem herdar o do painel"
    - "Chaves de cada objeto público travadas por assertEqual(set(...), {...}) (allowlist) além do deny-list"
    - "Ordem da galeria é regra da API: Prefetch('fotos', order_by('-capa','ordem','id'))"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/imoveis/vitrine.py
    - ../imoveis-aqui/Web/imoveis/api/serializers.py
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py

key-decisions:
  - "Task 2 (respondida pelo usuário): opcao-a — empresa_id fica em CorretorPublicoSerializer; registrado como PENDENTE para a frente web"
  - "Preço do lote é o preco_venda do Imóvel: o bloco lote não tem preco, vendido, ids nem cidade"
  - "Helper de teste do lote chama criar_lote_da_vitrine (o criar_lote(imovel, quadra) da W08 já existia)"

requirements-completed: [API-03, API-07]

coverage:
  - id: D1
    description: "Lote na lista pública: área do lote, quartos/suites/vagas nulos, cidade pelo endereço do Imóvel (não pela do loteamento), filtro e ordenação por área"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLoteTests"
        status: pass
    human_judgment: false
  - id: D2
    description: "Detalhe do lote com bloco lote (numero, area, frente, fundo, entrada_minima, parcelas_maximas, condicoes_parcelamento, quadra{identificacao, loteamento{...}}), casa/terreno/apartamento nulos, 3 consultas fixas"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLoteTests.test_detalhe_do_lote_traz_o_bloco_lote_e_as_outras_naturezas_nulas"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineLoteTests.test_detalhe_do_lote_tem_numero_fixo_de_consultas"
        status: pass
    human_judgment: false
  - id: D3
    description: "Allowlist exata de item, detalhe, endereco, cidade, foto, característica, casa, terreno, apartamento, predio, lote, quadra, loteamento e corretor_responsavel; deny-list com vendido/situacao/documentos/historico, lote incluso"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineAllowlistExataTests"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineSemTokenESemVazamentoTests"
        status: pass
    human_judgment: false
  - id: D4
    description: "Galeria começa pela capa; foto_capa do cartão = fotos[0] do detalhe; sem capa vale ordem/id"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineFotosCapaTests"
        status: pass
    human_judgment: false
  - id: D5
    description: "Suíte Django inteira (301 testes) verde em SQLite em memória; makemigrations --check sem mudanças"
    verification:
      - kind: integration
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput; manage.py makemigrations --check --dry-run"
        status: pass
    human_judgment: false

duration: 12min
completed: 2026-10-30
status: complete
---

# Phase 5 Plan 02: API pública do lote + allowlist exata + capa primeiro Summary

**Lote como natureza pública na lista e no detalhe (serializers explícitos lote/quadra/loteamento), chaves de todo objeto público travadas por teste de igualdade exata e galeria servida pela API começando pela capa; 301 testes Django verdes.**

## Escolhas (Task 2, checkpoint já respondido pelo usuário)

**Resposta registrada: `opcao-a`** — manter `empresa_id` no `CorretorPublicoSerializer` da W02 (que também alimenta `GET /api/publico/corretores/<id>/`) e registrar como PENDENTE para a frente web. W02 e seus testes ficaram intocados.

**Lista real de campos de `corretor_responsavel` que qualquer visitante recebe SEM TOKEN** (conferida em `Web/contas/api/serializers.py` + `Usuario.dados_perfil_publico`; sem divergência do plano):

`id`, `empresa_id`, `nome`, `foto`, `email`, `creci`, `telefone`, `whatsapp`, `apresentacao`

(contato = email, telefone, whatsapp, creci, apresentacao; `empresa_id` é o id interno; para corretor autônomo, creci/foto/telefone/whatsapp/apresentacao herdam da Empresa quando vazios.)

O conjunto de chaves final de `corretor_responsavel` está travado no teste (`VitrineAllowlistExataTests.CHAVES_CORRETOR`) com comentário apontando a pendência.

**LGPD (PENDENTE, adiado):** revisão de exposição de contato do corretor, §11.5 g — decisão da frente web/produto, adiada (CONTEXT, Deferred); o app exibe só nome e foto (D-16). Nenhuma opção desta fase remove contato. O plano 05-18 deve registrar em contrato, como PENDENTE: (1) a lista acima, (2) `empresa_id` no payload público e (3) a revisão LGPD.

## Git (política opcao-a + app-a de 05-01)

- API (`../imoveis-aqui`, `feat/APP05`): **nenhum commit** neste plano; as mudanças estão no working tree (4 arquivos modificados + `Web/empresas/management/` untracked pré-existente, intocado). Nunca push.
- App: nenhum código; só este SUMMARY e STATE/ROADMAP (docs do GSD).

## Accomplishments

- `vitrine.py`: `LOTE`, `When(natureza=LOTE, then=F("lote__area"))` em `area_anuncio`; cidade/bairro já vinham do endereço do Imóvel (o lote não tem endereço próprio, `Loteamento.cidade` é ignorada — provado com loteamento em Campinas e imóvel em São Paulo).
- `serializers.py`: `LoteamentoPublicoSerializer`, `QuadraPublicaSerializer`, `LotePublicoSerializer` (ModelSerializer, `fields` um a um, sem herdar os do painel; sem `vendido`, preço, ids, cidade); `LOTE` em `SERIALIZER_PUBLICO_POR_NATUREZA`; campo `lote` + `get_lote` no detalhe (depois de `apartamento`).
- `views.py`: `lote__quadra__loteamento` no `select_related` (detalhe fixo em 3 consultas) e `Prefetch("fotos", FotoImovel.objects.order_by("-capa", "ordem", "id"))`.
- `tests.py`: `VitrineLoteTests` (7), `VitrineAllowlistExataTests` (5), `VitrineFotosCapaTests` (4), helpers `criar_lote_da_vitrine` e `publicar_lote_da_vitrine`; `CHAVES_PROIBIDAS` + vendido/situacao/documentos/historico; o lote entra nas respostas de `VitrineSemTokenESemVazamentoTests` (chaves e valores internos, `LOTE-INTERNO`).

## Task Commits

1. **Task 1 (tracer)** — lote na lista e no detalhe; sem commit (opcao-a). Gate do tracer: modo `end-of-phase` com `<verify>` só automatizado — `VitrineLoteTests` e app `imoveis` inteiro (230 testes) verdes, seguiu para a Task 3.
2. **Task 2 (checkpoint:decision)** — respondida pelo usuário: `opcao-a`. Sem commit.
3. **Task 3 (auto, tdd)** — allowlist exata + capa primeiro; RED confirmado (3 falhas antes do `Prefetch`), depois GREEN; sem commit (opcao-a).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Nome do helper de teste do lote**
- **Found during:** Task 1
- **Issue:** o plano pede `criar_lote(imovel, empresa, cidade, **extra)`, mas `criar_lote(imovel, quadra, **extra)` já existe em `tests.py` (W08) e é usado por `LoteamentoModelTests`/`ApiLoteamentoTests`.
- **Fix:** helper novo chama `criar_lote_da_vitrine(imovel, empresa, cidade, **extra)` (cidade = do loteamento); mais `publicar_lote_da_vitrine(teste)` para reuso entre as classes.
- **Files modified:** Web/imoveis/tests.py

**2. [Rule 1 - Consequência do comportamento novo] Teste existente de ordem das fotos**
- **Found during:** Task 3
- **Issue:** `VitrineDetalheTests.test_detalhe_da_casa` esperava `capa == [False, True]` (ordem por `ordem`); com a capa primeiro vira `[True, False]`.
- **Fix:** expectativa atualizada com comentário (regra A-02).
- **Files modified:** Web/imoveis/tests.py

**3. [Rule 3 - Contagem de consultas] 3 consultas, não 4**
- O teste de N+1 do detalhe do lote usa `assertNumQueries(3)` (imóvel com todos os joins, fotos, características — o corretor já vem do `select_related`); o rascunho do teste tinha 4 por engano.

Linhas do plano "commit ... (opcao-b)" ignoradas conforme a política (opcao-a).

## Known Stubs

Nenhum.

## Threat Flags

Nenhum — superfície nova (bloco `lote`) coberta pelo threat model (T-05-02-01/03/04/05) e travada por testes de chaves exatas; T-05-02-02 mitigado pela decisão informada (opcao-a) e pela pendência LGPD registrada acima.

## Verificação

- `VitrineLoteTests`, `VitrineAllowlistExataTests`, `VitrineFotosCapaTests`, `VitrineSemTokenESemVazamentoTests`: OK.
- `manage.py test --noinput` (SQLite em memória): 301 testes OK; `makemigrations --check --dry-run`: sem mudanças.
- Banco de dev / `Web/.env` não tocados nem lidos; `.gitignore` intocado.

## Self-Check: PASSED

- `class LotePublicoSerializer(serializers.ModelSerializer)`, `class QuadraPublicaSerializer`, `class LoteamentoPublicoSerializer`, `Imovel.Natureza.LOTE: LotePublicoSerializer` e `def get_lote` presentes em `Web/imoveis/api/serializers.py`; `lote__area` em `vitrine.py`; `lote__quadra__loteamento` e `order_by("-capa", "ordem", "id")` em `api/views.py`.
- `class VitrineAllowlistExataTests`, `class VitrineFotosCapaTests`, `"vendido"` em `CHAVES_PROIBIDAS` e o conjunto literal do lote presentes em `Web/imoveis/tests.py`.
- Repo da API sem commits novos desde `0592176`.
