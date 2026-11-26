---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 09
subsystem: app (ponta a ponta, documentação, gates)
tags: [e2e, uat, readme, verificacao]
requires: ["11-08"]
provides:
  - "test/presentation/fotos_imovel/fotos_imovel_fluxo_test.dart (9 fluxos na pilha real)"
  - "PilhaReal.trocarPluginsDeFotos"
  - "README: seções \"Fotos do imóvel (APP-11)\" e \"Câmera e galeria (APP-11)\""
  - "11-UAT.md (14 itens, credenciais em cada passo) e 11-VERIFICATION.md (status human_needed)"
key-files:
  created:
    - "test/presentation/fotos_imovel/fotos_imovel_fluxo_test.dart"
    - ".planning/phases/11-fotos-do-im-vel-pela-c-mera-app-11/11-UAT.md"
    - ".planning/phases/11-fotos-do-im-vel-pela-c-mera-app-11/11-VERIFICATION.md"
  modified: ["test/support/pilha_real.dart", "README.md"]
status: tasks 1-2 concluídas; task 3 (human-check) pendente
---

# 11-09 — Ponta a ponta, UAT e gates

## O que foi feito
- **Fluxos ponta a ponta** na pilha real (DI de produção + `ApiFalsa`; só câmera/galeria e compressão falsas):
  1. abrir "Fotos" pela gestão, com o token;
  2. duas fotos da galeria enviadas uma por vez (GET, POST, GET, POST, GET), multipart com um `imagem` cada, JPEGs
     descartados;
  3. 400 do teto com a mensagem do servidor e "Remover";
  4. 500 e "Tentar de novo" que sobe;
  5. `onReorderItem(2, 0)` → PUT `{"ids": [90, 88, 89]}` e a lista devolvida (capa na Foto 3);
  6. capa e apagar com confirmação ("Foto apagada.");
  7. voltar até o acervo faz ele reler, e "Ver na vitrine" continua;
  8. 401 no envio → login com o aviso e token apagado;
  9. 404 → texto fixo, sem o `detail` em inglês.
- **`PilhaReal.trocarPluginsDeFotos`** troca só os dois gateways de plugin.
- **README:** como a tela funciona, o servidor para testar, câmera e galeria no emulador (`adb push`) e o porquê de não
  haver `CAMERA` no Android.
- **`11-UAT.md`:** 14 itens cobrindo os 6 critérios, a volta para a gestão/acervo, o 401 (token apagado pelo shell), o
  isolamento por `curl` (404/403/401), o visual e as proibições. Credenciais escritas em cada passo de login.
- **`11-VERIFICATION.md`:** critério × requisito × evidência automática × item do UAT.

## Desvios do plano
- **I/O real nos testes de widget:** o `MultipartFile.fromFile` lê o arquivo com I/O assíncrono de verdade, que não
  anda no relógio falso do `testWidgets`. Os fluxos de envio usam `tester.runAsync` intercalado com quadros (helper
  `deixarEnviar`).
- **README e UAT** ficam no app. O README da web já foi atualizado no 11-01.
- **Task 3 (human-check) não executada:** é da Palloma, no emulador, depois de instalar o Android Studio.
  REQUIREMENTS, ROADMAP e STATE só fecham depois disso.

## Verificação
- `flutter test test/presentation/fotos_imovel/fotos_imovel_fluxo_test.dart`: **9 OK**.
- Gates: app `flutter test` **2058 OK**, `flutter analyze` 106 infos (todas `material.dart`; o +1 é o import no teste
  novo), nenhum `warning`/`error`; web `python manage.py test` **835 OK**, `check` limpo, sem migração.
- `feat/APP11` dos dois repos sem upstream; nenhum push.
