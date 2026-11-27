# Phase 11: Fotos do Imóvel pela Câmera (APP 11) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-25
**Phase:** 11-fotos-do-im-vel-pela-c-mera-app-11
**Areas discussed:** 8 perguntas respondidas pela Palloma, depois do levantamento dos dois repos.

---

| # | Pergunta | Alternativas | Escolha da Palloma |
|---|----------|--------------|--------------------|
| 1 | Formato da rota | Aninhada `/api/imoveis/{id}/fotos/` · manter `/api/fotos-imovel/` | Aninhada. A antiga **fica como está** (outra tarefa); app e testes novos só na aninhada (D-01) |
| 2 | Reordenar | Lista completa numa chamada · `PATCH` por foto | Lista completa, transação, devolve a lista relida; faltando/repetido/de outro imóvel → 400 (D-02) |
| 3 | Quem pode | Qualquer corretor da empresa · só o responsável · gestor também | Qualquer corretor da empresa, igual ao acervo; gestor fora (D-03) |
| 4 | Capa inicial e capa apagada | Automática · manual; promover · deixar sem capa | Primeira foto vira capa; apagar a capa promove a próxima; apagar fecha a ordem e apaga o arquivo (D-04, D-05) |
| 5 | Teto de fotos | 30 · sem limite | 30; a 31ª → 400 com mensagem clara (D-06) |
| 6 | Redimensionar | 1920 px JPEG 85 · outro | 1920 px, JPEG 85 (D-07) |
| 7 | Onde fica a tela | Botão "Fotos" na gestão · dentro da própria gestão | Botão na gestão, tela própria (D-08) |
| 8 | Árvore local do app | Descartar · manter | Descartar com `git restore .` e descobrir a causa (feito: Flutter 3.47.5 × lock do 3.50.1) |

**Pedido extra:** corrigir na API envio de uma por requisição, ordem = maior + 1 e capa atômica (D-09).

## Decididas por Claude (mostradas para a Palloma corrigir)

| Área | Decidido | Por quê |
|------|----------|---------|
| Onde moram as regras | Serviço `imoveis/fotos.py` com trava no imóvel (D-11) | Concorrência de envios, teto e capa única num lugar só |
| Correções na rota antiga e no painel | Só `definir_como_capa` atômico no model; views antigas intocadas (D-11) | "Deixe como está" na rota antiga; o painel do site é de outra frente |
| Capa primeiro no site | Prefetch `-capa` em `site_publico` (D-24) — **pede OK** | Sem isso a galeria do site não começa pela capa (critério 6) |
| Ordem da fila | Uma por vez, na ordem da escolha (D-18) | A ordem no servidor segue a escolha; uma falha não trava as outras |
| Reordenar | Sem mover localmente; trava e relê (D-20) | Regra "quem decide é o servidor" |
| Permissão de câmera no Android | Não declarar `CAMERA` (D-26) — **pede OK** | Declarada sem pedido em tempo de execução, quebra a câmera do `image_picker` |
| Compressão | `flutter_image_compress` (D-17) | Garante JPEG, desvira pelo EXIF e tira o GPS da foto |
| App morto durante a câmera | Fora da fase (D-27) | Raro; corretor tira de novo |

## Deferred Ideas

Ver `<deferred>` no CONTEXT.
