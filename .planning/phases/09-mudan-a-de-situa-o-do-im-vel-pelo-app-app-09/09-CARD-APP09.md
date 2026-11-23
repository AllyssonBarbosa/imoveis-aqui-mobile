# [APP] 09 · Mudança de situação do imóvel pelo app

> Fonte: Kanban da equipe — https://kanban.repsys.com.br/cards/eb09e705-602e-4e2a-b40e-a2ce5b0f5b6e/ (copiado em 22/11/2026; status "Fazendo", responsável George Lucas dos Santos)

## Descrição

Como corretor, eu quero mudar a situação do imóvel pelo celular para marcar o reservado na hora da conversa, sem esperar chegar ao computador.

A troca entre disponível, reservado, vendido e alugado leva data e observação, e o histórico da mudança aparece na própria tela.

Quem decide é o servidor. O app pede a mudança; se a API recusar, a mensagem é mostrada e a tela não muda de estado por conta própria.

Tarefa A09 do documento de histórias.

## Critérios de aceite (todos obrigatórios)

- [ ] Trocar a situação do imóvel informando data e observação
- [ ] A mudança é feita pela API; o app não altera nada localmente
- [ ] O histórico das mudanças aparece na tela do imóvel
- [ ] Recusa do servidor mostra a mensagem e mantém a situação anterior
- [ ] A vitrine reflete a mudança na consulta seguinte
- [ ] Só o corretor responsável e o gestor da empresa conseguem mudar

## Dependência

- Depende de **[WEB] 08 · Documentos, publicação, situação e histórico** — em **Feito**
