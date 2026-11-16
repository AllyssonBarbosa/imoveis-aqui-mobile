# Phase 6: Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-16
**Phase:** 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
**Areas discussed:** Quais canais mostrar, Layout na página, Perfil do corretor, API e falhas

---

## Quais canais mostrar

| Option | Description | Selected |
|--------|-------------|----------|
| API expõe no detalhe | `canais_contato` no GET do detalhe via `canais_disponiveis()` da W11 | ✓ |
| Mostrar sempre os 3 | Sem mudar a API; o 400 avisa depois do toque | |
| Deduzir dos dados do corretor | Repete no app a regra de fallback para a empresa; quebra a F5/D-16 | |

**User's choice:** API expõe no detalhe

| Option | Description | Selected |
|--------|-------------|----------|
| Esconde a área de contato | Segue a F4/D-14 | ✓ |
| Mostra aviso | "Contato indisponível no momento" | |

**User's choice:** Esconde a área de contato

| Option | Description | Selected |
|--------|-------------|----------|
| Não, só no detalhe | Card da vitrine não muda | ✓ |
| Sim, também na lista | WhatsApp no ImovelCard | |

**User's choice:** Só no detalhe

---

## Layout na página

| Option | Description | Selected |
|--------|-------------|----------|
| Barra fixa: preço + WhatsApp + ⋮ | ⋮ abre bottom sheet com Ligar/E-mail | ✓ |
| Barra fixa com os 3 botões | Sem preço, ícones lado a lado | |
| Seção no corpo, sem barra | Botões na seção do corretor, no fim da página | |

**User's choice:** Barra fixa: preço + WhatsApp + ⋮

| Option | Description | Selected |
|--------|-------------|----------|
| Promove o próximo canal | Ordem WhatsApp → Telefone → E-mail | ✓ |
| Botão "Contato" genérico | Abre o bottom sheet | |

| Option | Description | Selected |
|--------|-------------|----------|
| Mesmo preço do topo/card | Reaproveita a formatação existente | ✓ |
| Barra sem preço | Só botões | |

| Option | Description | Selected |
|--------|-------------|----------|
| Só depois do detalhe | Canais vêm no detalhe | ✓ |
| Desde a prévia, desabilitada | Botão desabilitado até carregar | |

---

## Perfil do corretor

| Option | Description | Selected |
|--------|-------------|----------|
| Só quando veio de um imóvel | Mesmo POST por imóvel; sem imóvel, sem botão | ✓ |
| Novo endpoint por corretor | Exige mudar o model `Contato` da W11 | |
| Sempre, sem registrar | Quebra os critérios 4/5 e a F5/D-16 | |

| Option | Description | Selected |
|--------|-------------|----------|
| Componente isolado + avisar | Widget + Cubit reutilizáveis; pluga no stub atual | ✓ |
| Basear na feat/APP07 | Branch não mergeada, com mocks antigos | |
| Deixar o perfil para depois | Critério 1 pela metade | |

**Notes:** O usuário avisa o Allysson (APP 07).

| Option | Description | Selected |
|--------|-------------|----------|
| Mesma barra fixa, sem preço | "Sobre: <título do imóvel>" | ✓ |
| Botões no corpo, sob o nome | Estilo cartão de visita | |

---

## API e falhas

| Option | Description | Selected |
|--------|-------------|----------|
| feat/APP06 local: main + WEB-11 | Sem push sem OK (F5/D-03) | ✓ |
| Esperar a WEB-11 entrar na main | Fica parado esperando | |

| Option | Description | Selected |
|--------|-------------|----------|
| Loading no botão + SnackBar | Mensagens por tipo (rede/5xx, 400, 404, 429) | ✓ |
| Diálogo de erro | AlertDialog com "Tentar de novo" | |

| Option | Description | Selected |
|--------|-------------|----------|
| SnackBar, sem desfazer | Registro fica | ✓ |
| Checar antes do POST | canLaunchUrl só no esquema; `<queries>` no Android 11+ | |

---

## Claude's Discretion

- Nomes de classes, arquivos e estados; ícones e rótulos (confirmados no human-check).
- Encaixe da barra no `Scaffold`.
- Validação do esquema do link recebido (https wa.me / tel / mailto).
- Throttle no POST público da W11 (hoje sem `throttle_classes`), a avaliar na pesquisa.
- Mapeamento do 400 `{"canal": [...]}` → `Failure`.

## Deferred Ideas

- WhatsApp direto no card da vitrine.
- Contato pelo perfil sem imóvel (endpoint por corretor).
- Encaixar o componente na tela do APP 07 depois do merge.
