---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
reviewed: 2026-11-01T00:00:00Z
depth: standard
files_reviewed: 79
files_reviewed_list:
  - imovies-aqui-mobile/lib/data/datasources/cidade_prefs_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/cidade_remote_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/imovel_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/imovel_detalhe_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/imovel_detalhe_remote_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/imovel_remote_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/opcoes_filtro_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/opcoes_filtro_remote_datasource.dart
  - imovies-aqui-mobile/lib/data/datasources/parametros_consulta_imoveis.dart
  - imovies-aqui-mobile/lib/data/models/caracteristica_model.dart
  - imovies-aqui-mobile/lib/data/models/cidade_model.dart
  - imovies-aqui-mobile/lib/data/models/dados_natureza_model.dart
  - imovies-aqui-mobile/lib/data/models/detalhe_imovel_model.dart
  - imovies-aqui-mobile/lib/data/models/imoveis_envelope_model.dart
  - imovies-aqui-mobile/lib/data/models/imovel_model.dart
  - imovies-aqui-mobile/lib/data/repositories/cidade_repository_impl.dart
  - imovies-aqui-mobile/lib/data/repositories/imovel_detalhe_repository_impl.dart
  - imovies-aqui-mobile/lib/data/repositories/imovel_repository_impl.dart
  - imovies-aqui-mobile/lib/data/repositories/opcoes_filtro_repository_impl.dart
  - imovies-aqui-mobile/lib/domain/entities/caracteristica.dart
  - imovies-aqui-mobile/lib/domain/entities/cidade.dart
  - imovies-aqui-mobile/lib/domain/entities/dados_natureza.dart
  - imovies-aqui-mobile/lib/domain/entities/detalhe_imovel.dart
  - imovies-aqui-mobile/lib/domain/entities/filtros_vitrine.dart
  - imovies-aqui-mobile/lib/domain/entities/imovel.dart
  - imovies-aqui-mobile/lib/domain/entities/ordenacao_vitrine.dart
  - imovies-aqui-mobile/lib/domain/repositories/opcoes_filtro_repository.dart
  - imovies-aqui-mobile/lib/domain/usecases/obter_caracteristicas_usecase.dart
  - imovies-aqui-mobile/lib/presentation/detalhe_imovel/apresentacao_natureza.dart
  - imovies-aqui-mobile/lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
  - imovies-aqui-mobile/lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
  - imovies-aqui-mobile/lib/presentation/detalhe_imovel/widgets/cards_natureza.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/apresentacao_filtros.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/apresentacao_imovel.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/opcoes_filtro_state.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/rascunho_filtros_cubit.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/vitrine_cubit.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
  - imovies-aqui-mobile/lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart
  - imovies-aqui-mobile/test/data/cidade_prefs_datasource_test.dart
  - imovies-aqui-mobile/test/data/cidade_remote_datasource_test.dart
  - imovies-aqui-mobile/test/data/cidade_repository_impl_test.dart
  - imovies-aqui-mobile/test/data/contrato_detalhe_test.dart
  - imovies-aqui-mobile/test/data/contrato_lista_test.dart
  - imovies-aqui-mobile/test/data/detalhe_imovel_model_test.dart
  - imovies-aqui-mobile/test/data/imovel_detalhe_remote_datasource_test.dart
  - imovies-aqui-mobile/test/data/imovel_detalhe_repository_impl_test.dart
  - imovies-aqui-mobile/test/data/imovel_remote_datasource_test.dart
  - imovies-aqui-mobile/test/data/imovel_repository_impl_test.dart
  - imovies-aqui-mobile/test/data/opcoes_filtro_remote_datasource_test.dart
  - imovies-aqui-mobile/test/data/opcoes_filtro_repository_impl_test.dart
  - imovies-aqui-mobile/test/data/parametros_consulta_imoveis_test.dart
  - imovies-aqui-mobile/test/domain/filtros_vitrine_test.dart
  - imovies-aqui-mobile/test/presentation/apresentacao_filtros_test.dart
  - imovies-aqui-mobile/test/presentation/apresentacao_imovel_test.dart
  - imovies-aqui-mobile/test/presentation/apresentacao_natureza_test.dart
  - imovies-aqui-mobile/test/presentation/cartao_corretor_test.dart
  - imovies-aqui-mobile/test/presentation/detalhe_imovel_screen_test.dart
  - imovies-aqui-mobile/test/presentation/detalhe_navegacao_test.dart
  - imovies-aqui-mobile/test/presentation/filtros_bottom_sheet_test.dart
  - imovies-aqui-mobile/test/presentation/imovel_card_test.dart
  - imovies-aqui-mobile/test/presentation/opcoes_filtro_cubit_test.dart
  - imovies-aqui-mobile/test/presentation/perfil_corretor_screen_test.dart
  - imovies-aqui-mobile/test/presentation/rascunho_filtros_cubit_test.dart
  - imovies-aqui-mobile/test/presentation/sessao_filtros_vitrine_test.dart
  - imovies-aqui-mobile/test/presentation/vitrine_cubit_test.dart
  - imovies-aqui-mobile/test/presentation/vitrine_fluxo_test.dart
  - imovies-aqui-mobile/test/presentation/vitrine_screen_test.dart
  - imovies-aqui-mobile/test/support/api_falsa.dart
  - imovies-aqui-mobile/tool/capturar_fixtures_api.py
  - imoveis-aqui/Web/imoveis/vitrine.py
  - imoveis-aqui/Web/imoveis/api/serializers.py
  - imoveis-aqui/Web/imoveis/api/views.py
  - imoveis-aqui/Web/imoveis/api/urls_publico.py
  - imoveis-aqui/Web/imoveis/tests.py
  - imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py
  - imoveis-aqui/Web/empresas/tests.py
  - imoveis-aqui/Web/.env.example
  - imoveis-aqui/README.md
findings:
  critical: 2
  warning: 6
  info: 9
  total: 17
status: issues_found
---

# Fase 5: Relatório de Code Review

**Revisado em:** 2026-11-01
**Profundidade:** standard
**Arquivos revisados:** 79 (70 do app + 9 da API; 8 caminhos da lista do app não existem mais, foram os mocks removidos na fase)
**Status:** issues_found

## Resumo

Foram revisados o código de produção do app (`lib/`, `tool/`) e a superfície pública da API Django (`vitrine.py`, serializers, views, urls, seed e testes). Execução de verificação: `flutter analyze` sem avisos, `flutter test` com 585 testes passando, e `manage.py test empresas imoveis` com 274 testes passando. Os testes passam, mas **não cobrem entrada hostil nos parâmetros públicos**, que é onde estão os dois achados críticos.

O que está sólido (conferido, não só lido):
- Allowlist de campos: o detalhe e a lista públicos expõem só os campos listados nos serializers públicos. Não vazam `proprietario`, `codigo`, `empresa`, `publicado`, `situacao`, `complemento`, `numero` da unidade nem documentos. `empresa_id` e contatos do corretor seguem como pendência já aceita (LGPD, time web) e não são reportados de novo.
- Isolamento: lista, bairros e detalhe saem todos de `imoveis_da_vitrine()` (`publicado` + `DISPONIVEL` + `empresa__ativa`), sem cópia da regra. Detalhe de rascunho, imóvel reservado/vendido ou empresa inativa responde o mesmo 404 de id inexistente.
- N+1: medido com `CaptureQueriesContext`. A lista de 5 itens faz 4 consultas; o detalhe de casa, apartamento, terreno e lote faz 3 consultas cada; os bairros fazem 2.
- Seed: recusa com `DEBUG=False` sem criar nada, é idempotente e não altera outra empresa (testado).

Os dois críticos são na API pública sem autenticação: um filtro que gera um número ilimitado de JOINs (negação de serviço com uma única requisição) e valores numéricos que viram HTTP 500 em vez do 400 prometido.

## Achados Críticos

### CR-01: `?caracteristicas=` gera um JOIN por id, sem limite (DoS com uma requisição, endpoint público)

**Arquivo:** `imoveis-aqui/Web/imoveis/api/views.py:419-427`
**Problema:** o endpoint público e sem autenticação faz `queryset.filter(caracteristicas=id)` dentro de um `for` sobre `ids`. Cada `.filter()` encadeado em relação M2M adiciona um novo JOIN, e o número de ids não tem teto nenhum (nem de quantidade, nem de tamanho da URL além do limite do servidor). Reproduzi num teste com dados mínimos (5 imóveis): uma requisição com 50, 500 e 3000 ids em sequência deixou o backend do Postgres com a consulta `SELECT COUNT(*) FROM (SELECT DISTINCT ...)` ativa por mais de 2 minutos, e precisei encerrar o processo e o backend manualmente. O catálogo real tem poucas dezenas de características, então qualquer lista maior que o catálogo já é abuso. Além disso `int()` aceita `-1` e `1_0`, que viram filtros sem sentido.
**Correção:** validar e limitar os ids, e trocar os JOINs encadeados por uma única agregação (semântica "tem todas" mantida):
```python
from django.db.models import Count

MAX_CARACTERISTICAS = 20  # ou o tamanho do catálogo

caracteristicas = params.get("caracteristicas", "").strip()
if caracteristicas:
    try:
        ids = {int(i) for i in caracteristicas.split(",") if i.strip()}
    except ValueError:
        raise ValidationError({"caracteristicas": "Informe os ids separados por vírgula."})
    if any(i <= 0 for i in ids) or len(ids) > MAX_CARACTERISTICAS:
        raise ValidationError({"caracteristicas": "Lista de ids inválida."})
    if ids:
        queryset = queryset.filter(
            pk__in=Imovel.caracteristicas.through.objects
            .filter(caracteristica_id__in=ids)
            .values("imovel_id")
            .annotate(n=Count("caracteristica_id", distinct=True))
            .filter(n=len(ids))
            .values("imovel_id")
        )
```
Adicionar teste: 21+ ids devolve 400; `caracteristicas=1,2` continua exigindo as duas.

### CR-02: `NaN`, `sNaN` e `Infinity` em `preco_min/max` e `area_min/max` viram HTTP 500 (contrato diz 400)

**Arquivo:** `imoveis-aqui/Web/imoveis/api/views.py:315-326`
**Problema:** `_numero` usa `Decimal(valor)`, que aceita `"NaN"`, `"sNaN"` e `"Infinity"` sem lançar `InvalidOperation`. Depois `numero < 0` com NaN levanta `decimal.InvalidOperation` fora do `try` (500), e `Infinity` chega ao ORM e levanta `django.core.exceptions.ValidationError` (500). Confirmei no teste: `preco_min=NaN` e `area_min=sNaN` dão `InvalidOperation`; `preco_min=Infinity` dá `ValidationError`. O endpoint é público, então qualquer cliente derruba a resposta com 500 (e ruído em log/monitoramento). O docstring ("valor inválido vira 400 com mensagem clara") e o `erro_400` do contrato ficam falsos para essas entradas. `"1_0"` também é aceito silenciosamente (underscore), e `1e400` passa e vira filtro sem efeito.
**Correção:**
```python
def _numero(params, nome, tipo=Decimal):
    valor = params.get(nome)
    if valor in (None, ""):
        return None
    try:
        numero = tipo(valor)
    except (InvalidOperation, ValueError):
        raise ValidationError({nome: "Informe um número válido."})
    if tipo is Decimal and not numero.is_finite():
        raise ValidationError({nome: "Informe um número válido."})
    if numero < 0:
        raise ValidationError({nome: "O valor não pode ser negativo."})
    return numero
```
Se quiser, limitar também ao máximo do campo (`numero > Decimal("9999999999.99")` vira 400) e rejeitar `_` com `re.fullmatch(r"\d+(\.\d+)?", valor)`. Adicionar testes para `NaN`, `sNaN`, `Infinity`, `1e400` em `VitrineBuscaTests`.

## Avisos

### WR-01: byte NUL (`%00`) em `busca` ou `bairro` gera HTTP 500

**Arquivo:** `imoveis-aqui/Web/imoveis/api/views.py:365-371` e `411-417`
**Problema:** `?busca=a%00b` e `?bairro=a%00b` chegam ao Postgres como parâmetro de texto com NUL; o driver levanta `DataError: PostgreSQL text fields cannot contain NUL (0x00) bytes`, o que dá 500. Reproduzido no teste. Mesma classe de falha do CR-02, em endpoint público.
**Correção:** rejeitar antes de montar a consulta, num helper usado por `busca` e `bairro`:
```python
def _texto(params, nome, maximo=100):
    valor = params.get(nome, "")
    if "\x00" in valor or len(valor) > maximo:
        raise ValidationError({nome: "Valor inválido."})
    return valor.strip()
```

### WR-02: endpoints públicos sem limite de taxa e com listas CSV sem teto

**Arquivo:** `imoveis-aqui/Web/config/settings.py:134-142`, `imoveis-aqui/Web/imoveis/api/views.py:411-417`
**Problema:** `REST_FRAMEWORK` não define `DEFAULT_THROTTLE_CLASSES`, e as views públicas zeram `authentication_classes`. A consulta da vitrine faz `icontains` em `titulo`, `descricao` e no `Case` de bairro, com vários JOINs. Sozinho já é custo alto por requisição anônima; junto de CR-01 é a porta aberta. Além disso `?bairro=a,b,c,...` monta um `OR` de `iexact` por item, sem teto de itens nem de tamanho de `busca`.
**Correção:** adicionar `throttle_classes = [AnonRateThrottle]` (taxa em `DEFAULT_THROTTLE_RATES`) nas quatro views públicas, e limitar a quantidade de bairros (por exemplo 20) e o tamanho de `busca`.

### WR-03: opção de bairro devolvida por `/bairros/` pode não casar com o filtro `?bairro=` (busca vazia)

**Arquivo:** `imoveis-aqui/Web/imoveis/api/views.py:411-417` e `447-458`
**Problema:** o docstring de `BairrosDaCidadeAPIView` promete que "escolher uma opção nunca leva a uma busca vazia". O filtro faz `item.strip()` e compara com `iexact`, mas `/bairros/` devolve `bairro_anuncio` cru. Se um `Endereco.bairro` tiver espaço nas pontas (o modelo não normaliza; só serializers DRF/forms fazem `strip`, a seed, o admin e importações não), a opção `"Centro "` chega ao app, o servidor corta para `"Centro"` e `iexact` não encontra o registro. O mesmo vale para variações de caixa: `Centro` e `centro` aparecem como duas opções distintas (`distinct()` é sensível à caixa) que filtram exatamente os mesmos imóveis.
**Correção:** normalizar na origem da anotação para que lista e filtro usem o mesmo valor:
```python
from django.db.models.functions import Trim
# em vitrine.py: bairro_anuncio=Trim(_do_anuncio("bairro", "bairro"))
```
E, se quiser colapsar variações de caixa, devolver `Lower`-distinct com o primeiro valor. Teste: imóvel com bairro `" Moema "` aparece em `/bairros/` como `Moema` e `?bairro=Moema` o encontra.

### WR-04: seed grava título e descrição de apartamento com o bairro errado (e isso foi congelado nas fixtures do app)

**Arquivo:** `imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py:295, 317, 321-323` (impacto em `imovies-aqui-mobile/test/fixtures/api/lista_campinas_p1.json`)
**Problema:** o `bairro` do loop é o do endereço próprio do imóvel, mas apartamento usa o endereço do prédio (`_garantir_predio` escolhe `bairros[(ordem + 1) % len(bairros)]`). O título e a descrição saem com um bairro e o campo `bairro` da API com outro. Nas fixtures capturadas: o id 22 se chama "Apartamento no bairro Centro" e tem `"bairro": "Taquaral"`; o id 14 se chama "Apartamento no bairro Barão Geraldo" e o endereço do detalhe diz "Taquaral". Isso contamina `busca=Centro` (acha o apartamento que não é de Centro) e confunde qualquer conferência manual do app, além de ficar gravado nos testes do app como "resposta real".
**Correção:** para apartamento, usar o bairro do prédio no título e na descrição:
```python
if natureza == Imovel.Natureza.APARTAMENTO:
    predio = self._garantir_predio(empresa, cidade, rodada)
    bairro = predio.endereco.bairro
```
(antes de montar `titulo`/`descricao`, passando o prédio já obtido para `_criar_bloco_da_natureza`). Depois recapturar as fixtures.

### WR-05: a guarda do seed olha só `DEBUG`, não o banco de destino; README afirma mais isolamento do que existe

**Arquivo:** `imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py:136-141, 145, 150-165, 175, 200`; `imoveis-aqui/README.md` (seção "Seed de desenvolvimento")
**Problema:** `.env.example` entrega `DEBUG=True` por padrão. Quem apontar `DATABASE_URL` para um banco compartilhado/de homologação com `DEBUG=True` ganha 4 cidades, 6 características, uma empresa ativa, 2 usuários e ~40 imóveis publicados e visíveis na vitrine desse ambiente. O README diz que "nenhuma outra empresa é lida ou alterada", mas o comando: cria `Cidade` e `Caracteristica` globais (sem dono de empresa), lê `Usuario` por e-mail em todas as empresas (`filter(email=...)`) e usa `get_or_create` por nome de empresa, que levanta `MultipleObjectsReturned` se houver duas com o mesmo nome. Um CNPJ fixo (`66777888000505`) que já exista em outra empresa estoura `IntegrityError` no meio da execução. O corretor já existente é devolvido sem reconciliar `is_active` com o parâmetro `ativo`, então reexecutar depois de reativar o "corretor inativo" quebra o caso de borda sem aviso.
**Correção:** exigir confirmação explícita além do `DEBUG` (por exemplo `--confirmo` ou checar que o host do banco é local e imprimir o destino antes de gravar), tratar `MultipleObjectsReturned`/`IntegrityError` com `CommandError` claro, aplicar `is_active=ativo` ao corretor existente da empresa demo, e ajustar o texto do README para "cria também cidades e características globais".

### WR-06: testes de contrato do app leem arquivos de `.planning/`

**Arquivo:** `imovies-aqui-mobile/test/data/contrato_lista_test.dart:19-21, 55-58`; `imovies-aqui-mobile/test/data/contrato_detalhe_test.dart:312-314`
**Problema:** `flutter test` só passa se `.planning/phases/01-.../contrato/*.example.json` existir exatamente nesse caminho. Quando a fase 01 for arquivada, renomeada ou o pacote for gerado por CI sem `.planning/` (ou depois de `/gsd-cleanup`), esses testes quebram por motivo que não é regressão. Os exemplos são "cópia byte a byte da fixture", ou seja, a duplicação serve só para checar que ninguém editou à mão o documento de planejamento.
**Correção:** mover os exemplos para `test/fixtures/contrato/` (ou remover a duplicação e deixar a fixture capturada como única fonte), e o `.planning` apontar para lá.

## Informativos

### IN-01: `formatarValorCompacto` mostra "1.000 mil" perto de 1 milhão

**Arquivo:** `imovies-aqui-mobile/lib/presentation/vitrine/apresentacao_filtros.dart:151-159`
**Problema:** o comentário diz que o valor dividido "nunca chega a 1000", mas `999950` a `999999` dividem para 999,95 a 999,999 e `'#,##0.#'` arredonda para `1.000`, gerando "1.000 mil" (deveria ser "1 mi"). Entrada válida: a máscara aceita até 9 dígitos.
**Correção:** comparar após arredondar (`if (valor >= 999950)` usa a escala de milhões) e acrescentar teste para 999950 e 999999.

### IN-02: andar 0 (térreo) aparece como "0º"

**Arquivo:** `imovies-aqui-mobile/lib/presentation/detalhe_imovel/apresentacao_natureza.dart:130-131`
**Problema:** o model da API documenta `andar` com `help_text="0 para o térreo."`, e o app mostra "Andar: 0º".
**Correção:** `valor: andar == 0 ? 'Térreo' : '${andar}º'` e um teste.

### IN-03: comentários desatualizados após a remoção dos mocks

**Arquivo:** `imovies-aqui-mobile/lib/domain/repositories/opcoes_filtro_repository.dart:5-9`; `imovies-aqui-mobile/lib/domain/entities/imovel.dart:5-7, 49-53`; `imovies-aqui-mobile/lib/presentation/vitrine/rascunho_filtros_cubit.dart:35-38, 87-90`; `imovies-aqui-mobile/lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart:36-38, 436, 477-478, 589`
**Problema:** ainda falam em "impl concreta lê a mesma fixture", "Fase 4 troca por `dio` contra `GET /api/publico/bairros/`" (a rota real é `/cidades/<id>/bairros/`), "campo PENDENTE E2 ... `null` até o backend confirmar" (a API já manda `natureza` e `quartos`) e "servidor simulado". Quem lê o código hoje é induzido a achar que a integração ainda é mock.
**Correção:** reescrever os comentários para o estado atual (API pública real).

### IN-04: código morto no modelo de dados

**Arquivo:** `imovies-aqui-mobile/lib/data/models/detalhe_imovel_model.dart:163`; `imovies-aqui-mobile/lib/data/models/imovel_model.dart:26-30`
**Problema:** `FotoImovelModel.paraEntidade()` nunca é chamado (o mapeamento é refeito em linha em `DetalheImovelModel.paraEntidade`, linhas 74-78). `ImovelModel` declara `suites`, `vagas` e `area` que `paraEntidade()` descarta.
**Correção:** reutilizar `foto.paraEntidade()` no mapeamento (e filtrar a URL dentro dele), e remover os campos não usados do modelo da lista (ou levá-los à entidade se o card for usá-los).

### IN-05: chip de bairros mostra o primeiro por ordem de inserção, não de forma determinística

**Arquivo:** `imovies-aqui-mobile/lib/presentation/vitrine/apresentacao_filtros.dart:70, 141-145`
**Problema:** para características o chip usa nomes ordenados ("o chip mostra sempre o mesmo primeiro nome"), mas para bairros `_rotuloMultiSelecao(filtros.bairros)` pega `.first` do `Set` na ordem em que o usuário marcou. Marcar Taquaral e depois Cambuí mostra "Taquaral +1" e a URL enviada ordena por Cambuí. Inconsistência de apresentação, não de dados.
**Correção:** passar bairros ordenados por `normalizarTexto`, como já é feito com as características.

### IN-06: `next` de paginação atrás de proxy TLS pode ser rejeitado pela guarda de mesma origem

**Arquivo:** `imovies-aqui-mobile/lib/data/datasources/imovel_remote_datasource.dart:53-66`; `imoveis-aqui/Web/config/settings.py` (sem `SECURE_PROXY_SSL_HEADER`/`USE_X_FORWARDED_HOST`)
**Problema:** o DRF monta `next` com o esquema/host que o Django enxerga. Em produção atrás de proxy que termina TLS, sem `SECURE_PROXY_SSL_HEADER`, o `next` volta `http://` enquanto a base do app é `https://`, e a segunda página falha para sempre com `FormatException` (a guarda de origem está correta; a falha seria de configuração). Não afeta o desenvolvimento.
**Correção:** registrar no checklist de deploy da API (`SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")`) e, se desejado, um teste do app com `next` de esquema diferente para documentar o comportamento.

### IN-07: ferramenta de captura grava fixtures parcialmente e roda contra qualquer URL

**Arquivo:** `imovies-aqui-mobile/tool/capturar_fixtures_api.py:76-127, 190-216`
**Problema:** cada `salvar()` grava no meio do fluxo; se uma validação seguinte falhar, `test/fixtures/api` fica com um conjunto misto de capturas novas e antigas, sem aviso. Nada impede apontar `URL_BASE` para um servidor real (os dados reais viram fixtures versionadas). A captura é feita em SQLite, enquanto produção é Postgres: a ordenação de `bairros` (`order_by("bairro_anuncio")`) depende do collation do banco e pode diferir da fixture.
**Correção:** acumular tudo em memória e gravar só no fim, recusar `URL_BASE` que não seja `127.0.0.1`/`localhost` sem `--permitir-remoto`, e anotar a diferença de collation no cabeçalho do script.

### IN-08: 404 do detalhe ainda mostra a foto de capa da prévia

**Arquivo:** `imovies-aqui-mobile/lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:96-111, 114-115`
**Problema:** o comentário explica que no 404 o preço da prévia não é mostrado, mas a `flexibleSpace` continua exibindo `previa.fotoCapa` do imóvel que saiu do ar, com o texto "Este imóvel não está mais disponível" logo abaixo. Inconsistente com a decisão de esconder dados do anúncio retirado.
**Correção:** `DetalheNaoEncontrado() => const SizedBox.shrink()` (ou um fundo neutro) no `switch` do `background`.

### IN-09: um item inválido derruba a página inteira da lista, ao contrário das demais fontes

**Arquivo:** `imovies-aqui-mobile/lib/data/models/imovel_model.dart:55-65`; `imovies-aqui-mobile/lib/data/models/imoveis_envelope_model.dart:29-32`
**Problema:** cidades, bairros e características descartam linhas inválidas, mas na lista de imóveis uma única `finalidade` desconhecida lança `FormatException` e a vitrine inteira cai em erro. Se o servidor ganhar uma finalidade nova, o app deixa de mostrar qualquer imóvel até ser atualizado.
**Correção:** decidir conscientemente: descartar o item (com `try/catch` por item em `paraPagina`) ou manter a falha, e registrar a decisão num teste. Hoje é um comportamento diferente do resto sem justificativa escrita.

---

_Revisado em: 2026-11-01_
_Revisor: Claude (gsd-code-reviewer)_
_Profundidade: standard_
