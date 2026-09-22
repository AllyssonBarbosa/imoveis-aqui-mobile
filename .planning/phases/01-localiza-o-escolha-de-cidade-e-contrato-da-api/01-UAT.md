---
status: testing
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
source: [01-VERIFICATION.md]
started: 2026-09-22T00:00:00Z
updated: 2026-09-22T00:00:00Z
---

## Current Test

number: 1
name: Priming — permissão só a partir do CTA
expected: |
  Na primeira abertura, num emulador Android e num simulador iOS (`flutter run`), a tela de
  priming aparece e o prompt nativo de permissão do SO dispara APENAS após tocar
  "Usar minha localização" — nunca antes/na inicialização.
awaiting: user response

## Tests

### 1. Priming — permissão só a partir do CTA
expected: Nenhum diálogo de permissão aparece até o CTA ser tocado; ao tocar, o prompt real do SO dispara.
result: [pending]

### 2. Os 5 desfechos de localização em hardware real
expected: |
  Exercitar num emulador/simulador: permitir+cidade atendida, permitir+cidade não atendida,
  recusar, bloquear-para-sempre (tocar "Ativar localização nas Ajustes" e confirmar que abre os
  ajustes do sistema) e desligar o serviço de localização. Cada desfecho mostra sua própria
  tela/copy; nenhum cai numa tela de erro genérica ou beco sem saída; o CTA de Ajustes abre mesmo o app de configurações do SO.
result: [pending]

### 3. Troca de cidade no topo + persistência em cold restart
expected: |
  Após entrar numa cidade, tocar o cabeçalho "{Cidade}, {UF}" reabre a lista SEM prompt de
  permissão; escolher outra cidade atualiza o cabeçalho e sobrevive a um cold restart real
  (matar e reabrir o processo do app), não só a uma mudança de estado do Cubit em memória.
result: [pending]

### 4. Falha de geocodificação degrada sem crash
expected: |
  Simular falha de reverse geocoding (modo avião / sem rede, ou plataforma sem suporte a
  geocoding) e confirmar que o app mostra "Não conseguimos identificar sua localização
  automaticamente. Escolha sua cidade abaixo." (estado falhaGeocodificacao) em vez de travar ou crashar.
result: [pending]

### 5. Contrato da API acordado com a frente web (API-01, SC-5)
expected: |
  Copiar 01-CONTRATO-API.md para o repo irmão ../imoveis-aqui/Web e obter sign-off explícito da
  frente web (E2) nos 4 itens em aberto (semântica quartos/suites/vagas, formato do param cidade,
  preço do card VENDA_E_ALUGUEL, valores do enum ordenacao). Só então o contrato está "congelado"
  no sentido "escrito E acordado" do Success Criterion 5.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
