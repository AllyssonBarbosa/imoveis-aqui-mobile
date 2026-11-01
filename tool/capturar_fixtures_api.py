#!/usr/bin/env python3
"""Captura as respostas REAIS da API pública do Imóveis Aqui como fixtures de teste do app.

Nenhuma fixture de wire é escrita à mão (D-02, D-18): o JSON é salvo exatamente como a API
devolve (ensure_ascii=False, indent=2, quebra de linha final). Só biblioteca padrão.

Uso:
    python3 tool/capturar_fixtures_api.py [URL_BASE] [PASTA_SAIDA] [--grupo lista|todos]

Padrões: URL_BASE=http://127.0.0.1:8000, PASTA_SAIDA=test/fixtures/api, --grupo=todos.
Grupos: `lista` (cidades, listas de Campinas, bairros, características e o 400 de natureza);
`todos` equivale a `lista` nesta fase (o grupo `detalhe` entra no plano 05-07).
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
       python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo lista
  4. Pare o servidor temporário e apague o SQLite temporário.

Os ids são determinísticos para um banco novo semeado pelo mesmo comando.
"""

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


class ErroCaptura(Exception):
    """Resposta inesperada da API durante a captura."""


def obter(url, status_esperado=200):
    """GET em `url`; devolve o JSON já decodificado. Exige `status_esperado`."""
    requisicao = urllib.request.Request(url, headers={"Accept": "application/json"})
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


GRUPOS = {"lista": capturar_lista}


def main():
    analisador = argparse.ArgumentParser(
        description="Captura respostas reais da API pública como fixtures do app."
    )
    analisador.add_argument("url_base", nargs="?", default="http://127.0.0.1:8000")
    analisador.add_argument("pasta_saida", nargs="?", default="test/fixtures/api")
    analisador.add_argument(
        "--grupo",
        choices=["lista", "todos"],
        default="todos",
        help="`lista` (lista e opções) ou `todos` (equivale a `lista` nesta fase).",
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
