---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
verified: 2026-11-25
status: passed
score: 8/8 requisitos com evidência automática; UAT 2026-11-26: 12 pass, 0 falha, 2 só automáticos por decisão da Palloma (11, 12)
uat: 2026-11-26
---

# Phase 11 — Verificação (APP 11 · Fotos do imóvel pela câmera)

## Critérios do card × evidência

| # | Critério | Requisito | Evidência automática | Humano (UAT) |
|---|----------|-----------|----------------------|--------------|
| 1 | Tirar foto pela câmera ou escolher da galeria | FOT-01 | `SeletorDeFotosImagePicker`/`PreparadorDeFotoCompressao` (1920 px, JPEG 85, sem EXIF); Cubit `tirarFoto`/`escolherDaGaleria` (testes do Cubit); tela com os dois botões (widget); ponta a ponta com a galeria (`fotos_imovel_fluxo_test`); Info.plist com as duas chaves; manifesto sem `CAMERA` (conferido no código do `image_picker_android`) | ✅ 2 e 3 pass (galeria com fotos da câmera do emulador) |
| 2 | Várias de uma vez, com progresso e aviso de erro | FOT-02 | uma por requisição no servidor (`RotasFotosTests`, 0/2 arquivos → 400); multipart com `onSendProgress` (dados: progresso até 1.0); fila uma por vez na ordem (Cubit, com mutação provada); falha por foto com mensagem do servidor e "Tentar de novo"/"Remover" (Cubit, widget, ponta a ponta 400 e 500) | ✅ 3 e 4 pass (4 com o servidor derrubado antes do envio) |
| 3 | Reordenar e escolher a capa | FOT-03 | serviço `reordenar_fotos`/`definir_capa` atômicos (Django, capa única, lista inválida → 400 sem mudar nada); `PUT .../ordem/` com a lista completa (ponta a ponta); sem mudança local antes da resposta (Cubit) | ✅ 5 e 6 pass |
| 4 | Apagar foto enviada por engano | FOT-04 | `apagar_foto` renumera, promove a capa e apaga o arquivo depois do commit (Django); confirmação na tela (widget); `DELETE` e "Foto apagada." (ponta a ponta) | ✅ 7 pass |
| 5 | Só nos imóveis com acesso (os dele e os da imobiliária) | FOT-05 | colega da mesma empresa gerencia; outra empresa 404 nas 5 rotas sem mudar nada; foto de outro imóvel 404; gestor/administrador 403; anônimo 401 (Django); fixtures reais 404/403 (11-03); 401 → login e 404 → texto fixo (app, ponta a ponta) | ☑️ 11 e 12 com os testes automáticos (aceito) |
| 6 | Aparecem na vitrine e no site | FOT-06 | `FotosNaVitrineTests`: ordem e capa gravadas pelas rotas = detalhe público, `foto_capa` do cartão e galeria do site; galeria do site com a capa primeiro (`PaginaImovelTests`) | ✅ 9 e 10 pass (`/imovel/17/` e "Ver na vitrine" 1/4 pela capa; acervo com a capa nova) |
| — | Rotas da web com testes | API-17 | `imoveis/tests_fotos.py` (31) + `site_publico` (28); suíte web 835 OK; rota antiga intocada (diff) | ✅ 14 conferido |
| — | Contrato e fixtures | API-18 | §19 do contrato; 13 fixtures capturadas; `contrato_fotos_imovel_test.dart` (13) | — |

## Gates (2026-11-25)

- App (`feat/APP11` em `ef1db5f`, com o 11-09): `flutter test` **2058 OK**; `flutter analyze` **106 infos**,
  todas `deprecated_member_use` (import de `material.dart`, ver `11-NOTAS-PR.md`), nenhum `warning`/`error`.
- Web (`feat/APP11` em `6e56bda`): `python manage.py test` **835 OK**; `check` limpo; `makemigrations --check` sem
  mudanças.
- As duas branches **sem upstream**; nenhum push. Histórico reescrito em 2026-11-26 (nenhuma senha em
  commit); depois disso: app 2058 OK, web 835 OK.

## UAT no emulador (2026-11-26)

Feito pela Palloma no `Medium_Phone_API_37.0` (Android 17, API 37) com o Django da `feat/APP11`; detalhes em
`11-UAT.md`.

- **Pass (12):** 1, 2 (câmera), 3 (várias da galeria, 4 fotos), 5 (arrastar: a capa foi ao topo com o selo), 6 (Foto 3
  virou capa), 7 (apagar com confirmação: numeração fechou, capa subiu), 8 (acervo com a capa nova), 9 (vitrine 1/4 pela
  capa), 10 (site `/imovel/17/` pela capa), 13 (visual aceito), 14 (proibições, conferidas pelo Claude); 4 (servidor
  derrubado antes de escolher a foto: erro com "Tentar de novo"/"Remover" sem travar, e "Tentar de novo" enviou
  com o servidor de volta, 5 fotos).
- **Falhas:** nenhuma.
- **Só automático (2, aceito pela Palloma):** 11 (401 → login), 12 (critério 5: outra empresa 404, gestor 403,
  anônimo 401). Também só automático: a queda da rede **no meio** de um envio (item 4).
- **Ambiente:** arrastar arquivos do Windows para o emulador não funcionou; a galeria usou fotos tiradas pela câmera do
  emulador. Os plugins reais de câmera, galeria e compressão rodaram no aparelho (itens 2 e 3).

## Conclusão

Fase concluída em 2026-11-26 (aprovação da Palloma): FOT-01..06, API-17 e API-18 Complete no REQUIREMENTS,
Phase 11 concluída no ROADMAP. As duas `feat/APP11` continuam só locais (sem push).
