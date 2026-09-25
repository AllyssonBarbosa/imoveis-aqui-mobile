---
schema_version: 1
open_count: 4
waived_count: 0
fixed_count: 0
total_count: 4
last_updated: 2026-09-25T23:25:43.045Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md |  | Human-check: verificação visual real do endpoint /api/publico/cidades/ contra Postgres do usuário e Host 10.0.2.2 — requer credenciais do usuário, consolidado no UAT de fim de fase | open |  | 2026-09-25T20:15:37.658Z |  |
| 2 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md |  | Human-check: revisão de git diff/status no repo irmão imoveis-aqui (branch feat/APP02) e autorização explícita do usuário para o commit lá | open |  | 2026-09-25T20:15:45.158Z |  |
| 3 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-03-PLAN.md |  | Human-check: fling real ate o fim em Campinas/SP num emulador Android com o dev server Django rodando (spinner do rodape, sem cards repetidos, fim-da-lista) e troca para Indaiatuba/SP mostrando o vazio — consolidado no UAT de fim de fase | open |  | 2026-09-25T20:39:30.587Z |  |
| 4 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-05-PLAN.md |  | Human-check: fim de fase (Django dev server + Android/iOS) — buscar cambui/erro/termo sem resultado e trocar ordenacao (Menor preco/Maior area) em Campinas, incl. confirmar se o botao 'Ordenar' ao lado da busca satisfaz a leitura de D-10 (SearchBar+botao nao cabem lado a lado a 360dp) | open |  | 2026-09-25T23:25:43.045Z |  |

````json
[
  {
    "id": 1,
    "kind": "unrun-verify",
    "phase": "02",
    "file": ".planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md",
    "line": null,
    "description": "Human-check: verificação visual real do endpoint /api/publico/cidades/ contra Postgres do usuário e Host 10.0.2.2 — requer credenciais do usuário, consolidado no UAT de fim de fase",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-09-25T20:15:37.658Z",
    "resolved_at": null
  },
  {
    "id": 2,
    "kind": "unrun-verify",
    "phase": "02",
    "file": ".planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md",
    "line": null,
    "description": "Human-check: revisão de git diff/status no repo irmão imoveis-aqui (branch feat/APP02) e autorização explícita do usuário para o commit lá",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-09-25T20:15:45.158Z",
    "resolved_at": null
  },
  {
    "id": 3,
    "kind": "unrun-verify",
    "phase": "02",
    "file": ".planning/phases/02-vitrine-lista-busca-e-ordena-o/02-03-PLAN.md",
    "line": null,
    "description": "Human-check: fling real ate o fim em Campinas/SP num emulador Android com o dev server Django rodando (spinner do rodape, sem cards repetidos, fim-da-lista) e troca para Indaiatuba/SP mostrando o vazio — consolidado no UAT de fim de fase",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-09-25T20:39:30.587Z",
    "resolved_at": null
  },
  {
    "id": 4,
    "kind": "unrun-verify",
    "phase": "02",
    "file": ".planning/phases/02-vitrine-lista-busca-e-ordena-o/02-05-PLAN.md",
    "line": null,
    "description": "Human-check: fim de fase (Django dev server + Android/iOS) — buscar cambui/erro/termo sem resultado e trocar ordenacao (Menor preco/Maior area) em Campinas, incl. confirmar se o botao 'Ordenar' ao lado da busca satisfaz a leitura de D-10 (SearchBar+botao nao cabem lado a lado a 360dp)",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-09-25T23:25:43.045Z",
    "resolved_at": null
  }
]
````
