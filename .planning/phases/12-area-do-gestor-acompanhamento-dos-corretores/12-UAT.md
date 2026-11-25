---
status: complete
phase: 12-area-do-gestor-acompanhamento-dos-corretores
source: [12-VERIFICATION.md]
started: 2026-11-25T22:45:00Z
updated: 2026-11-25T22:58:52.144Z
---

## Current Test

[testing complete]

## Tests

Pré-requisito (feito em 2026-11-25 pelo Allysson, Task 4 do 12-09): o gestor `gestor.vitrine.demo@example.com` (senha `Teste12345`) existe na "Imobiliária Vitrine Demo (dev)" e o `seed_demo` rodou no Postgres. Roteiro completo no 12-09-SUMMARY.md; itens de verificação humana no 12-VERIFICATION.md.

### 1. Corretor cai no "Meu acervo" e muda a situação de um imóvel
expected: Na vitrine, tocar "Entrar" e entrar com e-mail `corretor.vitrine.demo@example.com` e senha `Teste12345` → cai no "Meu acervo", nunca na Área do gestor. Abrir um imóvel DISPONÍVEL, "Mudar situação" → Reservado, observação "Teste APP-12", confirmar. Tocar Sair e confirmar.
result: pass

### 2. Gestor abre a Área do gestor e os números batem com o site
expected: Tocar "Entrar" e entrar com e-mail `gestor.vitrine.demo@example.com` e senha `Teste12345` → abre a "Área do gestor" (título e Sair na barra de cima) com as 4 seções nesta ordem: Totais da empresa por situação, Acervo por corretor, Contatos por corretor, Mudanças de situação — últimos 7 dias. O Acervo por corretor mostra "Corretor Vitrine Demo" e "Corretor Desativado Demo (desativado)", e o rodapé "Total: N imóveis" é o mesmo N dos totais. A mudança do teste 1 aparece em Mudanças de situação com "Corretor Vitrine Demo" e a observação "Teste APP-12". No navegador, entrar no painel do site com e-mail `gestor.vitrine.demo@example.com` e senha `Teste12345`: em Relatórios → Acervo, a linha "Total" (Disponível, Reservado, Vendido, Alugado e total) bate com os 4 blocos e o "Total: N imóveis" do app; em Relatórios → Contatos ("Todo o período."), os "Contatos" e o "Aguardando retorno" de cada corretor e a linha Total batem com a seção Contatos por corretor do app.
result: pass

### 3. Chip "Período" recarrega só os contatos
expected: Na seção Contatos por corretor, tocar o chip "Período": abre o seletor em português; escolher um intervalo → só esta seção recarrega, o chip mostra as datas e aparece a linha "Período: ... a ...."; o "x" volta para "Todo o período.".
result: pass

### 4. Voltar e reabrir pelo botão do topo
expected: Voltar (gesto ou botão) → vitrine; o botão do topo continua "Meu acervo"; tocar nele → Área do gestor de novo, recarregando as 4 seções.
result: pass

### 5. Gestor de outra empresa vê só a própria empresa
expected: Tocar Sair na Área do gestor, confirmar, tocar "Entrar" e entrar com e-mail `gestor@demo.com` e senha `SenhaForte123` → a Área do gestor mostra só a "Imobiliaria Demo" (Corretor Demo, DEMO-CASA-01), nada da empresa da vitrine.
result: pass

### 6. Administrador fica no aviso
expected: Tocar Sair, confirmar, tocar "Entrar" e entrar com e-mail `admin@imoveisaqui.com` e senha `TrocarSenha123` → tela "Área do administrador" com "A área do administrador não está no app." e o botão Sair.
result: pass

### 7. Visual da Área do gestor
expected: Verde e branco do tema; blocos 2×2 dos totais legíveis; cada seção num cartão; nomes e títulos longos quebram sem estourar; textos no singular ("1 imóvel", "1 contato", "último dia"); aceitar ou não que o 403 ("Só o gestor da imobiliária pode ver estes números.") mantenha o botão "Tentar de novo".
result: pass

### 8. Proibições (revisão humana)
expected: A `feat/APP12` dos dois repositórios continua só local (sem push, PR ou merge); `.claude/CLAUDE.md` sem mudança; o script `criar_gestor_vitrine.py` ficou fora dos repositórios (em `C:\Users\allys\OneDrive\Área de Trabalho`).
result: pass

## Summary

total: 8
passed: 8
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
