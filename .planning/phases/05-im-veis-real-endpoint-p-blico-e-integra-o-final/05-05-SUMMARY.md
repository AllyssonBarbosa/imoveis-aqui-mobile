---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 05
subsystem: api
tags: [django, management-command, seed, vitrine, migrate, pillow]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-01 (merge W05..W08, migrações 0005/0006), 05-02 (lote na vitrine), 05-04 (bairros, características, CSV)"
provides:
  - "semear_vitrine_dev completo e idempotente: 36 imóveis das 4 naturezas nas 4 cidades (Campinas 24), fotos JPEG do Pillow, DEBUG-only"
  - "SemearVitrineDevTests: seed -> vitrine pública real, idempotência, retomada, guarda de DEBUG, senha inutilizável"
  - "Web/.env.example com 10.0.2.2 em ALLOWED_HOSTS"
  - "README da API com a nota Seed de desenvolvimento"
  - "Banco de dev do Web/.env migrado até imoveis.0006 (autorizado pelo usuário)"
affects: [05-06, 05-07, 05-18]

plan_head_before: 2e216734277f768980ed5f4a3414d8198a7b74fb
actuals:
  tokens: 22000
  tasks: 3
  commits: 0   # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): plano sem código no app. Repo da API: nenhum commit (opcao-a); mudanças no working tree.

tech-stack:
  added: []
  patterns:
    - "Seed por chave natural: imóvel por (empresa, código), prédio por (empresa, nome), loteamento por (empresa, nome), quadra por (loteamento, identificação), característica por nome, corretor por e-mail"
    - "Cada imóvel nasce numa transação única (endereço, imóvel, bloco da natureza, características, fotos, publicar): execução interrompida é retomada rodando de novo"
    - "Naturezas intercaladas na ordem de criação: as 4 aparecem entre os 20 mais recentes (primeira página de recentes)"

key-files:
  created:
    - ../imoveis-aqui/Web/empresas/management/__init__.py
    - ../imoveis-aqui/Web/empresas/management/commands/__init__.py
    - ../imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py
  modified:
    - ../imoveis-aqui/Web/empresas/tests.py
    - ../imoveis-aqui/Web/.env.example
    - ../imoveis-aqui/README.md

key-decisions:
  - "Imóvel que já existe é pulado inteiro pelo seed (nem fotos nem situação são mexidas): é isso que mantém o imóvel DEV-CAMPINAS-11 sem foto entre execuções e respeita edições feitas depois"
  - "Apartamento fica sem endereço próprio (usa o do prédio), como no cadastro real; lote leva o endereço do imóvel e Loteamento.cidade igual a ele"
  - "Teste da guarda de DEBUG numa classe separada com banco vazio: numa base já semeada, o seed idempotente também 'não criaria nada' e o teste não provaria a guarda"

requirements-completed: []

coverage:
  - id: D1
    description: "Seed põe as 4 naturezas no ar em Campinas e a vitrine pública real as entrega (lista + detalhe com o bloco da natureza; lote com quadra e loteamento)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/empresas/tests.py#SemearVitrineDevTests.test_vitrine_de_campinas_entrega_as_quatro_naturezas_com_o_bloco_preenchido"
        status: pass
    human_judgment: false
  - id: D2
    description: "Campinas > 20 imóveis, 4 naturezas entre os 20 mais recentes, segunda página; demais cidades com 4 (uma de cada natureza); três finalidades; 2 prédios e 1 loteamento com 2 quadras"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/empresas/tests.py#SemearVitrineDevTests"
        status: pass
    human_judgment: false
  - id: D3
    description: "Idempotência, outra empresa intocada, retomada de execução interrompida, DEBUG=False recusa sem criar nada, senha inutilizável, Loteamento.cidade igual à do endereço"
    requirement: API-07
    verification:
      - kind: unit
        ref: "Web/empresas/tests.py#SemearVitrineDevTests + SemearVitrineDevDebugDesligadoTests"
        status: pass
    human_judgment: false
  - id: D4
    description: "Casos de borda do app entre os 20 mais recentes de Campinas: um sem foto, um com corretor inativo (detalhe com corretor_responsavel null), um com capa na foto de ordem 2"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/empresas/tests.py#SemearVitrineDevTests.test_casos_de_borda_entre_os_20_mais_recentes_de_campinas"
        status: pass
    human_judgment: false
  - id: D5
    description: "Suíte Django inteira (331 testes) verde em SQLite em memória; makemigrations --check sem mudanças"
    verification:
      - kind: integration
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput; manage.py makemigrations --check --dry-run"
        status: pass
    human_judgment: false
  - id: D6
    description: "Banco de dev do Web/.env migrado: imoveis.0005_loteamento_quadra_lote e 0006_situacao_historico_documentos aplicados"
    verification:
      - kind: other
        ref: "manage.py showmigrations imoveis (depois do migrate: 0001..0006 todas [X])"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 05: Seed de desenvolvimento e migração do banco de dev Summary

**`semear_vitrine_dev` agora semeia 36 imóveis (4 naturezas, 4 cidades, Campinas com 24) idempotentes e testados contra a vitrine pública real, e o banco de dev do Web/.env foi migrado até `imoveis.0006`.**

## Git (política opcao-a + app-a de 05-01)

- API (`../imoveis-aqui`, `feat/APP05`): **nenhum commit** (último continua `0592176`). Mudanças no working tree, em cima das de 05-01/05-02/05-04, que ficaram intactas. `Web/empresas/management/` continua untracked: está "versionável" (com os dois `__init__.py`, sem `__pycache__`, que o `.gitignore` já cobre), mas não commitado. Nunca push.
- App: nenhum código; só este SUMMARY e STATE/ROADMAP (docs do GSD).
- Linhas do plano "commit ... (opcao-b)" ignoradas conforme a política.

## Accomplishments

- **Seed** (`Web/empresas/management/commands/semear_vitrine_dev.py`): guarda `DEBUG`, marcador `NOME_EMPRESA_DEMO`, 2 corretores (um ativo e um inativo) com `set_unusable_password()` e foto, 1 proprietário com CPF válido, catálogo `CARACTERISTICAS_DEMO` (6), `BAIRROS_POR_CIDADE`, fotos JPEG 800x600 geradas pelo Pillow (nada binário versionado).
- **Acervo**: Campinas 24 imóveis (`DEV-CAMPINAS-01..24`, naturezas intercaladas casa, apartamento, terreno, lote), Valinhos/Vinhedo/Indaiatuba 4 cada (`DEV-<CIDADE>-01..04`). Campinas: 2 prédios, 1 loteamento com 2 quadras; demais cidades: 1 prédio e 1 loteamento com 1 quadra. Total semeado numa base limpa: 36 imóveis, 87 fotos, 9 lotes, 5 quadras, 4 loteamentos, 5 prédios.
- **Códigos por natureza (primeiros de cada)**: casa `DEV-<CIDADE>-01`, apartamento `-02`, terreno `-03`, lote `-04`; em Campinas o ciclo se repete até `-24`.
- **Casos de borda** (todos entre os 20 mais recentes de Campinas): sem foto = `DEV-CAMPINAS-11` (terreno); corretor responsável inativo = `DEV-CAMPINAS-14` (apartamento, detalhe devolve `corretor_responsavel: null`); capa na foto de ordem 2 = `DEV-CAMPINAS-17` (casa, 3 fotos).
- **Finalidades**: VENDA, ALUGUEL e VENDA_E_ALUGUEL em Campinas; lote sempre VENDA (parcelamento só vale para lote à venda).
- **Testes**: 17 em `empresas/tests.py` (`SemearVitrineDevTests` e `SemearVitrineDevDebugDesligadoTests`).
- **`Web/.env.example`**: `ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2` com comentário em português.
- **README da API**: subseção "Seed de desenvolvimento" logo após "Vitrine pública (API)", sem tocar em outras seções.

## Task Commits

1. **Task 1 (tracer, tdd)** — teste RED (`Campinas` ausente de `publico-cidades`), depois GREEN. Sem commit (opcao-a). Gate do tracer: modo `end-of-phase` com `<verify>` só automatizado, reexecutado e verde, seguiu para a Task 2.
2. **Task 2 (auto, tdd)** — RED (7 falhas + 1 erro), depois GREEN (17 testes); seed repetido 3 vezes em SQLite scratch sem mudar nenhuma contagem. Sem commit (opcao-a).
3. **Task 3 (auto)** — README e migrate do banco de dev (abaixo). Sem commit na API (opcao-a).

## Migração do banco de dev (Task 3, [BLOCKING])

**Autorização:** o usuário autorizou o `migrate` no banco de dev do `Web/.env` (repassado pelo coordenador). Nenhuma outra escrita foi feita nesse banco; **o seed não foi rodado nele**. O `Web/.env` nunca foi lido nem impresso.

Primeira tentativa: o Postgres (porta 5433) recusou a conexão, a execução parou e reportou; o usuário subiu o container `imoveis-aqui-db` e a execução foi retomada.

Saída de **antes** (`showmigrations imoveis`):

```
imoveis
 [X] 0001_initial
 [X] 0002_imovel_fotoimovel_imovel_codigo_unico_por_empresa_and_more
 [ ] 0003_casa_terreno_natureza
 [ ] 0004_predio_apartamento
 [ ] 0005_loteamento_quadra_lote
 [ ] 0006_situacao_historico_documentos
```

Pendentes em todos os apps (`showmigrations --plan`): somente as quatro acima (`imoveis.0003` a `0006`); nenhum outro app tinha migração pendente.

`migrate --noinput` aplicou, todas OK: `imoveis.0003_casa_terreno_natureza`, `0004_predio_apartamento`, `0005_loteamento_quadra_lote`, `0006_situacao_historico_documentos`.

Saída de **depois** (`showmigrations imoveis`):

```
imoveis
 [X] 0001_initial
 [X] 0002_imovel_fotoimovel_imovel_codigo_unico_por_empresa_and_more
 [X] 0003_casa_terreno_natureza
 [X] 0004_predio_apartamento
 [X] 0005_loteamento_quadra_lote
 [X] 0006_situacao_historico_documentos
```

`makemigrations --check --dry-run` (SQLite em memória): "No changes detected". O banco de dev **continua sem acervo**: rodar `semear_vitrine_dev` nele é decisão do usuário (planos 05-06/05-07 e a verificação humana dependem disso).

## Deviations from Plan

None - plano executado como escrito. Observação (não é desvio de regra): o plano falava só em 0005/0006 pendentes, mas o banco de dev também estava sem `imoveis.0003` e `0004` (W05/W06); o mesmo `migrate` aplicou as quatro em sequência, sem conflito.

## Known Stubs

Nenhum. O acervo semeado é de demonstração por desenho (D-09), só roda com `DEBUG=True` e o README documenta isso.

## Threat Flags

Nenhum. T-05-05-01 a 05-05-04 mitigados e testados: guarda de `DEBUG` (teste com banco vazio), `set_unusable_password()` em todo usuário (teste de `has_usable_password`), seed só olha `NOME_EMPRESA_DEMO` (teste com empresa, corretor, proprietário e imóvel de mesmo código intocados), `.env` nunca lido e banco de dev só recebeu o `migrate` autorizado.

## Verificação

- `SemearVitrineDevTests` + `SemearVitrineDevDebugDesligadoTests`: 17 testes OK.
- Suíte Django inteira: 331 testes OK (SQLite em memória); `makemigrations --check --dry-run`: sem mudanças.
- Seed em SQLite scratch (`$TMPDIR/imoveis_seed_05.sqlite3`, removido): 3 execuções seguidas, sem erro e com contagens idênticas.
- `grep` do README (`semear_vitrine_dev`, `10.0.2.2`) e do `.env.example`: OK. Nenhum formatador rodado; `.gitignore` intocado.
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- API: `Web/empresas/management/__init__.py`, `commands/__init__.py` e `commands/semear_vitrine_dev.py` existem; o seed contém `set_unusable_password`, `publicar()`, `Loteamento`, `Quadra`, `Lote`, `PIL`, `BAIRROS_POR_CIDADE`, `CARACTERISTICAS_DEMO` e `DEV-`; `Web/empresas/tests.py` contém `class SemearVitrineDevTests` e `publico-vitrine-cidade`; `.env.example` e README contêm `10.0.2.2`.
- Repo da API sem commits novos desde `0592176`; `git status` lista `Web/empresas/management/` como novo, sem `__pycache__`.
