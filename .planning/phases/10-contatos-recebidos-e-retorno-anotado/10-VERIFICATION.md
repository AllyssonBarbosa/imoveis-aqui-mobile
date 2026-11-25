---
phase: 10-contatos-recebidos-e-retorno-anotado
verified: 2026-11-24T23:30:00Z
status: passed
score: 10/10 must-haves verified
covered_files:
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-01-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-01-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-02-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-02-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-03-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-03-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-04-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-04-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-05-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-05-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-06-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-06-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-07-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-07-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-08-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-08-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-09-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-09-SUMMARY.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-10-PLAN.md"
  - ".planning/phases/10-contatos-recebidos-e-retorno-anotado/10-10-SUMMARY.md"
  - "lib/data/datasources/caixa_contatos_remote_datasource.dart"
  - "lib/data/repositories/caixa_contatos_repository_impl.dart"
  - "lib/presentation/acervo/acervo_screen.dart"
  - "lib/presentation/contatos/apresentacao_contatos.dart"
  - "lib/presentation/contatos/caixa_contatos_cubit.dart"
  - "lib/presentation/contatos/caixa_contatos_screen.dart"
  - "test/data/contrato_contatos_test.dart"
  - "test/presentation/caixa_contatos_fluxo_test.dart"
covered_digest: "v4:sha256:013556a614cbbd8e6709161811c476c66553a60078738d9724f3d6b5ff40e969"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 10/10
  gaps_closed: []
  gaps_remaining: []
  regressions: []
---

# Phase 10: Contatos Recebidos e Retorno Anotado — Relatório de Verificação

**Objetivo da fase:** Como corretor, eu quero ver quem procurou pelos meus imóveis para retornar e não perder negócio. A lista traz os contatos mais recentes primeiro, com o imóvel, o canal e a data, e permite filtrar por imóvel e por período. O corretor anota o retorno: falei, visita agendada, sem resposta ou descartado. Card APP 10 (tarefa A10).
**Verificado em:** 2026-11-24
**Status:** passed
**Re-verificação:** Sim — o relatório anterior ficou obsoleto (stale) porque a `feat/APP10` recebeu a `main` com a APP-09 (merge `b9d36e9`, renumeração `51afe35`, PR #2 `2d71953`). Todas as verdades foram reconferidas contra o código atual dos dois repositórios, com atenção ao que o merge tocou.

## O que mudou desde a verificação anterior (foco da re-verificação)

| Mudança | Verificação | Resultado |
|---------|-------------|-----------|
| `acervo_screen.dart`: o toque no cartão agora abre a gestão da APP-09 (`aoAbrirGestao`, `_abrirGestao`); o 401 do acervo passou a `voltarAoLoginComSessaoTerminada` (`lib/presentation/sessao/sessao_expirada.dart`) | Li o arquivo e o diff `8f0be90..HEAD`. O `IconButton(Icons.inbox_outlined, tooltip: 'Meus contatos')` segue na `AppBar` (linhas 154-158), antes do "Sair", ligado a `widget.aoAbrirContatos(context)` com padrão `abrirCaixaContatos` (linhas 34 e 47). Os dois pontos de entrada coexistem. | ✓ Preservado |
| Tela da caixa e sessão | `caixa_contatos_screen.dart` mantém o próprio tratamento de `CaixaSessaoExpirada` (linhas 105, 169-170, 198-201, 244); o refactor do acervo não o alcança. | ✓ Intacto |
| Diff do código da APP-10 desde `8f0be90` | `git diff` em `lib/presentation/contatos`, models, `periodo_contatos.dart` e `parametros_consulta_contatos.dart`: só trocas de comentário `§16 -> §17`. Nenhuma lógica alterada. | ✓ Só renumeração |
| `lib/di/injection.config.dart` regenerado | `CaixaContatosDataSource`, `CaixaContatosRepository`, os 4 casos de uso e `CaixaContatosCubit` seguem registrados (linhas 372-440), ao lado dos da gestão. | ✓ Ambos registrados |
| Renumeração (§17, API-13/API-14) | `01-CONTRATO-API.md` tem §16 (situação, APP-09) e §17 (caixa, APP-10); todos os `PLAN` da fase declaram `API-13`/`API-14` (nunca `API-11`/`API-12`); comentários e teste de contrato citam §17/API-13. `REQUIREMENTS.md`: `API-11/API-12` -> Phase 9, `API-13/API-14` -> Phase 10. | ✓ Consistente |
| Fixtures x contrato | `cmp` byte a byte: `contatos.example.json`, `contatos_resumo.example.json`, `contatos_imoveis.example.json` e `contato_patch.example.json` são idênticos a `test/fixtures/api/contatos_p1.json`, `contatos_resumo.json`, `contatos_imoveis.json` e `contato_patch_200.json`. | ✓ Idênticos |
| Web | O código de `Web/contatos` em `origin/main` (`e2d1fa0`) é o de `d046bdc` (`git diff d046bdc origin/main -- contatos` vazio). | ✓ Igual |

## Alcance do Objetivo

### Verdades Observáveis

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | SC1: lista dos contatos recebidos, mais recentes primeiro, vinda da API | ✓ VERIFIED | `CaixaContatosRemoteDataSource.buscar` faz `GET /api/contatos/` pelo `Dio` `@Named('autenticado')`; o repositório repassa na ordem recebida e o Cubit nunca ordena. Servidor: `PaginacaoContatos` (20 por página, sem `page_size_query_param`) em `Web/contatos/api/views.py`; `PaginacaoDaCaixaTests.test_ordem_das_duas_paginas_e_a_do_servidor`. A rolagem infinita segue o `next` (`seguir`, só de mesma origem). |
| 2 | SC2: cada item mostra imóvel, canal e data | ✓ VERIFIED | `ItemContato` mostra o rótulo "código — título", ícone e nome do canal, data e hora formatadas e o chip do retorno (mais "anotado em"). Cobertos por `item_contato_test` e `apresentacao_contatos_test`. UAT 2 (visual) passou. |
| 3 | SC3: filtro por imóvel e por período, combinados, resolvidos no servidor | ✓ VERIFIED | `parametrosDaConsultaContatos` só monta `imovel`, `de` e `ate` (sem filtro local). As opções vêm de `GET /api/contatos/imoveis/`. O período usa `showDateRangePicker` em pt-BR. Servidor: `filtrar_contatos` e `PaginacaoDaCaixaTests.test_next_preserva_os_filtros`. UAT 3 passou no aparelho. |
| 4 | SC4: o corretor anota o retorno e a API grava | ✓ VERIFIED | `anotarRetorno` faz `PATCH /api/contatos/$id/` com `{'retorno': valorApi}` (barra final obrigatória), e o Cubit espera o servidor (sem otimismo) e troca o item pelo devolvido. Comportamento coberto por testes nomeados do Cubit (guarda de duplo toque, 404, 401, falha) e pelo fluxo "tocar o item -> Falei grava o PATCH". Servidor: `AnotarRetornoTests`. UAT 4 passou contra o Django real, incluindo 404 e falha. |
| 5 | SC5: contato de outra empresa/corretor nunca aparece (lista, contagem, opções, PATCH 404) | ✓ VERIFIED | `ContatoViewSet` com `permission_classes = [PertenceAUmaEmpresa]`; `get_queryset` aplica `restringir_ao_perfil`; `resumo` e `imoveis` partem de `contatos_visiveis_para(request.user)`. Rodei `manage.py test contatos` na web: **57 testes OK** (inclui `IsolamentoTests`). A fixture real `contatos_outra_empresa.json` é exercitada em `contrato_contatos_test`. |
| 6 | SC6: a tela mostra quantos contatos estão sem retorno | ✓ VERIFIED | `GET /api/contatos/resumo/` devolve `{"sem_retorno": N}` calculado no servidor, ignorando filtros (`ResumoSemRetornoTests`). No app: `ResumoContatosModel` -> `obterSemRetorno` -> `state.semRetorno` -> linha de contagem; recarrega ao abrir e depois de cada anotação. O app nunca soma nem subtrai. |
| 7 | PATCH sem `retorno` responde 400 (e não 500) | ✓ VERIFIED | `ContatoSerializer.validate` levanta `ValidationError({"retorno": ["Este campo é obrigatório."]})`; teste `test_api_patch_sem_retorno_da_400_e_nao_muda_o_contato`; §17.3 do contrato. |
| 8 | 401 em qualquer rota da caixa encerra a sessão e abre o login com "Sua sessão terminou. Entre de novo." | ✓ VERIFIED | `CaixaSessaoExpirada` é terminal no Cubit; a tela chama `encerrarPorExpiracao` e `pushAndRemoveUntil(LoginScreen(aviso: avisoSessaoTerminou))`. Teste de fluxo da caixa passou nesta rodada. |
| 9 | A caixa abre por ícone na `AppBar` do "Meu acervo", só corretor (reconferido pós-merge) | ✓ VERIFIED | Ver tabela de mudanças: o ícone `inbox_outlined` com tooltip "Meus contatos" convive com o toque do cartão que abre a gestão. `acervo_screen_test`: "o ícone vem antes do Sair e não tem selo" e "tocar chama aoAbrirContatos com o context do acervo" passaram. O acervo só é aberto para corretor (gestor e administrador vão para `AvisoAreaScreen`). |
| 10 | §17 do contrato congela a API com fixtures capturadas e testes de contrato nos dois repositórios (API-13) | ✓ VERIFIED | §17.1 a §17.10 em `01-CONTRATO-API.md` (o §16 é da APP-09, sem sobreposição). Os 4 exemplos em `contrato/` são idênticos às fixtures (`cmp`). `contrato_contatos_test.dart` passou. Lado Django: `contatos/tests.py`. |

**Score:** 10/10 verdades verificadas (0 presentes com comportamento não verificado)

### Artefatos Obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `Web/contatos/api/views.py` (origin/main) | `PaginacaoContatos`, `resumo`, `imoveis`, `PertenceAUmaEmpresa` | ✓ VERIFIED | Lido nesta rodada |
| `Web/contatos/api/serializers.py` | `validate` exigindo `retorno` | ✓ VERIFIED | Linhas 33-37 |
| `Web/contatos/tests.py` | Paginação, resumo, opções, isolamento, PATCH | ✓ VERIFIED | 57 testes OK |
| `lib/data/datasources/caixa_contatos_remote_datasource.dart`, `parametros_consulta_contatos.dart`, `caixa_contatos_repository_impl.dart` | Dados | ✓ VERIFIED | Lidos; finos, sem regra de negócio; `next` só de mesma origem |
| `lib/domain/**` da caixa (entidades, repositório, 4 use cases, falhas) | Domínio puro | ✓ VERIFIED | Existem e estão no DI |
| `lib/data/models/*contato*`, `resumo_contatos_model`, `imovel_com_contato_model` | Models | ✓ VERIFIED | Leem todas as fixtures (`contrato_contatos_test`) |
| `lib/presentation/contatos/*` (Cubit 344 linhas, State, Screen 357, apresentação, 5 widgets) | Apresentação | ✓ VERIFIED | Substantivos e ligados |
| `lib/presentation/acervo/acervo_screen.dart` | Ícone "Meus contatos" | ✓ VERIFIED | Preservado após o merge |
| `lib/di/injection.config.dart` | Registro da caixa e da gestão | ✓ VERIFIED | Ambos presentes |
| `01-CONTRATO-API.md` §17 e `contrato/contato*.example.json` | Contrato | ✓ VERIFIED | `cmp` idêntico |

### Verificação de Ligações-Chave

| De | Para | Via | Status |
|----|------|-----|--------|
| `AcervoScreen` AppBar | `CaixaContatosScreen` | `aoAbrirContatos = abrirCaixaContatos` | ✓ WIRED |
| Cartão do acervo | Gestão (APP-09) | `aoAbrirGestao` -> `_abrirGestao` | ✓ WIRED (convive sem conflito) |
| `CaixaContatosScreen` | `CaixaContatosCubit` | `getIt<CaixaContatosCubit>()..carregar()` | ✓ WIRED |
| Cubit | Repositório | 4 use cases -> `CaixaContatosRepository` (DI) | ✓ WIRED |
| Repositório | DataSource | `Dio` `@Named('autenticado')` | ✓ WIRED |
| Tela | Login | `BlocListener` em `CaixaSessaoExpirada` -> `encerrarPorExpiracao` | ✓ WIRED |
| Item | `anotarRetorno` | folha `mostrarFolhaAnotarRetorno` | ✓ WIRED |
| `resumo`/`imoveis` (web) | `contatos_visiveis_para` | `request.user` | ✓ WIRED |

### Trace de Fluxo de Dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| Lista | `CaixaCarregada.itens` | `GET /api/contatos/` | Sim (fixtures capturadas; Django real no UAT 4) | ✓ FLOWING |
| Contagem | `state.semRetorno` | `GET /api/contatos/resumo/` | Sim | ✓ FLOWING |
| Folha de imóvel | `opcoesDeImovel` | `GET /api/contatos/imoveis/` | Sim | ✓ FLOWING |
| Item após anotar | `itens[i]` | corpo do 200 do PATCH | Sim | ✓ FLOWING |

### Verificações Comportamentais

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Contrato, Cubit, tela, fluxo da caixa e acervo (pós-merge) | `flutter test` em `contrato_contatos_test`, `caixa_contatos_{fluxo,screen,cubit}_test`, `acervo_{screen,fluxo}_test` | 188 testes, "All tests passed!" | ✓ PASS |
| Caixa no Django | `manage.py test contatos` (web, SQLite em memória) | 57 testes OK | ✓ PASS |
| Gates do orquestrador (HEADs atuais) | `flutter analyze --no-fatal-infos lib test` | exit 0 (91 infos `deprecated_member_use`, 0 erros/avisos) | ✓ PASS |
| Regressão completa APP-09 + APP-10 | `flutter test` | 1743 passando (informado pelo orquestrador) | ✓ PASS |
| Suíte Django completa na web `origin/main` (`e2d1fa0`) | `manage.py test` | 776 OK (informado pelo orquestrador) | ✓ PASS |

### Execução de Probes

Step 7c: a fase não declara probes `scripts/*/tests/probe-*.sh`. SKIPPED (sem probes declarados).

### Cobertura de Requisitos

Os 8 IDs aparecem no frontmatter dos PLANs (10-01 a 10-10) e em `REQUIREMENTS.md`: `CXA-01..06`, `API-13` e `API-14`, todos `[x]` e "Complete" na tabela da Phase 10. `API-11` e `API-12` pertencem à Phase 9 e não são IDs desta fase. Nenhum ID órfão.

| Requisito | Planos | Status | Evidência |
|-----------|--------|--------|-----------|
| CXA-01 | 10-01, 04..08, 10 | ✓ SATISFIED | Verdades 1 e 2 |
| CXA-02 | 10-01, 04..07, 09, 10 | ✓ SATISFIED | Verdade 3 |
| CXA-03 | 10-01, 04..06, 10 | ✓ SATISFIED | Verdade 4 |
| CXA-04 | 10-01, 02, 03, 10 | ✓ SATISFIED | Verdade 5 |
| CXA-05 | 10-01, 04..08, 10 | ✓ SATISFIED | Verdade 6 |
| CXA-06 | 10-06..10 | ✓ SATISFIED | Verdades 8 e 9 |
| API-13 | 10-02, 03, 05, 10 | ✓ SATISFIED | Verdade 10 |
| API-14 | 10-01, 10 | ✓ SATISFIED | Verdades 5 e 7 |

### Anti-Padrões Encontrados

`grep` por `TBD|FIXME|XXX|TODO|HACK` nos arquivos da caixa (app: `lib/presentation/contatos`, data source, repositório, domínio e testes de contrato/fluxo): nenhum resultado. Sem stubs, handlers vazios nem props hardcoded vazias.

### Verificação Humana

Os 6 itens humanos do relatório anterior foram executados pelo usuário em 2026-11-24 num emulador Android contra o Django real e todos passaram: `10-UAT.md` (status `complete`, 6/6, commit `8f0be90`). `10-SECURITY.md` está verificado (`threats_open: 0`). Os itens estão cobertos por essa evidência.

Prohibitions de tier judgment (veredito do verificador é não autoritativo, ADR-550 D4), com a evidência reconferida:
- (b) "as rotas novas nunca devolvem dado de outra empresa/corretor": `IsolamentoTests`, `ResumoSemRetornoTests` e `OpcoesDeImovelDaCaixaTests` passam nos 57 testes de `contatos`, e a fixture `contatos_outra_empresa.json` é exercitada no contrato. Confirmado também no UAT 6.
- (a) "sem push/PR/merge do repo web nesta fase": foi verdadeira durante a execução (UAT 6 a confirmou). Depois, por decisão do usuário fora da fase, o web foi publicado (`origin/feat/APP10` contém `d046bdc` e o PR #9 foi mesclado em `e2d1fa0`). Isso não é lacuna da fase; o contrato §17.9 já registrava a dependência da branch até a entrada na `main` da web, e agora ela entrou.

Nenhum item humano novo: o merge só trocou o destino do toque do cartão (APP-09) e manteve o ícone "Meus contatos"; essa convivência é coberta por `acervo_screen_test` e `acervo_fluxo_test` (passando) e a AppBar não mudou de estrutura.

### Itens Fora do Escopo / Observações

- Review de código, validate-phase (Nyquist) e ui-review não foram executados por escolha do usuário; não contam como lacuna.
- Riscos aceitos do §17.9 (lista deixou de ser array, `/api/contatos/imoveis/` sem paginação, hora local do aparelho x site, enum novo no servidor, POST público sem limite de taxa) não são lacunas desta fase.
- A caixa do gestor é a APP-12 (OPT-OUT explícito em `COVERAGE.md`).
- Nenhuma verdade marcada como `coincidental-reliance`.

### Resumo das Lacunas

Não há lacunas. O objetivo está atingido no código atual, depois do merge com a APP-09: a caixa segue ligada ponta a ponta (ícone no acervo -> tela -> Cubit -> casos de uso -> repositório -> `Dio` autenticado -> API Django paginada e isolada), o comportamento de anotação e sessão tem testes nomeados, os 8 requisitos estão satisfeitos e as verificações de aparelho e servidor vivo foram feitas no UAT.

---

_Verificado: 2026-11-24_
_Verificador: Claude (gsd-verifier)_
