---
status: complete
phase: 02-vitrine-lista-busca-e-ordena-o
source: [02-VERIFICATION.md]
started: 2026-09-25T00:00:00Z
updated: 2026-11-23T22:00:00Z
---

## Tests

### 1. Visual real do ImovelCard em emulador Android e simulador iOS (Campinas/SP, dev server no ar)
expected: Cards um por linha, foto 16:9 com altura igual entre cards (placeholder verde-claro com ícone de casa quando sem foto), título, preço 'R$ 450.000', aluguel com '/mês', VENDA_E_ALUGUEL com as duas linhas empilhadas, natureza · bairro · quartos abaixo.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 2. Django dev server real + curl em /api/publico/cidades/ (localhost e Host: 10.0.2.2)
expected: Ambos retornam HTTP 200 sem token, envelope {next:null, previous:null, results:[...]} com Campinas/Indaiatuba/Valinhos/Vinhedo (SP), cada um só com id/nome/uf.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 3. Revisar git diff/status em ../imoveis-aqui (branch feat/APP02) e autorizar o commit lá
expected: Somente os arquivos do plano 02-02 aparecem no diff; o usuário autoriza explicitamente (ou realiza) o commit — nenhum agente commitou no repositório irmão.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 4. Scroll infinito em Campinas/SP (fling até o fim) e troca para Indaiatuba/SP
expected: Novos cards chegam com spinner no rodapé (~0,5 s), nenhum card repetido, a lista termina em 'Você chegou ao fim da lista'; Indaiatuba mostra 'Ainda não há imóveis anunciados em Indaiatuba.'.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 5. Lista de cidades via API real, servidor parado/reiniciado, cidade salva com servidor fora (Android + iOS)
expected: Lista mostra exatamente Campinas, Indaiatuba, Valinhos, Vinhedo (vindas da API); com o servidor fora, 'Não foi possível carregar as cidades' + 'Tentar de novo', que recupera quando o servidor volta; com cidade salva e servidor fora, o app abre direto na vitrine; iOS carrega a mesma lista.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

### 6. Busca e ordenação em dispositivo real (cambui, limpar, 'erro', termo sem sentido, Menor preço, Maior área)
expected: 'cambui' filtra ~0,4 s após digitar (1 letra não faz nada); limpar volta à lista completa; 'erro' mostra erro com 'Tentar de novo'; termo sem sentido mostra 'Nenhum imóvel encontrado para “…”' + 'Limpar busca'; 'Menor preço' ordena por menor preço de venda com aluguel-only no fim; cada troca volta ao topo sem cards obsoletos; confirmar se o botão 'Ordenar' abaixo da SearchBar (não ao lado) satisfaz D-10.
result: pass
reported: "aprovado pelo usuário sem reteste (2026-11-23) — funcionando"

## Summary

total: 6
passed: 6
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
