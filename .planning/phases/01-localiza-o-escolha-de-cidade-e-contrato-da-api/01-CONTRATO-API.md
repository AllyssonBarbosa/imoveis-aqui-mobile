# Contrato da API Pública — vitrine e página do imóvel (formato real, Fase 5)

**Status:** descreve a API que existe na branch `feat/APP05` do repositório irmão
(`../imoveis-aqui/Web`, Django 5.2 + DRF). Os exemplos em `contrato/*.example.json` são **cópias
exatas** de respostas capturadas dessa API semeada (D-02) e `test/data/contrato_lista_test.dart` /
`test/data/contrato_detalhe_test.dart` falham se divergirem das fixtures de `test/fixtures/api/` ou
se o conjunto de chaves de qualquer objeto mudar.

**Perfis e vitrine do anunciante (Fase 7 / 07.1):** os perfis públicos vêm da `main` da web; a vitrine do
anunciante e a correção do perfil de corretor de empresa inativa (D-11) vêm da branch `feat/APP07` da web,
até ela entrar na `main` dela. Ver §13.

**Login e acervo do corretor (Fase 8):** as rotas autenticadas (`/api/auth/login/`, `/api/auth/eu/`, `/api/auth/sair/` e a
lista do acervo em `GET /api/imoveis/`) vêm da branch `feat/APP08` da web, até ela entrar na `main` dela. Ver §14; os
exemplos `acervo`, `eu` e `login` são travados por `test/data/contrato_acervo_test.dart`.

**Caixa de contatos do corretor (Fase 10):** a lista paginada, a contagem dos sem retorno, as opções do filtro de imóvel e o PATCH do retorno vêm da branch `feat/APP10` da web, até ela entrar na `main` dela. Ver §16; os exemplos `contatos`, `contatos_resumo`, `contatos_imoveis` e `contato_patch` são travados por `test/data/contrato_contatos_test.dart`.

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
| `/api/publico/corretores/<id>/` | perfil público do corretor (§13.1) |
| `/api/publico/empresas/<id>/` | perfil público da empresa (§13.1) |
| `/api/publico/corretores/<id>/imoveis/` | lista paginada da vitrine de um corretor (§13.2–§13.5) |
| `/api/publico/empresas/<id>/imoveis/` | lista paginada da vitrine de uma empresa (§13.2–§13.5) |

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

As **sete rotas públicas** com limite de taxa (lista, detalhe, cidades, bairros, características e as duas
vitrines do anunciante, `corretores/<id>/imoveis/` e `empresas/<id>/imoveis/`) dividem
**um só balde por IP** (escopo `vitrine_publica`, `ThrottleVitrinePublica` do DRF). O **POST de contato** (§15)
tem balde **próprio** (escopo `contato_publico`, `CONTATO_TAXA_ANONIMA`, padrão `10/min`), separado do da
vitrine: navegar não gasta o limite do contato. Quem passa da taxa, em qualquer um dos dois, recebe:

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
  `lote`, `endereco`, `fotos`, `corretor_responsavel`, `canais_contato`.
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
| `canais_contato` | lista de strings | não | subconjunto de `WHATSAPP`, `TELEFONE`, `EMAIL`, **na ordem fixa** nessa sequência e sem repetição; **só nomes**, nunca número, e-mail nem link (o link só vem do POST, §15). `[]` esconde a área de contato no app (D-03). Só existe no detalhe, não na lista (D-04) |

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
| `perfil_corretor.json` | `perfil_corretor.example.json` |
| `perfil_empresa.json` | `perfil_empresa.example.json` |
| `vitrine_corretor_p1.json` | `vitrine_anunciante.example.json` |

Os três últimos vêm dos grupos de captura `perfis` e `anunciante` (§13.8), que se capturam à parte do `todos`.

As fixtures do contato (grupo `--grupo contato`, parte do `todos`) são `contato_201_whatsapp.json`,
`contato_201_telefone.json`, `contato_201_email.json` e `erro_400_canal_contato.json`; o detalhe capturado
agora traz `canais_contato`. Elas gravam contatos só no SQLite temporário da captura, nunca no banco do `Web/.env`,
e `test/data/contrato_contato_test.dart` as trava (chaves `{canal, link}`, esquema de cada link, round-trip).

A superfície de erro (400 e 429) é travada por `VitrineBuscaTests` e `VitrineLimiteDeTaxaTests` no Django e
pelos testes de 400/429 do app (`imovel_remote_datasource_test.dart`, `imovel_detalhe_repository_impl_test.dart`).

Os testes de contrato do app (`test/data/contrato_lista_test.dart`, `test/data/contrato_detalhe_test.dart`)
comparam cada exemplo com sua fixture e travam as chaves exatas de cidade, envelope, item, opções, detalhe e
dos blocos de natureza; no Django, `VitrineAllowlistExataTests` trava o mesmo do lado do servidor. Não há
mais cópia manual do documento para o repositório da API.

---

## 13. Perfis públicos e vitrine do anunciante (Fase 7 / 07.1)

A Fase 7 consome dois perfis públicos e a vitrine de um anunciante (corretor ou empresa). Os perfis (WEB 02)
já estão na `main` da web; a vitrine do anunciante e a correção do perfil de corretor de empresa inativa
vivem na branch `feat/APP07` da web até ela entrar na `main` dela. Este § foi escrito a partir do que o
Django **entrega** (D-05) e substitui o antigo adendo da APP-07 (§12.1 a §12.9 daquela versão), que propunha
`GET /api/publico/imoveis/?corretor=|empresa=`; essa rota não existe. O §12 acima ("Sincronização e antidrift")
não muda.

### 13.1 Perfis públicos (WEB 02)

- `GET /api/publico/corretores/<id>/` — 9 chaves: `id`, `empresa_id`, `foto`, `nome`, `email`, `creci`,
  `telefone`, `whatsapp`, `apresentacao`. Exemplo capturado: `contrato/perfil_corretor.example.json`.
- `GET /api/publico/empresas/<id>/` — 11 chaves: `id`, `tipo`, `razao_social_ou_nome`, `creci`, `telefone`,
  `whatsapp`, `email`, `descricao`, `logomarca`, `cidades_atuacao` (cada cidade `{id, nome, uf}`) e
  `corretores_ativos` (existe no wire; o app não o lê). Exemplo capturado: `contrato/perfil_empresa.example.json`.

Regras que o app assume:

- **404 decidido só pelo status.** O app ignora o corpo `{"detail": ...}`. Corretor inexistente, que não é corretor
  (gestor/admin), desativado **ou de empresa inativa** (D-11, corrigido na web e travado por
  `CorretorPublicoEmpresaInativaTests`) e empresa inexistente ou inativa dão 404. O 404 do corretor vira o
  aviso "Este corretor não está mais disponível".
- **Opcionais vazios** (`blank=True`) chegam `""` (telefone, apresentação, descrição e, por defesa, creci/whatsapp);
  o app os normaliza para ausente na camada de dados. `foto` e `logomarca` chegam como URL absoluta ou `null`;
  só esquema http(s) é aceito.
- **A herança do autônomo é do servidor** (`dados_perfil_publico`): o app mostra o que chegou e não completa nada.
- **404 uniforme**: inexistente e desativado são indistinguíveis, então não há canal novo de enumeração de ids.
- **Correção do §11.5 g:** o `corretor_responsavel` do detalhe do imóvel traz as **mesmas 9 chaves** do perfil
  (não só `id`, `nome` e `foto`). O app lê dele apenas `id`, `nome` e `foto` para a prévia.

### 13.2 Rotas da vitrine do anunciante

- `GET /api/publico/corretores/<id>/imoveis/`
- `GET /api/publico/empresas/<id>/imoveis/`

`AllowAny`, `authentication_classes = []` (token vencido no cabeçalho não derruba a consulta) e
`ThrottleVitrinePublica`, o mesmo balde `vitrine_publica` da vitrine da cidade (429 + `Retry-After`, ver "Erros 429").
O `<id>` é a PK inteira no caminho (`<int:pk>`); não há lista global com `?corretor=` ou `?empresa=`.

### 13.3 Resposta

Envelope `PageNumberPagination` do §4 (`count`, `next`, `previous`, `results`), **20 itens por página**, `next`
absoluto. Cada item é o do §3/§6: as mesmas **13 chaves** do `ImovelVitrineSerializer` (sem cidade, corretor, empresa
nem proprietário). Exemplo capturado: `contrato/vitrine_anunciante.example.json` (cópia byte a byte de
`test/fixtures/api/vitrine_corretor_p1.json`; no seed, o corretor tem 35 imóveis e a empresa 36, ou seja 2 páginas
de cada).

### 13.4 Recorte e ordem

O recorte parte de `imoveis_da_vitrine()` (publicado, disponível, empresa ativa) e filtra por
`corretor_responsavel` (corretor) ou pela `empresa` do imóvel (empresa). Ordem fixa `-criado_em, -id`.
**Só `page` é lido**; qualquer outro parâmetro é ignorado (resposta 200 igual). As funções `imoveis_do_corretor` e
`imoveis_da_empresa` são as mesmas que as páginas do site usam (D-19), então site e API não divergem.

### 13.5 404 e lista vazia

| Situação | Resposta |
|----------|----------|
| corretor inexistente, desativado, usuário que não é corretor, ou corretor de empresa inativa | 404 `{"detail": ...}` |
| empresa inexistente ou inativa | 404 `{"detail": ...}` |
| `?page` fora do intervalo | 404 "Página inválida." |
| anunciante ativo sem imóveis na vitrine | **200** com `results: []` |

O texto do `detail` do 404 difere entre as duas rotas; o app **não** depende dele.

**Muda em relação ao antigo §12.5 da APP-07** ("nunca 404"), escrito para uma rota `?corretor=` que não existe:
agora o anunciante inexistente ou inativo dá 404, exatamente como `cidades/<id>/imoveis/` e os perfis, sem canal
de enumeração (404 uniforme). Só o anunciante **ativo e sem imóveis** dá 200 vazio. A vitrine da empresa continua
listando um imóvel cujo corretor foi desativado (como a vitrine da cidade e o site); a vitrine do corretor
desativado dá 404.

### 13.6 No app

- `VitrineAnuncianteRemoteDataSource` monta o caminho por `caminhoVitrineDoAnunciante`, **não manda query string**
  e só segue `next` quando ele está na mesma origem da base URL (origem estranha é recusada sem requisição).
- 404, 429 e 500 da vitrine viram `Failure`: 'Tentar de novo' na primeira página, rodapé de erro ao carregar mais.
- Ao anexar uma página, id já listado é descartado (integridade da rolagem, não filtro de negócio).
- A vitrine só abre depois de o perfil responder 200.

### 13.7 PENDENTE WEB e decisões (antigo §12.8)

| Item | Destino |
|------|---------|
| **(a)** endpoint da vitrine do anunciante | **ENTREGUE** (web `feat/APP07`, §13.2) |
| **(b)** `cidade` opcional quando há anunciante | **OBSOLETO** (rotas aninhadas, sem `cidade`) |
| **(c)** imóveis de corretor desativado ou empresa inativa | **DECIDIDO** como no §13.5 |
| **(d)** perfil de corretor de empresa inativa | **CORRIGIDO** na web (D-11, `CorretorPublicoEmpresaInativaTests`) |
| **(e)** `slug` do `corretor` do detalhe | **RESOLVIDO** na Fase 5 |
| **(f)** exposição de e-mail, telefone, WhatsApp e CRECI (LGPD) | **CONTINUA PENDENTE**, agora também no `corretor_responsavel` do detalhe; decisão de produto |
| **(g)** views de perfil sem limite de taxa e sem `authentication_classes = []` (D-20) | **PENDENTE WEB**: ficam fora do balde `vitrine_publica`; um token vencido no cabeçalho as derrubaria com 401 |
| **(h)** `semear_vitrine_dev` sem corretor autônomo e sem corretor ativo sem imóveis (D-20) | **PENDENTE WEB** (extensão do seed) |

Limitação de UX registrada, sem correção: o item da lista não traz cidade, então a vitrine de um anunciante que
atua em várias cidades mostra só o bairro.

### 13.8 Sincronização

Capturar só os grupos novos e copiar byte a byte para `contrato/`:

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo perfis
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo anunciante
```

Nunca recapturar os grupos da APP-05 junto (`--grupo todos`): o sufixo aleatório das fotos do seed mudaria as
fixtures já travadas. Travas: no app, `test/data/contrato_perfis_test.dart` e
`test/data/vitrine_anunciante_remote_datasource_test.dart`; no Django, `VitrineDoAnuncianteTests`,
`VitrineAllowlistExataTests` e `CorretorPublicoEmpresaInativaTests`.

---

## 14. Login e acervo do corretor (Fase 8)

A Fase 8 acrescenta as **rotas autenticadas** que o app usa depois do login: quem sou eu, Sair e a lista do acervo
do corretor. Elas vivem na branch `feat/APP08` da web até ela entrar na `main` dela. Este § foi escrito a partir do
que o Django **entrega** (D-05, D-15) e não muda os §1 a §13: as rotas públicas da vitrine continuam sem token.
As respostas de exemplo são capturadas (§14.9), nunca escritas à mão.

### 14.1 Rotas e autenticação

| Rota | Método | Autenticação | Sucesso |
|------|--------|--------------|---------|
| `/api/auth/login/` | `POST` | nenhuma (`authentication_classes = []`) | 200 `{token}` |
| `/api/auth/eu/` | `GET` | `Authorization: Token <chave>` | 200 `{perfil}` |
| `/api/auth/sair/` | `POST` | `Authorization: Token <chave>` | 204 sem corpo |
| `/api/imoveis/` | `GET` | `Authorization: Token <chave>` | 200 envelope do §4 |

- O app manda `Authorization: Token <chave>` **só** em `eu`, `sair` e `GET /api/imoveis/`; nunca nas rotas públicas.
- Sem token, ou com chave inválida ou revogada: **401** `{"detail": ...}` com o cabeçalho `WWW-Authenticate: Token`
  (`TokenAuthentication` é a primeira classe de autenticação). `eu` e `sair` só aceitam token (sem sessão do site nem
  CSRF). `GET /api/imoveis/` mantém o padrão global (token, depois sessão do painel), mas o app só envia token.
- As rotas públicas da vitrine seguem com `authentication_classes = []`: um token velho no aparelho não as derruba.

### 14.2 Login

`POST /api/auth/login/` com corpo JSON `{"email": "...", "password": "..."}`.

- **200** `{"token": "<chave>"}` (exemplo: `contrato/login.example.json`, com o valor trocado por 40 zeros; ver §14.9).
- **400** para credencial inválida ou campo inválido (`{"non_field_errors": [...]}` ou erros por campo). O app
  **ignora o texto** e mostra o dele (D-03); só o status decide. A resposta não revela se o e-mail existe.
- **429** quando o limite de tentativas estoura: cabeçalho `Retry-After` (segundos) e corpo `{"detail": "..."}`. Não há
  fixture (não é capturável de forma determinística): o `Retry-After` é travado no Django e, no app, por resposta sintética.
- `authentication_classes = []`: um `Authorization: Token <revogado>` mandado ao login não vira 401.
- **Limite de tentativas em dois baldes**, conferido antes de checar a senha e contando toda tentativa (certa ou errada,
  e-mail existente ou não): `login_email` (chave pelo **SHA-256 do e-mail normalizado**, sem espaços e em minúsculas, nunca
  em texto) e `login_ip` (IP do cliente, respeitando `NUM_PROXIES`). Taxas por variável de ambiente:
  `LOGIN_TAXA_POR_EMAIL` (padrão `10/hour`) e `LOGIN_TAXA_POR_IP` (padrão `30/hour`), validadas na partida do Django.
  Corpo sem e-mail não tem chave de e-mail (responde o 400 do serializer).

### 14.3 Quem sou eu

`GET /api/auth/eu/` devolve exatamente `{"perfil": "CORRETOR" | "GESTOR" | "ADMINISTRADOR"}` (exemplo:
`contrato/eu.example.json`). De propósito não traz nome, e-mail nem empresa: o app só roteia a tela pelo papel (D-02).
Só vale token; a sessão do site não autentica esta rota (401).

### 14.4 Sair

`POST /api/auth/sair/` apaga a chave do usuário no servidor e responde **204**.

- O token é **único por usuário** (o login faz `get_or_create`): Sair **desconecta** todos os aparelhos do mesmo corretor,
  não só o que chamou. O site, que usa sessão, não é afetado. Um novo login gera chave nova.
- Repetir o Sair com a chave já revogada dá **401**; o app trata esse 401 como sucesso.
- O app **apaga o token local mesmo se a chamada falhar** (rede fora, 5xx): sair nunca fica preso no aparelho.

### 14.5 Lista do acervo

`GET /api/imoveis/` (permissão `EhCorretor`) devolve o acervo da **empresa do corretor logado**, no envelope do §4:
`{count, next, previous, results}`, `page_size = 20` fixo (o cliente não muda o tamanho) e `next`/`previous`
**absolutos**. Só `page` pagina; só a lista usa a paginação (detalhe, criação e edição do painel não mudam).

**Parâmetros** (os mesmos do painel do corretor no site, pela `FiltroImovelForm(campos=["busca", "situacao"])`):

| Parâmetro | Regra |
|-----------|-------|
| `busca` | código OU título, `icontains` |
| `situacao` | igualdade com `DISPONIVEL`, `RESERVADO`, `VENDIDO` ou `ALUGADO` |
| `page` | número da página (20 por página) |

Um valor inválido em **qualquer** campo do formulário (por exemplo `situacao=XYZ`) anula **todos** os filtros,
inclusive a busca: a lista vem sem filtro, nunca erro. `corretor`, `empresa`, `natureza` e os demais filtros do painel não
existem aqui (a URL não escolhe empresa nem corretor). Ordem fixa: `-criado_em, -pk` (o `pk` desempata, senão a página
pode repetir ou pular imóvel).

**Item: exatamente 10 chaves** (exemplo: `contrato/acervo.example.json`, cópia byte a byte de `test/fixtures/api/acervo_p1.json`):

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | |
| `codigo` | string | código do imóvel na empresa |
| `titulo` | string | |
| `finalidade` | string | `VENDA`, `ALUGUEL` ou `VENDA_E_ALUGUEL` |
| `preco_venda` | string decimal ou `null` | |
| `preco_aluguel` | string decimal ou `null` | |
| `foto_capa` | URL absoluta ou `null` | a capa marcada, senão a primeira foto |
| `situacao` | string | `DISPONIVEL`, `RESERVADO`, `VENDIDO` ou `ALUGADO` |
| `meu_imovel` | booleano | o corretor responsável é o usuário logado; calculado no servidor (D-06) |
| `na_vitrine` | booleano | o imóvel aparece na vitrine pública agora; regra única `na_vitrine()` do servidor (D-07) |

**Emenda ao D-13:** `finalidade` entra, além das 9 chaves decididas no D-13, porque o app decide por ela quais linhas
de preço mostrar (`linhasDePreco`), no mesmo formato do cartão público. O app nunca compara ids nem reaplica a regra de
publicação: `meu_imovel` e `na_vitrine` chegam prontos.

**Deny-list (nunca no item):** `proprietario`, `corretor_responsavel`, `empresa`, `descricao`, `fotos`, `endereco`,
`publicado`, `pode_publicar`, `pendencias_para_publicar` e `criado_em`. O serializer é dedicado
(`ImovelAcervoSerializer`, `fields` listados um a um), travado por `AcervoAllowlistExataTests`.

**Isolamento (AC-5):** o filtro por empresa é a primeira camada do queryset (sempre antes de `busca` e `situacao`); o
corretor de uma empresa nunca recebe imóvel de outra, por manipulação de parâmetro. Exemplos no wire: o corretor da
empresa demo recebe só códigos `DEV-*`; o da segunda empresa, só os dela (`test/fixtures/api/acervo_outra_empresa.json`).

### 14.6 Erros

| Situação | Status | Observação |
|----------|--------|------------|
| `login`: credencial ou campo inválido | **400** | texto ignorado pelo app (D-03) |
| `eu`, `sair` ou `GET /api/imoveis/` sem token, ou com chave inválida ou revogada | **401** | `{detail}` + `WWW-Authenticate: Token` |
| `GET /api/imoveis/` por gestor ou administrador | **403** `{detail}` | rota exclusiva do corretor |
| `?page` fora do intervalo | **404** "Página inválida." | padrão do DRF |
| imóvel de **outra empresa** pelo id (`/api/imoveis/<id>/`) | **404** | o queryset já é da empresa (sem canal de enumeração) |
| `login` acima do limite de tentativas | **429** | `Retry-After` em segundos + `{detail}` |

Exemplos capturados: `erro_400_login.json`, `erro_401.json` e `erro_403_acervo.json` em `test/fixtures/api/`.

### 14.7 No app

- **Dio público** (`'publico'`) para login e vitrine; **Dio `'autenticado'`** para `eu`, `sair` e a lista do acervo: o
  `InterceptadorSessao` coloca `Authorization: Token <chave>` **só quando a origem do pedido é a da API configurada**.
- **401 → `SessaoExpiradaException`**: o interceptador rejeita o erro já traduzido e apaga o token guardado (só se ainda for o que o pedido levou, para um 401 atrasado não derrubar o login novo)
  (nenhum `try/catch` acima da camada de dados).
- **`next` só na mesma origem** da base URL configurada (o mesmo teste do §4): o token nunca viaja para outro host.
- **`followRedirects: false`** nos dois Dio: uma credencial nunca segue um redirecionamento.

### 14.8 PENDENTE WEB e riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **Token sem expiração.** A chave vale até o Sair (ou até o administrador apagá-la). | Aceito (D-15): sem refresh nesta fase; o Sair revoga no servidor. |
| **Sair desconecta os outros aparelhos do mesmo corretor** (token único por usuário). | Aceito (D-A). Token por aparelho é ideia **deferida**. |
| **Bloqueio dirigido de e-mail.** Quem erra a senha de um e-mail 10 vezes por hora bloqueia o login legítimo dele por até 1 hora. | Aceito (T-08-19): o balde por e-mail freia força bruta; ajustável por `LOGIN_TAXA_POR_EMAIL`. |
| **IP compartilhado (CGNAT, escritório).** Muitos aparelhos atrás do mesmo IP dividem o balde `login_ip`. | Aceito (T-08-20): ajustável por `LOGIN_TAXA_POR_IP`; atrás de proxy reverso, configurar `NUM_PROXIES`. Item de deploy. |
| **`LocMemCache` por processo.** O contador do login fica na memória de cada worker; com vários workers o limite efetivo multiplica. | Aceito no dev; produção deve usar cache compartilhado. Item de deploy. |
| **Busca sensível a acento** (`icontains` no Postgres). | Aceito, como no §8; `unaccent` é melhoria da frente web. |
| **Formato de `GET /api/imoveis/` mudou de lista para envelope paginado.** | Aceito: sem consumidor conhecido além do app (o painel do site usa as views do Django, não esta rota). |
| **Taxas A1 (`10/hour` por e-mail, `30/hour` por IP)** são estimativa. | **PENDENTE**: confirmar no human-check do 08-12. |

### 14.9 Sincronização

Capturar só o grupo novo e copiar byte a byte para `contrato/`:

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo acervo
```

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `acervo_p1.json` | `acervo.example.json` |
| `eu_corretor.json` | `eu.example.json` |
| `login_200.json` | `login.example.json` |

O grupo faz login pela API, então precisa de credenciais **só por variável de ambiente** (nunca em arquivo):
`CAPTURA_EMAIL_CORRETOR`, `CAPTURA_SENHA_CORRETOR`, `CAPTURA_EMAIL_OUTRA_EMPRESA`, `CAPTURA_SENHA_OUTRA_EMPRESA`,
`CAPTURA_EMAIL_GESTOR` e `CAPTURA_SENHA_GESTOR`. Procedimento: SQLite temporário fora dos dois repositórios (nunca o
banco do `Web/.env`), com `migrate`, `semear_vitrine_dev` **e** `seed_demo` (a segunda empresa, o gestor e o corretor
dela); o corretor da vitrine demo nasce sem senha utilizável, então se gera uma **senha descartável** e se a define no
SQLite temporário lendo `os.environ`. O detalhe está no docstring de `tool/capturar_fixtures_api.py`.

**Redação do token:** o 200 do login é gravado com o valor de `token` trocado por 40 zeros
(`0000000000000000000000000000000000000000`), depois de a ferramenta conferir que a resposta tinha exatamente a chave
`token`. A chave real fica só em memória e é revogada no fim (a captura chama o Sair e confere o 401 seguinte).

**Nunca `--grupo todos`:** ele reescreveria as fixtures da APP-05 e da APP-07 (o sufixo aleatório das fotos do seed
mudaria as fixtures já travadas).

Travas: no app, `test/data/contrato_acervo_test.dart` (chaves exatas do envelope, do item, do `eu` e do login, exemplo =
fixture e isolamento entre empresas); no Django, `AcervoApiTests`, `AcervoAllowlistExataTests`,
`LoginLimiteDeTentativasTests`, `EuApiTests` e `SairApiTests`.

---

## 15. `POST /api/publico/imoveis/<id>/contato/` — contato (W11, APP 06)

O visitante escolhe um canal e o servidor registra o contato e devolve o link pronto para o app abrir.

- **Requisição:** corpo JSON `{"canal": "WHATSAPP" | "TELEFONE" | "EMAIL"}`. **Sem token e sem CSRF** (sem login;
  nenhuma sessão envolvida). POST, e não GET, para que robôs e pré-carregamento não gerem contatos falsos.
- **201** `{"canal": "<canal>", "link": "<link>"}` (`contato_201_whatsapp.json`, `contato_201_telefone.json`,
  `contato_201_email.json`). O servidor monta a mensagem e o link:
  - WhatsApp: `https://wa.me/<número>?text=<mensagem>`; o texto usa **`%20`** para espaços, **nunca `+`** (06-02).
  - Telefone: `tel:+<número>`.
  - E-mail: `mailto:<endereço>?subject=<assunto>&body=<mensagem>`, também com `%20`.
  O app **só abre o link como recebido**: nunca o altera, reconstrói nem reencoda (a codificação é do Django).
- **400** `{"canal": ["<mensagem>"]}` — canal fora da lista ou indisponível para o imóvel
  (`erro_400_canal_contato.json`).
- **404** `{"detail": "No Imovel matches the given query."}` — **idêntico** ao do detalhe (§11.1): id inexistente,
  rascunho, reservado/vendido ou empresa inativa.
- **405** em `GET` (e demais métodos).
- **429** com `Retry-After` e `{detail}` do balde **`contato_publico`** (`CONTATO_TAXA_ANONIMA`, padrão `10/min` por
  IP), **separado** do balde `vitrine_publica`.

**No app (D-13, D-14, D-15):** o app lê `canais_contato` do detalhe (§11.2) e só mostra os canais que o servidor
mandou; ao tocar, faz este POST, e abre o `link` recebido. Qualquer falha (400, 404, 429, rede) é um estado de
erro com "Tentar de novo", sem nova tentativa automática e sem montar link no aparelho.

---

## 16. Caixa de contatos do corretor (Fase 10)

A Fase 10 acrescenta a **caixa de contatos**: a lista dos contatos que o corretor recebeu pelo botão de contato da página
do imóvel (§15), a contagem dos que ainda não tiveram retorno, as opções do filtro de imóvel e o PATCH que anota o
retorno. Estas rotas vivem na branch `feat/APP10` da web até ela entrar na `main` dela. Este § foi escrito a partir do
que o Django **entrega** (D-26) e não muda os §1 a §15. As respostas de exemplo são capturadas (§16.10), nunca escritas à
mão.

### 16.1 Rotas e autenticação

Todas as rotas exigem `Authorization: Token <chave>` e a permissão `PertenceAUmaEmpresa`.

| Rota | Método | Sucesso |
|------|--------|---------|
| `/api/contatos/` | `GET` | 200 envelope do §4 (`page_size = 20`, `next`/`previous` absolutos) |
| `/api/contatos/resumo/` | `GET` | 200 `{"sem_retorno": N}` |
| `/api/contatos/imoveis/` | `GET` | 200 lista de opções (sem envelope, sem paginação) |
| `/api/contatos/<id>/` | `PATCH` | 200 item completo (12 chaves) |

- `GET /api/contatos/<id>/` também existe, mas o app **não** o usa. `PUT`, `POST` e `DELETE` respondem **405**
  (`{"detail": "Método \"PUT\" não é permitido."}`).
- Sem token, ou com chave inválida ou revogada: **401** `{"detail": ...}` com o cabeçalho `WWW-Authenticate: Token`.
- **Administrador** (não pertence a nenhuma empresa): **403**
  `{"detail": "Este recurso é restrito a usuários vinculados a uma empresa."}`.
- **Gestor** passa e vê todos os contatos da empresa, mas o app **não oferece a entrada** da caixa a ele (D-03): a
  caixa abre por um ícone na `AppBar` do "Meu acervo", que só o corretor tem.
- **Barra final obrigatória** (`/api/contatos/<id>/`): sem ela o `APPEND_SLASH` não redireciona um `PATCH`, e o `Dio`
  autenticado tem `followRedirects: false`.

### 16.2 Lista

`GET /api/contatos/` devolve os contatos visíveis ao usuário logado no envelope do §4: `{count, next, previous,
results}`, **`page_size = 20`** fixo (o cliente não escolhe o tamanho) e `next`/`previous` **absolutos**, com os filtros
já embutidos.

**Parâmetros:**

| Parâmetro | Regra |
|-----------|-------|
| `imovel` | id inteiro do imóvel; valor não numérico → 400 |
| `de` | `AAAA-MM-DD`, **inclusiva**, dia de São Paulo (§16.7) |
| `ate` | `AAAA-MM-DD`, **inclusiva**, dia de São Paulo; `de` depois de `ate` → 400 |
| `page` | número da página (20 por página) |

Os filtros se combinam e é o servidor quem os resolve. **Ordem fixa:** `-criado_em, -id` (o `id` desempata, senão a
página pode repetir ou pular contato).

**Item: exatamente 12 chaves** (`ContatoSerializer`; exemplo: `contrato/contatos.example.json`, cópia byte a byte de
`test/fixtures/api/contatos_p1.json`):

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | |
| `imovel` | inteiro | id do imóvel (o app não usa) |
| `imovel_codigo` | string | código interno do imóvel na empresa (não é público na vitrine) |
| `imovel_titulo` | string | |
| `corretor` | inteiro ou `null` | `null` quando o corretor foi desativado e o contato foi para a empresa (só o gestor vê esses) |
| `corretor_nome` | string ou `null` | o app não mostra (coluna só do gestor, D-09) |
| `canal` | string | `WHATSAPP`, `TELEFONE` ou `EMAIL` |
| `canal_exibicao` | string | `WhatsApp`, `Telefone`, `E-mail` (o app usa texto próprio) |
| `criado_em` | ISO-8601 com offset `-03:00` | |
| `retorno` | string | `PENDENTE`, `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA` ou `DESCARTADO` |
| `retorno_exibicao` | string | o app usa texto próprio (D-10) |
| `retorno_em` | ISO-8601 ou `null` | instante da última anotação; `null` enquanto `PENDENTE` |

**Nenhum dado do visitante** existe na tabela de contatos: sem nome, telefone, e-mail nem texto livre.

**Erros da lista:**

- **400** com `{"<campo>": "<mensagem>"}` (o valor é uma **string**, não uma lista), por exemplo
  `{"de": "A data inicial não pode ser depois da final."}`, `{"imovel": "Informe o id do imóvel."}` ou
  `{"de": "Informe a data no formato AAAA-MM-DD."}`. O app ignora o texto.
- `?page` fora do intervalo → **404** `{"detail": "Página inválida."}`.

**Mudança de formato:** antes da Fase 10 a lista de contatos era um array simples; agora é o envelope paginado. Não há
outro consumidor conhecido além do app.

### 16.3 Anotar o retorno

`PATCH /api/contatos/<id>/` com `Content-Type: application/json` e corpo `{"retorno": "<valor>"}`. Valores aceitos
(`RETORNOS_ANOTAVEIS`): `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA`, `DESCARTADO`. `PENDENTE` **não** é anotável: o
contato nasce `PENDENTE` e o app não o devolve a esse estado.

| Caso | Status | Corpo |
|------|--------|-------|
| Sucesso | **200** | o item completo, com as 12 chaves do §16.2 e `retorno_em` preenchido (`contrato/contato_patch.example.json`, cópia byte a byte de `contato_patch_200.json`) |
| `retorno` = `PENDENTE`, valor inválido ou `""` | **400** | `{"retorno": ["\"PENDENTE\" não é uma escolha válida."]}` (`erro_400_retorno.json`) |
| corpo sem `retorno` (por exemplo `{}`) | **400** | `{"retorno": ["Este campo é obrigatório."]}` |
| contato de **outro corretor** da mesma empresa | **404** | `{"detail": "No Contato matches the given query."}` (`erro_404_contato.json`) |
| contato de **outra empresa** | **404** | idêntico ao anterior (sem canal de enumeração) |
| administrador | **403** | `{"detail": "Este recurso é restrito a usuários vinculados a uma empresa."}` |
| sem token ou chave inválida | **401** | `{"detail": ...}` + `WWW-Authenticate: Token` |
| `PUT`, `POST`, `DELETE` | **405** | `{"detail": "Método ... não é permitido."}` |

- **Emenda pós-pesquisa ao D-25:** o corpo sem `retorno` respondia **500** (`KeyError`) no servidor; o `validate()` do
  serializer agora o transforma em **400**.
- Campos extras no corpo (`canal`, `imovel`, `id`...) são **ignorados**: só o `retorno` muda.
- **Cada anotação grava um `retorno_em` novo** e a troca de retorno é aceita (de `FALEI` para `SEM_RESPOSTA`, por
  exemplo) — D-15. O app espera o servidor responder antes de mostrar o novo valor (D-16) e só olha o **status** e o
  item do 200, nunca o texto do erro (D-17).

### 16.4 Contagem

`GET /api/contatos/resumo/` devolve exatamente `{"sem_retorno": <inteiro ≥ 0>}` (exemplo:
`contrato/contatos_resumo.example.json`). É sempre o total de contatos **visíveis ao usuário com `retorno = PENDENTE`**;
**ignora** `imovel`, `de`, `ate` e `page` (D-05): a contagem não muda quando o corretor filtra a lista. O app só mostra o
número que o servidor mandou, nunca soma nem subtrai; depois de uma anotação ele pede a contagem de novo (na captura,
25 antes e 24 depois, `contatos_resumo.json` e `contatos_resumo_apos.json`).

### 16.5 Opções do filtro de imóvel

`GET /api/contatos/imoveis/` devolve uma **lista** (sem envelope e sem paginação) de objetos com exatamente 3 chaves:
`{"id": <inteiro>, "codigo": "<string>", "titulo": "<string>"}` (exemplo: `contrato/contatos_imoveis.example.json`).
Só entram os imóveis que aparecem em contatos **visíveis ao usuário** (a mesma regra de `ContatoListView`, nada de
imóvel de outra empresa nem de outro corretor), ordenados por `codigo`.

### 16.6 Isolamento (D-13)

O filtro por **empresa** é a primeira camada (`EmpresaScopedQuerySetMixin`/`contatos_visiveis_para`); depois vem o
**perfil**: corretor só vê os contatos dele, gestor vê todos os da empresa, administrador não vê nada (403). Isso vale
para a lista (com e sem filtros), para a contagem, para as opções do filtro e para o PATCH (404 pelo id de outro corretor
ou de outra empresa).

**Evidência no wire:** a captura dá **1 contato à empresa B** (`contatos_outra_empresa.json`, `count` 1, canal
`TELEFONE`) e **25** à empresa A (`contatos_p1.json` + `contatos_p2.json`). O teste do app exige que a caixa da B **não
seja vazia** (senão a prova seria vazia), que nenhum id dela apareça na caixa da A, que o imóvel dela não apareça nas
opções da A e que a contagem da A seja só a dela. A captura também confere o PATCH cruzado: **404 nos dois sentidos**. A
cobertura completa por perfil (corretor × corretor, gestor, administrador) fica nas classes do Django (§16.10).

### 16.7 Fuso

O servidor usa `TIME_ZONE = 'America/Sao_Paulo'` com `USE_TZ = True`.

- `criado_em` e `retorno_em` saem em ISO-8601 **com offset de São Paulo** (`-03:00`), por exemplo
  `2026-11-23T19:43:37.310766-03:00`; `retorno_em` ainda sem anotação é `null`.
- `de` e `ate` são **dias de São Paulo**: o recorte usa `criado_em__date`, que com `USE_TZ = True` interpreta o dia em
  `America/Sao_Paulo`. O app manda a data escolhida no seletor, formatada do `DateTime` local, sem `toUtc()`.
- O app mostra a hora **do aparelho** (`toLocal()`). Num aparelho no fuso de Brasília ela bate com a do site; em outro
  fuso a hora mostrada difere do site em 1 ou 2 horas, e o dia escolhido no seletor continua valendo como dia de São
  Paulo. Risco aceito (A3).

### 16.8 No app

- **`Dio` `@Named('autenticado')` em todas as rotas** da caixa (lista, contagem, opções e PATCH): o `InterceptadorSessao`
  coloca `Authorization: Token <chave>` só quando a origem do pedido é a da API configurada.
- **401 → sessão terminada** (`SessaoExpiradaException`, como no §14.7): o app abre o login com o aviso "Sua sessão
  terminou. Entre de novo.".
- **`next` só na mesma origem** da base URL configurada (o mesmo teste do §4): o token nunca viaja para outro host.
  **`followRedirects: false`**.
- **Textos e rótulos fixos do app:** os campos `canal_exibicao` e `retorno_exibicao` **não** são usados (D-10); o mesmo
  vale para a mensagem de erro do servidor (D-17).
- **Canal ou retorno desconhecido** (valor fora das listas do §16.2) vira **falha de formato** da página: o app não
  adivinha o que o servidor mandou.
- As falhas do PATCH (rede, timeout, 5xx, 400 e 404) viram um aviso com texto fixo do app e o item fica como estava
  (D-17); no 404 a lista e a contagem são recarregadas; o app não repete a anotação sozinho.

### 16.9 PENDENTE WEB e riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **A lista deixou de ser array e virou envelope paginado.** | Aceito: sem outro consumidor conhecido além do app. |
| **`/api/contatos/imoveis/` sem paginação**: o limite é o tamanho do acervo do corretor. | Aceito agora; a **APP-12 deve revisitar** (acervo grande). |
| **Hora local do aparelho ≠ hora do site fora do fuso de Brasília** (§16.7). | Aceito (A3); o dia do filtro continua sendo o de São Paulo. |
| **Enum novo no servidor** (canal ou retorno novo) **quebra a página no app antigo** (falha de formato). | Aceito: o app não inventa rótulo; atualizar o app junto com o servidor. |
| **O POST público de contato (§15) não tem limite de taxa** na `main@8bf4448`; `CONTATO_TAXA_ANONIMA` não existe no `settings.py` da `feat/APP10`. | **PENDENTE WEB**: o §15 descreve o balde `contato_publico`, mas ele não existe nesta base; a captura roda sem ele. |

### 16.10 Sincronização

Capturar só o grupo novo e copiar byte a byte para `contrato/`:

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo contatos
```

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `contatos_p1.json` | `contatos.example.json` |
| `contatos_resumo.json` | `contatos_resumo.example.json` |
| `contatos_imoveis.json` | `contatos_imoveis.example.json` |
| `contato_patch_200.json` | `contato_patch.example.json` |

As demais fixtures do grupo (`contatos_p2`, `contatos_imovel`, `contatos_periodo_vazio`, `contatos_outra_empresa`,
`contatos_resumo_apos`, `erro_400_retorno`, `erro_404_contato`) não têm exemplo no contrato, mas o teste do app confere as
chaves e os valores delas.

O grupo faz login pela API, então as credenciais vêm **só por variável de ambiente** (nunca em arquivo):
`CAPTURA_EMAIL_CORRETOR`, `CAPTURA_SENHA_CORRETOR`, `CAPTURA_EMAIL_OUTRA_EMPRESA` e `CAPTURA_SENHA_OUTRA_EMPRESA`.
Procedimento: SQLite temporário fora dos dois repositórios (nunca o banco do `Web/.env`), com `migrate`,
`semear_vitrine_dev` **e** `seed_demo`; o imóvel da segunda empresa está fora da vitrine, então o **1 contato da empresa
B** é criado pelo ORM nesse SQLite temporário; a senha do corretor demo é uma **senha descartável**, definida lendo
`os.environ`. O detalhe está no docstring de `tool/capturar_fixtures_api.py`.

**Nunca `--grupo todos`:** ele reescreveria as fixtures das fases anteriores (o sufixo aleatório das fotos do seed
mudaria as fixtures já travadas).

Travas: no app, `test/data/contrato_contatos_test.dart` (chaves exatas do envelope, do item, do resumo e das opções,
exemplo = fixture e isolamento entre empresas no wire); no Django, `PaginacaoDaCaixaTests`, `ResumoSemRetornoTests`,
`OpcoesDeImovelDaCaixaTests`, `IsolamentoTests` e `AnotarRetornoTests`.
