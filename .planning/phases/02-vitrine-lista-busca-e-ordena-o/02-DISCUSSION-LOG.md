# Phase 2: Vitrine — Lista, Busca e Ordenação - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-25
**Phase:** 02-vitrine-lista-busca-e-ordena-o
**Areas discussed:** Card e layout da lista, Busca por texto, Ordenação, Mock de imóveis + cidades via API

---

## Card e layout da lista

**Layout da lista**

| Option | Description | Selected |
|--------|-------------|----------|
| Lista vertical | Um card por linha, foto larga em cima | ✓ |
| Grade de 2 colunas | Mais imóveis por tela, informação apertada | |
| Lista compacta | Miniatura à esquerda, texto à direita | |

**Preço quando VENDA_E_ALUGUEL**

| Option | Description | Selected |
|--------|-------------|----------|
| Os dois, empilhados | Venda e Aluguel/mês em duas linhas | ✓ |
| Só o de venda + selo | Selo "também para alugar" | |
| Depende da ordenação | Preço conforme a ordenação ativa | |

**Formato do preço**

| Option | Description | Selected |
|--------|-------------|----------|
| Moeda BRL completa | "R$ 450.000", aluguel com "/mês" | ✓ |
| Moeda abreviada | "R$ 450 mil" | |
| Com centavos sempre | "R$ 450.000,00" | |

**Sem foto_capa**

| Option | Description | Selected |
|--------|-------------|----------|
| Placeholder com ícone | Caixa verde clara com ícone, mesma proporção | ✓ |
| Card sem área de foto | Card encolhe | |

**User's choice:** todas as opções recomendadas.

---

## Busca por texto

| Question | Options | Selected |
|----------|---------|----------|
| Nome do param | `busca` / `q` / `search` | `busca` |
| Campos buscados | Título + bairro / + descrição / só título | Título + bairro |
| Posição da barra | Fixa abaixo do topo / lupa com SearchAnchor / some ao rolar | Fixa abaixo do topo |
| Debounce e mínimo | 400 ms e 2 letras / 300 ms e 1 / 600 ms e 3 | 400 ms, 2 letras |

**User's choice:** todas as opções recomendadas.

---

## Ordenação

| Question | Options | Selected |
|----------|---------|----------|
| Controle de UI | Botão + bottom sheet / menu suspenso / chips | Botão + bottom sheet |
| Opções e padrão | 5 opções com padrão mais recentes / 3 opções | 5 opções, mais recentes |
| Preço-base | coalesce(venda, aluguel) / venda com nulls last / deixar para o E2 | Venda com nulls last |
| Reset ao trocar | Reinicia do topo / mantém lista até chegar a nova | Reinicia do topo |

**User's choice:** todas as opções recomendadas.

---

## Mock de imóveis + cidades via API

| Question | Options | Selected |
|----------|---------|----------|
| Realismo do mock | Servidor simulado / fixture estática | Servidor simulado |
| Provocar erro/vazio | Gatilhos determinísticos / flag dart-define / falha aleatória | Gatilhos determinísticos |
| Falha de GET /cidades | Erro com retry (remove asset) / cai no asset / cache da última resposta | Erro com retry |
| Base URL | --dart-define com padrão / constante / .env | --dart-define com padrão |

**User's choice:** todas as opções recomendadas.

---

## Claude's Discretion

- Navegação seleção → vitrine, loading (skeleton ou spinner), tamanho de página, layout
  fino do card, mecanismo de troca mock/real no DI, implementação e testes do endpoint
  Django de cidades, formato do param `cidade` no mock (provisório nome+uf).

## Deferred Ideas

- Cache offline da lista de cidades: reavaliar se virar requisito.
- Busca na descrição: reavaliar com dados reais.
