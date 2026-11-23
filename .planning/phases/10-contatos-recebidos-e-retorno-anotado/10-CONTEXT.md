# Phase 10: Contatos Recebidos e Retorno Anotado (APP 10) - Context

**Gathered:** 2026-11-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Na área do corretor do app (a mesma da Phase 8), uma tela nova, **"Meus contatos"**, mostra os
contatos que o corretor logado recebeu, com o mais recente primeiro. Cada item traz o imóvel, o
canal, a data e o retorno atual. A tela tem filtro por imóvel e por período, mostra quantos
contatos estão sem retorno anotado e deixa o corretor anotar o retorno (falei, visita agendada, sem
resposta ou descartado). A anotação é gravada pela API.

A lista, os filtros, a anotação e o isolamento já existem na web (WEB 11, `ContatoViewSet`). Esta
fase completa a web na branch `feat/APP10` com as três lacunas do card: a contagem dos sem retorno,
a paginação e a lista de imóveis para o filtro. Também documenta o contrato e constrói a tela no
app.

**Fora desta fase:** a caixa do gestor (APP-12), filtro por situação do retorno, notificação de
contato novo e qualquer dado do visitante (o `Contato` da W11 não guarda nenhum).

</domain>

<decisions>
## Implementation Decisions

> O Allysson pediu: "decida pelas instruções do card". Nenhuma pergunta foi feita. Cada decisão
> abaixo sai do texto do card (`10-CARD-APP10.md`), do jeito que o site já faz a caixa
> (`ContatoListView` + `contato_list.html`) e das decisões das Phases 6 e 8. Nada fora do card
> entrou.

### Travadas no card, antes da discussão (D-A..D-C — não perguntar de novo)
- **D-A · Fluxo completo de planejamento:** pesquisa → padrões → planejador → verificador, como na
  APP-08.
- **D-B · Branches:** `feat/APP10` no app (já criada da `main` atualizada) e no repo web, quando a
  fase mexer no Django. Commits locais do GSD liberados nos dois repos. **Push só com autorização
  explícita** (nenhum plano faz `git push`).
- **D-C · Número da fase:** Phase 10 (fase N = card APP 0N); a Phase 9 fica reservada ao card
  APP 09.

### Entrada na caixa e quem usa
- **D-01:** A caixa abre por um **ícone na `AppBar` do "Meu acervo"** (`AcervoScreen`). Ícone de
  caixa de entrada, tooltip "Meus contatos", ao lado do Sair. Abre por `Navigator.push`, então o
  "voltar" retorna ao acervo. O título da tela é **"Meus contatos"**, o mesmo do site. Não há abas
  nem `NavigationBar`, porque o card não pede reestruturar a área do corretor.
- **D-02:** O número de pendentes aparece **só na tela da caixa**. O critério 6 diz "a tela mostra",
  então não há selo no ícone do acervo.
- **D-03:** **Só o corretor.** O card é escrito para o corretor. O gestor continua na tela de aviso
  da Phase 8 (F8/D-B), e a caixa da empresa fica para a APP-12. A API já atende o gestor (vê todos
  os da empresa); o app só não oferece a entrada para ele.

### Número de contatos sem retorno (critério 6)
- **D-04:** O número é **calculado no Django**: contatos visíveis para o usuário
  (`contatos_visiveis_para`) com `retorno = PENDENTE`. O app nunca conta, soma nem subtrai.
- **D-05:** O número é o **total do corretor, sem os filtros**. Ele responde "quantos ainda estão
  sem retorno" (o trabalho que falta) e não muda quando o corretor filtra por imóvel ou período.
  — **Reversibility:** reversible — se o grupo preferir que o número siga o filtro, basta passar os
  mesmos parâmetros para a rota da contagem.
- **D-06:** O número é pedido ao servidor **ao abrir a tela e depois de cada anotação bem-sucedida**.
  O app não decrementa o valor localmente. Forma recomendada: uma rota própria, sem filtros e sem
  paginação (sugestão: `GET /api/contatos/resumo/` → `{"sem_retorno": N}`). Fica assim a menos que a
  pesquisa ache forma mais simples que cumpra D-04 a D-06 (por exemplo, um campo no envelope da
  lista mais a resposta do PATCH).
- **D-07:** Texto da linha, logo abaixo da `AppBar`: "N contatos sem retorno" / "1 contato sem
  retorno" / "Nenhum contato sem retorno".

### Lista e item (critérios 1, 2 e 5)
- **D-08:** A ordem é a do servidor (`-criado_em, -id`, `Contato.Meta.ordering`). Não há botão de
  ordenar.
- **D-09:** O **item** mostra o mesmo que a linha da tabela do site, sem a coluna do gestor:
  - **imóvel:** "código — título" (`imovel_codigo` — `imovel_titulo`), até 2 linhas;
  - **canal:** ícone e nome de exibição, "WhatsApp", "Telefone" ou "E-mail" (os rótulos de
    `Contato.Canal`). Os ícones são os de `ApresentacaoCanalContato.icone` (F6). Os rótulos de ação
    da F6 ("Ligar", "Enviar e-mail") **não** servem aqui;
  - **data do contato:** completa, `dd/MM/yyyy HH:mm`, o formato do site (`d/m/Y H:i`);
  - **retorno atual:** um chip com o rótulo, que destaca "Aguardando retorno" para os pendentes
    saltarem à vista;
  - **"anotado em dd/MM/yyyy HH:mm"** quando houver `retorno_em`, como o site mostra.

  `corretor_nome` não aparece: no site, essa coluna é só do gestor.
- **D-10:** Rótulos do retorno: **iguais aos `Contato.Retorno` do site**: "Aguardando retorno",
  "Falei", "Visita agendada", "Sem resposta", "Descartado". São mapeados no app a partir do valor do
  enum (`PENDENTE`, `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA`, `DESCARTADO`), com textos fixos, como
  a F8 fez com a situação. Os valores do wire ficam só em `data/`.
- **D-11:** O toque no item **abre a anotação** (D-14). Não abre a página do imóvel, porque o card
  não pede.
- **D-12:** **Paginação por página** (`PageNumberPagination`) no `GET /api/contatos/`, com rolagem
  infinita e rodapés de carregando, erro e fim reaproveitando o `RodapePaginacaoLista`, como no
  acervo (F8/D-10). O `next` é seguido só se tiver a mesma origem (`mesmaOrigem`, T-08-30). O tamanho
  da página segue o padrão da APP-05/APP-08 (a pesquisa confere).
  — **Reversibility:** costly — muda o formato da resposta de uma rota que já existe (lista →
  envelope). Pelo levantamento, só o app consome `/api/contatos/` (a docstring do `ContatoViewSet`
  diz "Caixa de contatos do app"; o site usa a `ContatoListView`), mas a pesquisa confirma antes de
  mudar.
- **D-13:** O isolamento (critério 5) é **garantido e testado no Django**: contato de outra empresa
  ou de outro corretor nunca aparece na lista (com ou sem filtro), nem na contagem, nem nas opções do
  filtro de imóvel, e o PATCH pelo id cai em 404. O app não filtra nada (F8/D-14).

### Anotar o retorno (critério 4)
- **D-14:** O toque no item abre um **bottom sheet** com as 4 opções anotáveis (Falei, Visita
  agendada, Sem resposta, Descartado), com a atual marcada. É o padrão de folha que o app já usa
  (filtros, ordenação, contato). **Um toque numa opção já grava.** Não há botão "Salvar" (o site só
  tem um porque é formulário HTML) nem diálogo de confirmação, porque a anotação pode ser trocada
  depois. "Aguardando retorno" **não** é opção: a API recusa `PENDENTE`.
- **D-15:** **Pode trocar depois**, como no site: um contato já anotado reabre a folha e aceita
  outra das 4 opções. A API grava um novo `retorno_em`.
- **D-16:** **O app espera o servidor.** Durante o `PATCH /api/contatos/{id}/` com
  `{"retorno": VALOR}`, o item mostra carregamento e ignora novos toques. Com sucesso, o item é
  trocado pelos dados que o servidor devolveu (`retorno`, `retorno_em`) e o número de pendentes é
  pedido de novo (D-06). Não há atualização otimista: mudança de estado é decidida no Django.
- **D-17:** Falha na anotação → o item fica como estava e aparece uma **SnackBar com texto fixo do
  app**, nunca a string do servidor:
  - rede, timeout, 5xx ou 400 → "Não foi possível anotar o retorno. Tente de novo.";
  - 404 → "Este contato não está mais na sua caixa.", e a lista e o número são recarregados;
  - 401 → fluxo de sessão terminada (D-23).

### Filtro por imóvel e por período (critério 3)
- **D-18:** Abaixo da linha do número, **dois chips de filtro: "Imóvel" e "Período"**. Com valor, o
  chip fica selecionado, mostra o valor (o código do imóvel, ou "01/11/2026 – 22/11/2026") e tem um
  "x" para limpar só aquele filtro. Os dois se combinam. Trocar ou limpar um filtro recomeça a lista
  da página 1 e volta ao topo, como o acervo faz. O número de pendentes não muda (D-05).
- **D-19:** **Imóvel:** um bottom sheet com "Todos os imóveis" e a lista "código — título",
  **só dos imóveis que aparecem nos contatos que o usuário pode ver**, ordenada por código. É a mesma
  regra do seletor do site (`ContatoListView.get_context_data`, `imoveis`). Isso pede uma **rota
  nova na web** (lacuna 3, sugestão: `GET /api/contatos/imoveis/` → `id`, `codigo`, `titulo`, sem
  paginação). Vai `?imovel=<id>`.
- **D-20:** **Período:** `showDateRangePicker` do Material 3 (De/Até, como os dois campos de data do
  site), com as datas inclusivas e enviadas como `?de=AAAA-MM-DD&ate=AAAA-MM-DD`. Não há atalhos
  ("7 dias", "30 dias"), porque nem o card nem o site têm. O seletor garante `de ≤ ate`; se mesmo
  assim vier 400, a lista mostra o erro genérico.
  O seletor precisa estar **em português**: hoje o `MaterialApp` não tem `localizationsDelegates`
  nem `flutter_localizations`. A pesquisa confere o impacto de ativar o pt-BR no app inteiro e nos
  testes.

### Estados da tela
- **D-21:** Textos (fixos no app):
  - nenhum contato e sem filtro → "Você ainda não recebeu contatos.";
  - nenhum resultado com filtro → "Nenhum contato encontrado." (o texto do site);
  - erro ao carregar → "Não foi possível carregar os contatos." com "Tentar de novo".
- **D-22:** Se só a contagem falhar, a lista continua funcionando e a linha do número não aparece.
  A contagem é pedida de novo junto com o próximo recarregamento (anotação, "Tentar de novo",
  reabrir a tela).

### Sessão
- **D-23:** **Qualquer 401** (lista, contagem, opções do filtro ou PATCH) segue o fluxo da Phase 8:
  `SessaoCubit.encerrarPorExpiracao()` e o login abre com "Sua sessão terminou. Entre de novo.",
  deixando só a vitrine embaixo na pilha (`eRotaDaVitrine`). Todas as rotas da caixa usam o `Dio`
  `@Named('autenticado')`; o token nunca vai para as rotas públicas e nunca é logado.

### Web (lacunas do card, branch `feat/APP10`)
- **D-24:** Repo web em `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui` (pasta `Web` =
  Django), **não** `../imoveis-aqui/Web`. A `main` local está **5 commits atrás** de
  `origin/main` (`8bf4448`): atualizar antes de criar a `feat/APP10`.
- **D-25:** Mudanças na web, todas atrás de `PertenceAUmaEmpresa` +
  `EmpresaScopedQuerySetMixin` + `restringir_ao_perfil`:
  1. paginação na listagem do `ContatoViewSet` (D-12), mantendo os filtros e a ordem;
  2. contagem dos sem retorno (D-04 a D-06);
  3. opções do filtro de imóvel (D-19).

  O PATCH e o `ContatoSerializer` não mudam (a menos que a pesquisa escolha a variante de D-06). Os
  testes vão em `contatos/tests.py`, no padrão de `IsolamentoTests`, `CaixaDeContatosTests` e
  `AnotarRetornoTests`. Cobrem paginação; contagem só de `PENDENTE` e só dos visíveis; opções só com
  imóveis dos contatos visíveis; e outra empresa ou outro corretor nunca aparecendo nas rotas novas.
  `python manage.py test` verde.

### Contrato e rastreabilidade
- **D-26:** Novo **§16** em `01-CONTRATO-API.md`, no padrão dos §14 e §15: caixa de contatos (lista
  com parâmetros, envelope paginado e campos), PATCH do retorno (valores aceitos, resposta,
  400/401/404), contagem, opções do filtro de imóvel e a regra de isolamento.
- **D-27:** Novos IDs em `REQUIREMENTS.md`, seção "Caixa de contatos (APP10)", mapeados para a
  Phase 10 no ROADMAP (`**Requirements**:`, hoje TBD) e na tabela de rastreabilidade. Cobrem os
  critérios 1 a 6 e as rotas da web, como as Phases 7 e 8 fizeram. Os nomes dos IDs ficam para o
  planejador.

### Regras do projeto (carregadas das fases anteriores)
- **D-28 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado freezed,
  `Result`/falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e branco
  (cores só do `ColorScheme`, texto do `textTheme`), código e comentários em português,
  `Navigator.push` + `MaterialPageRoute`, sem go_router (F8/D-17).
- **D-29 [informational]:** `flutter analyze` limpo e `flutter test` verde **rodados à mão a cada
  onda**: o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter. O analyze já
  tem 41 infos `deprecated_member_use` pré-existentes (Flutter 3.50.1), que não são desta fase.
  Arquivos gerados que o `build_runner` reescreve só com CRLF são restaurados com `git checkout --`.
  `workflow.use_worktrees=false` (F8/D-18).

### Claude's Discretion
- Nomes de classes, arquivos e estados. Sugestão: `lib/presentation/contatos/` com
  `ContatosScreen`, `ContatosCubit`, `widgets/item_contato.dart`,
  `widgets/folha_anotar_retorno.dart`, `widgets/folha_filtro_imovel.dart`; entidades `ContatoRecebido`,
  `RetornoContato`, `ConsultaContatos`, `PaginaContatos`, `ImovelComContato` em `domain/`;
  `ContatosRepository` e use cases; `ContatosRemoteDataSource` no `Dio` autenticado. O número de
  Cubits (um para a tela, ou um separado para o filtro de imóvel) fica para o planejador.
- Ícone exato da entrada (D-01) e da linha do número, cores do chip de retorno (só do
  `ColorScheme`) e espaçamentos. Tudo é confirmado no human-check de fim de fase.
- Fuso da data mostrada: hora local do aparelho (`toLocal()`). A pesquisa confere o `TIME_ZONE` do
  Django, que vale para o recorte `criado_em__date` dos filtros `de`/`ate`, e anota no §16 se houver
  diferença.
- Valor de retorno ou canal desconhecido vindo do servidor: tratar como falha de formato na camada
  de dados, como os outros Models fazem (a pesquisa confere o padrão vigente).
- Quando carregar as opções do filtro de imóvel (ao abrir a tela ou ao abrir a folha), e o
  `firstDate` do seletor de período.
- **UI-SPEC:** como na F4/D-20, F7/D-16 e F8, as decisões D-01 a D-22 servem de contrato de UI, com
  confirmação no human-check de fim de fase. `/gsd-ui-phase 10` é opcional.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Card e escopo
- `.planning/phases/10-contatos-recebidos-e-retorno-anotado/10-CARD-APP10.md` — texto oficial do card (história + critérios 1–6), levantamento da API já entregue, as 3 lacunas da web e D-A..D-C.
- `.planning/ROADMAP.md` § "Phase 10" — goal, dependências e success criteria.
- `.planning/REQUIREMENTS.md` — onde entram os IDs novos (D-27) e a tabela de rastreabilidade.
- `.planning/PROJECT.md` — core value e restrições (nada de regra no aparelho).

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` §14 (login e acervo, padrão do envelope paginado autenticado e dos 401) e §15 (contato público da W11) — o §16 novo segue o mesmo formato (D-26).

### Decisões das fases anteriores
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-CONTEXT.md` — sessão, 401, `Dio` autenticado, paginação do acervo, textos fixos, disciplina de testes (D-17/D-18).
- `.planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-CONTEXT.md` — enum `CanalContato`, ícones dos canais, origem dos contatos (POST público).

### Web (repo `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui`, pasta `Web`)
- `Web/contatos/models.py` — `Contato` (`Canal`, `Retorno`, `RETORNOS_ANOTAVEIS`, `anotar_retorno`, ordering).
- `Web/contatos/api/views.py` — `ContatoViewSet` (list/retrieve/PATCH, filtros, 400 de filtro inválido).
- `Web/contatos/api/serializers.py` — `ContatoSerializer` (campos do item, só `retorno` gravável).
- `Web/contatos/api/urls.py` — rota `contatos` montada em `api/`.
- `Web/contatos/servicos.py` — `restringir_ao_perfil`, `contatos_visiveis_para`, `filtrar_contatos`.
- `Web/contatos/views.py` — `ContatoListView` (regra do seletor de imóvel do site, `paginate_by = 50`).
- `Web/templates/contatos/contato_list.html` — layout de referência do site (colunas, rótulos, "anotado em", "Nenhum contato encontrado.").
- `Web/contatos/tests.py` — `IsolamentoTests`, `CaixaDeContatosTests`, `AnotarRetornoTests` (padrão dos testes novos).
- `Web/core/permissions.py` (`PertenceAUmaEmpresa`) e `Web/core/mixins.py` (`EmpresaScopedQuerySetMixin`).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/presentation/acervo/acervo_screen.dart` — modelo da tela: `BlocListener` de sessão expirada → `encerrarPorExpiracao` + `LoginScreen(aviso: avisoSessaoTerminou)` com `eRotaDaVitrine`; rolagem infinita com guarda de "não preenche a tela"; `_MensagemDoAcervo` para estados vazios/erro. A `AppBar` dela recebe o ícone de entrada (D-01).
- `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart` — rodapé carregando/erro/fim (D-12).
- `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart` — padrão de Cubit paginado com consulta, `carregarMais`, `tentarNovamente` e estado de sessão expirada.
- `lib/data/datasources/acervo_remote_datasource.dart` — DataSource fino no `Dio` `@Named('autenticado')`, `seguir(next)` com `mesmaOrigem`; `lib/data/repositories/acervo_repository_impl.dart` traduz 401/403/demais para falhas tipadas.
- `lib/data/network/interceptador_sessao.dart` + `lib/di/modulo_rede.dart` — o `Dio` autenticado que já leva o token.
- `lib/presentation/contato/rotulos_contato.dart` — `ApresentacaoCanalContato.icone` (reaproveitar os ícones; os rótulos de ação não servem, D-09).
- `lib/domain/entities/canal_contato.dart` + `lib/data/models/canal_contato_api.dart` — enum de canal e o mapeamento do wire (reaproveitar).
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart`, `ordenacao_bottom_sheet.dart`, `chips_filtros_ativos.dart` e `lib/presentation/contato/widgets/contato_bottom_sheet.dart` — padrão de bottom sheet e de chips com valor/limpar (D-14, D-18, D-19).
- `lib/presentation/sessao/sessao_cubit.dart`, `rota_vitrine.dart`, `lib/presentation/login/apresentacao_login.dart` (`avisoSessaoTerminou`) — fluxo de sessão terminada (D-23).
- `intl` (^0.20.3) já é dependência — formatação `dd/MM/yyyy HH:mm` (D-09).

### Established Patterns
- Estados freezed com `switch` exaustivo na tela; textos fixos em `apresentacao_*.dart`; nenhuma string do servidor na UI.
- Paginação seguindo o `next` absoluto da resposta, só de mesma origem.
- Injeção com `injectable` (`@LazySingleton(as: ...)`, `@injectable`) e telas aceitando `criarCubit` para testes de widget sem DI.
- Testes: `bloc_test` + `mocktail`; fixtures reais capturadas do Django (padrão da 07.1/08).

### Integration Points
- `AcervoScreen` (AppBar) → `Navigator.push(ContatosScreen)`.
- `MaterialApp` (raiz do app) → `localizationsDelegates`/`supportedLocales` pt-BR para o `showDateRangePicker` (D-20).
- `lib/di/` → registrar DataSource/Repository/UseCases/Cubit novos (rodar `build_runner`).
- Web: `ContatoViewSet` (paginação + actions novas) e `contatos/tests.py`.

</code_context>

<specifics>
## Specific Ideas

- Referência visual e de texto: a caixa do site (`Web/templates/contatos/contato_list.html`): título "Meus contatos", "código — título" do imóvel, data `d/m/Y H:i`, rótulos de canal e de retorno do Django, "anotado em …" e "Nenhum contato encontrado.".
- O Allysson quer tudo decidido pelo texto do card, sem extras.

</specifics>

<deferred>
## Deferred Ideas

- **Caixa do gestor** (todos os contatos da empresa, coluna "Recebido por"): APP-12.
- **Filtro pela situação do retorno** (por exemplo, "só pendentes"): fora do card e do site.
- **Selo com o número de pendentes no ícone do acervo**: o card pede o número na própria tela (D-02).
- **Abrir a página do imóvel a partir do contato**: fora do card (D-11).
- **Atalhos de período** ("7 dias", "30 dias") e **puxar para atualizar**: fora do card.
- **Notificação de contato novo**: fora do card.

</deferred>

---

*Phase: 10-contatos-recebidos-e-retorno-anotado*
*Context gathered: 2026-11-22*
