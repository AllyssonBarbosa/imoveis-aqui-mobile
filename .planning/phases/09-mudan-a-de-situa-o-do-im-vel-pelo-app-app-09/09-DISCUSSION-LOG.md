# Phase 9: Mudança de Situação do Imóvel pelo App (APP 09) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-22
**Phase:** 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
**Areas discussed:** Tela do imóvel no acervo, A "data" da mudança, Gestor no app, Fluxo da troca e histórico

---

## Tela do imóvel no acervo

| Option | Description | Selected |
|--------|-------------|----------|
| Tela nova de gestão | Aberta pelo cartão do acervo, para qualquer imóvel; GET /api/imoveis/{id}/ + /historico/ | ✓ |
| Dentro da página pública | Seção extra em abrirDetalheImovel; imóvel reservado sai da vitrine | |
| Folha inferior no cartão | Troca direto no cartão; histórico escondido | |

| Option (toque no cartão) | Description | Selected |
|--------|-------------|----------|
| Todo cartão abre a gestão | "Ver na vitrine" dentro da tela só com na_vitrine=true | ✓ |
| Só os cartões "Seu" | Os da imobiliária mantêm o comportamento atual | |

| Option (conteúdo) | Description | Selected |
|--------|-------------|----------|
| Só o cabeçalho | Foto, código, título, preço, situação + desde, botão, histórico | ✓ |
| Dados completos do imóvel | Endereço, descrição, detalhes por natureza | |

| Option (botão) | Description | Selected |
|--------|-------------|----------|
| Só quando pode_mudar_situacao | Booleano do Django; recusa ainda mostra a mensagem | ✓ |
| Sempre, o servidor recusa | 403 com a mensagem do servidor | |

**User's choice:** todas as recomendadas.

---

## A "data" da mudança

| Option | Description | Selected |
|--------|-------------|----------|
| Data automática do servidor | alterado_em, igual ao site; "Data: hoje" informativo | ✓ |
| Corretor informa a data | Campo novo + migração no Django | |

| Option (observação) | Description | Selected |
|--------|-------------|----------|
| Opcional, como no servidor | Mesma dica do SituacaoForm | ✓ |
| Obrigatória | Só se o Django passar a exigir | |

---

## Gestor no app

| Option | Description | Selected |
|--------|-------------|----------|
| Continua no aviso | AC-6 garantido pelo servidor; gestor usa o site; APP-12 depois | ✓ |
| Abrir o mínimo para o gestor | Lista via /api/gestao/imoveis/ + mesma tela | |

| Option (repo web) | Description | Selected |
|--------|-------------|----------|
| Só se faltar algo | Pesquisa confere rotas e testes; feat/APP09 na web se precisar | ✓ |
| Nenhum, só o app | Lacuna vira pendência para o colega | |

---

## Fluxo da troca e histórico

| Option (formulário) | Description | Selected |
|--------|-------------|----------|
| Folha inferior | Chips de escolha única, observação, "Data: hoje", Confirmar | ✓ |
| Folha + diálogo de confirmação | Um toque a mais | |
| Tela própria | Formulário em tela cheia | |

| Option (resposta) | Description | Selected |
|--------|-------------|----------|
| Folha espera o servidor | Recusa mantém a folha com a mensagem do servidor; sucesso fecha, SnackBar e recarga da API | ✓ |
| Fecha e avisa por SnackBar | Recusa obriga a redigitar | |

| Option (histórico) | Description | Selected |
|--------|-------------|----------|
| Lista simples | De → Para, data/hora · nome, observação; vazio com o texto do site | ✓ |
| Linha do tempo | Widget novo, mais visual | |

| Option (volta ao acervo) | Description | Selected |
|--------|-------------|----------|
| Recarrega da API | Tela devolve "mudou"; acervo refaz a consulta | ✓ |
| Não recarrega | Cartão pode mostrar a situação antiga | |

---

## Claude's Discretion

- Nomes de telas/Cubits/arquivos, título da tela, ícones, primeira carga e erro, puxar para atualizar.
- Carga paralela de imóvel e histórico; achatar mensagens do 400/403.
- UI-SPEC opcional (decisões D-01..D-12 servem de contrato de UI).

## Deferred Ideas

- Área do gestor no app (APP-12).
- Data informada pelo corretor (exigiria mudança no Django).
- Dados completos e edição do imóvel pelo app.
