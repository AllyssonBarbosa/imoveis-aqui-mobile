---
status: testing
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
source: [05-VERIFICATION.md]
started: 2026-11-16T00:00:00Z
updated: 2026-11-16T00:00:00Z
---

## Current Test

number: 1
name: Verificação ponta a ponta no emulador (vitrine e detalhe com a API real)
expected: |
  A vitrine mostra, busca, ordena e filtra imóveis reais; fotos carregam pela rede; rolagem e latência
  normais (a navegação normal não dá 429); os blocos das 4 naturezas aparecem no detalhe; textos legíveis
  em português a 360 dp, Material 3 verde e branco.
awaiting: user response

## Tests

### 1. Verificação ponta a ponta no emulador (vitrine e detalhe com a API real)
setup: subir `runserver 0.0.0.0:8000` no banco de dev semeado; rodar o app (Android AVD com base URL padrão `http://10.0.2.2:8000`, ou iOS com `--dart-define=API_BASE_URL=http://127.0.0.1:8000`). Roteiro completo no README do app, seção "Verificação ponta a ponta (emulador)".
steps: |
  (1) Campinas: rolar a lista inteira, duas páginas, sem card repetido.
  (2) Buscar "Cambuí" e depois um texto sem resultado.
  (3) Ordenar por "Maior preço".
  (4) Filtros: Casa e Lote, um bairro, "Piscina", faixa de preço; aplicar, remover um chip, "Limpar filtros".
  (5) Abrir uma casa, um apartamento, um terreno e um lote (galeria começando pela capa "N/M", blocos "Sobre a ...", lote sem "Preço do lote", posição solar e uso permitido em português); tocar no cartão do corretor.
  (6) Abrir o imóvel sem fotos e o sem corretor.
  (7) Trocar para Valinhos com filtro ativo.
expected: A vitrine mostra, busca, ordena e filtra imóveis reais; fotos carregam pela rede; rolagem e latência normais (sem 429 na navegação normal); os blocos das 4 naturezas aparecem no detalhe; textos legíveis em português a 360 dp, Material 3 verde e branco.
result: [pending]

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
