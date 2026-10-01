---
status: testing
phase: 03-vitrine-filtros-server-side
source: [03-VERIFICATION.md]
started: 2026-10-01T02:10:00Z
updated: 2026-10-01T02:10:00Z
---

## Current Test

number: 1
name: Verificação no aparelho ao fim da fase (fidelidade Material 3, ergonomia teclado/máscara, ciclo completo dos filtros)
expected: |
  No emulador Android e no simulador iOS (incluindo largura classe 360dp), na vitrine de Campinas:
  (1) 'Ordenar: …' e 'Filtros' lado a lado numa linha (D-15); linha de chips só quando há filtro ativo.
  (2) Sheet em tela cheia, Material 3 verde/branco, seções roláveis com o rodapé 'Limpar'/'Ver imóveis' sempre visível, inclusive acima do teclado (D-07).
  (3) Preço desabilitado até escolher finalidade; máscara 'R$ 250.000'; trocar para Aluguel limpa os campos e mostra '/mês' (D-03, D-09, D-13).
  (4) Área Mínimo 300.000 / Máximo 250.000 → erro inline sob Máximo e 'Ver imóveis' desabilitado (D-12).
  (5) Casa + Apartamento, '2+' quartos, um bairro via 'Filtrar bairros', Piscina → a lista recarrega do topo uma vez; chips 'Casa, Apto', '2+ quartos', 'Cambuí', 'Piscina'; botão 'Filtros (N)'.
  (6) Corpo do chip reabre o sheet com os valores aplicados; 'x' reconsulta na hora; 'Limpar filtros' preserva busca e ordenação (D-17, D-18).
  (7) Terreno + '1+' quartos → 'Nenhum imóvel com esses filtros'; com termo de busca → mensagem citando a busca e 'Limpar busca e filtros' (D-22).
  (8) Venda + um bairro, depois trocar de cidade → Venda mantido, chip de bairro sumiu, lista da nova cidade já filtrada (D-14).
  (9) Fechar e reabrir o app → reabre na cidade salva sem filtros (D-23).
awaiting: user response

## Tests

### 1. Verificação no aparelho ao fim da fase (fidelidade Material 3, ergonomia teclado/máscara, ciclo completo dos filtros)
expected: Os nove passos acima se comportam como descrito em "Current Test" (fonte: 03-VERIFICATION.md human_verification, colhido de 03-05-PLAN.md Task 2 `<human-check>`).
result: [pending]

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
