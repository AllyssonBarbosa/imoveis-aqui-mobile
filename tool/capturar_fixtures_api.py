#!/usr/bin/env python3
"""Captura as respostas REAIS da API pública do Imóveis Aqui como fixtures de teste do app.

Nenhuma fixture de wire é escrita à mão (D-02, D-18): o JSON é salvo exatamente como a API
devolve (ensure_ascii=False, indent=2, quebra de linha final). Só biblioteca padrão.

Uso:
    python3 tool/capturar_fixtures_api.py [URL_BASE] [PASTA_SAIDA]
        [--grupo lista|detalhe|contato|perfis|anunciante|acervo|situacao|contatos|gestor|fotos|todos]

Padrões: URL_BASE=http://127.0.0.1:8000, PASTA_SAIDA=test/fixtures/api, --grupo=todos.
Grupos: `lista` (cidades, listas de Campinas, bairros, características e o 400 de natureza);
`detalhe` (um detalhe por natureza, o sem fotos, o sem corretor e o 404 fora da vitrine; lê a
lista de Campinas ao vivo e NÃO reescreve as fixtures de lista); `contato` (as respostas do POST de
contato: 201 de WhatsApp, telefone e e-mail, e o 400 de canal inválido; recusa um link do WhatsApp com '+');
`perfis` (perfil do corretor, perfil da
empresa e o 404 de perfil; descobre os ids ao vivo pelo corretor responsável de um detalhe); `anunciante`
(p1 e p2 da vitrine de imóveis do corretor e da empresa); `acervo` (rotas autenticadas da Fase 8: login,
eu, acervo do corretor em `GET /api/imoveis/` e o Sair; ver "Grupo acervo" abaixo); `situacao` (Fase 9: detalhe de
gestão, POST de mudança de situação, histórico, as recusas 400/403 e o 404 de outra empresa no detalhe e no
histórico; ver "Grupo situacao" abaixo); `contatos` (caixa de contatos do corretor da Fase 10: 25 POSTs públicos,
lista p1/p2 e filtros, contagem antes e depois de anotar, opções do filtro de imóvel, PATCH 200/400, a caixa da
outra empresa e o 404 cruzado; ver "Grupo contatos" abaixo); `gestor` (relatórios da Área do gestor da Fase 12: contatos
públicos, PATCH, 2 mudanças de situação, as 4 rotas do gestor, os 400/403/401 e a outra empresa; ver "Grupo gestor"
abaixo); `fotos` (fotos do imóvel da Fase 11: lista, envio multipart, ordem, capa, apagar, recusas 400, 404 de outra
empresa, 403 do gestor e o teto de 30; ver "Grupo fotos" abaixo); `todos` = `lista`, `detalhe`, `contato`, `perfis`,
`anunciante`, `acervo`, `situacao`, `contatos`, `gestor` e `fotos`, nessa ordem. ATENÇÃO: `todos` reescreve as fixtures da lista e do
detalhe (as URLs de foto mudam a cada banco novo); para acrescentar só um grupo rode `--grupo contato`,
`--grupo perfis`, `--grupo anunciante`, `--grupo acervo`, `--grupo situacao`, `--grupo contatos` ou `--grupo gestor`
(nunca `todos`).
ATENÇÃO: cada POST de contato grava um Contato no banco do servidor; por isso o grupo `contato` só roda
contra o SQLite temporário abaixo, NUNCA contra o banco do Web/.env.
Sai com código 1 (e mensagem em português) quando alguma resposta esperada não é produzida.

Procedimento de captura (NUNCA contra o banco do Web/.env; use um SQLite temporário):

  1. Em ../imoveis-aqui/Web:
       CAPTURA_DB="sqlite:///${TMPDIR:-/tmp}/imoveis_captura_06.sqlite3"
       rm -f "${TMPDIR:-/tmp}/imoveis_captura_06.sqlite3"
       DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py migrate --noinput
       DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py semear_vitrine_dev
  2. Suba o servidor temporário em segundo plano:
       DEBUG=True ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2 CONTATO_TAXA_ANONIMA=1000/min \\
         DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py runserver 127.0.0.1:8000 --noreload
     (CONTATO_TAXA_ANONIMA alto só evita o 429 ao repetir o grupo `contato` no mesmo minuto; não muda
     nenhum corpo capturado) e aguarde `curl -sf http://127.0.0.1:8000/api/publico/cidades/` responder (até ~30 s).
  3. Na raiz do app:
       python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo <grupo>
  4. Pare o servidor temporário e apague o SQLite temporário.

Os ids são determinísticos para um banco novo semeado pelo mesmo comando.

Procedimento no Windows (Git Bash; repo web em "$WEB", sempre entre aspas) — o venv do web é
`Web\venv\Scripts\python.exe`:

  1. CAPTURA="$(cygpath -m "${TMPDIR:-/tmp}")/imoveis_captura.sqlite3"; rm -f "$CAPTURA"
     (caminho do SQLite com letra de drive e barras normais, nunca `/c/...`: o Django responde
     "unable to open database file"). Em "$WEB/Web", com
       DEBUG=True DATABASE_URL="sqlite:///$CAPTURA" PYTHONIOENCODING=utf-8
     rode `./venv/Scripts/python.exe manage.py migrate --noinput` e
     `./venv/Scripts/python.exe manage.py semear_vitrine_dev`.
  2. Suba `./venv/Scripts/python.exe manage.py runserver 127.0.0.1:8000 --noreload` em segundo plano
     com as mesmas variáveis e `ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2`. A porta 8000 precisa
     estar livre antes (nunca capture contra um servidor que já esteja ligado).
  3. Na raiz do app: `python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api
     --grupo perfis` e depois `--grupo anunciante`.
  4. Encerre o servidor, confira que a porta 8000 ficou livre, apague o SQLite e confira que
     `git -C "$WEB" status --porcelain` está vazio.

Grupo acervo (credenciais NUNCA entram em arquivo: só por variável de ambiente):

  Variáveis: CAPTURA_EMAIL_CORRETOR e CAPTURA_SENHA_CORRETOR (corretor da empresa demo da vitrine),
  CAPTURA_EMAIL_OUTRA_EMPRESA e CAPTURA_SENHA_OUTRA_EMPRESA (corretor da segunda empresa, do
  `seed_demo`) e CAPTURA_EMAIL_GESTOR e CAPTURA_SENHA_GESTOR (gestor, que deve receber 403 no acervo).

  Passos extras no SQLite temporário (além de `migrate` e `semear_vitrine_dev`):
    - rode também `manage.py seed_demo` (segunda empresa, gestor e administrador);
    - o corretor da vitrine demo nasce SEM senha utilizável: gere uma senha descartável
      (`python3 -c 'import secrets; print(secrets.token_urlsafe(18))'`), exporte-a em
      CAPTURA_SENHA_CORRETOR e defina-a no SQLite temporário com `manage.py shell -c` lendo
      `os.environ` (nunca na linha de comando em texto).
  Redação do token: o 200 do login é gravado com o valor de `token` trocado por 40 zeros, depois de
  conferir que a resposta tinha exatamente a chave `token`; a chave real fica só em memória e é
  revogada no fim (Sair). Não há fixture de 429 (não é capturável de forma determinística).

Grupo situacao (Fase 9; credenciais também só por variável de ambiente):

  Variáveis: CAPTURA_EMAIL_CORRETOR e CAPTURA_SENHA_CORRETOR (corretor da empresa demo) e
  CAPTURA_EMAIL_OUTRA_EMPRESA e CAPTURA_SENHA_OUTRA_EMPRESA (corretor da segunda empresa, do `seed_demo`).
  O grupo LÊ as fixtures do acervo já versionadas (`acervo_p1`, `acervo_busca`, `acervo_outra_empresa`): rode
  antes o grupo `acervo` num banco novo semeado na mesma ordem (`migrate` -> `semear_vitrine_dev` -> `seed_demo`),
  porque os ids precisam bater (a ferramenta confere ao vivo e para se não bater).
  O POST de situação GRAVA no banco do servidor (RESERVADO no imóvel alvo): só rode contra o SQLite temporário.
  O grupo prova ao vivo o 404 de outra empresa no detalhe E no histórico (mesmo corpo `{detail}`, IDOR).

  Procedimento com o código da `origin/main` (o clone do web pode estar em qualquer branch, D-19; nada é escrito
  no clone nem exigido dele):
    CLONE=/caminho/do/clone/imoveis-aqui; PY="$CLONE/Web/.venv/bin/python"
    EXTRACAO="$(mktemp -d "${TMPDIR:-/tmp}/imoveis-main-09.XXXXXX")"
    git -C "$CLONE" archive origin/main Web | tar -x -C "$EXTRACAO"
  Em "$EXTRACAO/Web", com DEBUG=True DJANGO_SECRET_KEY=captura-local DATABASE_URL="sqlite:///$EXTRACAO/captura.sqlite3":
    migrate --noinput; semear_vitrine_dev; seed_demo (nessa ordem); defina a senha descartável do corretor demo
    com `manage.py shell -c` lendo `os.environ`; suba `runserver 127.0.0.1:8000 --noreload` e rode, na raiz do
    app, `python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo situacao`.
  No fim: encerre o servidor, confira a porta 8000 livre, apague "$EXTRACAO" e limpe as variáveis CAPTURA_*.

Grupo contatos (Fase 10; só contra o SQLite temporário: cada POST público grava um Contato):

  Variáveis usadas: CAPTURA_EMAIL_CORRETOR e CAPTURA_SENHA_CORRETOR (corretor da empresa demo da vitrine, a
  empresa A) e CAPTURA_EMAIL_OUTRA_EMPRESA e CAPTURA_SENHA_OUTRA_EMPRESA (corretor da empresa B, do
  `seed_demo`). Nada de senha ou token em arquivo; o token nunca é salvo nem impresso.

  Passos extras no SQLite temporário (além dos do grupo acervo: `migrate`, `semear_vitrine_dev`, `seed_demo` e a
  senha descartável do corretor demo):
    - crie o contato da empresa B ANTES da captura: o único imóvel dela (`DEMO-CASA-01`) está VENDIDO, fora da
      vitrine, e a rota pública recusaria o POST. Com `manage.py shell -c`, crie 1 `Contato` com
      `empresa_id` do imóvel, `imovel` = ele, `corretor` = o corretor responsável dele e canal `TELEFONE` (o mesmo
      `Contato.objects.create` de `registrar_contato`). Sem ele a checagem de isolamento seria vazia e nunca
      falharia; a captura exige exatamente 1 contato na caixa da empresa B.
  Taxa: na `main` o POST público de contato não tem limite de taxa; se o `settings.py` tiver
  CONTATO_TAXA_ANONIMA, suba o servidor com CONTATO_TAXA_ANONIMA=1000/min (os 25 POSTs saem em sequência).
  Ordem do grupo: 25 POSTs públicos (até 3 imóveis da vitrine do corretor, 3 canais) -> resumo (25) -> lista p1
  (20) -> p2 (5, seguindo o `next` real) -> filtro por imóvel -> período sem contato -> opções do filtro -> PATCH
  FALEI (200) -> resumo (24) -> PATCH PENDENTE (400) -> caixa da empresa B (1 contato) -> PATCH cruzado (404);
  por fim confere, sem salvar, o PATCH da A no contato da B (404), a lista sem token (401) e `?page=99` (404).

Grupo gestor (Fase 12; só contra o SQLite temporário: o grupo GRAVA no banco — 4 contatos públicos, 1 PATCH e 2
mudanças de situação):

  Variáveis usadas (6; nada de e-mail, senha ou token em arquivo, e o token nunca é salvo nem impresso):
  CAPTURA_EMAIL_CORRETOR e CAPTURA_SENHA_CORRETOR (corretor demo da empresa A, a da vitrine),
  CAPTURA_EMAIL_GESTOR_VITRINE e CAPTURA_SENHA_GESTOR_VITRINE (gestor da empresa A, criado só no SQLite
  temporário) e CAPTURA_EMAIL_GESTOR e CAPTURA_SENHA_GESTOR (gestor da empresa B, do `seed_demo`).

  Passos extras no SQLite temporário (além de `migrate`, `semear_vitrine_dev` e `seed_demo`, nessa ordem), num
  único `manage.py shell -c` que lê tudo de `os.environ` (nenhum seed nem arquivo do repo web muda):
    - senha descartável do corretor demo (como no grupo acervo);
    - o gestor da empresa A (perfil gestor, mesma empresa do corretor demo) com a senha descartável de
      CAPTURA_SENHA_GESTOR_VITRINE;
    - um corretor ativo SEM nenhum imóvel na empresa A (a linha "Nenhum imóvel" do relatório);
    - a mudança antiga: o imóvel do corretor demo de maior `codigo` (Z) vira RESERVADO por `update`, com um
      `HistoricoSituacao` DISPONIVEL -> RESERVADO cujo `alterado_em` é 10 dias atrás (fora dos 7 dias padrão,
      dentro de `?dias=30`: a janela é provada nos dois sentidos).
  O acervo do corretor precisa ter 36 imóveis e exatamente 1 RESERVADO (o Z); a ferramenta para com a dica se não.

  Ordem do grupo: login dos 3 usuários -> acervo inteiro do corretor -> escolhe X e Y (DISPONIVEL, do corretor,
  na vitrine) e W (de outro corretor, na vitrine, responsável desativado) -> 4 contatos públicos (X WHATSAPP,
  X TELEFONE, Y EMAIL, W WHATSAPP) -> PATCH FALEI -> X RESERVADO e Y VENDIDO -> os 4 relatórios do gestor A
  (acervo, acervo por corretor, contatos, contatos de janeiro de 2024, 400 de período, mudanças, `?dias=30`,
  400 de dias) -> 403 do corretor e 401 do anônimo nas 4 rotas -> relatórios do gestor da empresa B.
  Porta: suba o servidor temporário em 127.0.0.1:8012, NUNCA na 8000 (o servidor do desenvolvedor costuma estar
  nela, contra o Postgres dele); as respostas dos relatórios não têm URL absoluta, então a porta não entra nas
  fixtures. Suba com `LOGIN_TAXA_POR_EMAIL=100/hour LOGIN_TAXA_POR_IP=100/hour` (a captura faz vários logins).

Grupo fotos (Fase 11; o grupo GRAVA fotos no servidor — 3 + 28 envios — e apaga todas no fim):

  Variáveis usadas (6; nada de e-mail, senha ou token em arquivo): CAPTURA_EMAIL_CORRETOR e CAPTURA_SENHA_CORRETOR
  (corretor demo da empresa A, a da vitrine), CAPTURA_EMAIL_OUTRA_EMPRESA e CAPTURA_SENHA_OUTRA_EMPRESA (corretor da
  empresa B, do `seed_demo`) e CAPTURA_EMAIL_GESTOR e CAPTURA_SENHA_GESTOR (gestor do `seed_demo`: o perfil gestor
  recebe 403 nas rotas de fotos, de qualquer empresa).

  Rode o servidor a partir de uma EXTRAÇÃO da branch (`git archive feat/APP11 Web | tar -x -C "$EXTRACAO"`), não do
  clone: as fotos enviadas vão para o `media/` da extração, que é apagada no fim. Em "$EXTRACAO/Web", com
  DEBUG=True DJANGO_SECRET_KEY=captura-local DATABASE_URL="sqlite:///$EXTRACAO/captura.sqlite3" (caminho com letra de
  drive no Windows, `cygpath -m`): `migrate --noinput`, `semear_vitrine_dev`, `seed_demo` e a senha descartável do
  corretor demo com `manage.py shell -c` lendo `os.environ`. Suba `runserver 127.0.0.1:8011 --noreload` (NUNCA a
  8000) com `LOGIN_TAXA_POR_EMAIL=100/hour LOGIN_TAXA_POR_IP=100/hour`. As URLs de `imagem` nas fixtures levam esse
  host (`http://127.0.0.1:8011/media/...`); o app não depende do host.

  Ordem do grupo: login dos 3 -> acha DEV-CAMPINAS-11 (sem foto no seed) pelo acervo -> lista vazia -> 3 envios (o
  primeiro vira capa) -> lista -> PUT ordem invertida -> PUT com id repetido (400, nada muda) -> capa na do meio ->
  DELETE dessa capa (promove a primeira restante, ordens 0..1) -> 400 de tipo, de tamanho (5 MB + 1) e de dois
  arquivos -> 404 da empresa B nas 5 rotas (só a lista vira fixture) -> 403 do gestor -> 401 sem token -> completa 30
  e a 31ª dá o 400 do teto -> apaga todas e confere a lista vazia.
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path


class ErroCaptura(Exception):
    """Resposta inesperada da API durante a captura."""


def obter(url, status_esperado=200, token=None):
    """GET em `url`; devolve o JSON já decodificado. Exige `status_esperado`.

    Com `token`, manda `Authorization: Token <token>` (rotas autenticadas da Fase 8).
    """
    cabecalhos = {"Accept": "application/json"}
    if token:
        cabecalhos["Authorization"] = f"Token {token}"
    requisicao = urllib.request.Request(url, headers=cabecalhos)
    return _executar(requisicao, url, status_esperado)


def postar(url, corpo, token=None, status_esperado=200):
    """POST de `corpo` como JSON em `url`; devolve o JSON decodificado (ou `None` se o corpo vier vazio, 204)."""
    cabecalhos = {"Accept": "application/json", "Content-Type": "application/json"}
    if token:
        cabecalhos["Authorization"] = f"Token {token}"
    requisicao = urllib.request.Request(
        url,
        data=json.dumps(corpo).encode("utf-8"),
        headers=cabecalhos,
        method="POST",
    )
    return _executar(requisicao, url, status_esperado)


def enviar_patch(url, corpo, token=None, status_esperado=200):
    """PATCH de `corpo` como JSON em `url`; devolve o JSON decodificado. Exige `status_esperado`."""
    cabecalhos = {"Accept": "application/json", "Content-Type": "application/json"}
    if token:
        cabecalhos["Authorization"] = f"Token {token}"
    requisicao = urllib.request.Request(
        url,
        data=json.dumps(corpo).encode("utf-8"),
        headers=cabecalhos,
        method="PATCH",
    )
    return _executar(requisicao, url, status_esperado)


def _executar(requisicao, url, status_esperado):
    """Envia a requisição e confere o status; decodifica o JSON (corpo vazio vira `None`)."""
    try:
        with urllib.request.urlopen(requisicao, timeout=30) as resposta:
            status = resposta.status
            corpo = resposta.read().decode("utf-8")
    except urllib.error.HTTPError as erro:
        status = erro.code
        corpo = erro.read().decode("utf-8")
    except urllib.error.URLError as erro:
        raise ErroCaptura(f"Não foi possível acessar {url}: {erro.reason}") from erro
    if status != status_esperado:
        raise ErroCaptura(f"{url} respondeu {status}; esperado {status_esperado}.")
    if not corpo.strip():
        return None
    try:
        return json.loads(corpo)
    except json.JSONDecodeError as erro:
        raise ErroCaptura(f"{url} não devolveu JSON válido: {erro}") from erro


def salvar(pasta, nome, dados):
    """Grava `dados` em <pasta>/<nome>.json, como recebido (sem reordenar chaves)."""
    caminho = pasta / f"{nome}.json"
    caminho.write_text(
        json.dumps(dados, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"  gravado {caminho}")


def capturar_lista(base, pasta):
    """Cidades, listas de Campinas (p1, p2, CASA,LOTE, vazia), bairros, características e o 400."""
    publico = f"{base}/api/publico"

    cidades = obter(f"{publico}/cidades/")
    if not isinstance(cidades, list):
        raise ErroCaptura("/api/publico/cidades/ deveria devolver uma lista.")
    campinas = next((c for c in cidades if c.get("nome") == "Campinas"), None)
    if campinas is None:
        raise ErroCaptura("Campinas não está em /api/publico/cidades/ (o seed rodou?).")
    salvar(pasta, "cidades", cidades)
    id_campinas = campinas["id"]
    print(f"  Campinas = id {id_campinas}")

    imoveis = f"{publico}/cidades/{id_campinas}/imoveis/"

    p1 = obter(imoveis)
    if not p1.get("next"):
        raise ErroCaptura("A primeira página de Campinas deveria ter `next` (seed com 24 imóveis).")
    salvar(pasta, "lista_campinas_p1", p1)

    p2 = obter(p1["next"])
    if not p2.get("previous"):
        raise ErroCaptura("A segunda página de Campinas deveria apontar `previous`.")
    salvar(pasta, "lista_campinas_p2", p2)

    casa_lote = obter(f"{imoveis}?{urllib.parse.urlencode({'natureza': 'CASA,LOTE'})}")
    if not casa_lote.get("results"):
        raise ErroCaptura("A lista natureza=CASA,LOTE deveria ter resultados.")
    salvar(pasta, "lista_campinas_casa_lote", casa_lote)

    vazia = obter(f"{imoveis}?{urllib.parse.urlencode({'busca': 'nada-encontrado-zzz'})}")
    if vazia.get("results") != []:
        raise ErroCaptura("A busca por 'nada-encontrado-zzz' deveria devolver results vazio.")
    salvar(pasta, "lista_campinas_vazia", vazia)

    bairros = obter(f"{publico}/cidades/{id_campinas}/bairros/")
    if not isinstance(bairros, list) or not bairros:
        raise ErroCaptura("Os bairros de Campinas deveriam ser uma lista não vazia.")
    salvar(pasta, "bairros_campinas", bairros)

    caracteristicas = obter(f"{publico}/caracteristicas/")
    if not isinstance(caracteristicas, list) or not caracteristicas:
        raise ErroCaptura("As características deveriam ser uma lista não vazia.")
    salvar(pasta, "caracteristicas", caracteristicas)

    erro = obter(
        f"{imoveis}?{urllib.parse.urlencode({'natureza': 'XYZ'})}", status_esperado=400
    )
    if "natureza" not in erro:
        raise ErroCaptura("O 400 de natureza inválida deveria trazer a chave `natureza`.")
    salvar(pasta, "erro_400_natureza", erro)


def _itens_de_campinas(base):
    """Itens da p1 e da p2 de Campinas lidos ao vivo (id de Campinas vem de /cidades/)."""
    publico = f"{base}/api/publico"
    cidades = obter(f"{publico}/cidades/")
    campinas = next((c for c in cidades if c.get("nome") == "Campinas"), None)
    if campinas is None:
        raise ErroCaptura("Campinas não está em /api/publico/cidades/ (o seed rodou?).")
    p1 = obter(f"{publico}/cidades/{campinas['id']}/imoveis/")
    if not p1.get("next"):
        raise ErroCaptura("A primeira página de Campinas deveria ter `next` (seed com 24 imóveis).")
    p2 = obter(p1["next"])
    return p1["results"] + p2["results"], p1["results"]


def capturar_detalhe(base, pasta):
    """Um detalhe por natureza, o sem fotos, o sem corretor e o 404 fora da vitrine."""
    publico = f"{base}/api/publico"
    itens, itens_p1 = _itens_de_campinas(base)

    for natureza in ("CASA", "APARTAMENTO", "TERRENO", "LOTE"):
        item = next(
            (i for i in itens_p1 if i["natureza"] == natureza and i.get("foto_capa")), None
        )
        if item is None:
            raise ErroCaptura(f"A p1 de Campinas não tem {natureza} com foto_capa.")
        detalhe = obter(f"{publico}/imoveis/{item['id']}/")
        if not detalhe.get("fotos"):
            raise ErroCaptura(f"O detalhe {item['id']} ({natureza}) deveria ter fotos.")
        if not detalhe.get("corretor_responsavel"):
            raise ErroCaptura(f"O detalhe {item['id']} ({natureza}) deveria ter corretor.")
        salvar(pasta, f"detalhe_{natureza.lower()}", detalhe)
        print(f"  {natureza} = id {item['id']}")

    sem_foto = next((i for i in itens if i.get("foto_capa") is None), None)
    if sem_foto is None:
        raise ErroCaptura("Nenhum item de Campinas (p1+p2) com foto_capa nula.")
    detalhe = obter(f"{publico}/imoveis/{sem_foto['id']}/")
    if detalhe.get("fotos") != []:
        raise ErroCaptura(f"O detalhe {sem_foto['id']} deveria ter fotos vazio.")
    salvar(pasta, "detalhe_sem_fotos", detalhe)
    print(f"  sem fotos = id {sem_foto['id']}")

    for item in itens:
        detalhe = obter(f"{publico}/imoveis/{item['id']}/")
        if detalhe.get("corretor_responsavel") is None:
            salvar(pasta, "detalhe_sem_corretor", detalhe)
            print(f"  sem corretor = id {item['id']}")
            break
    else:
        raise ErroCaptura("Nenhum detalhe de Campinas (p1+p2) com corretor_responsavel nulo.")

    erro = obter(f"{publico}/imoveis/999999/", status_esperado=404)
    if "detail" not in erro:
        raise ErroCaptura("O 404 do detalhe deveria trazer a chave `detail`.")
    salvar(pasta, "erro_404_detalhe", erro)


_CANAIS_ESPERADOS = ["WHATSAPP", "TELEFONE", "EMAIL"]
_PREFIXO_DO_LINK = {
    "WHATSAPP": "https://wa.me/",
    "TELEFONE": "tel:+",
    "EMAIL": "mailto:",
}


def capturar_contato(base, pasta):
    """POST de contato de uma casa de Campinas: 201 de cada canal e o 400 de canal inválido.

    Cada POST grava um Contato no banco do servidor: só rode contra o SQLite temporário.
    """
    publico = f"{base}/api/publico"
    _, itens_p1 = _itens_de_campinas(base)
    item = next(
        (i for i in itens_p1 if i["natureza"] == "CASA" and i.get("foto_capa")), None
    )
    if item is None:
        raise ErroCaptura("A p1 de Campinas não tem CASA com foto_capa.")
    detalhe = obter(f"{publico}/imoveis/{item['id']}/")
    if detalhe.get("canais_contato") != _CANAIS_ESPERADOS:
        raise ErroCaptura(
            f"O detalhe {item['id']} deveria ter canais_contato {_CANAIS_ESPERADOS}; "
            f"veio {detalhe.get('canais_contato')!r} (servidor sem a feat/APP06?)."
        )
    print(f"  CASA = id {item['id']}")

    url = f"{publico}/imoveis/{item['id']}/contato/"
    for canal in _CANAIS_ESPERADOS:
        resposta = postar(url, {"canal": canal}, status_esperado=201)
        if set(resposta) != {"canal", "link"}:
            raise ErroCaptura(f"O 201 de {canal} deveria ter só `canal` e `link`: {sorted(resposta)}.")
        if resposta["canal"] != canal:
            raise ErroCaptura(f"O 201 de {canal} devolveu canal {resposta['canal']!r}.")
        link = resposta["link"]
        if not link.startswith(_PREFIXO_DO_LINK[canal]):
            raise ErroCaptura(f"O link de {canal} deveria começar com {_PREFIXO_DO_LINK[canal]}: {link}")
        if canal == "WHATSAPP":
            # Servidor sem a correção do 06-02 codifica o espaço como '+': nunca capturar.
            if "+" in link:
                raise ErroCaptura(
                    f"O link do WhatsApp tem '+' (servidor sem a codificação %20 do 06-02): {link}"
                )
            if "%20" not in link:
                raise ErroCaptura(f"O link do WhatsApp deveria ter %20 entre as palavras: {link}")
        salvar(pasta, f"contato_201_{canal.lower()}", resposta)

    erro = postar(url, {"canal": "SMS"}, status_esperado=400)
    if not isinstance(erro.get("canal"), list) or not erro["canal"]:
        raise ErroCaptura("O 400 de canal inválido deveria trazer a lista `canal`.")
    salvar(pasta, "erro_400_canal_contato", erro)


def _anunciantes_ao_vivo(base):
    """Ids `(id_corretor, id_empresa)` lidos ao vivo: o corretor responsável de um detalhe de Campinas."""
    publico = f"{base}/api/publico"
    itens, _ = _itens_de_campinas(base)
    for item in itens:
        detalhe = obter(f"{publico}/imoveis/{item['id']}/")
        corretor = detalhe.get("corretor_responsavel")
        if corretor and corretor.get("empresa_id") is not None:
            return corretor["id"], corretor["empresa_id"]
    raise ErroCaptura(
        "Nenhum detalhe de Campinas (p1+p2) com corretor_responsavel e empresa (o seed rodou?)."
    )


def capturar_perfis(base, pasta):
    """Perfil do corretor, perfil da empresa e o 404 de perfil inexistente."""
    publico = f"{base}/api/publico"
    id_corretor, id_empresa = _anunciantes_ao_vivo(base)

    corretor = obter(f"{publico}/corretores/{id_corretor}/")
    if corretor.get("id") != id_corretor or corretor.get("empresa_id") != id_empresa:
        raise ErroCaptura("O perfil do corretor não bate com o corretor responsável do detalhe.")
    salvar(pasta, "perfil_corretor", corretor)
    print(f"  corretor = id {id_corretor}")

    empresa = obter(f"{publico}/empresas/{id_empresa}/")
    if empresa.get("id") != id_empresa or not empresa.get("cidades_atuacao"):
        raise ErroCaptura("O perfil da empresa deveria ter o id pedido e cidades_atuacao.")
    salvar(pasta, "perfil_empresa", empresa)
    print(f"  empresa = id {id_empresa}")

    erro = obter(f"{publico}/corretores/999999/", status_esperado=404)
    if "detail" not in erro:
        raise ErroCaptura("O 404 de perfil deveria trazer a chave `detail`.")
    salvar(pasta, "erro_404_perfil", erro)


def capturar_anunciante(base, pasta):
    """Vitrine de imóveis do corretor e da empresa (p1 e p2 seguindo o `next` real)."""
    publico = f"{base}/api/publico"
    ids = dict(zip(("corretor", "empresa"), _anunciantes_ao_vivo(base)))

    for recurso, plural in (("corretor", "corretores"), ("empresa", "empresas")):
        p1 = obter(f"{publico}/{plural}/{ids[recurso]}/imoveis/")
        if not p1.get("next") or not p1.get("results"):
            raise ErroCaptura(
                f"A vitrine do {recurso} deveria ter `next` e resultados na primeira página."
            )
        salvar(pasta, f"vitrine_{recurso}_p1", p1)

        p2 = obter(p1["next"])
        if not p2.get("previous"):
            raise ErroCaptura(f"A segunda página da vitrine do {recurso} deveria apontar `previous`.")
        salvar(pasta, f"vitrine_{recurso}_p2", p2)
        print(f"  {recurso} = id {ids[recurso]} ({p1['count']} imóveis)")


TOKEN_REDIGIDO = "0" * 40


def _credencial(nome):
    """Lê a credencial da variável de ambiente `nome`; sem ela a captura para (nada de senha em arquivo)."""
    valor = os.environ.get(nome)
    if not valor:
        raise ErroCaptura(
            f"defina a variável {nome}; credenciais nunca vão para arquivo."
        )
    return valor


def _entrar(base, nome_email, nome_senha):
    """Login pela API; devolve a chave (só em memória). Exige o corpo exatamente `{token}`."""
    resposta = postar(
        f"{base}/api/auth/login/",
        {"email": _credencial(nome_email), "password": _credencial(nome_senha)},
    )
    if not isinstance(resposta, dict) or set(resposta) != {"token"} or not resposta["token"]:
        raise ErroCaptura("O 200 do login deveria ter exatamente a chave `token`, não vazia.")
    return resposta["token"]


def capturar_acervo(base, pasta):
    """Login, eu, acervo do corretor (p1, p2, busca, situação vazia), outra empresa, gestor (403) e Sair."""
    auth = f"{base}/api/auth"
    imoveis = f"{base}/api/imoveis/"

    erro_401 = obter(f"{auth}/eu/", status_esperado=401)
    if "detail" not in erro_401:
        raise ErroCaptura("O 401 deveria trazer a chave `detail`.")
    salvar(pasta, "erro_401", erro_401)

    erro_400 = postar(
        f"{auth}/login/",
        {"email": _credencial("CAPTURA_EMAIL_CORRETOR"), "password": "senha-errada-captura"},
        status_esperado=400,
    )
    if not isinstance(erro_400, dict) or not erro_400:
        raise ErroCaptura("O 400 do login deveria trazer um objeto de erro.")
    salvar(pasta, "erro_400_login", erro_400)

    token_corretor = _entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")
    # a chave real nunca vai para arquivo: a fixture guarda só o formato `{token}`
    salvar(pasta, "login_200", {"token": TOKEN_REDIGIDO})

    eu_corretor = obter(f"{auth}/eu/", token=token_corretor)
    if eu_corretor.get("perfil") != "CORRETOR":
        raise ErroCaptura("O `eu` do corretor deveria ter perfil CORRETOR.")
    salvar(pasta, "eu_corretor", eu_corretor)

    p1 = obter(imoveis, token=token_corretor)
    if not p1.get("next") or len(p1.get("results", [])) != 20:
        raise ErroCaptura("A p1 do acervo deveria ter `next` e 20 resultados (seed com 36 imóveis).")
    salvar(pasta, "acervo_p1", p1)

    p2 = obter(p1["next"], token=token_corretor)
    if not p2.get("previous"):
        raise ErroCaptura("A segunda página do acervo deveria apontar `previous`.")
    salvar(pasta, "acervo_p2", p2)

    busca = obter(
        f"{imoveis}?{urllib.parse.urlencode({'busca': 'DEV-CAMPINAS-14'})}", token=token_corretor
    )
    if busca.get("count") != 1:
        raise ErroCaptura("A busca por DEV-CAMPINAS-14 deveria devolver exatamente 1 imóvel.")
    salvar(pasta, "acervo_busca", busca)

    vazia = obter(
        f"{imoveis}?{urllib.parse.urlencode({'situacao': 'VENDIDO'})}", token=token_corretor
    )
    if vazia.get("count") != 0:
        raise ErroCaptura("situacao=VENDIDO deveria devolver count 0 para o corretor da empresa demo.")
    salvar(pasta, "acervo_situacao_vazia", vazia)

    token_outra = _entrar(base, "CAPTURA_EMAIL_OUTRA_EMPRESA", "CAPTURA_SENHA_OUTRA_EMPRESA")
    outra = obter(imoveis, token=token_outra)
    if any(item["codigo"].startswith("DEV-") for item in outra.get("results", [])):
        raise ErroCaptura("O acervo da outra empresa não pode trazer imóvel da empresa demo (DEV-*).")
    salvar(pasta, "acervo_outra_empresa", outra)

    token_gestor = _entrar(base, "CAPTURA_EMAIL_GESTOR", "CAPTURA_SENHA_GESTOR")
    eu_gestor = obter(f"{auth}/eu/", token=token_gestor)
    if eu_gestor.get("perfil") != "GESTOR":
        raise ErroCaptura("O `eu` do gestor deveria ter perfil GESTOR.")
    salvar(pasta, "eu_gestor", eu_gestor)

    erro_403 = obter(imoveis, status_esperado=403, token=token_gestor)
    if "detail" not in erro_403:
        raise ErroCaptura("O 403 do acervo deveria trazer a chave `detail`.")
    salvar(pasta, "erro_403_acervo", erro_403)

    # só confere (não salva): o Sair revoga a chave do corretor e a mesma chave passa a dar 401
    postar(f"{auth}/sair/", {}, token=token_corretor, status_esperado=204)
    obter(f"{auth}/eu/", status_esperado=401, token=token_corretor)
    print("  Sair conferido (204 e a mesma chave passou a dar 401)")


CHAVES_LIDAS_DO_IMOVEL = (
    "id",
    "codigo",
    "titulo",
    "finalidade",
    "preco_venda",
    "preco_aluguel",
    "situacao",
    "situacao_desde",
    "pode_mudar_situacao",
)
CHAVES_DO_HISTORICO = (
    "id",
    "situacao_anterior",
    "situacao_nova",
    "alterado_por",
    "alterado_em",
    "observacao",
)
OBSERVACAO_DA_CAPTURA = "Reservado na conversa com o cliente."


def _ler_fixture(pasta, nome):
    """Lê <pasta>/<nome>.json já versionado; sem ele a captura do grupo para."""
    caminho = pasta / f"{nome}.json"
    if not caminho.is_file():
        raise ErroCaptura(f"falta {caminho}; rode antes o grupo acervo.")
    return json.loads(caminho.read_text(encoding="utf-8"))


def _exigir_chaves(dados, chaves, descricao):
    """Exige que `dados` seja um objeto com todas as `chaves`."""
    if not isinstance(dados, dict):
        raise ErroCaptura(f"{descricao} deveria ser um objeto.")
    faltando = [chave for chave in chaves if chave not in dados]
    if faltando:
        raise ErroCaptura(f"{descricao} sem as chaves {faltando}.")


def _exigir_detail(corpo, descricao):
    """Exige o corpo `{detail}` (recusa 403/404 do DRF)."""
    if not isinstance(corpo, dict) or set(corpo) != {"detail"} or not corpo["detail"]:
        raise ErroCaptura(f"{descricao} deveria ter exatamente a chave `detail`: {corpo!r}.")


def capturar_situacao(base, pasta):
    """Wire da mudança de situação: detalhe, POST, histórico, recusas e 404 de outra empresa.

    O POST grava no banco do servidor: só rode contra o SQLite temporário.
    """
    imoveis = f"{base}/api/imoveis/"
    auth = f"{base}/api/auth"

    p1 = _ler_fixture(pasta, "acervo_p1")["results"][0]
    if not p1.get("meu_imovel") or p1.get("situacao") != "DISPONIVEL":
        raise ErroCaptura("o primeiro item de acervo_p1 deveria ser meu_imovel e DISPONIVEL.")
    alvo = p1["id"]
    alheio_item = _ler_fixture(pasta, "acervo_busca")["results"][0]
    if alheio_item.get("meu_imovel"):
        raise ErroCaptura("o item de acervo_busca deveria ser de outro corretor (meu_imovel falso).")
    alheio = alheio_item["id"]
    contrato_item = next(
        (i for i in _ler_fixture(pasta, "acervo_outra_empresa")["results"] if i.get("codigo") == "DEMO-CASA-01"),
        None,
    )
    if contrato_item is None:
        raise ErroCaptura("acervo_outra_empresa não traz o imóvel DEMO-CASA-01.")
    contrato = contrato_item["id"]
    print(f"  alvo = id {alvo}, alheio = id {alheio}, contrato assinado = id {contrato}")

    token = _entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")

    primeira = obter(imoveis, token=token)["results"][0]
    if primeira.get("id") != alvo or primeira.get("codigo") != p1["codigo"]:
        raise ErroCaptura(
            "os ids do banco não batem com acervo_p1/acervo_busca; recrie o banco na ordem "
            "migrate → semear_vitrine_dev → seed_demo."
        )
    busca = obter(
        f"{imoveis}?{urllib.parse.urlencode({'busca': alheio_item['codigo']})}", token=token
    )
    if [i["id"] for i in busca.get("results", [])] != [alheio]:
        raise ErroCaptura(
            "os ids do banco não batem com acervo_p1/acervo_busca; recrie o banco na ordem "
            "migrate → semear_vitrine_dev → seed_demo."
        )

    # só confere: sem token a escrita é recusada (o corpo do 401 já está em erro_401.json)
    sem_token = postar(f"{imoveis}{alvo}/situacao/", {"situacao": "RESERVADO"}, status_esperado=401)
    if not isinstance(sem_token, dict) or "detail" not in sem_token:
        raise ErroCaptura("o 401 do POST de situação deveria trazer `detail`.")

    disponivel = obter(f"{imoveis}{alvo}/", token=token)
    _exigir_chaves(disponivel, CHAVES_LIDAS_DO_IMOVEL, "o detalhe do imóvel")
    if disponivel["pode_mudar_situacao"] is not True or disponivel["situacao"] != "DISPONIVEL":
        raise ErroCaptura("o detalhe do alvo deveria ser DISPONIVEL com pode_mudar_situacao verdadeiro.")
    salvar(pasta, "imovel_gestao_disponivel", disponivel)

    vazio = obter(f"{imoveis}{alvo}/historico/", token=token)
    if vazio != []:
        raise ErroCaptura("o histórico do alvo deveria começar vazio (banco recém-semeado).")
    salvar(pasta, "historico_vazio", vazio)

    corpo = {"situacao": "RESERVADO", "observacao": OBSERVACAO_DA_CAPTURA}
    mudou = postar(f"{imoveis}{alvo}/situacao/", corpo, token=token, status_esperado=200)
    _exigir_chaves(mudou, CHAVES_LIDAS_DO_IMOVEL, "o 200 da mudança de situação")
    if mudou["situacao"] != "RESERVADO":
        raise ErroCaptura("o 200 da mudança deveria trazer situacao RESERVADO.")
    salvar(pasta, "situacao_200", mudou)

    reservado = obter(f"{imoveis}{alvo}/", token=token)
    _exigir_chaves(reservado, CHAVES_LIDAS_DO_IMOVEL, "o detalhe relido")
    if reservado["situacao"] != "RESERVADO":
        raise ErroCaptura("o detalhe relido deveria estar RESERVADO.")
    if reservado["situacao_desde"] == disponivel["situacao_desde"]:
        raise ErroCaptura("situacao_desde deveria mudar depois da mudança de situação.")
    salvar(pasta, "imovel_gestao_reservado", reservado)

    historico = obter(f"{imoveis}{alvo}/historico/", token=token)
    if not isinstance(historico, list) or len(historico) != 1:
        raise ErroCaptura("o histórico do alvo deveria ter exatamente 1 item depois da mudança.")
    item = historico[0]
    if set(item) != set(CHAVES_DO_HISTORICO):
        raise ErroCaptura(f"o item do histórico deveria ter as chaves {sorted(CHAVES_DO_HISTORICO)}: {sorted(item)}.")
    if (
        item["situacao_anterior"] != "DISPONIVEL"
        or item["situacao_nova"] != "RESERVADO"
        or item["observacao"] != OBSERVACAO_DA_CAPTURA
    ):
        raise ErroCaptura("o item do histórico deveria ser DISPONIVEL → RESERVADO com a observação enviada.")
    salvar(pasta, "historico_um_item", historico)

    mesma = postar(f"{imoveis}{alvo}/situacao/", {"situacao": "RESERVADO"}, token=token, status_esperado=400)
    if (
        not isinstance(mesma, dict)
        or set(mesma) != {"situacao"}
        or not isinstance(mesma["situacao"], list)
        or not mesma["situacao"]
    ):
        raise ErroCaptura(f"o 400 de mesma situação deveria ser {{situacao: [...]}}: {mesma!r}.")
    salvar(pasta, "erro_400_mesma_situacao", mesma)

    sem_permissao = obter(f"{imoveis}{alheio}/", token=token)
    _exigir_chaves(sem_permissao, CHAVES_LIDAS_DO_IMOVEL, "o detalhe do imóvel do colega")
    if sem_permissao["pode_mudar_situacao"] is not False:
        raise ErroCaptura("o imóvel do colega deveria ter pode_mudar_situacao falso.")
    salvar(pasta, "imovel_gestao_sem_permissao", sem_permissao)

    recusa = postar(f"{imoveis}{alheio}/situacao/", {"situacao": "RESERVADO"}, token=token, status_esperado=403)
    _exigir_detail(recusa, "o 403 do colega")
    salvar(pasta, "erro_403_situacao", recusa)

    token_outra = _entrar(base, "CAPTURA_EMAIL_OUTRA_EMPRESA", "CAPTURA_SENHA_OUTRA_EMPRESA")
    achado = obter(f"{imoveis}?{urllib.parse.urlencode({'busca': 'DEMO-CASA-01'})}", token=token_outra)
    if [i["id"] for i in achado.get("results", [])] != [contrato]:
        raise ErroCaptura(
            "o id de DEMO-CASA-01 não bate com acervo_outra_empresa; recrie o banco na ordem "
            "migrate → semear_vitrine_dev → seed_demo."
        )
    assinado = postar(
        f"{imoveis}{contrato}/situacao/", {"situacao": "DISPONIVEL"}, token=token_outra, status_esperado=400
    )
    textos = assinado.get("situacao") if isinstance(assinado, dict) else None
    if not textos or "contrato" not in " ".join(textos).lower():
        raise ErroCaptura(f"o 400 do contrato assinado deveria citar o contrato: {assinado!r}.")
    salvar(pasta, "erro_400_contrato_assinado", assinado)

    do_contrato = obter(f"{imoveis}{contrato}/historico/", token=token_outra)
    if not isinstance(do_contrato, list) or not do_contrato:
        raise ErroCaptura("o histórico do imóvel com contrato deveria ser uma lista não vazia.")
    salvar(pasta, "historico_contrato", do_contrato)

    # IDOR entre empresas (T-09-02): o imóvel ALVO é da empresa demo, o token é da outra
    nao_acha = obter(f"{imoveis}{alvo}/", status_esperado=404, token=token_outra)
    _exigir_detail(nao_acha, "o 404 do detalhe de outra empresa")
    salvar(pasta, "erro_404_imovel", nao_acha)
    nao_acha_historico = obter(f"{imoveis}{alvo}/historico/", status_esperado=404, token=token_outra)
    _exigir_detail(nao_acha_historico, "o 404 do histórico de outra empresa")
    if nao_acha_historico != nao_acha:
        raise ErroCaptura("o histórico de outra empresa não respondeu como o detalhe.")
    salvar(pasta, "erro_404_historico", nao_acha_historico)
    # só confere (não salva): a escrita também não distingue "existe" de "não existe"
    postar(f"{imoveis}{alvo}/situacao/", {"situacao": "DISPONIVEL"}, token=token_outra, status_esperado=404)

    # só confere: revoga as duas chaves
    postar(f"{auth}/sair/", {}, token=token, status_esperado=204)
    postar(f"{auth}/sair/", {}, token=token_outra, status_esperado=204)
    print("  Sair conferido nas duas chaves")


CANAIS_CONTATO = ("WHATSAPP", "TELEFONE", "EMAIL")
_CHAVES_ITEM_CONTATO = 12
_TOTAL_CONTATOS = 25
_POR_PAGINA = 20


def capturar_contatos(base, pasta):
    """Caixa de contatos do corretor: 25 contatos públicos, lista, filtros, resumo, opções, PATCH e isolamento.

    Cada POST público grava um Contato no banco do servidor: só rode contra o SQLite temporário, com o
    contato da empresa B já criado (ver a docstring do arquivo). O token nunca vai para arquivo nem para o print.
    """
    caixa = f"{base}/api/contatos/"
    publico = f"{base}/api/publico"

    token_corretor = _entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")

    acervo = obter(f"{base}/api/imoveis/", token=token_corretor)
    escolhidos = [
        item["id"]
        for item in acervo.get("results", [])
        if item.get("meu_imovel") and item.get("na_vitrine")
    ][:3]
    if len(escolhidos) < 2:
        raise ErroCaptura(
            "O acervo do corretor deveria ter ao menos 2 imóveis dele na vitrine (o seed rodou?)."
        )
    print(f"  imóveis escolhidos = {escolhidos}")

    for i in range(_TOTAL_CONTATOS):
        imovel = escolhidos[i % len(escolhidos)]
        canal = CANAIS_CONTATO[(i // len(escolhidos)) % len(CANAIS_CONTATO)]
        postar(f"{publico}/imoveis/{imovel}/contato/", {"canal": canal}, status_esperado=201)
    print(f"  {_TOTAL_CONTATOS} contatos públicos criados")

    resumo = obter(f"{caixa}resumo/", token=token_corretor)
    if resumo != {"sem_retorno": _TOTAL_CONTATOS}:
        raise ErroCaptura(
            f"O resumo deveria ser {{'sem_retorno': {_TOTAL_CONTATOS}}}; veio {resumo!r} "
            "(um número maior indica contato de outra empresa vazando)."
        )
    salvar(pasta, "contatos_resumo", resumo)

    p1 = obter(caixa, token=token_corretor)
    if p1.get("count") != _TOTAL_CONTATOS or len(p1.get("results", [])) != _POR_PAGINA:
        raise ErroCaptura(
            f"A p1 da caixa deveria ter count {_TOTAL_CONTATOS} e {_POR_PAGINA} resultados; "
            f"veio count {p1.get('count')!r} e {len(p1.get('results', []))} resultados."
        )
    if not str(p1.get("next")).startswith(caixa):
        raise ErroCaptura(f"O `next` da p1 deveria começar com {caixa}: {p1.get('next')!r}.")
    for item in p1["results"]:
        if item.get("retorno") != "PENDENTE" or item.get("retorno_em") is not None:
            raise ErroCaptura(f"O contato {item.get('id')} deveria nascer PENDENTE e sem retorno_em.")
    datas = [item["criado_em"] for item in p1["results"]]
    if datas != sorted(datas, reverse=True):
        raise ErroCaptura("A p1 da caixa deveria vir ordenada por criado_em não crescente.")
    salvar(pasta, "contatos_p1", p1)

    p2 = obter(p1["next"], token=token_corretor)
    if (
        len(p2.get("results", [])) != _TOTAL_CONTATOS - _POR_PAGINA
        or not p2.get("previous")
        or p2.get("next")
    ):
        raise ErroCaptura(
            "A p2 da caixa deveria ter os 5 restantes, `previous` preenchido e `next` nulo."
        )
    salvar(pasta, "contatos_p2", p2)

    do_imovel = obter(
        f"{caixa}?{urllib.parse.urlencode({'imovel': escolhidos[0]})}", token=token_corretor
    )
    if do_imovel.get("count", 0) < 1 or any(
        item["imovel"] != escolhidos[0] for item in do_imovel["results"]
    ):
        raise ErroCaptura("O filtro por imóvel deveria trazer só contatos do imóvel pedido (count >= 1).")
    salvar(pasta, "contatos_imovel", do_imovel)

    periodo_vazio = obter(
        f"{caixa}?{urllib.parse.urlencode({'de': '2024-01-01', 'ate': '2024-01-31'})}",
        token=token_corretor,
    )
    if periodo_vazio.get("count") != 0 or periodo_vazio.get("results") != []:
        raise ErroCaptura("O período de janeiro de 2024 deveria vir com count 0 e results vazio.")
    salvar(pasta, "contatos_periodo_vazio", periodo_vazio)

    opcoes = obter(f"{caixa}imoveis/", token=token_corretor)
    if not isinstance(opcoes, list) or any(set(o) != {"id", "codigo", "titulo"} for o in opcoes):
        raise ErroCaptura("As opções do filtro deveriam ser uma lista de {id, codigo, titulo}.")
    if {o["id"] for o in opcoes} != set(escolhidos):
        raise ErroCaptura(
            f"As opções do filtro deveriam ser exatamente os imóveis com contato {sorted(escolhidos)}; "
            f"vieram {sorted(o['id'] for o in opcoes)} (o imóvel da empresa B nunca pode aparecer)."
        )
    if [o["codigo"] for o in opcoes] != sorted(o["codigo"] for o in opcoes):
        raise ErroCaptura("As opções do filtro deveriam vir ordenadas por código.")
    salvar(pasta, "contatos_imoveis", opcoes)

    id_anotado = p1["results"][0]["id"]
    anotado = enviar_patch(f"{caixa}{id_anotado}/", {"retorno": "FALEI"}, token=token_corretor)
    if (
        len(anotado) != _CHAVES_ITEM_CONTATO
        or anotado.get("retorno") != "FALEI"
        or not anotado.get("retorno_em")
    ):
        raise ErroCaptura("O PATCH FALEI deveria devolver o item de 12 chaves com retorno_em preenchido.")
    salvar(pasta, "contato_patch_200", anotado)

    resumo_apos = obter(f"{caixa}resumo/", token=token_corretor)
    if resumo_apos != {"sem_retorno": _TOTAL_CONTATOS - 1}:
        raise ErroCaptura(
            f"Depois do PATCH o resumo deveria cair para {_TOTAL_CONTATOS - 1}; veio {resumo_apos!r}."
        )
    salvar(pasta, "contatos_resumo_apos", resumo_apos)

    erro_retorno = enviar_patch(
        f"{caixa}{id_anotado}/", {"retorno": "PENDENTE"}, token=token_corretor, status_esperado=400
    )
    if "retorno" not in erro_retorno:
        raise ErroCaptura("O 400 do PATCH PENDENTE deveria trazer a chave `retorno`.")
    salvar(pasta, "erro_400_retorno", erro_retorno)

    token_outra = _entrar(base, "CAPTURA_EMAIL_OUTRA_EMPRESA", "CAPTURA_SENHA_OUTRA_EMPRESA")
    outra = obter(caixa, token=token_outra)
    if outra.get("count") == 0:
        raise ErroCaptura(
            "A caixa da empresa B veio vazia: crie o contato da empresa B no SQLite temporário "
            "antes da captura (ver docstring)."
        )
    if outra.get("count") != 1 or len(outra.get("results", [])) != 1:
        raise ErroCaptura(
            f"A caixa da empresa B deveria ter exatamente 1 contato; veio count {outra.get('count')!r}."
        )
    ids_a = {item["id"] for item in p1["results"] + p2["results"]}
    id_outra = outra["results"][0]["id"]
    if id_outra in ids_a:
        raise ErroCaptura("O contato da empresa B apareceu na caixa da empresa A (isolamento vazou).")
    salvar(pasta, "contatos_outra_empresa", outra)

    erro_404 = enviar_patch(
        f"{caixa}{id_anotado}/", {"retorno": "FALEI"}, token=token_outra, status_esperado=404
    )
    if "detail" not in erro_404:
        raise ErroCaptura("O 404 do PATCH cruzado deveria trazer a chave `detail`.")
    salvar(pasta, "erro_404_contato", erro_404)

    # só confere (não salva): isolamento no outro sentido, anônimo e página inexistente
    enviar_patch(f"{caixa}{id_outra}/", {"retorno": "FALEI"}, token=token_corretor, status_esperado=404)
    obter(caixa, status_esperado=401)
    obter(f"{caixa}?page=99", status_esperado=404, token=token_corretor)
    print("  isolamento conferido nos dois sentidos, anônimo 401 e page=99 404")


ROTAS_DO_GESTOR = (
    "/api/relatorios/acervo/",
    "/api/relatorios/acervo-por-corretor/",
    "/api/relatorios/contatos/",
    "/api/relatorios/mudancas-situacao/",
)
CHAVES_LINHA_ACERVO_CORRETOR = {"corretor_id", "corretor", "ativo", "total"}
CHAVES_LINHA_CONTATOS_CORRETOR = CHAVES_LINHA_ACERVO_CORRETOR | {"pendentes"}
CHAVES_MUDANCA_RECENTE = {
    "id",
    "imovel_id",
    "imovel_codigo",
    "imovel_titulo",
    "situacao_anterior",
    "situacao_nova",
    "alterado_por",
    "alterado_em",
    "observacao",
}
SITUACOES_DO_ACERVO = {"DISPONIVEL", "RESERVADO", "VENDIDO", "ALUGADO"}
OBSERVACAO_GESTOR = "Captura APP-12: reserva para o relatório do gestor."
_TOTAL_ACERVO_EMPRESA_A = 36


def _ler_acervo_inteiro(base, token):
    """Todos os itens de `GET /api/imoveis/` do corretor, seguindo o `next` real."""
    itens = []
    url = f"{base}/api/imoveis/"
    while url:
        pagina = obter(url, token=token)
        itens.extend(pagina["results"])
        url = pagina.get("next")
    return itens


def _exigir_linhas(dados, chaves, descricao):
    """Exige `dados["linhas"]` como lista de objetos com exatamente as `chaves`."""
    linhas = dados.get("linhas")
    if not isinstance(linhas, list):
        raise ErroCaptura(f"{descricao} deveria ter `linhas` como lista.")
    for linha in linhas:
        if not isinstance(linha, dict) or set(linha) != set(chaves):
            raise ErroCaptura(
                f"cada linha de {descricao} deveria ter as chaves {sorted(chaves)}: {linha!r}."
            )
    return linhas


def capturar_gestor(base, pasta):
    """Relatórios da Área do gestor: as 4 rotas, 400/403/401 e a outra empresa.

    O grupo GRAVA no banco do servidor (contatos públicos, PATCH e 2 mudanças de situação): só rode contra o
    SQLite temporário, preparado como na docstring do arquivo. Os números do servidor são conferidos contra o
    acervo real lido pelo corretor (soma, janela, papel e isolamento entre empresas podem falhar de verdade).
    O token nunca vai para arquivo nem para o print; só ids e contagens são impressos.
    """
    relatorios = f"{base}/api/relatorios"
    publico = f"{base}/api/publico"
    imoveis = f"{base}/api/imoveis"

    # (1) login dos três usuários (as chaves ficam só em memória)
    token_corretor = _entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")
    token_gestor = _entrar(base, "CAPTURA_EMAIL_GESTOR_VITRINE", "CAPTURA_SENHA_GESTOR_VITRINE")
    token_gestor_b = _entrar(base, "CAPTURA_EMAIL_GESTOR", "CAPTURA_SENHA_GESTOR")

    # (2) acervo inteiro do corretor e escolha dos imóveis
    acervo = _ler_acervo_inteiro(base, token_corretor)
    if len(acervo) != _TOTAL_ACERVO_EMPRESA_A:
        raise ErroCaptura(
            f"O acervo do corretor deveria ter {_TOTAL_ACERVO_EMPRESA_A} imóveis; veio {len(acervo)}."
        )
    reservados = [i["id"] for i in acervo if i.get("situacao") == "RESERVADO"]
    if len(reservados) != 1:
        raise ErroCaptura(
            f"O acervo deveria ter exatamente 1 RESERVADO (a mudança antiga); veio {len(reservados)}: "
            "crie a mudança antiga no SQLite temporário antes da captura (ver docstring)."
        )
    z = reservados[0]
    candidatos = [
        i["id"]
        for i in acervo
        if i.get("meu_imovel") and i.get("na_vitrine") and i.get("situacao") == "DISPONIVEL"
    ]
    if len(candidatos) < 2:
        raise ErroCaptura("O corretor deveria ter ao menos 2 imóveis DISPONIVEL na vitrine.")
    x, y = candidatos[0], candidatos[1]
    de_outro = [i["id"] for i in acervo if not i.get("meu_imovel") and i.get("na_vitrine")]
    if not de_outro:
        raise ErroCaptura("O acervo deveria ter um imóvel de outro corretor (o desativado) na vitrine.")
    w = de_outro[0]
    detalhe_w = obter(f"{publico}/imoveis/{w}/")
    if detalhe_w["corretor_responsavel"] is not None:
        raise ErroCaptura(f"O imóvel {w} deveria ter corretor_responsavel nulo (responsável desativado).")
    # `canais_contato` só existe no detalhe da feat/APP06; o Django da feat/APP12 (base origin/main) não o traz.
    # O POST de contato abaixo (201 exigido) é a prova de que o canal WHATSAPP é aceito.
    # o corretor demo (responsável de X) lido enquanto X ainda está na vitrine
    detalhe_x = obter(f"{publico}/imoveis/{x}/")
    id_corretor_demo = detalhe_x["corretor_responsavel"]["id"]
    print(f"  X = {x}, Y = {y}, Z (mudança antiga) = {z}, W (corretor desativado) = {w}")
    print(f"  corretor demo = id {id_corretor_demo}")

    # (3) 4 contatos públicos, sem token
    for imovel, canal in ((x, "WHATSAPP"), (x, "TELEFONE"), (y, "EMAIL"), (w, "WHATSAPP")):
        postar(f"{publico}/imoveis/{imovel}/contato/", {"canal": canal}, status_esperado=201)
    print("  4 contatos públicos criados")

    # (4) a caixa do corretor só tem os 3 dele; um deles é anotado como FALEI
    caixa = obter(f"{base}/api/contatos/", token=token_corretor)
    if caixa.get("count") != 3:
        raise ErroCaptura(
            f"A caixa do corretor deveria ter 3 contatos; veio {caixa.get('count')!r} "
            "(o contato do imóvel do desativado vai para a empresa)."
        )
    anotado = enviar_patch(
        f"{base}/api/contatos/{caixa['results'][0]['id']}/", {"retorno": "FALEI"}, token=token_corretor
    )
    if anotado.get("retorno") != "FALEI":
        raise ErroCaptura("O PATCH FALEI deveria devolver retorno FALEI.")

    # (5) duas mudanças de situação, pelo corretor, na ordem X depois Y
    postar(
        f"{imoveis}/{x}/situacao/",
        {"situacao": "RESERVADO", "observacao": OBSERVACAO_GESTOR},
        token=token_corretor,
    )
    postar(f"{imoveis}/{y}/situacao/", {"situacao": "VENDIDO"}, token=token_corretor)

    # (6) o acervo depois das mudanças: as contas que o servidor tem que repetir
    acervo = _ler_acervo_inteiro(base, token_corretor)
    contagem = Counter(i["situacao"] for i in acervo)
    meus = sum(1 for i in acervo if i.get("meu_imovel"))
    print(f"  acervo depois: {dict(contagem)}; do corretor: {meus}")

    # (7) totais por situação do acervo (gestor da empresa A)
    acervo_relatorio = obter(f"{relatorios}/acervo/", token=token_gestor)
    totais = acervo_relatorio.get("totais")
    if not isinstance(totais, dict) or set(totais) != SITUACOES_DO_ACERVO:
        raise ErroCaptura(f"`totais` deveria ter exatamente as 4 situações: {totais!r}.")
    esperados = {s: contagem.get(s, 0) for s in SITUACOES_DO_ACERVO}
    if totais != esperados:
        raise ErroCaptura(f"`totais` {totais!r} não bate com as situações do acervo {esperados!r}.")
    if acervo_relatorio.get("total") != _TOTAL_ACERVO_EMPRESA_A:
        raise ErroCaptura(
            f"`total` do acervo deveria ser {_TOTAL_ACERVO_EMPRESA_A} (37 indica imóvel da empresa B): "
            f"{acervo_relatorio.get('total')!r}."
        )
    salvar(pasta, "relatorio_acervo", acervo_relatorio)

    # (8) acervo por corretor: soma, zero, desativado e linha do corretor demo achada pelo id
    por_corretor = obter(f"{relatorios}/acervo-por-corretor/", token=token_gestor)
    if set(por_corretor) != {"linhas", "total"}:
        raise ErroCaptura(f"O acervo por corretor deveria ter só `linhas` e `total`: {sorted(por_corretor)}.")
    linhas_a = _exigir_linhas(por_corretor, CHAVES_LINHA_ACERVO_CORRETOR, "acervo por corretor")
    if por_corretor["total"] != acervo_relatorio["total"] or por_corretor["total"] != sum(
        linha["total"] for linha in linhas_a
    ):
        raise ErroCaptura("O `total` do acervo por corretor deveria ser o do acervo e a soma das linhas.")
    if not any(linha["ativo"] is True and linha["total"] == 0 for linha in linhas_a):
        raise ErroCaptura("Faltou o corretor ativo sem imóvel (crie o corretor sem acervo; ver docstring).")
    if not any(linha["ativo"] is False and linha["total"] >= 1 for linha in linhas_a):
        raise ErroCaptura("Faltou o corretor desativado com imóvel (o seed rodou?).")
    linha_demo = next((l for l in linhas_a if l["corretor_id"] == id_corretor_demo), None)
    if linha_demo is None or linha_demo["ativo"] is not True or linha_demo["total"] != meus:
        raise ErroCaptura(
            f"A linha do corretor demo ({id_corretor_demo}) deveria ser ativa com total {meus}: {linha_demo!r}."
        )
    totais_linhas = [linha["total"] for linha in linhas_a]
    if totais_linhas != sorted(totais_linhas, reverse=True):
        raise ErroCaptura("As linhas do acervo por corretor deveriam vir com totais não crescentes.")
    salvar(pasta, "relatorio_acervo_por_corretor", por_corretor)

    # (9) contatos de todo o período: a linha da empresa (corretor nulo) e os pendentes
    contatos = obter(f"{relatorios}/contatos/", token=token_gestor)
    linhas_contatos = _exigir_linhas(contatos, CHAVES_LINHA_CONTATOS_CORRETOR, "contatos por corretor")
    if contatos.get("total") != 4 or contatos.get("pendentes") != 3:
        raise ErroCaptura(
            f"Contatos deveria ter total 4 e pendentes 3: {contatos.get('total')!r}/{contatos.get('pendentes')!r}."
        )
    da_empresa = [l for l in linhas_contatos if l["corretor_id"] is None]
    if len(da_empresa) != 1 or da_empresa[0]["total"] != 1:
        raise ErroCaptura(f"Deveria haver 1 linha da empresa com total 1: {da_empresa!r}.")
    if sum(l["total"] for l in linhas_contatos) != contatos["total"] or sum(
        l["pendentes"] for l in linhas_contatos
    ) != contatos["pendentes"]:
        raise ErroCaptura("A soma das linhas de contatos deveria fechar com `total` e `pendentes`.")
    salvar(pasta, "relatorio_contatos", contatos)

    # (10) um período sem contato: os corretores ativos com zero e nenhuma linha da empresa
    periodo = obter(
        f"{relatorios}/contatos/?{urllib.parse.urlencode({'de': '2024-01-01', 'ate': '2024-01-31'})}",
        token=token_gestor,
    )
    linhas_periodo = _exigir_linhas(periodo, CHAVES_LINHA_CONTATOS_CORRETOR, "contatos do período")
    if periodo.get("total") != 0 or periodo.get("pendentes") != 0:
        raise ErroCaptura("Janeiro de 2024 deveria vir com total 0 e pendentes 0.")
    if not linhas_periodo or any(l["corretor_id"] is None or l["total"] != 0 for l in linhas_periodo):
        raise ErroCaptura("Janeiro de 2024 deveria ter só corretores com zero, sem linha da empresa.")
    salvar(pasta, "relatorio_contatos_periodo", periodo)

    # (11) período invertido
    erro_periodo = obter(
        f"{relatorios}/contatos/?{urllib.parse.urlencode({'de': '2024-02-01', 'ate': '2024-01-01'})}",
        status_esperado=400,
        token=token_gestor,
    )
    if "de" not in erro_periodo:
        raise ErroCaptura("O 400 de período invertido deveria trazer a chave `de`.")
    salvar(pasta, "erro_400_relatorio_contatos", erro_periodo)

    # (12) mudanças dos últimos 7 dias: só as 2 desta captura, a mais recente primeiro
    mudancas = obter(f"{relatorios}/mudancas-situacao/", token=token_gestor)
    if set(mudancas) != {"dias", "desde", "mudancas"} or mudancas["dias"] != 7:
        raise ErroCaptura(f"As mudanças deveriam ter {{dias: 7, desde, mudancas}}: {sorted(mudancas)}.")
    itens = mudancas["mudancas"]
    if any(set(item) != CHAVES_MUDANCA_RECENTE for item in itens):
        raise ErroCaptura(f"Cada mudança deveria ter as chaves {sorted(CHAVES_MUDANCA_RECENTE)}.")
    ids_mudancas = [item["imovel_id"] for item in itens]
    if ids_mudancas != [y, x]:
        raise ErroCaptura(
            f"As mudanças de 7 dias deveriam ser {[y, x]} (Y depois X; Z de 10 dias atrás fora): {ids_mudancas}."
        )
    if itens[1]["observacao"] != OBSERVACAO_GESTOR or itens[1]["situacao_nova"] != "RESERVADO":
        raise ErroCaptura("A mudança de X deveria ser RESERVADO com a observação da captura.")
    if itens[0]["situacao_nova"] != "VENDIDO":
        raise ErroCaptura("A mudança de Y deveria ser VENDIDO.")
    if any(not item["alterado_em"].endswith("-03:00") for item in itens):
        raise ErroCaptura("`alterado_em` deveria vir no fuso de São Paulo (-03:00).")
    salvar(pasta, "relatorio_mudancas", mudancas)

    # (13) só confere: 30 dias traz também a mudança antiga (a janela falha nos dois sentidos)
    trinta = obter(f"{relatorios}/mudancas-situacao/?dias=30", token=token_gestor)
    if {item["imovel_id"] for item in trinta["mudancas"]} != {x, y, z}:
        raise ErroCaptura("Com ?dias=30 as mudanças deveriam ser as de X, Y e Z.")

    # (14) dias fora do intervalo
    erro_dias = obter(f"{relatorios}/mudancas-situacao/?dias=0", status_esperado=400, token=token_gestor)
    if "dias" not in erro_dias:
        raise ErroCaptura("O 400 de dias=0 deveria trazer a chave `dias`.")
    salvar(pasta, "erro_400_dias", erro_dias)

    # (15) o corretor recebe 403 nas 4 rotas e o anônimo 401
    for rota in ROTAS_DO_GESTOR:
        recusa = obter(f"{base}{rota}", status_esperado=403, token=token_corretor)
        _exigir_detail(recusa, f"o 403 de {rota}")
        if rota == "/api/relatorios/acervo-por-corretor/":
            salvar(pasta, "erro_403_relatorio", recusa)
        sem_token = obter(f"{base}{rota}", status_esperado=401)
        if "detail" not in sem_token:
            raise ErroCaptura(f"O 401 de {rota} deveria trazer `detail`.")
    print("  403 do corretor e 401 do anônimo conferidos nas 4 rotas")

    # (16) a empresa B: tem imóvel e mudança de verdade e nada em comum com a A
    por_corretor_b = obter(f"{relatorios}/acervo-por-corretor/", token=token_gestor_b)
    linhas_b = _exigir_linhas(por_corretor_b, CHAVES_LINHA_ACERVO_CORRETOR, "acervo por corretor da empresa B")
    if not linhas_b or por_corretor_b.get("total", 0) < 1:
        raise ErroCaptura("O acervo por corretor da empresa B veio vazio (o seed_demo rodou?).")
    if {l["corretor_id"] for l in linhas_b} & {l["corretor_id"] for l in linhas_a}:
        raise ErroCaptura("Há corretor em comum entre as empresas A e B (isolamento vazou).")
    salvar(pasta, "relatorio_acervo_por_corretor_outra_empresa", por_corretor_b)

    mudancas_b = obter(f"{relatorios}/mudancas-situacao/", token=token_gestor_b)
    if not mudancas_b.get("mudancas"):
        raise ErroCaptura("As mudanças da empresa B vieram vazias (o seed_demo grava 1 na hora do seed).")
    ids_b = {item["imovel_id"] for item in mudancas_b["mudancas"]}
    if ids_b & ({x, y, z, w} | set(ids_mudancas)):
        raise ErroCaptura("Há imóvel em comum entre as mudanças das empresas A e B (isolamento vazou).")
    salvar(pasta, "relatorio_mudancas_outra_empresa", mudancas_b)

    # só confere (não salva): a empresa B não tem contato nenhum
    contatos_b = obter(f"{relatorios}/contatos/", token=token_gestor_b)
    if contatos_b.get("total") != 0:
        raise ErroCaptura("O relatório de contatos da empresa B deveria ter total 0.")
    print("  empresa B conferida: imóvel e mudança próprios, nada em comum com a A")


def _requisicao_com_token(url, metodo, token, dados=None, tipo=None):
    cabecalhos = {"Accept": "application/json"}
    if token:
        cabecalhos["Authorization"] = f"Token {token}"
    if tipo:
        cabecalhos["Content-Type"] = tipo
    return urllib.request.Request(url, data=dados, headers=cabecalhos, method=metodo)


def enviar_put(url, corpo, token=None, status_esperado=200):
    """PUT de `corpo` como JSON em `url`; devolve o JSON decodificado. Exige `status_esperado`."""
    requisicao = _requisicao_com_token(
        url, "PUT", token, json.dumps(corpo).encode("utf-8"), "application/json"
    )
    return _executar(requisicao, url, status_esperado)


def enviar_delete(url, token=None, status_esperado=200):
    """DELETE em `url`; devolve o JSON decodificado. Exige `status_esperado`."""
    return _executar(_requisicao_com_token(url, "DELETE", token), url, status_esperado)


def enviar_multipart(url, arquivos, token=None, status_esperado=201):
    """POST multipart/form-data montado à mão (só biblioteca padrão).

    `arquivos` é uma lista de `(campo, nome_do_arquivo, bytes, content_type)`: a rota de fotos aceita
    exatamente um arquivo no campo `imagem`, e a captura manda dois para provar o 400.
    """
    fronteira = "----capturaimoveisaqui7d1f3a"
    partes = []
    for campo, nome, conteudo, tipo in arquivos:
        partes.append(
            (
                f"--{fronteira}\r\n"
                f'Content-Disposition: form-data; name="{campo}"; filename="{nome}"\r\n'
                f"Content-Type: {tipo}\r\n\r\n"
            ).encode("utf-8")
            + conteudo
            + b"\r\n"
        )
    corpo = b"".join(partes) + f"--{fronteira}--\r\n".encode("utf-8")
    requisicao = _requisicao_com_token(
        url, "POST", token, corpo, f"multipart/form-data; boundary={fronteira}"
    )
    return _executar(requisicao, url, status_esperado)


def _png_minimo(largura, altura, cor):
    """PNG RGB válido de uma cor só, montado com `zlib` e `struct` (o Pillow do servidor o aceita)."""
    import struct
    import zlib

    def bloco(tipo, dados):
        return (
            struct.pack(">I", len(dados))
            + tipo
            + dados
            + struct.pack(">I", zlib.crc32(tipo + dados) & 0xFFFFFFFF)
        )

    linha = b"\x00" + bytes(cor) * largura  # filtro 0 + pixels
    return (
        b"\x89PNG\r\n\x1a\n"
        + bloco(b"IHDR", struct.pack(">IIBBBBB", largura, altura, 8, 2, 0, 0, 0))
        + bloco(b"IDAT", zlib.compress(linha * altura))
        + bloco(b"IEND", b"")
    )


CHAVES_DA_FOTO = {"id", "imagem", "ordem", "capa"}
CORES_DAS_FOTOS_DA_CAPTURA = [(46, 139, 87), (143, 188, 143), (34, 139, 34), (60, 179, 113)]
CODIGO_IMOVEL_SEM_FOTO = "DEV-CAMPINAS-11"  # o seed deixa este imóvel sem nenhuma foto
LIMITE_FOTOS = 30
MENSAGEM_LIMITE_FOTOS = "Este imóvel já tem 30 fotos, o máximo permitido."


def _exigir_lista_de_fotos(lista, descricao, quantidade):
    """Lista de fotos com as chaves exatas, ordens 0..n-1 em sequência e no máximo uma capa
    (exatamente uma quando há foto)."""
    if not isinstance(lista, list) or len(lista) != quantidade:
        raise ErroCaptura(f"{descricao} deveria ser uma lista com {quantidade} fotos: {lista!r}.")
    for item in lista:
        if not isinstance(item, dict) or set(item) != CHAVES_DA_FOTO:
            raise ErroCaptura(f"{descricao}: item com chaves erradas: {item!r}.")
        if not isinstance(item["imagem"], str) or "/media/imoveis/fotos/" not in item["imagem"]:
            raise ErroCaptura(f"{descricao}: `imagem` deveria ser a URL absoluta da mídia: {item!r}.")
    if [item["ordem"] for item in lista] != list(range(quantidade)):
        raise ErroCaptura(f"{descricao}: as ordens deveriam ser 0..{quantidade - 1} em sequência.")
    capas = [item["id"] for item in lista if item["capa"]]
    if len(capas) != (1 if quantidade else 0):
        raise ErroCaptura(f"{descricao}: deveria haver exatamente uma capa, há {len(capas)}.")
    return capas[0] if capas else None


def _exigir_erro_de_campo(corpo, campo, descricao):
    """400 do DRF com exatamente a chave `campo` e uma lista de textos."""
    if (
        not isinstance(corpo, dict)
        or set(corpo) != {campo}
        or not isinstance(corpo[campo], list)
        or not corpo[campo]
        or not all(isinstance(texto, str) and texto for texto in corpo[campo])
    ):
        raise ErroCaptura(f"{descricao} deveria ter só a chave `{campo}` com textos: {corpo!r}.")


def capturar_fotos(base, pasta):
    """Fotos do imóvel (Fase 11): lista, envio, ordem, capa, apagar, recusas e isolamento.

    O grupo GRAVA fotos no servidor e apaga todas as que criou no fim: só rode contra o servidor
    temporário (ver "Grupo fotos" no topo).
    """
    token_a = _entrar(base, "CAPTURA_EMAIL_CORRETOR", "CAPTURA_SENHA_CORRETOR")
    token_b = _entrar(base, "CAPTURA_EMAIL_OUTRA_EMPRESA", "CAPTURA_SENHA_OUTRA_EMPRESA")
    token_gestor = _entrar(base, "CAPTURA_EMAIL_GESTOR", "CAPTURA_SENHA_GESTOR")

    busca = obter(
        f"{base}/api/imoveis/?{urllib.parse.urlencode({'busca': CODIGO_IMOVEL_SEM_FOTO})}",
        token=token_a,
    )
    if busca.get("count") != 1:
        raise ErroCaptura(f"A busca por {CODIGO_IMOVEL_SEM_FOTO} deveria achar 1 imóvel no acervo.")
    imovel_id = busca["results"][0]["id"]
    fotos = f"{base}/api/imoveis/{imovel_id}/fotos/"

    def png(indice):
        cor = CORES_DAS_FOTOS_DA_CAPTURA[indice % len(CORES_DAS_FOTOS_DA_CAPTURA)]
        return ("imagem", f"foto-{indice}.png", _png_minimo(16, 12, cor), "image/png")

    vazia = obter(fotos, token=token_a)
    _exigir_lista_de_fotos(vazia, "A lista inicial", 0)
    salvar(pasta, "fotos_lista_vazia", vazia)

    # 3 envios, um por requisição: o primeiro vira capa sozinho
    enviadas = [enviar_multipart(fotos, [png(indice)], token=token_a) for indice in range(3)]
    primeira = enviadas[0]
    if not isinstance(primeira, dict) or set(primeira) != CHAVES_DA_FOTO:
        raise ErroCaptura(f"O 201 do envio deveria ter as chaves {sorted(CHAVES_DA_FOTO)}.")
    if (primeira["ordem"], primeira["capa"]) != (0, True):
        raise ErroCaptura("A primeira foto enviada deveria ter ordem 0 e ser a capa.")
    if [(foto["ordem"], foto["capa"]) for foto in enviadas[1:]] != [(1, False), (2, False)]:
        raise ErroCaptura("As fotos seguintes deveriam entrar no fim (ordem 1 e 2), sem capa.")
    salvar(pasta, "foto_enviada", primeira)
    a, b, c = (foto["id"] for foto in enviadas)

    lista = obter(fotos, token=token_a)
    if _exigir_lista_de_fotos(lista, "A lista com 3 fotos", 3) != a:
        raise ErroCaptura("A capa da lista deveria ser a primeira foto enviada.")
    if [foto["id"] for foto in lista] != [a, b, c]:
        raise ErroCaptura("A lista deveria vir na ordem de envio.")
    salvar(pasta, "fotos_lista", lista)

    reordenadas = enviar_put(f"{fotos}ordem/", {"ids": [c, b, a]}, token=token_a)
    _exigir_lista_de_fotos(reordenadas, "A lista reordenada", 3)
    if [foto["id"] for foto in reordenadas] != [c, b, a]:
        raise ErroCaptura("A lista devolvida pelo PUT deveria estar na ordem pedida.")
    salvar(pasta, "fotos_reordenadas", reordenadas)

    erro_ordem = enviar_put(f"{fotos}ordem/", {"ids": [c, c, a]}, token=token_a, status_esperado=400)
    _exigir_erro_de_campo(erro_ordem, "ids", "O 400 da ordem com id repetido")
    salvar(pasta, "erro_400_fotos_ordem", erro_ordem)
    if [foto["id"] for foto in obter(fotos, token=token_a)] != [c, b, a]:
        raise ErroCaptura("O PUT recusado não deveria mudar a ordem.")

    capa_definida = postar(f"{fotos}{b}/capa/", {}, token=token_a)
    if _exigir_lista_de_fotos(capa_definida, "A lista depois de definir a capa", 3) != b:
        raise ErroCaptura("Depois de definir a capa, a única capa deveria ser a foto pedida.")
    salvar(pasta, "fotos_capa_definida", capa_definida)

    apos_apagar = enviar_delete(f"{fotos}{b}/", token=token_a)
    if _exigir_lista_de_fotos(apos_apagar, "A lista depois de apagar a capa", 2) != c:
        raise ErroCaptura("Apagar a capa deveria promover a primeira restante pela ordem.")
    if [foto["id"] for foto in apos_apagar] != [c, a]:
        raise ErroCaptura("Apagar deveria fechar o buraco na ordem ([c, a]).")
    salvar(pasta, "fotos_apos_apagar_capa", apos_apagar)

    erro_tipo = enviar_multipart(
        fotos, [("imagem", "foto.jpg", b"isto nao e uma imagem", "image/jpeg")],
        token=token_a, status_esperado=400,
    )
    _exigir_erro_de_campo(erro_tipo, "imagem", "O 400 de tipo")
    salvar(pasta, "erro_400_foto_tipo", erro_tipo)

    erro_tamanho = enviar_multipart(
        fotos, [("imagem", "foto.jpg", b"\0" * (5 * 1024 * 1024 + 1), "image/jpeg")],
        token=token_a, status_esperado=400,
    )
    _exigir_erro_de_campo(erro_tamanho, "imagem", "O 400 de tamanho")
    salvar(pasta, "erro_400_foto_tamanho", erro_tamanho)

    erro_quantidade = enviar_multipart(fotos, [png(5), png(6)], token=token_a, status_esperado=400)
    _exigir_erro_de_campo(erro_quantidade, "imagem", "O 400 de dois arquivos")
    salvar(pasta, "erro_400_foto_quantidade", erro_quantidade)
    _exigir_lista_de_fotos(obter(fotos, token=token_a), "A lista depois das recusas", 2)

    erro_404 = obter(fotos, status_esperado=404, token=token_b)
    _exigir_detail(erro_404, "O 404 do imóvel de outra empresa")
    salvar(pasta, "erro_404_fotos_outra_empresa", erro_404)
    # só confere (não salva): a outra empresa também não envia, não reordena, não muda capa nem apaga
    enviar_multipart(fotos, [png(7)], token=token_b, status_esperado=404)
    enviar_put(f"{fotos}ordem/", {"ids": [c, a]}, token=token_b, status_esperado=404)
    postar(f"{fotos}{a}/capa/", {}, token=token_b, status_esperado=404)
    enviar_delete(f"{fotos}{a}/", token=token_b, status_esperado=404)

    erro_403 = obter(fotos, status_esperado=403, token=token_gestor)
    _exigir_detail(erro_403, "O 403 do gestor")
    salvar(pasta, "erro_403_fotos_gestor", erro_403)

    obter(fotos, status_esperado=401)
    print("  401 sem token conferido (a fixture erro_401 já existe)")

    # teto: completa 30 fotos e a 31ª é recusada
    for indice in range(LIMITE_FOTOS - 2):
        enviar_multipart(fotos, [png(indice)], token=token_a)
    erro_limite = enviar_multipart(fotos, [png(99)], token=token_a, status_esperado=400)
    if erro_limite != {"imagem": [MENSAGEM_LIMITE_FOTOS]}:
        raise ErroCaptura(f"O 400 do teto deveria ser a mensagem do limite: {erro_limite!r}.")
    salvar(pasta, "erro_400_foto_limite", erro_limite)

    # limpeza: apaga tudo o que o grupo criou e confere a lista vazia
    for foto in obter(fotos, token=token_a):
        enviar_delete(f"{fotos}{foto['id']}/", token=token_a)
    _exigir_lista_de_fotos(obter(fotos, token=token_a), "A lista depois da limpeza", 0)
    print(f"  limpeza conferida: o imóvel {CODIGO_IMOVEL_SEM_FOTO} voltou a ficar sem fotos")


GRUPOS = {
    "lista": capturar_lista,
    "detalhe": capturar_detalhe,
    "contato": capturar_contato,
    "perfis": capturar_perfis,
    "anunciante": capturar_anunciante,
    "acervo": capturar_acervo,
    "situacao": capturar_situacao,
    "contatos": capturar_contatos,
    "gestor": capturar_gestor,
    "fotos": capturar_fotos,
}


def main():
    analisador = argparse.ArgumentParser(
        description="Captura respostas reais da API pública como fixtures do app."
    )
    analisador.add_argument("url_base", nargs="?", default="http://127.0.0.1:8000")
    analisador.add_argument("pasta_saida", nargs="?", default="test/fixtures/api")
    analisador.add_argument(
        "--grupo",
        choices=["lista", "detalhe", "contato", "perfis", "anunciante", "acervo", "situacao", "contatos", "gestor", "fotos", "todos"],
        default="todos",
        help="`lista` (lista e opções), `detalhe`, `contato` (POST de contato), `perfis`, `anunciante`, `acervo`, "
        "`situacao` (mudança de situação, Fase 9; grava no banco), `contatos` (caixa de contatos, Fase 10; grava no "
        "banco), `gestor` (relatórios da Área do gestor, Fase 12; grava no banco), `fotos` (fotos do imóvel, Fase 11; "
        "grava e apaga fotos) ou `todos` (os dez, nessa ordem; "
        "nunca use `todos` só para acrescentar um grupo).",
    )
    argumentos = analisador.parse_args()

    base = argumentos.url_base.rstrip("/")
    pasta = Path(argumentos.pasta_saida)
    pasta.mkdir(parents=True, exist_ok=True)

    grupos = list(GRUPOS) if argumentos.grupo == "todos" else [argumentos.grupo]
    try:
        for grupo in grupos:
            print(f"Grupo {grupo}:")
            GRUPOS[grupo](base, pasta)
    except ErroCaptura as erro:
        print(f"ERRO: {erro}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
