# Phase 9: Mudança de Situação do Imóvel pelo App (APP 09) - Context

**Gathered:** 2026-11-22
**Status:** Ready for planning
**Source:** card APP 09 (`09-CARD-APP09.md`, usado como PRD) + discuss-phase

<domain>
## Phase Boundary

O corretor, já logado (Phase 8), abre um imóvel do **Meu acervo** numa **tela nova de gestão** e,
quando o servidor permite, troca a situação (Disponível / Reservado / Vendido / Alugado) com uma
observação. A mudança é **pedida à API**; o app não altera nada localmente. A mesma tela mostra o
**histórico** das mudanças. Se a API recusar, a mensagem aparece e a situação anterior fica.

A WEB 08 (situação e histórico) já está na `main` do repo web (`origin/main` em `8bf4448`):

- `POST /api/imoveis/{id}/situacao/` — corpo `{situacao, observacao}` (observação opcional);
  403 para quem não é o corretor responsável; 400 `{"situacao": [mensagens]}` quando o modelo
  recusa (mesma situação, contrato assinado, situação inválida); 200 devolve o `ImovelSerializer`.
- `GET /api/imoveis/{id}/historico/` — lista `{id, situacao_anterior, situacao_nova, alterado_por
  (nome), alterado_em, observacao}`, mais recente primeiro.
- `GET /api/imoveis/{id}/` — `ImovelSerializer` com `situacao`, `situacao_desde` e
  `pode_mudar_situacao` (calculado pelo Django).
- O gestor tem as mesmas ações em `/api/gestao/imoveis/{id}/` (fora desta fase, ver D-08).

Os 6 critérios de aceite do card são o checklist da fase:
AC-1 trocar a situação com data e observação · AC-2 a mudança é feita pela API, nada local ·
AC-3 histórico na tela do imóvel · AC-4 recusa mostra a mensagem e mantém a situação anterior ·
AC-5 a vitrine reflete a mudança na consulta seguinte · AC-6 só o corretor responsável e o gestor
conseguem mudar.

</domain>

<decisions>
## Implementation Decisions

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
  recebe esse booleano (por exemplo, passado do cartão ao abrir). Depois de uma mudança o botão
  some até a tela ser reaberta (D-18).
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
  assinatura." (Exceção aprovada depois pelo usuário: limite de 500 caracteres no campo, D-17.)

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
  (A pesquisa achou lacuna de teste; onde nasce a `feat/APP09` foi decidido depois: D-19.)

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

### Decisões do planejamento (usuário, 2026-11-22, durante o plan-phase)
- **D-17:** **Observação com limite de 500 caracteres no app** (`maxLength` 500 no campo da
  folha, com contador). Aprovado pelo usuário em 2026-11-22 como **exceção à D-06**: é proteção
  de interface (o servidor hoje não limita a observação — Pitfall 5 da pesquisa, T-09-09), não
  regra de negócio. O `max_length` no serializer da web (L8) continua fora desta fase, como
  pergunta à equipe web.
- **D-18:** **"Ver na vitrine" some depois de uma mudança** feita na tela de gestão
  (`!state.mudou`), até a tela ser reaberta: o `na_vitrine` que veio do cartão ficou velho e o
  app não recalcula publicação (Pitfall 2 da pesquisa). Aprovado pelo usuário em 2026-11-22;
  complementa a D-02.
- **D-19:** **Web num worktree separado.** A branch `feat/APP09` da web nasce da `origin/main`
  num worktree próprio, `../imoveis-aqui-APP09`
  (`/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui-APP09`), criado com
  `git -C ../imoveis-aqui worktree add -b feat/APP09 ../imoveis-aqui-APP09 origin/main`. O clone
  `../imoveis-aqui` **nunca troca de branch** nesta fase (continua no que o usuário deixou); a
  captura de fixtures lê a `origin/main` por `git archive`, sem depender da branch do clone.
  Commits locais na `feat/APP09` do worktree, **sem push**. Os testes que faltam na web (API-12)
  são feitos — não há caminho de "pular". Aprovado pelo usuário em 2026-11-22; resolve o ponto
  aberto da D-08.

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Fonte da fase
- `.planning/phases/09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09/09-CARD-APP09.md` — texto oficial do card (história + 6 critérios + dependência da WEB 08)
- `.planning/ROADMAP.md` — Phase 9 (goal; Requirements ainda "TBD", D-14)
- `.planning/REQUIREMENTS.md` — onde entram os IDs novos (D-14)
- `.planning/PROJECT.md` — regras (nada de regra de negócio no app, servidor decide)

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — §12 sincronização e antidrift, §14 login e acervo (modelo para o §16 e exemplos capturados, §14.9), §15 (último número usado)

### Fases anteriores (padrões a seguir)
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-CONTEXT.md` — sessão, token só nas rotas autenticadas, 401 → sessão expirada, cartão do acervo (D-05..D-07), chips de situação
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-PATTERNS.md` — padrões de arquivos da área do corretor
- `.planning/phases/07.1-integra-o-da-app-07-com-a-api-real/07.1-CONTEXT.md` — como uma fase trabalha nos dois repos (branch na web, testes, UAT com `semear_vitrine_dev`)

### Django (repo web, ler na `origin/main` `8bf4448`; clone local em `../imoveis-aqui/Web`)
- `Web/imoveis/models.py` — `Imovel.pode_mudar_situacao`, `Imovel.mudar_situacao` (todas as recusas e mensagens), `situacao_desde`, `HistoricoSituacao` (`alterado_em` automático, ordenação)
- `Web/imoveis/api/views.py` — `ImovelViewSet.situacao` / `.historico` (403, 400), `GestaoImovelViewSet` (rotas do gestor, fora da fase)
- `Web/imoveis/api/serializers.py` — `ImovelSerializer` (`pode_mudar_situacao`, `situacao_desde`), `MudancaSituacaoSerializer`, `HistoricoSituacaoSerializer`, `ImovelAcervoSerializer` (`na_vitrine`)
- `Web/imoveis/forms.py` — `SituacaoForm` (dica da observação, D-06)
- `Web/imoveis/views.py` — `imovel_mudar_situacao` e `_contexto_situacao` (textos do site: SnackBar, D-10)
- `Web/templates/imoveis/imovel_detail.html` — histórico no site (colunas e texto de vazio, D-11)
- `Web/core/permissions.py` — `EhCorretor`, `EhGestor`
- `Web/imoveis/tests.py` — o que já é testado de situação/histórico (D-08)

### App (este repo)
- `lib/presentation/acervo/acervo_screen.dart`, `acervo_cubit.dart` — onde o toque passa a abrir a gestão e o recarregar na volta (D-02, D-12)
- `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` — `onTap` hoje só com `naVitrine` (muda pelo D-02)
- `lib/presentation/acervo/widgets/chips_situacao.dart`, `lib/presentation/acervo/apresentacao_acervo.dart` (`rotuloSituacao`) — chips e rótulos de situação
- `lib/domain/entities/situacao_imovel.dart`, `imovel_acervo.dart` — enum e entidade do acervo
- `lib/data/datasources/acervo_remote_datasource.dart` — DataSource autenticado do acervo e tratamento de 401
- `lib/presentation/sessao/` — sessão, sessão expirada, Sair
- `lib/presentation/vitrine/apresentacao_imovel.dart` (`linhasDePreco`), `lib/presentation/comum/imagem_rede.dart` — cabeçalho da tela (D-03)
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` — `abrirDetalheImovel` ("Ver na vitrine", D-02)
- `lib/core/result.dart` — `Result` sealed

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `rotuloSituacao` e os chips de situação do acervo: rótulos na tela, no histórico e na folha.
- `ImagemRede` + `linhasDePreco`: cabeçalho da tela de gestão.
- `abrirDetalheImovel`: botão "Ver na vitrine".
- DataSource autenticado do acervo (Phase 8): `Dio` com o token, falha de sessão expirada no 401.
- `Result` sealed e falhas tipadas por status HTTP.

### Established Patterns
- DataSource remoto com `Dio` injetado + Model freezed/json_serializable + entidade + UseCase +
  Cubit com estado freezed; DI por `injectable` (`dart run build_runner build -d`).
- Testes com `bloc_test` + `mocktail`; DataSources testados com Dio mockado e fixtures de wire
  capturadas da API real; e2e com a API falsa de `test/support`.
- Primeira ação de escrita (POST autenticado) do app: até aqui o app só lia.

### Integration Points
- Cartão do acervo → tela de gestão (`Navigator.push`, resultado "mudou" no `pop`) → recarga do
  `AcervoCubit`.
- Nova rota autenticada de detalhe, de histórico e o POST de situação no DataSource do acervo (ou
  num novo), registrados no `injection.dart`.
- Repo web: só se a pesquisa achar lacuna (D-08).

</code_context>

<specifics>
## Specific Ideas

- Textos fixos decididos: "Mudar situação" · "Confirmar" · "Data: hoje" · dica "Ex.: reservado
  para o cliente João até a assinatura." · "Situação alterada para <situação>." · "Não foi possível
  mudar a situação agora. Tente de novo." · "Nenhuma mudança ainda — disponível desde o cadastro."
  · "Ver na vitrine".
- Caso de uso do card: o corretor marca "Reservado" na hora da conversa com o cliente, pelo celular.
- UAT precisa de: corretor responsável, outro corretor da mesma empresa (sem botão), corretor de
  outra empresa (404) e um imóvel com contrato assinado (recusa com mensagem do servidor). A
  pesquisa confere se o `semear_vitrine_dev` cria isso ou se o UAT usa admin/shell.
- Testar no emulador exige o Django rodando (`runserver 0.0.0.0:8000`, `10.0.2.2` no
  `ALLOWED_HOSTS`), como na Phase 8.

</specifics>

<deferred>
## Deferred Ideas

- **Área do gestor no app** (lista da empresa via `/api/gestao/imoveis/` e a mesma tela de gestão):
  APP-12.
- **Data informada pelo corretor** (diferente da data do servidor): exigiria campo novo no
  `HistoricoSituacao` e migração no Django; só se a equipe web decidir.
- **Dados completos do imóvel** na tela de gestão (endereço, descrição, detalhe por natureza) e
  edição pelo app: fora do card.

</deferred>

---

*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Context gathered: 2026-11-22*
