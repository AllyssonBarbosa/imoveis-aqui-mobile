# Phase 3: Vitrine — Filtros Server-Side - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-30
**Phase:** 03-vitrine-filtros-server-side
**Areas discussed:** Semântica dos filtros, Modal de filtros, Chips ativos, Fonte das opções

---

## Semântica dos filtros

| Question | Options | Selected |
|----------|---------|----------|
| Quartos/suítes/vagas | Mínimo "N ou mais" (Recomendado) / Exato | Mínimo ✓ |
| VENDA_E_ALUGUEL | Em ambos (Recomendado) / Só em opção própria | Em ambos ✓ |
| preco_min/max compara com | Depende da finalidade (Recomendado) / Venda sempre / Qualquer um dos dois | Depende da finalidade ✓ |
| Características múltiplas | E: tem todas (Recomendado) / OU: tem alguma | E ✓ |
| Natureza e bairro | Multi-seleção, OU entre valores (Recomendado) / Um valor só | Multi OU ✓ |
| Formato multivalor | CSV (Recomendado) / Params repetidos / Você decide | CSV ✓ |

**User's choice:** todas as recomendadas.

---

## Modal de filtros

| Question | Options | Selected |
|----------|---------|----------|
| Onde abre | Bottom sheet tela cheia (Recomendado) / Tela própria | Bottom sheet ✓ |
| Quando aplica | Rascunho + Aplicar explícito (Recomendado) / Ao vivo | Rascunho + Aplicar ✓ |
| Faixas preço/área | Dois campos mín/máx (Recomendado) / RangeSlider / Faixas predefinidas | Campos ✓ |
| Quartos/suítes/vagas | ChoiceChips Qualquer,1+..4+ (Recomendado) / Stepper | ChoiceChips ✓ |
| Finalidade/natureza | SegmentedButton + FilterChips (Recomendado) / Tudo FilterChips | SegmentedButton + FilterChips ✓ |
| Min > max | Erro inline + Aplicar desabilitado (Recomendado) / Trocar automaticamente | Erro inline ✓ |
| Trocar finalidade com preço | Limpa faixa (Recomendado) / Mantém | Limpa ✓ |
| Trocar cidade | Mantém gerais, limpa bairros (Recomendado) / Limpa tudo / Mantém tudo | Mantém gerais, limpa bairros ✓ |

**User's choice:** todas as recomendadas.

---

## Chips ativos

| Question | Options | Selected |
|----------|---------|----------|
| Posição | Mesma linha [Filtros (3)] [Ordenar] + chips roláveis abaixo (Recomendado) / Tudo numa linha rolável | Mesma linha + chips abaixo ✓ |
| Granularidade | Um chip por filtro, resumido (Recomendado) / Um chip por valor | Por filtro ✓ |
| Toque / "x" | "x" remove e reconsulta; toque abre modal (Recomendado) / Só "x" | "x" + toque abre ✓ |
| Limpar tudo | Fim da linha de chips + rodapé do modal (Recomendado) / Só no modal | Ambos ✓ |

**User's choice:** todas as recomendadas.

---

## Fonte das opções

| Question | Options | Selected |
|----------|---------|----------|
| Origem bairros/características | Endpoints de opções no contrato, mock agora (Recomendado) / Características real já, bairros mock / Listas fixas no app | Endpoints + mock ✓ |
| Escolha de bairro | Checkboxes + campo de filtrar lista (Recomendado) / FilterChips em Wrap / Texto livre | Checkboxes ✓ |
| Sem resultado com filtros | Estado próprio + Limpar filtros (Recomendado) / Reusar semResultado | Estado próprio ✓ |
| Persistência | Só sessão (Recomendado) / shared_preferences | Só sessão ✓ |

**User's choice:** todas as recomendadas.

---

## Claude's Discretion

- Modelagem de `FiltrosVitrine` e do rascunho do sheet.
- Formato numérico dos valores de faixa enviados e a conversão da máscara.
- Loading e erro das opções dentro do sheet, e o momento de carregar essas opções.
- Layout fino do sheet e rótulos e abreviações dos chips.
- Forma exata dos endpoints de opções no adendo ao contrato.

## Deferred Ideas

- "Ver N imóveis" (v2, API-05).
- Endpoints reais de opções (Fase 4).
- Persistir filtros entre aberturas.
- RangeSlider com limites vindos do servidor.
