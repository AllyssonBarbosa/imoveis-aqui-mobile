---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
verified: 2026-11-25
status: human_needed
score: 8/8 requisitos com evidência automática; UAT no emulador pendente (14 itens em 11-UAT.md)
---

# Phase 11 — Verificação (APP 11 · Fotos do imóvel pela câmera)

## Critérios do card × evidência

| # | Critério | Requisito | Evidência automática | Humano (UAT) |
|---|----------|-----------|----------------------|--------------|
| 1 | Tirar foto pela câmera ou escolher da galeria | FOT-01 | `SeletorDeFotosImagePicker`/`PreparadorDeFotoCompressao` (1920 px, JPEG 85, sem EXIF); Cubit `tirarFoto`/`escolherDaGaleria` (testes do Cubit); tela com os dois botões (widget); ponta a ponta com a galeria (`fotos_imovel_fluxo_test`); Info.plist com as duas chaves; manifesto sem `CAMERA` (conferido no código do `image_picker_android`) | testes 2 e 3 |
| 2 | Várias de uma vez, com progresso e aviso de erro | FOT-02 | uma por requisição no servidor (`RotasFotosTests`, 0/2 arquivos → 400); multipart com `onSendProgress` (dados: progresso até 1.0); fila uma por vez na ordem (Cubit, com mutação provada); falha por foto com mensagem do servidor e "Tentar de novo"/"Remover" (Cubit, widget, ponta a ponta 400 e 500) | testes 3 e 4 |
| 3 | Reordenar e escolher a capa | FOT-03 | serviço `reordenar_fotos`/`definir_capa` atômicos (Django, capa única, lista inválida → 400 sem mudar nada); `PUT .../ordem/` com a lista completa (ponta a ponta); sem mudança local antes da resposta (Cubit) | testes 5 e 6 |
| 4 | Apagar foto enviada por engano | FOT-04 | `apagar_foto` renumera, promove a capa e apaga o arquivo depois do commit (Django); confirmação na tela (widget); `DELETE` e "Foto apagada." (ponta a ponta) | teste 7 |
| 5 | Só nos imóveis com acesso (os dele e os da imobiliária) | FOT-05 | colega da mesma empresa gerencia; outra empresa 404 nas 5 rotas sem mudar nada; foto de outro imóvel 404; gestor/administrador 403; anônimo 401 (Django); fixtures reais 404/403 (11-03); 401 → login e 404 → texto fixo (app, ponta a ponta) | testes 11 e 12 |
| 6 | Aparecem na vitrine e no site | FOT-06 | `FotosNaVitrineTests`: ordem e capa gravadas pelas rotas = detalhe público, `foto_capa` do cartão e galeria do site; galeria do site com a capa primeiro (`PaginaImovelTests`) | testes 9 e 10 |
| — | Rotas da web com testes | API-17 | `imoveis/tests_fotos.py` (31) + `site_publico` (28); suíte web 835 OK; rota antiga intocada (diff) | teste 14 |
| — | Contrato e fixtures | API-18 | §19 do contrato; 13 fixtures capturadas; `contrato_fotos_imovel_test.dart` (13) | — |

## Gates (2026-11-25)

- App (`feat/APP11` em `ef1db5f`, com o 11-09): `flutter test` **2058 OK**; `flutter analyze` **106 infos**,
  todas `deprecated_member_use` (import de `material.dart`, ver `11-NOTAS-PR.md`), nenhum `warning`/`error`.
- Web (`feat/APP11` em `6e56bda`): `python manage.py test` **835 OK**; `check` limpo; `makemigrations --check` sem
  mudanças.
- As duas branches **sem upstream**; nenhum push. Histórico reescrito em 2026-11-26 (nenhuma senha em
  commit); depois disso: app 2058 OK, web 835 OK.

## Pendente (humano)

- UAT no emulador Android (`11-UAT.md`, 14 itens), depois de a Palloma instalar o Android Studio. Os plugins reais
  (câmera, galeria, compressão) só rodam no aparelho: os itens 2, 3 e 13 são a única prova deles.
- Depois do UAT: FOT-01..06, API-17 e API-18 marcados Complete no REQUIREMENTS, Phase 11 concluída no ROADMAP.
