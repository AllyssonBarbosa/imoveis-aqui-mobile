---
status: complete
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
source: [09-VERIFICATION.md]
started: 2026-11-22T20:30:00Z
updated: 2026-11-23T21:30:00Z
---

## Current Test

[testing complete]

## Tests

### 1. AC-5 ponta a ponta contra o Django real (vitrine reflete a mudança)
expected: Reservado não aparece na vitrine pública; ao voltar a Disponível reaparece; o acervo do corretor recarrega com o chip certo.
result: pass
verified_by: claude — Django feat/APP09 real (SQLite isolado, semear_vitrine_dev + seed_demo) via as mesmas rotas do app; lado do app coberto por flutter test (1442 passando). Sem toque na UI.
evidence: DEV-CAMPINAS-01 POST RESERVADO 200 → some da vitrine pública de Campinas (24→23); POST DISPONIVEL 200 → reaparece (24); acervo devolve (RESERVADO, na_vitrine=False) e depois (DISPONIVEL, True); histórico com 2 entradas na ordem do servidor, autor e observação.

### 2. Recusa real por contrato assinado (`DEMO-CASA-01`, Vendido → Disponível)
expected: A folha continua aberta com a mensagem do servidor sobre o contrato e a observação preservada; a tela segue Vendido.
result: pass
verified_by: claude — API real + flutter test; a folha aberta com observação preservada é coberta pelos testes de widget, não vista na tela.
evidence: DEMO-CASA-01 POST DISPONIVEL → 400 {"situacao":["Este imóvel tem um contrato assinado (#1): a situação não pode ser mudada à mão enquanto o contrato estiver valendo."]}; continua VENDIDO.

### 3. Colega sem permissão (`DEV-CAMPINAS-14`); opcional: POST forçado por curl com o token dele
expected: A tela mostra situação e histórico, sem o botão Mudar situação; o POST forçado recebe 403 com a mensagem do servidor.
result: pass
verified_by: claude — API real + flutter test (botão escondido por pode_mudar_situacao).
evidence: DEV-CAMPINAS-14 detalhe 200 com pode_mudar_situacao=false, histórico 200; POST forçado com token do corretor vitrine → 403 "Só o corretor responsável por este imóvel ou o gestor podem mudar a situação." Extras: sem token 401, outra empresa 404, mesma situação 400 "O imóvel já está disponível."

### 4. Visual e comportamento real: Material 3 verde e branco, voltar do iOS e do Android depois de uma mudança, servidor fora do ar no envio, sessão revogada no envio, gestor na tela de aviso (D-07)
expected: Aparência conforme D-01..D-12; o acervo recarrega na volta por qualquer forma de voltar; textos fixos de falha; login com "Sua sessão terminou. Entre de novo."; gestor no aviso.
result: pass
verified_by: usuário no emulador Android (API 36) contra o Django feat/APP09 real
evidence: visual Material 3 verde e branco ok; voltar pelo botão do Android recarrega o acervo com o chip novo; servidor derrubado no envio → "Não foi possível mudar a situação agora. Tente de novo."; token revogado no servidor no envio → login com "Sua sessão terminou. Entre de novo."; gestor@demo.com → tela de aviso (D-07).
note: gesto de voltar do iOS não testado — decisão do usuário (projeto acadêmico, baixa importância); Android cobre o fluxo de recarga.

### 5. Decisões abertas: push das duas `feat/APP09` (app e web) e pedido do `max_length` da observação à equipe web (L8)
expected: Decisão registrada pelo usuário.
result: pass
decision: "push das duas: sim" — push das `feat/APP09` (app e web) e merge + push para a main autorizados pelo usuário em 2026-11-23.
note: "max_length: depois" — pedido à equipe web adiado (ver Deferred Follow-Ups).

## Summary

total: 5
passed: 5
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
[none]

## Deferred Follow-Ups

- test: 5
  idea: "max_length: depois — pedir à equipe web um max_length (ex.: 500, igual ao app) em `observacao` no `MudancaSituacaoSerializer` (L8)"
  deferred_at: 2026-11-23
