# Contrato da API Pública — vitrine e página do imóvel (formato real, Fase 5)

**Status:** descreve a API que existe na branch `feat/APP05` do repositório irmão
(`../imoveis-aqui/Web`, Django 5.2 + DRF). Os exemplos em `contrato/*.example.json` são **cópias
exatas** de respostas capturadas dessa API semeada (D-02) e `test/data/contrato_lista_test.dart` /
`test/data/contrato_detalhe_test.dart` falham se divergirem das fixtures de `test/fixtures/api/` ou
se o conjunto de chaves de qualquer objeto mudar.

**Histórico:** as propostas congeladas nas Fases 1 a 4 (paginação por cursor, `GET /api/publico/imoveis/?cidade=`,
`ordenacao`, sufixo `_min`, `bairro`/`caracteristicas` por nome, `corretor{slug}`, `lote.preco`,
`posicao_solar` livre etc.) foram **substituídas** na Fase 5 pelo formato real da API, que é dona
dos dados e das regras (D-01, D-02). O texto antigo continua no histórico do git. O app não
decide regra de negócio: tudo chega calculado e filtrado do servidor.

**Rotas** (todas `GET`, `AllowAny`, sem token — um token vencido no aparelho não impede a consulta):

| Rota | O que devolve |
|------|---------------|
| `/api/publico/cidades/` | array de cidades com vitrine (§2) |
| `/api/publico/cidades/<id>/imoveis/` | lista paginada da vitrine de uma cidade (§3–§5) |
| `/api/publico/cidades/<id>/bairros/` | bairros com imóvel na vitrine da cidade (§9) |
| `/api/publico/caracteristicas/` | catálogo global de características (§10) |
| `/api/publico/imoveis/<id>/` | detalhe de um imóvel da vitrine (§11) |

Todo número monetário, área, medida e coordenada chega como **string decimal** (padrão do DRF para
`DecimalField`); o app formata e nunca calcula.

---

## 1. Fonte da verdade e git

- A regra do que aparece é a `Imovel.objects.na_vitrine()` da W08: `publicado=True`,
  `situacao=DISPONIVEL` e `empresa.ativa=True`. A lista, o detalhe, as cidades e os bairros partem da
  mesma `imoveis_da_vitrine()`, então uma opção oferecida nunca leva a uma busca vazia.
- As chaves de cada objeto público estão travadas por teste de **igualdade exata de conjunto**
  (`VitrineAllowlistExataTests`, 05-02) e por uma deny-list (`proprietario`, `documento`, `empresa`, `codigo`, `publicado`, `vendido`, `situacao`,
  `documentos`, `historico`, ...). Quem ganhar ou perder uma chave quebra o teste
  do Django **e** o teste de contrato do app.
- Regenerar os exemplos: ver §12.

---

## 2. `GET /api/publico/cidades/`

Array JSON simples (sem envelope e sem paginação, D-05). Só entram cidades que têm **pelo menos um
imóvel na vitrine** (`Cidade.objects.filter(pk__in=imoveis_da_vitrine().values("cidade_anuncio"))`) —
o visitante nunca escolhe uma cidade que não devolve nada. Ordenado por nome.

| Campo | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | usado na rota da lista e dos bairros (A-01); **não** é a identidade da cidade no app |
| `nome` | string | |
| `uf` | string (2) | sigla, ex. `"SP"` |

A identidade da cidade no app continua sendo a chave natural `nome-uf` (preferência salva no
aparelho); o `id` é só um atributo de roteamento (A-01).

Exemplo: `contrato/cidades.example.json` (Campinas, Indaiatuba, Valinhos, Vinhedo).

---

## 3. `GET /api/publico/cidades/<id>/imoveis/` — item da lista

Cidade inexistente: **404** `{"detail": ...}`. Cidade existente sem imóvel: `200` com `results: []`.

Chaves exatas do item (travadas em 05-02):

| Campo | Tipo | Nulo? | Observação |
|-------|------|-------|------------|
| `id` | inteiro | não | |
| `titulo` | string | não | |
| `natureza` | enum | não | `CASA` \| `APARTAMENTO` \| `TERRENO` \| `LOTE` |
| `finalidade` | enum | não | `VENDA` \| `ALUGUEL` \| `VENDA_E_ALUGUEL` |
| `preco_venda` | string decimal | sim | `null` quando só `ALUGUEL` |
| `preco_aluguel` | string decimal | sim | `null` quando só `VENDA` |
| `preco_condominio` | string decimal | sim | |
| `bairro` | string | sim | bairro do endereço do anúncio (do prédio, no apartamento); o app trata `null` como vazio |
| `area` | string decimal (m²) | sim | **por natureza**: casa = `area_construida`; apartamento = `area_privativa`; terreno = `area_total`; lote = `area` do lote |
| `quartos`, `suites`, `vagas` | inteiro | sim | da casa ou do apartamento; terreno e lote vêm `null` |
| `foto_capa` | string URL absoluta | sim | a foto marcada como capa; sem capa vale a primeira; `null` sem fotos |

A lista **não** traz `descricao`, `cidade`, `caracteristicas` nem `criado_em` (a cidade está na rota).

Exemplo: `contrato/imoveis.example.json` (primeira página de Campinas, 20 de 24).

---

## 4. Paginação — `PageNumberPagination`

Envelope: `{"count": <total>, "next": <url|null>, "previous": <url|null>, "results": [...]}`, com
`page_size = 20` fixo. `next` e `previous` são **URLs absolutas** na origem do servidor.

- O app segue `next` tal e qual (nunca reconstrói a URL) e **só** se tiver a mesma origem da base URL
  configurada (T-05-09-01); `next` de outra origem vira falha.
- O app descarta ids já listados ao anexar uma página (a ordem é estável: o `id` desempata no fim,
  mas o acervo pode mudar entre as páginas).
- Página fora do intervalo: **404** `{"detail": ...}` (comportamento padrão do DRF).
- `count` existe, mas a UI não mostra prévia numérica no botão de filtros (API-05 continua v2).

---

## 5. Parâmetros de consulta da lista (nomes da W09)

| Param | Semântica |
|-------|-----------|
| `busca` | texto; `icontains` em `titulo`, bairro e `descricao`. Aparado; vazio é ignorado; **até 200 caracteres** depois de aparado; o byte NUL (`%00`) dá 400. **Sensível a acento** (risco aceito, D-14) |
| `ordenar` | `recentes` (padrão) \| `preco` \| `-preco` \| `area` \| `-area`; nulos sempre por último; empate desfeito por `-id` |
| `finalidade` | `VENDA` \| `ALUGUEL`; inclusivo (`VENDA` traz também `VENDA_E_ALUGUEL`, idem `ALUGUEL`). `VENDA_E_ALUGUEL` como parâmetro dá 400 |
| `natureza` | CSV, **OU** entre os valores (`natureza=CASA,LOTE`); valor fora do enum dá 400 |
| `quartos`, `suites`, `vagas` | inteiro ASCII (só dígitos `0-9`), **mínimo** ("N ou mais"), de 0 a **32767**; negativo, não-inteiro ou acima do teto dá 400 |
| `bairro` | CSV de nomes, **OU**, sem diferenciar maiúsculas (`bairro=Cambuí,Taquaral`); **até 20 itens** de **até 100 caracteres** cada; o byte NUL dá 400 |
| `preco_min`, `preco_max` | decimal ASCII (`123` ou `123.45`) de 0 a **9999999999.99** (o teto da coluna de preço); limites inclusivos; compara `preco_venda` com `finalidade=VENDA`, `preco_aluguel` com `ALUGUEL` e o primeiro preenchido sem `finalidade` |
| `area_min`, `area_max` | decimal ASCII (`123` ou `123.45`) de 0 a **99999999.99** (o teto da coluna de área, que é menor que o do preço), inclusivo, sobre a `area` do item (§3) |
| `caracteristicas` | CSV de **ids** inteiros positivos (do catálogo, §10), **E** (o imóvel precisa ter todas, numa única subconsulta); até **20 ids distintos** (repetidos contam uma vez); nome no lugar do id dá 400 |
| `page` | número da página (o app não monta: segue `next`) |

Parâmetros diferentes combinam por E. Um filtro numérico ativo exclui a linha cujo valor é nulo.

**Formato numérico:** só dígitos ASCII `0-9`, com um ponto decimal opcional nos decimais. Recusados com 400:
expoente (`1e3`), `NaN`, `Infinity`, sinal de mais, espaço, sublinhado (`1_0`) e dígito não ASCII. Nenhuma
entrada hostil dá 500, inclusive o byte NUL em qualquer parâmetro.

**Mapeamento do app (`parametrosDaApi`)**: `OrdenacaoVitrine.maisRecentes` -> `recentes`; `precoAsc` -> `preco`;
`precoDesc` -> `-preco`; `areaAsc` -> `area`; `areaDesc` -> `-area`. `quartosMin`/`suitesMin`/`vagasMin` do
domínio viajam como `quartos`/`suites`/`vagas`. Naturezas saem na ordem do enum, bairros ordenados por
texto normalizado e características por id crescente, para que a mesma escolha gere sempre a mesma URL
(D-07).

**Erros 400** (valor inválido): corpo `{"<campo>": "<mensagem em português>"}`, por exemplo
`test/fixtures/api/erro_400_natureza.json`:
`{"natureza": "Opções válidas: CASA, TERRENO, APARTAMENTO, LOTE."}`. O app mostra o estado de erro com
"Tentar de novo"; nunca inventa dado. Mensagens, exatamente como a view as devolve:

| Campo | Quando | Mensagem |
|-------|--------|----------|
| `preco_min`, `preco_max`, `area_min`, `area_max`, `quartos`, `suites`, `vagas` | fora do formato numérico (expoente, NaN, Infinity, sinal, espaço, sublinhado, dígito não ASCII, decimal onde se espera inteiro) | `Informe um número válido.` |
| os mesmos sete | valor negativo | `O valor não pode ser negativo.` |
| os mesmos sete | acima do teto (preço 9999999999.99, área 99999999.99, inteiro 32767) | `O valor passa do máximo permitido.` |
| `natureza`, `finalidade`, `ordenar` | valor fora do enum | `Opções válidas: ...` (lista os valores aceitos, ex. `Opções válidas: CASA, TERRENO, APARTAMENTO, LOTE.`) |
| `busca`, `bairro` | contém o byte NUL | `O texto tem um caractere inválido.` |
| `busca` | mais de 200 caracteres | `Use no máximo 200 caracteres.` |
| `bairro` | mais de 20 itens | `Escolha no máximo 20 bairros.` |
| `bairro` | item com mais de 100 caracteres | `Cada bairro tem no máximo 100 caracteres.` |
| `caracteristicas` | item que não é inteiro positivo (nome no lugar do id, zero, negativo) | `Informe os ids separados por vírgula.` |
| `caracteristicas` | mais de 20 ids distintos | `Escolha no máximo 20 características.` |

## Erros 429 (limite de taxa)

As **cinco rotas públicas** da tabela de rotas (lista, detalhe, cidades, bairros e características) dividem
**um só balde por IP** (escopo `vitrine_publica`, `ThrottleVitrinePublica` do DRF). Quem passa da taxa recebe:

- status **429**;
- cabeçalho **`Retry-After`** (segundos até poder tentar de novo);
- corpo `{"detail": "<texto em português>"}`, o mesmo formato `{detail}` do 404 (`test/fixtures/api/erro_404_detalhe.json`).

**Taxa:** padrão `120/min` por IP, ajustável por `VITRINE_TAXA_ANONIMA` (formato do DRF: `número/periodo`).
Navegar pelo app usa em torno de 4 requisições ao abrir a vitrine e uma por página, busca ou detalhe, bem abaixo
do limite. **`NUM_PROXIES`** (padrão `0` = usa o IP da conexão e ignora o `X-Forwarded-For`, que o cliente
forja; atrás de proxy reverso, o número de proxies confiáveis). A API autenticada do painel **não** é limitada.

**No app (D-14):** 429 é uma falha como qualquer outra: o `ImovelRepositoryImpl` devolve `Result.failure` com a
`DioException` e a UI mostra o estado de erro com "Tentar de novo", sem nova tentativa automática. No detalhe,
só o 404 vira "não encontrado" (D-17); o 429 vira falha com o erro do dio. Nenhuma mudança em `lib/`; travado
por testes (`test/data/imovel_remote_datasource_test.dart`, `test/data/imovel_detalhe_repository_impl_test.dart`).

---

## 6. Allowlist exata — o que é (e o que nunca é) público

Chaves exatas, iguais às de `VitrineAllowlistExataTests`:

- **item da lista:** as 13 chaves do §3.
- **detalhe:** `id`, `titulo`, `natureza`, `finalidade`, `preco_venda`, `preco_aluguel`,
  `preco_condominio`, `preco_iptu`, `descricao`, `caracteristicas`, `casa`, `terreno`, `apartamento`,
  `lote`, `endereco`, `fotos`, `corretor_responsavel`.
- **endereco:** `logradouro`, `numero`, `bairro`, `cep`, `cidade`, `latitude`, `longitude`.
- **cidade:** `id`, `nome`, `uf`. **foto:** `imagem`, `ordem`, `capa`. **característica:** `id`, `nome`.
- **casa, terreno, apartamento, predio, lote, quadra, loteamento e corretor_responsavel:** ver §11.3 e §11.4.

**Nunca** aparecem: `proprietario`, `documento`, `empresa` do imóvel, `codigo`, `publicado`, `vendido`, `situacao`,
`documentos`, `historico`, nem imóvel não publicado, reservado ou de empresa inativa. O serializer público
é dedicado, com `fields` listados um a um — nunca o `ImovelSerializer` do painel.

**Decisão do corretor (05-02, opcao-a):** `corretor_responsavel` usa o `CorretorPublicoSerializer` da W02
tal como está. Os campos que **qualquer visitante recebe sem token** são exatamente:
`id`, `empresa_id`, `nome`, `foto`, `email`, `creci`, `telefone`, `whatsapp`, `apresentacao`. O app
declara só `id`, `nome` e `foto` (D-16) e descarta o resto; a revisão desse conjunto é **PENDENTE** da
frente web (ver §11.5, itens g e l).

---

## 7. Isolamento

A vitrine reúne imóveis de **várias empresas** da mesma cidade (marketplace). O que o servidor garante, por
queryset e não por confiança no cliente, é que nada fora de `na_vitrine()` escapa por manipulação de `id`,
cidade ou qualquer parâmetro. O mesmo vale para o detalhe: 404 idêntico (§11.1).

---

## 8. Riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **Vírgula dentro do nome de um bairro (A-05).** `bairro` viaja em CSV; um bairro "Jardim, Vila" seria partido em dois. | Aceito: os dados não têm vírgula nos nomes; travado por teste no Django e documentado no README da API. Se aparecer, o contrato muda para `getlist("bairro")` ou id de bairro. |
| **Busca sensível a acento (Pitfall 3, D-14).** `busca=Cambui` não acha "Cambuí" no Postgres. | Aceito nesta fase; `unaccent` é melhoria da frente web. |
| **`Cidade.id` como atributo de roteamento (A-01).** A identidade da cidade no app é `nome-uf`; o `id` pode divergir entre ambientes (dev x produção). | Aceito: o app pega o `id` da lista de cidades carregada; sem `id` a vitrine mostra "Tentar de novo". Fixture e servidor de captura têm ids determinísticos. |
| **Dados de contato do corretor no payload público.** | PENDENTE, ver §11.5 (g). |
| **Área de 9 dígitos no app.** O campo de área aceita 9 dígitos (`_maximoDigitos = 9` em `mascara_numerica.dart`); uma área de 100.000.000 m² ou mais passa do teto da coluna (99999999.99) e a API responde 400. | Aceito: nenhum anúncio real chega a 100 km². O app mostra o estado de erro com "Tentar de novo"; `lib/` não muda (D-01). |
| **IP compartilhado (CGNAT, proxy sem `NUM_PROXIES`).** Muitos aparelhos atrás do mesmo IP dividem o balde de 120/min e podem receber 429. | Aceito: ajustável por `VITRINE_TAXA_ANONIMA`; atrás de proxy reverso, configurar `NUM_PROXIES`. Item de deploy. |
| **`LocMemCache` por processo.** O contador do limite fica na memória de cada worker; com vários workers o limite efetivo multiplica. | Aceito no dev; produção deve usar cache compartilhado. Item de deploy. |
| **O app não limita o tamanho da busca nem a quantidade de bairros/características marcados.** Busca com mais de 200 caracteres, mais de 20 bairros ou mais de 20 características dão 400. | Aceito (raro): o excesso vira o estado de erro com "Tentar de novo"; `lib/` não muda (D-01). |
| **Rotas públicas da frente web sem limite:** `corretores/<id>/` e `empresas/<id>/`. | Fora do escopo: o app não as consome; dona: a frente web. |

---

## 9. `GET /api/publico/cidades/<id>/bairros/`

Array JSON de strings, sem paginação, **ordenado** e sem repetição, derivado de `imoveis_da_vitrine()`
(apartamento pelo bairro do prédio; bairro vazio ou nulo fica de fora). Cidade sem imóvel: `[]`. Cidade
inexistente: 404. `POST`: 405.

Exemplo: `contrato/bairros.example.json`.

---

## 10. `GET /api/publico/caracteristicas/`

Catálogo **global** (não por cidade), array `[{"id": 1, "nome": "Piscina"}, ...]` ordenado por nome, sem
paginação, inclusive características sem uso. O filtro da lista envia os **ids** (§5), nunca o nome.

Exemplo: `contrato/caracteristicas.example.json`.

---

## 11. `GET /api/publico/imoveis/<id>/` — detalhe

### 11.1 Resposta

- **200:** objeto das seções 11.2 a 11.4.
- **404** `{"detail": "No Imovel matches the given query."}` — **idêntico** para id inexistente, rascunho,
  reservado/vendido e empresa inativa, para que ninguém consiga enumerar o que não é público.
- Sem paginação; consulta fixa ao banco (sem N+1). URLs de `fotos[].imagem` e `corretor_responsavel.foto`
  saem **absolutas** (`context={"request": request}`).

### 11.2 Campos comuns

| Campo | Tipo | Nulo? | Observação |
|-------|------|-------|------------|
| `id`, `titulo`, `natureza`, `finalidade` | | não | igual à lista |
| `preco_venda`, `preco_aluguel` | string decimal | sim | |
| `preco_condominio`, `preco_iptu` | string decimal | sim | públicos **somente no detalhe** (e `preco_condominio` também na lista); período do IPTU: ver §11.5 (c) |
| `descricao` | string | não | pode ser `""` |
| `caracteristicas` | lista `[{id, nome}]` | não | pode ser `[]` |
| `endereco` | objeto | sim | `logradouro`, `numero`, `bairro`, `cep`, `cidade{id, nome, uf}`, `latitude`, `longitude` (strings decimais ou `null`). Apartamento mostra o endereço do prédio; o lote, o do imóvel |
| `fotos` | lista `[{imagem, ordem, capa}]` | não | **com a capa primeiro** (regra da API: `-capa, ordem, id`, 05-02); `[]` sem fotos. O app mostra a ordem recebida e **nunca reordena** |
| `corretor_responsavel` | objeto ou `null` | sim | `null` quando o imóvel não tem corretor ou ele está inativo. Chaves: §6 |
| `casa`, `terreno`, `apartamento`, `lote` | objeto ou `null` | sim | **exatamente um** preenchido, o da `natureza`; os outros três vêm `null` |

### 11.3 Blocos por natureza (chaves exatas)

Todo campo de bloco é anulável: o app omite a linha cujo valor é `null` e esconde a seção inteira quando
todos os campos são nulos.

**`casa`** (14): `area_terreno`, `area_construida`, `area_livre` (strings decimais); `quartos`, `suites`,
`banheiros`, `salas`, `vagas`, `pavimentos`, `ano_construcao` (inteiros); `piscina`, `quintal`,
`churrasqueira`, `mobiliada` (booleanos). `area_livre` é **calculada pelo servidor** (`area_terreno -
area_construida`), `null` se faltar uma das duas, nunca `0`; o app nunca a calcula.

**`terreno`** (9): `area_total`, `frente`, `fundo`, `lateral_esquerda`, `lateral_direita` (strings decimais);
`topografia` (`PLANO` \| `ACLIVE` \| `DECLIVE`); `murado`, `esquina` (booleanos); `uso_permitido` (**código**
`RESIDENCIAL` \| `COMERCIAL` \| `MISTO` \| `INDUSTRIAL` \| `RURAL`; rótulo em português no app, A-04).

**`apartamento`** (10): `predio` (objeto ou `null`), `andar`, `quartos`, `suites`, `banheiros`, `vagas`
(inteiros); `area_privativa`, `area_total` (strings decimais); `varanda` (booleano); `posicao_solar`
(**código** `NASCENTE` \| `POENTE` \| `NORTE` \| `SUL`, pode ser `""`; rótulo no app, vazio omite a linha).
**Não** há número da unidade (omitido de propósito).

**`apartamento.predio`** (9): `nome`; `andares`, `ano_construcao`, `elevadores` (inteiros); `portaria_24h`,
`piscina`, `academia`, `salao_de_festas`, `playground` (booleanos). **Não** há `unidades_por_andar`.

**`lote`** (8): `numero` (string), `area`, `frente`, `fundo`, `entrada_minima` (strings decimais),
`parcelas_maximas` (inteiro), `condicoes_parcelamento` (string), `quadra` (objeto ou `null`). **Não** há
`preco` (o preço do lote é o `preco_venda` do imóvel, W07), `vendido`, ids nem cidade.

**`lote.quadra`** (2): `identificacao`, `loteamento` (objeto ou `null`).

**`lote.quadra.loteamento`** (8): `nome`, `incorporadora`, `areas_de_lazer` (string livre; o app a mostra em
texto corrido e **não** a divide por vírgula) e cinco booleanos de infraestrutura `asfalto`, `agua`,
`energia`, `esgoto`, `iluminacao` (o app traduz os verdadeiros em rótulos, em ordem fixa).

### 11.4 Exemplos

- `contrato/imovel_detalhe.example.json` — apartamento 22 (alugado, Taquaral, Campinas), com `predio`.
- `contrato/imovel_detalhe_lote.example.json` — lote 24 (venda, Barão Geraldo, Campinas), com quadra e loteamento.

### 11.5 Itens que a Fase 1 deixou em aberto (a–k) e os que surgiram na Fase 5 (l)

**RESOLVIDO** = decidido pelo código da web (ou do app) entregue na Fase 5. **PENDENTE** = depende da
frente web ou de produto; nenhum deve ser tratado como decidido pelo app.

| Item | Situação | Resolução / pendência |
|------|----------|----------------------|
| **(a)** `corretor.slug` | RESOLVIDO | `Usuario` não tem `slug` e o wire não traz: o perfil abre com o `corretor_responsavel` **já carregado pelo detalhe**, nunca por URL montada (05-16). O campo agora se chama `corretor_responsavel`. |
| **(b)** `posicao_solar` sem conjunto fechado | RESOLVIDO | É um **código** (`PosicaoSolar`: `NASCENTE`, `POENTE`, `NORTE`, `SUL`, ou `""`); o rótulo em português fica no app, com fallback para o texto cru (A-04, 05-17). |
| **(c)** período do `preco_iptu` (mensal ou anual) | **PENDENTE** (web) | Indefinido na W06/W08. O app mostra `IPTU R$ X` sem `/mês` nem `/ano`; o condomínio é `/mês`. |
| **(d)** `lote.preco` x `preco_venda` | RESOLVIDO | W07: o lote **não tem preço próprio**; o preço do lote é o `preco_venda` do imóvel. O bloco `lote` não tem `preco` (D-06) e o app não mostra "Preço do lote". |
| **(e)** regra de `area_livre` | RESOLVIDO | `Casa.area_livre` (W05) é property do servidor: `area_terreno - area_construida`, `null` se faltar entrada. O app nunca calcula. |
| **(f)** URLs absolutas | RESOLVIDO | `fotos[].imagem`, `foto_capa` e `corretor_responsavel.foto` saem absolutas via `request.build_absolute_uri` / `context={"request": request}`. |
| **(g)** exposição de contato do corretor (LGPD) | **PENDENTE** (web/produto) | O `CorretorPublicoSerializer` da W02 expõe sem token `id`, `empresa_id`, `nome`, `foto`, `email`, `creci`, `telefone`, `whatsapp`, `apresentacao` (05-02, opcao-a). O app usa só `id`, `nome` e `foto`. A revisão da exposição é decisão da frente web/produto e foi adiada (CONTEXT, Deferred). |
| **(h)** `terreno.laterais` | RESOLVIDO | São duas medidas: `lateral_esquerda` e `lateral_direita` (W05); duas linhas na UI (D-17). |
| **(i)** qual área a lista espelha | RESOLVIDO | `area_anuncio` por natureza: casa `area_construida`, apartamento `area_privativa`, terreno `area_total`, lote `area` (§3). |
| **(j)** latitude/longitude como string decimal | RESOLVIDO | `DecimalField` serializa como string (padrão do DRF); o Model do app lê string. |
| **(k)** `natureza` e blocos dependem de W05/W06/W07 | RESOLVIDO | As quatro naturezas (inclusive `LOTE`) e seus blocos foram entregues (W05–W08, merge `feat/APP05`). |
| **(l)** `empresa_id` no payload público do corretor | **PENDENTE** (web) | Veio da W02 e permanece (05-02, opcao-a); é um id interno que a vitrine não precisa. Sugestão à frente web: removê-lo do `CorretorPublicoSerializer` junto com a revisão LGPD de (g). O app o ignora. |

---

## 12. Sincronização e antidrift (substitui as notas de sincronização antigas)

O contrato **não** é mais "rascunho aguardando sign-off do E2": é a descrição do que a API faz, e os
exemplos são respostas reais. Para recapturar tudo (quando o servidor mudar):

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo todos
```

(procedimento completo, com SQLite temporário e servidor local, no docstring de `tool/capturar_fixtures_api.py`
e no README do app), depois copiar byte a byte para `contrato/`:

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `cidades.json` | `cidades.example.json` |
| `lista_campinas_p1.json` | `imoveis.example.json` |
| `detalhe_apartamento.json` | `imovel_detalhe.example.json` |
| `detalhe_lote.json` | `imovel_detalhe_lote.example.json` |
| `bairros_campinas.json` | `bairros.example.json` |
| `caracteristicas.json` | `caracteristicas.example.json` |

A superfície de erro (400 e 429) é travada por `VitrineBuscaTests` e `VitrineLimiteDeTaxaTests` no Django e
pelos testes de 400/429 do app (`imovel_remote_datasource_test.dart`, `imovel_detalhe_repository_impl_test.dart`).

Os testes de contrato do app (`test/data/contrato_lista_test.dart`, `test/data/contrato_detalhe_test.dart`)
comparam cada exemplo com sua fixture e travam as chaves exatas de cidade, envelope, item, opções, detalhe e
dos blocos de natureza; no Django, `VitrineAllowlistExataTests` trava o mesmo do lado do servidor. Não há
mais cópia manual do documento para o repositório da API.
