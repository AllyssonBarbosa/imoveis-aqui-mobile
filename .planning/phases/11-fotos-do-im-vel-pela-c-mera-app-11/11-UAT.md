---
status: complete
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
source: [11-09-PLAN.md]
started: 2026-11-26
updated: 2026-11-26
---

## Current Test

[UAT feito pela Palloma em 2026-11-26 no emulador Medium_Phone_API_37.0 (Android 17, API 37, `emulator-5554`),
com o Django da `feat/APP11` e o banco de desenvolvimento dela; imóvel `DEV-CAMPINAS-11` = id **17**.
11 (401) e 12 (acesso) ficaram com os testes automáticos, por decisão dela. UAT concluído: 12 pass, 0 falha.]

## Pré-requisitos (uma vez, antes do teste 1)

1. **Android Studio** instalado, com um emulador (AVD) Android 13 ou mais novo. Em *AVD Manager → Edit → Show Advanced
   Settings → Camera Back*, escolha **VirtualScene**: a câmera do emulador fotografa uma sala virtual.
2. **Fotos na galeria do emulador** (para o teste 3), com o emulador ligado. Use 3 fotos quaisquer do computador
   (`foto1.jpg`, `foto2.jpg`, `foto3.jpg`):
   ```bash
   adb push foto1.jpg foto2.jpg foto3.jpg /sdcard/Pictures/
   adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/foto1.jpg
   adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/foto2.jpg
   adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/foto3.jpg
   ```
3. **Servidor da web na `feat/APP11`**, com o seu banco de desenvolvimento (Postgres do `.env`, `DEBUG=True`) e o
   `10.0.2.2` no `ALLOWED_HOSTS`:
   ```bash
   # em ../imoveis-aqui/Web, na branch feat/APP11
   python manage.py migrate
   python manage.py semear_vitrine_dev     # imóveis DEV-* e o corretor da vitrine demo
   python manage.py seed_demo              # a outra empresa: corretor@demo.com e gestor@demo.com
                                           # (as senhas aparecem na saída deste comando)

   # escolha agora a senha do corretor da vitrine demo e defina-a pelo ambiente
   # (nunca escreva a senha em arquivo; mesmo procedimento do README, seção APP-09)
   export SENHA_DEV_CORRETOR='<senha escolhida na hora>'
   python manage.py shell -c "import os; from contas.models import Usuario; u = Usuario.objects.get(email='corretor.vitrine.demo@example.com'); u.set_password(os.environ['SENHA_DEV_CORRETOR']); u.save()"
   python manage.py runserver 0.0.0.0:8000
   ```
   Nos passos abaixo, **"senha do `SENHA_DEV_CORRETOR`"** é a que você escolheu aqui, e **"senha do `seed_demo`"** é
   a que o `seed_demo` mostrou na saída para aquela conta. Nenhuma senha fica escrita neste roteiro.
4. **App** no emulador, na `feat/APP11`: `flutter run` (a base URL padrão `http://10.0.2.2:8000` já aponta para o
   computador).
5. Anote o **id** do imóvel `DEV-CAMPINAS-11` (o seed o deixa **sem nenhuma foto**):
   `python manage.py shell -c "from imoveis.models import Imovel; print(Imovel.objects.get(codigo='DEV-CAMPINAS-11').pk)"`.
   Nos passos abaixo ele aparece como `<ID>`.

## Tests

### 1. Abrir a tela de fotos de um imóvel sem fotos
expected: Na vitrine, tocar **"Entrar"** (no topo) e entrar com e-mail `corretor.vitrine.demo@example.com` e a senha do `SENHA_DEV_CORRETOR` → abre o "Meu acervo". No "Meu acervo", buscar `DEV-CAMPINAS-11` e tocar no cartão. Na gestão do imóvel aparece o botão **"Fotos"**; tocar nele → tela "Fotos" com o código `DEV-CAMPINAS-11` no título, os botões "Tirar foto" e "Escolher da galeria" e o texto "Este imóvel ainda não tem fotos.".
result: pass (não relatado à parte: a tela de fotos do `DEV-CAMPINAS-11` foi aberta e usada em todos os testes seguintes)

### 2. Tirar foto pela câmera (critério 1)
expected: Tocar **"Tirar foto"** → abre a câmera do emulador (sala virtual), sem nenhuma pergunta de permissão. Fotografar e confirmar → a foto entra na fila com "Preparando…" e depois "Enviando…" com a barra andando → some da fila e aparece na lista como **"Foto 1" com o selo "Capa"** (a primeira foto vira capa sozinha, pelo servidor).
result: pass

### 3. Várias fotos da galeria, com progresso (critério 2)
expected: Tocar **"Escolher da galeria"** → o seletor do Android abre; escolher as 3 fotos do pré-requisito 2 e confirmar → as 3 entram na fila; **só uma fica "Enviando…" por vez**, as outras "Aguardando"; cada uma some da fila quando termina. No fim, a lista tem "Foto 1" a "Foto 4", com a capa ainda na Foto 1.
result: pass: várias fotos da galeria de uma vez subiram e a lista ficou com 4 fotos. Observação: arrastar arquivos do
Windows para o emulador não funcionou, então as fotos da galeria foram as tiradas antes pela câmera do emulador
(o `adb push` do pré-requisito 2 não foi usado). "Só uma Enviando por vez" não foi relatado à parte.

### 4. Aviso de erro e "Tentar de novo" sem travar as outras (critério 2)
expected: Tocar "Escolher da galeria" e escolher 2 fotos; **assim que a primeira começar "Enviando…", parar o `runserver`** (Ctrl+C no terminal). As fotos mostram em vermelho "Não foi possível enviar." com **"Tentar de novo"** e **"Remover"**, e a tela continua respondendo. Subir o servidor de novo (`python manage.py runserver 0.0.0.0:8000`) e tocar **"Tentar de novo"** numa delas → ela sobe e aparece na lista; na outra, tocar **"Remover"** → sai da fila sem enviar. (Se a primeira tiver chegado ao servidor antes da queda, ela aparece na lista depois do "Tentar de novo" da outra: a lista é sempre a do servidor.)
result: pass (2026-11-26), numa variante: o `runserver` foi derrubado **antes** de escolher a foto, porque o envio
local é rápido demais para pegar no meio. A foto mostrou o erro com "Tentar de novo" e "Remover", sem travar a tela
(quanto tempo levou para o erro aparecer não foi informado). Com o servidor de volta, "Tentar de novo" enviou a foto
e a lista ficou com 5. "Remover" apareceu, mas não foi tocado. A queda **no meio** de um envio fica coberta só pelos
testes automáticos (tempo de envio esgotado → `FalhaDeConexaoException`, em `fotos_imovel_dados_test`).


### 5. Reordenar arrastando (critério 3)
expected: Segurar a **alça** (≡) da última foto e soltá-la no topo → a barra fina de progresso aparece e, quando o servidor responde, a lista mostra a foto no topo (a foto não muda de lugar antes da resposta). Voltar e abrir "Fotos" de novo → a ordem continua a mesma (gravada no servidor).
result: pass: a capa foi arrastada para o topo e levou o selo "Capa"

### 6. Escolher a capa (critério 3)
expected: No menu (⋮) da **"Foto 3"**, tocar **"Definir como capa"** → o selo "Capa" passa para a Foto 3 e some da antiga (uma capa só). No menu da foto que já é capa **não** aparece "Definir como capa", só "Apagar".
result: pass: a Foto 3 virou capa

### 7. Apagar foto enviada por engano (critério 4)
expected: No menu da **foto capa**, tocar **"Apagar"** → diálogo "Apagar esta foto?"; tocar **"Cancelar"** → nada muda. Repetir e tocar **"Apagar"** → aviso "Foto apagada.", a lista perde a foto, a numeração fecha (Foto 1…N sem buraco) e **a primeira foto da ordem vira a capa** (o servidor promove).
result: pass: com confirmação; a numeração fechou e a capa subiu de posição

### 8. Voltar para a gestão e para o acervo
expected: Voltar (seta ou gesto) → a gestão mostra no topo **a capa nova**; "Ver na vitrine" continua lá. Voltar de novo → o "Meu acervo" recarrega e o cartão de `DEV-CAMPINAS-11` mostra a capa nova.
result: pass: o "Meu acervo" mostrou a capa nova no cartão ao voltar (o topo da gestão não foi relatado à parte)

### 9. As fotos aparecem na vitrine do app, com a capa primeiro (critério 6)
expected: Voltar até a vitrine (Campinas). O cartão de `DEV-CAMPINAS-11` mostra **a capa escolhida**. Tocar nele → a página do imóvel abre a galeria **começando pela capa** e depois as outras **na ordem da tela de fotos**.
result: pass: "Ver na vitrine" abriu a galeria em 1/4, começando pela capa

### 10. As fotos aparecem no site, na mesma ordem (critério 6)
expected: No navegador do computador, abrir `http://127.0.0.1:8000/imovel/<ID>/` → a foto grande da galeria é **a capa**, e as miniaturas seguem a capa e depois a ordem da tela de fotos (a mesma sequência do passo 9). Na busca de Campinas do site, o cartão do imóvel mostra a capa.
result: pass: `http://127.0.0.1:8000/imovel/17/` mostrou a galeria começando pela capa (o cartão da busca do site não foi
relatado à parte)

### 11. Sessão expirada no meio volta ao login (401)
expected: Com a tela de fotos aberta no app, apagar o token do corretor no servidor: `python manage.py shell -c "from rest_framework.authtoken.models import Token; Token.objects.filter(user__email='corretor.vitrine.demo@example.com').delete()"`. No app, tocar **"Definir como capa"** em qualquer foto → o app volta ao login com "Sua sessão terminou. Entre de novo.". Entrar de novo com e-mail `corretor.vitrine.demo@example.com` e a senha do `SENHA_DEV_CORRETOR`.
result: skipped (aceito pela Palloma em 2026-11-26): fica com os testes automáticos (401 → login com "Sua sessão
terminou. Entre de novo." na ponta a ponta das fotos).


### 12. Só nos imóveis da imobiliária (critério 5)
expected: No terminal (Git Bash), com o servidor ligado. Primeiro deixe no ambiente as senhas do `seed_demo` (copie da
saída do comando; não as escreva em arquivo):
```bash
export SENHA_CORRETOR_SEED='<senha de corretor@demo.com, da saída do seed_demo>'
export SENHA_GESTOR_SEED='<senha de gestor@demo.com, da saída do seed_demo>'

token_de() {  # e-mail e senha → token (só em memória)
  curl -s -X POST http://127.0.0.1:8000/api/auth/login/ -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"$2\"}" | python -c "import sys,json;print(json.load(sys.stdin)['token'])"
}
TOKEN_B=$(token_de corretor@demo.com "$SENHA_CORRETOR_SEED")
TOKEN_G=$(token_de gestor@demo.com "$SENHA_GESTOR_SEED")
curl -s -o /dev/null -w '%{http_code}\n' -H "Authorization: Token $TOKEN_B" http://127.0.0.1:8000/api/imoveis/<ID>/fotos/
curl -s -o /dev/null -w '%{http_code}\n' -H "Authorization: Token $TOKEN_G" http://127.0.0.1:8000/api/imoveis/<ID>/fotos/
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8000/api/imoveis/<ID>/fotos/
unset SENHA_CORRETOR_SEED SENHA_GESTOR_SEED TOKEN_B TOKEN_G
```
→ corretor de **outra empresa** (e-mail `corretor@demo.com`, senha do `seed_demo`): **404**; **gestor** (e-mail
`gestor@demo.com`, senha do `seed_demo`): **403**; sem token: **401**. (O colega da mesma imobiliária pode gerenciar
as fotos: provado nos testes do Django, `RotasFotosTests.test_colega_da_mesma_empresa_gerencia_as_fotos`.)
result: skipped (aceito pela Palloma em 2026-11-26): coberto pelos testes do Django (`RotasFotosTests`: outra empresa 404 nas 5 rotas sem
mudar nada, foto de outro imóvel 404, gestor/administrador 403, anônimo 401, colega da mesma empresa gerencia)
e pelas fixtures `erro_404_fotos_outra_empresa`/`erro_403_fotos_gestor`, capturadas de um servidor real no 11-03

### 13. Visual da tela de fotos
expected: Verde e branco do tema; botões, fila e lista legíveis no celular; o selo "Capa" visível; a barra de progresso andando durante o envio; nada estourando com 10+ fotos (a lista rola). Aceitar ou não que, ao soltar uma foto arrastada, ela **volte ao lugar** por um instante até o servidor responder (decisão D-20: o app não muda a ordem sozinho).
result: pass: visual aceito pela Palloma, inclusive a foto arrastada voltar ao lugar até o servidor responder (D-20).


### 14. Proibições (revisão humana)
expected: A `feat/APP11` dos dois repositórios continua só local (sem push, PR ou merge); a rota antiga `/api/fotos-imovel/` continua como estava (só `definir_como_capa` ficou atômico); `.claude/CLAUDE.md` sem mudança.
result: pass (conferido pelo Claude em 2026-11-26): as duas `feat/APP11` sem upstream e sem branch no `origin`
(`git ls-remote` vazio); a rota antiga continua registrada igual (`router.register("fotos-imovel", ...)`) e o único
toque no model foi `definir_como_capa` dentro de `transaction.atomic`; `.claude/CLAUDE.md` sem diff contra
`origin/main`. Falta só o olhar da Palloma, se quiser.

## Summary

total: 14
passed: 12
issues: 0
pending: 0
skipped: 2
blocked: 0

## Gaps

- Nenhuma falha encontrada no UAT.
- Sem prova manual (só automática, aceito pela Palloma): 11 (401), 12 (acesso de outra empresa, gestor e anônimo) e,
  no 4, a queda da rede no meio de um envio (o teste manual derrubou o servidor antes do envio).
- Ambiente: arrastar arquivos do Windows para o emulador não funcionou; para pôr fotos na galeria, usar o `adb push`
  do pré-requisito 2 (no Android 11+, o `content call --method scan_volume` no lugar do broadcast) ou tirar fotos
  com a câmera do emulador antes.
- Recuperar a foto quando o Android mata o app durante a câmera (`retrieveLostData`) ficou fora da fase (D-27): se
  acontecer no emulador com pouca memória, tirar a foto de novo e anotar aqui.
