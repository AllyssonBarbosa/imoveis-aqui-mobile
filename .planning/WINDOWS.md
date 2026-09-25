---
schema_version: 1
open_count: 2
waived_count: 0
fixed_count: 0
total_count: 2
last_updated: 2026-09-25T20:15:45.158Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md |  | Human-check: verificação visual real do endpoint /api/publico/cidades/ contra Postgres do usuário e Host 10.0.2.2 — requer credenciais do usuário, consolidado no UAT de fim de fase | open |  | 2026-09-25T20:15:37.658Z |  |
| 2 | 02 | unrun-verify | .planning/phases/02-vitrine-lista-busca-e-ordena-o/02-02-PLAN.md |  | Human-check: revisão de git diff/status no repo irmão imoveis-aqui (branch feat/APP02) e autorização explícita do usuário para o commit lá | open |  | 2026-09-25T20:15:45.158Z |  |

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
  }
]
````
