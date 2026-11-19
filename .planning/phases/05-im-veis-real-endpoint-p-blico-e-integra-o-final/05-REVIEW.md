---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
reviewed: 2026-11-16T00:00:00Z
depth: standard
files_reviewed: 10
files_reviewed_list:
  - ../imoveis-aqui/README.md
  - ../imoveis-aqui/Web/.env.example
  - ../imoveis-aqui/Web/config/settings.py
  - ../imoveis-aqui/Web/core/throttles.py
  - ../imoveis-aqui/Web/empresas/tests.py
  - ../imoveis-aqui/Web/imoveis/api/views.py
  - ../imoveis-aqui/Web/imoveis/tests.py
  - ../imoveis-aqui/Web/localizacao/api/views.py
  - test/data/imovel_detalhe_repository_impl_test.dart
  - test/data/imovel_remote_datasource_test.dart
findings:
  critical: 0
  warning: 3
  info: 5
  total: 8
  deferred_carried: 13
status: issues_found
---

# Fase 5: Relatório de Code Review (rodada de gap closure 05-19..05-22)

**Revisado em:** 2026-11-16
**Profundidade:** standard
**Arquivos revisados:** 10 (8 da API, 2 testes do app)
**Status:** issues_found
**Revisão anterior:** preservada no git em `8e36e81` (CR-01, CR-02, WR-01..06, IN-01..09)

## Resumo

Esta é uma revisão incremental das mudanças dos planos 05-19 a 05-22, que estão sem commit na árvore de trabalho da API (`feat/APP05`, sobre o HEAD `0592176`). O foco foram os helpers `_numero`, `_texto`, `_bairros_do_filtro` e `_ids_de_caracteristicas`, a subconsulta agregada de características, o `ThrottleVitrinePublica` com as configurações dele, os testes adicionados e os 3 testes novos do app.

Limite desta revisão: o ambiente não tem Django instalado, e eu não li `Web/.env` nem subi servidor, como pedido. Por isso **não executei as suítes**. A avaliação vem da leitura do código e dos testes, e das contagens que os SUMMARYs registram (353 testes na API, 588 no app). Onde um achado depende de comportamento de runtime, o texto diz isso.

Os quatro achados anteriores que a rodada devia fechar (CR-01, CR-02, WR-01, WR-02) estão resolvidos no código, e a leitura não achou regressão nos caminhos corrigidos. Não há achado crítico novo. Os três avisos novos são casos de borda na mesma classe de falha que a rodada tratava (entrada hostil virando 500, ou limite de taxa mal calibrado) e um acoplamento da suíte com o ambiente.

O que está sólido (conferido no código):
- A allowlist `[0-9]` com `fullmatch` em `_numero` e `_FORMATO_ID` recusa `NaN`, `sNaN`, `Infinity`, `inf`, expoente, `_`, espaço e dígito de outro alfabeto. `fullmatch` evita o problema do `$` com `\n` final.
- O 400 de byte NUL é decidido em Python, antes da consulta, então vale em SQLite e em Postgres. O teste cobre nove parâmetros.
- A subconsulta de características (`views.py:520-527`) mantém a semântica "tem todas" (`Count distinct == len(ids)`), e o teste de forma do SQL compara as ocorrências da tabela M2M entre 2 e 20 ids.
- O throttle usa `NUM_PROXIES=0`, então o `X-Forwarded-For` forjado não reinicia a contagem (teste cobre). Não há `DEFAULT_THROTTLE_CLASSES`, então a API autenticada não é limitada. As 5 rotas públicas da vitrine declaram o throttle e um teste trava isso.
- O README descreve os tetos, as mensagens e o comportamento 429 de forma coerente com o código (conferi preço, área, inteiro, busca, bairros, características, balde único e `Retry-After`).

## Status dos achados da revisão anterior

| ID | Status | Evidência |
|----|--------|-----------|
| CR-01 (`?caracteristicas=` com um JOIN por id) | **Resolvido** | `_ids_de_caracteristicas` (`views.py:400-420`) aceita só `[0-9]+` positivo, deduplica e recusa mais de 20 ids distintos com 400 antes de montar qualquer consulta. O filtro virou uma subconsulta única `pk__in` com `GROUP BY imovel_id HAVING COUNT(DISTINCT) = n` (`views.py:520-527`). Testes: `test_caracteristicas_demais_da_400` (inclui prova de que o 400 não consulta `imoveis_imovel`), `test_filtro_caracteristicas_usa_uma_so_subconsulta_...` (tabela M2M aparece 1 vez por consulta, sem `JOIN`), `test_paginacao_com_filtro_...` e o teste antigo "exige todas", sem edição. Ressalva em WR-07 (id com dígitos demais). |
| CR-02 (`NaN`/`Infinity` viram 500) | **Resolvido** | `_numero` (`views.py:347-369`) valida o texto com `_FORMATO_DECIMAL`/`_FORMATO_INTEIRO` por `fullmatch` antes de converter, depois recusa negativo e acima do teto da coluna (preço 9999999999.99, área 99999999.99, inteiro 32767). `1e400`, `1_0` e `٣` também dão 400. Testes: `test_numero_nao_finito_ou_fora_do_formato_da_400` (4 campos x 11 valores), `test_numero_inteiro_fora_do_formato_da_400`, `test_numero_acima_do_teto_...`, `test_area_tem_o_teto_da_coluna`. A conversão inteira continua dentro do `try/except ValueError`, então o limite de 4300 dígitos do `int()` também vira 400 ali. |
| WR-01 (byte NUL em `busca`/`bairro` dá 500) | **Resolvido** | `_texto` (`views.py:372-382`) e `_bairros_do_filtro` (`views.py:385-397`) recusam `\x00` com 400 em Python. Testes: `test_byte_nul_em_busca_e_bairro_da_400` e `test_byte_nul_em_qualquer_parametro_nunca_da_500` (9 parâmetros). |
| WR-02 (sem limite de taxa e CSV sem teto) | **Resolvido para as rotas da vitrine** (resíduo em IN-12) | `ThrottleVitrinePublica` (`core/throttles.py`) com taxa em `DEFAULT_THROTTLE_RATES` (`settings.py:145-147`), aplicado nas 5 rotas (`views.py:451,546,570,581` e `localizacao/api/views.py:20`). Tetos: `busca` 200 caracteres, `bairro` 20 itens de até 100 caracteres, características 20 ids. Testes em `VitrineLimiteDeTaxaTests` (429 + `Retry-After`, balde único, XFF forjado, 5 views com o throttle). As rotas `corretores/<id>/` e `empresas/<id>/` continuam sem limite, e o README diz isso. |
| WR-03 (bairro de `/bairros/` pode não casar com `?bairro=`) | **Adiado por escopo** | Sem mudança. Agora o filtro apara cada item do CSV, e `/bairros/` ainda devolve `bairro_anuncio` cru, então o descasamento com espaço nas pontas continua possível. |
| WR-04 (seed grava bairro errado no apartamento) | **Adiado por escopo** | Fora desta rodada. |
| WR-05 (guarda do seed olha só `DEBUG`) | **Adiado por escopo** | Fora desta rodada. O README ainda diz que "nenhuma outra empresa é lida ou alterada", afirmação mais forte que o comando (ver o achado original). |
| WR-06 (testes de contrato leem `.planning/`) | **Adiado por escopo** | Fora desta rodada. |
| IN-01 a IN-09 | **Adiados por escopo** | Carregados sem alteração. IN-06 (`SECURE_PROXY_SSL_HEADER`) ganhou um vizinho nesta rodada, em WR-08. |

## Avisos

### WR-07: `int(item)` sem proteção em `_ids_de_caracteristicas` ainda pode dar 500 (id com dígitos demais)

**Arquivo:** `../imoveis-aqui/Web/imoveis/api/views.py:341,413-415`
**Problema:** `_FORMATO_ID = [0-9]+` não limita o tamanho. Depois do `fullmatch`, `int(item)` roda **fora** de qualquer `try`, duas vezes (linhas 413 e 415). Dois caminhos:
1. A partir do Python 3.10.7 e 3.11, `int()` de uma string decimal com mais de 4300 dígitos levanta `ValueError`. Um `?caracteristicas=000...0` (4301+ dígitos, zeros à esquerda contam) passa pelo regex e estoura em `int()`: HTTP 500, exatamente a classe do CR-02. Em `runserver` e em servidores ASGI o limite de linha de requisição passa de 64 KB, então é alcançável. O gunicorn (4094 por padrão) mascara o caso, mas isso é acaso de deploy, não validação.
2. Um id grande mas abaixo de 4300 dígitos (por exemplo 30 dígitos) vira parâmetro inteiro fora do range do bigint. No Postgres com psycopg 3 vira `numeric` e compara sem erro (resultado vazio). No SQLite o driver levanta `OverflowError` ao ligar o parâmetro. Não reproduzi (sem Django no ambiente), então trate este segundo caminho como risco a confirmar. O primeiro é comportamento documentado do Python.
Nenhum teste cobre id longo: os valores hostis do teste são curtos (`0`, `-1`, `1_0`, `٣`, `1.0`, `abc`).
**Correção:** limitar o tamanho no próprio regex (18 dígitos cabem em bigint) e converter uma vez só:
```python
_FORMATO_ID = re.compile(r"[0-9]{1,18}")
...
        if not _FORMATO_ID.fullmatch(item):
            raise ValidationError({"caracteristicas": "Informe os ids separados por vírgula."})
        numero = int(item)
        if numero <= 0:
            raise ValidationError({"caracteristicas": "Informe os ids separados por vírgula."})
        ids.add(numero)
```
Adicionar ao `test_id_de_caracteristica_fora_do_formato_da_400` os valores `"0" * 5000` e `"9" * 30`.

### WR-08: `NUM_PROXIES` com padrão 0 em produção atrás de proxy junta todos os visitantes em um só balde

**Arquivo:** `../imoveis-aqui/Web/config/settings.py:150`, `../imoveis-aqui/Web/.env.example:11-12`
**Problema:** o padrão `0` é a escolha certa contra `X-Forwarded-For` forjado, mas falha de forma perigosa em produção. Atrás de um proxy reverso sem `NUM_PROXIES` configurado, `REMOTE_ADDR` é o IP do proxy para todo mundo. Como o limite é `120/min` por "IP", **o app inteiro passa a dividir 120 requisições por minuto** e um único cliente que faça 121 requisições bloqueia todos os outros com 429. O deploy continua "funcionando" em teste manual (poucas requisições) e só quebra com tráfego. O README avisa, mas um aviso em texto não protege quem copia `.env.example` com `DEBUG=True` (o próprio WR-05 anterior já nota esse padrão). O mesmo vale para `SECURE_PROXY_SSL_HEADER` (IN-06): é configuração de proxy que só aparece quando falha.
**Correção:** exigir o valor explícito fora do desenvolvimento, para que esquecer vire erro de inicialização, não 429 em massa:
```python
'NUM_PROXIES': env.int('NUM_PROXIES', default=0) if DEBUG else env.int('NUM_PROXIES'),
```
(ou, no mínimo, um `check` do Django que avise quando `DEBUG=False` e `NUM_PROXIES=0`). Registrar no checklist de deploy junto com IN-06.

### WR-09: a suíte da API depende da taxa configurada no ambiente (`VITRINE_TAXA_ANONIMA`)

**Arquivo:** `../imoveis-aqui/Web/imoveis/tests.py:1047-1049` (`VitrineBase.setUp`), `:1448-1470` e `:1350-1380` (laços de requisições)
**Problema:** os testes só chamam `cache.clear()` e usam a taxa real do settings, que vem de `env('VITRINE_TAXA_ANONIMA', default='120/min')`, lida do `.env` de quem roda. Vários testes fazem dezenas de requisições no mesmo teste (`test_numero_nao_finito_ou_fora_do_formato_da_400` faz 44, mais as do `setUp`). Se alguém deixar `VITRINE_TAXA_ANONIMA=30/min` no `.env` local (é para isso que a variável existe), esses testes passam a receber 429 no lugar do 400 esperado e falham por motivo que não é regressão. O resumo do 05-21 fala em "suíte estável em duas rodadas", mas isso só prova estabilidade com o padrão. Hoje a margem entre o maior teste e o padrão é pequena (44 contra 120), e qualquer valor hostil novo adicionado ao laço aproxima do limite.
**Correção:** fixar uma taxa alta para toda a base e deixar os testes de throttle sobrescreverem (os `mock.patch.object` internos já sobrepõem):
```python
def setUp(self):
    cache.clear()
    patcher = mock.patch.object(ThrottleVitrinePublica, "rate", "100000/min", create=True)
    patcher.start()
    self.addCleanup(patcher.stop)
```
`test_taxa_padrao_vem_do_settings` então deve comparar a leitura do settings com a constante esperada, não com `ThrottleVitrinePublica().rate` (que passaria a devolver o valor mockado).

## Informativos

### IN-10: código defensivo inalcançável e regex duplicado em `_numero`

**Arquivo:** `../imoveis-aqui/Web/imoveis/api/views.py:318-321,341,357-366`
**Problema:** depois do `fullmatch`, `Decimal(valor)` não levanta `InvalidOperation` e o resultado é sempre finito, então `except (InvalidOperation, ValueError)` (para Decimal) e `if tipo is Decimal and not numero.is_finite()` não executam nunca. O único `ValueError` alcançável é o do limite de 4300 dígitos do `int()`. Além disso `_FORMATO_ID` repete `_FORMATO_INTEIRO` sem o sinal. Código morto parece defesa e esconde qual proteção realmente vale (o regex).
**Correção:** manter o `try/except ValueError` só para o inteiro (com comentário sobre o limite do Python), remover o `is_finite()` ou deixá-lo documentado como cinto e suspensório, e reaproveitar um único padrão de dígitos.

### IN-11: `test_api_autenticada_do_painel_nao_tem_limite` passa mesmo sem proteger nada

**Arquivo:** `../imoveis-aqui/Web/imoveis/tests.py:1219-1226`
**Problema:** o `mock.patch.object(ThrottleVitrinePublica, "rate", "1/min")` não tem relação com a view `imovel-list` (ela não usa esse throttle), então as três requisições seguiriam passando com ou sem o patch. A única asserção com efeito é `DEFAULT_THROTTLE_CLASSES == []`. Se alguém adicionar `AnonRateThrottle` direto numa view autenticada, o teste não pega. O nome promete mais do que verifica.
**Correção:** remover o patch e renomear para algo como `test_nao_ha_throttle_global_no_rest_framework`, ou testar de fato que `ImovelViewSet.throttle_classes` está vazio.

### IN-12: rotas públicas de `contas` e `empresas` seguem sem limite, e o limite por IP tem lacunas conhecidas

**Arquivo:** `../imoveis-aqui/Web/contas/api/views.py:39-45`, `../imoveis-aqui/Web/empresas/api/views.py:8-14`, `../imoveis-aqui/README.md` (bullet "Limite de taxa")
**Problema:** `CorretorPublicoAPIView` e `EmpresaPublicaAPIView` são `AllowAny` sem throttle (e sem `authentication_classes = []`, então um token inválido vira 401). São buscas por chave primária, baratas, e o README já declara a exceção, por isso não é bug. Fica o registro para quem ampliar: a regra "toda rota pública declara o throttle" não é imposta por teste para essas duas. Além disso o limite é por IP exato: um cliente IPv6 com um bloco /64 troca de endereço à vontade, e CGNAT de operadora junta muita gente em um IP. O throttle reduz o abuso casual, não substitui limite na borda (proxy/WAF).
**Correção:** decidir conscientemente (aplicar `ThrottleVitrinePublica` ou manter a exceção documentada com um teste que a trave) e tratar o limite de borda no checklist de deploy.

### IN-13: testes 429 do app reaproveitam o corpo do 404 e o app não trata `Retry-After`

**Arquivo:** `test/data/imovel_remote_datasource_test.dart:183-191`, `test/data/imovel_detalhe_repository_impl_test.dart:97-122`
**Problema:** o teste do 429 da lista usa `fixture: 'erro_404_detalhe.json'` (`"No Imovel matches the given query."`) como corpo, embora o comentário diga "o mesmo formato do Throttled do DRF". O corpo real do DRF é `{"detail": "Request was throttled. Expected available in N seconds."}` com cabeçalho `Retry-After`, que não é simulado nem capturado por `tool/capturar_fixtures_api.py`. Os testes só afirmam o status, então passam, mas o nome do arquivo induz a ler o teste como "404". Em `lib/` não há tratamento de 429: o estado de erro oferece "Tentar de novo" imediato, que reenvia a requisição dentro da janela bloqueada. O contrato da fase chama isso de comportamento aceito, então fica como informativo.
**Correção:** criar `erro_429_throttled.json` com o corpo real do DRF e usá-lo nos dois testes; se quiser UX melhor depois, ler `Retry-After` para adiar o "Tentar de novo".

### IN-14: `empresas/tests.py` cria diretório temporário na importação do módulo

**Arquivo:** `../imoveis-aqui/Web/empresas/tests.py:92,98-101`
**Problema:** `MEDIA_DO_SEED = tempfile.mkdtemp()` roda ao importar o módulo, e o `rmtree` só acontece no `tearDownClass` de `SemearVitrineDevTests`. Importações em que essa classe não roda (filtro por tag, `--exclude-tag`, ou descoberta que importa e não executa) deixam um diretório em `/tmp` por execução. A segunda classe (`SemearVitrineDevDebugDesligadoTests`) reaproveita o caminho já apagado.
**Correção:** criar o diretório em `setUpClass` (ou usar `tempfile.TemporaryDirectory` com `addClassCleanup`) em vez de em nível de módulo.

## Pendências carregadas (adiadas por escopo do usuário)

Sem reanálise nesta rodada, mantidas como na revisão `8e36e81`:
- WR-03 (bairro cru em `/bairros/` vs `iexact` com `strip`), WR-04 (seed: bairro errado no apartamento), WR-05 (guarda do seed só olha `DEBUG`), WR-06 (testes de contrato leem `.planning/`).
- IN-01 a IN-09 (formatação "1.000 mil", andar 0, comentários desatualizados, código morto no modelo, ordem do chip de bairros, `next` atrás de proxy TLS, ferramenta de captura, foto de capa no 404, item inválido derruba a página).

Observação: `VITRINE_TAXA_ANONIMA` com formato inválido (por exemplo `120 por minuto`) só falha na primeira requisição pública, como 500 em todas as rotas, porque o DRF analisa a taxa em tempo de uso. Vale validar `<número>/<período>` no settings junto com a correção de WR-08.

---

_Revisado em: 2026-11-16_
_Revisor: Claude (gsd-code-reviewer)_
_Profundidade: standard_
