---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
verified: 2026-11-22T21:00:00Z
status: human_needed
score: 6/6 must-haves verified
covered_files:
  - ".planning/REQUIREMENTS.md"
  - "lib/data/datasources/gestao_imovel_remote_datasource.dart"
  - "lib/data/repositories/gestao_imovel_repository_impl.dart"
  - "lib/presentation/acervo/acervo_cubit.dart"
  - "lib/presentation/acervo/acervo_screen.dart"
  - "lib/presentation/gestao_imovel/gestao_imovel_cubit.dart"
  - "lib/presentation/gestao_imovel/gestao_imovel_screen.dart"
  - "lib/presentation/gestao_imovel/mudar_situacao_cubit.dart"
  - "lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart"
covered_digest: "v1:sha256:5c0f35a39ba7e681e9b48713a1d1d66106d362d8a45e8df3818c7bda1dc2f6bb"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "AC-5 ponta a ponta contra o Django real: reservar um imóvel `DEV-*` pelo app, abrir a vitrine pública da cidade e conferir que ele sumiu; voltar a Disponível pelo app e conferir que reaparece na consulta seguinte"
    expected: "Reservado não aparece na vitrine pública; ao voltar a Disponível reaparece; o acervo do corretor recarrega com o chip certo"
    why_human: "Depende do Django rodando com dados semeados e do app num aparelho/emulador; os testes automáticos provam a regra do servidor (VitrinePublicaTests) e a recarga do app separadamente, mas nenhum teste liga as duas pontas"
  - test: "Recusa real do servidor por contrato assinado: corretor da empresa demo, `DEMO-CASA-01` (Vendido, contrato assinado), Mudar situação para Disponível e Confirmar"
    expected: "A folha continua aberta com a mensagem do servidor sobre o contrato e a observação preservada; a tela segue Vendido"
    why_human: "A mensagem é do Django real; os testes do app usam a fixture capturada e a ApiFalsa"
  - test: "Colega sem permissão: entrar com o corretor não responsável (`DEV-CAMPINAS-14`) e abrir o imóvel; opcionalmente forçar o POST por curl com o token dele"
    expected: "Tela mostra situação e histórico, sem o botão Mudar situação; o POST forçado recebe 403 com a mensagem do servidor"
    why_human: "Prova AC-6 contra o servidor real (o 403 já é provado pelos testes Django do worktree e o botão ausente pelo fluxo com ApiFalsa)"
  - test: "Visual Material 3 verde e branco da tela de gestão e da folha, gesto de voltar do iOS e botão voltar do Android depois de uma mudança, servidor fora do ar durante o envio, sessão revogada durante o envio, gestor continua na tela de aviso (D-07)"
    expected: "Aparência conforme D-01..D-12; acervo recarrega na volta por qualquer das formas de voltar; textos fixos de falha; login com 'Sua sessão terminou. Entre de novo.'; gestor no aviso"
    why_human: "Aparência, gesto nativo do iOS e comportamento de rede real não são verificáveis por grep nem por teste de widget"
  - test: "Decisões abertas do plano 09-13 (item 10 do roteiro): autorizar ou não o push das branches `feat/APP09` do app e da web, e pedir ou não à equipe web o `max_length` da observação (L8)"
    expected: "Decisão registrada pelo usuário"
    why_human: "Decisão do usuário; nenhum plano pode fazer push sem autorização explícita"
advisory:
  - finding: "WR-01 (09-REVIEW): `recarregar()` durante `tentarNovamenteHistorico()` com falha do imóvel pode deixar o histórico preso em carregando"
    category: other
    reason: "Corrida rara de duas ações do usuário seguidas de falha de rede; recuperável com novo puxar-para-atualizar; não quebra nenhum dos 6 critérios"
    evidence_status: "revisão de código; sem teste vermelho"
  - finding: "WR-02 (09-REVIEW): POST com timeout/5xx que gravou deixa tela e acervo defasados (`mudou` continua falso)"
    category: other
    reason: "O AC-4 trata recusa do servidor; resultado desconhecido por timeout é caso à parte, já registrado no contrato §16.6 como risco aceito (puxar para atualizar corrige a tela). Recomenda-se corrigir antes do UAT final ou na próxima fase"
    evidence_status: "revisão de código; documentado como risco aceito"
  - finding: "WR-03 (09-REVIEW): `tool/capturar_fixtures_api.py` grava no servidor sem trava de host e roda o grupo `situacao` no `--grupo todos` padrão"
    category: other
    reason: "Ferramenta de desenvolvimento; não afeta o app entregue. O contrato §16.7 já avisa 'nunca --grupo todos'"
    evidence_status: "revisão de código"
---

# Fase 9: Mudança de Situação do Imóvel pelo App (APP 09) — Relatório de Verificação

**Objetivo da fase:** o corretor muda a situação do imóvel (disponível, reservado, vendido, alugado) pelo celular, com observação e data; a mudança é pedida à API e o app nunca altera estado local; o histórico aparece na tela do imóvel; a recusa do servidor mostra a mensagem e mantém a situação anterior; a vitrine reflete a mudança na consulta seguinte; só quem o servidor autoriza consegue mudar.
**Verificado em:** 2026-11-22
**Status:** human_needed
**Reverificação:** não, verificação inicial

## Resultado

Todos os seis critérios de aceite têm código real, ligado de ponta a ponta e coberto por teste que passa. Nenhum critério falhou, nenhum artefato é stub e não há marcador de dívida (`TBD`, `FIXME`, `XXX`) nos arquivos da fase. O status é `human_needed` e não `passed` porque o roteiro de fim de fase do plano 09-13 (visual, gesto do iOS, Django real com dados semeados e a ponta a ponta da vitrine) exige uma pessoa, e porque restam decisões do usuário (push, `max_length`).

## Verdades observáveis (critérios do ROADMAP, contrato da fase)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | AC-1: trocar a situação com observação opcional; a data é a do servidor, informada como "Data: hoje" e mostrada com data e hora no histórico (D-05, D-06) | VERIFICADO | `mudar_situacao_sheet.dart`: quatro `ChoiceChip` (atual desabilitado), campo com `maxLength: limiteObservacao` (500, D-17), texto `textoDataHoje`, `FilledButton` Confirmar. O DataSource envia só `situacao` e, se houver texto, `observacao` (`.trim()`), sem data do cliente. Testes: `mudar_situacao_sheet_test`, `gestao_imovel_fluxo_test` ("Mudar situação → chip Reservado → Confirmar: POST com..." e "a observação digitada vai no corpo do POST"). Leitura da data do servidor: `SecaoSituacao` e `HistoricoSituacao` com `dd/MM/yyyy HH:mm`. A exigência literal do card ("informando data") é atendida pela data do servidor, decisão travada D-05 e reescrita no critério 1 do ROADMAP |
| 2 | AC-2: a mudança é feita pela API; o app não altera nada localmente | VERIFICADO | `MudarSituacaoCubit.confirmar` só chama `MudarSituacaoUseCase`; o sucesso emite apenas `EnvioConcluido`. `GestaoImovelCubit.registrarMudanca` marca `mudou` sem tocar em imóvel nem histórico e chama `recarregar()`, que troca o estado só pelo que `GET /api/imoveis/{id}/` e `/historico/` devolveram. O DataSource ignora o corpo do 200 de propósito. O chip do cartão no acervo vem da nova consulta (`AcervoCubit.recarregar`). Teste e2e na pilha real: "volta ao acervo depois da gestão (D-12, SIT-05, AC-2, AC-5)" (cartão "Reservado" vindo de corpo do servidor) |
| 3 | AC-3: o histórico aparece na tela do imóvel | VERIFICADO | `gestao_imovel_screen.dart` renderiza `HistoricoSituacao` no `ImovelGestaoCarregado`; DataSource devolve a lista na ordem do servidor (sem sort, sem paginação); texto vazio do site; falha parcial com "Tentar de novo". Testes: `historico_situacao_test`, fluxo ("a gestão mostra o histórico", "histórico com uma mudança do servidor aparece com de → para...", "falha só do histórico mantém o imóvel na tela...") |
| 4 | AC-4: recusa do servidor mostra a mensagem e mantém a situação anterior | VERIFICADO | `GestaoImovelRepositoryImpl._executar`: 400/403 viram `MudancaSituacaoRecusadaException(texto)` via `mensagemDeRecusa`; `MudarSituacaoCubit._envioDaFalha` mapeia para `EnvioRecusado`; a folha (`PopScope canPop: !enviando`) não fecha e mostra o texto em `colorScheme.error` com a observação preservada (controlador próprio da folha); a tela de baixo não é tocada. 5xx/rede, 404 e 401 têm desfechos próprios. Testes e2e: "contrato assinado (400): a folha continua aberta com o texto...", "quem força a mudança (403)...", "falha 5xx no envio...", "404 no envio...", "401 no envio leva ao login...". WR-02 do code review (timeout ambíguo) é caso de resultado desconhecido, não de recusa do servidor; não quebra o critério (ver Advisory) |
| 5 | AC-5: a vitrine reflete a mudança na consulta seguinte (o servidor decide a publicação) | VERIFICADO (metades) + HUMANO | App: o acervo relê a API na volta com `mudou == true`, mantendo busca e situação (`AcervoCubit.recarregar`, `AcervoScreen._abrirGestao` com `mounted`); sem mudança, nenhum GET novo; vale para AppBar e `handlePopRoute`. Servidor: rodei `VitrinePublicaTests.test_vitrine_so_lista_disponivel_e_publicado` e `test_detalhe_de_imovel_fora_da_vitrine_da_404` no worktree (`Ran 2 tests ... OK`). A ponta a ponta app para Django real é item do UAT humano (nenhum teste liga as duas) |
| 6 | AC-6: só quem o servidor autoriza consegue mudar (corretor responsável pelo app; gestor segue pela web até a APP-12 — D-07) | VERIFICADO | Botão "Mudar situação" só em `if (imovel.podeMudarSituacao)`, valor lido do Django (`pode_mudar_situacao`); nenhum widget decide por papel ou responsável. Colega: teste e2e "colega (pode_mudar_situacao falso): sem Mudar situação e com o histórico à vista". Servidor: `AppSituacaoApiTests` no commit `c02a506` (403 de colega com corpo inválido antes de 400, 403 de gestor na rota do corretor, 404 de outra empresa, 401 sem token), mais a suíte de 403 já existente. A parte "gestor" é honrada como decisão travada D-07 (gestor segue na tela de aviso; a rota do corretor devolve 403 a ele): não é falha |

**Pontuação:** 6/6 verdades verificadas (0 presentes mas sem verificação de comportamento).

### Itens diferidos

| # | Item | Endereçado em | Evidência |
|---|------|---------------|-----------|
| 1 | Gestor mudando a situação pelo app (`/api/gestao/imoveis/{id}/`) | APP-12 | D-07 e D-08 do `09-CONTEXT.md`; critério 6 do ROADMAP já limita o app ao corretor responsável |
| 2 | Data informada pelo corretor (campo novo no `HistoricoSituacao`) | Decisão da equipe web | `09-CONTEXT.md` "Deferred Ideas"; D-05 trava a data do servidor |

## Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `lib/data/datasources/gestao_imovel_remote_datasource.dart` | GET detalhe, GET histórico, POST situação com `Dio` autenticado | VERIFICADO | 73 linhas, rotas com barra final, injetado `@Named('autenticado')`, registrado em `injection.config.dart` |
| `lib/data/repositories/gestao_imovel_repository_impl.dart` | Tradução de 401/404/400/403/rede em falhas tipadas | VERIFICADO | Cadeia única `_executar`; sem retry no POST |
| `lib/data/network/mensagem_de_recusa.dart`, `lib/data/models/imovel_gestao_model.dart`, `mudanca_situacao_model.dart` | Achatamento da mensagem, 9 chaves do imóvel, 6 do histórico | VERIFICADO | Travados por `contrato_gestao_situacao_test` |
| `lib/domain/usecases/{mudar_situacao,obter_historico_situacao,obter_imovel_gestao}_usecase.dart` + entidades + repositório | Camada de domínio | VERIFICADO | Registrados no DI |
| `lib/presentation/gestao_imovel/*` (screen, cubit, state, sheet, cabeçalho, seção, histórico) | Tela de gestão e folha | VERIFICADO | 310 + 191 + 194 linhas; sem `try/catch` na UI; cores do `ColorScheme` |
| `lib/presentation/acervo/{acervo_screen,acervo_cubit,widgets/cartao_imovel_acervo}.dart` | Todo cartão abre a gestão; recarga na volta | VERIFICADO | `aoTocar` sempre ligado; `_abrirGestao` recarrega só com `mudou` |
| `.planning/phases/01-*/01-CONTRATO-API.md` §16 | Rotas, corpo, 200/400/401/403/404, histórico, riscos | VERIFICADO | §16.1 a §16.7 presentes, com fixtures capturadas em `test/fixtures/api/` |
| `tool/capturar_fixtures_api.py` (grupo `situacao`) | Captura do wire real | VERIFICADO (com WR-03) | Fixtures `situacao_200`, `erro_400_mesma_situacao`, `erro_403_situacao`, `erro_404_historico`, `historico_*`, `imovel_gestao_*` presentes |
| Web `feat/APP09` (`c02a506`): `Web/imoveis/tests.py`, `Web/contratos/tests.py` | Testes das rotas do corretor, sem mudança de código de produção | VERIFICADO | Só testes (164 linhas adicionadas); árvore limpa |

## Ligações-chave

| De | Para | Via | Status |
|----|------|-----|--------|
| Cartão do acervo | `GestaoImovelScreen` | `aoTocar` → `_abrirGestao` → `abrirGestaoImovel` (`Navigator.push`) | LIGADO |
| `GestaoImovelScreen` | `MudarSituacaoCubit` | botão `FilledButton.icon` → `mostrarMudarSituacaoSheet` com `BlocProvider.value` | LIGADO |
| `MudarSituacaoCubit` | `POST /api/imoveis/{id}/situacao/` | UseCase → Repository → DataSource (`Dio` autenticado) | LIGADO |
| `EnvioConcluido` | releitura da API | `BlocListener` → `registrarMudanca()` → `recarregar()` (GET detalhe + histórico em paralelo) | LIGADO |
| Volta da gestão | `AcervoCubit.recarregar` | `abrirGestaoImovel` devolve `cubit.state.mudou` | LIGADO |
| 401 em qualquer chamada | login com "Sua sessão terminou..." | `voltarAoLoginComSessaoTerminada` (leituras e envio) | LIGADO |

## Fluxo de dados (nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `SecaoSituacao` / botão | `imovel.situacao`, `situacaoDesde`, `podeMudarSituacao` | `GET /api/imoveis/{id}/` via `ImovelGestaoModel` | Sim | FLUINDO |
| `HistoricoSituacao` | lista de `MudancaSituacao` | `GET /api/imoveis/{id}/historico/` | Sim | FLUINDO |
| Cartão do acervo pós-volta | chip de situação | nova consulta `GET /api/imoveis/` | Sim | FLUINDO |

## Verificações de comportamento

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Contrato §16, DataSource, fluxo e2e, folha, Cubit da folha, tela, acervo | `flutter test` nos 7 arquivos relevantes | 153 testes, "All tests passed!" | PASSOU |
| Suíte completa do app | Observada pelo orquestrador: `flutter analyze lib` limpo, `flutter test` 1442 verdes | passou | PASSOU (não repetida) |
| Suíte Django do worktree `feat/APP09` | `manage.py test --noinput` | `Ran 753 tests ... OK` | PASSOU |
| Metade do servidor do AC-5 | `VitrinePublicaTests` (2 testes nomeados) | `Ran 2 tests ... OK` | PASSOU |

## Execução de probes

Passo ignorado: a fase não declara probes (`scripts/*/tests/probe-*.sh`); a verificação é feita por testes Dart e Django.

## Cobertura de requisitos

Todos os nove IDs aparecem no frontmatter `requirements` dos planos e no REQUIREMENTS.md (checkbox `[x]` e linha `Complete` na tabela de rastreabilidade). Não há requisito órfão mapeado à Fase 9 sem plano.

| Requisito | Planos | Descrição | Status | Evidência |
|-----------|--------|-----------|--------|-----------|
| SIT-01 | 09-07, 09-09, 09-10, 09-11, 09-13 | Folha com chips, observação opcional, data do servidor | SATISFEITO | Verdade 1 |
| SIT-02 | 09-08, 09-09, 09-10, 09-11, 09-13 | POST à API; app não altera local; relê na sequência | SATISFEITO | Verdade 2 |
| SIT-03 | 09-03, 09-06, 09-07, 09-13 | Histórico na tela, ordem do servidor, vazio do site | SATISFEITO | Verdade 3 |
| SIT-04 | 09-08, 09-09, 09-11, 09-12, 09-13 | Recusa 400/403 com mensagem; rede/5xx, 404 e 401 | SATISFEITO | Verdade 4 |
| SIT-05 | 09-13 | Acervo recarrega na volta; vitrine reflete (regra do servidor) | SATISFEITO (ponta a ponta no UAT) | Verdade 5 |
| SIT-06 | 09-02, 09-10, 09-12, 09-13 | Só o responsável pelo app; 403 testado no Django | SATISFEITO | Verdade 6 |
| SIT-07 | 09-03, 09-04, 09-05, 09-07, 09-10, 09-13 | Todo cartão abre a gestão; "Ver na vitrine" só com `na_vitrine` e some após mudança | SATISFEITO | `cartao_imovel_acervo.dart`, `gestao_imovel_screen.dart` (`previa.naVitrine && !state.mudou`) |
| API-11 | 09-01, 09-13 | §16 do contrato com fixtures capturadas e teste de contrato | SATISFEITO | §16 presente; `contrato_gestao_situacao_test.dart` passa |
| API-12 | 09-02, 09-13 | Testes Django do corretor, sem código de produção, sem push | SATISFEITO | Commit `c02a506` só toca arquivos `tests.py`; suíte 753 OK; sem `origin/feat/APP09` |

## Anti-padrões

Varredura em todos os arquivos de produção da fase: nenhum `TBD`/`FIXME`/`XXX`/`TODO`/`HACK` (o único `XXX` é o modelo do `mktemp` em `tool/capturar_fixtures_api.py`, não é marcador de dívida). Nenhum stub; nenhum `try/catch` em UI. Achados do code review (`09-REVIEW.md`), todos sem bloquear critério:

| Arquivo | Achado | Severidade | Impacto |
|---------|--------|------------|---------|
| `gestao_imovel_cubit.dart:88-95` | WR-01: histórico pode ficar preso em carregando (corrida rara) | Aviso | Recuperável com puxar para atualizar |
| `mudar_situacao_cubit.dart` / `gestao_imovel_screen.dart` | WR-02: timeout/5xx do POST que gravou deixa tela e acervo defasados | Aviso | Fora do escopo literal do AC-4 (recusa); risco aceito no contrato §16.6; recomendo corrigir (marcar `mudou` e reler no `EnvioFalhou`) |
| `tool/capturar_fixtures_api.py` | WR-03: sem trava de host; `--grupo todos` por padrão inclui escrita | Aviso | Ferramenta de desenvolvimento, não afeta o app |
| vários | IN-01 a IN-06 (403 de leitura, `podeConfirmar` com `EnvioConcluido`, toque duplo no cartão, 404 sem reação na folha, corte UTF-16, duplicações) | Info | Qualidade; nenhum quebra critério |

## Verificação humana necessária

Os itens abaixo vêm do roteiro `<human-check>` do plano 09-13 consolidado com a análise do verificador.

### 1. Vitrine reflete a mudança, ponta a ponta (AC-5)

**Teste:** com o Django do worktree `feat/APP09` rodando, reservar um `DEV-*` pelo app, abrir a vitrine pública da cidade; depois voltar a Disponível pelo app.
**Esperado:** o imóvel some da vitrine quando reservado e reaparece na consulta seguinte quando disponível; o acervo do corretor mostra o chip certo na volta.
**Por que humano:** exige o servidor real com dados semeados; os testes automáticos só provam cada metade separadamente.

### 2. Recusa real por contrato assinado (AC-4)

**Teste:** corretor da empresa demo, `DEMO-CASA-01` (Vendido, contrato assinado), mudar para Disponível e Confirmar.
**Esperado:** folha aberta com a mensagem do servidor e a observação preservada; tela continua Vendido.
**Por que humano:** a mensagem real vem do Django.

### 3. Colega sem botão e 403 forçado (AC-6)

**Teste:** entrar com o corretor não responsável (`DEV-CAMPINAS-14`), abrir o imóvel; opcionalmente forçar o POST por curl.
**Esperado:** situação e histórico visíveis, sem "Mudar situação"; POST forçado recebe 403 com mensagem.
**Por que humano:** conferência contra o servidor real.

### 4. Visual, gesto e falhas reais

**Teste:** visual Material 3 verde e branco da tela e da folha; voltar pelo gesto do iOS e pelo botão do Android depois de uma mudança; servidor fora do ar durante o envio; sessão revogada durante o envio; gestor entra e vê o aviso (D-07).
**Esperado:** conforme D-01..D-12 e D-10; acervo recarrega por qualquer forma de voltar; textos fixos de falha; login com "Sua sessão terminou. Entre de novo."
**Por que humano:** aparência, gesto nativo e rede real.

### 5. Decisões do usuário

**Teste:** decidir o push das duas `feat/APP09` (app e web) e se a equipe web recebe o pedido de `max_length` da observação (L8).
**Esperado:** decisão registrada.
**Por que humano:** nenhuma decisão de push pode ser tomada por agente.

## Resumo das lacunas

Nenhuma lacuna bloqueante. O código entrega os seis critérios de aceite conforme as decisões travadas (data do servidor, D-05; gestor fora do app até a APP-12, D-07). Recomendação antes de fechar a fase: tratar o WR-02 (resultado desconhecido do POST) e o WR-01, que são correções pequenas, e então rodar o roteiro humano acima.

---

_Verificado em: 2026-11-22_
_Verificador: Claude (gsd-verifier)_
