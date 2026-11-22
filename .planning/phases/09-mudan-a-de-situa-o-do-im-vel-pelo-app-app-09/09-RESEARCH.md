# Phase 9: Mudança de Situação do Imóvel pelo App (APP 09) - Research

**Researched:** 2026-11-22
**Domain:** App Flutter (Clean Architecture + Cubit) consumindo rotas autenticadas já prontas do Django/DRF (primeira escrita autenticada do app)
**Confidence:** HIGH (contrato da API lido na `origin/main` `8bf4448` e exercitado com testes reais; padrões do app lidos no código; nenhuma biblioteca nova)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Tela do imóvel no acervo
- **D-01:** **Tela nova de gestão do imóvel**, aberta por `Navigator.push` a partir do cartão do
  Meu acervo. Serve para qualquer imóvel do acervo, inclusive reservado, vendido, alugado ou não
  publicado. Dados de `GET /api/imoveis/{id}/` + `GET /api/imoveis/{id}/historico/`. É a "Detalhe
  do acervo" que a Phase 8 adiou, limitada ao que o card pede (D-03). A página pública não serve:
  imóvel reservado sai da vitrine e não daria para voltá-lo a disponível pelo app.
- **D-02:** **Todo cartão do acervo abre a tela de gestão** (substitui o comportamento do F8/D-07,
  em que só o cartão `na_vitrine` reagia). Dentro da tela, um botão "Ver na vitrine" aparece só
  quando o servidor diz `na_vitrine = true` e abre a página pública que já existe
  (`abrirDetalheImovel`). O app nunca decide isso olhando `publicado`/`situacao`. Como o
  `na_vitrine` vem da lista do acervo (e não do `ImovelSerializer`), a pesquisa define como a tela
  recebe esse booleano (por exemplo, passado do cartão ao abrir).
- **D-03:** Conteúdo da tela = **só o cabeçalho + situação + histórico**: foto de capa, código,
  título, preço (reaproveitando `linhasDePreco`), situação atual com "desde" (`situacao_desde`),
  botão "Mudar situação" e o histórico. Nada de endereço, descrição ou detalhe por natureza.
- **D-04:** O botão "Mudar situação" aparece **só quando `pode_mudar_situacao = true`** (vem do
  Django). Corretor que não é o responsável vê a situação e o histórico, sem botão. Se mesmo assim
  o servidor recusar, vale o D-10.

### Data e observação
- **D-05:** **A data é a do servidor** (`alterado_em`, gravada automaticamente), igual ao site.
  Nenhuma mudança no modelo do Django. O formulário mostra "Data: hoje" só como informação; o
  histórico mostra a data e a hora de cada mudança (`dd/mm/aaaa HH:mm`). Isso atende o AC-1 do
  mesmo jeito que o site.
- **D-06:** **Observação opcional**, como na API e no site. O app não cria regra própria. O campo
  usa a mesma dica do `SituacaoForm` do site: "Ex.: reservado para o cliente João até a
  assinatura."

### Gestor e repo web
- **D-07:** **O gestor continua na tela de aviso** (F8/D-B); a área dele é da APP-12, que pode
  reaproveitar a tela de gestão depois. O AC-6 é garantido pelo servidor
  (`pode_mudar_situacao` + 403 + `EhCorretor` no `ImovelViewSet`) e provado por teste no Django e
  no UAT com um corretor que não é o responsável (sem botão; e, se forçar, recusa).
- **D-08:** **Repo web só se faltar algo.** A pesquisa confere se as rotas atendem como estão,
  inclusive se há testes de 403, de isolamento entre empresas e de 400 (contrato assinado / mesma
  situação) para `POST situacao/` e `GET historico/` da API. Se faltar teste ou campo, entra numa
  branch `feat/APP09` criada da `main` atualizada do repo web; se não faltar nada, a web não muda.
  Atenção: o clone local `../imoveis-aqui` está na `feat/APP06`, atrás da `origin/main`; a
  pesquisa lê a `origin/main`. Commits locais liberados; **push só com autorização explícita**.

### Fluxo da troca
- **D-09:** **Folha inferior** (`showModalBottomSheet`) aberta pelo botão "Mudar situação": chips
  de escolha única Disponível / Reservado / Vendido / Alugado (a situação atual aparece
  desabilitada), campo de observação, "Data: hoje" informativo e `FilledButton` "Confirmar". Sem
  diálogo extra: o Confirmar é a confirmação. Confirmar fica desabilitado até escolher uma situação
  diferente da atual.
- **D-10:** **A folha espera o servidor.** Durante o envio, Confirmar mostra carregamento e a folha
  não fecha.
  - **Recusa (400/403):** a folha continua aberta, com a observação preservada, e mostra **a
    mensagem do servidor** (as mensagens do Django são em português e explicam o motivo, como
    contrato assinado ou "Só o corretor responsável..."). A situação na tela não muda (AC-4).
  - **Rede, timeout ou 5xx:** texto fixo "Não foi possível mudar a situação agora. Tente de novo."
  - **401:** segue o tratamento de sessão expirada da Phase 8 (apaga o token, volta ao login com
    "Sua sessão terminou. Entre de novo.").
  - **Sucesso:** a folha fecha, aparece o SnackBar "Situação alterada para reservado." (o mesmo
    texto do site, com a situação em minúsculas) e a tela **recarrega imóvel e histórico da API**.
    O app não monta o estado novo sozinho (AC-2).
  As falhas são tipadas na camada de dados (recusa com mensagem, sem permissão, rede, sessão
  expirada), sem `try/catch` na UI.

### Histórico
- **D-11:** **Lista simples**, na ordem do servidor (mais recente primeiro). Cada item:
  "Disponível → Reservado", "22/11/2026 14:30 · Nome de quem mudou" e a observação, quando houver.
  Vazio: "Nenhuma mudança ainda — disponível desde o cadastro." (o mesmo texto do site). Os
  rótulos das situações reaproveitam `rotuloSituacao`. Sem paginação: a rota devolve a lista
  inteira.

### Volta ao acervo e vitrine
- **D-12:** **O acervo recarrega da API** ao voltar da tela de gestão quando houve mudança (a tela
  devolve "mudou" no `pop`), mantendo a busca e o filtro de situação atuais. O chip do cartão vem
  certo do servidor. A vitrine pública já consulta o servidor a cada abertura; o AC-5 é provado no
  UAT (reservar → o imóvel some da vitrine na próxima consulta; voltar a disponível → reaparece).

### Contrato e rastreabilidade
- **D-13:** Novo **§16** em `01-CONTRATO-API.md` (o §15 já é o contato da APP 06), no padrão do
  §13/§14: `GET /api/imoveis/{id}/` (campos que a tela usa), `POST .../situacao/` (corpo, 200,
  400, 401, 403, 404) e `GET .../historico/`, com exemplos capturados da API real, não escritos à
  mão (como o §14.9).
- **D-14:** Novos IDs em `REQUIREMENTS.md` (seção "Situação do imóvel (APP09)"), mapeados para a
  Phase 9 no ROADMAP (`**Requirements**:`, hoje "TBD") e na tabela de rastreabilidade, cobrindo
  AC-1..AC-6, como a Phase 8 fez (F8/D-16). Os nomes exatos ficam para o planejador.

### Regras do projeto (carregadas das fases anteriores)
- **D-15 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado
  freezed, `Result`/falhas tipadas, sem `try/catch` na UI, Material 3 verde e branco (cores só do
  `ColorScheme`, texto do `textTheme`), código e comentários em português, `Navigator.push` +
  `MaterialPageRoute` (sem go_router). O token vai só nas rotas autenticadas (F8).
- **D-16 [informational]:** `flutter analyze` limpo e `flutter test` verde rodados à mão a cada
  onda (o gate pós-merge do GSD pula os testes Flutter por causa do `ios/Runner.xcodeproj`).
  `python manage.py test` verde no repo web, se ele mudar. Arquivos gerados que o `build_runner`
  reescreve só com CRLF são restaurados com `git checkout --`. `workflow.use_worktrees=false`.
  Nenhum commit sem o OK do usuário.

### Claude's Discretion
- Nomes de telas, Cubits e arquivos (sugestão: `lib/presentation/gestao_imovel/` com Cubit da tela
  e Cubit/estado da folha, ou um Cubit só), entidades e UseCases novos em `domain/`, DataSource em
  `data/` (estendendo o do acervo ou um novo).
- Título da tela (sugestão: o código do imóvel ou "Imóvel"), ícones, carregamento e erro da
  primeira carga da tela (com "Tentar de novo"), e o "puxar para atualizar".
- Se a tela carrega imóvel e histórico em paralelo e como mostra falha parcial.
- Como achatar as mensagens do 400 (`{"situacao": [...]}`) e do 403 (`{"detail": ...}`) numa
  mensagem só; se vier vazia, usar o texto fixo de rede.
- UI-SPEC: como na F4/D-20, F7/D-16 e F8, as decisões D-01..D-12 podem servir de contrato de UI,
  com confirmação no human-check de fim de fase; `/gsd-ui-phase 9` é opcional.

### Deferred Ideas (OUT OF SCOPE)
- **Área do gestor no app** (lista da empresa via `/api/gestao/imoveis/` e a mesma tela de gestão):
  APP-12.
- **Data informada pelo corretor** (diferente da data do servidor): exigiria campo novo no
  `HistoricoSituacao` e migração no Django; só se a equipe web decidir.
- **Dados completos do imóvel** na tela de gestão (endereço, descrição, detalhe por natureza) e
  edição pelo app: fora do card.
</user_constraints>

<phase_requirements>
## Phase Requirements

Os IDs são **propostos** aqui (D-14 deixa os nomes para o planejador). Prefixo `SIT-` para o app e `API-11`/`API-12` para contrato e web (a Phase 8 parou em `API-10`).

| ID | Descrição (proposta) | Research Support |
|----|----------------------|------------------|
| SIT-01 | O corretor troca a situação (Disponível/Reservado/Vendido/Alugado) com observação opcional; a data é a do servidor, mostrada como "Data: hoje" informativo no formulário e no histórico (AC-1) | §Contrato da API (POST), §Pattern 3 (folha), §Pitfall 8 (data/fuso) |
| SIT-02 | A troca é pedida à API e o app nunca altera nada localmente: depois do 200 a tela recarrega imóvel e histórico (AC-2) | §Pattern 2 (Cubit), §Pitfall 3 (recarga que falha) |
| SIT-03 | O histórico das mudanças aparece na tela do imóvel, na ordem do servidor, com de→para, data/hora, autor e observação (AC-3) | §Contrato (GET historico), §Code Examples |
| SIT-04 | Recusa do servidor (400/403) mostra a mensagem do servidor, mantém a folha aberta com a observação e não muda a situação exibida; rede/5xx usam o texto fixo; 401 volta ao login (AC-4) | §Pattern 4 (falhas tipadas), §Contrato (formas do 400) |
| SIT-05 | A vitrine pública reflete a mudança na consulta seguinte (AC-5); o acervo recarrega da API ao voltar | §Pattern 5 (volta ao acervo), §UAT, regra única `na_vitrine()` no servidor |
| SIT-06 | Só o corretor responsável (e o gestor, pela web) muda: o botão só existe com `pode_mudar_situacao`, e o servidor recusa (403) quem forçar (AC-6) | §Contrato, §Security Domain, §Lacunas de teste no Django |
| SIT-07 | Todo cartão do acervo abre a tela de gestão; "Ver na vitrine" só quando o servidor diz `na_vitrine` (substitui o ACV-04 da Phase 8) | §Pattern 5, §Pitfall 2 (na_vitrine velho) |
| API-11 | O §16 de `01-CONTRATO-API.md` congela as três rotas com exemplos capturados da API real e teste de contrato no app | §Contrato da API, §Validation Architecture |
| API-12 | (condicional, D-08) A web ganha, na `feat/APP09`, os testes que faltam para `POST situacao/` e `GET historico/` do corretor | §Lacunas de teste no Django |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Extraídas de `./.claude/CLAUDE.md` (mesma autoridade que decisões travadas):

- **Arquitetura:** Clean Architecture em `data/` (Models, Repositories, DataSources), `domain/` (UseCases puros, interfaces de Repository) e `presentation/` (Widgets limpos, Cubits). Widget nenhum faz lógica de negócio nem rede. Não negociável.
- **Estado:** `Cubit` (flutter_bloc), imutabilidade estrita nos estados de tela (freezed).
- **Modelos de API:** todo JSON em Models imutáveis (`freezed` + `json_serializable`); nunca `dynamic` onde a tipagem forte couber.
- **Erros de API:** `Result`/sealed classes; sem `try/catch` genérico na UI.
- **UI:** Material 3 estrito; `ColorScheme.fromSeed`; widgets de `material.dart`; tipografia só do `Theme.of(context).textTheme`; paleta verde e branco.
- **Regra de negócio:** nada que mude estado (situação) é decidido no app, só no Django.
- **Idioma:** models, variáveis e comentários em português.
- **Branches:** `feat/<número do card>` (a branch atual do app já é `feat/APP09`).
- **Workflow GSD:** editar arquivos só via comando GSD. **Memória do usuário:** nunca commitar sem OK; perguntar antes; explicar em português.

## Summary

A fase é pequena no servidor e média no app. **Todas as rotas que o app precisa já existem na `origin/main` do Django** (`8bf4448`) e fazem exatamente o que o CONTEXT descreve: `GET /api/imoveis/{id}/`, `POST /api/imoveis/{id}/situacao/` e `GET /api/imoveis/{id}/historico/`, as três com `Authorization: Token`, permissão `EhCorretor` e queryset já filtrado pela empresa (imóvel de outra empresa dá 404). Não falta nenhum campo: `situacao`, `situacao_desde` e `pode_mudar_situacao` estão no `ImovelSerializer`. Exercitei as rotas com testes descartáveis numa cópia da `origin/main` (fora do repo) e capturei o wire real, inclusive todas as formas de erro (seção "Contrato da API"). O que **falta no Django são testes**, não código: a rota do corretor (`imovel-situacao`) não tem teste de 400 (mesma situação, situação inválida, contrato assinado), de 401 sem token nem de histórico de outra empresa (D-08 → branch `feat/APP09` só com testes).

No app, o trabalho é seguir o padrão da Phase 8: um DataSource autenticado novo (ou o do acervo estendido) com GET detalhe, GET histórico e o primeiro POST autenticado; um Repository que traduz status em falhas tipadas (recusa com mensagem, sessão expirada, não encontrado, rede); três UseCases; um Cubit da tela de gestão (carga paralela de imóvel e histórico) e um Cubit da folha (envio, recusa com mensagem, rede, sessão expirada). O cartão do acervo passa a abrir a tela sempre, e o acervo recarrega ao voltar com `mudou`. Não há pacote novo (`intl`, `dio`, `flutter_bloc`, `freezed` já estão no `pubspec.yaml`).

Há quatro armadilhas que o CONTEXT não previu e que o planejador deve tratar: (1) o clone local `../imoveis-aqui` na `feat/APP06` **não tem** as rotas desta fase (0 ocorrências de `pode_mudar_situacao`; a `origin/main` as tem) e a `feat/APP06` tem 2 commits que a `main` não tem, então o servidor do UAT e da captura precisa vir da `origin/main`; (2) o `na_vitrine` que a tela recebe do cartão fica velho depois de uma mudança bem-sucedida; (3) o 404 do Django vem em **inglês** ("No Imovel matches the given query."), nunca pode ser exibido; (4) a observação não tem limite no servidor (aceitou 100 000 caracteres), então o campo do app precisa de `maxLength`.

**Primary recommendation:** Estender o padrão da Phase 8 sem inventar nada: DataSource autenticado em `@Named('autenticado')`, falhas tipadas no Repository, Cubit com versão de consulta, folha com Cubit próprio via `BlocProvider.value`, `abrirGestaoImovel` devolvendo `Future<bool>` lido do estado do Cubit; capturar fixtures reais (grupo novo `situacao` no `tool/capturar_fixtures_api.py`) contra o código da `origin/main` em SQLite temporário, usando os seeds existentes (que já cobrem contrato assinado, imóvel de colega e outra empresa).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Quem pode mudar a situação (`pode_mudar_situacao`, 403) | API / Backend | — | Regra de negócio é só do Django (`Imovel.pode_mudar_situacao`); o app apenas lê o booleano |
| Validar a mudança (mesma situação, contrato assinado, situação inválida) | API / Backend | — | `Imovel.mudar_situacao` é a "única porta"; o app só repassa a mensagem |
| Gravar histórico (quem, quando, de/para) | Database / Storage | API / Backend | `HistoricoSituacao` com `alterado_em` automático; o app não envia data nem autor |
| Ordem do histórico | API / Backend | — | `Meta.ordering = ["-alterado_em", "-id"]`; o app não reordena |
| `na_vitrine` / sumiço da vitrine (AC-5) | API / Backend | — | Regra única `Imovel.objects.na_vitrine()`; o app não olha `publicado`/`situacao` |
| Pedir a mudança (POST) e recarregar | Browser / Client (app) | API / Backend | O app pede e relê; nunca monta estado novo |
| Mostrar mensagem de recusa, carregamento, SnackBar | Browser / Client (app) | — | Apresentação pura; mensagem vem do servidor |
| Token só na origem da API; 401 → sessão expirada | Browser / Client (app) | — | `InterceptadorSessao` já existente; rotas novas só usam o Dio `'autenticado'` |
| Formatar data/hora e rótulos | Browser / Client (app) | — | `intl` + `rotuloSituacao`; apenas apresentação |

## Standard Stack

### Core
Nenhuma biblioteca nova. Tudo o que a fase usa já está em `pubspec.yaml` (lido nesta sessão):

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `dio` | ^5.11.1 | GET/POST autenticados (`@Named('autenticado')`) | Já é o cliente da Phase 8; `followRedirects: false` e interceptor de token prontos |
| `flutter_bloc` | ^9.1.1 | `Cubit` da tela e da folha | Padrão do projeto |
| `freezed_annotation` / `freezed` | ^3.1.0 / ^4.0.1 | Estados, Models | Padrão do projeto |
| `json_annotation` / `json_serializable` | ^4.12.0 / ^6.14.1 | `fromJson` dos Models | Padrão do projeto |
| `injectable` / `get_it` | ^3.0.0 / ^9.3.0 | DI (regenerar `injection.config.dart`) | Padrão do projeto |
| `intl` | ^0.20.3 | `DateFormat('dd/MM/yyyy HH:mm')` | Já usado em `formatarPrecoBrl` |

### Supporting (dev)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `bloc_test` | ^10.0.0 | Testes dos dois Cubits | Sequência de estados |
| `mocktail` | ^1.0.5 | Mock de UseCases/Repositório | Testes de Cubit e tela |
| `flutter_test` | sdk (Flutter 3.47.5) | Widget/fluxo | Folha, tela, fluxo ponta a ponta |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Cubit próprio da folha | Estado efêmero no `StatefulWidget` da folha | Perde teste de sequência de estados e a regra "falha tipada sem `try/catch` na UI"; o Cubit é pequeno e segue `ContatoCubit` |
| Estender `AcervoDataSource` | `GestaoImovelDataSource` novo | O acervo é lista paginada; detalhe/histórico/POST são outro assunto. **Recomendado: DataSource novo** (`GestaoImovelDataSource` + `...RemoteDataSource`), mesmo Dio `'autenticado'` |
| Reusar o 200 do POST como estado novo | Recarregar (D-10) | O 200 traz o `ImovelSerializer` completo, mas o D-10 manda recarregar os dois; seguir o D-10 |

**Installation:** nenhuma. Após criar `@injectable`/`@freezed`/`@JsonSerializable`:
```bash
dart run build_runner build --delete-conflicting-outputs
```
(arquivos `*.freezed.dart`, `*.g.dart` e `lib/di/injection.config.dart` são versionados; restaurar com `git checkout --` os que só mudarem de CRLF, D-16.)

**Version verification:** versões lidas de `pubspec.yaml` nesta sessão `[VERIFIED: pubspec.yaml]`; `flutter analyze lib` limpo e `flutter test` com **1194 testes verdes** em 56 s, medidos hoje `[VERIFIED: execução local]`. Flutter 3.47.5 / Dart ^3.13.4.

## Package Legitimacy Audit

**Nenhum pacote externo novo é instalado nesta fase.** Todos os pacotes acima já estão no `pubspec.yaml`/`pubspec.lock` desde fases anteriores; não há `npm`/`pip`/`cargo` envolvido. Por isso a auditoria `package-legitimacy check` não se aplica.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| (nenhum novo) | — | — | — | — | — | Nada a aprovar |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

Se o planejador decidir acrescentar qualquer pacote (não recomendado), ele deve passar pelo gate e ganhar `checkpoint:human-verify`.

## Contrato da API (exato, da `origin/main` `8bf4448`)

Fonte: leitura de `Web/imoveis/api/views.py`, `serializers.py`, `models.py`, `core/permissions.py`, `core/mixins.py` e **execução de sondas descartáveis** numa cópia extraída de `git archive origin/main` (fora dos dois repos; sondas apagadas). Os textos abaixo são respostas reais, não suposição.

### Rotas

| Rota | Método | Autenticação | Permissão | Escopo |
|------|--------|--------------|-----------|--------|
| `/api/imoveis/{id}/` | GET | `Authorization: Token <chave>` | `EhCorretor` | queryset da empresa do usuário (mixin) |
| `/api/imoveis/{id}/situacao/` | POST | idem | `EhCorretor` + `pode_mudar_situacao` | idem |
| `/api/imoveis/{id}/historico/` | GET | idem | `EhCorretor` | idem; sem paginação |

URLs confirmadas por `reverse()`: `/api/imoveis/7/`, `/api/imoveis/7/situacao/`, `/api/imoveis/7/historico/` `[VERIFIED: manage.py shell no código da origin/main]`. **Barra final obrigatória**: o Dio autenticado tem `followRedirects: false`, então um POST sem `/` final tomaria 301 do `APPEND_SLASH` e falharia.

Decisões do servidor, na ordem em que acontecem num POST (verificado com a sonda "colega + corpo inválido" → 403, não 400):
1. 401 se não há token válido (`TokenAuthentication` primeiro → cabeçalho `WWW-Authenticate: Token`);
2. 403 se o usuário não é corretor (`EhCorretor`);
3. 404 se o imóvel não é da empresa dele (queryset filtrado) ou não existe — **mesmo corpo para os dois**;
4. 403 se `not imovel.pode_mudar_situacao(usuario)`;
5. 400 de validação do `MudancaSituacaoSerializer`;
6. 400 do `Imovel.mudar_situacao` (mesma situação, contrato assinado, situação inválida);
7. 200.

### `GET /api/imoveis/{id}/` — o que a tela lê

200 devolve o `ImovelSerializer` completo (26 chaves: `apartamento, caracteristicas, casa, codigo, corretor_responsavel, criado_em, descricao, endereco, finalidade, fotos, id, lote, natureza, pendencias_para_publicar, pode_mudar_situacao, pode_publicar, preco_aluguel, preco_condominio, preco_iptu, preco_venda, proprietario, publicado, situacao, situacao_desde, terreno, titulo`). **O app lê só 9:** `id`, `codigo`, `titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `situacao`, `situacao_desde`, `pode_mudar_situacao`. Chaves a mais são ignoradas pelo `json_serializable`; o Model **não** deve declarar `proprietario`, `descricao`, `endereco` etc. (menos superfície, menos dado sensível em memória).

Amostra real: `"preco_venda":"300000.00"` (string decimal, como no acervo), `"situacao":"DISPONIVEL"`, `"situacao_desde":"2026-11-22T02:03:05.244984-03:00"` (ISO 8601 com offset `-03:00` e microssegundos), `"pode_mudar_situacao":true`.

`ImovelSerializer.situacao_desde` e `pode_mudar_situacao`: [VERIFIED: `Web/imoveis/api/serializers.py:294-296`] — trecho citado: `situacao_desde = serializers.DateTimeField(read_only=True)` e `pode_mudar_situacao = serializers.SerializerMethodField()`.

Foto de capa: o `ImovelSerializer` tem `fotos` (lista de `{id, imovel, imagem, ordem, capa}`), mas **recomendo não parsear**: a tela recebe o `ImovelAcervo` do cartão e usa o `fotoCapa` dele (a capa já vem calculada pelo servidor na lista, `FotoCapaMixin`), como a prévia do DET-01.

### `POST /api/imoveis/{id}/situacao/`

Corpo JSON: `{"situacao": "RESERVADO", "observacao": "Reservado para o João"}`. `observacao` é opcional (default `""`).

Valores aceitos em `situacao` [VERIFIED: `Web/imoveis/models.py:63-67`]:
```
DISPONIVEL = "DISPONIVEL", "Disponível"
RESERVADO = "RESERVADO", "Reservado"
VENDIDO = "VENDIDO", "Vendido"
ALUGADO = "ALUGADO", "Alugado"
```
O app já tem o mapeamento exaustivo `codigoDaSituacao` [VERIFIED: `lib/data/datasources/parametros_consulta_acervo.dart:23-28`]: `SituacaoImovel.disponivel => 'DISPONIVEL'`, `reservado => 'RESERVADO'`, `vendido => 'VENDIDO'`, `alugado => 'ALUGADO'`. **Reusar** essa função (não duplicar o mapa).

A view [VERIFIED: `Web/imoveis/api/views.py:113-131`]: `@action(detail=True, methods=["post"], serializer_class=MudancaSituacaoSerializer)`, 403 com `"Só o corretor responsável por este imóvel ou o gestor podem mudar a situação."` e 400 com `{"situacao": erro.messages}`; 200 devolve `ImovelSerializer(...).data`.

Respostas capturadas:

| Caso | Status | Corpo real |
|------|--------|-----------|
| Sucesso | 200 | `ImovelSerializer` com `"situacao": "RESERVADO"`, `situacao_desde` novo, `pode_mudar_situacao` |
| Mesma situação | 400 | `{"situacao": ["O imóvel já está disponível."]}` |
| Contrato assinado | 400 | `{"situacao": ["Este imóvel tem um contrato assinado (#1): a situação não pode ser mudada à mão enquanto o contrato estiver valendo."]}` |
| Situação fora da lista | 400 | `{"situacao": ["\"DEMOLIDO\" não é uma escolha válida."]}` (minúscula `"reservado"` também recusa) |
| `situacao` ausente | 400 | `{"situacao": ["Este campo é obrigatório."]}` |
| `observacao: null` | 400 | `{"observacao": ["Este campo pode não ser nulo."]}` (**chave `observacao`, não `situacao`**) |
| Corpo não é objeto | 400 | `{"non_field_errors": ["Dado inválido. Esperava um dicionário, mas recebeu list."]}` |
| Não é o responsável (colega, mesma empresa) | 403 | `{"detail": "Só o corretor responsável por este imóvel ou o gestor podem mudar a situação."}` |
| Gestor/admin nesta rota | 403 | `{"detail": "Este recurso é restrito ao corretor."}` |
| Sem token / token revogado | 401 | `{"detail": "As credenciais de autenticação não foram fornecidas."}` + `WWW-Authenticate: Token` |
| Imóvel de outra empresa ou inexistente | 404 | `{"detail": "No Imovel matches the given query."}` — **em inglês** |
| `GET` na rota | 405 | — |

Fatos adicionais medidos: `observacao` só com espaços vira `''` no histórico (o DRF faz `trim`); a rota também aceita `multipart`; **observação de 100 000 caracteres foi aceita (200)** — sem limite no servidor.

### `GET /api/imoveis/{id}/historico/`

Lista simples (sem envelope, sem paginação). Cada item [VERIFIED: `Web/imoveis/api/serializers.py:370-377`]: `fields = ["id", "situacao_anterior", "situacao_nova", "alterado_por", "alterado_em", "observacao"]`, com `alterado_por = serializers.CharField(source="alterado_por.nome", read_only=True)` (nome, não id).

Ordem [VERIFIED: `Web/imoveis/models.py:688-691`]: `ordering = ["-alterado_em", "-id"]` (mais recente primeiro; `id` desempata).

Exemplo real:
```json
[
  {
    "id": 1,
    "situacao_anterior": "DISPONIVEL",
    "situacao_nova": "RESERVADO",
    "alterado_por": "Corretor Teste",
    "alterado_em": "2026-11-22T02:00:37.259695-03:00",
    "observacao": "Reservado para o João"
  }
]
```
Sem histórico: `[]`. Uma mudança feita pela assinatura de contrato aparece no histórico com observação automática (`"Contrato #1 de venda assinado em 21/11/2026."`) — o app só mostra texto.

O colega (mesma empresa, não responsável) **pode ler** o histórico (200) e o detalhe com `pode_mudar_situacao: false` — consistente com D-04.

### Quem pode mudar (regra do servidor)

[VERIFIED: `Web/imoveis/models.py:204-212`]:
```python
def pode_mudar_situacao(self, usuario):
    ...
    if usuario is None or usuario.empresa_id != self.empresa_id:
        return False
    if usuario.perfil == Usuario.Perfil.GESTOR:
        return True
    return usuario.perfil == Usuario.Perfil.CORRETOR and usuario.pk == self.corretor_responsavel_id
```
O gestor muda pelas rotas `/api/gestao/imoveis/{id}/situacao|historico/` (`GestaoImovelViewSet`, `EhGestor`), **fora desta fase** (D-07). Na rota do corretor o gestor toma 403.

### Datas e fuso

`TIME_ZONE = 'America/Sao_Paulo'` e `USE_TZ = True` (`config/settings.py`); a API serializa com offset. No Dart, `DateTime.parse('2026-11-22T02:00:37.259695-03:00')` devolve UTC (`isUtc == true`); `.toLocal()` usa o fuso do aparelho. `DateFormat('dd/MM/yyyy HH:mm')` **sem locale** funciona; `DateFormat('...', 'pt_BR')` lança `LocaleDataException` se `initializeDateFormatting` não foi chamado `[VERIFIED: dart run local nesta sessão]`.

## Lacunas de teste no Django (D-08)

Resultado da conferência em `origin/main`: **nenhuma lacuna de código/campo**; lacunas só de teste para a rota do **corretor** (as do gestor e do painel já têm). Linha de base: `manage.py test` na cópia da `origin/main` = **743 testes OK** `[VERIFIED: execução local]`; `CorretorMudaSituacaoTests` + `ApiGestaoTests` = 27 OK.

Já coberto (em `Web/imoveis/tests.py`): corretor responsável muda e lê histórico (`test_api_corretor_responsavel_muda_situacao`), colega 403 (`test_api_colega_recebe_403`), outra empresa 404 no POST (`test_api_imovel_de_outra_empresa_da_404`), `pode_mudar_situacao` true/false (`test_api_informa_se_pode_mudar_a_situacao`), PATCH não muda situação, regra de quem pode (`test_quem_pode_mudar_a_situacao`), e (via gestor) mesma situação/400 + histórico (`ApiGestaoTests`), contrato assinado 400 (`contratos/tests.py::TravaDaSituacaoManualTests.test_api_da_w08_recusa`, só na rota do gestor).

**Falta (e o app depende disso):**

| # | Teste que falta | Rota | Por que importa |
|---|-----------------|------|-----------------|
| L1 | 400 "O imóvel já está …" | `imovel-situacao` (corretor) | AC-4: mensagem que o app exibe |
| L2 | 400 contrato assinado | `imovel-situacao` (corretor) | AC-4: caso de UAT; hoje só na rota do gestor |
| L3 | 400 situação inválida/ausente (`{"situacao": [...]}`) | `imovel-situacao` | O app achata qualquer chave; trava o formato |
| L4 | 401 sem token em POST situação e GET histórico/detalhe | ambas | AC-6/V4: trava o contrato de sessão |
| L5 | 404 de histórico (e detalhe) de outra empresa | `imovel-historico` | Isolamento multitenant (V4/IDOR) |
| L6 | Histórico na ordem mais recente primeiro, com `alterado_por` = nome | `imovel-historico` | D-11 depende da ordem do servidor |
| L7 | Precedência: colega + corpo inválido = 403 (não 400) | `imovel-situacao` | AC-6: recusa de permissão não vaza validação |
| L8 | (opcional, hardening) `observacao` com limite | `MudancaSituacaoSerializer` | 100 000 caracteres aceitos hoje; exige OK da equipe web |

Recomendação: criar `feat/APP09` na web **a partir da `origin/main`** com uma classe `AppSituacaoApiTests` (L1–L7; L8 só se a equipe aceitar). Cuidado operacional: o clone local `../imoveis-aqui` está na `feat/APP06` com árvore limpa; **trocar de branch nele altera o que o usuário vê/roda**, então é um `checkpoint` com autorização explícita (commits locais liberados, push não, D-08). Para rodar/capturar sem mexer no clone, extrair a `origin/main` com `git archive origin/main Web | tar -x -C <pasta-temporária>` (testado nesta sessão, usa o `.venv` do clone sem alterá-lo).

**Armadilha de branch (importante):** a `feat/APP06` local tem 0 ocorrências de `pode_mudar_situacao` e 0 de `ImovelAcervoSerializer` (é anterior à APP08 e à situação do corretor), e tem 2 commits (`420bcaf` canais_contato, `7d4f5cd`) que a `origin/main` ainda não tem `[VERIFIED: git show/grep nos dois refs]`. Logo: **UAT e captura da Phase 9 precisam do código da `origin/main`** (ou da `feat/APP09`), não do clone como está. O contato por canais (APP06) fica sem `canais_contato` nesse servidor, o que só afeta o botão de contato da página pública (não é escopo da fase).

## Architecture Patterns

### System Architecture Diagram

```
Cartão do acervo ──toque──► abrirGestaoImovel(context, ImovelAcervo)
 (todo cartão, D-02)          │  cria GestaoImovelCubit, push da tela, aguarda o pop
                              ▼
                    GestaoImovelScreen (prévia do cartão aparece na hora)
                              │ carregar(id): em paralelo
              ┌───────────────┴────────────────┐
              ▼                                ▼
   ObterImovelGestaoUseCase          ObterHistoricoSituacaoUseCase
              │                                │
              └──► GestaoImovelRepository ◄────┘   (traduz status → falhas tipadas)
                              │
                   GestaoImovelRemoteDataSource ── Dio 'autenticado' (Token só na origem da API)
                              │
        GET /api/imoveis/{id}/        GET /api/imoveis/{id}/historico/
                              │ (401 → SessaoExpiradaException → login)
                              ▼
   pode_mudar_situacao == true? ──sim──► botão "Mudar situação"
                                              │ toque
                                              ▼
                  showModalBottomSheet (enableDrag:false, PopScope enquanto envia)
                  MudarSituacaoCubit: escolher(situação≠atual) → confirmar()
                                              │
                              MudarSituacaoUseCase → Repository
                                              │ POST /api/imoveis/{id}/situacao/
              ┌───────────────┬───────────────┼──────────────────┬───────────────┐
              ▼               ▼               ▼                  ▼               ▼
           200 ok       400/403 recusa     401 sessão        404 não achou    rede/5xx
        fecha a folha   folha ABERTA,      volta ao login    texto fixo da    texto fixo
        SnackBar +      msg do servidor,   (Fase 8)          tela             "Tente de novo"
        recarrega       observação mantida
        imóvel+histórico
              │
              └─► estado `mudou = true` ──pop──► AcervoScreen recarrega da API (busca+situação mantidas)
                                                       │
                                  vitrine pública já consulta o servidor a cada abertura (AC-5)
```

### Recommended Project Structure
```
lib/
├── domain/
│   ├── entities/imovel_gestao.dart              # id, codigo, titulo, finalidade, precos, situacao?, situacaoDesde, podeMudarSituacao
│   ├── entities/mudanca_situacao.dart           # item do histórico
│   ├── repositories/gestao_imovel_repository.dart   # interface + falhas (MudancaSituacaoRecusadaException)
│   └── usecases/{obter_imovel_gestao,obter_historico_situacao,mudar_situacao}_usecase.dart
├── data/
│   ├── models/{imovel_gestao_model,mudanca_situacao_model}.dart   # freezed + json
│   ├── datasources/gestao_imovel_{datasource,remote_datasource}.dart
│   └── repositories/gestao_imovel_repository_impl.dart
└── presentation/
    ├── gestao_imovel/
    │   ├── gestao_imovel_{cubit,state,screen}.dart
    │   ├── mudar_situacao_{cubit,state}.dart
    │   ├── apresentacao_gestao.dart             # textos fixos, formatarDataHora, mensagem de falha
    │   └── widgets/{cabecalho_gestao,secao_situacao,historico_situacao,mudar_situacao_sheet}.dart
    └── acervo/ (muda: cartão sempre toca; AcervoScreen abre a gestão; AcervoCubit.recarregar)
test/
├── fixtures/api/{imovel_gestao_*,situacao_200,historico_*,erro_400_*,erro_403_situacao,erro_404_imovel}.json   # capturadas
├── support/api_falsa.dart                       # + 3 rotas
└── data|domain|presentation/…                   # ver Validation Architecture
tool/capturar_fixtures_api.py                    # + grupo `situacao`
```

### Pattern 1: DataSource autenticado fino + Repository que traduz (modelo: `AcervoRemoteDataSource` / `AcervoRepositoryImpl`)
**What:** o DataSource usa o Dio `@Named('autenticado')`, não captura `DioException`, não loga; o Repository tem cadeia única de tradução (sessão expirada primeiro, depois status, depois `TypeError`, depois `Exception`).
**When to use:** as três rotas. A rota é montada com `id` **inteiro** (`'/api/imoveis/$id/situacao/'`), nunca com texto livre.
```dart
// Source: padrão de lib/data/datasources/acervo_remote_datasource.dart (Phase 8)
@override
Future<void> mudarSituacao(int id, SituacaoImovel nova, String observacao) async {
  await _dio.post<Object?>(
    '/api/imoveis/$id/situacao/',
    data: {
      'situacao': codigoDaSituacao(nova),
      if (observacao.trim().isNotEmpty) 'observacao': observacao.trim(),
    },
  );
}
```
Sem `observacao` quando vazia (o servidor assume `""`); nunca mandar `null` (400 na chave `observacao`).

### Pattern 2: Cubit da tela com versão de consulta e `isClosed` (modelo: `AcervoCubit`)
**What:** estado freezed com duas seções independentes — imóvel (`carregando | carregado | erro | naoEncontrado | sessaoExpirada`) e histórico (`carregando | carregado | erro`) — mais `mudou` (bool). Carga em paralelo com `Future.wait`; falha só do histórico mantém imóvel e botão e mostra "Tentar de novo" no histórico; falha do imóvel esconde o botão (não sabe `pode_mudar_situacao`).
**Regras:** token de versão (`++_versao`) descarta respostas obsoletas (puxar para atualizar sobreposto à recarga pós-sucesso); `isClosed` antes de todo `emit`; recarga pós-sucesso **mantém o conteúdo atual visível** (sem spinner de tela cheia).

### Pattern 3: Folha com Cubit próprio, fora do `BlocProvider` da tela (modelo: `contato_bottom_sheet.dart`)
O código do projeto já documenta: "a rota do modal fica fora do `BlocProvider`, então o sheet nunca lê o Cubit diretamente". Logo, a tela captura o Cubit da folha antes de abrir e o injeta com `BlocProvider.value` dentro do `builder`.
```dart
// Source: padrão do projeto + verificação no SDK (modal_barrier.dart:224-231, bottom_sheet.dart:769-773)
Future<void> mostrarMudarSituacaoSheet(BuildContext context, {required MudarSituacaoCubit cubit, required SituacaoImovel atual}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,   // teclado + campo de texto
    enableDrag: false,          // o arrasto chama Navigator.pop direto e ignora PopScope
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MudarSituacaoCubit, MudarSituacaoState>(
        builder: (context, state) => PopScope(
          canPop: !state.enviando,          // toque na barreira e botão voltar usam maybePop → respeitam PopScope
          child: _ConteudoDaFolha(atual: atual),
        ),
      ),
    ),
  );
}
```
`ModalBarrier` chama `Navigator.maybePop` ao toque `[VERIFIED: /opt/homebrew/share/flutter/packages/flutter/lib/src/widgets/modal_barrier.dart:224-231]` (respeita `PopScope`), mas o `BottomSheet.onClosing` chama `Navigator.pop` direto `[VERIFIED: .../material/bottom_sheet.dart:769-773]` (não respeita), por isso `enableDrag: false`.
- Chips: `ChoiceChip` (como `ChipsSituacao`); o da situação atual com `onSelected: null` (desabilitado). Confirmar (`FilledButton`) desabilitado até haver escolha ≠ atual e durante o envio (mostra `CircularProgressIndicator`).
- `TextField` da observação com `maxLength` (ver Pitfall 5), `hintText: 'Ex.: reservado para o cliente João até a assinatura.'`; o `TextEditingController` mora no `State` da folha, então **sobrevive à recusa** (a folha não fecha).
- Recusa: texto de erro abaixo do campo (usar `colorScheme.error`), `Text` simples (nunca `Text.rich`/HTML), com `maxLines`/`overflow` para mensagem hostil longa.
- Sucesso: a folha fecha (`Navigator.pop` pelo `BlocListener` da folha), a tela mostra o `SnackBar` e chama `recarregar()`.

### Pattern 4: Falhas tipadas (extensão de `falhas_autenticacao.dart`)
| Status | Falha de domínio | O que a UI faz |
|--------|------------------|----------------|
| 400, 403 | **nova** `MudancaSituacaoRecusadaException(String mensagem)` (achatar `detail` e todas as listas do corpo; se vazio → cair em `FalhaDeConexaoException`) | folha aberta + mensagem do servidor |
| 401 | `SessaoExpiradaException` (já vem do interceptor dentro de `DioException.error`) | `SessaoCubit.encerrarPorExpiracao()` + `pushAndRemoveUntil(LoginScreen(aviso: avisoSessaoTerminou), eRotaDaVitrine)` |
| 404 | `ImovelNaoEncontradoException` (já existe) | texto **fixo** em português (o do servidor é inglês) |
| rede/timeout/5xx/JSON ruim | `FalhaDeConexaoException` (já existe) | "Não foi possível mudar a situação agora. Tente de novo." |
Achatar: `detail` (String) + todo valor `List<String>` de qualquer chave (`situacao`, `observacao`, `non_field_errors`), unidos por espaço. Mensagem recebida do servidor passa só por `trim` e corte de tamanho; nunca é usada como lógica.

### Pattern 5: Abertura devolve `bool` pelo Cubit, não pelo `pop` (decisão de implementação sugerida)
O D-12 diz "devolve 'mudou' no `pop`". Para funcionar também com o botão voltar do sistema e o gesto de voltar do iOS (que não passam resultado), o **abridor** guarda o Cubit:
```dart
Future<bool> abrirGestaoImovel(BuildContext context, ImovelAcervo imovel, {GestaoImovelCubit Function()? criarCubit}) async {
  final cubit = (criarCubit ?? () => getIt<GestaoImovelCubit>())()..carregar(imovel.id);
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => BlocProvider.value(value: cubit, child: GestaoImovelScreen(imovel: imovel)),
  ));
  final mudou = cubit.state.mudou;
  await cubit.close();
  return mudou;
}
```
`AcervoScreen` ganha o parâmetro `aoAbrirGestao` (padrão `abrirGestaoImovel`, injetável para teste, como o `aoAbrirImovel` de hoje) e, se `true`, chama `AcervoCubit.recarregar()`. **Não** usar `PopScope(canPop:false)` na tela de gestão: ele desliga o gesto de voltar do iOS.
`AcervoCubit.recarregar()` = `_aplicarConsulta(state.termoBusca, state.situacao)` (mantém busca e chip; volta ao topo e mostra o carregando, aceito pelo D-12; ver Open Question 5). `mudou` vira `true` **assim que o POST responde 200**, mesmo que a recarga seguinte falhe.

### Anti-Patterns to Avoid
- **Montar o estado novo no app** depois do POST (violaria AC-2): sempre reler imóvel e histórico.
- **Olhar `publicado`/`situacao` para decidir "Ver na vitrine" ou o botão:** só `na_vitrine` (do cartão) e `pode_mudar_situacao`.
- **Exibir `detail` do 404 ou qualquer corpo de 5xx:** o 404 é inglês, o 5xx é HTML/depuração.
- **`try/catch` na UI** ou `Dio` direto em widget/Cubit.
- **Parsear o `ImovelSerializer` inteiro:** declarar só as 9 chaves.
- **Duplicar o mapa situação↔código:** reusar `codigoDaSituacao` e `rotuloSituacao`; o enum `SituacaoImovel` é o único lugar.
- **Chamar `getIt` em `build`:** só no toque (padrão `abrirDetalheImovel`).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Token e origem | Anexar `Authorization` à mão | Dio `@Named('autenticado')` + `InterceptadorSessao` | Já faz compare-and-delete no 401 e só envia à origem da API |
| 401 → login | Novo fluxo de sessão expirada | `SessaoCubit.encerrarPorExpiracao` + `pushAndRemoveUntil(... eRotaDaVitrine)` (como `_aoSessaoExpirar` do `AcervoScreen`) | Extrair um helper compartilhado em vez de copiar |
| Rótulo/código da situação | Novo `switch` | `rotuloSituacao`, `codigoDaSituacao` | Exaustivos: situação nova no enum quebra a compilação |
| Linhas de preço | Formatação própria | `linhasDePrecoPorFinalidade` / `linhasDePreco` | Já trata "Preço sob consulta" |
| Foto/placeholder | `Image.network` | `ImagemRede` (`urlHttpOuNula` filtra esquema) | Defesa de esquema e placeholder |
| Data pt-BR | `intl` com locale | `DateFormat('dd/MM/yyyy HH:mm')` sem locale, sobre `DateTime.toLocal()` | Locale `pt_BR` exigiria `initializeDateFormatting` |
| Regra "pode mudar?" | `meuImovel`, perfil, empresa | `pode_mudar_situacao` do servidor | Regra do `Imovel`, inclusive gestor |
| Fila/retry de POST | Reenvio automático | Nada (retry é explícito pelo usuário) | POST não é idempotente no cliente; o servidor recusa o repetido (400 "já está …") |

**Key insight:** o servidor já é a única porta de decisão (`mudar_situacao`) e já devolve mensagens em português para as recusas de negócio. O app é só "pedir, esperar, mostrar a mensagem e reler".

## Common Pitfalls

### Pitfall 1: Servidor do UAT/captura na branch errada
**What goes wrong:** subir o Django do clone local (`feat/APP06`) e as rotas desta fase não existem (sem `pode_mudar_situacao`, sem acervo) — o app quebra de formas confusas.
**How to avoid:** servidor = `origin/main` (extraída com `git archive` em pasta temporária ou `feat/APP09` da web criada da `main`). **Warning signs:** `GET /api/imoveis/` devolve lista em vez de envelope; detalhe sem `pode_mudar_situacao`.

### Pitfall 2: `na_vitrine` fica velho depois da mudança
**What goes wrong:** a tela recebe `naVitrine` do cartão; depois de reservar um imóvel publicado, o botão "Ver na vitrine" continua visível e leva a um 404 público (que o DET-06 trata com "Este imóvel não está mais disponível", mas é confuso). O `ImovelSerializer` **não** tem `na_vitrine`.
**How to avoid (recomendado, a confirmar):** após qualquer 200, o estado marca `naVitrineConhecido = false` e o botão some até a tela ser reaberta pelo acervo recarregado. Isso não é decisão de negócio (o app não deduz `na_vitrine`, só deixa de oferecer um dado que sabe estar velho). Alternativa mais cara: reconsultar `GET /api/imoveis/?busca=<codigo>` e filtrar por `id`.

### Pitfall 3: POST deu certo, a recarga falhou
**What goes wrong:** o servidor mudou, mas a tela mostra a situação antiga e o botão; o acervo não recarrega ao voltar porque `mudou` ficou `false`.
**How to avoid:** `mudou = true` no 200 do POST, independente da recarga; recarga com falha mostra "Tentar de novo"/puxar para atualizar sem apagar o conteúdo anterior; SnackBar de sucesso aparece de qualquer forma.

### Pitfall 4: Timeout/queda no POST é ambíguo
**What goes wrong:** o POST pode ter gravado no servidor mesmo com `receiveTimeout` (10 s) estourado; o usuário vê "Tente de novo", repete e recebe 400 "O imóvel já está reservado." — correto, mas parece defeito.
**How to avoid:** manter o texto fixo do D-10 (decidido), sem retry automático; o 400 do segundo toque já explica. O puxar para atualizar corrige a tela. Registrar no UAT.

### Pitfall 5: Observação sem limite no servidor
**What goes wrong:** 100 000 caracteres foram aceitos (200) e vão para `HistoricoSituacao.observacao` (`TextField`) e para o histórico no celular.
**How to avoid:** `TextField(maxLength: …)` na folha (sugestão **500**, `[ASSUMED]`, decisão de produto) e, se a equipe web aceitar, `max_length` no `MudancaSituacaoSerializer` (L8). O histórico exibe a observação com quebra de linha normal (sem `maxLines` que esconda conteúdo legítimo, ou com "ver mais" se preferirem).

### Pitfall 6: 400 com chave diferente de `situacao`
**What goes wrong:** achatar só `body['situacao']` perde `observacao`/`non_field_errors`/`detail`.
**How to avoid:** percorrer **todos** os valores do mapa (listas de strings) + `detail`; vazio → texto fixo de rede (regra do discretion). Testar com as fixtures dos três formatos.

### Pitfall 7: Barra final e redirecionamento
`followRedirects: false` + POST sem `/` final = 301 sem seguir (falha). Sempre `/api/imoveis/$id/situacao/`.

### Pitfall 8: Data/hora e fuso nos testes
**What goes wrong:** `DateTime.parse(...)` vem em UTC; formatar sem `.toLocal()` mostra 05:00 em vez de 02:00; testes que comparam texto fixo quebram em máquinas com outro fuso.
**How to avoid:** `formatarDataHora(DateTime)` pura que recebe um `DateTime` e chama `.toLocal()`; no teste de widget calcular o esperado com a mesma função a partir da fixture (ou usar `DateTime(2026, 11, 22, 14, 30)` local direto no teste da função). Nunca `DateFormat(..., 'pt_BR')` sem `initializeDateFormatting`. O "desde" mostra o fuso do aparelho (o site mostra America/Sao_Paulo); para corretor no Brasil é o mesmo `[ASSUMED]`.

### Pitfall 9: Testes e requisitos antigos que a mudança do cartão quebra
`CartaoImovelAcervo` hoje só tem `InkWell` com `naVitrine` (linhas 35-46 do arquivo). Mudam: `test/presentation/cartao_imovel_acervo_test.dart` (grupo "toque (D-07)", casos "sem naVitrine: não há InkWell…"), `test/presentation/acervo_screen_test.dart` (grupo "toque no cartão (D-07)", uso de `aoAbrirImovel`) e `test/presentation/acervo_fluxo_test.dart`. O `ACV-04` do `REQUIREMENTS.md` ("O toque num cartão do acervo só abre a página do imóvel quando o servidor diz que ele está na vitrine") fica **superado** e precisa de nota/emenda junto do SIT-07.

### Pitfall 10: Toque duplo no Confirmar
Cubit ignora `confirmar()` com `enviando == true` (como `ContatoCubit`); botão desabilitado; nenhuma nova tentativa automática.

### Pitfall 11: Estados órfãos ao fechar
`isClosed` antes de `emit` (resposta chegando depois do `pop`); o abridor fecha o Cubit depois de ler `mudou`; a folha descarta o `TextEditingController` no `dispose`.

## Code Examples

### Achatar a mensagem de recusa (camada de dados)
```dart
// Source: derivado das respostas reais capturadas (§Contrato) — pura e testável
String? mensagemDeRecusa(Object? corpo) {
  if (corpo is! Map<String, dynamic>) return null;
  final partes = <String>[];
  for (final valor in corpo.values) {
    if (valor is String) partes.add(valor.trim());
    if (valor is List) partes.addAll(valor.whereType<String>().map((s) => s.trim()));
  }
  final texto = partes.where((s) => s.isNotEmpty).join(' ');
  if (texto.isEmpty) return null;
  return texto.length > 300 ? '${texto.substring(0, 300)}…' : texto;
}
```

### Repository: tradução de status
```dart
// Source: padrão de AcervoRepositoryImpl/ContatoRepositoryImpl (Phase 6/8)
Future<Result<void>> _pedir(Future<void> Function() acao) async {
  try {
    await acao();
    return Result.success(null);
  } on DioException catch (erro) {
    if (erro.error is SessaoExpiradaException) return Result.failure(const SessaoExpiradaException());
    final status = erro.response?.statusCode;
    if (status == 400 || status == 403) {
      final mensagem = mensagemDeRecusa(erro.response?.data);
      return Result.failure(mensagem == null
          ? const FalhaDeConexaoException()
          : MudancaSituacaoRecusadaException(mensagem));
    }
    if (status == 404) return Result.failure(const ImovelNaoEncontradoException());
    return Result.failure(const FalhaDeConexaoException());
  } on TypeError {
    return Result.failure(const FalhaDeConexaoException());
  } on Exception {
    return Result.failure(const FalhaDeConexaoException());
  }
}
```

### Model do detalhe (só as 9 chaves) e data
```dart
@freezed
abstract class ImovelGestaoModel with _$ImovelGestaoModel {
  const factory ImovelGestaoModel({
    required int id,
    required String codigo,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    String? situacao,
    @JsonKey(name: 'situacao_desde') required String situacaoDesde,   // ISO 8601 com offset
    @JsonKey(name: 'pode_mudar_situacao') required bool podeMudarSituacao,
  }) = _ImovelGestaoModel;
  factory ImovelGestaoModel.fromJson(Map<String, Object?> json) => _$ImovelGestaoModelFromJson(json);
}
// paraEntidade(): DateTime.parse(situacaoDesde) (FormatException → falha genérica);
// reaproveitar o mapeamento string→SituacaoImovel? (desconhecido vira null) e _mapearFinalidade do ImovelAcervoModel.
```
```dart
// Apresentação (pura): hora local do aparelho, sem locale (verificado nesta sessão)
String formatarDataHora(DateTime momento) => DateFormat('dd/MM/yyyy HH:mm').format(momento.toLocal());
```

### ApiFalsa: três rotas novas (e override por teste)
`ApiFalsa._atender` ganha, depois do `GET /api/imoveis/`: `GET /api/imoveis/<id>/` (token obrigatório, senão 401 `erro_401.json`; serve `imovel_gestao_<…>.json` cujo `id` bate, senão 404 com `erro_404_imovel.json`), `GET /api/imoveis/<id>/historico/` (`historico_vazio.json` por padrão) e `POST /api/imoveis/<id>/situacao/` (200 com `situacao_200.json`). Fluxos de recusa/sucesso usam o `responder(...)` existente, que vale "a última registrada": registrar a troca da fixture de detalhe/histórico **antes de tocar em Confirmar** simula o estado novo vindo do servidor.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Cartão do acervo só reage com `na_vitrine` (F8/D-07, ACV-04) | Todo cartão abre a tela de gestão; "Ver na vitrine" condicional | Esta fase (D-02) | Atualizar testes e ACV-04 |
| App só lê (GET) | Primeira escrita autenticada (POST) | Esta fase | Cuidado com duplo envio, resposta ambígua e preservação do texto |
| Gestor/corretor mudavam situação só no painel web | Corretor muda pelo app; gestor segue na web/APP-12 | WEB 08 (Feito) | Rotas `/api/gestao/...` ficam fora |

**Deprecated/outdated:** `Imovel.publicar` na rota do corretor (saiu na W08: 404); `ACV-04` como escrito.

## Runtime State Inventory

Não se aplica: a fase não renomeia, refatora em massa nem migra dados. (Verificado: nenhuma string/registro externo é renomeado; o histórico novo vive no banco do Django e nada é guardado no aparelho além do token já existente.)

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `maxLength` de 500 caracteres na observação | Pitfall 5 | Decisão de produto; limite menor/maior muda só a UI (o servidor não limita) |
| A2 | Após 200, esconder "Ver na vitrine" (`naVitrineConhecido=false`) até reabrir | Pitfall 2 | Se o usuário preferir manter o botão, a página pública cai no 404 já tratado (DET-06) |
| A3 | Mostrar data/hora no fuso do aparelho (`toLocal`) | Pitfall 8 | Corretor com aparelho em outro fuso vê hora diferente da do site |
| A4 | O padrão "abridor devolve `bool` lido do Cubit" cobre botão voltar do Android e gesto do iOS | Pattern 5 | Se falhar em teste de widget, usar `PopScope` com `onPopInvokedWithResult` só no Android; coberto por teste de navegação |
| A5 | Cubit separado para a folha | Pattern 3 | Discricionário (CONTEXT permite um Cubit só); só muda a organização dos testes |
| A6 | IDs de requisito `SIT-01..07`, `API-11`, `API-12` | Phase Requirements | Só nomenclatura (D-14 deixa para o planejador) |
| A7 | `max_length` no serializer da web (L8) é aceitável para a equipe web | Lacunas L8 | Mudança de contrato na web exige OK deles; é opcional |
| A8 | UAT visual pode usar o simulador iOS (`iPhone 17`) ou o AVD `Medium_Phone` | Environment | `adb` não está no PATH (existe em `~/Library/Android/sdk/platform-tools`); ajustar PATH ou usar o iOS |

## Open Questions

1. **O que fazer com `na_vitrine` velho depois da mudança?** (Pitfall 2)
   - Sabemos: o `ImovelSerializer` não traz `na_vitrine`; o cartão traz o valor do instante da lista.
   - Falta: preferência do usuário (esconder o botão até reabrir, ou deixar e confiar no 404 tratado).
   - Recomendação: esconder (A2), registrar no UAT.
2. **Limite da observação (A1) e se a web ganha `max_length` (L8).**
   - Recomendação: `maxLength` 500 no app já nesta fase; L8 só como pergunta à equipe web, fora do caminho crítico.
3. **Texto do SnackBar para "disponível".** O site usa `get_situacao_display().lower()` → "Situação alterada para disponível." (mesma regra do D-10). Sem dúvida técnica; confirmar só se o texto soar estranho.
4. **Branch do servidor para a UAT e para o trabalho da web.** O clone está na `feat/APP06` (sem as rotas). Recomendação: extrair a `origin/main` para capturas/UAT e, para a `feat/APP09`, pedir autorização antes de trocar a branch do clone (ou criar um segundo clone/worktree da web).
5. **Recarga do acervo volta ao topo e mostra o carregando** (reuso de `_aplicarConsulta`). Aceito pelo D-12 (a lista pode mudar de ordem/filtro); se quiserem manter a posição, é um `recarregar()` mais elaborado (não recomendado).
6. **Gestor:** continua no aviso (D-07). Nenhuma ação.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter / Dart | Código, testes, analyze | ✓ | Flutter 3.47.5, Dart ^3.13.4 | — |
| `build_runner` (via pub) | freezed/json/injectable | ✓ | ^2.16.1 | — |
| Python 3 (sistema) | `tool/capturar_fixtures_api.py` (só stdlib) | ✓ | 3.9.6 | — |
| Python do Django (`../imoveis-aqui/Web/.venv`) | `manage.py test`, `migrate`, seeds, runserver | ✓ | 3.13.18; Django 5.2.17, DRF 3.18.1 | — |
| Código da `origin/main` do Django | UAT, captura, base da `feat/APP09` | ✓ (via `git archive`) | `8bf4448` | — |
| SQLite | Banco temporário de captura/UAT | ✓ | embutido | — |
| Simulador iOS | UAT visual | ✓ | iPhone 17 (iOS 26.x), desligado | AVD Android |
| Android SDK / AVD | UAT no emulador (`10.0.2.2`) | ✓ (SDK + AVD `Medium_Phone`) | — | `adb` fora do PATH: usar `~/Library/Android/sdk/platform-tools/adb` |
| Dados de seed para os cenários da UAT | AC-4, AC-6 | ✓ | `semear_vitrine_dev` + `seed_demo` | — |

Cenários de UAT **já cobertos pelos seeds** (conferido rodando os dois comandos num SQLite temporário):
- **Corretor responsável, imóvel da vitrine:** `corretor.vitrine.demo@example.com` (senha inutilizável de fábrica; definir uma descartável pelo `manage.py shell` lendo `os.environ`, como no docstring do `tool/`) responsável por 35 imóveis `DEV-*` publicados e disponíveis → reservar/voltar prova AC-1, AC-3 e AC-5 na vitrine.
- **Corretor da mesma empresa que NÃO é o responsável (sem botão, e 403 se forçar):** `DEV-CAMPINAS-14` tem como responsável o corretor **desativado** (`is_active=False`) da empresa demo `[VERIFIED: manage.py shell]`; o corretor demo ativo vê esse imóvel no acervo com `meu_imovel=false` e `pode_mudar_situacao=false`. **Não é preciso criar usuário.**
- **Contrato assinado (400 com mensagem do servidor):** `corretor@demo.com` / `SenhaForte123` (empresa "Imobiliaria Demo") é responsável por `DEMO-CASA-01`, que nasce `VENDIDO` com contrato assinado e fora da vitrine `[VERIFIED: shell]`; mudar para Disponível dá o 400 do contrato.
- **Outra empresa (404):** o corretor de uma das duas empresas tentando um id da outra.

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** `adb` no PATH (caminho completo no SDK).

Para o emulador Android o Django precisa de `10.0.2.2` em `ALLOWED_HOSTS`, como na Phase 8; no simulador iOS usar `--dart-define=API_BASE_URL=http://127.0.0.1:8000` (README).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | App: `flutter_test` (Flutter 3.47.5) + `bloc_test ^10.0.0` + `mocktail ^1.0.5`. Web: Django `manage.py test` (Django 5.2.17 + DRF 3.18.1, `APITestCase`) |
| Config file | App: `analysis_options.yaml` (`flutter_lints`). Web: nenhum extra |
| Quick run command (app) | `flutter test test/<arquivo>_test.dart` |
| Full suite (app) | `flutter analyze lib` + `flutter test` (linha de base **1194 testes**, ~56 s, `analyze` limpo — medidos hoje) |
| Quick run (web) | `cd ../imoveis-aqui/Web && DATABASE_URL="sqlite://:memory:" DJANGO_SECRET_KEY=x DEBUG=True .venv/bin/python manage.py test imoveis.tests.<Classe> --noinput` |
| Full suite (web) | idem sem classe (linha de base **743 testes** na `origin/main`, ~9 s) |

Observação: rodar o web **na branch/commit da `origin/main`** (a `feat/APP06` local não tem as rotas).

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SIT-01 | Folha: chips (atual desabilitado), Confirmar só com escolha ≠ atual, corpo do POST (`situacao` em código, `observacao` só se houver) | widget + datasource | `flutter test test/presentation/mudar_situacao_sheet_test.dart test/data/gestao_imovel_remote_datasource_test.dart` | ❌ Wave 0 |
| SIT-01 | Data/hora `dd/MM/yyyy HH:mm` | unit | `flutter test test/presentation/apresentacao_gestao_test.dart` | ❌ Wave 0 |
| SIT-02 | Depois do 200 recarrega imóvel e histórico (2 GETs) e não altera estado antes; `mudou=true` mesmo se a recarga falhar | bloc_test | `flutter test test/presentation/gestao_imovel_cubit_test.dart` | ❌ Wave 0 |
| SIT-03 | Histórico: de→para, data·autor, observação, vazio com o texto do site, ordem do servidor | widget + model | `flutter test test/presentation/historico_situacao_test.dart test/data/mudanca_situacao_model_test.dart` | ❌ Wave 0 |
| SIT-04 | 400/403 → folha aberta com mensagem e observação preservada; rede/5xx → texto fixo; 401 → login com aviso; 404 → texto fixo | bloc_test + repo + fluxo | `flutter test test/presentation/mudar_situacao_cubit_test.dart test/data/gestao_imovel_repository_impl_test.dart test/presentation/gestao_imovel_fluxo_test.dart` | ❌ Wave 0 |
| SIT-05 | Acervo recarrega ao voltar com `mudou`, mantendo busca e chip; sem `mudou` não recarrega | bloc_test + widget | `flutter test test/presentation/acervo_cubit_test.dart test/presentation/acervo_screen_test.dart` | ✅ (estender) |
| SIT-05 | Vitrine reflete a mudança | UAT manual (servidor decide) | roteiro de UAT (reservar → some da vitrine; voltar → reaparece) | manual-only: depende do Django real |
| SIT-06 | Botão só com `pode_mudar_situacao`; colega sem botão; 403 forçado mostra mensagem | widget + fluxo | `flutter test test/presentation/gestao_imovel_screen_test.dart` | ❌ Wave 0 |
| SIT-06 | Servidor: 403 colega, 404 outra empresa, 401 sem token, precedência 403>400 | Django | `manage.py test imoveis.tests.AppSituacaoApiTests` | ❌ Wave 0 (web) |
| SIT-07 | Todo cartão toca; "Ver na vitrine" só com `na_vitrine` e some após mudança | widget | `flutter test test/presentation/cartao_imovel_acervo_test.dart test/presentation/gestao_imovel_screen_test.dart` | ✅ (inverter casos D-07) |
| API-11 | §16 + exemplos = fixtures; chaves lidas pelo app presentes e do tipo certo (subconjunto, não allowlist exata: o serializer é compartilhado com o painel) | contrato | `flutter test test/data/contrato_gestao_situacao_test.dart` | ❌ Wave 0 |
| API-12 | L1–L7 (e L8 se aprovado) | Django | `manage.py test imoveis.tests.AppSituacaoApiTests` | ❌ Wave 0 (web) |

### Sampling Rate
- **Por commit de tarefa:** comando rápido do arquivo tocado + `flutter analyze lib` se tocou `lib/`.
- **Por onda:** `flutter analyze lib` + `flutter test` completo (à mão, D-16: o gate pós-merge do GSD pula os testes Flutter) e, se a web mudou, `manage.py test` completo.
- **Antes do `/gsd-verify-work`:** app 1194+N verde e analyze limpo; web 743+N verde (se mudou).
- **Latência máxima de feedback:** ~60 s.

### Wave 0 Gaps
- [ ] `tool/capturar_fixtures_api.py` — grupo `situacao` (nunca `todos`): detalhe antes/depois, `situacao_200`, histórico vazio e com itens, `erro_400_mesma_situacao`, `erro_400_contrato_assinado` (corretor@demo.com em `DEMO-CASA-01`), `erro_403_situacao` (corretor demo em `DEV-CAMPINAS-14`), `erro_404_imovel` (corretor da outra empresa). Sempre em SQLite temporário, credenciais só por variável de ambiente, token redigido; o POST **muda o banco**, então reverter/usar banco descartável.
- [ ] `test/fixtures/api/*` novas (capturadas, nada à mão) e `contrato/*.example.json` do §16.
- [ ] `test/support/api_falsa.dart` — 3 rotas (detalhe, histórico, POST) + 401 sem token.
- [ ] Testes novos listados na tabela acima (datasource, repository, models, 2 Cubits, folha, tela, apresentação, fluxo, contrato).
- [ ] Ajuste dos testes do cartão/acervo (inverter D-07) e `test/main_launch_routing_test.dart` só se o DI mudar o que ele registra.
- [ ] Web (condicional D-08): `AppSituacaoApiTests` na `feat/APP09`.
- [ ] Framework: nenhuma instalação.

### Decomposição de ondas sugerida (para o planejador)
1. **Contrato e dados reais:** (checkpoint de autorização para a branch da web) testes L1–L7 na `feat/APP09`; grupo `situacao` no `tool/` e captura; §16 + exemplos; `ApiFalsa`.
2. **Dados do app:** models, datasource, repository (falhas tipadas), use cases, DI (`build_runner`).
3. **Apresentação:** Cubit da tela, Cubit da folha, tela, folha, histórico, textos; cartão + `AcervoScreen`/`AcervoCubit.recarregar`.
4. **Fechamento:** fluxo ponta a ponta sobre `PilhaReal`, `REQUIREMENTS.md`/`ROADMAP.md`/README, `flutter analyze`/`flutter test`, UAT humano.

## Security Domain

`security_enforcement: true`, ASVS nível 1, bloquear em severidade **high** (`.planning/config.json`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | herdada | Token DRF no Keychain/Keystore (Phase 8); nada novo, mas toda rota nova exige `Authorization` |
| V3 Session Management | sim | 401 → `SessaoExpiradaException` → apaga token (compare-and-delete) e volta ao login; sem token em log |
| V4 Access Control | **sim (núcleo da fase)** | Servidor decide: `EhCorretor` + `pode_mudar_situacao` + queryset por empresa; UI só reflete o booleano |
| V5 Input Validation | sim | `situacao` só do enum via `codigoDaSituacao`; `observacao` com `maxLength` e `trim`; servidor valida (`ChoiceField`) |
| V7 Error Handling & Logging | sim | Falhas tipadas; mensagem do servidor só nos 400/403, como `Text` simples e com corte; 404/5xx com texto fixo; sem `LogInterceptor`/`print` |
| V8 Data Protection | sim | Observação e histórico só em memória; nada gravado em `shared_preferences`/disco; limpar ao fechar |
| V9 Communications | herdada | Dev em `http://10.0.2.2:8000` (cleartext só em desenvolvimento); produção deve ser HTTPS (item de deploy já registrado na Phase 8) |
| V13 API | sim | Cliente só usa as rotas documentadas no §16; trailing slash; sem redirecionamento com credencial |

### Known Threat Patterns (insumo para o `<threat_model>` do planejador)

| ID sugerido | Pattern | STRIDE | Sev. | Mitigação padrão (e o teste) |
|-------------|---------|--------|------|------------------------------|
| T-09-01 | Corretor não responsável força a mudança (botão escondido por UI não é controle) | Elevation of Privilege | high | Servidor: `pode_mudar_situacao` → 403 (L7, L-colega); app: botão só com `pode_mudar_situacao`, e o 403 mostra a mensagem e **não** muda a tela (teste de fluxo) |
| T-09-02 | IDOR: trocar `id` na URL para mexer em imóvel de outra empresa | Information Disclosure / Tampering | high | Queryset por empresa → 404 idêntico a inexistente (L5); app só usa ids vindos da lista do próprio acervo; `id` é `int` na montagem da URL |
| T-09-03 | App muda estado local sem confirmação do servidor (AC-2) | Tampering | high | Cubit nunca emite o estado novo; só recarga da API; teste: após 400/403 o `situacao` exibido é o anterior e após 200 só muda depois do GET |
| T-09-04 | Token enviado a origem errada / seguindo redirect | Information Disclosure | high | Rotas novas só no Dio `'autenticado'`; `followRedirects:false`; sempre barra final; reaproveita testes do `InterceptadorSessao` |
| T-09-05 | Vazamento por mensagem de erro (HTML de depuração do 5xx, texto em inglês do 404) | Information Disclosure | medium | Só 400/403 mostram texto do servidor (já em português e de negócio); resto usa texto fixo; corte de 300 caracteres |
| T-09-06 | Dado sensível em log/disco (observação pode ter nome de cliente) | Information Disclosure | medium | Sem log de corpo/observação; sem persistência; Model do detalhe não declara `proprietario`/`descricao` |
| T-09-07 | Duplo envio / replay do Confirmar | Tampering / DoS | medium | `enviando` bloqueia; botão desabilitado; sem retry automático; servidor recusa repetido (400 "já está …") |
| T-09-08 | Sessão expirada durante o POST perde a mudança em silêncio | Repudiation / DoS | medium | 401 tipado → login com aviso; teste de fluxo; observação perdida é aceita (sessão terminou) |
| T-09-09 | Observação gigante (100 000 caracteres aceitos hoje) | Denial of Service | low | `maxLength` no campo; (opcional) `max_length` no serializer da web (L8) |
| T-09-10 | Resposta malformada ou `situacao` desconhecida derruba a tela | DoS / Tampering | low | `situacao` desconhecida → `null` (sem chip, sem crash); data inválida → `FormatException` → falha genérica com "Tentar de novo" |
| T-09-11 | Corrida entre dois aparelhos (estado velho) | Tampering | low | Servidor é o árbitro (400 "já está …"); puxar para atualizar |
| T-09-12 | Captura de fixtures contra banco real, com credenciais em arquivo | Information Disclosure | high | Estende T-08-21/T-08-23: SQLite temporário, credenciais por `os.environ`, token redigido, repo web limpo; **o POST grava no banco, então nunca contra o banco do `Web/.env`** |
| T-09-13 | Texto do servidor interpretado como marcação | Tampering | low | Só `Text` simples (Flutter não interpreta HTML); sem `Text.rich` de dado externo; sem `launchUrl` a partir de texto do servidor |

Severidade ≥ high (T-09-01..04, T-09-12) precisa de mitigação comprovada por teste automatizado ou por UAT antes de encerrar a fase.

## Sources

### Primary (HIGH confidence)
- Código do Django em `origin/main` `8bf4448` (lido via `git show`/`git archive`, e `Read` nas faixas citadas): `Web/imoveis/api/views.py`, `serializers.py`, `models.py`, `Web/core/permissions.py`, `Web/core/mixins.py`, `Web/config/settings.py`, `Web/imoveis/tests.py`, `Web/contratos/tests.py`, `Web/empresas/management/commands/semear_vitrine_dev.py`, `Web/core/management/commands/seed_demo.py`, `Web/templates/imoveis/imovel_detail.html`.
- Execução real: sondas descartáveis (wire de todos os erros), `manage.py test` completo (743 OK), seeds num SQLite temporário, `reverse()` das URLs; `flutter analyze lib` e `flutter test` (1194 verdes).
- Código do app (este repo): `lib/data/**`, `lib/domain/**`, `lib/presentation/acervo/**`, `lib/presentation/contato/**`, `lib/di/modulo_rede.dart`, `test/support/api_falsa.dart`, `tool/capturar_fixtures_api.py`.
- SDK do Flutter instalado: `packages/flutter/lib/src/widgets/modal_barrier.dart`, `material/bottom_sheet.dart`.
- Artefatos do projeto: `09-CONTEXT.md`, `09-CARD-APP09.md`, `09-DISCUSSION-LOG.md`, `REQUIREMENTS.md`, `STATE.md`, `ROADMAP.md`, `01-CONTRATO-API.md` §14–§15, `08-VALIDATION.md`, `08-SECURITY.md`, `08-UAT.md`, `08-PATTERNS.md`.

### Secondary / Tertiary
- Nenhuma fonte externa de internet foi necessária: não há biblioteca nova nem API de terceiros (o seam `research-plan` não foi acionado porque nenhuma pergunta dependia de documentação externa).

## Metadata

**Confidence breakdown:**
- Contrato da API: HIGH — lido no código e confirmado por execução.
- Standard stack: HIGH — nenhuma dependência nova; versões do `pubspec.yaml`.
- Architecture: HIGH — repete padrões já provados nas Phases 6–8 (Cubit, falhas tipadas, folha com `BlocProvider.value`).
- Pitfalls: HIGH para os verificados (branch errada, 404 em inglês, observação sem limite, fuso/`intl`, barreira da folha); MEDIUM para A2/A4 (dependem de confirmação/teste).

**Research date:** 2026-11-22
**Valid until:** 2026-12-22 (a API do Django é interna e estável; reler só se a `origin/main` mudar as rotas de imóveis)
