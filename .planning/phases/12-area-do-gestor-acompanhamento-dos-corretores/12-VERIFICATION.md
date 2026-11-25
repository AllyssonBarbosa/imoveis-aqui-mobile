---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
verified: 2026-11-25T21:00:00Z
status: human_needed
score: 6/6 must-haves verified
covered_files:
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-01-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-01-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-02-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-02-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-03-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-03-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-04-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-04-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-05-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-05-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-06-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-06-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-07-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-07-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-08-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-08-SUMMARY.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-09-PLAN.md"
  - ".planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-09-SUMMARY.md"
  - "lib/data/datasources/area_gestor_remote_datasource.dart"
  - "lib/data/repositories/area_gestor_repository_impl.dart"
  - "lib/presentation/area_gestor/area_gestor_cubit.dart"
  - "lib/presentation/area_gestor/area_gestor_screen.dart"
  - "lib/presentation/login/login_screen.dart"
  - "lib/presentation/sessao/aviso_area_screen.dart"
  - "lib/presentation/sessao/entrada_area_screen.dart"
  - "test/data/contrato_area_gestor_test.dart"
  - "test/presentation/area_gestor_fluxo_test.dart"
covered_digest: "v4:sha256:97d10bb26c0a899b60cbb9dbfc54d481dedb7d8f41a6f8e2dafc90c650e8324b"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Roteiro de UAT do 12-09-SUMMARY (passos 1 a 6) no emulador Android com a API em http://10.0.2.2:8000: corretor cai em 'Meu acervo'; gestor.vitrine.demo cai na 'Área do gestor' com as 4 seções na ordem; mudança feita pelo corretor aparece em 'Mudanças de situação'; chip 'Período' recarrega só os contatos; botão do topo volta à Área do gestor; gestor@demo.com vê só a Imobiliaria Demo; admin@imoveisaqui.com cai em 'Área do administrador'."
    expected: "Os números do app batem com o painel do site (Relatórios > Acervo e > Contatos) e com o Postgres real; cada papel cai na tela certa; o 'Total: N imóveis' do acervo por corretor é igual ao total da seção de totais."
    why_human: "Depende de emulador, do runserver e do Postgres do Allysson (proibido para o verificador), de login real e da conferência visual contra o painel do site."
  - test: "Passo 7 do roteiro: conferir o visual (verde e branco, blocos 2x2 dos totais, cada seção num cartão, nomes e títulos longos quebrando sem estourar, singulares '1 imóvel', '1 contato', 'último dia'; 403 com 'Tentar de novo')."
    expected: "Tela legível e coerente com o tema Material 3 verde e branco, sem overflow."
    why_human: "Aparência e legibilidade não são asseridas por teste automatizado."
  - test: "Passo 8 do roteiro (revisão humana das proibições): feat/APP12 dos dois repositórios só local (sem push, PR ou merge), .claude/CLAUDE.md sem mudança e o script de preparo do UAT fora dos repositórios."
    expected: "Nada empurrado; CLAUDE.md intacto."
    why_human: "O verificador só confirmou a ausência de ref remota e que o CLAUDE.md não mudou desde os commits antigos; a conferência final do que está na máquina do Allysson é dele."
---

# Phase 12: Área do Gestor — Acompanhamento dos Corretores — Relatório de Verificação

**Objetivo da fase:** Como gestor da imobiliária, acompanhar pelo celular o que a equipe está fazendo: quantos imóveis cada corretor tem, quantos contatos cada um recebeu, o que mudou de situação nos últimos dias e quanto a empresa tem em cada situação (disponível, reservado, vendido, alugado). Card APP 12 (tarefa A12).
**Verificado em:** 2026-11-25
**Status:** human_needed
**Re-verificação:** Não — verificação inicial

## Resumo

Nenhuma lacuna encontrada no código. Os 6 critérios de sucesso do ROADMAP e os `must_haves` dos 9 planos foram conferidos contra o código real dos dois repositórios (app Flutter e web Django), não contra os SUMMARYs. Os testes direcionados que o verificador rodou passaram. O status é `human_needed` porque o roteiro de UAT de 8 passos (emulador, Postgres real, comparação visual com o painel do site) ainda não foi executado e depende de pessoa.

## Alcance do objetivo

### Verdades observáveis (critérios do ROADMAP)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Acervo por corretor, com o total de cada um | VERIFICADO | Web: `acervo_por_corretor()` em `Web/relatorios/servicos.py` agrupa `Imovel` da empresa por `corretor_responsavel`, inclui todo corretor ativo (mesmo com zero) e o desativado que ainda é responsável (`ativo: false`), ordena por quantidade e depois nome, e devolve `total = imoveis.count()`. View `AcervoPorCorretorApiView` e rota `relatorio-acervo-por-corretor` existem. App: `AreaGestorRemoteDataSource.obterAcervoPorCorretor` -> `AcervoPorCorretorModel` -> `SecaoAcervoCorretores` (nome com "(desativado)", "N imóveis"/"Nenhum imóvel", rodapé do servidor). Testes: `AcervoPorCorretorTests` (9 testes, inclui soma = total e desativado), `modelos_area_gestor_test.dart`, `secoes_area_gestor_test.dart`. |
| 2 | Contatos recebidos por corretor e por período | VERIFICADO | `obterContatosPorCorretor([periodo])` chama `/api/relatorios/contatos/` com `de`/`ate` só quando há período (`parametrosDaConsultaContatos`, o mesmo mapeamento da APP-10). `AreaGestorCubit.aplicarPeriodo`/`limparPeriodo` recarregam só a seção de contatos, com versão por seção para descartar resposta de período antigo (testes "dois Tentar de novo seguidos" e de período no cubit). Chip "Período" usa `escolherPeriodoComSeletor` (seletor pt-BR da APP-10). Linha da empresa (`corretor_id` nulo) vira `daEmpresa` com texto fixo do app. |
| 3 | Lista dos imóveis que mudaram de situação nos últimos dias, com quem mudou | VERIFICADO | Web: `mudancas_de_situacao()` filtra `HistoricoSituacao` por `imovel__empresa_id` e janela inclusiva no dia de São Paulo (padrão 7, `ler_dias(..., padrao=DIAS_MUDANCAS_PADRAO)`, 400 com chave `dias` fora de 1..365); `_mudanca()` expõe lista fechada de 9 campos com `alterado_em` em `-03:00`; `MudancasDeSituacaoTests` (9) e `AreaDoGestorApiTests` (9) cobrem janela, ordem, assinatura de contrato, isolamento e 400. App: `MudancasRecentesModel` exige situação conhecida (senão `FormatException`), `SecaoMudancas` mostra "código — título", "Disponível -> Reservado", data/hora local e nome, observação e vazio. |
| 4 | Totais da empresa por situação | VERIFICADO | `obterTotaisPorSituacao` lê só `totais` e `total` de `/api/relatorios/acervo/`; `TotaisPorSituacaoModel.paraEntidade` exige as 4 situações e falha se faltar ou sobrar; `SecaoTotais` mostra 4 blocos e "Total: N imóveis" do servidor. |
| 5 | Todos os números vêm da API, calculados no servidor | VERIFICADO | Varredura em `lib/presentation/area_gestor/**` e nas 4 entidades: nenhum `where`, `fold`, `reduce`, `sort`, soma ou contagem; os únicos `.length` são condição de laço de índice e igualdade das entidades. Cubit só repassa as entidades dos use cases. Repositório não reordena. Cada seção tem estado próprio (carregando/falha/carregada) e a falha de uma não derruba as outras (testes do cubit "repete só a seção pedida", "cada seção repete o seu próprio use case"; fluxo ponta a ponta). Fixtures são capturadas do Django (grupo `gestor` em `tool/capturar_fixtures_api.py`) e `contrato_area_gestor_test.dart` trava chaves, soma = total e exemplos = fixtures. |
| 6 | Só o gestor enxerga esta área; o corretor não | VERIFICADO | Servidor: as 4 rotas usam `RelatorioApiView` com `EhGestor`; `AreaDoGestorApiTests.test_so_o_gestor_entra_nas_rotas_do_app` cobre 403 (corretor e administrador), 401 (anônimo) e 200 (gestor). App: `EntradaAreaScreen` e `LoginScreen` roteiam por `Papel` vindo de `GET /api/auth/eu/` (`Papel.gestor => AreaGestorScreen`, `administrador => AvisoAreaScreen`, `corretor => AcervoScreen`). A única referência a `/api/relatorios/` em `lib/` é o `AreaGestorRemoteDataSource`, alcançável só por `AreaGestorScreen`. O teste de fluxo do corretor afirma `requisicoesDosRelatorios` vazio. 401 leva ao login com "Sua sessão terminou. Entre de novo."; 403 mostra texto fixo. |

**Pontuação:** 6/6 critérios verificados; 0 verdades com comportamento não exercitado (os invariantes de transição — resposta antiga descartada, 401 terminal, nada emitido após `close()` — têm teste nomeado no cubit).

### Verificação dos `must_haves` dos planos

| Plano | Resultado | Evidência principal |
|-------|-----------|---------------------|
| 12-01 (web) | VERIFICADO | Branch `feat/APP12` com 2 commits sobre `e2d1fa0` (`2803c5b`, `5763b90`); diff toca só `README.md`, `relatorios/{servicos,tests}.py` e `relatorios/api/{urls,views}.py`; nenhuma migração; sem ref remota `origin/feat/APP12` (sem push). Rodei `manage.py test relatorios` com `DATABASE_URL="sqlite://:memory:"`: 51 testes, OK. |
| 12-02 | VERIFICADO | As 10 fixtures novas existem em `test/fixtures/api/` (`erro_400_dias`, `erro_400_relatorio_contatos`, `erro_403_relatorio`, `relatorio_acervo`, `relatorio_acervo_por_corretor`, `..._outra_empresa`, `relatorio_contatos`, `relatorio_contatos_periodo`, `relatorio_mudancas`, `relatorio_mudancas_outra_empresa`), todas no commit `18cb39d`; grupo `capturar_gestor` na ferramenta. |
| 12-03 | VERIFICADO | §18 (18.1 a 18.10) em `01-CONTRATO-API.md`; 4 exemplos em `contrato/`; `contrato_area_gestor_test.dart` passa; REQUIREMENTS tem a seção da Área do gestor e a nota no LOG-01. |
| 12-04 | VERIFICADO | 4 entidades, `AreaGestorRepository` e 4 use cases existem; registrados em `lib/di/injection.config.dart` (7 ocorrências dos tipos da fase). |
| 12-05 | VERIFICADO | 4 Models freezed/json; `modelos_area_gestor_test.dart` passa (todas as fixtures, inclusive da outra empresa, e os casos de `FormatException`). |
| 12-06 | VERIFICADO | `AreaGestorRemoteDataSource` no `Dio` `@Named('autenticado')`; `AreaGestorRepositoryImpl` traduz 401 -> `SessaoExpiradaException`, 403 -> `SemPermissaoException`, demais -> `Failure`; testes do datasource e do repositório passam. |
| 12-07 | VERIFICADO | `apresentacao_area_gestor.dart` (textos fixos e funções puras), `AreaGestorState`/`EstadoSecao` e `AreaGestorCubit` (4 versões por seção, `_encerrado` antes de todo `emit`); 15 testes do cubit passam. |
| 12-08 | VERIFICADO | `AreaGestorScreen` numa tela só, 4 seções na ordem totais, acervo, contatos, mudanças; `AppBar` com título e Sair (`confirmarESair`); `BlocListener` do 401 -> `voltarAoLoginComSessaoTerminada`; testes de tela e de seções passam. |
| 12-09 | VERIFICADO (itens automáticos) | Roteamento por papel nos dois pontos; `AvisoAreaScreen` agora só do administrador ("Área do administrador" / "A área do administrador não está no app."); `area_gestor_fluxo_test.dart` sobre a pilha real (`PilhaReal`); REQUIREMENTS com GES-01..06, API-15 e API-16 marcados completos. O roteiro humano (Task 4 e UAT) está pendente. |

### Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `Web/relatorios/servicos.py` | `acervo_por_corretor`, `mudancas_de_situacao`, `ler_dias(padrao)` | VERIFICADO | Implementação real, filtro por `empresa_id`, sem retorno estático. |
| `Web/relatorios/api/views.py` e `urls.py` | 2 views e 2 rotas novas atrás de `EhGestor` | VERIFICADO | Herdam `RelatorioApiView`; `_mudanca()` com lista fechada de campos. |
| `lib/data/**` (4 models, datasource, repositório) | Leitura e tradução de falhas | VERIFICADO | Conferidos por leitura de código e testes. |
| `lib/domain/**` (4 entidades, repositório, 4 use cases) | Domínio puro | VERIFICADO | Só repassam; DI registrado. |
| `lib/presentation/area_gestor/**` (tela, cubit, estado, 4 seções, moldura) | UI e estado | VERIFICADO | Sem cálculo local; textos fixos do app. |
| `lib/presentation/sessao/entrada_area_screen.dart`, `login/login_screen.dart`, `sessao/aviso_area_screen.dart` | Roteamento por papel | VERIFICADO | `switch` sobre `Papel` nos dois pontos de entrada. |
| `01-CONTRATO-API.md` §18 e 4 exemplos | Contrato congelado | VERIFICADO | §18.1 a §18.10 presentes; exemplos iguais às fixtures (travado por teste). |

### Verificação dos elos (key links)

| De | Para | Via | Status |
|----|------|-----|--------|
| `AcervoPorCorretorApiView` / `MudancasSituacaoApiView` | `EhGestor` | herdam `RelatorioApiView` | CONECTADO |
| `mudancas_de_situacao` | `HistoricoSituacao` | `imovel__empresa_id=empresa_id` + janela de datas | CONECTADO |
| `MudancasSituacaoApiView` | `ler_dias` | `padrao=DIAS_MUDANCAS_PADRAO`, `FiltroInvalido` -> `ValidationError` | CONECTADO |
| `AreaGestorRemoteDataSource` | `Dio` autenticado | `@Named('autenticado')` | CONECTADO |
| `obterContatosPorCorretor` | `parametrosDaConsultaContatos` | `ConsultaContatos(periodo: periodo)` | CONECTADO |
| `AreaGestorRepositoryImpl` | `falhas_autenticacao` | 401 e 403 viram exceções de domínio | CONECTADO |
| `AreaGestorScreen` | `voltarAoLoginComSessaoTerminada`, `escolherPeriodoComSeletor`, `confirmarESair` | `BlocListener`, parâmetro `escolherPeriodo`, `IconButton` | CONECTADO |
| `EntradaAreaScreen` / `LoginScreen` | `AreaGestorScreen` | `Papel.gestor => const AreaGestorScreen()` | CONECTADO |
| Botão do topo (`botao_sessao_topo.dart`) | `EntradaAreaScreen` | `builder: (_) => const EntradaAreaScreen()` | CONECTADO |

### Fluxo de dados (nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `SecaoTotais` | `TotaisPorSituacao` | `GET /api/relatorios/acervo/` via `Dio` autenticado | Sim (consulta real no Django; fixture capturada nos testes) | FLUINDO |
| `SecaoAcervoCorretores` | `AcervoPorCorretor` | `GET /api/relatorios/acervo-por-corretor/` | Sim (`Imovel.objects` agrupado) | FLUINDO |
| `SecaoContatosCorretores` | `ContatosPorCorretor` | `GET /api/relatorios/contatos/?de=&ate=` | Sim | FLUINDO |
| `SecaoMudancas` | `MudancasRecentes` | `GET /api/relatorios/mudancas-situacao/` | Sim (`HistoricoSituacao`) | FLUINDO |

### Verificações comportamentais (spot-checks)

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Suíte web de relatórios (acervo por corretor, mudanças, acesso por papel, isolamento) | `DATABASE_URL="sqlite://:memory:" venv/Scripts/python.exe manage.py test relatorios` (em `Web/`) | 51 testes, OK | PASSOU |
| Contrato, models, datasource, repositório, cubit, tela, seções, apresentação, fluxo ponta a ponta, entrada por papel, login | `flutter test` nos 12 arquivos da fase | 172 testes, todos passaram | PASSOU |
| Gate de regressão do orquestrador (informado, não reexecutado) | `flutter analyze lib`, `flutter test` completo, suíte Django | 0 erros/avisos; 1924 testes; 803 OK | Aceito do orquestrador |

Nenhum servidor foi iniciado, sondado ou acessado; nenhum teste apontou para o Postgres de `Web/.env` nem para a porta 8000.

### Execução de probes

Passo 7c: não aplicável. A fase não declara probes (`probe-*.sh`) e não é de migração/ferramentas; nenhum arquivo `scripts/*/tests/probe-*.sh` é citado nos PLAN/SUMMARY.

### Cobertura de requisitos

| Requisito | Plano de origem | Descrição | Status | Evidência |
|-----------|-----------------|-----------|--------|-----------|
| GES-01 | 12-01, 12-04..08 | Acervo por corretor (todo ativo, desativado marcado, total) | SATISFEITO | `acervo_por_corretor` + `SecaoAcervoCorretores`; `AcervoPorCorretorTests` |
| GES-02 | 12-01, 12-04..08 | Contatos por corretor e por período | SATISFEITO | datasource de contatos + cubit de período + chip |
| GES-03 | 12-01, 12-04..08 | Mudanças de situação recentes (janela do servidor) | SATISFEITO | `mudancas_de_situacao` + `SecaoMudancas` |
| GES-04 | 12-01, 12-04..08 | Totais da empresa por situação | SATISFEITO | `TotaisPorSituacaoModel` + `SecaoTotais` |
| GES-05 | 12-02, 12-04..08 | Números do servidor; seção independente | SATISFEITO | varredura sem cálculo local; testes do cubit e do fluxo |
| GES-06 | 12-01, 12-02, 12-03, 12-09 | Só o gestor; 401/403 | SATISFEITO | `EhGestor` + testes de papel no Django + roteamento por `Papel` no app |
| API-15 | 12-01 | Duas rotas novas na web, `feat/APP12`, sem migração | SATISFEITO | diff `e2d1fa0..HEAD`, sem arquivo de migração, 51 testes |
| API-16 | 12-02, 12-03 | §18 do contrato, fixtures capturadas e testes de contrato | SATISFEITO | §18.1..18.10, 4 exemplos, `contrato_area_gestor_test.dart` |

Os 8 IDs declarados nos PLANs constam em `.planning/REQUIREMENTS.md` (linhas 101 a 108, marcados `[x]`, e linhas 235 a 242 da tabela de rastreabilidade como "Phase 12 / Complete"). Nenhum requisito órfão: o mapeamento da Phase 12 no REQUIREMENTS é exatamente este conjunto.

### Anti-padrões encontrados

| Arquivo | Linha | Padrão | Gravidade | Impacto |
|---------|-------|--------|-----------|---------|
| `lib/data/models/*_por_corretor_model.dart` (comentários) | cabeçalhos | Comentário cita `GET /api/relatorios/acervo/por-corretor/` e numeração de § que não coincide com a rota real (`acervo-por-corretor`) | Info | Só documentação; o código usa a rota correta. |

Varredura de `TBD`, `FIXME`, `XXX`, `TODO` e `HACK` nos arquivos `lib/` e `tool/` alterados pela fase: nenhum marcador (a única ocorrência, `XXXXXX` em `mktemp`, é padrão de shell). Nenhum stub, `return null` ou prop vazia hardcoded que alimente a UI.

### Verificação humana necessária

#### 1. UAT de login e conferência com o painel (passos 1 a 6 do roteiro)

**Teste:** no emulador Android (API em `http://10.0.2.2:8000`), seguir o roteiro do `12-09-SUMMARY.md`: entrar como corretor (cai em "Meu acervo"), mudar a situação de um imóvel DISPONÍVEL para Reservado com a observação "Teste APP-12", sair; entrar como `gestor.vitrine.demo@example.com` (senha `Teste12345`) e conferir as 4 seções, a mudança recém-feita, o chip "Período" e o botão do topo; entrar como `gestor@demo.com` (`SenhaForte123`) e ver só a Imobiliaria Demo; entrar como `admin@imoveisaqui.com` (`TrocarSenha123`) e ver "Área do administrador".
**Esperado:** cada papel cai na tela certa; os totais, o acervo e os contatos batem com o painel do site (Relatórios > Acervo e > Contatos); o total do acervo por corretor é igual ao total da seção de totais.
**Por que humano:** exige emulador, runserver e Postgres do Allysson (o verificador não os acessa) e comparação visual contra o painel.

#### 2. Aparência (passo 7)

**Teste:** conferir verde e branco, blocos 2x2 dos totais, cartão por seção, quebra de nomes e títulos longos, singulares ("1 imóvel", "1 contato", "último dia") e o 403 com "Tentar de novo".
**Esperado:** tela legível, sem overflow, coerente com o tema Material 3.
**Por que humano:** aparência e legibilidade não são asseridas por teste.

#### 3. Proibições (passo 8)

**Teste:** confirmar que `feat/APP12` dos dois repositórios segue só local, que `.claude/CLAUDE.md` não mudou e que o script de preparo do UAT ficou fora dos repositórios.
**Esperado:** nada empurrado; CLAUDE.md intacto.
**Por que humano:** o verificador confirmou a ausência de ref remota `feat/APP12` nos dois repositórios e que o CLAUDE.md não tem commit novo, mas o estado na máquina e no GitHub do Allysson é dele.

### Resumo das lacunas

Nenhuma lacuna bloqueante. Pontos de atenção, nenhum deles lacuna de código:

- A caixa de seleção da Phase 12 em `.planning/ROADMAP.md` (linha 34) ainda está `[ ]`; é ajuste de fechamento de fase para o orquestrador.
- Itens fora do escopo, já registrados: a web `main`/`feat/APP12` não tem `canais_contato` no detalhe público (só na `origin/feat/APP06`), e a fase não depende disso.
- Code review, `/gsd-secure-phase 12` e `/gsd-validate-phase 12` rodam à parte por decisão do usuário; sua ausência não foi tratada como lacuna.
- As duas rotas novas só existem na `feat/APP12` da web (PENDENTE WEB já registrado no §18.9 do contrato).

---

_Verificado: 2026-11-25_
_Verificador: Claude (gsd-verifier)_
