# Phase 5: Imóveis Real — Endpoint Público e Integração Final - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-29
**Phase:** 05-im-veis-real-endpoint-p-blico-e-integra-o-final
**Areas discussed:** Direção geral (pré-discussão), Branches da API, Filtros sem par na API, Detalhe e corretor, Destino dos mocks

---

## Direção geral (pré-discussão)

Contexto: WEB 07 concluída em `origin/feat/web-07`; a API pública já existe em `origin/WEB-09` (colega), divergente do contrato da Fase 1 e sem `lote`; nada mergeado na `main`.

| Option | Description | Selected |
|--------|-------------|----------|
| Adaptar o app à API real | Web é dona do dado; reescrever Models/DataSources | ✓ |
| Pedir alinhamento à equipe web | Levar a tabela de divergências | |
| Meio-termo | Adaptar a maior parte, pedir só o crítico | |

| Option | Description | Selected |
|--------|-------------|----------|
| Eu faço na API (lote) | Branch própria juntando web-07 e WEB-09 | ✓ |
| Pedir à Palloma/equipe | | |
| Deixar lote para depois | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fase 5 completa via GSD | discuss → plan → execute | ✓ |
| Só detalhe via quick | | |
| Direto, sem GSD | | |

---

## Branches da API

| Option | Description | Selected |
|--------|-------------|----------|
| Nova branch de WEB-10 + merge web-07 | | |
| Esperar a main | | |
| web-07 + cherry-pick W09 | | |

**User's choice:** "realize o merge e siga o trabalho, WEB10 acho que não foi feito ainda" → seguido de:

| Option | Description | Selected |
|--------|-------------|----------|
| WEB-09 + web-08 | Traz W07+W08; vitrine usa disponível+publicado | ✓ |
| WEB-09 + só web-07 | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Branch feat/APP05 local, sem push | | ✓ |
| Branch + push + PR | | |

| Option | Description | Selected |
|--------|-------------|----------|
| /cidades/ da W09 | Lista simples, regra "tem imóvel publicado" | ✓ |
| A do usuário (cursor) | | |
| A do usuário com regra da W09 | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Seguir o `next` da resposta | | ✓ |
| Calcular ?page=N no app | | |

---

## Filtros sem par na API

| Option | Description | Selected |
|--------|-------------|----------|
| Estender a API para CSV (natureza/bairro) | | ✓ |
| Simplificar o app para valor único | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Criar endpoints públicos de bairros e características | | ✓ |
| Manter opções mockadas | | |

| Option | Description | Selected |
|--------|-------------|----------|
| App usa características {id, nome} | | ✓ |
| API aceita nomes | | |

---

## Detalhe e corretor

| Option | Description | Selected |
|--------|-------------|----------|
| Aceitar o que a API manda; app mostra nome+foto | | ✓ |
| Enxugar serializer do detalhe | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Manter stub de perfil com dados do detalhe | | ✓ |
| Buscar perfil real | | |

| Option | Description | Selected |
|--------|-------------|----------|
| App segue a API (remove/renomeia campos) | | ✓ |
| Pedir à web para expor campos | | |

---

## Destino dos mocks

| Option | Description | Selected |
|--------|-------------|----------|
| Remover do app; fixtures de wire para test/ | | ✓ |
| Manter mocks via --dart-define=USAR_MOCK | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Estender semear_vitrine_dev | | ✓ |
| Cadastrar pelo painel à mão | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Bloco lote = contrato F4 ajustado ao model W07 | | ✓ |
| Só dados do lote | | |

---

## Claude's Discretion

- Fatiamento/ordem dos planos; mapeamento de ordenação; tratamento de `count`; erros 400; resolução de conflitos W08×W09; `corretor_responsavel: null`.

## Deferred Ideas

- Perfil completo do corretor; botão WhatsApp (APP 06); revisão LGPD do contato do corretor; PR/merge na main; WEB-10.
