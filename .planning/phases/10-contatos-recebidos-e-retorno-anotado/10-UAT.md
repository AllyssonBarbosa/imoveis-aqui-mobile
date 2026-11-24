---
status: complete
phase: 10-contatos-recebidos-e-retorno-anotado
source: [10-VERIFICATION.md]
started: 2026-11-24T08:40:00Z
updated: 2026-11-24T22:23:12.507Z
---

## Current Test

[testing complete]

## Tests

### 1. Ícones e entrada da caixa "Meus contatos"
expected: A caixa "Meus contatos" abre pelo ícone de caixa de entrada do acervo (tooltip "Meus contatos"); os ícones de canal (WhatsApp, Telefone, E-mail) e o de "sem retorno" são reconhecíveis e coerentes com o Material 3 verde/branco; o voltar retorna ao acervo.
result: pass

### 2. Visual do item e das folhas
expected: O chip "Aguardando retorno" (tertiaryContainer) se destaca dos demais retornos (neutros); títulos de imóvel longos quebram em até 2 linhas sem estourar o layout; a folha "Filtrar por imóvel" (com "Todos os imóveis" e check no escolhido) e a folha "Anotar retorno" (4 opções, check na atual) ficam legíveis e sem corte.
result: pass

### 3. Seletor de período em pt-BR no aparelho
expected: Ao tocar no chip "Período", abre o seletor do Material em português ("Selecione o intervalo", "Salvar"); o intervalo escolhido vira o chip "dd/MM/yyyy – dd/MM/yyyy" e a lista é recarregada pelo servidor; o "x" do chip limpa só o período.
result: pass

### 4. Anotar retorno contra o Django real (inclusive 404 e falha)
expected: Com a API da feat/APP10 rodando, anotar "Falei" num contato mostra o retorno devolvido pelo servidor (com "anotado em") e o número "sem retorno" cai em 1; um 404 (contato que saiu da caixa) mostra "Este contato não está mais na sua caixa." e recarrega lista e número; uma falha de rede mostra "Não foi possível anotar o retorno. Tente de novo.".
result: pass

### 5. Hora do app × hora do site (fuso de Brasília)
expected: Data e hora de um mesmo contato coincidem no app e na caixa do site com o aparelho no fuso de Brasília; em outro fuso podem diferir 1 ou 2 horas (risco aceito A3, §17.7), e o dia usado pelo filtro de período continua sendo o de São Paulo.
result: pass

### 6. Proibições de julgamento (revisão humana)
expected: (a) A feat/APP10 do repo web continua só local, sem push/PR/merge nesta fase; (b) as rotas novas nunca devolvem contato, imóvel ou contagem de outra empresa/corretor — evidência no 10-VERIFICATION.md (branch sem upstream; IsolamentoTests, ResumoSemRetornoTests e OpcoesDeImovelDaCaixaTests verdes; fixture contatos_outra_empresa.json exercitada no teste de contrato).
result: pass

## Summary

total: 6
passed: 6
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
