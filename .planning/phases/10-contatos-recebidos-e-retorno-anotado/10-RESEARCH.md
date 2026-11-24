# Phase 10: Contatos Recebidos e Retorno Anotado (APP 10) - Research

**Researched:** 2026-11-22
**Domain:** Caixa de contatos do corretor: lista paginada + filtros (imóvel, período), contagem dos "sem retorno", anotação do retorno (PATCH), isolamento por empresa e perfil. Web em Django + DRF (completar `ContatoViewSet`); app em Flutter (Clean Architecture + Cubit freezed) sobre o `Dio` autenticado da Phase 8.
**Confidence:** HIGH no lado web e no wiring do app (código lido e experimentos de leitura rodados nesta sessão, sem alterar nenhum dos dois repos); MEDIUM no fuso (decisão de produto para aparelhos fora de São Paulo) e no `firstDate` do seletor de período.

**Repos lidos:** app `C:/projetos/imoveis-aqui-mobile` (branch `feat/APP10`, árvore limpa); web `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` na branch `main`, commit `8bf4448` (`git log --oneline -1` = `8bf4448 Merge branch 'feat/APP08' into main`), árvore limpa. **Nada foi alterado, commitado ou criado** nos dois repos. Os experimentos rodaram em arquivos temporários fora dos repos (scratchpad) com o SQLite em memória; o pacote de teste do seletor de datas também ficou no scratchpad.

**Linha de base medida nesta sessão (gate de cada onda):**

| Gate | Comando | Resultado hoje |
|------|---------|----------------|
| Django (suíte completa) | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` | `Ran 743 tests in 20.179s` / `OK` |
| Django (só contatos) | `... manage.py test contatos --noinput` | arquivo `contatos/tests.py` tem 392 linhas: `ContatoBase` + 6 classes de teste (`LinkDoWhatsAppTests`, `GravacaoDoContatoTests`, `SemLoginTests`, `CaixaDeContatosTests`, `AnotarRetornoTests`, `IsolamentoTests`) |
| App: analyze | `flutter analyze lib` | `41 issues found.` — **todas** `deprecated_member_use` e **todas** `'package:flutter/material.dart' is deprecated ... Use package:material_ui/material_ui.dart` (1 por arquivo de `lib/` que importa `material.dart`: `grep -l` dá 41 arquivos) |
| App: testes | `flutter test` | `All tests passed!` com **1194** testes (`+1194`) |

Ferramentas: Flutter 3.50.1 / Dart 3.14.0; Python 3.11.9, Django 5.2.17, DRF 3.18.1 (`venv` do web). [VERIFIED: `flutter --version`, `./venv/Scripts/python.exe -c "import django, rest_framework..."`]

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

> O Allysson pediu: "decida pelas instruções do card". Nenhuma pergunta foi feita. Cada decisão
> abaixo sai do texto do card (`10-CARD-APP10.md`), do jeito que o site já faz a caixa
> (`ContatoListView` + `contato_list.html`) e das decisões das Phases 6 e 8. Nada fora do card
> entrou.

**Travadas no card, antes da discussão (D-A..D-C — não perguntar de novo)**
- **D-A · Fluxo completo de planejamento:** pesquisa → padrões → planejador → verificador, como na APP-08.
- **D-B · Branches:** `feat/APP10` no app (já criada da `main` atualizada) e no repo web, quando a fase mexer no Django. Commits locais do GSD liberados nos dois repos. **Push só com autorização explícita** (nenhum plano faz `git push`).
- **D-C · Número da fase:** Phase 10 (fase N = card APP 0N); a Phase 9 fica reservada ao card APP 09.

**Entrada na caixa e quem usa**
- **D-01:** A caixa abre por um **ícone na `AppBar` do "Meu acervo"** (`AcervoScreen`). Ícone de caixa de entrada, tooltip "Meus contatos", ao lado do Sair. Abre por `Navigator.push`, então o "voltar" retorna ao acervo. O título da tela é **"Meus contatos"**, o mesmo do site. Não há abas nem `NavigationBar`, porque o card não pede reestruturar a área do corretor.
- **D-02:** O número de pendentes aparece **só na tela da caixa**. O critério 6 diz "a tela mostra", então não há selo no ícone do acervo.
- **D-03:** **Só o corretor.** O card é escrito para o corretor. O gestor continua na tela de aviso da Phase 8 (F8/D-B), e a caixa da empresa fica para a APP-12. A API já atende o gestor (vê todos os da empresa); o app só não oferece a entrada para ele.

**Número de contatos sem retorno (critério 6)**
- **D-04:** O número é **calculado no Django**: contatos visíveis para o usuário (`contatos_visiveis_para`) com `retorno = PENDENTE`. O app nunca conta, soma nem subtrai.
- **D-05:** O número é o **total do corretor, sem os filtros**. Ele responde "quantos ainda estão sem retorno" (o trabalho que falta) e não muda quando o corretor filtra por imóvel ou período. — **Reversibility:** reversible — se o grupo preferir que o número siga o filtro, basta passar os mesmos parâmetros para a rota da contagem.
- **D-06:** O número é pedido ao servidor **ao abrir a tela e depois de cada anotação bem-sucedida**. O app não decrementa o valor localmente. Forma recomendada: uma rota própria, sem filtros e sem paginação (sugestão: `GET /api/contatos/resumo/` → `{"sem_retorno": N}`). Fica assim a menos que a pesquisa ache forma mais simples que cumpra D-04 a D-06 (por exemplo, um campo no envelope da lista mais a resposta do PATCH).
- **D-07:** Texto da linha, logo abaixo da `AppBar`: "N contatos sem retorno" / "1 contato sem retorno" / "Nenhum contato sem retorno".

**Lista e item (critérios 1, 2 e 5)**
- **D-08:** A ordem é a do servidor (`-criado_em, -id`, `Contato.Meta.ordering`). Não há botão de ordenar.
- **D-09:** O **item** mostra o mesmo que a linha da tabela do site, sem a coluna do gestor:
  - **imóvel:** "código — título" (`imovel_codigo` — `imovel_titulo`), até 2 linhas;
  - **canal:** ícone e nome de exibição, "WhatsApp", "Telefone" ou "E-mail" (os rótulos de `Contato.Canal`). Os ícones são os de `ApresentacaoCanalContato.icone` (F6). Os rótulos de ação da F6 ("Ligar", "Enviar e-mail") **não** servem aqui;
  - **data do contato:** completa, `dd/MM/yyyy HH:mm`, o formato do site (`d/m/Y H:i`);
  - **retorno atual:** um chip com o rótulo, que destaca "Aguardando retorno" para os pendentes saltarem à vista;
  - **"anotado em dd/MM/yyyy HH:mm"** quando houver `retorno_em`, como o site mostra.

  `corretor_nome` não aparece: no site, essa coluna é só do gestor.
- **D-10:** Rótulos do retorno: **iguais aos `Contato.Retorno` do site**: "Aguardando retorno", "Falei", "Visita agendada", "Sem resposta", "Descartado". São mapeados no app a partir do valor do enum (`PENDENTE`, `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA`, `DESCARTADO`), com textos fixos, como a F8 fez com a situação. Os valores do wire ficam só em `data/`.
- **D-11:** O toque no item **abre a anotação** (D-14). Não abre a página do imóvel, porque o card não pede.
- **D-12:** **Paginação por página** (`PageNumberPagination`) no `GET /api/contatos/`, com rolagem infinita e rodapés de carregando, erro e fim reaproveitando o `RodapePaginacaoLista`, como no acervo (F8/D-10). O `next` é seguido só se tiver a mesma origem (`mesmaOrigem`, T-08-30). O tamanho da página segue o padrão da APP-05/APP-08 (a pesquisa confere). — **Reversibility:** costly — muda o formato da resposta de uma rota que já existe (lista → envelope). Pelo levantamento, só o app consome `/api/contatos/` (a docstring do `ContatoViewSet` diz "Caixa de contatos do app"; o site usa a `ContatoListView`), mas a pesquisa confirma antes de mudar.
- **D-13:** O isolamento (critério 5) é **garantido e testado no Django**: contato de outra empresa ou de outro corretor nunca aparece na lista (com ou sem filtro), nem na contagem, nem nas opções do filtro de imóvel, e o PATCH pelo id cai em 404. O app não filtra nada (F8/D-14).

**Anotar o retorno (critério 4)**
- **D-14:** O toque no item abre um **bottom sheet** com as 4 opções anotáveis (Falei, Visita agendada, Sem resposta, Descartado), com a atual marcada. É o padrão de folha que o app já usa (filtros, ordenação, contato). **Um toque numa opção já grava.** Não há botão "Salvar" (o site só tem um porque é formulário HTML) nem diálogo de confirmação, porque a anotação pode ser trocada depois. "Aguardando retorno" **não** é opção: a API recusa `PENDENTE`.
- **D-15:** **Pode trocar depois**, como no site: um contato já anotado reabre a folha e aceita outra das 4 opções. A API grava um novo `retorno_em`.
- **D-16:** **O app espera o servidor.** Durante o `PATCH /api/contatos/{id}/` com `{"retorno": VALOR}`, o item mostra carregamento e ignora novos toques. Com sucesso, o item é trocado pelos dados que o servidor devolveu (`retorno`, `retorno_em`) e o número de pendentes é pedido de novo (D-06). Não há atualização otimista: mudança de estado é decidida no Django.
- **D-17:** Falha na anotação → o item fica como estava e aparece uma **SnackBar com texto fixo do app**, nunca a string do servidor:
  - rede, timeout, 5xx ou 400 → "Não foi possível anotar o retorno. Tente de novo.";
  - 404 → "Este contato não está mais na sua caixa.", e a lista e o número são recarregados;
  - 401 → fluxo de sessão terminada (D-23).

**Filtro por imóvel e por período (critério 3)**
- **D-18:** Abaixo da linha do número, **dois chips de filtro: "Imóvel" e "Período"**. Com valor, o chip fica selecionado, mostra o valor (o código do imóvel, ou "01/11/2026 – 22/11/2026") e tem um "x" para limpar só aquele filtro. Os dois se combinam. Trocar ou limpar um filtro recomeça a lista da página 1 e volta ao topo, como o acervo faz. O número de pendentes não muda (D-05).
- **D-19:** **Imóvel:** um bottom sheet com "Todos os imóveis" e a lista "código — título", **só dos imóveis que aparecem nos contatos que o usuário pode ver**, ordenada por código. É a mesma regra do seletor do site (`ContatoListView.get_context_data`, `imoveis`). Isso pede uma **rota nova na web** (lacuna 3, sugestão: `GET /api/contatos/imoveis/` → `id`, `codigo`, `titulo`, sem paginação). Vai `?imovel=<id>`.
- **D-20:** **Período:** `showDateRangePicker` do Material 3 (De/Até, como os dois campos de data do site), com as datas inclusivas e enviadas como `?de=AAAA-MM-DD&ate=AAAA-MM-DD`. Não há atalhos ("7 dias", "30 dias"), porque nem o card nem o site têm. O seletor garante `de ≤ ate`; se mesmo assim vier 400, a lista mostra o erro genérico. O seletor precisa estar **em português**: hoje o `MaterialApp` não tem `localizationsDelegates` nem `flutter_localizations`. A pesquisa confere o impacto de ativar o pt-BR no app inteiro e nos testes.

**Estados da tela**
- **D-21:** Textos (fixos no app):
  - nenhum contato e sem filtro → "Você ainda não recebeu contatos.";
  - nenhum resultado com filtro → "Nenhum contato encontrado." (o texto do site);
  - erro ao carregar → "Não foi possível carregar os contatos." com "Tentar de novo".
- **D-22:** Se só a contagem falhar, a lista continua funcionando e a linha do número não aparece. A contagem é pedida de novo junto com o próximo recarregamento (anotação, "Tentar de novo", reabrir a tela).

**Sessão**
- **D-23:** **Qualquer 401** (lista, contagem, opções do filtro ou PATCH) segue o fluxo da Phase 8: `SessaoCubit.encerrarPorExpiracao()` e o login abre com "Sua sessão terminou. Entre de novo.", deixando só a vitrine embaixo na pilha (`eRotaDaVitrine`). Todas as rotas da caixa usam o `Dio` `@Named('autenticado')`; o token nunca vai para as rotas públicas e nunca é logado.

**Web (lacunas do card, branch `feat/APP10`)**
- **D-24:** Repo web em `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui` (pasta `Web` = Django), **não** `../imoveis-aqui/Web`. A `main` local foi atualizada em 2026-11-22 (fast-forward até `origin/main` = `8bf4448`, sem migração nova; as taxas novas do login têm valor padrão no `settings.py`). A `feat/APP10` da web nasce dessa `main` no primeiro plano que mexer no Django.
- **D-25:** Mudanças na web, todas atrás de `PertenceAUmaEmpresa` + `EmpresaScopedQuerySetMixin` + `restringir_ao_perfil`:
  1. paginação na listagem do `ContatoViewSet` (D-12), mantendo os filtros e a ordem;
  2. contagem dos sem retorno (D-04 a D-06);
  3. opções do filtro de imóvel (D-19).

  O PATCH e o `ContatoSerializer` não mudam (a menos que a pesquisa escolha a variante de D-06). Os testes vão em `contatos/tests.py`, no padrão de `IsolamentoTests`, `CaixaDeContatosTests` e `AnotarRetornoTests`. Cobrem paginação; contagem só de `PENDENTE` e só dos visíveis; opções só com imóveis dos contatos visíveis; e outra empresa ou outro corretor nunca aparecendo nas rotas novas. `python manage.py test` verde.

**Contrato e rastreabilidade**
- **D-26:** Novo **§17** em `01-CONTRATO-API.md`, no padrão dos §14 e §15: caixa de contatos (lista com parâmetros, envelope paginado e campos), PATCH do retorno (valores aceitos, resposta, 400/401/404), contagem, opções do filtro de imóvel e a regra de isolamento.
- **D-27:** Novos IDs em `REQUIREMENTS.md`, seção "Caixa de contatos (APP10)", mapeados para a Phase 10 no ROADMAP (`**Requirements**:`, hoje TBD) e na tabela de rastreabilidade. Cobrem os critérios 1 a 6 e as rotas da web, como as Phases 7 e 8 fizeram. Os nomes dos IDs ficam para o planejador.

**Regras do projeto (carregadas das fases anteriores)**
- **D-28 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado freezed, `Result`/falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e branco (cores só do `ColorScheme`, texto do `textTheme`), código e comentários em português, `Navigator.push` + `MaterialPageRoute`, sem go_router (F8/D-17).
- **D-29 [informational]:** `flutter analyze` limpo e `flutter test` verde **rodados à mão a cada onda**: o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter. O analyze já tem 41 infos `deprecated_member_use` pré-existentes (Flutter 3.50.1), que não são desta fase. Arquivos gerados que o `build_runner` reescreve só com CRLF são restaurados com `git checkout --`. `workflow.use_worktrees=false` (F8/D-18).

### Claude's Discretion
- Nomes de classes, arquivos e estados. Sugestão: `lib/presentation/contatos/` com `ContatosScreen`, `ContatosCubit`, `widgets/item_contato.dart`, `widgets/folha_anotar_retorno.dart`, `widgets/folha_filtro_imovel.dart`; entidades `ContatoRecebido`, `RetornoContato`, `ConsultaContatos`, `PaginaContatos`, `ImovelComContato` em `domain/`; `ContatosRepository` e use cases; `ContatosRemoteDataSource` no `Dio` autenticado. O número de Cubits (um para a tela, ou um separado para o filtro de imóvel) fica para o planejador.
- Ícone exato da entrada (D-01) e da linha do número, cores do chip de retorno (só do `ColorScheme`) e espaçamentos. Tudo é confirmado no human-check de fim de fase.
- Fuso da data mostrada: hora local do aparelho (`toLocal()`). A pesquisa confere o `TIME_ZONE` do Django, que vale para o recorte `criado_em__date` dos filtros `de`/`ate`, e anota no §17 se houver diferença.
- Valor de retorno ou canal desconhecido vindo do servidor: tratar como falha de formato na camada de dados, como os outros Models fazem (a pesquisa confere o padrão vigente).
- Quando carregar as opções do filtro de imóvel (ao abrir a tela ou ao abrir a folha), e o `firstDate` do seletor de período.
- **UI-SPEC:** como na F4/D-20, F7/D-16 e F8, as decisões D-01 a D-22 servem de contrato de UI, com confirmação no human-check de fim de fase. `/gsd-ui-phase 10` é opcional.

### Deferred Ideas (OUT OF SCOPE)
- **Caixa do gestor** (todos os contatos da empresa, coluna "Recebido por"): APP-12.
- **Filtro pela situação do retorno** (por exemplo, "só pendentes"): fora do card e do site.
- **Selo com o número de pendentes no ícone do acervo**: o card pede o número na própria tela (D-02).
- **Abrir a página do imóvel a partir do contato**: fora do card (D-11).
- **Atalhos de período** ("7 dias", "30 dias") e **puxar para atualizar**: fora do card.
- **Notificação de contato novo**: fora do card.
</user_constraints>

<phase_requirements>
## Phase Requirements

> O ROADMAP diz `Requirements: TBD` e o `REQUIREMENTS.md` ainda não tem a seção "Caixa de contatos (APP10)". Por D-27 o planejador cria os IDs. Abaixo vai uma **proposta pronta para adoção**: prefixo novo `CXA` (caixa) e `API-13`/`API-14` continuando a série `API-xx`, que hoje termina em `API-10` [VERIFIED: `.planning/REQUIREMENTS.md:67-68` — `API-09` e `API-10`; tabela de rastreabilidade termina em `| API-10 | Phase 8 | Complete |`]. Registrar é a primeira tarefa da fase (padrão das Phases 7 e 8).

| ID | Descrição proposta (texto para o REQUIREMENTS.md) | Critério / decisão | Research Support |
|----|---------------------------------------------------|--------------------|------------------|
| CXA-01 | O corretor vê "Meus contatos": a lista dos contatos que recebeu, mais recentes primeiro, vinda de `GET /api/contatos/` (paginada, rolagem infinita); cada item traz imóvel ("código — título"), canal, data e retorno atual. | Crit. 1 e 2; D-08..D-12 | R1, R7; Padrões 1-2 |
| CXA-02 | Filtro por imóvel (opções vindas de `GET /api/contatos/imoveis/`) e por período (`de`/`ate`, `showDateRangePicker` em pt-BR); os dois se combinam e o servidor resolve. | Crit. 3; D-18..D-20 | R3, R5, R6 |
| CXA-03 | O corretor anota o retorno (Falei, Visita agendada, Sem resposta, Descartado) com um toque; a anotação é gravada por `PATCH /api/contatos/<id>/` e o app espera o servidor; falhas viram SnackBar com texto fixo. | Crit. 4; D-14..D-17 | R4, R8 |
| CXA-04 | Contato de outra empresa ou de outro corretor nunca aparece na lista, na contagem nem nas opções do filtro, e o PATCH pelo id dá 404 — garantido e testado no Django. | Crit. 5; D-13 | R2, R3, R10 |
| CXA-05 | A tela mostra quantos contatos estão sem retorno anotado (`GET /api/contatos/resumo/` → `{"sem_retorno": N}`), calculado no Django, sem filtros, atualizado ao abrir e depois de cada anotação. | Crit. 6; D-04..D-07, D-22 | R2, R8 |
| CXA-06 | A caixa abre por um ícone na `AppBar` do "Meu acervo" (só o corretor); qualquer 401 encerra a sessão e abre o login com o aviso "Sua sessão terminou. Entre de novo."; os textos de estado são fixos do app. | D-01..D-03, D-21..D-23 | R7, R8 |
| API-13 | O §17 de `01-CONTRATO-API.md` congela a lista paginada, os parâmetros, os 12 campos do item, o PATCH (valores, resposta, 400/401/403/404/405), a contagem, as opções do imóvel, o fuso e o isolamento, com fixtures capturadas do Django e testes de contrato nos dois repositórios. | D-26 | R9 |
| API-14 | A web entrega, com testes, a paginação de `GET /api/contatos/`, `GET /api/contatos/resumo/` e `GET /api/contatos/imoveis/`, todas atrás de `PertenceAUmaEmpresa` e do escopo de empresa e perfil. | D-25 | R1, R2, R3 |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Fontes lidas: `.claude/CLAUDE.md` do app (carregado no contexto), `CLAUDE.md` da raiz do repo web (29 linhas) e `.claude/skills/flutter-frontend/skill` (arquivo chama-se `skill`, sem extensão; `name: flutter-md3-expert`). [VERIFIED: leitura nesta sessão]

- **Arquitetura (não negociável):** `data/` (Models com serialização, Repositories, Data Sources), `domain/` (UseCases puros, interfaces de Repository), `presentation/` (Widgets limpos, Cubits). Widget nunca faz lógica de negócio nem chamada de rede.
- **Estado:** Cubit (flutter_bloc), estados imutáveis (freezed). **Erros:** `Result`/sealed + `Loading`/`Success<T>`/`Failure(Exception)`; sem `try/catch` genérico na UI.
- **Modelos de API:** todo JSON em Models imutáveis (`freezed` + `json_serializable`); nunca `dynamic` onde a tipagem forte couber.
- **UI:** Material 3, `ColorScheme.fromSeed`, widgets de `material.dart`, `Theme.of(context).textTheme`; paleta verde e branco; nenhuma cor fora do `ColorScheme`.
- **Skill flutter-md3-expert:** construtores `const` sempre; **não** criar métodos `Widget buildX()` (extrair classes `StatelessWidget`); evitar `!`; pattern matching do Dart 3; componentes visuais não fazem HTTP.
- **Regra de negócio:** nada que "valha dinheiro" ou mude estado é decidido no app (aqui: contagem, retorno gravado e "quem vê" vêm prontos do Django). **Isolamento multitenant:** toda consulta filtra pela empresa do usuário logado (CLAUDE.md do web); administrador não pertence a nenhuma empresa.
- **Idioma:** código, models, variáveis e comentários em português. **Branches:** `feat/APP10` nos dois repos.
- **Segurança (CLAUDE.md do web):** nunca token/senha no código; `.env`. Não editar `.gitignore` sem avisar. **Git (web):** nenhum commit/push sem autorização — aqui D-B libera commits locais do GSD; **push só com autorização explícita**.
- **Workflow GSD:** edições de arquivo só dentro de um comando GSD.

## Summary

A web já entrega 80% da fase: `ContatoViewSet` lista, filtra, mostra o detalhe e anota o retorno, com `PertenceAUmaEmpresa` + `EmpresaScopedQuerySetMixin` + `restringir_ao_perfil`. Faltam três coisas, todas pequenas e todas cabendo no padrão que a Phase 8 usou no acervo: (1) **paginação** só na `list` (`pagination_class` na ViewSet; as `@action` devolvem `Response` direto e não paginam); (2) **`GET /api/contatos/resumo/`** → `{"sem_retorno": N}` como `@action(detail=False)`; (3) **`GET /api/contatos/imoveis/`** → `[{id, codigo, titulo}]` como `@action(detail=False)`. Rodei as três num experimento com SQLite em memória (ViewSet derivada fora do repo) e todas se comportam como o CONTEXT quer: o router do DRF registra as rotas de lista (`imoveis/`, `resumo/`) **antes** da rota de detalhe `(?P<pk>[^/.]+)/`, então não há colisão; corretor vê só os dele, gestor os da empresa, a outra empresa só os dela, administrador 403 e anônimo 401.

No app, quase tudo é reaproveitamento do stack do acervo: DataSource fino no `Dio` `@Named('autenticado')` com `seguir(next)` + `mesmaOrigem`, Repository que traduz 401/403/404/demais em falhas tipadas, Cubit paginado com token de versão, `RodapePaginacaoLista`, o fluxo de sessão expirada e o `ApiFalsa` com fixtures capturadas. O trabalho novo de verdade é (a) o estado "anotando este item" dentro de um estado freezed imutável, (b) o seletor de período em pt-BR, que exige `flutter_localizations` (já é dependência **transitiva**; basta declará-la) e `localizationsDelegates`/`supportedLocales` no `MaterialApp` de `lib/main.dart`, e (c) novas fixtures capturadas do Django (grupo `contatos` na ferramenta de captura).

**Primary recommendation:** Faça a web primeiro (paginação + `resumo` + `imoveis` + um endurecimento de 3 linhas no PATCH, ver Achado 2) e congele o §17 com fixtures capturadas; no app use **um único Cubit** (`lista + contagem + opções do imóvel + anotando`), um `Set<int>` de itens em anotação dentro do estado `carregada`, e um campo one-shot `aviso` para a SnackBar, repetindo o padrão `ContatoCubit`/`BarraContato`.

### Achados que mudam o plano (não estavam no CONTEXT)

1. **Só o app consome `GET /api/contatos/`; o envelope pode entrar sem custo de compatibilidade.** `grep` em todo o repo web (py/html/js/md) e em **todas** as branches remotas: as únicas referências são `contatos/tests.py` (via `reverse("contato-list")`) e o `README.md` (linhas 188-189). O diretório `App/` do repo web está vazio. O app (`lib/`) não referencia `/api/contatos` hoje. Os relatórios têm rota própria (`/api/relatorios/contatos/`). O único teste que itera a resposta como lista é o helper `ContatoBase.ids_api` (`for item in response.data` → passa a `response.data["results"]`); as demais chamadas só checam `status_code`. A linha 188 do README precisa ser atualizada. [VERIFIED: `grep`/`git grep` nesta sessão; `contatos/tests.py`, helper `ids_api`]
2. **BUG latente: `PATCH /api/contatos/<id>/` com corpo vazio `{}` dá `KeyError` (500).** O `ContatoSerializer.update` faz `validated_data["retorno"]` e, no PATCH (`partial=True`), o campo `retorno` não é obrigatório. Reproduzido: `KeyError: 'retorno'` em `contatos/api/serializers.py:34`. O app nunca manda corpo vazio, mas é um 500 numa rota autenticada (vaza traceback se `DEBUG=True`). Correção de 3 linhas verificada (`validate()` levantando `ValidationError({"retorno": ["Este campo é obrigatório."]})` → 400). **Isso contraria o texto "O PATCH e o `ContatoSerializer` não mudam" do D-25** — está na lista de Open Questions para o Allysson aprovar; a recomendação é incluir (1 linha de código + 1 teste).
3. **`RodapePaginacaoLista` tem o texto fixo "Não foi possível carregar mais imóveis".** Reaproveitá-lo na caixa mostraria "imóveis" para uma lista de contatos. Precisa de um parâmetro opcional `mensagemErro` (padrão = o texto atual, para não quebrar acervo/vitrine). [VERIFIED: `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart:46`]
4. **O gate "41 infos" não vale para arquivos novos.** As 41 infos de hoje são exatamente 1 por arquivo que importa `package:flutter/material.dart` (41 arquivos; mensagem "deprecated ... Use package:material_ui/material_ui.dart"). Todo arquivo novo de tela/widget que importar `material.dart` soma +1 info do mesmo tipo. Migrar o app para `material_ui` está fora do escopo (`material_ui` só é dependência transitiva). O gate correto da fase: **0 errors/warnings e nenhuma info que não seja `deprecated_member_use` do import de `material.dart`** (baseline 41 + 1 por arquivo novo que importa `material.dart`).
5. **`ApresentacaoCanalContato.rotulo` é o rótulo de AÇÃO ("Ligar", "Enviar e-mail"), não o nome do canal.** O item da caixa precisa de "WhatsApp", "Telefone", "E-mail" (D-09): criar uma extensão nova em `apresentacao_contatos.dart` e reaproveitar só o `.icone`. [VERIFIED: `lib/presentation/contato/rotulos_contato.dart:11-21`]
6. **Colisão de nomes com a Phase 6.** Já existem `ContatoRepository`, `ContatoDataSource`, `ContatoRemoteDataSource`, `ContatoCubit`, `ContatoState`, `ContatoRegistradoModel`, `ContatoDoImovel` (contato do **visitante**, POST público). Os nomes sugeridos no CONTEXT (`ContatosRepository`, `ContatosCubit`) diferem por uma letra e vão confundir quem lê. Recomendação: prefixo `CaixaContatos*` para Repository/DataSource/Cubit/Screen (ver Standard Stack).
7. **Datas em testes dependem do fuso da máquina se a conversão `toLocal()` ficar dentro do formatador.** `DateTime.parse('...-03:00')` devolve UTC (`isUtc == true`). Recomendação: o formatador é função pura sobre um `DateTime` já local; a conversão `toLocal()` fica em um único ponto; testes de formatação usam `DateTime(2026, 1, 9, 22, 30)` (local) e a tela recebe a entidade com `DateTime` local. Ver Pitfall 5.
8. **As fixtures precisam de ≥ 21 contatos para existir a página 2** (`page_size = 20`) e o seed não cria contatos. A captura precisa gerá-los pela própria API pública (POST de contato, como o grupo `contato`), com `CONTATO_TAXA_ANONIMA=1000/min`. Os seeds `semear_vitrine_dev` e `seed_demo` não referenciam `Contato` (`grep` sem ocorrências).

## Resolução dos itens de pesquisa (R1–R10)

### R1 — D-12: paginação (consumidores, padrão vigente, como aplicar só na `list`)

**Quem consome:** ninguém além do app (Achado 1). Decisão: **mudar a `list` para envelope é seguro**; atualizar `ids_api` e o README.

**Padrão vigente da APP-05/APP-08** (classe, onde mora, tamanho):
```python
# imoveis/vitrine.py:26
IMOVEIS_POR_PAGINA = 20
# imoveis/api/views.py:69-72
class PaginacaoAcervo(PageNumberPagination):
    """Acervo do corretor: 20 por página, como as vitrines, e o cliente não muda o tamanho (D-10)."""

    page_size = IMOVEIS_POR_PAGINA
# imoveis/api/views.py:79-80
    # só `list` pagina: retrieve/create/update e as @action não chamam o paginador
    pagination_class = PaginacaoAcervo
```
[VERIFIED: `imoveis/vitrine.py:26`, `imoveis/api/views.py:69-80`] Não há `PAGE_SIZE`/`DEFAULT_PAGINATION_CLASS` global em `REST_FRAMEWORK` (`config/settings.py:177-198` só tem autenticação, permissão, `DEFAULT_THROTTLE_RATES` e `NUM_PROXIES`), então a paginação é por ViewSet. O envelope é `{count, next, previous, results}`, `next`/`previous` absolutos; o cliente **não** muda o tamanho (sem `page_size_query_param`) — experimento: `?page_size=50` ignorado. [VERIFIED: experimento nesta sessão + `01-CONTRATO-API.md` §14.5]

**Recomendação (prescritiva):** em `contatos/api/views.py`, uma `PaginacaoContatos(PageNumberPagination)` com `page_size = 20` (constante local `CONTATOS_POR_PAGINA = 20`, para não acoplar a caixa à constante dos imóveis; o valor é o mesmo da APP-05/08) e `pagination_class = PaginacaoContatos` na `ContatoViewSet`. Como o `PageNumberPagination` só é chamado pelo `ListModelMixin.list`, `retrieve`/`partial_update` e as `@action` novas **não** paginam (as `@action` devolvem `Response` direto — experimento confirmou `resumo`/`imoveis` sem envelope). O `site` continua com `paginate_by = 50` na `ContatoListView` (não muda). [VERIFIED: `contatos/views.py:26`]

**Efeitos nos testes existentes:** só `ids_api` quebra (itera `response.data`; passa a `response.data["results"]`). `IsolamentoTests`, `CaixaDeContatosTests` e `AnotarRetornoTests` usam `ids_api` (lista) e/ou `status_code`, e `reverse("contato-detail")`; nada mais lê o corpo da lista. Com ≤ 20 contatos por usuário nos cenários atuais (≤ 4), a primeira página traz tudo.

**`next` preserva os filtros e a ordem:** experimento com `page_size=1`, `?de=2026-01-01&ate=2026-12-31`, `HTTP_HOST=10.0.2.2:8000` → `next = http://10.0.2.2:8000/apix/contatos/?ate=2026-12-31&de=2026-01-01&page=2`. Absoluto, com a origem do `Host` e com os filtros. `?page=9` → 404 `{"detail": "Página inválida."}`. A lista custa 5 queries (com `select_related("imovel","corretor")`). [VERIFIED: experimento]

### R2 — D-04..D-06: contagem dos `PENDENTE`

**Decisão: rota própria `GET /api/contatos/resumo/` → `{"sem_retorno": N}`** (a variante recomendada pelo CONTEXT). A alternativa "campo no envelope da lista" é pior: o `count` do envelope já respeita os filtros (violaria D-05), exigiria um paginador customizado e uma 2ª consulta em toda página; e o PATCH teria de devolver o total (mudaria o `ContatoSerializer`).

**Ordem do router (pedido do briefing):** o `DefaultRouter` do DRF 3.18.1 registrou, na ordem: `contatos/`, `contatos/imoveis/`, `contatos/resumo/`, **depois** `contatos/(?P<pk>[^/.]+)/`. `resolve("/apix/contatos/resumo/")` → `contatox-resumo`, `resolve("/apix/contatos/imoveis/")` → `contatox-imoveis`, `resolve("/apix/contatos/5/")` → `contatox-detail`. Ou seja, `resumo`/`imoveis` **não colidem** com o `{pk}` (a rota de detalhe é `[^/.]+`, que casaria "resumo", mas vem depois). Nomes de rota resultantes com `basename="contato"`: `contato-resumo` e `contato-imoveis` (teste de regressão: `resolve(reverse("contato-resumo")).url_name == "contato-resumo"` e `reverse("contato-detail", args=[5])` continua `…/5/`). [VERIFIED: experimento — ViewSet derivada com `@action(detail=False)` registrada num router próprio]

**Escopo e filtros ignorados por construção:** o `resumo` usa `contatos_visiveis_para(request.user)` — a mesma função do site (`contatos/servicos.py:126-130`: empresa do usuário, depois `restringir_ao_perfil`) — e **não chama** `filtrar_contatos`, então `?imovel=`/`?de=`/`?ate=` nunca entram. (Alternativa equivalente: `self.get_queryset()`; para `self.action != "list"` o `get_queryset` devolve só empresa+perfil sem filtros. Preferir `contatos_visiveis_para` por ser o ponto único de verdade usado pelo painel e documentado como o critério 6.)

Resultados medidos (cenário `ContatoBase` com 4 contatos: 2 do corretor, 1 do corretor 2, 1 da outra empresa): corretor `{'sem_retorno': 2}`; gestor `{'sem_retorno': 3}`; corretor da outra empresa `{'sem_retorno': 1}`; administrador **403**; anônimo **401** com `WWW-Authenticate: Token`. Após o PATCH `FALEI` o total cai (contato deixa de ser `PENDENTE`).

### R3 — D-19: opções do filtro de imóvel

**`GET /api/contatos/imoveis/` → lista JSON (sem envelope, sem paginação) de `{"id", "codigo", "titulo"}` ordenada por `codigo`**, com a mesma consulta do site (`contatos/views.py:46-50`):
```python
"imoveis": Imovel.objects.filter(
    pk__in=contatos_visiveis_para(self.request.user).values("imovel")
).order_by("codigo"),
```
[VERIFIED: `contatos/views.py:46-50`] Experimento: corretor → `[{'id': 1, 'codigo': 'CASA-INTERNO-1', ...}, {'id': 2, 'codigo': 'CASA-INTERNO-2', ...}]`; gestor → 3 imóveis (inclui `DO-CORRETOR-2`); corretor da outra empresa → só `OUTRA-1`; admin 403; anônimo 401.

**Sem paginação é aceitável:** o resultado é limitado aos imóveis que têm pelo menos um contato visível; para o corretor, ≤ o acervo dele; para o gestor (não usado no app nesta fase, D-03) ≤ o acervo da empresa. Estimativa: ~90 bytes por item → 1.000 imóveis ≈ 90 KB. A APP-12 (caixa do gestor) pode precisar de busca/limite, anotado como risco aceito no §17. [ASSUMED: tamanho médio por item; ordem de grandeza, não medido em produção]

**Quando carregar (discricionário):** recomendação = **ao abrir a folha** (carga preguiçosa), guardando o resultado só enquanto a folha existe; reabrir busca de novo. Motivos: não custa uma requisição se o corretor nunca filtra por imóvel; a lista é atual (um contato novo pode ter trazido um imóvel novo); o chip "Imóvel" só precisa de `id` + `codigo` do item escolhido, que o Cubit já guarda em `consulta.imovel` — não depende de pré-carga.

### R4 — D-14..D-17: contrato do PATCH (medido)

`PATCH /api/contatos/<id>/` com `Content-Type: application/json`, corpo `{"retorno": "FALEI"}` (experimento, corretor dono do contato):

| Caso | Status | Corpo (medido) |
|------|--------|----------------|
| Sucesso | **200** | o `ContatoSerializer` completo (12 chaves): `{"id": 1, "imovel": 1, "imovel_codigo": "CASA-INTERNO-1", "imovel_titulo": "Casa com quintal", "corretor": 1, "corretor_nome": "Corretor Teste", "canal": "WHATSAPP", "canal_exibicao": "WhatsApp", "criado_em": "2026-11-22T21:48:24.683322-03:00", "retorno": "FALEI", "retorno_exibicao": "Falei", "retorno_em": "2026-11-22T21:48:24.713319-03:00"}` |
| `retorno = "PENDENTE"` | **400** | `{"retorno": ["\"PENDENTE\" não é uma escolha válida."]}` |
| `retorno = "XYZ"` | **400** | `{"retorno": ["\"XYZ\" não é uma escolha válida."]}` |
| `retorno = ""` | **400** | `{"retorno": ["\"\" não é uma escolha válida."]}` |
| corpo `{}` | **500 hoje** (`KeyError: 'retorno'`) → **400** com o `validate()` proposto: `{"retorno": ["Este campo é obrigatório."]}` | Achado 2 |
| `PUT` | **405** | `{"detail": "Método \"PUT\" não é permitido."}` (`http_method_names = ["get", "patch", "head", "options"]`) |
| contato de **outro corretor** (mesma empresa) | **404** | `{"detail": "No Contato matches the given query."}` |
| contato de **outra empresa** | **404** | idem |
| **administrador** | **403** | `{"detail": "Este recurso é restrito a usuários vinculados a uma empresa."}` |
| sem token | **401** | `{"detail": "As credenciais de autenticação não foram fornecidas."}` + `WWW-Authenticate: Token` |

Campos extras no corpo (`canal`, `imovel`) são ignorados (`read_only_fields`; já coberto por `test_api_anota_o_retorno_e_nao_deixa_mudar_o_resto`). `POST`/`DELETE` → 405 (já coberto). O app só olha o **status** e o item do 200 (D-17: nunca o texto). Barra final obrigatória: `/api/contatos/<id>/` — sem ela o `APPEND_SLASH` não redireciona PATCH e o `Dio` autenticado tem `followRedirects: false` (Pitfall 2).

Valores (verbatim):
```python
# contatos/models.py:25-36 (Retorno e RETORNOS_ANOTAVEIS)
class Retorno(models.TextChoices):
    PENDENTE = "PENDENTE", "Aguardando retorno"
    FALEI = "FALEI", "Falei"
    VISITA_AGENDADA = "VISITA_AGENDADA", "Visita agendada"
    SEM_RESPOSTA = "SEM_RESPOSTA", "Sem resposta"
    DESCARTADO = "DESCARTADO", "Descartado"

RETORNOS_ANOTAVEIS = [
    Retorno.FALEI, Retorno.VISITA_AGENDADA, Retorno.SEM_RESPOSTA, Retorno.DESCARTADO,
]
# contatos/models.py:20-23 (Canal)
class Canal(models.TextChoices):
    WHATSAPP = "WHATSAPP", "WhatsApp"
    TELEFONE = "TELEFONE", "Telefone"
    EMAIL = "EMAIL", "E-mail"
```
[VERIFIED: `contatos/models.py:20-36` — lido com `Read`/`cat` nesta sessão]

### R5 — D-20: `showDateRangePicker` em pt-BR

**Estado de hoje:** o único `MaterialApp` de produção está em `lib/main.dart:59` (`MaterialApp(title: 'Imóveis Aqui', theme: AppTheme.tema, home: const _TelaInicial())`); sem `localizationsDelegates`/`supportedLocales`. O `pubspec.yaml` não declara `flutter_localizations`. [VERIFIED: `lib/main.dart:59-63`, `pubspec.yaml`]

**O que mudar (mínimo):**
1. `pubspec.yaml`, em `dependencies`: `flutter_localizations:` com `sdk: flutter`. É pacote do SDK (sem registry). `flutter pub add flutter_localizations --sdk=flutter --dry-run` resolve limpo: `flutter_localizations 0.0.0 from sdk flutter (from transitive dependency to direct dependency)` / `Would change 1 dependency` — hoje já é **transitiva**; só muda o marcador no `pubspec.lock`. `flutter_localizations` exige `intl: ^0.20.3`, igual ao pubspec (`intl: ^0.20.3`), sem conflito. [VERIFIED: `flutter pub add ... --dry-run` + `/c/src/flutter/packages/flutter_localizations/pubspec.yaml`]
2. `MaterialApp(localizationsDelegates: GlobalMaterialLocalizations.delegates, supportedLocales: const [Locale('pt', 'BR')], ...)` (import `package:flutter_localizations/flutter_localizations.dart`). **Sem** `locale:` fixo: em aparelho com outro idioma o Flutter cai no primeiro `supportedLocales` (pt-BR). Recomendação extra: extrair para uma constante em `lib/app_localizacao.dart` (`delegatesDeLocalizacao`, `localesSuportados`) para o `main.dart` **e** o teste da tela usarem a mesma configuração.
3. `generate: true`/ARB **não** são necessários (só `GlobalMaterialLocalizations`).

**Provado (experimento num pacote de teste isolado no scratchpad, com o mesmo SDK):** com `GlobalMaterialLocalizations.delegates` + `supportedLocales: [Locale('pt','BR')]` o `showDateRangePicker` mostra: `D S T Q Q S S`, `novembro de 2026`, `Salvar`, `Selecione o intervalo`, `Data de início`, `Data de término`; tooltips `Fechar` e `Mudar para modo de entrada`. Sem delegates (como todos os testes de hoje) aparece em inglês (`Save`, `Select range`, `Start Date`, `End Date`). [VERIFIED: `flutter test` do experimento]

**Impacto em `intl` e nos formatadores existentes:** o `NumberFormat('#,##0', 'pt_BR')` etc. (`mascara_numerica.dart`, `apresentacao_filtros.dart`, `apresentacao_natureza.dart`, `apresentacao_imovel.dart`) usam locale **explícito** e dados de número embutidos no `intl`: `NumberFormat('#,##0','pt_BR').format(1234567)` → `1.234.567` sem nenhuma inicialização (rodado com `dart`). Ativar os delegates **não muda** `Intl.defaultLocale`: continua `en_US` (medido no experimento: `defaultLocale: en_US / current: en_US`). Logo, nada dos formatadores atuais muda. **Para as datas da caixa use `DateFormat('dd/MM/yyyy HH:mm')` SEM locale** (padrão só numérico, independe de locale): funciona com e sem os delegates; `DateFormat('...', 'pt_BR')` explícito **lança** `LocaleDataException: Locale data has not been initialized, call initializeDateFormatting(<locale>)` quando os delegates não carregaram (todo teste de widget sem delegates) — medido com `dart`. [VERIFIED: experimentos `fmt.dart` e `picker_test.dart`]

**Impacto nos testes existentes:** os testes de widget montam o **próprio** `MaterialApp` (sem delegates) e não mudam. O único teste que usa o `MaterialApp` de produção é `test/main_launch_routing_test.dart` (`pumpWidget(const ImoveisAquiApp())`, 7 vezes); `grep` por `byTooltip`, `'Back'`, `'Close'`, `'Cancel'`, `'OK'`, `'Search'`, `BackButton` nesse arquivo → **sem ocorrências**, então os textos padrão do Material (que passam a pt-BR) não são consultados. O `Localizations` do Material carrega de forma síncrona (`SynchronousFuture`, `util.loadDateIntlDataIfNotLoaded()`), sem quadro extra. Confirmar rodando `flutter test test/main_launch_routing_test.dart` na onda. [VERIFIED: grep; carga síncrona lida em `material_localizations.dart:722-737`; efeito no teste real: a confirmar na execução]

**`firstDate` / `lastDate` / `initialDateRange` (recomendação):** `lastDate = hoje` (date-only; contato futuro não existe — `criado_em` é `auto_now_add`); `firstDate = DateTime(2024)` (anterior a qualquer contato: a caixa nasceu na W11 em 2026); `initialDateRange` = o período já aplicado, se houver. [ASSUMED: `2024` é escolha de produto — o Allysson pode preferir `DateTime(2026)`; nenhum contato anterior a 2026 pode existir]. Para o texto do seletor use `helpText: 'Selecione o período'` e `saveText: 'Aplicar'` (opcionais; o pt-BR padrão já é "Selecione o intervalo"/"Salvar").

**Formato enviado:** `de`/`ate` como `AAAA-MM-DD` formatados **do `DateTime` local escolhido, sem `toUtc()`** (formatar em UTC deslocaria o dia). Fica só em `data/` (`parametros_consulta_contatos.dart`), como o acervo faz com `parametrosDaConsultaAcervo`.

### R6 — Fuso e formato de data no fio

- `config/settings.py`: `TIME_ZONE = 'America/Sao_Paulo'`, `USE_TZ = True`, `LANGUAGE_CODE = 'pt-br'`. [VERIFIED: `config/settings.py:117-123`]
- **No fio**, `criado_em` e `retorno_em` saem em ISO-8601 **com offset de São Paulo**: `"2026-11-22T21:48:24.683322-03:00"`; `retorno_em` nulo → `null` (medido em respostas reais do `ContatoSerializer`). `DateTime.parse` do Dart converte para UTC (`isUtc == true`); `toLocal()` devolve a hora do aparelho.
- **Recorte dos filtros:** `filtrar_contatos` usa `criado_em__date__gte/lte`, que com `USE_TZ=True` interpreta o dia **em `America/Sao_Paulo`**. Prova: contato com `criado_em = 2026-01-10T01:30Z` (= 09/01 22:30 em SP) → `de=ate=2026-01-09` **acha**; `de=ate=2026-01-10` **não acha** (experimento). `README.md:152` já documenta "dia de São Paulo" nos relatórios.
- **Conclusão para o §17:** `de`/`ate` são **dias de São Paulo**; `criado_em`/`retorno_em` vêm com offset `-03:00` (o Brasil não tem horário de verão desde 2019 [ASSUMED: sem DST atual; o `zoneinfo` do servidor é quem decide]). `toLocal()` bate com o site em aparelho no fuso de Brasília; em aparelho em outro fuso (Manaus `-04:00`, Rio Branco `-05:00`, Noronha `-02:00`) a hora mostrada difere do site em 1-2 h, e o dia escolhido no seletor continua valendo como dia de SP. Documentar como risco aceito; manter `toLocal()` (decisão do CONTEXT). Ver A3.

### R7 — Mapa de reaproveitamento do app (leitura do código)

| Peça existente | Arquivo | Reuso na fase |
|----------------|---------|---------------|
| DataSource fino + `seguir(next)` com `mesmaOrigem` | `lib/data/datasources/acervo_remote_datasource.dart`, `acervo_datasource.dart`, `lib/data/network/mesma_origem.dart` | Copiar o desenho: `buscar(consulta)`, `seguir(next)` (lança `FormatException` se origem ≠ base), + `contarSemRetorno()`, `listarImoveis()`, `anotarRetorno(id, retorno)` |
| Tradução de erros em `Result` | `lib/data/repositories/acervo_repository_impl.dart` | Cadeia única `_executar`: `SessaoExpiradaException` direta ou em `DioException.error` → 403 `SemPermissaoException` → demais `DioException` → `TypeError` → `FormatException` do Model. Acrescentar **404 → `ContatoNaoEncontradoException`** só no PATCH |
| Falhas tipadas | `lib/domain/repositories/falhas_autenticacao.dart` (`SessaoExpiradaException`, `SemPermissaoException`, `FalhaDeConexaoException`) | Reaproveitar; criar `ContatoNaoEncontradoException` num arquivo novo em `domain/repositories/` |
| Envelope paginado | `lib/data/models/acervo_envelope_model.dart` (`next`, `previous`, `results`; `count` ignorado) | Copiar para `ContatosEnvelopeModel` (não-genérico, como os outros) |
| Item com enum no Model | `lib/data/models/imovel_acervo_model.dart` (`finalidade` desconhecida → `FormatException`; `situacao` desconhecida → `null`) | **Padrão vigente para enum desconhecido:** campo obrigatório → `FormatException` (o Repository converte em falha); campo opcional/de enfeite → `null`. Para `canal` e `retorno` (ambos obrigatórios e essenciais) usar **`FormatException`**, como `finalidade` e como `EuModel.paraPapel` (`perfil desconhecido`) |
| `Dio` autenticado + interceptor | `lib/di/modulo_rede.dart` (`@Named('autenticado')`, `followRedirects:false`, timeouts 10 s), `lib/data/network/interceptador_sessao.dart` | Nada a mudar: o token só vai para a origem da base URL; todo 401 vira `DioException.error = SessaoExpiradaException` |
| Cubit paginado | `lib/presentation/acervo/acervo_cubit.dart` + `acervo_state.dart` | Copiar: `_versaoConsulta`, `isClosed` antes de todo `emit`, `carregarMais`/`tentarNovamente`/`_carregarProximaPagina`, dedupe por id |
| Tela, rolagem e sessão | `lib/presentation/acervo/acervo_screen.dart` | Copiar: `BlocListener` de sessão expirada → `encerrarPorExpiracao()` + `pushAndRemoveUntil(LoginScreen(aviso: avisoSessaoTerminou), eRotaDaVitrine)`; `ScrollController(keepScrollOffset: false)`, `_aoRolar` a 90%, guarda "lista não preenche a tela", `_MensagemDoAcervo`. Extrair o `_aoSessaoExpirar` para um helper em `presentation/sessao/` é opcional (3ª cópia) |
| Rodapé | `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart` | Reusar, com `mensagemErro` opcional (Achado 3) |
| Folha (bottom sheet) | `lib/presentation/contato/widgets/contato_bottom_sheet.dart` (`showModalBottomSheet`, `showDragHandle`, `ListTile`s, `Navigator.pop` + callback capturado da TELA com `context.read`) | Padrão da folha de anotação e da folha de imóvel (a rota do modal fica fora do `BlocProvider`: passar o Cubit/callback **por valor**) |
| Chips com "x" | `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` (`InputChip(onPressed, onDeleted, deleteButtonTooltipMessage)`) | Modelo dos chips "Imóvel"/"Período" (D-18) |
| Ícones de canal | `lib/presentation/contato/rotulos_contato.dart` | `Icons.chat`, `Icons.call`, `Icons.email_outlined` (só `.icone`; rótulo próprio — Achado 5) |
| Canal no domínio/wire | `lib/domain/entities/canal_contato.dart` (`enum CanalContato { whatsapp, telefone, email }`), `lib/data/models/canal_contato_api.dart` (`valorApi`: `'WHATSAPP'`, `'TELEFONE'`, `'EMAIL'`) | Reusar o enum; criar o **inverso** (wire → enum) em `data/` (`CanalContatoNaApi.deValorApi`), pois só existe `valorApi` (enum → wire) |
| Sessão | `lib/presentation/sessao/sessao_cubit.dart` (`encerrarPorExpiracao()`), `rota_vitrine.dart` (`eRotaDaVitrine`), `lib/presentation/login/apresentacao_login.dart` (`avisoSessaoTerminou = 'Sua sessão terminou. Entre de novo.'`) | Reusar sem mudança |
| Entrada | `AcervoScreen` é aberta por `login_screen.dart:78` e `entrada_area_screen.dart:49` (`Papel.corretor => const AcervoScreen()`) | O ícone entra na `AppBar` (`actions`) antes do `Icons.logout`; injetar o destino por callback padrão (como `aoAbrirImovel = abrirDetalheImovel`) para o teste do acervo não depender de DI |
| Fake de API | `test/support/api_falsa.dart` (`ApiFalsa`, `lerFixtureApi`, `responder`, `falharProximas`, `chamadas` com corpo/cabeçalhos, `criarDioAutenticado`) | Acrescentar rotas de contatos (ver Validation Architecture) |
| Captura de fixtures | `tool/capturar_fixtures_api.py` (grupos `lista/detalhe/contato/perfis/anunciante/acervo`; `GRUPOS`, `argparse choices`, `salvar`, `obter`, `postar`, `_entrar` com env `CAPTURA_*`) | Novo grupo `contatos` (R9/Validation); **`todos` nunca** para só acrescentar um grupo |
| Contrato antidrift | `test/data/contrato_acervo_test.dart` (exemplos em `.planning/phases/01-.../contrato/*.example.json` = cópia byte a byte da fixture; chaves exatas) | Novo `contrato_contatos_test.dart` no mesmo padrão |
| DI | `injectable` (`@LazySingleton(as: ...)`, `@injectable`), `lib/di/injection.config.dart` (gerado, versionado) | Rodar `dart run build_runner build -d`; restaurar com `git checkout --` arquivos gerados que mudarem só CRLF (D-29) |

### R8 — Estado por item em voo e SnackBar sem `try/catch` na UI

**Um único `CaixaContatosCubit`** (recomendação; a decisão do número de Cubits é do planejador). Razões: (a) **um só caminho de 401** (lista, contagem, opções e PATCH convergem em `ConteudoCaixa.sessaoExpirada`, e a tela tem um único `BlocListener`); (b) a consulta, o item em anotação e a contagem se influenciam (404 recarrega os dois; sucesso recarrega a contagem); (c) a folha de imóvel recebe o Cubit **por valor** (padrão do `mostrarFiltrosBottomSheet`: "nunca criado/fechado pelo sheet").

Forma do estado (freezed, imutável; `Set<int>` vira `EqualUnmodifiableSetView` no freezed):
```dart
@freezed
abstract class CaixaContatosState with _$CaixaContatosState {
  const factory CaixaContatosState({
    @Default(ConsultaContatos()) ConsultaContatos consulta,   // imóvel? + período?
    int? semRetorno,                                         // null = ainda não veio / falhou (D-22)
    @Default(OpcoesDeImovel.naoCarregadas()) OpcoesDeImovel opcoesDeImovel,
    @Default(ConteudoCaixa.carregando()) ConteudoCaixa conteudo,
    AvisoCaixa? aviso,                                       // one-shot da SnackBar (D-17)
  }) = _CaixaContatosState;
}

@freezed
sealed class ConteudoCaixa with _$ConteudoCaixa {
  const factory ConteudoCaixa.carregando() = CaixaCarregando;
  const factory ConteudoCaixa.vazio() = CaixaVazia;               // sem filtro, 0 itens
  const factory ConteudoCaixa.semResultado() = CaixaSemResultado;  // com filtro, 0 itens
  const factory ConteudoCaixa.erro() = CaixaErro;
  const factory ConteudoCaixa.sessaoExpirada() = CaixaSessaoExpirada;
  const factory ConteudoCaixa.carregada({
    required List<ContatoRecebido> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
    @Default(<int>{}) Set<int> anotando,                         // ids com PATCH em voo
  }) = CaixaCarregada;
}

enum AvisoCaixa { falhouAoAnotar, contatoSumiu }
```
(Padrão = `AcervoState`/`ConteudoAcervo` + `ContatoState.falhou(motivo)`; ver "Code Examples".)

Fluxo de `anotarRetorno(id, retorno)`:
1. Guarda: só em `CaixaCarregada`; ignora se `id` já está em `anotando` (D-16: "ignora novos toques") ou se `isClosed`. (Tocar na opção **já atual**: recomendação = não chamar a API e só fechar a folha; ver A6.)
2. `emit` com `anotando + {id}` e `aviso: null` (limpar o aviso aqui garante que a próxima falha seja uma emissão **diferente** da anterior — o `Cubit` ignora `emit` de estado igual).
3. `await _anotar(id, retorno)`; checar `isClosed`.
4. **Success(contato):** trocar o item pelo `id` (se ainda estiver na lista), tirar `id` de `anotando`; **sempre** disparar `unawaited(_recarregarResumo())` (D-06), mesmo que a lista tenha sido reiniciada no meio.
5. **Failure:** `SessaoExpiradaException` → `conteudo: sessaoExpirada`; `ContatoNaoEncontradoException` → tirar de `anotando`, `aviso: contatoSumiu`, e recarregar lista **e** número (`_aplicarConsulta` + resumo); demais (rede, timeout, 5xx, 400, `FormatException`) → tirar de `anotando`, `aviso: falhouAoAnotar`. O item **fica como estava** (nenhuma troca otimista).
6. **Versão:** `_versaoConsulta` protege a lista (uma resposta de PATCH que chega depois de o corretor trocar o filtro não pode reabrir a lista antiga: ao reconstruir `CaixaCarregada` o `anotando` nasce vazio, e o `map` por id simplesmente não acha o item); `_versaoResumo` impede que um `resumo` velho sobrescreva um novo.

A tela mostra o item com `LinearProgressIndicator`/spinner e `onTap: null` quando `anotando.contains(item.id)`. A SnackBar sai de um `BlocListener` com `listenWhen: (a, b) => b.aviso != null && a.aviso != b.aviso`, `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(...)` (mesmo desenho de `BarraContato`, `lib/presentation/contato/widgets/barra_contato.dart:48-56`), com **textos fixos** de D-17 num `switch` exaustivo sobre `AvisoCaixa` em `apresentacao_contatos.dart`. Nenhum `try/catch` na UI: o Cubit decide só pelo **tipo** da falha. [VERIFIED: padrão `ContatoCubit` — `lib/presentation/contato/contato_cubit.dart` e `contato_state.dart`]

**Contagem (D-22):** `semRetorno: int?` separado de `conteudo`; falha da contagem (qualquer coisa, menos 401) deixa `null` e a linha some; a lista segue. Pedir de novo em: abrir a tela, após PATCH com sucesso, após 404, no "Tentar de novo" da lista e no retry da contagem junto do recarregamento.

**Opções do imóvel:** `OpcoesDeImovel` sealed (`naoCarregadas | carregando | carregadas(List<ImovelComContato>) | erro`); `carregarOpcoesDeImovel()` chamado ao abrir a folha; 401 → mesmo `sessaoExpirada` da tela (a folha fecha e o `BlocListener` da tela navega).

### R9 — Contrato §17 (formato do §14/§15)

Seguir `## 16. Caixa de contatos do corretor (Fase 10)` com os subitens do §14 (`16.1 Rotas e autenticação`, `16.2 Lista`, `16.3 Anotar o retorno`, `16.4 Contagem`, `16.5 Opções do filtro de imóvel`, `16.6 Erros`, `16.7 Fuso`, `16.8 No app`, `16.9 PENDENTE WEB e riscos aceitos`, `16.10 Sincronização`) e a abertura "Elas vivem na branch `feat/APP10` da web até entrarem na `main` dela". **Congelar exatamente:**

**16.1 Rotas** (todas `Authorization: Token <chave>`, permissão `PertenceAUmaEmpresa`):

| Rota | Método | Sucesso |
|------|--------|---------|
| `/api/contatos/` | `GET` | 200 envelope do §4 (`page_size = 20`, `next`/`previous` absolutos) |
| `/api/contatos/resumo/` | `GET` | 200 `{"sem_retorno": N}` |
| `/api/contatos/imoveis/` | `GET` | 200 lista (sem envelope, sem paginação) |
| `/api/contatos/<id>/` | `PATCH` | 200 item completo (12 chaves) |

`GET /api/contatos/<id>/` existe mas o app não usa; `PUT`/`POST`/`DELETE` → **405**. Sem token ou com chave inválida/revogada → **401** + `WWW-Authenticate: Token`; **administrador → 403** `{"detail": "Este recurso é restrito a usuários vinculados a uma empresa."}`; gestor passa (vê todos os da empresa) mas o app não oferece a entrada (D-03).

**16.2 Lista** — parâmetros: `imovel` (inteiro; não numérico → 400), `de`, `ate` (`AAAA-MM-DD`, **inclusivas**, dia de São Paulo; `de > ate` → 400), `page`. Ordem fixa `-criado_em, -id`. Mudança de formato: a lista deixou de ser array simples e virou envelope (aceita; sem outro consumidor).
**Item: exatamente 12 chaves** (`ContatoSerializer`; verbatim `contatos/api/serializers.py:27-30`): `id`, `imovel`, `imovel_codigo`, `imovel_titulo`, `corretor`, `corretor_nome`, `canal`, `canal_exibicao`, `criado_em`, `retorno`, `retorno_exibicao`, `retorno_em`.

| Chave | Tipo | Observação |
|-------|------|------------|
| `id` | inteiro | |
| `imovel` | inteiro | id do imóvel (o app não usa) |
| `imovel_codigo` / `imovel_titulo` | string | código interno e título (rota interna da empresa; o código não é público na vitrine) |
| `corretor` | inteiro ou `null` | `null` quando o corretor estava desativado e o contato foi para a empresa (só o gestor vê esses) |
| `corretor_nome` | string ou `null` | (o app não mostra: coluna só do gestor, D-09) |
| `canal` | string | `WHATSAPP`, `TELEFONE` ou `EMAIL` |
| `canal_exibicao` | string | `WhatsApp`, `Telefone`, `E-mail` (o app usa texto próprio) |
| `criado_em` | ISO-8601 com offset `-03:00` | |
| `retorno` | string | `PENDENTE`, `FALEI`, `VISITA_AGENDADA`, `SEM_RESPOSTA`, `DESCARTADO` |
| `retorno_exibicao` | string | (o app usa texto próprio, D-10) |
| `retorno_em` | ISO-8601 ou `null` | |

**Nenhum dado do visitante** existe na tabela (sem nome/telefone/e-mail/texto livre). **Erros da lista:** 400 com `{"<campo>": "<mensagem>"}` — **string**, não lista, p.ex. `{"de": "A data inicial não pode ser depois da final."}`, `{"imovel": "Informe o id do imóvel."}`, `{"de": "Informe a data no formato AAAA-MM-DD."}` (medido); `?page` fora do intervalo → 404 `{"detail": "Página inválida."}`; o app ignora os textos.
**16.3 PATCH:** ver R4 (corpo, valores aceitos, 200 = item completo, 400/401/403/404/405, corpo vazio → 400 após o endurecimento).
**16.4 Contagem:** `{"sem_retorno": <inteiro ≥ 0>}`, sempre sobre **todos** os contatos visíveis ao usuário com `retorno = PENDENTE`, **ignora** `imovel`/`de`/`ate`/`page`.
**16.5 Imóveis:** lista de `{"id": int, "codigo": string, "titulo": string}` (exatamente 3 chaves), só de imóveis que aparecem em contatos visíveis ao usuário, ordenada por `codigo`.
**16.6 Isolamento (critério 5):** o filtro por empresa é a primeira camada (`EmpresaScopedQuerySetMixin`/`contatos_visiveis_para`), depois o perfil (corretor: só os dele; gestor: todos da empresa; administrador: nada → 403). Vale para lista (com e sem filtros), contagem, opções e PATCH (404 pelo id de outro corretor ou de outra empresa).
**16.7 Fuso:** ver R6. **16.9 riscos aceitos:** envelope substituiu array (sem outro consumidor); `imoveis/` sem paginação (limite = acervo); hora local do aparelho ≠ site fora do fuso de Brasília; `canal`/`retorno` desconhecido quebra a página no app antigo (FormatException).
**16.10 Sincronização:** `python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo contatos`; tabela fixture → exemplo do contrato (`contatos_p1.json` → `contatos.example.json`, `contatos_resumo.json` → `contatos_resumo.example.json`, `contatos_imoveis.json` → `contatos_imoveis.example.json`, `contato_patch_200.json` → `contato_patch.example.json`); credenciais **só por variável de ambiente**; SQLite temporário com `migrate`, `semear_vitrine_dev` e `seed_demo`; `CONTATO_TAXA_ANONIMA=1000/min` no servidor temporário (o grupo faz ≥ 21 POSTs de contato). Travas: no app `test/data/contrato_contatos_test.dart`; no Django as classes novas de `contatos/tests.py`.

### R10 — Segurança (para o threat model)

Ver "Security Domain". Resumo: isolamento por empresa **e** perfil em todas as rotas (testes por rota nova); token só no `Dio` autenticado e só para a origem da base URL; `next` só da mesma origem (`mesmaOrigem`, T-08-30); nenhum PII de visitante em `Contato` (docstring de `Contato` em `contatos/models.py`: "não há nenhum dado do visitante aqui — nem nome, nem telefone, nem campo de texto livre"); sem `LogInterceptor` com cabeçalhos; PATCH só aceita `retorno` ∈ `RETORNOS_ANOTAVEIS`; corpo vazio hoje vira 500 (Achado 2).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Listar contatos recebidos (ordem, recorte por empresa/perfil) | API / Backend (`ContatoViewSet`, `restringir_ao_perfil`) | App (mostra, na ordem do servidor) | Regra de quem vê é do Django; o app nunca filtra (D-13) |
| Paginação | API / Backend (`PaginacaoContatos`) | App (segue `next` de mesma origem) | `next` absoluto é do servidor; app só segue |
| Filtro por imóvel e período | API / Backend (`filtrar_contatos`) | App (monta `imovel`, `de`, `ate`) | Recorte `criado_em__date` em São Paulo é do servidor |
| Contagem dos sem retorno | API / Backend (`resumo`) | App (exibe; nunca conta) | D-04: o app não soma nem subtrai |
| Opções do filtro de imóvel | API / Backend (`imoveis`) | App (folha de escolha) | Mesma regra do seletor do site |
| Anotar o retorno | API / Backend (`anotar_retorno`, grava `retorno_em`) | App (envia 1 valor, espera o servidor) | Mudança de estado só no Django (D-16) |
| Isolamento multitenant | API / Backend (mixin + perfil) | — | Nunca no aparelho |
| Sessão/401 | App `data/` (interceptor) | App `presentation/` (navega ao login) | Fluxo da Phase 8, sem `try/catch` na UI |
| Rótulos, chip, formato de data | App `presentation/` (`apresentacao_contatos.dart`) | — | Texto fixo do app; valores do wire só em `data/` |
| Seletor de período (pt-BR) | App `presentation/` (`showDateRangePicker`) | App raiz (`MaterialApp` delegates) | UI nativa Material 3 |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `dio` | ^5.11.1 (já no pubspec) | HTTP do app (`@Named('autenticado')`) | Stack travado; interceptor de sessão já existe [VERIFIED: `pubspec.yaml`] |
| `flutter_bloc` | ^9.1.1 (já) | `CaixaContatosCubit` | Stack travado |
| `freezed` / `freezed_annotation` | ^4.0.1 / ^3.1.0 (já) | Estado e Models imutáveis | Stack travado |
| `json_serializable` / `json_annotation` | ^6.14.1 / ^4.12.0 (já) | `fromJson` dos Models | Stack travado |
| `injectable` / `get_it` | ^3.0.0 / ^9.3.0 (já) | DI do DataSource/Repository/UseCases/Cubit | Padrão da Phase 8 |
| `intl` | ^0.20.3 (já) | `DateFormat('dd/MM/yyyy HH:mm')` (sem locale) | Já usado para números |
| `flutter_localizations` | SDK (`sdk: flutter`) — **única mudança de `pubspec.yaml`** | `GlobalMaterialLocalizations.delegates` para o seletor em pt-BR | Já é transitiva; exige `intl ^0.20.3` (igual) [VERIFIED: `flutter pub add --dry-run`] |
| Django REST Framework | 3.18.1 (venv do web) | `PageNumberPagination`, `@action`, `ChoiceField` | Já usado [VERIFIED: `import rest_framework`] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `bloc_test` / `mocktail` | ^10.0.0 / ^1.0.5 (já) | Testes do Cubit e das telas | Padrão do repo |
| `flutter_test` | SDK | Widget tests, `tester` | Padrão |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Rota `resumo` | Campo `sem_retorno` no envelope da lista | Exige paginador customizado, consulta extra por página e o `count` já segue filtros (viola D-05) |
| 1 Cubit | Cubit de lista + Cubit das opções do imóvel | 2 caminhos de 401 e coordenação entre Cubits; ganho de isolamento pequeno |
| `DateFormat` sem locale | `DateFormat(..., 'pt_BR')` + `initializeDateFormatting` | Exigiria inicialização antes do `runApp` e em todos os testes; o padrão numérico não precisa |
| `material.dart` | `material_ui` | Migração do app inteiro, fora do escopo (só transitiva) |

**Installation (único ajuste):**
```yaml
# pubspec.yaml -> dependencies:
  flutter_localizations:
    sdk: flutter
```
```bash
flutter pub get
```
**Version verification:** nenhum pacote de registry novo. `flutter_localizations` é parte do Flutter 3.50.1 instalado em `/c/src/flutter/packages/flutter_localizations` (`environment: sdk: ^3.13.0-0`, `intl: ^0.20.3`). [VERIFIED: leitura do `pubspec.yaml` do SDK]

**Nomes recomendados (evitam a colisão com a Phase 6, Achado 6):**
- `domain/entities/`: `contato_recebido.dart` (`ContatoRecebido`), `retorno_contato.dart` (`enum RetornoContato { pendente, falei, visitaAgendada, semResposta, descartado }` + getter/const `anotaveis`), `consulta_contatos.dart` (`ConsultaContatos`), `periodo_contatos.dart` (`PeriodoContatos`), `pagina_contatos.dart`, `imovel_com_contato.dart`.
- `domain/repositories/`: `caixa_contatos_repository.dart` (+ `falhas_caixa_contatos.dart` com `ContatoNaoEncontradoException`).
- `domain/usecases/`: `buscar_contatos_usecase.dart` (`call` + `seguir`), `obter_sem_retorno_usecase.dart`, `listar_imoveis_dos_contatos_usecase.dart`, `anotar_retorno_usecase.dart`.
- `data/`: `datasources/caixa_contatos_datasource.dart` + `caixa_contatos_remote_datasource.dart`, `datasources/parametros_consulta_contatos.dart`, `models/contato_recebido_model.dart`, `contatos_envelope_model.dart`, `resumo_contatos_model.dart`, `imovel_com_contato_model.dart`, `models/retorno_contato_api.dart`, `repositories/caixa_contatos_repository_impl.dart`.
- `presentation/contatos/`: `caixa_contatos_screen.dart`, `caixa_contatos_cubit.dart`, `caixa_contatos_state.dart`, `apresentacao_contatos.dart`, `widgets/item_contato.dart`, `widgets/folha_anotar_retorno.dart`, `widgets/folha_filtro_imovel.dart`, `widgets/chips_filtros_contatos.dart`.
- `lib/app_localizacao.dart` (constantes de pt-BR para `main.dart` e testes).

## Package Legitimacy Audit

> Esta fase **não instala nenhum pacote de registry** (npm/PyPI/crates/pub.dev). A única mudança de dependência é declarar `flutter_localizations` com `sdk: flutter`, um pacote **do SDK do Flutter** (já presente como dependência transitiva em `pubspec.lock`), não baixado de registry. Nada para `gsd-tools query package-legitimacy check`.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `flutter_localizations` | Flutter SDK (`sdk: flutter`) | parte do SDK 3.50.1 | n/a | github.com/flutter/flutter (`packages/flutter_localizations`) | OK (SDK) | Approved |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 App (Flutter)                                              Web (Django + DRF)
 ───────────────────────────────────────────────            ───────────────────────────────────────────
 AcervoScreen (AppBar: ícone "Meus contatos")
        │ Navigator.push
        ▼
 CaixaContatosScreen ◄─ BlocProvider<CaixaContatosCubit>
   │  initState/carregar()
   │      ├──────────────► BuscarContatosUseCase ──► CaixaContatosRepositoryImpl ──► CaixaContatosRemoteDataSource
   │      │                                                (traduz 401/403/404/demais)     │  Dio @Named('autenticado')
   │      │                                                                                │  + InterceptadorSessao (Token só p/ origem da API)
   │      │                                                                                ▼
   │      │                                          GET /api/contatos/?imovel&de&ate&page ─────► ContatoViewSet.list
   │      │                                                                                        PertenceAUmaEmpresa
   │      │                                                                                        EmpresaScopedQuerySetMixin
   │      │                                                                                        restringir_ao_perfil
   │      │                                                                                        filtrar_contatos (400 se inválido)
   │      │                                                                                        PaginacaoContatos (20)
   │      ├──────────────► ObterSemRetornoUseCase ───────► GET /api/contatos/resumo/ ───────────► contatos_visiveis_para ∩ PENDENTE → {"sem_retorno": N}
   │      │
   │ chip "Imóvel" ► folha ─► ListarImoveisDosContatosUseCase ► GET /api/contatos/imoveis/ ─────► Imovel(pk__in contatos_visiveis_para) ordem codigo
   │ chip "Período" ► showDateRangePicker (pt-BR) ► de/ate (AAAA-MM-DD, dia de SP)
   │ toque no item ► folha de 4 retornos ► AnotarRetornoUseCase ► PATCH /api/contatos/<id>/ {"retorno": X}
   │                                                                  200 item completo │ 400/404/5xx/rede │ 401
   ▼
 estado freezed: consulta · semRetorno · opcoesDeImovel · conteudo(carregada{itens, anotando:Set<int>,...}) · aviso
   │  aviso != null  → SnackBar (texto fixo)          401 em QUALQUER rota → SessaoCubit.encerrarPorExpiracao()
   │                                                            → LoginScreen(aviso) via pushAndRemoveUntil(eRotaDaVitrine)
```

### Recommended Project Structure
```
lib/
├── app_localizacao.dart                      # delegates + supportedLocales pt-BR (main + testes)
├── data/
│   ├── datasources/ caixa_contatos_datasource.dart, caixa_contatos_remote_datasource.dart, parametros_consulta_contatos.dart
│   ├── models/      contato_recebido_model.dart, contatos_envelope_model.dart, resumo_contatos_model.dart,
│   │                imovel_com_contato_model.dart, retorno_contato_api.dart
│   └── repositories/ caixa_contatos_repository_impl.dart
├── domain/
│   ├── entities/    contato_recebido.dart, retorno_contato.dart, consulta_contatos.dart, periodo_contatos.dart, pagina_contatos.dart, imovel_com_contato.dart
│   ├── repositories/ caixa_contatos_repository.dart, falhas_caixa_contatos.dart
│   └── usecases/    buscar_contatos_usecase.dart, obter_sem_retorno_usecase.dart, listar_imoveis_dos_contatos_usecase.dart, anotar_retorno_usecase.dart
└── presentation/contatos/
    ├── caixa_contatos_screen.dart, caixa_contatos_cubit.dart, caixa_contatos_state.dart, apresentacao_contatos.dart
    └── widgets/     item_contato.dart, folha_anotar_retorno.dart, folha_filtro_imovel.dart, chips_filtros_contatos.dart
Web/contatos/api/views.py (+ PaginacaoContatos, resumo, imoveis), serializers.py (validate), tests.py (classes novas), ../README.md (linhas 188-189)
```

### Pattern 1: Paginação só na `list` + ações de lista no mesmo ViewSet (web)
**What:** `pagination_class` na ViewSet; `@action(detail=False)` para `resumo` e `imoveis`.
**When to use:** rotas auxiliares com o mesmo escopo e a mesma permissão do recurso.
**Example:** ver "Code Examples" (Django).

### Pattern 2: Cubit paginado com consulta imutável e token de versão (app)
**What:** `_versaoConsulta` descarta respostas velhas; `isClosed` antes de todo `emit`; dedupe por `id` na página seguinte; retry sempre explícito.
**Source:** `lib/presentation/acervo/acervo_cubit.dart` (lido), a ser copiado.

### Pattern 3: Item em voo dentro do estado imutável + aviso one-shot
Ver R8. Cada falha passa por uma emissão com `anotando` não vazio, então a emissão com `aviso` nunca é igual à anterior.

### Pattern 4: Folha que recebe callbacks por valor
A rota do modal fica fora do `BlocProvider`; capturar `context.read<CaixaContatosCubit>()` na TELA e passar ao `mostrar...BottomSheet` (`contato_bottom_sheet.dart`, `filtros_bottom_sheet.dart`).

### Pattern 5: Data local numa borda só
`DateTime.parse` → UTC; `toLocal()` num único ponto (mapeamento para a apresentação ou o próprio item); formatador puro.

### Anti-Patterns to Avoid
- **Contar `PENDENTE` no app** (somar/subtrair ao anotar): viola D-04/D-06; sempre repedir `resumo`.
- **Atualização otimista do retorno:** viola D-16.
- **Mostrar `retorno_exibicao`/`canal_exibicao` do servidor:** D-10 manda texto fixo mapeado do enum; qualquer string do servidor na UI é proibida.
- **`DateFormat(pattern, 'pt_BR')`:** quebra testes sem delegates (Pitfall 4).
- **`try/catch` na tela/Cubit para `DioException`:** o Repository já devolve `Result`.
- **Passar o Cubit da tela por `context.read` dentro do `builder` da folha:** a rota do modal não herda o `BlocProvider`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Paginação da API | Paginador manual | `PageNumberPagination` (`PaginacaoContatos`) | `next`/`previous` absolutos, 404 de página inválida, mantém os filtros (medido) |
| Escopo empresa/perfil | `filter(corretor=...)` duplicado nas rotas novas | `contatos_visiveis_para(request.user)` | Ponto único, o mesmo do site e dos testes de isolamento |
| Seletor de período | Dois `TextField` de data ou calendário próprio | `showDateRangePicker` (Material 3) + `GlobalMaterialLocalizations` | Acessível, validado (`de ≤ ate`), localizado |
| Rodapé de lista paginada | Novo widget de rodapé | `RodapePaginacaoLista` (+ `mensagemErro`) | Já testado nos 3 consumidores |
| Rolagem infinita | Pacote `infinite_scroll_pagination` | `ScrollController` + `carregarMais` do Cubit | Decisão do stack (estado todo no Cubit) |
| Tradução de 401 | Checagem de status na tela | `InterceptadorSessao` + `Repository._executar` | Já centralizado |
| Fixtures | JSON escrito à mão | `tool/capturar_fixtures_api.py --grupo contatos` | Regra D-02/D-18 da fase 6/8: nenhum wire à mão |
| Formato `AAAA-MM-DD` / data BR | Concatenação manual de strings | `DateFormat('yyyy-MM-dd')` / `DateFormat('dd/MM/yyyy HH:mm')` (sem locale) | Padding e ordem corretos |

**Key insight:** a fase é quase toda composição de peças já testadas; o risco está nos detalhes de borda (fuso, pt-BR, estado por item, 404 no PATCH), não em lógica nova.

## Common Pitfalls

### Pitfall 1: `resumo`/`imoveis` caindo na rota `{pk}`
**What goes wrong:** `GET /api/contatos/resumo/` vira `retrieve(pk="resumo")` e dá 404.
**Why it happens:** a rota de detalhe `[^/.]+` casa qualquer segmento.
**How to avoid:** usar `@action(detail=False)` no mesmo `ViewSet` (o router ordena as de lista antes do detalhe — medido). Não declarar as rotas num `path()` depois do `router.urls`.
**Warning signs:** 404 com `"No Contato matches the given query."` ao chamar a rota nova; teste `resolve("/api/contatos/resumo/").url_name == "contato-resumo"` falhando.

### Pitfall 2: PATCH sem barra final ou seguindo redirecionamento
**What goes wrong:** `PATCH /api/contatos/12` (sem `/`) → `APPEND_SLASH` não redireciona PATCH; e o `Dio` autenticado tem `followRedirects: false`.
**How to avoid:** montar sempre `'/api/contatos/$id/'`; teste do DataSource confere o `path` exato na `ApiFalsa`.
**Warning signs:** 301/404 no PATCH em teste de integração.

### Pitfall 3: Paginar "tira" o item de uma lista que a tela já mostra
**What goes wrong:** o PATCH devolve o item atualizado, mas a tela troca por id só se achar; se o corretor mudou o filtro no meio, a resposta velha não acha o item (correto) mas o `semRetorno` deve ser recarregado mesmo assim.
**How to avoid:** `_versaoConsulta` só protege a **lista**; o resumo é independente (`_versaoResumo`).

### Pitfall 4: Locale explícito em `DateFormat`
**What goes wrong:** `LocaleDataException` em qualquer widget test sem delegates (e em produção antes de o delegate carregar).
**How to avoid:** `DateFormat('dd/MM/yyyy HH:mm')` sem locale (padrão numérico). Confirmado por experimento.

### Pitfall 5: Teste de data dependente do fuso da máquina
**What goes wrong:** `DateTime.parse('2026-01-09T22:30:00-03:00').toLocal()` dá horas diferentes em CI/máquina de outro fuso → teste verde aqui, vermelho lá.
**How to avoid:** formatador puro sobre `DateTime` local; testes usam `DateTime(2026, 1, 9, 22, 30)`; o único teste que parseia o ISO compara com `esperado.toLocal()` computado, nunca string fixa.

### Pitfall 6: SnackBar que não reaparece na 2ª falha igual
**What goes wrong:** o `Cubit` ignora `emit` de estado igual; duas falhas seguidas com o mesmo `aviso` não disparam o listener.
**How to avoid:** toda anotação começa com `emit(... anotando+{id}, aviso: null)`; o `aviso` só é setado na emissão de falha (sempre diferente da anterior).

### Pitfall 7: Lista "não preenche a tela" trava a paginação
**What goes wrong:** poucos itens na 1ª página sem rolagem → `carregarMais` nunca dispara.
**How to avoid:** copiar `_agendarCarregarMaisSeNaoPreencheATela` do acervo (com 20 por página e telas altas o caso real existe).

### Pitfall 8: Token vazando por `next` de outra origem
**What goes wrong:** `next` malicioso/mal configurado faria o app mandar o token a outro host.
**How to avoid:** `mesmaOrigem(Uri.parse(next), Uri.parse(_dio.options.baseUrl))` no DataSource (lança `FormatException`) **e** a checagem do interceptor (só anexa o token se `mesmaOrigem` do pedido).

### Pitfall 9: `ids_api` e README esquecidos
**What goes wrong:** depois de paginar, `ids_api` itera chaves do envelope (`TypeError: string indices must be integers`) e o README segue descrevendo uma lista.
**How to avoid:** primeira tarefa web: ajustar `ids_api` para `response.data["results"]` e atualizar `README.md:188-189` (+ linhas das rotas novas).

### Pitfall 10: Gate do analyze com baseline errada
**What goes wrong:** `flutter analyze lib` volta com 42-50 infos e a onda é barrada, ou pior, alguém "corrige" removendo o `import material.dart`.
**How to avoid:** gate = 0 errors/warnings e só infos `deprecated_member_use` do import de `material.dart` (41 + 1 por arquivo novo). Ver Achado 4.

## Code Examples

### Django — paginação, resumo e imóveis (a ser aplicado em `contatos/api/views.py`)
```python
# Padrão: imoveis/api/views.py:69-80 (PaginacaoAcervo) e contatos/views.py:46-50 (opções do site).
# Experimento nesta sessão (ViewSet derivada fora do repo) confirmou: ordem do router, escopo,
# respostas e 401/403. Escrito aqui como proposta (ainda não aplicado no repo).
from rest_framework.decorators import action
from rest_framework.pagination import PageNumberPagination

from imoveis.models import Imovel

from ..servicos import contatos_visiveis_para

CONTATOS_POR_PAGINA = 20


class PaginacaoContatos(PageNumberPagination):
    """Caixa do app: 20 por página, como o acervo e as vitrines; o cliente não muda o tamanho."""

    page_size = CONTATOS_POR_PAGINA


class ContatoViewSet(...):
    # só `list` pagina: retrieve/PATCH e as @action não chamam o paginador
    pagination_class = PaginacaoContatos

    @action(detail=False, methods=["get"])
    def resumo(self, request):
        """Quantos contatos visíveis a este usuário ainda estão sem retorno (ignora filtros)."""
        sem_retorno = contatos_visiveis_para(request.user).filter(retorno=Contato.Retorno.PENDENTE).count()
        return Response({"sem_retorno": sem_retorno})

    @action(detail=False, methods=["get"])
    def imoveis(self, request):
        """Opções do filtro de imóvel: só os que aparecem em contatos visíveis, por código."""
        imoveis = (
            Imovel.objects.filter(pk__in=contatos_visiveis_para(request.user).values("imovel"))
            .order_by("codigo")
            .values("id", "codigo", "titulo")
        )
        return Response(list(imoveis))
```
`Contato.Retorno.PENDENTE` = `"PENDENTE"` [VERIFIED: `contatos/models.py:26`]. As permissões `PertenceAUmaEmpresa` (classe da ViewSet) valem para as `@action` (admin 403 / anônimo 401 — medido).

### Django — endurecimento do PATCH (Achado 2; verificado em experimento)
```python
# contatos/api/serializers.py — dentro de ContatoSerializer
def validate(self, atributos):
    if "retorno" not in atributos:  # PATCH {} chegaria ao update() sem a chave -> KeyError/500
        raise serializers.ValidationError({"retorno": ["Este campo é obrigatório."]})
    return atributos
```
Resultado medido: `PATCH {}` → 400 `{'retorno': ['Este campo é obrigatório.']}`; `PATCH {"retorno":"FALEI"}` → 200.

### Django — ajuste do helper e padrão dos testes novos
```python
# contatos/tests.py — ContatoBase.ids_api (hoje: `for item in response.data`)
def ids_api(self, usuario, **filtros):
    self.client.force_login(usuario)
    response = self.client.get(reverse("contato-list"), filtros)
    self.assertEqual(response.status_code, status.HTTP_200_OK)
    return {item["id"] for item in response.data["results"]}

# padrão de teste de página pequena (imoveis/tests.py:1410): mock.patch.object(PaginacaoVitrine, "page_size", 1)
# -> aqui: with mock.patch.object(PaginacaoContatos, "page_size", 1): ...
```

### Dart — URL da página seguinte e parâmetros (padrão do acervo)
```dart
// Padrão: lib/data/datasources/acervo_remote_datasource.dart (lido). `next` só de mesma origem.
Future<ContatosEnvelopeModel> seguir(String proximaPagina) async {
  if (!mesmaOrigem(Uri.parse(proximaPagina), Uri.parse(_dio.options.baseUrl))) {
    throw const FormatException('URL "next" da caixa aponta para outra origem.');
  }
  final resposta = await _dio.get<Object?>(proximaPagina);
  return _lerEnvelope(resposta.data);
}

Future<ContatoRecebidoModel> anotarRetorno(int id, RetornoContato retorno) async {
  final resposta = await _dio.patch<Object?>(
    '/api/contatos/$id/', // barra final obrigatória (followRedirects: false)
    data: {'retorno': retorno.valorApi}, // 'FALEI' | 'VISITA_AGENDADA' | 'SEM_RESPOSTA' | 'DESCARTADO'
  );
  return _lerItem(resposta.data);
}
```

### Dart — enum desconhecido = `FormatException` (padrão `ImovelAcervoModel._mapearFinalidade`)
```dart
static CanalContato _mapearCanal(String valor) => switch (valor) {
  'WHATSAPP' => CanalContato.whatsapp,
  'TELEFONE' => CanalContato.telefone,
  'EMAIL' => CanalContato.email,
  _ => throw FormatException('canal desconhecido: $valor'),
};
// retorno: 'PENDENTE','FALEI','VISITA_AGENDADA','SEM_RESPOSTA','DESCARTADO' -> RetornoContato; default -> FormatException
```

### Dart — `MaterialApp` pt-BR (provado no experimento de pacote isolado)
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  title: 'Imóveis Aqui',
  theme: AppTheme.tema,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('pt', 'BR')],
  home: const _TelaInicial(),
)
```

### Dart — seletor de período
```dart
final hoje = DateUtils.dateOnly(DateTime.now());
final escolhido = await showDateRangePicker(
  context: context,
  firstDate: DateTime(2024),          // [ASSUMED] ver A4
  lastDate: hoje,
  initialDateRange: periodoAtual == null ? null : DateTimeRange(start: periodoAtual.de, end: periodoAtual.ate),
);
// de/ate vão ao servidor como AAAA-MM-DD do DateTime LOCAL (sem toUtc).
```

### Dart — SnackBar de falha (padrão `BarraContato`)
```dart
BlocListener<CaixaContatosCubit, CaixaContatosState>(
  listenWhen: (a, b) => b.aviso != null && a.aviso != b.aviso,
  listener: (context, state) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(textoDoAviso(state.aviso!)))); // switch exaustivo em apresentacao_contatos.dart
  },
  child: ...,
)
```
(`!` aqui é evitável com `switch` por pattern: `if (state.aviso case final aviso?)`; preferir isso pela skill.)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `package:flutter/material.dart` | `package:material_ui/material_ui.dart` (deprecado desde Flutter 3.47) | Flutter 3.47+ | As 41 infos do analyze; migração fora do escopo desta fase |
| `SharedPreferences.getInstance()` | `SharedPreferencesAsync` | — | Não usado nesta fase |
| Lista simples em `GET /api/contatos/` | Envelope `PageNumberPagination` | Esta fase | App é o único consumidor |

**Deprecated/outdated:**
- `import 'package:flutter/material.dart'`: gera 1 info `deprecated_member_use` por arquivo; mantido por consistência (D-29).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | ~90 bytes por item de `GET /api/contatos/imoveis/` (1.000 imóveis ≈ 90 KB) — ordem de grandeza, não medida em produção | R3 | Se um gestor tiver milhares de imóveis a lista cresce; a APP-12 deve revisitar (busca/limite) |
| A2 | `canal`/`retorno` desconhecidos viram `FormatException` e derrubam a página inteira (erro genérico "Não foi possível carregar os contatos.") — é o que o CONTEXT delega e o padrão vigente faz com `finalidade`/`perfil` | R7 | Se a web criar um canal/retorno novo, apps antigos mostram erro em toda a caixa até atualizar; alternativa seria ignorar só o item ou cair num valor `desconhecido` (decisão de produto) |
| A3 | `toLocal()` basta: o Brasil não tem horário de verão desde 2019 e a maioria dos corretores usa o fuso de Brasília; em outros fusos a hora difere do site em 1-2 h | R6 | Contato "de ontem à noite" pode aparecer com data diferente da do site; aceito e documentado no §17 |
| A4 | `firstDate = DateTime(2024)` e `lastDate = hoje` para o seletor | R5 | Se o Allysson quiser outro limite (p.ex. `DateTime(2026)`), é uma constante; sem impacto no servidor |
| A5 | Incluir o endurecimento do PATCH (`validate()` → 400) apesar do D-25 dizer que o serializer não muda | Achado 2 | Se o Allysson preferir não tocar no serializer, fica o 500 em `PATCH {}` (só alcançável por cliente que não seja o app) |
| A6 | Tocar na opção que já é a atual na folha apenas fecha a folha, sem chamar a API | R8 | Se o Allysson quiser re-gravar `retorno_em` ao tocar na mesma opção, basta remover a guarda |
| A7 | Um único Cubit para lista + contagem + opções + anotação | R8 | Se o planejador preferir 2 Cubits, o caminho de 401 das opções precisa de um listener próprio |
| A8 | `page_size = 20` como constante local da caixa (o mesmo da APP-05/08) | R1 | Nenhum risco funcional; só convenção |
| A9 | O Brasil sem horário de verão atual (`America/Sao_Paulo` fixo em `-03:00`) | R6 | Se o governo reinstituir o horário de verão, o offset do fio varia sazonalmente; o app continua correto porque usa `DateTime.parse` com offset |

## Open Questions (RESOLVED)

> Resolvidas pelo orquestrador em 2026-11-22, por delegação do Allysson ("decida pelas instruções do card"); registradas em `10-CONTEXT.md`.

1. **Aprovar o endurecimento do PATCH (corpo vazio → 400)?** — **RESOLVED:** incluído (emenda do D-25 em `10-CONTEXT.md`).
   - What we know: `PATCH {}` hoje levanta `KeyError` (500); correção de 3 linhas verificada; contraria a letra do D-25 ("o `ContatoSerializer` não muda").
   - What's unclear: se o Allysson aceita a exceção ao D-25.
   - Recommendation: incluir (1 linha de produção + 1 teste `test_patch_sem_retorno_e_400`); rotular no plano como desvio explícito do D-25 e registrar no §17.

2. **`firstDate` do seletor (2024 vs 2026)?** — **RESOLVED:** `DateTime(2024)`, `lastDate` = hoje (`10-CONTEXT.md`, Claude's Discretion).
   - What we know: nenhum contato anterior à W11 (2026) existe; o picker só limita a navegação.
   - Recommendation: `DateTime(2024)` (folga) — constante em `apresentacao_contatos.dart`.

3. **RESOLVED (adiado de propósito para o human-check de fim de fase, D-29 / `10-VALIDATION.md` Manual-Only):** confirmar no human-check: ícone da entrada (`Icons.inbox_outlined`), cor do chip "Aguardando retorno" (sugestão: `tertiaryContainer`/`primaryContainer` do `ColorScheme`, sem cor fixa), textos longos do item (2 linhas).

4. **RESOLVED (procedimento, D-29):** rodar `build_runner` e conferir CRLF (D-29) ao gerar `*.freezed.dart`, `*.g.dart` e `injection.config.dart` — sem dúvida de design, só procedimento.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter / Dart | App (todas as ondas) | ✓ | Flutter 3.50.1, Dart 3.14.0 | — |
| Python (venv do web) | Testes Django, captura | ✓ | 3.11.9 (`Web/venv/Scripts/python.exe`), Django 5.2.17, DRF 3.18.1 | — |
| `python3` no PATH | `tool/capturar_fixtures_api.py` | ✓ | 3.11.9 | usar o do `venv` |
| SQLite em memória | Testes Django (`DATABASE_URL="sqlite://:memory:"`) | ✓ | (embutido) | — |
| git (dois repos) | Commits locais (D-B) | ✓ | — | — |
| Servidor Django temporário + SQLite em arquivo | Captura das fixtures (grupo `contatos`) | ✓ (procedimento do docstring da ferramenta) | `runserver 127.0.0.1:8000 --noreload` | — |
| Credenciais de captura (`CAPTURA_*`) | Grupo `contatos` (login do corretor, outra empresa, gestor) | ✗ (só por variável de ambiente, nunca em arquivo; o executor as gera) | — | Senha descartável definida no SQLite temporário (procedimento do §14.9) |
| Mac/iOS | Nada novo nesta fase | n/a | — | — |

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** credenciais de captura (geradas no SQLite temporário, como na Phase 8).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework (web) | Django `TestCase`/DRF `APITestCase` (`manage.py test`), 743 testes hoje |
| Framework (app) | `flutter_test` + `bloc_test` + `mocktail`, 1194 testes hoje |
| Config file | `Web/manage.py` / `pubspec.yaml`; sem config extra |
| Quick run (web) | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test contatos --noinput` |
| Full suite (web) | `... manage.py test --noinput` (743 OK hoje; ~20 s) |
| Quick run (app) | `flutter test test/<arquivo>_test.dart` |
| Full suite (app) | `flutter test` (1194 hoje) + `flutter analyze lib` (41 infos hoje, ver Achado 4) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| API-14 / CXA-01 | Lista paginada: envelope `count/next/previous/results`, 20 por página (`mock.patch.object(PaginacaoContatos, "page_size", 1)`), `next` mantém filtros, `page` inválida 404, cliente não muda tamanho, retrieve/PATCH não paginam | integration (Django) | `manage.py test contatos.tests.PaginacaoDaCaixaTests --noinput` | ❌ Wave 0 |
| API-14 / CXA-05 | `resumo`: só `PENDENTE`, só visíveis, ignora `imovel/de/ate/page`, cai após PATCH, gestor ≠ corretor, outra empresa isolada, corretor `None` só no gestor, admin 403, anônimo 401, rota não colide com `{pk}` | integration (Django) | `manage.py test contatos.tests.ResumoSemRetornoTests --noinput` | ❌ Wave 0 |
| API-14 / CXA-02 | `imoveis`: exatamente `id/codigo/titulo`, só imóveis de contatos visíveis, ordem por `codigo`, igual a `ContatoListView.context["imoveis"]`, admin 403, anônimo 401 | integration (Django) | `manage.py test contatos.tests.OpcoesDeImovelDaCaixaTests --noinput` | ❌ Wave 0 |
| CXA-04 | Isolamento nas rotas novas (corretor×corretor, empresa×empresa, gestor) — estender `IsolamentoTests` | integration (Django) | `manage.py test contatos.tests.IsolamentoTests --noinput` | ✅ estender |
| CXA-03 / API-13 | PATCH 200 item completo, 400 (PENDENTE/XYZ/""/{}), 404 (outro corretor/outra empresa), 405 PUT; fuso (`-03:00`; dia de SP no filtro) | integration (Django) | `manage.py test contatos.tests.AnotarRetornoTests --noinput` | ✅ estender |
| API-13 | Contrato: chaves exatas do envelope, do item (12), do `resumo`, das opções (3); exemplo = fixture; `canal`/`retorno` ∈ enums; isolamento entre empresas | contract (app) | `flutter test test/data/contrato_contatos_test.dart` | ❌ Wave 0 |
| CXA-01 | Models/Repository/DataSource: parse do envelope, `FormatException` em enum desconhecido, 401/403/404 tipados, `seguir` rejeita outra origem, PATCH em `/api/contatos/<id>/` com `{'retorno': ...}` | unit (app) | `flutter test test/data/caixa_contatos_remote_datasource_test.dart test/data/caixa_contatos_repository_impl_test.dart test/data/contato_recebido_model_test.dart` | ❌ Wave 0 |
| CXA-02 | `parametrosDaConsultaContatos`: `imovel`, `de`, `ate` `AAAA-MM-DD` (sem `toUtc`), vazio não gera chave | unit (app) | `flutter test test/data/parametros_consulta_contatos_test.dart` | ❌ Wave 0 |
| CXA-01..05 | `CaixaContatosCubit` (bloc_test): carregar, vazio×semResultado, erro, 401, carregarMais/retry/dedupe, troca de filtro com versão, contagem falhando não derruba a lista, `anotarRetorno` sucesso/404/401/falha/duplo toque, aviso one-shot | unit (app) | `flutter test test/presentation/caixa_contatos_cubit_test.dart` | ❌ Wave 0 |
| CXA-01..06 | `CaixaContatosScreen` (widget): linha do número (0/1/N/ausente), item (código — título, canal, data `dd/MM/yyyy HH:mm`, chip de retorno, "anotado em"), chips Imóvel/Período com "x", folha de 4 opções com a atual marcada, item em voo sem toque, SnackBar com texto fixo, estados vazio/sem resultado/erro, 401 → login com aviso | widget (app) | `flutter test test/presentation/caixa_contatos_screen_test.dart` | ❌ Wave 0 |
| CXA-02 | Seletor de período em pt-BR com os delegates de `app_localizacao.dart` ("Salvar", "Data de início") | widget (app) | `flutter test test/presentation/seletor_periodo_pt_br_test.dart` | ❌ Wave 0 |
| CXA-06 | `AcervoScreen` tem o ícone "Meus contatos" que chama o destino; `MaterialApp` de produção tem `supportedLocales == [pt_BR]` | widget (app) | `flutter test test/presentation/acervo_screen_test.dart test/main_launch_routing_test.dart` | ✅ estender |
| CXA-03 / API-13 | Fluxo ponta a ponta com `ApiFalsa` + fixtures reais (lista → anotar → resumo atualizado; 404 recarrega) | integration (app) | `flutter test test/presentation/caixa_contatos_fluxo_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test <arquivos da tarefa>` e/ou `manage.py test contatos --noinput`.
- **Per wave merge:** `flutter analyze lib` (0 errors/warnings; infos só `deprecated_member_use` do `material.dart`: 41 + arquivos novos) **e** `flutter test` completo; e `manage.py test --noinput` completo (743 + novos). Rodados à mão (D-29).
- **Phase gate:** as três suítes verdes antes de `/gsd-verify-work`; human-check de fim de fase (ícone, chip, textos, pt-BR do seletor num aparelho).

### Wave 0 Gaps
- [ ] `Web/contatos/tests.py` — ajustar `ids_api` (`response.data["results"]`); classes `PaginacaoDaCaixaTests`, `ResumoSemRetornoTests`, `OpcoesDeImovelDaCaixaTests`; estender `IsolamentoTests`/`AnotarRetornoTests` (PATCH vazio, fuso).
- [ ] `tool/capturar_fixtures_api.py` — novo grupo `contatos` (acrescentar a `GRUPOS`, ao `choices` do `argparse` e ao docstring; **não** entra em `todos` sem nota). Passos: login do corretor demo, escolher imóveis dele com `meu_imovel` e `na_vitrine` no acervo, ≥ 21 POSTs públicos de contato (canais alternados, `CONTATO_TAXA_ANONIMA=1000/min`), capturar `contatos_p1`, `contatos_p2` (seguindo o `next`), `contatos_imovel` (`?imovel=`), `contatos_periodo_vazio` (período sem contatos → `results: []`), `contatos_resumo` (antes de anotar), `contatos_imoveis`, PATCH 200 → `contato_patch_200`, `contatos_resumo_apos` (um a menos), `erro_400_retorno`, `erro_404_contato` (PATCH do token demo no contato de **outra empresa**, criado por POST no imóvel da outra empresa), e conferir 403 do administrador só se houver credencial (opcional).
- [ ] `test/fixtures/api/contatos_*.json`, `contato_patch_200.json`, `erro_400_retorno.json`, `erro_404_contato.json` (capturadas, nunca à mão) + cópias byte a byte em `.planning/phases/01-.../contrato/*.example.json`.
- [ ] `test/support/api_falsa.dart` — rotas `GET /api/contatos/` (p1; `page=2` → p2; `imovel` → filtrada; `de`/`ate` → vazia), `GET /api/contatos/resumo/`, `GET /api/contatos/imoveis/`, `PATCH /api/contatos/<id>/` (fixture para o id capturado; `404` para outro id), todas exigindo token (senão 401); atualizar o comentário de cabeçalho da classe.
- [ ] `test/data/contrato_contatos_test.dart`, testes de data/domain/presentation listados acima.
- [ ] `lib/app_localizacao.dart` + `pubspec.yaml` (`flutter_localizations`).
- [ ] `build_runner` para `*.freezed.dart`, `*.g.dart` e `injection.config.dart`.

## Security Domain

> `security_enforcement: true`, `security_asvs_level: 1`, `security_block_on: high` (`.planning/config.json`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes (reuso) | `TokenAuthentication` da Phase 8; token só no `Dio` `@Named('autenticado')` |
| V3 Session Management | yes (reuso) | 401 → `SessaoCubit.encerrarPorExpiracao()`, token apagado (compare-and-delete no interceptor) |
| V4 Access Control | **yes** | `PertenceAUmaEmpresa` + `EmpresaScopedQuerySetMixin` + `restringir_ao_perfil`/`contatos_visiveis_para` em **todas** as rotas, incluindo as novas; testes por rota |
| V5 Input Validation | yes | `ChoiceField(RETORNOS_ANOTAVEIS)`; `date.fromisoformat`; `imovel.isdigit()`; corpo vazio → 400 (endurecimento) |
| V6 Cryptography | no | sem criptografia nova |
| V7 Error Handling & Logging | yes | sem `LogInterceptor`; texto do servidor nunca vai à UI; 500 por `KeyError` corrigido |
| V13 API | yes | 405 em métodos não previstos; envelope paginado com tamanho fixo |

### Known Threat Patterns for Django/DRF + Flutter

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Leitura entre empresas (IDOR na lista, `resumo`, `imoveis`, `?imovel=`) | Information Disclosure | Escopo empresa→perfil na primeira camada; testes com 2 empresas e 2 corretores em cada rota (`ids_api(gestor_b, imovel=casa.pk) == set()` já existe) |
| IDOR no PATCH por id de outro corretor/empresa | Tampering | `get_queryset` filtrado → 404 sem revelar existência (já testado) |
| Mass assignment pelo corpo do PATCH | Tampering | `read_only_fields`; `update()` só chama `anotar_retorno(validated_data["retorno"])` |
| Acesso do administrador | Elevation of Privilege | `PertenceAUmaEmpresa` → 403 (medido nas 3 rotas) |
| Token vazando via `next` de outra origem | Information Disclosure | `mesmaOrigem` no DataSource + só anexar token à origem da base URL no interceptor |
| Token em log/fixture | Information Disclosure | Sem log de cabeçalhos; fixture `login_200` com 40 zeros; credenciais de captura só por env |
| 500 em `PATCH {}` (traceback com `DEBUG=True`) | Information Disclosure / DoS | `validate()` → 400 |
| `imoveis/` sem paginação para gestor com acervo enorme | DoS (leve) | Aceito (risco no §17); o app só oferece a caixa ao corretor |
| PII de visitante | Information Disclosure | Inexistente por desenho: `Contato` não guarda nome/telefone/e-mail/texto livre |
| Enumeração por `?page` | Information Disclosure | 404 padrão do DRF, sem canal de enumeração (escopo já aplicado antes) |

## Sources

### Primary (HIGH confidence)
- Código do web lido nesta sessão (`Web/` em `main` = `8bf4448`): `contatos/api/views.py`, `serializers.py`, `urls.py`, `urls_publico.py`, `contatos/servicos.py`, `contatos/models.py`, `contatos/views.py`, `contatos/tests.py`, `core/permissions.py`, `core/mixins.py`, `config/urls.py`, `config/settings.py`, `imoveis/api/views.py` (`PaginacaoAcervo`), `imoveis/vitrine.py`, `README.md`, `CLAUDE.md` (raiz).
- Código do app lido nesta sessão: `lib/data/**` do acervo, `lib/di/modulo_rede.dart`, `lib/data/network/*`, `lib/domain/**` do acervo e de contato, `lib/presentation/acervo/*`, `contato/*`, `sessao/*`, `login/apresentacao_login.dart`, `perfis/widgets/rodape_paginacao_lista.dart`, `main.dart`, `pubspec.yaml`, `pubspec.lock`, `test/support/api_falsa.dart`, `tool/capturar_fixtures_api.py`, `test/data/contrato_acervo_test.dart`.
- Contrato `01-CONTRATO-API.md` §14 e §15 (lidos na íntegra); `08-RESEARCH.md` (formato).
- Experimentos rodados nesta sessão (SQLite em memória, ViewSets derivadas fora do repo): ordem do router, `resumo`/`imoveis`/paginação, respostas do PATCH (200/400/404/403/401/405), `KeyError` do PATCH vazio e correção, fuso e recorte `criado_em__date`, `next` com filtros, 5 queries na lista; pacote Flutter isolado: seletor pt-BR e `DateFormat`.
- SDK Flutter 3.50.1: `/c/src/flutter/packages/flutter_localizations/{pubspec.yaml,lib/src/material_localizations.dart}`; `flutter pub add flutter_localizations --sdk=flutter --dry-run`.

### Secondary (MEDIUM confidence)
- Nenhuma fonte externa usada: todo o domínio é in-repo e do SDK instalado. Não foram consultados Context7/web (nada de biblioteca de registry nova).

### Tertiary (LOW confidence)
- Estimativa de tamanho do `imoveis/` (A1) e premissa de fuso (A3, A9).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero pacote novo de registry; `flutter_localizations` do SDK resolve limpo.
- Architecture: HIGH — réplica do desenho do acervo (Phase 8) com experimentos que provam o comportamento da web.
- Pitfalls: HIGH — a maioria reproduzida (KeyError, `LocaleDataException`, ordem do router); fuso/ícone/cor ficam para o human-check.

**Research date:** 2026-11-22
**Valid until:** 2026-12-22 (30 dias; stack estável; reconferir se o Flutter ou o DRF mudarem de versão)
