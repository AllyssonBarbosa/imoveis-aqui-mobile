---
status: testing
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
source: [09-VERIFICATION.md]
started: 2026-11-22T20:30:00Z
updated: 2026-11-22T20:30:00Z
---

## Current Test

number: 1
name: AC-5 ponta a ponta contra o Django real (vitrine reflete a mudança)
expected: |
  Reservar um imóvel `DEV-*` pelo app: ele some da vitrine pública da cidade. Voltar a Disponível pelo app: reaparece na consulta seguinte. O acervo do corretor recarrega com o chip certo.
awaiting: user response

## Tests

### 1. AC-5 ponta a ponta contra o Django real (vitrine reflete a mudança)
expected: Reservado não aparece na vitrine pública; ao voltar a Disponível reaparece; o acervo do corretor recarrega com o chip certo.
result: [pending]

### 2. Recusa real por contrato assinado (`DEMO-CASA-01`, Vendido → Disponível)
expected: A folha continua aberta com a mensagem do servidor sobre o contrato e a observação preservada; a tela segue Vendido.
result: [pending]

### 3. Colega sem permissão (`DEV-CAMPINAS-14`); opcional: POST forçado por curl com o token dele
expected: A tela mostra situação e histórico, sem o botão Mudar situação; o POST forçado recebe 403 com a mensagem do servidor.
result: [pending]

### 4. Visual e comportamento real: Material 3 verde e branco, voltar do iOS e do Android depois de uma mudança, servidor fora do ar no envio, sessão revogada no envio, gestor na tela de aviso (D-07)
expected: Aparência conforme D-01..D-12; o acervo recarrega na volta por qualquer forma de voltar; textos fixos de falha; login com "Sua sessão terminou. Entre de novo."; gestor no aviso.
result: [pending]

### 5. Decisões abertas: push das duas `feat/APP09` (app e web) e pedido do `max_length` da observação à equipe web (L8)
expected: Decisão registrada pelo usuário.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
