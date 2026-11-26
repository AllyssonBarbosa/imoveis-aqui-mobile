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

**Situação e histórico do imóvel (Fase 9):** as rotas autenticadas `GET /api/imoveis/<id>/`,
`POST /api/imoveis/<id>/situacao/` e `GET /api/imoveis/<id>/historico/` (WEB 08) vêm da `main` da web (lidas em
`origin/main` `8bf4448`). Ver §16; os exemplos `imovel_gestao` e `historico_situacao` são travados por
`test/data/contrato_gestao_situacao_test.dart`.

**Caixa de contatos do corretor (Fase 10):** a lista paginada, a contagem dos sem retorno, as opções do filtro de imóvel e o PATCH do retorno vêm da branch `feat/APP10` da web, até ela entrar na `main` dela. Ver §17; os exemplos `contatos`, `contatos_resumo`, `contatos_imoveis` e `contato_patch` são travados por `test/data/contrato_contatos_test.dart`.

**Área do gestor (Fase 12):** os totais por situação e os contatos por corretor vêm da `main` da web (W12); o acervo por corretor e as mudanças de situação recentes vêm da branch `feat/APP12` da web, até ela entrar na `main` dela. Ver §18; os exemplos `relatorio_acervo`, `relatorio_acervo_por_corretor`, `relatorio_contatos` e `relatorio_mudancas` são travados por `test/data/contrato_area_gestor_test.dart`.

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

## 16. Situação e histórico do imóvel (Fase 9)

A Fase 9 acrescenta as **rotas autenticadas por imóvel** que o app usa para o corretor mudar a situação do seu imóvel:
o detalhe de gestão, o POST da mudança e o histórico. Elas foram entregues pela WEB 08 e estão na `origin/main` da web
(lidas em `8bf4448`). Este § foi escrito a partir do que o Django **entrega** (D-13) e não muda os §1 a §15. As
respostas de exemplo são capturadas (§16.7), nunca escritas à mão.

### 16.1 Rotas e autenticação

| Rota | Método | Autenticação | Sucesso |
|------|--------|--------------|---------|
| `/api/imoveis/<id>/` | `GET` | `Authorization: Token <chave>` | 200 `ImovelSerializer` (§16.2) |
| `/api/imoveis/<id>/situacao/` | `POST` | idem | 200 `ImovelSerializer` (§16.3) |
| `/api/imoveis/<id>/historico/` | `GET` | idem | 200 lista (§16.4) |

- **A barra final é obrigatória nas três rotas.** O Dio `'autenticado'` tem `followRedirects: false` (§14.7): um POST sem `/`
  final tomaria 301 do `APPEND_SLASH` e falharia, em vez de chegar à view.
- `Authorization: Token <chave>` como no §14.1, só na mesma origem da API. Permissão `EhCorretor`; o queryset é sempre o
  da **empresa** do corretor logado (o id da URL é entrada não confiável).
- **Ordem das decisões do servidor num POST de situação:** 401 (sem token válido) → 403 (não é corretor) → 404 (imóvel
  de outra empresa **ou** inexistente, mesmo corpo) → 403 (não é o responsável: `pode_mudar_situacao` falso) → 400 de
  validação do corpo → 400 de regra (`mudar_situacao`: mesma situação, contrato assinado) → 200. Por isso um colega com
  corpo inválido recebe 403, não 400.

### 16.2 `GET /api/imoveis/<id>/`

Devolve o `ImovelSerializer` completo (26 chaves; o mesmo do painel do corretor). **O app lê só 9:** `id`, `codigo`,
`titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `situacao`, `situacao_desde` e `pode_mudar_situacao`. As outras
17 chaves são ignoradas e **não** são declaradas no Model do app (menos superfície, menos dado sensível em memória; por
isso a trava do app é um subconjunto, não uma allowlist exata). Exemplo: `contrato/imovel_gestao.example.json`, cópia
byte a byte de `test/fixtures/api/imovel_gestao_disponivel.json`.

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | o mesmo `id` do cartão do acervo |
| `codigo`, `titulo` | string | |
| `finalidade` | string | `VENDA`, `ALUGUEL` ou `VENDA_E_ALUGUEL` |
| `preco_venda`, `preco_aluguel` | string decimal ou `null` | o app formata e nunca calcula |
| `situacao` | string | `DISPONIVEL`, `RESERVADO`, `VENDIDO` ou `ALUGADO` |
| `situacao_desde` | ISO 8601 | **com offset** (`-03:00`) e microssegundos; a data é do servidor (D-05) |
| `pode_mudar_situacao` | booleano | calculado pelo Django (`Imovel.pode_mudar_situacao`): corretor responsável do imóvel, ou gestor da mesma empresa; o app não reaplica a regra |

- `na_vitrine` **não** está nesta rota: vem da lista do §14.5. A foto de capa da tela também vem do cartão do acervo
  (já calculada pelo servidor na lista), não do `fotos` deste detalhe.
- Imóvel de **outra empresa** pelo id: **404** `{"detail": "No Imovel matches the given query."}`
  (`erro_404_imovel.json`), indistinguível de um id que não existe.
- Um colega da mesma empresa lê o detalhe (200) com `pode_mudar_situacao: false` (`imovel_gestao_sem_permissao.json`).

### 16.3 `POST /api/imoveis/<id>/situacao/`

Corpo JSON `{"situacao": "RESERVADO", "observacao": "Reservado na conversa com o cliente."}`.

- `situacao`: só os 4 códigos (`DISPONIVEL`, `RESERVADO`, `VENDIDO`, `ALUGADO`), em maiúsculas.
- `observacao`: **opcional**. O app a **omite** quando vazia e nunca manda `null` (o servidor recusa `null`). Espaços nas
  pontas são cortados pelo DRF (`trim`).
- O **200** devolve o `ImovelSerializer` (`situacao_200.json`), mas o app **não o usa como estado novo**: ele relê o
  detalhe e o histórico (D-10), para mostrar sempre o que o servidor guardou.

| Caso | Status | Corpo real |
|------|--------|-----------|
| Sucesso | 200 | `ImovelSerializer` com a `situacao` nova e `situacao_desde` novo (`situacao_200.json`) |
| Mesma situação | 400 | `{"situacao": ["O imóvel já está reservado."]}` (`erro_400_mesma_situacao.json`) |
| Contrato assinado | 400 | `{"situacao": ["Este imóvel tem um contrato assinado (#1): a situação não pode ser mudada à mão enquanto o contrato estiver valendo."]}` (`erro_400_contrato_assinado.json`) |
| `situacao` fora da lista (ou minúscula) | 400 | `{"situacao": ["\"DEMOLIDO\" não é uma escolha válida."]}` |
| `situacao` ausente | 400 | `{"situacao": ["Este campo é obrigatório."]}` |
| `observacao: null` | 400 | `{"observacao": ["Este campo pode não ser nulo."]}` (chave `observacao`, não `situacao`) |
| Corpo que não é objeto | 400 | `{"non_field_errors": ["Dado inválido. Esperava um dicionário, mas recebeu list."]}` |
| Sem token, ou token revogado | 401 | `{"detail": "As credenciais de autenticação não foram fornecidas."}` + `WWW-Authenticate: Token` (`erro_401.json`) |
| Não é o responsável (colega da mesma empresa) | 403 | `{"detail": "Só o corretor responsável por este imóvel ou o gestor podem mudar a situação."}` (`erro_403_situacao.json`) |
| Gestor ou administrador nesta rota | 403 | `{"detail": "Este recurso é restrito ao corretor."}` |
| Imóvel de outra empresa ou inexistente | 404 | `{"detail": "No Imovel matches the given query."}` — **em inglês** |
| `GET` na rota | 405 | |

O servidor **não limita** o tamanho da `observacao` (100 000 caracteres foram aceitos em sonda): ver §16.6.

### 16.4 `GET /api/imoveis/<id>/historico/`

Devolve uma **lista simples**, **sem envelope e sem paginação** (`[]` quando nunca houve mudança:
`historico_vazio.json`). Cada item tem exatamente **6 chaves** (exemplo: `contrato/historico_situacao.example.json`,
cópia byte a byte de `test/fixtures/api/historico_um_item.json`):

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | |
| `situacao_anterior`, `situacao_nova` | string | um dos 4 códigos |
| `alterado_por` | string | o **nome** de quem mudou, não o id |
| `alterado_em` | ISO 8601 | com offset; gravado pelo servidor (D-05) |
| `observacao` | string | pode ser `""` |

- **Ordem do servidor:** `-alterado_em, -id` (mais recente primeiro; o `id` desempata). O app mostra na ordem recebida.
- Uma mudança feita pela **assinatura de contrato** aparece no histórico com observação automática (por exemplo,
  `Contrato #1 de venda assinado em 01/07/2026.`, `historico_contrato.json`): o app só mostra o texto.
- O **colega da mesma empresa lê** o histórico (200), como lê o detalhe.
- O corretor de **outra empresa** recebe o **mesmo 404** do detalhe: `{"detail": "No Imovel matches the given query."}`
  (`erro_404_historico.json`, igual a `erro_404_imovel.json`), pelo mesmo `get_object` do `ImovelViewSet` — sem canal de
  enumeração entre empresas (T-09-02).

### 16.5 No app

- **400 e 403 → recusa com a mensagem do servidor**, **achatada**: `detail` e todas as listas de texto de **qualquer**
  chave do corpo (não só `situacao`: o `null` de `observacao` e o `non_field_errors` vêm em outras chaves), juntando as
  mensagens, com `trim` e corte de **300 caracteres**; se o resultado ficar vazio, vira falha de conexão.
- **404 → texto fixo em português**; o `detail` **em inglês** do servidor nunca é exibido.
- **401 → `SessaoExpiradaException`** (§14.7); o interceptador do Dio `'autenticado'` já traduz e apaga o token.
- **Rede, timeout, 5xx ou JSON ruim → falha de conexão**, sem nova tentativa automática.
- **Datas:** `DateTime.parse` devolve UTC; a tela mostra `situacao_desde` e `alterado_em` no **fuso do aparelho**
  (`.toLocal()`) com `DateFormat('dd/MM/yyyy HH:mm')` **sem locale** (`DateFormat(..., 'pt_BR')` lança
  `LocaleDataException` sem `initializeDateFormatting`).
- O app **nunca** decide quem pode mudar nem deduz a `na_vitrine`: tudo chega pronto do servidor.

### 16.6 PENDENTE WEB e riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **Observação sem `max_length` no serializer.** O servidor aceita textos enormes. | O app limita a **500 caracteres** no campo, com contador (**D-17**: decisão do usuário, aprovada em 2026-11-22, exceção à D-06 que mandava não criar regra própria). O limite no servidor (hardening **L8**, `max_length` no `MudancaSituacaoSerializer`) **depende da equipe web**. |
| **POST com tempo esgotado é ambíguo.** O servidor pode ter gravado mesmo com o app tendo desistido. | Sem retry automático. O reenvio recebe 400 `O imóvel já está …`, que explica; puxar para atualizar corrige a tela. |
| **Rotas do gestor** `/api/gestao/imoveis/<id>/...`. | **Fora do app** até a APP-12; nesta rota o gestor toma 403. |
| **404 em inglês** (`No Imovel matches the given query.`). | Aceito: o app mostra texto fixo em português e não depende do texto. |
| **`na_vitrine` fica velho depois da mudança** (não vem no detalhe). | O app deixa de oferecer o dado que sabe estar velho até a tela ser reaberta pelo acervo recarregado. |

### 16.7 Sincronização

Capturar só o grupo novo e copiar byte a byte para `contrato/`:

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo situacao
```

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `imovel_gestao_disponivel.json` | `imovel_gestao.example.json` |
| `historico_um_item.json` | `historico_situacao.example.json` |

O grupo faz login pela API, então precisa de credenciais **só por variável de ambiente** (nunca em arquivo):
`CAPTURA_EMAIL_CORRETOR`, `CAPTURA_SENHA_CORRETOR`, `CAPTURA_EMAIL_OUTRA_EMPRESA` e `CAPTURA_SENHA_OUTRA_EMPRESA`.
Ele **lê** as fixtures do acervo (`acervo_p1`, `acervo_busca`, `acervo_outra_empresa`) e confere ao vivo que os ids
batem. Procedimento: SQLite temporário dentro de uma pasta de `mktemp -d` (nunca o banco do `Web/.env`), com `migrate`,
`semear_vitrine_dev` **e** `seed_demo`, **nessa ordem**; o código do Django é o da `origin/main`, extraído com
`git archive origin/main Web | tar -x -C <pasta temporária>` — o clone da web **pode estar em qualquer branch**, nada é
lido da árvore dele nem escrito nele (D-19). **O POST grava no banco** (reserva o imóvel alvo): só roda no SQLite
temporário. **Nunca `--grupo todos`:** reescreveria as fixtures das fases anteriores.

Travas: no app, `test/data/contrato_gestao_situacao_test.dart` (as 9 chaves lidas, as 6 do histórico, a forma dos
erros, os dois 404 iguais, exemplo = fixture e os ids casados com o acervo); no Django, `CorretorMudaSituacaoTests`,
`AppSituacaoApiTests` e `TravaDaSituacaoManualTests.test_api_do_corretor_recusa_com_contrato_assinado`, na `feat/APP09`
do worktree `../imoveis-aqui-APP09` (09-02, D-19).

---

## 17. Caixa de contatos do corretor (Fase 10)

> Nos documentos da Fase 10 (planos, SUMMARYs, VERIFICATION) esta seção aparece como **§16**; virou **§17** ao juntar a `main` com a Fase 9, que ficou com o §16.

A Fase 10 acrescenta a **caixa de contatos**: a lista dos contatos que o corretor recebeu pelo botão de contato da página
do imóvel (§15), a contagem dos que ainda não tiveram retorno, as opções do filtro de imóvel e o PATCH que anota o
retorno. Estas rotas vivem na branch `feat/APP10` da web até ela entrar na `main` dela. Este § foi escrito a partir do
que o Django **entrega** (D-26) e não muda os §1 a §15. As respostas de exemplo são capturadas (§17.10), nunca escritas à
mão.

### 17.1 Rotas e autenticação

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

### 17.2 Lista

`GET /api/contatos/` devolve os contatos visíveis ao usuário logado no envelope do §4: `{count, next, previous,
results}`, **`page_size = 20`** fixo (o cliente não escolhe o tamanho) e `next`/`previous` **absolutos**, com os filtros
já embutidos.

**Parâmetros:**

| Parâmetro | Regra |
|-----------|-------|
| `imovel` | id inteiro do imóvel; valor não numérico → 400 |
| `de` | `AAAA-MM-DD`, **inclusiva**, dia de São Paulo (§17.7) |
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

### 17.3 Anotar o retorno

`PATCH /api/contatos/<id>/` com `Content-Type: application/json` e corpo `{"retorno": "<valor>"}`. Valores aceitos
(`RETORNOS_ANOTAVEIS`): `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA`, `DESCARTADO`. `PENDENTE` **não** é anotável: o
contato nasce `PENDENTE` e o app não o devolve a esse estado.

| Caso | Status | Corpo |
|------|--------|-------|
| Sucesso | **200** | o item completo, com as 12 chaves do §17.2 e `retorno_em` preenchido (`contrato/contato_patch.example.json`, cópia byte a byte de `contato_patch_200.json`) |
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

### 17.4 Contagem

`GET /api/contatos/resumo/` devolve exatamente `{"sem_retorno": <inteiro ≥ 0>}` (exemplo:
`contrato/contatos_resumo.example.json`). É sempre o total de contatos **visíveis ao usuário com `retorno = PENDENTE`**;
**ignora** `imovel`, `de`, `ate` e `page` (D-05): a contagem não muda quando o corretor filtra a lista. O app só mostra o
número que o servidor mandou, nunca soma nem subtrai; depois de uma anotação ele pede a contagem de novo (na captura,
25 antes e 24 depois, `contatos_resumo.json` e `contatos_resumo_apos.json`).

### 17.5 Opções do filtro de imóvel

`GET /api/contatos/imoveis/` devolve uma **lista** (sem envelope e sem paginação) de objetos com exatamente 3 chaves:
`{"id": <inteiro>, "codigo": "<string>", "titulo": "<string>"}` (exemplo: `contrato/contatos_imoveis.example.json`).
Só entram os imóveis que aparecem em contatos **visíveis ao usuário** (a mesma regra de `ContatoListView`, nada de
imóvel de outra empresa nem de outro corretor), ordenados por `codigo`.

### 17.6 Isolamento (D-13)

O filtro por **empresa** é a primeira camada (`EmpresaScopedQuerySetMixin`/`contatos_visiveis_para`); depois vem o
**perfil**: corretor só vê os contatos dele, gestor vê todos os da empresa, administrador não vê nada (403). Isso vale
para a lista (com e sem filtros), para a contagem, para as opções do filtro e para o PATCH (404 pelo id de outro corretor
ou de outra empresa).

**Evidência no wire:** a captura dá **1 contato à empresa B** (`contatos_outra_empresa.json`, `count` 1, canal
`TELEFONE`) e **25** à empresa A (`contatos_p1.json` + `contatos_p2.json`). O teste do app exige que a caixa da B **não
seja vazia** (senão a prova seria vazia), que nenhum id dela apareça na caixa da A, que o imóvel dela não apareça nas
opções da A e que a contagem da A seja só a dela. A captura também confere o PATCH cruzado: **404 nos dois sentidos**. A
cobertura completa por perfil (corretor × corretor, gestor, administrador) fica nas classes do Django (§17.10).

### 17.7 Fuso

O servidor usa `TIME_ZONE = 'America/Sao_Paulo'` com `USE_TZ = True`.

- `criado_em` e `retorno_em` saem em ISO-8601 **com offset de São Paulo** (`-03:00`), por exemplo
  `2026-11-23T19:43:37.310766-03:00`; `retorno_em` ainda sem anotação é `null`.
- `de` e `ate` são **dias de São Paulo**: o recorte usa `criado_em__date`, que com `USE_TZ = True` interpreta o dia em
  `America/Sao_Paulo`. O app manda a data escolhida no seletor, formatada do `DateTime` local, sem `toUtc()`.
- O app mostra a hora **do aparelho** (`toLocal()`). Num aparelho no fuso de Brasília ela bate com a do site; em outro
  fuso a hora mostrada difere do site em 1 ou 2 horas, e o dia escolhido no seletor continua valendo como dia de São
  Paulo. Risco aceito (A3).

### 17.8 No app

- **`Dio` `@Named('autenticado')` em todas as rotas** da caixa (lista, contagem, opções e PATCH): o `InterceptadorSessao`
  coloca `Authorization: Token <chave>` só quando a origem do pedido é a da API configurada.
- **401 → sessão terminada** (`SessaoExpiradaException`, como no §14.7): o app abre o login com o aviso "Sua sessão
  terminou. Entre de novo.".
- **`next` só na mesma origem** da base URL configurada (o mesmo teste do §4): o token nunca viaja para outro host.
  **`followRedirects: false`**.
- **Textos e rótulos fixos do app:** os campos `canal_exibicao` e `retorno_exibicao` **não** são usados (D-10); o mesmo
  vale para a mensagem de erro do servidor (D-17).
- **Canal ou retorno desconhecido** (valor fora das listas do §17.2) vira **falha de formato** da página: o app não
  adivinha o que o servidor mandou.
- As falhas do PATCH (rede, timeout, 5xx, 400 e 404) viram um aviso com texto fixo do app e o item fica como estava
  (D-17); no 404 a lista e a contagem são recarregadas; o app não repete a anotação sozinho.

### 17.9 PENDENTE WEB e riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **A lista deixou de ser array e virou envelope paginado.** | Aceito: sem outro consumidor conhecido além do app. |
| **`/api/contatos/imoveis/` sem paginação**: o limite é o tamanho do acervo do corretor. | Aceito agora; a **APP-12 deve revisitar** (acervo grande). |
| **Hora local do aparelho ≠ hora do site fora do fuso de Brasília** (§17.7). | Aceito (A3); o dia do filtro continua sendo o de São Paulo. |
| **Enum novo no servidor** (canal ou retorno novo) **quebra a página no app antigo** (falha de formato). | Aceito: o app não inventa rótulo; atualizar o app junto com o servidor. |
| **O POST público de contato (§15) não tem limite de taxa** na `main@8bf4448`; `CONTATO_TAXA_ANONIMA` não existe no `settings.py` da `feat/APP10`. | **PENDENTE WEB**: o §15 descreve o balde `contato_publico`, mas ele não existe nesta base; a captura roda sem ele. |

### 17.10 Sincronização

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

---

## 18. Área do gestor (Fase 12)

A Fase 12 acrescenta a **Área do gestor**: quatro relatórios da empresa do gestor logado — totais por situação, acervo por
corretor, contatos por corretor e período, e mudanças de situação recentes. Duas das rotas (totais e contatos) já existem
na `main` da web (W12); as outras duas (acervo por corretor e mudanças de situação) vivem na branch `feat/APP12` da web
até ela entrar na `main` dela. Este § foi escrito a partir do que o Django **entrega** (D-27) e não muda os §1 a §17. As
respostas de exemplo são capturadas (§18.10), nunca escritas à mão.

> Se o card APP 11 (do colega) chegar antes com um §18 próprio, este § vira o seguinte no merge, como aconteceu com o §16
> e o §17 (D-27). Nos documentos da Fase 12 ele aparece como §18.

### 18.1 Rotas e autenticação

Todas as rotas são `GET`, exigem `Authorization: Token <chave>` e a permissão `EhGestor` (só o perfil gestor, com empresa).

| Rota | O que devolve | Seção |
|------|---------------|-------|
| `/api/relatorios/acervo/` | totais por situação e por natureza (W12) | §18.2 |
| `/api/relatorios/acervo-por-corretor/` | quantos imóveis cada corretor tem (`feat/APP12`) | §18.3 |
| `/api/relatorios/contatos/` | contatos por corretor e por período (W12) | §18.4 |
| `/api/relatorios/mudancas-situacao/` | mudanças de situação dos últimos dias (`feat/APP12`) | §18.5 |

- `GET /api/relatorios/parcelas/` também existe (W12), mas o app **não** o usa.
- **Corretor** e **administrador**: **403** `{"detail": "Este recurso é restrito ao gestor."}`
  (`erro_403_relatorio.json`).
- Sem token, ou com chave inválida ou revogada: **401** `{"detail": ...}` com o cabeçalho `WWW-Authenticate: Token`.
- A **empresa é sempre a do usuário logado**, nunca um parâmetro: o app não manda `empresa`.
- Sem migração: as duas rotas novas só consultam.

### 18.2 Totais por situação

`GET /api/relatorios/acervo/` (exemplo: `contrato/relatorio_acervo.example.json`, cópia byte a byte de
`test/fixtures/api/relatorio_acervo.json`). **O app lê só duas chaves** (D-09):

| Chave | Tipo | Observação |
|-------|------|------------|
| `totais` | objeto | exatamente as 4 situações — `DISPONIVEL`, `RESERVADO`, `VENDIDO`, `ALUGADO` — com **inteiros** ≥ 0 |
| `total` | inteiro | igual à soma dos quatro; o app mostra o número do servidor |

`situacoes` (lista de `{situacao, rotulo}`) e `linhas` (quebra por natureza, com `por_situacao`) **existem na resposta e o
app não os lê**. O app **não soma** os quatro valores: cada card mostra o `totais.<situação>` e o rodapé mostra o `total`.

### 18.3 Acervo por corretor

`GET /api/relatorios/acervo-por-corretor/` (exemplo: `contrato/relatorio_acervo_por_corretor.example.json`, cópia byte a
byte de `relatorio_acervo_por_corretor.json`). Resposta `{linhas, total}`; **sem paginação** e sem parâmetros.

**Linha: exatamente 4 chaves:**

| Chave | Tipo | Observação |
|-------|------|------------|
| `corretor_id` | inteiro | |
| `corretor` | string | nome do corretor |
| `ativo` | booleano | `false` = usuário desativado que ainda é responsável por imóvel (o app escreve "(desativado)", D-14) |
| `total` | inteiro | quantos imóveis o corretor tem |

- **O que conta (D-12):** todos os imóveis da empresa, em **qualquer situação**, publicados ou não, agrupados por
  `corretor_responsavel`. A base é a mesma do §18.2, então a **soma das linhas é igual ao `total`** e esse `total` é igual
  ao `total` do §18.2 (na captura, 36).
- **Quem aparece (D-13):** todo corretor **ativo** da empresa, **mesmo com zero** (quem está sem acervo é justamente o que o
  gestor quer ver), e também o desativado que ainda é responsável por algum imóvel, com `ativo: false`. Na captura:
  `35` (ativo), `1` (desativado) e `0` (ativo sem acervo).
- **Ordem:** quem tem mais imóveis primeiro e, no empate, por nome.

### 18.4 Contatos por corretor

`GET /api/relatorios/contatos/` (exemplo: `contrato/relatorio_contatos.example.json`, cópia byte a byte de
`relatorio_contatos.json`).

| Parâmetro | Regra |
|-----------|-------|
| `de` | `AAAA-MM-DD`, **inclusiva**, dia de São Paulo (§18.7) |
| `ate` | `AAAA-MM-DD`, **inclusiva**, dia de São Paulo; `de` depois de `ate` → 400 |
| `imovel` | id do imóvel; **o app não manda** (D-15): o card não pede filtro por imóvel |

Sem `de` e `ate` a resposta cobre **todo o período** (o padrão do app, D-16). A resposta é
`{de, ate, linhas, total, pendentes}`: `de` e `ate` voltam **ecoados** (`null` quando não foram enviados),
`total` e `pendentes` são inteiros e a soma de `total` das linhas é igual ao `total` da resposta.

**Linha: exatamente 5 chaves:**

| Chave | Tipo | Observação |
|-------|------|------------|
| `corretor_id` | inteiro ou `null` | `null` na linha da empresa (contatos de corretor desativado no clique) |
| `corretor` | string | nome; na linha da empresa o servidor manda um texto próprio que o app **NÃO mostra**: usa o texto fixo "Empresa (corretor desativado no clique)" (D-17) |
| `ativo` | booleano ou `null` | `null` na linha da empresa; `false` = corretor desativado |
| `total` | inteiro | contatos recebidos no período |
| `pendentes` | inteiro | os que ainda aguardam retorno (`retorno = PENDENTE`) |

Todo corretor **ativo** aparece, mesmo com `total` 0 (`relatorio_contatos_periodo.json`: janeiro de 2024, `total` 0 e duas
linhas zeradas). Ordem: quem recebeu mais primeiro e, no empate, por nome.

**Erro:** data inválida ou período invertido → **400** `{"<campo>": "<mensagem>"}` (o valor é uma **string**), por exemplo
`{"de": "A data inicial não pode ser depois da final."}` (`erro_400_relatorio_contatos.json`). O app ignora o texto (§18.8).

### 18.5 Mudanças de situação

`GET /api/relatorios/mudancas-situacao/` (exemplo: `contrato/relatorio_mudancas.example.json`, cópia byte a byte de
`relatorio_mudancas.json`).

| Parâmetro | Regra |
|-----------|-------|
| `dias` | opcional, inteiro de **1 a 365**; **o padrão (7) é decidido no servidor** e o app **não manda** (D-19) |

Resposta `{dias, desde, mudancas}`: `dias` (inteiro) é a janela usada, **que o app mostra** no título "últimos N dias" (o
"7" não fica escrito no app), e `desde` (`AAAA-MM-DD`) é o primeiro dia da janela (hoje e os 6 dias anteriores, pelo dia de
São Paulo).

**Item de `mudancas`: exatamente 9 chaves** (D-20):

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | id do registro de histórico |
| `imovel_id` | inteiro | |
| `imovel_codigo` | string | código interno do imóvel na empresa |
| `imovel_titulo` | string | |
| `situacao_anterior` | string | uma das 4 situações do §18.2 |
| `situacao_nova` | string | uma das 4 situações |
| `alterado_por` | string | só o nome de quem mudou |
| `alterado_em` | ISO-8601 com offset `-03:00` | |
| `observacao` | string | pode ser `""` |

- **Ordem fixa:** `-alterado_em, -id`.
- **Entram todas as mudanças do período**, inclusive as feitas pela **assinatura de contrato** (na captura da empresa B,
  `observacao` "Contrato #1 de venda assinado em 01/07/2026.").
- **Sem paginação:** a janela de dias já limita o tamanho. Risco `costly` aceito (§18.9).
- **Erro:** `dias` fora de 1 a 365 ou não numérico → **400** `{"dias": "Informe um número de dias entre 1 e 365."}`
  (`erro_400_dias.json`).
- Na captura, a mudança de 10 dias atrás (criada só no SQLite temporário) **fica fora** da janela de 7 dias e entra com
  `?dias=30`: a janela falha nos dois sentidos.

### 18.6 Isolamento e papel

**Só o gestor, só a empresa dele, nas 4 rotas.** O filtro por empresa é sempre o `request.user.empresa_id`, e o papel é a
permissão `EhGestor`: corretor e administrador recebem 403 e o anônimo 401, em todas as rotas.

**Evidência no wire:** a captura dá **imóvel e mudança de situação à empresa B** (`relatorio_acervo_por_corretor_outra_empresa.json`,
`total` 1, e `relatorio_mudancas_outra_empresa.json`, 1 mudança) e exige que nada dela apareça nos relatórios da A; o
corretor da captura recebe 403 nas 4 rotas. O teste do app exige que os relatórios da B **não sejam vazios** (senão a
prova seria vazia), que nenhum `corretor_id` dela esteja no acervo por corretor da A e que nenhum `imovel_id` das mudanças
dela esteja nas da A. A cobertura completa por perfil fica nas classes do Django (§18.10): `AcervoPorCorretorTests`,
`MudancasDeSituacaoTests`, `AreaDoGestorApiTests` e `ApiRelatoriosTests`.

### 18.7 Fuso e janela

O servidor usa `TIME_ZONE = 'America/Sao_Paulo'` com `USE_TZ = True`.

- `de` e `ate` do §18.4 e a janela de `dias` do §18.5 são **dias de São Paulo** (o recorte usa o dia local do servidor).
  Dia de São Paulo, não UTC: um contato das 22h de Brasília continua no dia dele.
- `alterado_em` sai em ISO-8601 **com offset de São Paulo** (`-03:00`), por exemplo `2026-11-25T17:53:12.715486-03:00`.
- O app manda `de`/`ate` formatados do `DateTime` local escolhido no seletor, sem `toUtc()`, e mostra a hora **do aparelho**
  (`toLocal()`). Num aparelho fora do fuso de Brasília a hora mostrada difere da do site; o dia do filtro continua sendo o
  de São Paulo (mesmo risco aceito do §17.7).

### 18.8 No app

- **`Dio` `@Named('autenticado')` nas 4 rotas:** o `InterceptadorSessao` coloca `Authorization: Token <chave>` só quando a
  origem do pedido é a da API configurada.
- **401 → sessão terminada** (`SessaoExpiradaException`, §14.7): o app abre o login com o aviso "Sua sessão terminou. Entre
  de novo." (D-22).
- **403 → texto fixo** "Só o gestor da imobiliária pode ver estes números." (D-23).
- **Rede, timeout, 5xx e 400 → "Não foi possível carregar."**, sempre com texto fixo do app e "Tentar de novo".
- **Situação desconhecida no wire** (valor fora das 4 do §18.2) vira **falha de formato da seção**: o app não adivinha o que
  o servidor mandou (D-24).
- **Nenhuma string do servidor na UI**, só dados como nomes de corretor, códigos e títulos de imóvel e observações; rótulos,
  mensagens de erro e o texto da linha da empresa são do app.
- **Nenhum número calculado no aparelho:** o app não conta, não soma e não filtra; cada seção carrega e falha sozinha.

### 18.9 PENDENTE WEB e riscos aceitos

| Risco | Tratamento |
|-------|-----------|
| **As mudanças vêm sem paginação.** Paginar depois troca a lista por um envelope: risco `costly` (D-20). | Aceito: a janela de dias limita o tamanho; se o volume crescer, revisitar com versão nova do app. |
| **As duas rotas novas só existem na `feat/APP12` da web** até o PR dela entrar na `main`. | **PENDENTE WEB:** o app só funciona contra um servidor que tenha a branch (ou a `main` com ela). |
| **Não há páginas "acervo por corretor" nem "mudanças recentes" no painel do site.** | Aceito: o app é o primeiro consumidor dessas duas rotas. |
| **O administrador não tem área no app** (não pertence a uma empresa). | Aceito: ele continua no aviso "Área do administrador". |
| **Situação nova no servidor quebra a seção no app antigo** (falha de formato, D-24). | Aceito: o app não inventa rótulo; atualizar o app junto com o servidor. |

### 18.10 Sincronização

Capturar só o grupo novo e copiar byte a byte para `contrato/`:

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8012 test/fixtures/api --grupo gestor
```

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `relatorio_acervo.json` | `relatorio_acervo.example.json` |
| `relatorio_acervo_por_corretor.json` | `relatorio_acervo_por_corretor.example.json` |
| `relatorio_contatos.json` | `relatorio_contatos.example.json` |
| `relatorio_mudancas.json` | `relatorio_mudancas.example.json` |

As demais fixtures do grupo (`relatorio_contatos_periodo`, `erro_400_relatorio_contatos`, `erro_400_dias`,
`erro_403_relatorio`, `relatorio_acervo_por_corretor_outra_empresa` e `relatorio_mudancas_outra_empresa`) não têm exemplo
no contrato, mas o teste do app confere as chaves e os valores delas.

O grupo faz login pela API, então as credenciais vêm **só por variável de ambiente** (nunca em arquivo): as 6 variáveis
`CAPTURA_*` descritas no docstring de `tool/capturar_fixtures_api.py`. Procedimento: **SQLite temporário** fora dos dois
repositórios (nunca o banco do `Web/.env`), com `migrate`, `semear_vitrine_dev` **e** `seed_demo`; a senha do corretor demo é
uma **senha descartável**; no mesmo SQLite se cria o gestor da empresa A, um corretor ativo **sem acervo** e a **mudança
antiga de 10 dias** que prova a janela. O servidor sobe numa **porta diferente da 8000** (a captura usou a 8012), e as
respostas dos relatórios não têm URL absoluta.

**Nunca `--grupo todos`:** ele reescreveria as fixtures das fases anteriores (o sufixo aleatório das fotos do seed mudaria
as fixtures já travadas).

Travas: no app, `test/data/contrato_area_gestor_test.dart` (chaves lidas, exemplo = fixture, soma = total e isolamento
entre empresas no wire); no Django, `AcervoPorCorretorTests`, `MudancasDeSituacaoTests`, `AreaDoGestorApiTests` e
`ApiRelatoriosTests`.

## 19. Fotos do imóvel (Fase 11)

A Fase 11 (card APP 11) acrescenta as **fotos do imóvel pelo app**: o corretor lista, envia (uma foto por requisição),
reordena, escolhe a capa e apaga as fotos de um imóvel do acervo da empresa. As rotas são aninhadas no imóvel, vivem na
branch `feat/APP11` da web até ela entrar na `main` dela, e as regras ficam num serviço só (`Web/imoveis/fotos.py`). Este §
foi escrito a partir do que o Django **entrega** e não muda os §1 a §18. As respostas de exemplo são capturadas (§19.8),
nunca escritas à mão.

### 19.1 Rotas e autenticação

Todas exigem `Authorization: Token <chave>` e a permissão `EhCorretor`. O imóvel é lido pelo mesmo recorte de empresa do
acervo (§14): **qualquer corretor da empresa do imóvel** pode usar as rotas, não só o responsável (critério 5: "os dele e
os da imobiliária"). Todas as rotas terminam em barra.

| Método e rota | Corpo | Resposta | Seção |
|---|---|---|---|
| `GET /api/imoveis/<id>/fotos/` | — | 200, lista de fotos | §19.2 |
| `POST /api/imoveis/<id>/fotos/` | multipart, **um** arquivo no campo `imagem` | 201, a foto criada | §19.3 |
| `PUT /api/imoveis/<id>/fotos/ordem/` | `{"ids": [<int>, ...]}` | 200, lista relida | §19.4 |
| `POST /api/imoveis/<id>/fotos/<foto_id>/capa/` | — | 200, lista relida | §19.5 |
| `DELETE /api/imoveis/<id>/fotos/<foto_id>/` | — | 200, lista relida | §19.6 |

- A rota antiga `/api/fotos-imovel/` (outra tarefa da equipe) continua existindo e o app **não** a usa.
- **Gestor** e **administrador**: **403** `{"detail": "Este recurso é restrito ao corretor."}` (`erro_403_fotos_gestor.json`).
- Sem token, ou com chave inválida ou revogada: **401** (§14; o interceptador do app transforma em sessão terminada).
- Imóvel inexistente ou de **outra empresa**: **404** `{"detail": ...}` igual nos dois casos, nas 5 rotas
  (`erro_404_fotos_outra_empresa.json`). `foto_id` de **outro imóvel** (mesmo da mesma empresa): **404**. O `detail`
  do 404 vem em inglês do Django e o app nunca o exibe.
- Sem migração: o model `FotoImovel` (`ordem`, `capa`, regra `uma_capa_por_imovel` no banco) já existia.

### 19.2 Item e lista

Cada foto tem **exatamente** quatro chaves (exemplo: `contrato/fotos_lista.example.json`, cópia byte a byte de
`test/fixtures/api/fotos_lista.json`):

| Chave | Tipo | Regra |
|---|---|---|
| `id` | int | id da foto |
| `imagem` | string | **URL absoluta** da mídia (`http://<host>/media/imoveis/fotos/...`), montada com o host da requisição |
| `ordem` | int | posição definida pelo corretor; nas listas devolvidas pelas escritas é sempre `0..n-1` |
| `capa` | bool | **exatamente uma** `true` quando o imóvel tem foto; nenhuma quando não tem |

A lista vem ordenada por **`ordem, id`** (a ordem que o corretor arrumou). A capa é indicada pelo campo, **não** pela
posição: o app mostra a lista na ordem recebida e marca a capa pelo `capa`. Sem paginação (no máximo 30 itens).
Imóvel sem foto: `[]` (`fotos_lista_vazia.json`).

### 19.3 Envio (uma foto por requisição)

`POST` `multipart/form-data` com **exatamente um** arquivo no campo `imagem` (exemplo de 201:
`contrato/foto_enviada.example.json`).

- A foto entra **no fim**: `ordem` = maior ordem do imóvel + 1 (0 quando não há fotos).
- Vira **capa** quando o imóvel ainda não tem capa (a primeira foto vira capa sozinha).
- Validação no servidor, abrindo o arquivo com o Pillow (o content-type enviado não vale): **JPEG, PNG ou WEBP**, até
  **5 MB**. O app manda JPEG de até 1920 px no lado maior (D-07), bem abaixo do limite.
- **No máximo 30 fotos por imóvel.**
- Recusa = **400** com **só a chave `imagem`** (lista de textos em português) e **nada é gravado**:

| Caso | Mensagem (fixture) |
|---|---|
| arquivo que não é imagem | "O arquivo enviado não é uma imagem válida." (`erro_400_foto_tipo.json`) |
| acima de 5 MB | "A imagem não pode passar de 5MB." (`erro_400_foto_tamanho.json`) |
| 0 ou 2+ arquivos | "Envie exatamente uma imagem por requisição." (`erro_400_foto_quantidade.json`) |
| 31ª foto | "Este imóvel já tem 30 fotos, o máximo permitido." (`erro_400_foto_limite.json`) |

O app mostra essa mensagem achatada (`mensagemDeRecusa`) na foto recusada, só como texto: nenhuma decisão sai dela.
Um POST que esgotou o tempo pode ter gravado: o app não reenvia sozinho, e a lista relida mostra a verdade.

### 19.4 Reordenar

`PUT .../fotos/ordem/` com `{"ids": [...]}` contendo **todas** as fotos do imóvel, cada uma uma vez, na ordem nova. O
servidor grava `ordem = 0..n-1` numa transação e devolve a **lista relida** (`fotos_reordenadas.json`). Id faltando,
repetido, de outro imóvel, lista vazia com fotos, `ids` ausente ou que não seja lista de inteiros: **400** com **só a
chave `ids`** ("Envie a lista completa das fotos deste imóvel, sem repetir." ou "Envie a lista de ids das fotos (números
inteiros)."; `erro_400_fotos_ordem.json`) e **nada muda**. O app nunca move a foto localmente: mostra a lista devolvida.

### 19.5 Capa

`POST .../fotos/<foto_id>/capa/` (sem corpo): a foto vira a **única** capa, numa transação; devolve a lista relida
(`fotos_capa_definida.json`).

### 19.6 Apagar

`DELETE .../fotos/<foto_id>/`: apaga a foto e o **arquivo do disco** (depois do commit), **renumera** as restantes
`0..n-1` e, se o imóvel ficou sem capa, **promove a primeira restante pela ordem**; devolve a lista relida (exemplo:
`contrato/fotos_apos_apagar_capa.example.json`). Apagar a última deixa `[]`.

### 19.7 Onde as fotos aparecem (critério 6)

As leituras públicas leem as mesmas fotos, com a **capa primeiro** e depois a ordem do corretor:
`GET /api/publico/imoveis/<id>/` (`fotos`, §11), o `foto_capa` do cartão (§2/§13) e a página do imóvel no site
(`site_publico`, corrigida na `feat/APP11` para usar a mesma sequência). Só aparecem para imóvel que está na vitrine
(publicado e disponível, regra inalterada). Concorrência: cada escrita trava o imóvel (`select_for_update`), então envios
simultâneos não repetem ordem, não criam duas capas e não furam o teto.

### 19.8 Sincronização

```bash
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8011 test/fixtures/api --grupo fotos
```

| Fixture capturada | Exemplo do contrato |
|-------------------|---------------------|
| `fotos_lista.json` | `fotos_lista.example.json` |
| `foto_enviada.json` | `foto_enviada.example.json` |
| `fotos_apos_apagar_capa.json` | `fotos_apos_apagar_capa.example.json` |

As demais (`fotos_lista_vazia`, `fotos_reordenadas`, `fotos_capa_definida`, os quatro `erro_400_foto_*`,
`erro_400_fotos_ordem`, `erro_404_fotos_outra_empresa` e `erro_403_fotos_gestor`) não têm exemplo no contrato, mas o teste
do app confere as chaves e as regras delas. As URLs de `imagem` levam o host da captura (`127.0.0.1:8011`); nada no app
depende do host.

Procedimento ("Grupo fotos" no docstring da ferramenta): servidor a partir de uma **extração** da branch
(`git archive`), SQLite temporário com `migrate`, `semear_vitrine_dev` e `seed_demo`, senha descartável do corretor demo,
credenciais só por variável de ambiente, porta diferente da 8000. O grupo apaga todas as fotos que criou no fim.
**Nunca `--grupo todos`.**

Travas: no app, `test/data/contrato_fotos_imovel_test.dart`; no Django, `imoveis/tests_fotos.py` (`ServicoFotosTests`,
`RotasFotosTests`, `FotosNaVitrineTests`) e `site_publico.tests.PaginaImovelTests`.
