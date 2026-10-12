# Phase 4: Página do Imóvel — Galeria e Dados da Natureza - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-12
**Phase:** 04-pagina-do-imovel-galeria-e-dados-da-natureza
**Areas discussed:** Contrato do detalhe, Galeria de fotos, Layout e ordem das seções, Corretor e navegação

---

## Contrato do detalhe

| Pergunta | Opções | Escolha |
|---|---|---|
| Estrutura da natureza | Bloco por tipo / objeto genérico `dados_natureza` / campos planos | Bloco por tipo |
| Prédio e quadra/loteamento | Embutidos completos / só ids + endpoints próprios | Embutidos completos |
| Área livre | Vem pronta da API / app calcula | Vem pronta da API |
| Campos comuns extras | Fotos ordenadas, condomínio/IPTU, descrição/características, corretor/endereço | Todos |

## Galeria de fotos

| Pergunta | Opções | Escolha |
|---|---|---|
| Formato | PageView com "1/N" / bolinhas / foto grande + miniaturas | PageView com "1/N" |
| Toque na foto | Tela cheia com zoom / nada | Tela cheia com zoom |
| Rolagem | SliverAppBar colapsável / galeria fixa | SliverAppBar colapsável |
| Sem fotos | Placeholder da vitrine / esconder galeria | Placeholder da vitrine |

## Layout e ordem das seções

| Pergunta | Opções | Escolha |
|---|---|---|
| Ordem | preços → natureza → descrição → características → corretor / corretor perto do preço | Primeira |
| Barra fixa | Não nesta fase / sim, com preço | Não nesta fase |
| Formato da natureza | Ícones-resumo + pares / só pares | Ícones-resumo + pares |
| Campo nulo | Omitir / "Não informado" | Omitir |

## Corretor e navegação

| Pergunta | Opções | Escolha |
|---|---|---|
| Caminho para o perfil | Tela stub / botão "em breve" / só nome e foto | Tela stub |
| Carga | Prévia da lista + detalhe / loading de tela inteira | Prévia + detalhe |
| Erro | Retry + 404 próprio / erro genérico | Retry + 404 próprio |
| Navegação | Navigator.push / go_router | Navigator.push |

## Claude's Discretion

Ícones, rótulos, formatação de áreas, fixtures do mock, estrutura de pastas.

## Deferred Ideas

Barra fixa com WhatsApp (APP 06), mapa e favoritos (APP 05), perfil real (APP 07), go_router/deep link.
