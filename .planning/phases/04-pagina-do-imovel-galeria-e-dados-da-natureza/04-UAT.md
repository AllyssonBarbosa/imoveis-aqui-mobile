---
status: complete
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
source: [04-VERIFICATION.md]
started: 2026-10-12T14:00:00Z
updated: 2026-11-23T22:00:00Z
---

## Tests

### 1. Pinch-zoom x swipe no visualizador em tela cheia (aparelho real)
Abrir um imóvel com 3+ fotos (ex.: 103 em Campinas), tocar na galeria, dar pinch-zoom e arrastar/dar swipe.
expected: Sem zoom o swipe troca de foto; ampliada, o arrasto move a imagem (não troca de foto); ao voltar a 1x o swipe volta. Zoom até 4x.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 2. Legibilidade do botão voltar sobre fotos claras e escuras
Abrir um imóvel e rolar a página (SliverAppBar fixo), incluindo os imóveis 103 e 104 (sem fotos) em Campinas.
expected: O botão voltar continua visível e legível em qualquer foto, também com a barra colapsada.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 3. Seção "Sobre ..." por natureza
Abrir uma casa (57), um terreno (63, Valinhos), um apartamento (42) e um lote (103).
expected: Ícones, rótulos e ordem dos destaques e da ficha fazem sentido e estão legíveis; cards "Prédio" e "Quadra e loteamento" aparecem só para apartamento/lote; casa 57 mostra área livre 100 m².
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 4. Cartões de 404 e de erro no Vinhedo
No Vinhedo ordenado por "Mais recentes", abrir o último card (id 339) e o penúltimo (id 338).
expected: 339 mostra "Este imóvel não está mais disponível" com "Voltar à vitrine" (sem "Tentar de novo"); 338 mostra "Não foi possível carregar este imóvel." com "Tentar de novo" que repete a busca.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 5. (Advisório, 04-REVIEW WR-01) Paginar a galeria com mouse no Windows/macOS
Rodar o app no desktop e tentar passar as fotos da galeria e do visualizador com o mouse.
expected: Decisão do dono — hoje o PageView não aceita arrasto de mouse e não há botões/atalhos; decidir se corrige nesta fase ou depois.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

## Summary

total: 5
passed: 5
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
