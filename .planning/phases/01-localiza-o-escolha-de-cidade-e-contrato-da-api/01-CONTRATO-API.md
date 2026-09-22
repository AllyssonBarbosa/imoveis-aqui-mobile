# Contrato da API Pública — `GET /cidades` e `GET /imoveis`

**Status:** rascunho técnico, aguardando sign-off da frente web (E2) — ver §7.
**Fonte:** auditoria direta dos models/serializers/views do repositório irmão
`../imoveis-aqui/Web` (Django 5.2 + DRF), lidos nesta sessão. Nenhum campo abaixo foi
inventado sem checar o código-fonte real.
**Versionamento:** este documento deve ser copiado para `../imoveis-aqui/Web` (D-03) e só
é considerado "congelado" depois do E2 concordar — ver §8.

---

## 1. Resumo da auditoria

O `PROJECT.md` deste repo (app) tinha uma nota desatualizada dizendo que "o model de
Imóvel ainda não existe". **Isso está incorreto.** A auditoria desta sessão confirma:

- O model `Imovel` (`../imoveis-aqui/Web/imoveis/models.py`) **já existe**, com `codigo`,
  `titulo`, `finalidade` (enum `VENDA`/`ALUGUEL`/`VENDA_E_ALUGUEL`), `preco_venda`,
  `preco_aluguel`, `preco_condominio`, `preco_iptu`, `descricao`, `caracteristicas` (M2M),
  `endereco` (FK 1:1 para `core.Endereco`), `publicado` (bool) e `criado_em`.
- O model `Cidade` (`../imoveis-aqui/Web/localizacao/models.py`) já existe com `nome` e
  `uf`, `unique(nome, uf)` — exatamente a chave natural que D-15 já assume.
- Já existe um `CidadeSerializer` (`id`, `nome`, `uf`) em
  `../imoveis-aqui/Web/empresas/api/serializers.py`, reaproveitável tal como está para o
  futuro endpoint público de cidades.
- Já existe o precedente de endpoint público sem token:
  `EmpresaPublicaAPIView` (`AllowAny`, `queryset = Empresa.objects.filter(ativa=True)`)
  em `../imoveis-aqui/Web/empresas/api/views.py` — o modelo a copiar para
  `/api/publico/cidades/` e `/api/publico/imoveis/`.
- Já existe um `ImovelViewSet` **autenticado e empresa-scoped**
  (`core.mixins.EmpresaScopedQuerySetMixin`) em `../imoveis-aqui/Web/imoveis/api/views.py`,
  usando `ImovelSerializer`, que expõe `corretor_responsavel` e `proprietario` — campos
  que **NUNCA** podem vazar no endpoint público (ver §6).

O que **realmente falta** (a lacuna real, não a lacuna suposta pelo PROJECT.md):

1. A **tipologia** do imóvel — `natureza` (casa/apartamento/terreno/lote), `quartos`,
   `suites`, `vagas`, `area` — não existe em nenhum campo do model `Imovel` hoje.
   Dependência externa da frente web (E2). Marcado **PENDENTE E2** em todo este documento.
2. Os **endpoints públicos** `GET /cidades` e `GET /imoveis` em si — não existem ainda,
   nem rota nem view nem serializer dedicado.

Este documento congela o contrato desses dois endpoints ainda-não-construídos, para que
APP02/APP03 (app) e a Fase 4 (endpoint real) construam contra a mesma forma.

---

## 2. `GET /cidades`

### 2.1 Campos (grounded em `Cidade` + `CidadeSerializer` existente)

| Campo | Tipo | Origem | Observação |
|-------|------|--------|------------|
| `id` | inteiro | `Cidade.id` (PK) | |
| `nome` | string | `Cidade.nome` (max 100) | |
| `uf` | string (2 chars) | `Cidade.uf` (max 2) | Sigla, ex. `"SP"` |

Forma idêntica ao `CidadeSerializer` já existente em
`empresas/api/serializers.py` (`fields = ["id", "nome", "uf"]`) — o endpoint público pode
reaproveitar esse serializer sem alteração.

### 2.2 Envelope — `CursorPagination`

```json
{
  "next": null,
  "previous": null,
  "results": [
    { "id": 1, "nome": "Campinas", "uf": "SP" }
  ]
}
```

Ver §4 para a especificação completa da paginação (D-01).

### 2.3 Regra do conjunto servido ("atendidas")

`GET /cidades` **NÃO** é `Cidade.objects.all()`. Uma linha em `Cidade` pode existir sem
nenhuma `Empresa` atuando ali (é "tabela geral mantida pelo administrador", desacoplada de
quem realmente atua). A regra correta, auditada em
`../imoveis-aqui/Web/empresas/models.py` (`Empresa.cidades_atuacao`, M2M,
`related_name="empresas_atuantes"`) e espelhando o precedente
`EmpresaPublicaAPIView.queryset = Empresa.objects.filter(ativa=True)`:

```python
Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()
```

Ou seja: só entram cidades com pelo menos uma `Empresa` ativa (`ativa=True`) atuando nelas.
Esta regra deve ser aplicada de forma **idêntica** pela `assets/cidades.json` fixa desta
fase (D-13/D-16) e pelo endpoint real da Fase 2 — senão a lista fixa e a lista real
divergem silenciosamente (Pitfall 4 do RESEARCH.md).

---

## 3. `GET /imoveis`

### 3.1 Campos — reais hoje (grounded em `Imovel` + `Endereco` + `Cidade`)

| Campo | Tipo | Origem | Observação |
|-------|------|--------|------------|
| `id` | inteiro | `Imovel.id` (PK) | |
| `titulo` | string | `Imovel.titulo` (max 200) | |
| `finalidade` | enum string | `Imovel.finalidade` | `VENDA` \| `ALUGUEL` \| `VENDA_E_ALUGUEL` |
| `preco_venda` | string decimal, nullable | `Imovel.preco_venda` | `null` quando finalidade é só `ALUGUEL` |
| `preco_aluguel` | string decimal, nullable | `Imovel.preco_aluguel` | `null` quando finalidade é só `VENDA` |
| `descricao` | string | `Imovel.descricao` | pode ser vazio |
| `bairro` | string | `Imovel.endereco.bairro` (`core.Endereco`) | pode ser vazio |
| `cidade` | objeto aninhado `{id, nome, uf}` | `Imovel.endereco.cidade` (FK `Cidade`) | mesma forma de §2.1 |
| `foto_capa` | string URL, nullable | `FotoImovel` do imóvel com `capa=True` | `null` se nenhuma foto marcada como capa |
| `caracteristicas` | lista de strings | `Imovel.caracteristicas` (M2M → `Caracteristica.nome`) | ex. `["Portão eletrônico", "Ar-condicionado"]` |
| `criado_em` | string ISO 8601 datetime | `Imovel.criado_em` | |

Campos que existem no model (`preco_condominio`, `preco_iptu`) mas **não** foram incluídos
na vitrine por escopo de VIT-02 — disponíveis no model real se uma fase futura precisar
deles; não fazem parte deste contrato v1.

### 3.2 Campos de tipologia — **PENDENTE E2** (não existem no model hoje)

| Campo | Tipo proposto | Enum/observação | Status |
|-------|---------------|------------------|--------|
| `natureza` | enum string | `CASA` \| `APARTAMENTO` \| `TERRENO` \| `LOTE` | **PENDENTE E2** |
| `quartos` | inteiro | — | **PENDENTE E2** |
| `suites` | inteiro | — | **PENDENTE E2** |
| `vagas` | inteiro | — | **PENDENTE E2** |
| `area` | string decimal | m² | **PENDENTE E2** |

Confirmado por leitura completa de `imoveis/models.py`: **nenhum** desses campos existe no
model `Imovel` atualmente (D-02). Congelamos a forma agora — nomes, tipos, enum de
`natureza` — para que APP02/APP03 construam a UI/models Freezed contra a forma completa
desde já; quando o E2 entregar o model real, o parsing já bate. Renomear estes campos
depois é **custoso** (D-02): exige mexer em fixtures, models `freezed` do app e no
serializer público da API ao mesmo tempo.

### 3.3 Exemplo de linha completa (real + PENDENTE E2)

```json
{
  "id": 42,
  "titulo": "Apartamento 2 quartos no Cambuí",
  "finalidade": "VENDA",
  "preco_venda": "450000.00",
  "preco_aluguel": null,
  "descricao": "Apartamento reformado, próximo ao centro.",
  "bairro": "Cambuí",
  "cidade": { "id": 3, "nome": "Campinas", "uf": "SP" },
  "foto_capa": "https://api.exemplo.com/media/imoveis/fotos/capa-42.jpg",
  "caracteristicas": ["Portão eletrônico", "Ar-condicionado"],
  "criado_em": "2026-08-14T10:32:00Z",
  "natureza": "APARTAMENTO",
  "quartos": 2,
  "suites": 1,
  "vagas": 1,
  "area": "68.50"
}
```

---

## 4. Paginação — `CursorPagination`

Ambos os endpoints (`GET /cidades` e `GET /imoveis`) usam **DRF `CursorPagination`**
(D-01), não `PageNumberPagination`/`LimitOffsetPagination`:

- **Envelope:** `{ "next": <url|null>, "previous": <url|null>, "results": [...] }`.
- **Sem `count`** total no envelope — trade-off aceito conscientemente (D-01). Uma "Ver N
  imóveis" fica para v2/API-05, quando houver contagem barata.
- **Sem pulo de página** — só "próxima"/"anterior", nunca "ir para página 5".
- **Ordenação estável obrigatória:** o `ordering` do `CursorPagination` deve ser um campo
  estável e não-nulo, ex. `-criado_em` para `/imoveis`, `["nome", "uf"]` para `/cidades`
  (mesmo `ordering` já declarado em `Cidade.Meta.ordering`).
- **Query param:** `cursor` (D-04, snake_case — coincide com o default do DRF).
- **Racional (D-01):** cursor imuniza o scroll infinito da vitrine contra cards
  duplicados/embaralhados quando o acervo muda durante a navegação — critério de sucesso
  das Fases 2/3.
- **Reversibilidade:** **one-way**. Trocar o esquema de paginação depois quebra o contrato
  já acordado com a frente web e o parsing de toda resposta paginada no app — não mude sem
  reabrir esta decisão com o E2.

---

## 5. Query params de `GET /imoveis` (português snake_case, D-04)

| Param | Tipo | Semântica | Status |
|-------|------|-----------|--------|
| `cidade` | string ou int | Filtra por cidade — **formato exato pendente, ver §7** | pendente formato |
| `preco_min` | decimal | Preço mínimo (venda ou aluguel, conforme `finalidade`) | congelado (nome) |
| `preco_max` | decimal | Preço máximo | congelado (nome) |
| `quartos_min` | inteiro | Quartos — **mínimo ou exato? ver §7** | pendente semântica |
| `suites_min` | inteiro | Suítes — **mínimo ou exato? ver §7** | pendente semântica |
| `vagas_min` | inteiro | Vagas — **mínimo ou exato? ver §7** | pendente semântica |
| `natureza` | string (enum) | `CASA`\|`APARTAMENTO`\|`TERRENO`\|`LOTE` — PENDENTE E2 (campo não existe ainda) | pendente E2 |
| `finalidade` | string (enum) | `VENDA`\|`ALUGUEL`\|`VENDA_E_ALUGUEL` | congelado |
| `bairro` | string | Filtro textual de bairro | congelado (nome) |
| `area_min` | decimal | Área mínima em m² — PENDENTE E2 | pendente E2 |
| `area_max` | decimal | Área máxima em m² — PENDENTE E2 | pendente E2 |
| `caracteristicas` | lista (CSV ou múltiplos params) | Filtra por características marcadas | congelado (nome) |
| `ordenacao` | string (enum) | **Valores exatos pendentes, ver §7** | pendente valores |
| `cursor` | string (opaco) | Cursor de paginação (§4) | congelado |

Todos os nomes acima são português snake_case, coerente com D-04 e com os models Django já
em PT. Nenhum filtro/busca/ordenação é resolvido no app — tudo é resolvido no servidor e a
lista chega pronta (regra de negócio do projeto: "nada é recalculado dentro do aparelho").

---

## 6. Serializer público / segurança — allowlist obrigatória

**Requisito de alto peso, não negociável para a Fase 4:**

- O endpoint público de `/imoveis` **deve** usar um serializer **dedicado e público**,
  nunca o `ImovelSerializer` autenticado existente
  (`../imoveis-aqui/Web/imoveis/api/serializers.py`). Esse serializer autenticado expõe
  `corretor_responsavel` e `proprietario` — dados internos de empresa/pessoa que **nunca**
  podem aparecer numa resposta `AllowAny`.
- A **allowlist explícita** do serializer público é exatamente a tabela de §3.1 + §3.2
  (`id`, `titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `descricao`, `bairro`,
  `cidade`, `foto_capa`, `caracteristicas`, `criado_em`, mais os campos PENDENTE E2 quando
  existirem). Nenhum outro campo do model `Imovel` deve ser serializado publicamente —
  especificamente **nunca** `corretor_responsavel`, `proprietario`, `empresa`,
  `preco_condominio`, `preco_iptu` (fora de escopo de VIT-02, não motivo para expor).
- **Filtragem obrigatória em nível de queryset**, não de confiança por request:
  `Imovel.objects.filter(publicado=True)` — nunca confiar num filtro vindo do cliente para
  decidir o que é público. Isso espelha a disciplina do
  `EmpresaScopedQuerySetMixin` (usado pelo `ImovelViewSet` autenticado para nunca confiar
  em manipulação de URL/ID): lá o filtro obrigatório é por `empresa`; aqui o filtro
  obrigatório equivalente é por `publicado=True`.
- **Isolamento multitenant preservado de outra forma:** o endpoint público de `/imoveis` é
  propositalmente **não** escopado a uma única empresa — é uma vitrine de marketplace que
  reúne imóveis publicados de **várias** empresas na mesma cidade. O que precisa ser
  garantido é que nenhum imóvel **não publicado** (rascunho, de qualquer empresa) escape
  por manipulação de `id`/`cidade`/outro parâmetro — daí o `publicado=True` obrigatório no
  queryset, sempre, independentemente dos filtros pedidos.

---

## 7. Itens PENDENTES de sign-off da frente web

Os itens abaixo são **genuinamente em aberto** — não foram chutados como congelados; cada
um precisa de uma decisão explícita do E2 (ou do time) antes deste contrato virar
"congelado" de fato (§8).

1. **`quartos_min` / `suites_min` / `vagas_min` — mínimo (range) ou exato?**
   O nome atual (`_min`, D-04) sugere filtro de limiar (`quartos_min=2` = "2 ou mais"), mas
   isso não está confirmado com a frente web. Alternativa: nomes sem sufixo
   (`quartos=2` = exatamente 2). **Apresentando os dois lados:**
   - Opção A (limiar): `quartos_min`, `suites_min`, `vagas_min` — "2 ou mais".
   - Opção B (exato): `quartos`, `suites`, `vagas` — "exatamente 2".
   Requer escolha explícita do E2 antes de o app implementar FIL-03.

2. **Formato do param `cidade` em `GET /imoveis` — nome+uf ou id numérico?**
   D-15 persiste a cidade escolhida no app pela chave natural (`nome+uf`), não por `id`,
   justamente para ficar estável entre a fixture e a API real. Recomendação (não
   congelada): manter o mesmo formato natural no query param, ex. `?cidade=Campinas-SP`,
   por consistência com D-15 — mas isso muda como o futuro `filter backend` do
   `ImovelViewSet` público resolve o parâmetro (um lookup tipo slug em dois campos é um
   pouco mais código que um filtro de FK por `id`). Requer acordo explícito do E2.

3. **Qual preço a vitrine mostra no card quando `finalidade == VENDA_E_ALUGUEL`?**
   O model permite `preco_venda` e `preco_aluguel` populados simultaneamente. `GET /imoveis`
   sempre expõe os dois campos (já é o caso hoje); qual é mostrado/priorizado no card é uma
   decisão de **UI da Fase 2**, não do contrato da API — sinalizado aqui para a Fase 2 não
   ser pega de surpresa pelo dado duplo, não é um bloqueio de API-01.

4. **Valores do enum `ordenacao`.**
   Proposta de trabalho (convenção snake_case, fácil de corrigir depois por ser valor de
   param, não forma de dado): `preco_asc`, `preco_desc`, `area_asc`, `area_desc`,
   `mais_recentes`. **Não congelado** — precisa validação do E2, especialmente porque
   `area_asc`/`area_desc` dependem dos campos PENDENTE E2 (§3.2) existirem.

Nenhum destes quatro itens deve ser tratado como decidido pela app ou pela API antes do
sign-off — congelar um chute aqui é exatamente o erro que este documento existe para
evitar.

---

## 8. Nota de sincronização (D-03)

Este documento é a fonte da verdade combinada entre os dois repositórios. Passos manuais
de coordenação (fora do escopo automatizável deste plano):

1. Copiar `01-CONTRATO-API.md` (este arquivo) para `../imoveis-aqui/Web` (ou um local
   equivalente acessível ao E2).
2. Obter concordância explícita do E2 sobre os itens de §7 (e sobre a forma geral dos
   campos de §2/§3, incluindo os PENDENTE E2 de §3.2).
3. Só depois desse sign-off o contrato é considerado **congelado** de fato — até lá, ele é
   um rascunho técnico grounded em código real, pronto para servir de base de discussão.

Enquanto o sign-off não acontece, `contrato/cidades.example.json` e
`contrato/imoveis.example.json` (ver Task 2) servem como fixtures de mock para as Fases
2/3 (API-04), permitindo que o app avance sem bloquear na resposta do E2.
