# Phase 10: Contatos Recebidos e Retorno Anotado (APP 10) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-22
**Phase:** 10-contatos-recebidos-e-retorno-anotado
**Areas discussed:** nenhuma interativamente. O Allysson recusou a seleção de áreas e pediu "decida
pelas instruções do card".

---

## Áreas propostas (não discutidas: decididas pelo card)

| Área proposta | Perguntas que ela trazia | Decidido por |
|---------------|--------------------------|--------------|
| Entrada e contagem | Ícone no "Meu acervo" ou abas? O número segue o filtro? Selo no ícone? | Card ("a tela mostra") + título do site → ícone na AppBar do acervo, número total sem filtro, só na caixa (D-01..D-07) |
| Anotar o retorno | Folha ou menu no item? Pode trocar? Espera o servidor? | Site (select por linha, troca permitida) + padrão de folhas do app + regra "estado decidido no Django" (D-14..D-17) |
| Filtro imóvel/período | Chips + folhas? Atalhos de período? | Site (select de imóveis dos contatos visíveis + De/Até) (D-18..D-20) |
| Item da lista | Retorno atual e "anotado em"? Data completa ou relativa? | Tabela do site (`d/m/Y H:i`, rótulos do Django, "anotado em") (D-08..D-11) |

**User's choice:** "decida pela as instruçoes do card"
**Notes:** Igual ao discuss da Phase 8 ("FAÇA TUDO DE ACORDO COM OS DETALHES DA FASE QUE TE MANDEI").
Registrado na memória de feedback: nos próximos discuss-phase, decidir sem perguntar e mostrar as
decisões no fim.

## Claude's Discretion

- Nomes de classes, arquivos e estados; número de Cubits.
- Ícones, cores do chip de retorno, espaçamentos (confirmados no human-check).
- Fuso da data mostrada; tratamento de enum desconhecido; quando carregar as opções do filtro.
- Forma exata da contagem na web (rota própria recomendada, D-06).

## Deferred Ideas

- Caixa do gestor (APP-12); filtro por situação do retorno; selo no ícone do acervo; abrir o imóvel
  a partir do contato; atalhos de período; puxar para atualizar; notificação de contato novo.
