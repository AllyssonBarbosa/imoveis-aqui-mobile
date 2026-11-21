---
phase: 08
review: 08-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "\"Sair\" e \"sessão expirada\" usam `isFirst` e levam ao priming no primeiro uso, não à vitrine"
  - id: WR-02
    severity: warning
    disposition: open
    title: "\"Sair\" pode ficar até 10 s sem feedback; o comentário promete 5 s"
  - id: WR-03
    severity: warning
    disposition: open
    title: "A salvaguarda T-08-49 (re-descartar a sessão local após falha ao apagar) não existe no código"
  - id: WR-04
    severity: warning
    disposition: open
    title: "Limite de login por e-mail permite bloquear a conta alheia e conta logins bem-sucedidos"
  - id: WR-05
    severity: warning
    disposition: open
    title: "Os limites de taxa dependem do cache padrão (LocMem) e não valem entre workers"
  - id: WR-06
    severity: warning
    disposition: open
    title: "`next` absoluto montado pela requisição quebra a paginação do app atrás de proxy TLS"
  - id: WR-07
    severity: warning
    disposition: open
    title: "`SECRET_KEY` com valor padrão inseguro e `DEBUG` desligado por padrão"
  - id: IN-01
    severity: info
    disposition: open
    title: "Impossible-state guard — `on SessaoExpiradaException` direto nos repositórios"
  - id: IN-02
    severity: info
    disposition: open
    title: "Token no Keychain/Keystore sobrevive à reinstalação no iOS"
  - id: IN-03
    severity: info
    disposition: open
    title: "Token de API não expira e é único por usuário"
  - id: IN-04
    severity: info
    disposition: open
    title: "403 no acervo e na entrada da área vira \"Tentar de novo\" eterno"
  - id: IN-05
    severity: info
    disposition: open
    title: "Script de captura anuncia revogação de tokens que não faz e segue qualquer URL"
open: 12
total: 12
recorded: 2026-11-21T15:45:47.955Z
---

# Phase 08: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | open | - |
| WR-07 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
