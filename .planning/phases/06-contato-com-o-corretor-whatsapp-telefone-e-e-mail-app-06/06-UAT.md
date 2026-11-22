---
status: complete
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
source: [06-01-SUMMARY.md, 06-02-SUMMARY.md, 06-03-SUMMARY.md, 06-04-SUMMARY.md, 06-05-SUMMARY.md, 06-06-SUMMARY.md, 06-07-SUMMARY.md, 06-08-SUMMARY.md, 06-09-SUMMARY.md, 06-10-SUMMARY.md]
started: 2026-11-22T12:00:00Z
updated: 2026-11-22T13:00:00Z
---

## Current Test

[testing complete]

## Tests

### 1. WhatsApp pela página do imóvel
expected: Na página de um imóvel com corretor ativo, a barra inferior mostra o botão "WhatsApp". Ao tocar, o WhatsApp abre na conversa com o número do corretor e a mensagem já escrita, com espaços normais entre as palavras (nenhum "+" no lugar de espaço). Nenhuma SnackBar aparece.
result: pass
covers: 06-02 D3, 06-07 D1, 06-10 E1

### 2. Aparência da barra de contato na página
expected: A barra fica fixa embaixo, com o preço repetido na legenda (o mesmo texto do cabeçalho), o botão WhatsApp com ícone e o ⋮ ao lado. Em tela estreita o texto não estoura (reticências ou quebra de linha). A última seção da página fica visível acima da barra. A barra não aparece enquanto carrega, em erro, em imóvel inexistente nem em imóvel sem canais.
result: pass
covers: 06-07 D3, 06-07 D4, 06-09 E3

### 3. Menu ⋮ e "Ligar"
expected: Tocar no ⋮ abre um painel inferior com exatamente "Ligar" e "Enviar e-mail". Tocar em "Ligar" fecha o painel e abre o discador com o número do corretor já preenchido.
result: pass
covers: 06-08 E1, 06-08 E2, 06-08 E5, 06-06 D4

### 4. "Enviar e-mail"
expected: No ⋮, tocar em "Enviar e-mail" abre o app de e-mail com o endereço do corretor no destinatário (e assunto/mensagem preenchidos, se o servidor mandar).
result: pass
covers: 06-06 D4, 06-10 E2

### 5. Carregamento durante o contato
expected: Logo após tocar num canal, aparece um spinner no botão tocado (no WhatsApp ou no ⋮, conforme o canal) e os botões ficam desabilitados; toques repetidos não disparam um segundo contato.
result: pass
covers: 06-08 E3

### 6. Mensagem de falha
expected: Com o servidor fora do ar (ou após passar da taxa de 10 contatos/min), tocar num canal mostra uma SnackBar com mensagem em português, sem mostrar número, e-mail ou link (nada de wa.me, tel:, mailto: ou @). Tocar de novo mostra a SnackBar de novo.
result: pass
covers: 06-08 E4, 06-07 D2

### 7. Contato pelo perfil do corretor
expected: Na página do imóvel, tocar no cartão do corretor abre o perfil com a barra "Sobre: <título do imóvel>" (até 2 linhas, sem estourar), botão WhatsApp e ⋮. Tocar em WhatsApp abre o WhatsApp como na página. Um perfil aberto sem imóvel de origem não mostra barra nem botões de contato, e o perfil não exibe telefone, e-mail ou CRECI em texto.
result: pass
covers: 06-09 E1, 06-09 E2, 06-09 E4

### 8. Imóvel com corretor desativado
expected: No imóvel de Campinas cujo corretor foi desativado, a página não mostra cartão de corretor, mas a barra aparece com os canais da empresa (WhatsApp e ⋮ só com "Enviar e-mail", já que a empresa não tem telefone).
result: pass
covers: 06-09 E3, 06-01 D3

### 9. Contatos registrados no servidor
expected: Cada toque bem-sucedido nos testes acima gerou um registro de Contato no servidor (admin do Django ou painel), com o imóvel, o corretor e o canal certos.
result: pass
covers: 06-10 E2

### 10. Branch da API = main + WEB-11, sem push
expected: feat/APP06 da API = main + merge de origin/WEB-11, 3 conflitos aditivos resolvidos mantendo os dois lados, sem push, origin/WEB-11 intocada
result: pass
source: automated
coverage_id: 06-01 D1

### 11. POST público grava Contato
expected: POST público de contato sem token grava Contato e devolve {canal, link}; imóvel reservado dá 404 sem gravar
result: pass
source: automated
coverage_id: 06-01 D2

### 12. canais_contato no detalhe
expected: canais_contato no detalhe: só nomes, ordem fixa, fallback da empresa, [] sem destino, ausente na lista
result: pass
source: automated
coverage_id: 06-01 D3

### 13. Limite de taxa 429
expected: POST público de contato acima da taxa responde 429 com Retry-After e {detail}, sem gravar Contato; a view segue sem login
result: pass
source: automated
coverage_id: 06-02 D1

### 14. Baldes de taxa isolados
expected: Baldes isolados nos dois sentidos, taxa padrão do settings, X-Forwarded-For forjado não reinicia a contagem, taxa inválida para a partida
result: pass
source: automated
coverage_id: 06-02 D2

### 15. Detalhes recapturados
expected: Detalhes recapturados diferem da main só em canais_contato e sufixo de mídia; 404 idêntico; exemplos do contrato são cópias byte a byte
result: pass
source: automated
coverage_id: 06-03 D1

### 16. Allowlist de canais_contato
expected: canais_contato travado na allowlist exata do app e validado nos JSON capturados
result: pass
source: automated
coverage_id: 06-03 D2

### 17. Respostas reais do POST capturadas
expected: Respostas reais do POST de contato capturadas; link do WhatsApp com %20 e sem '+'
result: pass
source: automated
coverage_id: 06-03 D3

### 18. canais_contato tipado no app
expected: canais_contato dos detalhes capturados vira List<CanalContato> tipada, na ordem fixa
result: pass
source: automated
coverage_id: 06-04 D1

### 19. Parse tolerante de canais
expected: Parse tolerante: ausente, nulo, desconhecido, repetido/fora de ordem e vazio nunca derrubam o detalhe
result: pass
source: automated
coverage_id: 06-04 D2

### 20. Contrato do POST travado
expected: POST de contato travado sobre as respostas reais: chaves {canal, link}, esquema por canal, %20 sem '+', round-trip do link
result: pass
source: automated
coverage_id: 06-04 D3

### 21. POST sem Authorization/Cookie
expected: POST de contato com corpo {canal} vindo do enum, sem Authorization nem Cookie, resposta lida do JSON capturado
result: pass
source: automated
coverage_id: 06-05 D1

### 22. Falhas tipadas no datasource
expected: Falhas 400/404/429 tipadas, rede/5xx como DioException, JSON malformado como FormatException
result: pass
source: automated
coverage_id: 06-05 D2

### 23. Validação do link recebido
expected: Link fora da lista do canal (http, host falso, javascript:, intent:, canal trocado, link ilegível) vira LinkContatoInvalidoException; link válido fica byte a byte igual ao capturado
result: pass
source: automated
coverage_id: 06-05 D3

### 24. Ponta a ponta até o lançador
expected: Ponta a ponta: POST na ApiFalsa, repositório real e UrlLauncherPlatform falso recebe exatamente o link capturado do WhatsApp, com externalApplication, depois de exatamente um POST
result: pass
source: automated
coverage_id: 06-06 D1

### 25. Gateway do lançador
expected: Gateway entrega wa.me, tel e mailto ao sistema como aplicativo externo; false, PlatformException ACTIVITY_NOT_FOUND e ArgumentError viram false sem lançar
result: pass
source: automated
coverage_id: 06-06 D2

### 26. Registro antes da abertura
expected: Registro antes da abertura; falha no registro não abre nada; abertura false devolve ContatoSemAplicativoException sem desfazer o registro
result: pass
source: automated
coverage_id: 06-06 D3

### 27. ContatoCubit
expected: Cubit: sucesso, sete tipos de falha mapeados por tipo, toque duplo com uma só chamada, falhas seguidas emitem de novo, close durante o POST sem emitir nem lançar, Loading
result: pass
source: automated
coverage_id: 06-07 D2

## Summary

total: 27
passed: 27
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none yet]
