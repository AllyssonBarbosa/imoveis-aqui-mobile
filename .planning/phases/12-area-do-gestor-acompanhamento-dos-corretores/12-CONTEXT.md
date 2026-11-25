# Phase 12: Área do Gestor — Acompanhamento dos Corretores (APP 12) - Context

**Gathered:** 2026-11-25
**Status:** Ready for planning

<domain>
## Phase Boundary

O gestor da imobiliária entra no app (login da Phase 8) e, no lugar da tela de aviso de hoje, abre a
**"Área do gestor"**. É uma tela só, que responde as quatro perguntas do card:

1. quantos imóveis cada corretor tem;
2. quantos contatos cada corretor recebeu, por período;
3. quais imóveis mudaram de situação nos últimos dias e quem mudou;
4. quanto a empresa tem em cada situação (disponível, reservado, vendido e alugado).

Todos os números vêm calculados do Django. O app não conta, não soma e não filtra nada. Só o gestor
vê esta área: o corretor continua no "Meu acervo" e o servidor recusa as rotas a quem não é gestor.

Duas perguntas já têm rota na `main` da web (W12): os totais por situação
(`GET /api/relatorios/acervo/`) e os contatos por corretor (`GET /api/relatorios/contatos/`). Esta fase
cria na web, na branch `feat/APP12`, as duas que faltam (acervo por corretor e mudanças recentes),
documenta o contrato e constrói a tela no app.

**Fora desta fase:** relatório de parcelas, mudar situação ou anotar retorno pelo gestor, lista de
imóveis da empresa (`/api/gestao/imoveis/`), páginas novas no painel do site e qualquer número
calculado no aparelho.

</domain>

<decisions>
## Implementation Decisions

> Caminho curto pedido pelo Allysson (D-A): nenhuma pergunta foi feita. Cada decisão abaixo sai do
> texto do card (`12-CARD-APP12.md`), do painel de relatórios do site (W12:
> `relatorios/servicos.py` e `templates/relatorios/*.html`) e das decisões das Phases 8, 9 e 10.
> Nada fora do card entrou.

### Travadas no card, antes da discussão (D-A..D-C — não perguntar de novo)
- **D-A · Caminho curto:** discuss sem perguntas → planejador → verificador de planos com **uma
  rodada**. **Sem pesquisa e sem mapa de padrões**: os padrões vêm da APP-10 (app) e da W12 (web). O
  planejador lê direto os arquivos das referências canônicas abaixo.
- **D-B · Branches:** `feat/APP12` no app (já criada da `feat/APP10`). No repo web, `feat/APP12` nasce
  da `main` (`origin/main` = `e2d1fa0`) no primeiro plano que mexer no Django. Commits locais do GSD
  liberados nos dois repos. **Push só com autorização explícita** (nenhum plano faz `git push`).
- **D-C · Número da fase:** Phase 12 (fase N = card APP N); a Phase 11 fica reservada ao card APP 11,
  de outro colega.

### Quem entra e por onde
- **D-01:** O **gestor** passa a cair na **"Área do gestor"** (tela nova) depois do login e ao tocar
  no botão do topo da vitrine. A troca é feita nos dois pontos que hoje mandam o gestor para a
  `AvisoAreaScreen`: `Papel.gestor => AreaGestorScreen()` em `entrada_area_screen.dart` e em
  `login_screen.dart`. O login e a sessão não mudam (F8/D-B já previa "a APP-12 troca essa tela").
- **D-02:** O **administrador continua na `AvisoAreaScreen`**, porque as rotas da W12 usam `EhGestor`
  e o administrador não tem empresa. O texto da tela de aviso deixa de falar do gestor: título
  "Área do administrador" e mensagem "A área do administrador não está no app.", com o mesmo botão
  Sair.
- **D-03:** O **corretor nunca vê a área** (critério 6). O app só escolhe a tela pelo papel que vem
  do servidor (`GET /api/auth/eu/`), e quem garante é o Django: todas as rotas da tela ficam atrás de
  `EhGestor` (corretor, administrador e anônimo recebem 403/401). Testes no Django provam isso para
  as duas rotas novas e conferem as duas que já existem.
- **D-04:** O botão do topo da vitrine continua dizendo **"Meu acervo"** para qualquer sessão (F8/D-C).
  O papel não é guardado no aparelho, então o rótulo não pode depender dele sem uma regra nova.
  — **Reversibility:** reversible — trocar por um rótulo neutro é só um texto.

### A tela
- **D-05:** **Uma tela só**, com rolagem, título **"Área do gestor"** na `AppBar` e **Sair** na
  própria `AppBar` (`confirmarESair`, igual ao acervo). Não há abas nem `NavigationBar`: o card diz
  "a tela responde quatro perguntas".
- **D-06:** **Quatro seções, nesta ordem:**
  1. **Totais da empresa por situação** (critério 4): é o resumo, com 4 números curtos, então fica no
     topo;
  2. **Acervo por corretor** (critério 1);
  3. **Contatos por corretor** (critério 2);
  4. **Mudanças de situação** (critério 3): fica por último porque é a única lista que pode crescer e
     não deve empurrar as outras para baixo.

  — **Reversibility:** reversible — é só a ordem dos widgets.
- **D-07:** **Cada seção carrega sozinha.** Ao abrir a tela, os quatro pedidos saem em paralelo.
  Cada seção tem o próprio carregando e o próprio erro ("Não foi possível carregar." com "Tentar de
  novo", que repete só aquele pedido). Se uma falhar, as outras continuam aparecendo, como no F10/D-22.
  Não há "puxar para atualizar": reabrir a tela recarrega tudo, como na caixa de contatos.
- **D-08:** **Sem toque nas linhas.** Linha de corretor e item de mudança não abrem nada, porque o
  card não pede (ver Deferred).

### Seção 1 — Totais da empresa por situação (critério 4)
- **D-09:** Dados de `GET /api/relatorios/acervo/` (já existe): usa só `totais` (`DISPONIVEL`,
  `RESERVADO`, `VENDIDO`, `ALUGADO`) e `total`. A tabela natureza × situação (`linhas`) não aparece,
  porque o card pede só o total por situação. A rota não muda.
- **D-10:** Quatro blocos (rótulo + número) na ordem do card: Disponível, Reservado, Vendido,
  Alugado. Os rótulos vêm de `rotuloSituacao` (textos fixos do app, F8). Abaixo, "Total: N imóveis",
  com o `total` do servidor. O app não soma os quatro.

### Seção 2 — Acervo por corretor (critério 1)
- **D-11:** **Rota nova na web** (lacuna 1 do card), no padrão da W12: uma função nova em
  `relatorios/servicos.py` (sugestão: `acervo_por_corretor(empresa_id)`) e uma `RelatorioApiView`
  (`EhGestor`, sempre `request.user.empresa_id`). Sugestão de rota:
  `GET /api/relatorios/acervo-por-corretor/`. O nome final fica com o planejador.
- **D-12:** **O que conta:** todos os imóveis da empresa, em qualquer situação, publicados ou não,
  agrupados por `corretor_responsavel`. É a mesma base de `acervo_por_natureza_e_situacao`, então a
  soma da coluna fecha com o `total` da seção 1 (o teste do Django confere isso).
- **D-13:** **Quem aparece:** a mesma regra de `contatos_por_corretor`: todo corretor **ativo** da
  empresa, mesmo com zero (quem está sem acervo é justamente o que o gestor quer ver), e também o
  usuário desativado que ainda é responsável por algum imóvel, marcado com `ativo: false`. Ordem: quem
  tem mais primeiro e, no empate, por nome. Resposta sugerida:
  `{"linhas": [{"corretor_id", "corretor", "ativo", "total"}], "total"}`. Sem paginação, como os
  relatórios da W12.
- **D-14:** Cada linha mostra o nome (com "(desativado)" quando `ativo` é false, como no site) e o
  número: "N imóveis", "1 imóvel" ou "Nenhum imóvel". Rodapé "Total: N imóveis", com o `total` do
  servidor. Sem corretores: "Nenhum corretor cadastrado." (texto do site). Só o total de cada um,
  como pede o critério 1; a quebra por situação de cada corretor fica para depois.

### Seção 3 — Contatos por corretor e por período (critério 2)
- **D-15:** Dados de `GET /api/relatorios/contatos/?de=AAAA-MM-DD&ate=AAAA-MM-DD` (já existe, W12; a
  rota não muda). O app não manda `imovel`, porque o card não pede filtro por imóvel.
- **D-16:** **Período:** um chip "Período" no topo da seção, que reaproveita o seletor da APP-10
  (`escolherPeriodoComSeletor`, `showDateRangePicker` em pt-BR, `PeriodoContatos`, `firstDate` 2024,
  `lastDate` hoje). Com valor, o chip mostra "01/11/2026 – 25/11/2026" e tem o "x" para limpar.
  **Padrão: todo o período** (sem `de`/`ate`), como o site e o servidor fazem. Trocar o período
  recarrega **só esta seção**. A linha de baixo mostra "Todo o período." ou
  "Período: 01/11/2026 a 25/11/2026." Datas inclusivas, no dia de São Paulo (regra do
  `filtrar_contatos`). Um 400 vira o erro da seção.
- **D-17:** Cada linha mostra o nome do corretor ("(desativado)" quando `ativo` é false) e
  "N contatos · M aguardando retorno": as duas colunas do relatório do site, ambas do servidor
  (`total` e `pendentes`). A linha com `corretor_id: null` usa um **texto fixo do app**,
  "Empresa (corretor desativado no clique)", igual ao do site, sem exibir a string do servidor. Ordem:
  a do servidor (quem recebeu mais primeiro). Rodapé "Total: N contatos · M aguardando retorno", com o
  `total` e os `pendentes` do servidor. Sem linhas: "Nenhum corretor cadastrado."

### Seção 4 — Mudanças de situação nos últimos dias (critério 3)
- **D-18:** **Rota nova na web** (lacuna 2 do card), no mesmo padrão: uma função em
  `relatorios/servicos.py` (sugestão: `mudancas_de_situacao(empresa_id, dias)`) sobre
  `HistoricoSituacao` filtrado por `imovel__empresa_id` e uma `RelatorioApiView` com `EhGestor`.
  Sugestão de rota: `GET /api/relatorios/mudancas-situacao/`.
- **D-19:** **"Últimos dias" = 7 dias**: hoje e os 6 dias anteriores, contados pelo dia de São Paulo
  (`timezone.localdate()`), como os outros recortes por data. **O padrão fica no servidor.** A rota
  aceita `?dias=` opcional (de 1 a 365, validado no padrão do `ler_dias`, com 400 quando inválido),
  mas o app não manda: usa o padrão e mostra o número de dias que o servidor devolve na resposta. O
  "7" não fica escrito no app.
  — **Reversibility:** reversible — mudar a janela é trocar uma constante no Django, sem nova versão
  do app.
- **D-20:** **Campos (lista fechada):** `id`, imóvel (`imovel_id`, `imovel_codigo`, `imovel_titulo`),
  `situacao_anterior`, `situacao_nova`, `alterado_por` (só o nome, como o `HistoricoSituacaoSerializer`),
  `alterado_em` e `observacao`. Nada de proprietário, preço ou dado interno. A ordem é a do modelo
  (`-alterado_em, -id`). Entram todas as mudanças do período, inclusive as feitas pela assinatura de
  contrato. Resposta sugerida: `{"dias", "desde", "mudancas": [...]}`. **Sem paginação**, como os
  relatórios da W12: a janela de dias já limita o tamanho.
  — **Reversibility:** costly — paginar depois muda o formato da resposta (lista → envelope).
- **D-21:** Título da seção: "Mudanças de situação — últimos N dias" (N vem do servidor). O item segue
  o histórico da APP-09 (F9/D-11), com o imóvel em cima:
  - "código — título" (até 2 linhas);
  - "Disponível → Reservado" (`rotuloSituacao`);
  - "dd/MM/yyyy HH:mm · Nome de quem mudou" (hora local, `toLocal()`);
  - a observação, quando houver.

  Vazio: "Nenhuma mudança de situação nos últimos N dias."

### Erros e sessão
- **D-22:** **Qualquer 401** em qualquer seção segue o fluxo da Phase 8:
  `SessaoCubit.encerrarPorExpiracao()` e o login abre com "Sua sessão terminou. Entre de novo.",
  deixando só a vitrine na pilha (`eRotaDaVitrine`). Todas as rotas usam o `Dio` `@Named('autenticado')`.
- **D-23:** **403** (o papel mudou no servidor durante a sessão, por exemplo) vira o erro da seção com
  um texto fixo próprio: "Só o gestor da imobiliária pode ver estes números." Rede, timeout, 5xx e
  400 viram "Não foi possível carregar." Nenhuma string do servidor aparece na UI.
- **D-24:** **Valor de situação desconhecido** vindo do servidor vira falha de formato na camada de
  dados, como os outros Models fazem.

### Web (lacunas do card, branch `feat/APP12`)
- **D-25:** Repo web em `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui` (pasta `Web` =
  Django), **não** `../imoveis-aqui/Web`. Hoje a cópia local está na `feat/APP10`, 3 commits atrás da
  `origin/main` (`e2d1fa0`, que já tem a APP-10). O primeiro plano que mexer no Django faz
  `checkout main`, avança com `--ff-only` até a `origin/main` e cria a `feat/APP12`. **Sem migração:**
  as rotas novas só consultam. O `runserver` do Allysson roda dessa pasta, então trocar de branch
  muda o que ele serve. Isso não causa problema, porque as rotas são aditivas.
- **D-26:** Mudanças na web, todas em `relatorios/` (`servicos.py`, `api/views.py`, `api/urls.py`),
  atrás de `EhGestor` e sempre com a empresa do usuário: (1) acervo por corretor (D-11..D-13);
  (2) mudanças de situação (D-18..D-20). As rotas que já existem e o painel do site não mudam. Os
  testes vão em `relatorios/tests.py`, no padrão dos que já existem, e cobrem:
  - corretor, administrador e anônimo barrados nas duas rotas;
  - outra empresa nunca contada nem listada;
  - corretor ativo com zero e desativado com imóvel aparecendo;
  - soma por corretor = total da empresa;
  - janela de dias (dentro e fora, limite do dia de São Paulo);
  - `?dias=` inválido → 400;
  - os campos exatos da mudança.

  `python manage.py test` fica verde.

### Contrato e rastreabilidade
- **D-27:** Novo **§18** em `01-CONTRATO-API.md` (o §17 é a caixa de contatos da APP-10), no padrão
  dos §16 e §17. Ele cobre as quatro rotas que a tela usa: as duas da W12 (só os campos que o app lê)
  e as duas novas (parâmetros, campos, 400/401/403), mais a regra "só o gestor, só a empresa dele".
  Os exemplos são **capturados do Django real** (fixtures), não escritos à mão, com testes de contrato
  nos dois repositórios, como fez a API-13. Se a APP-11 do colega chegar antes com o §18, renumerar no
  merge, como foi feito na APP-10.
- **D-28:** Novos IDs em `REQUIREMENTS.md`, numa seção "Área do gestor (APP12)", cobrindo os critérios
  1 a 6 e as rotas da web (sugestão: `GES-01..` e `API-15`/`API-16`; os nomes ficam com o planejador),
  mapeados para a Phase 12 no ROADMAP (`**Requirements**:`, hoje TBD) e na tabela de
  rastreabilidade. O `LOG-01` do v2 ganha a nota de que a área do gestor foi promovida para a Phase 12.

### Regras do projeto (carregadas das fases anteriores)
- **D-29 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado freezed,
  `Result` e falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e branco
  (cores só do `ColorScheme`, texto do `textTheme`), código e comentários em português,
  `Navigator.push` + `MaterialPageRoute`, sem go_router, telas aceitando `criarCubit` para os testes
  de widget.
- **D-30 [informational]:** `flutter analyze` limpo e `flutter test` verde **rodados à mão a cada
  onda** (o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter). O analyze já
  tem 41 infos `deprecated_member_use` antigas (Flutter 3.50.1), que não são desta fase. Arquivos
  gerados que o `build_runner` reescreve só com CRLF voltam com `git checkout --`.
  `workflow.use_worktrees=false`.
- **D-31 [informational]:** **UAT com credenciais dentro de cada passo** (feedback da APP-10). São
  precisos um gestor e um corretor **da mesma empresa** do `corretor.vitrine.demo@example.com` /
  `Teste12345`, que já existe no Postgres do Allysson, e outra empresa com dados para provar o
  isolamento. O `semear_vitrine_dev` não cria gestor. O `seed_demo` cria `gestor@demo.com` /
  `SenhaForte123`, mas numa empresa demo própria. O planejador escolhe: usar a empresa do
  `seed_demo` ou criar um gestor na empresa da vitrine com um script fora do repo (como o
  `criar_contatos.py` da APP-10). O roteiro sempre escreve o e-mail e a senha no passo que pede
  login.

### Claude's Discretion
- Nomes de classes, arquivos e estados. Sugestão: `lib/presentation/area_gestor/` com
  `AreaGestorScreen`, um Cubit por seção ou um Cubit com quatro sub-estados (o planejador escolhe) e
  `widgets/secao_*.dart`. Entidades em `domain/` (`TotaisPorSituacao`, `AcervoDoCorretor`,
  `ContatosDoCorretor`, `MudancaRecente`), `AreaGestorRepository` e use cases,
  `AreaGestorRemoteDataSource` no `Dio` autenticado.
- Visual dos blocos de totais (grade 2×2 ou linha), ícones, espaçamentos e se cada seção fica num
  `Card`. Só cores do `ColorScheme`. Tudo é confirmado no human-check de fim de fase.
- Nomes finais das rotas e chaves das respostas novas (as sugestões de D-11, D-13, D-18 e D-20 servem
  de ponto de partida).
- **UI-SPEC:** como na F4/D-20, F7/D-16, F8 e F10, as decisões D-05 a D-23 servem de contrato de UI,
  com confirmação no human-check. `/gsd-ui-phase 12` é opcional.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Card e escopo
- `.planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-CARD-APP12.md` — texto oficial do card (história + critérios 1–6), levantamento da W12 e do histórico, as 2 lacunas da web e D-A..D-C.
- `.planning/ROADMAP.md` § "Phase 12" — goal, dependências e success criteria.
- `.planning/REQUIREMENTS.md` — onde entram os IDs novos (D-28), `LOG-01` do v2 e a tabela de rastreabilidade.
- `.planning/PROJECT.md` — core value e restrições (nada de regra ou conta no aparelho).

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` §14 (login, `Dio` autenticado, 401), §16 (situação e histórico, formato do item de histórico) e §17 (caixa de contatos, último número usado; modelo de seção com fixtures capturadas) — o §18 novo segue o mesmo formato (D-27).

### Decisões das fases anteriores
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-CONTEXT.md` — D-B (gestor/admin na tela de aviso, que a APP-12 troca), sessão, 401, `Dio` autenticado, textos fixos.
- `.planning/phases/09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09/09-CONTEXT.md` — D-11 (item do histórico de situação, rótulos, data `dd/MM/yyyy HH:mm`).
- `.planning/phases/10-contatos-recebidos-e-retorno-anotado/10-CONTEXT.md` — D-20 (seletor de período pt-BR), D-22 (falha parcial), D-23 (401), disciplina de testes D-29.

### Web (repo `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui`, pasta `Web`, ler na `origin/main` `e2d1fa0`)
- `Web/relatorios/servicos.py` — `acervo_por_natureza_e_situacao`, `contatos_por_corretor` (regra de quem aparece, linha da empresa, ordenação), `ler_dias` (validação de `?dias=`).
- `Web/relatorios/api/views.py` — `RelatorioApiView` (`EhGestor`), `AcervoApiView`, `ContatosApiView` (400 de `FiltroInvalido`).
- `Web/relatorios/api/urls.py` — onde entram as rotas novas.
- `Web/relatorios/tests.py` — padrão dos testes novos (D-26).
- `Web/templates/relatorios/acervo.html`, `contatos.html`, `index.html` — textos e colunas do site ("Aguardando retorno", "(desativado)", "Todo o período.", "Nenhum corretor cadastrado.").
- `Web/core/permissions.py` — `EhGestor` (só gestor com empresa).
- `Web/imoveis/models.py` — `Imovel.Situacao`, `corretor_responsavel`, `HistoricoSituacao` (campos, ordenação).
- `Web/imoveis/api/serializers.py` — `HistoricoSituacaoSerializer` (`alterado_por` = nome).
- `Web/contatos/servicos.py` — `filtrar_contatos` (datas inclusivas no dia de São Paulo).
- `Web/imoveis/vitrine.py` — `FiltroInvalido`.
- `Web/core/management/commands/seed_demo.py` — `gestor@demo.com` / `SenhaForte123` (D-31).

### App (este repo)
- `lib/presentation/sessao/aviso_area_screen.dart` — tela de aviso (passa a ser só do administrador, D-02).
- `lib/presentation/sessao/entrada_area_screen.dart` e `lib/presentation/login/login_screen.dart` — roteamento por papel (D-01).
- `lib/presentation/sessao/dialogo_sair.dart` (`confirmarESair`), `sessao_cubit.dart`, `rota_vitrine.dart` (`eRotaDaVitrine`), `lib/presentation/login/apresentacao_login.dart` (`avisoSessaoTerminou`) — Sair e sessão terminada (D-05, D-22).
- `lib/presentation/contatos/caixa_contatos_screen.dart` + `caixa_contatos_cubit.dart` — modelo de tela autenticada com 401 e falha parcial.
- `lib/presentation/contatos/widgets/seletor_periodo.dart`, `chips_filtros_contatos.dart`, `lib/domain/entities/periodo_contatos.dart` — seletor e chip de período (D-16).
- `lib/presentation/gestao_imovel/widgets/historico_situacao.dart` + `apresentacao_gestao.dart` — item do histórico (D-21).
- `lib/presentation/acervo/apresentacao_acervo.dart` (`rotuloSituacao`), `lib/domain/entities/situacao_imovel.dart` — rótulos e enum de situação.
- `lib/data/datasources/caixa_contatos_remote_datasource.dart` + `lib/data/repositories/caixa_contatos_repository_impl.dart` — DataSource no `Dio` autenticado e tradução de 401/403/demais em falhas tipadas.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `escolherPeriodoComSeletor` + `PeriodoContatos` + o chip com valor/limpar da caixa de contatos: período da seção 3, sem código novo de seletor (o pt-BR já foi ativado na APP-10).
- `rotuloSituacao` e o enum `SituacaoImovel` (com o mapeamento do wire na camada de dados): rótulos das seções 1 e 4.
- Item do histórico da APP-09 (`historico_situacao.dart`): base visual do item de mudança.
- `confirmarESair` e o fluxo de sessão terminada (`encerrarPorExpiracao` + `LoginScreen(aviso: avisoSessaoTerminou)`).
- `Dio` `@Named('autenticado')` com o interceptador de sessão; `Result` sealed e falhas tipadas.
- `intl` para `dd/MM/yyyy HH:mm` e para as datas do período.

### Established Patterns
- DataSource remoto fino + Model freezed/json_serializable + entidade + UseCase + Cubit com estado freezed e `switch` exaustivo; DI por `injectable` (`dart run build_runner build -d`).
- Textos fixos em `apresentacao_*.dart`; nenhuma string do servidor na UI (só dados, como nomes e títulos).
- Testes: `bloc_test` + `mocktail`; fixtures reais capturadas do Django; e2e na API falsa de `test/support` (`api_falsa.dart`, `pilha_real.dart`).
- Web: relatórios só chamam `relatorios/servicos.py`; nada é gravado; `EhGestor` + `request.user.empresa_id`.

### Integration Points
- `entrada_area_screen.dart` e `login_screen.dart`: `Papel.gestor` passa a apontar para a `AreaGestorScreen`.
- `aviso_area_screen.dart`: texto passa a ser do administrador.
- `lib/di/`: registrar DataSource, Repository, UseCases e Cubit(s) novos.
- `test/support/api_falsa.dart` e `pilha_real.dart`: responder as 4 rotas no e2e.
- Web: `relatorios/servicos.py`, `relatorios/api/views.py`, `relatorios/api/urls.py`, `relatorios/tests.py`.

</code_context>

<specifics>
## Specific Ideas

- Referência de textos: o painel de relatórios do site ("Contatos por corretor", "Aguardando retorno", "(desativado)", "Todo o período.", "Nenhum corretor cadastrado.", "Empresa (corretor desativado no clique)").
- História do card: o gestor quer saber "quem está com acervo parado e quem está recebendo contato". Por isso o corretor ativo com zero aparece nas seções 2 e 3.
- O Allysson quer tudo decidido pelo card, sem extras, e o fluxo curto (D-A).

</specifics>

<deferred>
## Deferred Ideas

- **Quebra por situação do acervo de cada corretor** (quantos disponíveis, reservados etc. por pessoa): o critério 1 pede só o total.
- **Tocar no corretor** para ver o acervo ou os contatos dele, e **tocar na mudança** para abrir o imóvel (pediria a tela de gestão pelas rotas `/api/gestao/imoveis/`): fora do card.
- **Escolher a janela de dias das mudanças no app** (a rota já aceita `?dias=`, D-19): fora do card.
- **Filtro por imóvel no relatório de contatos** (a rota aceita `imovel`): fora do card.
- **Relatório de parcelas** (`/api/relatorios/parcelas/`), **caixa de contatos da empresa** e **mudar situação pelo gestor**: fora do card.
- **Páginas "acervo por corretor" e "mudanças recentes" no painel do site**: as funções ficam em `relatorios/servicos.py`, prontas para o site usar, mas as páginas são da frente web.
- **Rótulo neutro no botão do topo** ("Minha área" em vez de "Meu acervo") para o gestor (D-04).
- **Puxar para atualizar**: fora do card (como na APP-10).

</deferred>

---

*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Context gathered: 2026-11-25*
