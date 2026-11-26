---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 03
subsystem: ferramenta de captura + fixtures do app
tags: [fixtures, contrato, fotos]
requires: ["11-01", "11-02"]
provides:
  - "Grupo `fotos` em tool/capturar_fixtures_api.py (enviar_put, enviar_delete, enviar_multipart, _png_minimo, capturar_fotos)"
  - "13 fixtures reais das rotas de fotos em test/fixtures/api/"
key-files:
  modified: ["tool/capturar_fixtures_api.py"]
  created:
    - "test/fixtures/api/fotos_lista_vazia.json"
    - "test/fixtures/api/foto_enviada.json"
    - "test/fixtures/api/fotos_lista.json"
    - "test/fixtures/api/fotos_reordenadas.json"
    - "test/fixtures/api/fotos_capa_definida.json"
    - "test/fixtures/api/fotos_apos_apagar_capa.json"
    - "test/fixtures/api/erro_400_foto_tipo.json"
    - "test/fixtures/api/erro_400_foto_tamanho.json"
    - "test/fixtures/api/erro_400_foto_limite.json"
    - "test/fixtures/api/erro_400_foto_quantidade.json"
    - "test/fixtures/api/erro_400_fotos_ordem.json"
    - "test/fixtures/api/erro_404_fotos_outra_empresa.json"
    - "test/fixtures/api/erro_403_fotos_gestor.json"
completed: 2026-11-25
---

# 11-03 — Fixtures reais das fotos (grupo `fotos`)

## O que foi feito
- **Ferramenta:** helpers só com biblioteca padrão (`enviar_put`, `enviar_delete`, `enviar_multipart` com o
  corpo `multipart/form-data` montado à mão, `_png_minimo` com `zlib`/`struct`) e `capturar_fotos`, que confere
  cada resposta antes de salvar: chaves exatas `{id, imagem, ordem, capa}`, URL de mídia, ordens `0..n-1`,
  exatamente uma capa, a primeira foto como capa, a ordem pedida no PUT, o PUT recusado sem mudar nada, a promoção
  ao apagar a capa, os 400 com uma única chave (`imagem`/`ids`), o `{detail}` de 404/403, o 401 sem token, os 404 da
  empresa B nas 5 rotas e a mensagem exata do teto. No fim apaga todas as fotos que criou e confere a lista vazia.
  Grupo registrado em `GRUPOS`, em `--grupo` e na docstring ("Grupo fotos").
- **Captura ao vivo:**
  - Servidor temporário montado com `git archive feat/APP11 Web` (commits hoje `ac5e95f` + `6e56bda`, depois da reescrita de 2026-11-26 que tirou uma senha de teste do `tests_fotos.py`; o código das rotas é o mesmo) numa pasta
    temporária, SQLite temporário, `migrate` → `semear_vitrine_dev` → `seed_demo` e senha descartável do corretor demo.
  - `runserver 127.0.0.1:8011` com taxa de login alta.
  - Contas: corretor demo da vitrine (empresa A), `corretor@demo.com` (empresa B) e `gestor@demo.com` (403).
    Credenciais só por variável de ambiente.
  - Imóvel usado: `DEV-CAMPINAS-11`, que o seed deixa sem foto.

## Desvios do plano
- O servidor rodou a partir de uma **extração** da branch, e não do clone: as fotos enviadas caíram no `media/`
  temporário e o clone da web não foi tocado (`git status --porcelain` vazio).
- O 401 foi conferido ao vivo, mas não virou fixture nova: a `erro_401` já existe desde a Fase 8.

## Verificação
- A captura saiu sem erro em nenhuma das checagens; nenhum arquivo `foto-*` enviado sobrou na mídia temporária.
- Servidor encerrado, porta 8011 livre, extração, SQLite e senha descartável apagados.
- O aviso `SyntaxWarning: invalid escape sequence '\S'` do `py_compile` já existia antes (caminho `venv\Scripts` na
  docstring) e não é desta fase.
- Exemplos: 400 de tipo "O arquivo enviado não é uma imagem válida."; de tamanho "A imagem não pode passar de 5MB.";
  de quantidade "Envie exatamente uma imagem por requisição."; de ordem "Envie a lista completa das fotos deste
  imóvel, sem repetir."; do teto "Este imóvel já tem 30 fotos, o máximo permitido."; 403 "Este recurso é restrito ao
  corretor."; 404 `detail` em inglês do Django (o app nunca exibe).
- Sem commit no app (aguardando aprovação).
