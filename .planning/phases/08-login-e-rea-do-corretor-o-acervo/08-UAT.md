---
status: testing
phase: 08-login-e-rea-do-corretor-o-acervo
source: [08-VERIFICATION.md]
started: 2026-11-21T16:06:16Z
updated: 2026-11-21T16:06:16Z
---

## Current Test

number: 1
name: Emulador Android contra o Django real da feat/APP08: abrir sem login, Entrar como corretor, ver Meu acervo, buscar, filtrar por situação, Sair. Repetir o Sair no primeiro uso (sem cidade salva) e com cidade salva
expected: |
  Abre na vitrine com o botão Entrar; o corretor cai em Meu acervo; fechar e reabrir mantém Meu acervo; Sair devolve ao anônimo, apaga o token e volta à vitrine (no primeiro uso, não ao priming); Sair com a rede cortada termina em até cerca de 5 s
awaiting: user response

## Tests

### 1. Emulador Android contra o Django real da feat/APP08: abrir sem login, Entrar como corretor, ver Meu acervo, buscar, filtrar por situação, Sair. Repetir o Sair no primeiro uso (sem cidade salva) e com cidade salva
expected: Abre na vitrine com o botão Entrar; o corretor cai em Meu acervo; fechar e reabrir mantém Meu acervo; Sair devolve ao anônimo, apaga o token e volta à vitrine (no primeiro uso, não ao priming); Sair com a rede cortada termina em até cerca de 5 s
result: [pending]

### 2. Token no Keychain do iOS num Mac M1 (entrar, fechar e reabrir no simulador)
expected: O token persiste; se não persistir, adicionar a capability Keychain Sharing pelo Xcode
result: [pending]

### 3. Isolamento com dados reais: corretor B (outra empresa) abre o acervo
expected: Só vê DEMO-CASA-01 (Vendido, sem toque) e nenhum DEV-*; gestor e administrador caem em 'A área do gestor ainda não está no app.' com Sair
result: [pending]

### 4. Limite de tentativas: repetir o login errado até o 429 e decidir se 10/hour por e-mail e 30/hour por IP servem
expected: Mensagem 'Muitas tentativas. Tente de novo em N minutos.' e valores de taxa aceitos pelo time
result: [pending]

### 5. Sair em dois aparelhos (token único por usuário). Conferir também que, ao expirar a sessão (401), o app volta à vitrine com o login e o aviso, sem reoferecer Meu acervo
expected: O outro aparelho volta ao login com 'Sua sessão terminou. Entre de novo.' ao tocar em Meu acervo; depois, a vitrine mostra Entrar (e não Meu acervo)
result: [pending]

### 6. Aparência (login, aviso, acervo, cartão compacto), autofill do gerenciador de senhas e o botão do topo em 360 dp
expected: Material 3 verde e branco; Entrar / Meu acervo ao lado do seletor de cidade sem truncar; oferta de preenchimento no login
result: [pending]

### 7. Push das branches feat/APP08 dos dois repositórios, aviso ao time da web e nota do .claude/CLAUDE.md
expected: Autorização do usuário; time da web ciente de que GET /api/imoveis/ virou envelope paginado; nota sobre flutter_secure_storage atualizada ou recusada
result: [pending]

## Summary

total: 7
passed: 0
issues: 0
pending: 7
skipped: 0
blocked: 0

## Gaps
