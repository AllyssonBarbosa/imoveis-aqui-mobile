---
phase: 10-contatos-recebidos-e-retorno-anotado
verified: 2026-11-24T12:00:00Z
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
covered_digest: "v4:sha256:587033ea86dc1c9ea37f3f50d4ffa88f2c4ffb54fe413a5a4987c9cf424bc6d3"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Ícones e entrada: abrir o 'Meu acervo' logado como corretor e tocar no ícone de caixa de entrada (Icons.inbox_outlined, tooltip 'Meus contatos'); conferir ícones de canal (WhatsApp, Telefone, E-mail), o ícone de 'sem retorno' e o voltar ao acervo."
    expected: "A caixa 'Meus contatos' abre; os ícones são reconhecíveis e coerentes com o Material 3 verde/branco."
    why_human: "Aparência e reconhecimento de ícones não são julgados por teste automatizado."
  - test: "Visual do item e das folhas: cor do chip 'Aguardando retorno' (tertiaryContainer) contra os demais (neutros), títulos de imóvel longos (maxLines 2), folha 'Filtrar por imóvel' com muitas opções e folha 'Anotar retorno' (4 opções, check na atual)."
    expected: "Chip pendente se destaca, textos longos não estouram o layout, folhas legíveis e sem corte."
    why_human: "Escolhas visuais e de layout; só widget tests de estrutura existem."
  - test: "Seletor de período em pt-BR num aparelho real: tocar no chip 'Período' e escolher um intervalo."
    expected: "showDateRangePicker com textos do Material em português ('Selecione o intervalo', 'Salvar'); intervalo aplicado vira o chip 'dd/MM/yyyy – dd/MM/yyyy' e a lista é recarregada pelo servidor."
    why_human: "Localização real do Material no aparelho; os testes usam MaterialApp com delegates mas não o diálogo no dispositivo."
  - test: "Anotar contra o Django real (inclusive 404 e falha): com a API da feat/APP10 rodando, anotar 'Falei' num contato; depois forçar um 404 (contato de outro corretor/removido) e uma falha de rede."
    expected: "Item mostra o retorno devolvido pelo servidor e o número 'sem retorno' cai em 1; 404 mostra 'Este contato não está mais na sua caixa.' e recarrega lista e número; falha mostra 'Não foi possível anotar o retorno. Tente de novo.'."
    why_human: "Os testes usam a ApiFalsa com fixtures capturadas; a prova contra o servidor vivo e a captura real da falha exigem execução manual."
  - test: "Hora do app x hora do site (fuso de Brasília): comparar data e hora de um mesmo contato no app e na caixa do site, em aparelho no fuso de Brasília e em outro fuso."
    expected: "Em Brasília coincidem; em outro fuso diferem em 1 ou 2 horas (risco aceito A3, §17.7), e o dia do filtro continua sendo o de São Paulo."
    why_human: "Depende do fuso do aparelho; não há teste automatizado que troque o fuso do dispositivo."
  - test: "Prohibições de tier 'judgment' (revisão humana recomendada, unverified-prohibition): (a) nenhum push/PR/merge do repo web nesta fase; (b) as rotas novas nunca devolvem contato, imóvel ou contagem de outra empresa/corretor."
    expected: "(a) A feat/APP10 da web continua só local. (b) A evidência abaixo é suficiente."
    why_human: "Veredito do verificador é NÃO AUTORITATIVO para prohibitions de tier judgment (ADR-550 D4). Evidência colhida: (a) `git branch -r --contains d046bdc` vazio e `feat/APP10` sem upstream; (b) IsolamentoTests, ResumoSemRetornoTests e OpcoesDeImovelDaCaixaTests passam (57 testes de `contatos` OK) e a fixture contatos_outra_empresa.json (count 1) é exercitada em contrato_contatos_test.dart."
---

# Phase 10: Contatos Recebidos e Retorno Anotado — Relatório de Verificação

**Objetivo da fase:** Como corretor, eu quero ver quem procurou pelos meus imóveis para retornar e não perder negócio. A lista traz os contatos mais recentes primeiro, com o imóvel, o canal e a data, e permite filtrar por imóvel e por período. O corretor anota o retorno: falei, visita agendada, sem resposta ou descartado. Card APP 10 (tarefa A10).
**Verificado em:** 2026-11-24
**Status:** human_needed (código e testes comprovam o objetivo; restam só os itens de aparelho/fuso/servidor vivo do roteiro de fim de fase)
**Re-verificação:** Não — verificação inicial

## Alcance do Objetivo

### Verdades Observáveis

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | SC1: lista dos contatos recebidos, mais recentes primeiro, vinda da API | ✓ VERIFIED | `CaixaContatosRemoteDataSource.buscar` faz `GET /api/contatos/` pelo `Dio` `@Named('autenticado')`; repositório repassa na ordem recebida; Cubit nunca ordena. Servidor: `Meta.ordering` `-criado_em, -id` e `PaginacaoContatos` (20) em `Web/contatos/api/views.py`; `PaginacaoDaCaixaTests.test_ordem_das_duas_paginas_e_a_do_servidor`. Rolagem infinita por `next` (`seguir`, guarda de mesma origem) coberta em `caixa_contatos_fluxo_test` ("rolar até o fim pede a página 2"). |
| 2 | SC2: cada item mostra imóvel, canal e data | ✓ VERIFIED | `ItemContato` mostra `rotuloImovelDoContato` ("código — título"), ícone + `nomeExibicao` do canal, `formatarDataHoraContato(criadoEm)` e o chip do retorno atual (+ "anotado em" se há `retornoEm`); `item_contato_test.dart` e `apresentacao_contatos_test.dart` passam. |
| 3 | SC3: filtro por imóvel e por período, combinados, resolvidos no servidor | ✓ VERIFIED | `parametrosDaConsultaContatos` só monta `imovel`, `de`, `ate` (sem filtro local); `GET /api/contatos/imoveis/` alimenta a folha; `showDateRangePicker` com pt-BR (`app_localizacao.dart` ligado em `main.dart`). Servidor: `filtrar_contatos` (`criado_em__date`, dia de São Paulo) e testes `CaixaDeContatosTests`/`PaginacaoDaCaixaTests.test_next_preserva_os_filtros`. Cubit: grupo `filtros` (aplicar/limpar/combinar, descarte de resposta antiga). Fluxo ponta a ponta do imóvel: `caixa_contatos_fluxo_test`. |
| 4 | SC4: o corretor anota o retorno e a API grava | ✓ VERIFIED | `anotarRetorno` faz `PATCH /api/contatos/$id/` com `{'retorno': valorApi}` (barra final); `folha_anotar_retorno.dart` mostra as 4 opções anotáveis; Cubit espera o servidor (item em voo, sem otimismo), troca o item pelo devolvido e pede o resumo de novo. Comportamento (transição/invariante) provado por testes nomeados do Cubit (`anotarRetorno (D-06, D-15, D-16, D-17, D-23)`, guarda de duplo toque, 404/401/falha) e pelo fluxo "tocar o item -> Falei grava o PATCH". Servidor: `AnotarRetornoTests` (inclui PUT 405 e 12 chaves). |
| 5 | SC5: contato de outra empresa/corretor nunca aparece (lista, contagem, opções, PATCH 404) | ✓ VERIFIED | Rotas atrás de `PertenceAUmaEmpresa`; `resumo` e `imoveis` partem de `contatos_visiveis_para(request.user)`, `get_queryset` aplica `restringir_ao_perfil`. `IsolamentoTests` (corretor x corretor, outra empresa, trocar id → 404, admin 403, anônimo 401, resumo/opções batem). Fixture real `contatos_outra_empresa.json` (count 1, não vazia) usada em `contrato_contatos_test.dart`. Rodei `manage.py test contatos`: 57 testes OK. |
| 6 | SC6: a tela mostra quantos contatos estão sem retorno | ✓ VERIFIED | `GET /api/contatos/resumo/` → `{"sem_retorno": N}` (ignora filtros; `ResumoSemRetornoTests`); `ResumoContatosModel` → `obterSemRetorno` → `state.semRetorno` → `_LinhaSemRetorno`/`textoSemRetorno`; o app nunca soma/subtrai, recarrega ao abrir e depois de cada anotação. Fixtures capturadas 25 → 24. |
| 7 | PATCH sem `retorno` responde 400 (e não 500) | ✓ VERIFIED | `ContatoSerializer.validate` levanta `ValidationError({"retorno": [...]})`; `test_api_patch_sem_retorno_da_400_e_nao_muda_o_contato`; §17.3 do contrato. |
| 8 | 401 em qualquer rota da caixa encerra a sessão e abre o login com "Sua sessão terminou. Entre de novo." | ✓ VERIFIED | Repositório traduz 401 (direto ou em `DioException.error`) em `SessaoExpiradaException`; Cubit torna `CaixaSessaoExpirada` terminal (lista, página seguinte, resumo, opções, PATCH); tela chama `encerrarPorExpiracao` + `pushAndRemoveUntil(LoginScreen(aviso: avisoSessaoTerminou))`; `caixa_contatos_fluxo_test` ("401 na lista leva ao login…"). Textos de estado e SnackBar são fixos do app (`apresentacao_contatos.dart`). |
| 9 | A caixa abre por ícone na `AppBar` do "Meu acervo", só corretor | ✓ VERIFIED | `acervo_screen.dart` linha ~161: `IconButton(Icons.inbox_outlined, tooltip: 'Meus contatos')` → `aoAbrirContatos` (padrão `abrirCaixaContatos`, `Navigator.push`). O acervo só é aberto para corretor (`login_screen.dart`/`entrada_area_screen.dart` mandam gestor/administrador a `AvisoAreaScreen`). `acervo_screen_test` cobre a entrada. |
| 10 | §17 do contrato congela a API com fixtures capturadas e testes de contrato nos dois repositórios (API-13) | ✓ VERIFIED | §17.1 a §17.10 em `01-CONTRATO-API.md` (rotas, 12 chaves, PATCH, contagem, opções, isolamento, fuso, riscos); `contrato/contatos*.example.json` idênticos (`cmp`) às fixtures `test/fixtures/api/contatos_p1/resumo/imoveis/contato_patch_200.json`; `tool/capturar_fixtures_api.py --grupo contatos`; `contrato_contatos_test.dart` passa; testes de contrato do lado Django (`contatos/tests.py`). |

**Score:** 10/10 verdades verificadas (0 presentes com comportamento não verificado)

### Artefatos Obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `Web/contatos/api/views.py` | `PaginacaoContatos`, `resumo`, `imoveis` | ✓ VERIFIED | Lido; `pagination_class`, `@action(detail=False)` ×2, `permission_classes = [PertenceAUmaEmpresa]` |
| `Web/contatos/api/serializers.py` | `validate` exigindo `retorno` | ✓ VERIFIED | Diff 8bf4448..d046bdc confirma |
| `Web/contatos/tests.py` | Classes de paginação, resumo, opções, isolamento | ✓ VERIFIED | 57 testes OK |
| `README.md` (web) | Linhas das rotas da caixa | ✓ VERIFIED | Diff confirma as 4 linhas |
| `lib/domain/entities/*contato*`, `repositories/caixa_contatos_repository.dart`, `falhas_caixa_contatos.dart`, use cases | Domínio puro | ✓ VERIFIED | Existem e injetados (DI) |
| `lib/data/models/{contato_recebido,contatos_envelope,resumo_contatos,imovel_com_contato}_model.dart`, `canal_contato_api.dart`, `retorno_contato_api.dart` | Models freezed + wire | ✓ VERIFIED | Existem; leem todas as fixtures (`contrato_contatos_test`) |
| `caixa_contatos_remote_datasource.dart`, `parametros_consulta_contatos.dart`, `caixa_contatos_repository_impl.dart` | Dados | ✓ VERIFIED | Lidos; substantivos, sem lógica de negócio |
| `presentation/contatos/*` (Cubit, State, Screen, apresentacao, 5 widgets) | Apresentação | ✓ VERIFIED | Lidos; substantivos e ligados |
| `lib/app_localizacao.dart` + `main.dart` | pt-BR do Material | ✓ VERIFIED | `localizationsDelegates`/`supportedLocales` no `MaterialApp` |
| `lib/di/injection.config.dart` | Registro da caixa | ✓ VERIFIED | DataSource, Repository, 4 use cases e `CaixaContatosCubit` registrados |

### Verificação de Ligações-Chave

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|----------|
| `resumo`/`imoveis` (views.py) | `contatos_visiveis_para` | `contatos_visiveis_para(request.user)` | ✓ WIRED | Presente nas duas ações; nenhuma chama `filtrar_contatos` |
| `ContatoViewSet` | `PertenceAUmaEmpresa` | `permission_classes` | ✓ WIRED | Vale para list, PATCH e `@action` |
| `AcervoScreen` | `CaixaContatosScreen` | `aoAbrirContatos = abrirCaixaContatos` | ✓ WIRED | IconButton na AppBar |
| `CaixaContatosScreen` | `CaixaContatosCubit` | `getIt<CaixaContatosCubit>()..carregar()` | ✓ WIRED | Cubit registrado no DI |
| Cubit | Repositório | 4 use cases → `CaixaContatosRepository` | ✓ WIRED | DI confere |
| Repositório | DataSource | `Dio` `@Named('autenticado')` | ✓ WIRED | Token só na origem da API; `next` só de mesma origem |
| Tela | Login | `BlocListener` em `CaixaSessaoExpirada` → `encerrarPorExpiracao` | ✓ WIRED | Coberto pelo fluxo |
| Tela (item) | `anotarRetorno` | `mostrarFolhaAnotarRetorno(aoEscolher)` | ✓ WIRED | Cubit lido antes de abrir a folha |

### Trace de Fluxo de Dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| Lista de itens | `CaixaCarregada.itens` | `GET /api/contatos/` (fixtures capturadas do Django na ApiFalsa; Django real nos testes web) | Sim | ✓ FLOWING |
| Linha de sem retorno | `state.semRetorno` | `GET /api/contatos/resumo/` | Sim (25 → 24) | ✓ FLOWING |
| Folha de imóvel | `opcoesDeImovel` | `GET /api/contatos/imoveis/` | Sim | ✓ FLOWING |
| Item após anotar | `itens[i]` | corpo do 200 do PATCH | Sim | ✓ FLOWING |

### Verificações Comportamentais

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Caixa no Django (lista paginada, resumo, opções, isolamento, PATCH 400/405) | `manage.py test contatos` (web, SQLite em memória) | 57 testes OK | ✓ PASS |
| Contrato, Cubit, tela, fluxo ponta a ponta e acervo no app | `flutter test` em `contrato_contatos_test`, `caixa_contatos_{fluxo,screen,cubit}_test`, `acervo_{screen,fluxo}_test` | 186 passando | ✓ PASS |
| Camadas de dados e domínio da caixa | `flutter test` em `caixa_contatos_remote_datasource_test`, `caixa_contatos_repository_impl_test`, `caixa_contatos_usecases_test` | passam (115 no lote anterior, sem falha de teste; a única falha foi eu passar diretórios inexistentes como argumento, corrigido com arquivos) | ✓ PASS |
| Gates do orquestrador (frescos nos HEADs atuais) | `flutter analyze` 0 erros/avisos; `flutter test` 1495 passando; suíte Django 766 OK | informado pelo orquestrador | ✓ PASS |

### Execução de Probes

Step 7b/7c: a fase não declara probes `scripts/*/tests/probe-*.sh`. SKIPPED (sem probes declarados).

### Cobertura de Requisitos

Os 8 IDs aparecem no frontmatter dos PLANs (10-01 a 10-10) e em REQUIREMENTS.md (todos `[x]`, tabela "Complete"); nenhum ID órfão.

| Requisito | Planos | Descrição | Status | Evidência |
|-----------|--------|-----------|--------|-----------|
| CXA-01 | 10-01, 04..08, 10 | Lista "Meus contatos", mais recentes primeiro, paginada, com imóvel/canal/data/retorno | ✓ SATISFIED | Verdades 1 e 2 |
| CXA-02 | 10-01, 04..07, 09, 10 | Filtro por imóvel (opções do servidor) e período (pt-BR), combinados no servidor | ✓ SATISFIED | Verdade 3 (seletor no aparelho = item humano) |
| CXA-03 | 10-01, 04..06, 10 | Anotar retorno por PATCH, espera o servidor, SnackBar fixa | ✓ SATISFIED | Verdade 4 |
| CXA-04 | 10-01, 02, 03, 10 | Isolamento por empresa/corretor testado no Django | ✓ SATISFIED | Verdade 5 |
| CXA-05 | 10-01, 04..08, 10 | Contagem de sem retorno do servidor, sem filtros, atualizada após anotar | ✓ SATISFIED | Verdade 6 |
| CXA-06 | 10-06..10 | Ícone no acervo (só corretor), 401 → login com aviso, textos fixos | ✓ SATISFIED | Verdades 8 e 9 |
| API-13 | 10-02, 03, 05, 10 | §17 do contrato, fixtures capturadas, testes de contrato nos dois repos | ✓ SATISFIED | Verdade 10 |
| API-14 | 10-01, 10 | Web entrega paginação, resumo, opções, PATCH `{}` → 400, atrás de `PertenceAUmaEmpresa` | ✓ SATISFIED | Verdades 5 e 7; 57 testes de `contatos` |

### Anti-Padrões Encontrados

`grep` por `TBD|FIXME|XXX|TODO|HACK` nos arquivos da fase (app e `Web/contatos`): nenhum resultado. Sem retornos vazios, handlers vazios, props hardcoded vazias nem `console.log`-only. Nenhum stub identificado.

### Itens Fora do Escopo / Observações

- Review de código, secure-phase, validate-phase (Nyquist) e ui-review não foram executados por escolha do usuário; não contam como lacuna.
- Riscos aceitos já documentados no §17.9 (lista deixou de ser array; `/api/contatos/imoveis/` sem paginação, APP-12 deve revisitar; hora local do aparelho x site; enum novo no servidor; POST público sem limite de taxa na base atual) — não são lacunas desta fase.
- Caixa do gestor é a APP-12 (OPT-OUT explícito em `COVERAGE.md`), não deferida por lacuna.
- Nenhuma verdade marcada como `coincidental-reliance`.

### Verificação Humana Necessária

Roteiro de fim de fase (5 passos, ainda não executados por um humano), mais a revisão das prohibitions de tier judgment:

1. **Ícones e entrada** — Teste: abrir a caixa pelo ícone do acervo e olhar ícones de canal/sem retorno. Esperado: reconhecíveis e coerentes. Por que humano: aparência.
2. **Cor do chip, textos longos, folhas** — Teste: ver o chip "Aguardando retorno", títulos longos e as folhas de imóvel/anotação. Esperado: destaque claro, sem estourar layout. Por que humano: julgamento visual.
3. **Seletor de período em pt-BR no aparelho** — Teste: tocar em "Período". Esperado: textos em português e filtro aplicado pelo servidor. Por que humano: localização real no dispositivo.
4. **Anotar contra o Django real, com 404 e falha** — Teste: anotar "Falei", forçar 404 e falha de rede. Esperado: item e número do servidor; avisos de texto fixo; 404 recarrega. Por que humano: depende de servidor vivo.
5. **Hora do app x hora do site (fuso de Brasília)** — Teste: comparar o mesmo contato nos dois. Esperado: iguais em Brasília; diferença de 1–2 h em outro fuso (A3). Por que humano: depende do fuso do aparelho.
6. **Prohibitions judgment (unverified-prohibition — human review recommended)** — sem push da web nesta fase; sem vazamento entre empresas/corretores. Evidência colhida acima; veredito do verificador é não autoritativo.

### Resumo das Lacunas

Não há lacunas bloqueantes. O objetivo da fase está atingido no código: a caixa existe, está ligada ponta a ponta (acervo → tela → Cubit → casos de uso → repositório → `Dio` autenticado → API Django paginada e isolada), o comportamento de anotação/cancelamento/sessão tem testes nomeados, e os 8 requisitos estão satisfeitos. O status é `human_needed` apenas pelo roteiro visual/de aparelho/de servidor vivo/de fuso, que testes automatizados não cobrem.

---

_Verificado: 2026-11-24_
_Verificador: Claude (gsd-verifier)_
