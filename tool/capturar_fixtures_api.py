#!/usr/bin/env python3
"""Captura as respostas REAIS da API pública do Imóveis Aqui como fixtures de teste do app.

Nenhuma fixture de wire é escrita à mão (D-02, D-18): o JSON é salvo exatamente como a API
devolve (ensure_ascii=False, indent=2, quebra de linha final). Só biblioteca padrão.

Uso:
    python3 tool/capturar_fixtures_api.py [URL_BASE] [PASTA_SAIDA]
        [--grupo lista|detalhe|contato|perfis|anunciante|acervo|contatos|todos]

Padrões: URL_BASE=http://127.0.0.1:8000, PASTA_SAIDA=test/fixtures/api, --grupo=todos.
Grupos: `lista` (cidades, listas de Campinas, bairros, características e o 400 de natureza);
`detalhe` (um detalhe por natureza, o sem fotos, o sem corretor e o 404 fora da vitrine; lê a
lista de Campinas ao vivo e NÃO reescreve as fixtures de lista); `contato` (as respostas do POST de
contato: 201 de WhatsApp, telefone e e-mail, e o 400 de canal inválido; recusa um link do WhatsApp com '+');
`perfis` (perfil do corretor, perfil da
empresa e o 404 de perfil; descobre os ids ao vivo pelo corretor responsável de um detalhe); `anunciante`
(p1 e p2 da vitrine de imóveis do corretor e da empresa); `acervo` (rotas autenticadas da Fase 8: login,
eu, acervo do corretor em `GET /api/imoveis/` e o Sair; ver "Grupo acervo" abaixo); `contatos` (caixa de
contatos do corretor da Fase 10: 25 POSTs públicos, lista p1/p2 e filtros, contagem antes e depois de anotar,
opções do filtro de imóvel, PATCH 200/400, a caixa da outra empresa e o 404 cruzado; ver "Grupo contatos"
abaixo); `todos` = `lista`, `detalhe`, `contato`, `perfis`, `anunciante`, `acervo` e `contatos`, nessa ordem.
ATENÇÃO: `todos` reescreve as fixtures da lista e do detalhe (as URLs de foto mudam a cada banco novo); para
acrescentar só um grupo rode `--grupo contato`, `--grupo perfis`, `--grupo anunciante`, `--grupo acervo` ou
`--grupo contatos` (nunca `todos`).
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
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
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


GRUPOS = {
    "lista": capturar_lista,
    "detalhe": capturar_detalhe,
    "contato": capturar_contato,
    "perfis": capturar_perfis,
    "anunciante": capturar_anunciante,
    "acervo": capturar_acervo,
    "contatos": capturar_contatos,
}


def main():
    analisador = argparse.ArgumentParser(
        description="Captura respostas reais da API pública como fixtures do app."
    )
    analisador.add_argument("url_base", nargs="?", default="http://127.0.0.1:8000")
    analisador.add_argument("pasta_saida", nargs="?", default="test/fixtures/api")
    analisador.add_argument(
        "--grupo",
        choices=["lista", "detalhe", "contato", "perfis", "anunciante", "acervo", "contatos", "todos"],
        default="todos",
        help="`lista` (lista e opções), `detalhe`, `contato` (POST de contato), `perfis`, `anunciante`, `acervo`, "
        "`contatos` (caixa de contatos) ou `todos` (os sete, nessa ordem; nunca use `todos` só para acrescentar um grupo).",
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
