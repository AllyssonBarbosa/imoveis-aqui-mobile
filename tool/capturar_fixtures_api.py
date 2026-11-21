#!/usr/bin/env python3
"""Captura as respostas REAIS da API pública do Imóveis Aqui como fixtures de teste do app.

Nenhuma fixture de wire é escrita à mão (D-02, D-18): o JSON é salvo exatamente como a API
devolve (ensure_ascii=False, indent=2, quebra de linha final). Só biblioteca padrão.

Uso:
    python3 tool/capturar_fixtures_api.py [URL_BASE] [PASTA_SAIDA]
        [--grupo lista|detalhe|perfis|anunciante|acervo|todos]

Padrões: URL_BASE=http://127.0.0.1:8000, PASTA_SAIDA=test/fixtures/api, --grupo=todos.
Grupos: `lista` (cidades, listas de Campinas, bairros, características e o 400 de natureza);
`detalhe` (um detalhe por natureza, o sem fotos, o sem corretor e o 404 fora da vitrine; lê a
lista de Campinas ao vivo e NÃO reescreve as fixtures de lista); `perfis` (perfil do corretor, perfil da
empresa e o 404 de perfil; descobre os ids ao vivo pelo corretor responsável de um detalhe); `anunciante`
(p1 e p2 da vitrine de imóveis do corretor e da empresa); `acervo` (rotas autenticadas da Fase 8: login,
eu, acervo do corretor em `GET /api/imoveis/` e o Sair; ver "Grupo acervo" abaixo); `todos` = `lista`,
`detalhe`, `perfis`, `anunciante` e `acervo`, nessa ordem. ATENÇÃO: `todos` reescreve as fixtures da lista e
do detalhe (as URLs de foto mudam a cada banco novo); para acrescentar só perfis/anunciante/acervo rode
`--grupo perfis`, `--grupo anunciante` e `--grupo acervo` (nunca `todos`).
Sai com código 1 (e mensagem em português) quando alguma resposta esperada não é produzida.

Procedimento de captura (NUNCA contra o banco do Web/.env; use um SQLite temporário):

  1. Em ../imoveis-aqui/Web:
       CAPTURA_DB="sqlite:///${TMPDIR:-/tmp}/imoveis_captura_05.sqlite3"
       rm -f "${TMPDIR:-/tmp}/imoveis_captura_05.sqlite3"
       DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py migrate --noinput
       DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py semear_vitrine_dev
  2. Suba o servidor temporário em segundo plano:
       DEBUG=True ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2 DATABASE_URL="$CAPTURA_DB" \\
         .venv/bin/python manage.py runserver 127.0.0.1:8000 --noreload
     e aguarde `curl -sf http://127.0.0.1:8000/api/publico/cidades/` responder (até ~30 s).
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


GRUPOS = {
    "lista": capturar_lista,
    "detalhe": capturar_detalhe,
    "perfis": capturar_perfis,
    "anunciante": capturar_anunciante,
    "acervo": capturar_acervo,
}


def main():
    analisador = argparse.ArgumentParser(
        description="Captura respostas reais da API pública como fixtures do app."
    )
    analisador.add_argument("url_base", nargs="?", default="http://127.0.0.1:8000")
    analisador.add_argument("pasta_saida", nargs="?", default="test/fixtures/api")
    analisador.add_argument(
        "--grupo",
        choices=["lista", "detalhe", "perfis", "anunciante", "acervo", "todos"],
        default="todos",
        help="`lista` (lista e opções), `detalhe`, `perfis`, `anunciante`, `acervo` ou `todos` (os cinco, nessa ordem; nunca use `todos` só para acrescentar o acervo).",
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
