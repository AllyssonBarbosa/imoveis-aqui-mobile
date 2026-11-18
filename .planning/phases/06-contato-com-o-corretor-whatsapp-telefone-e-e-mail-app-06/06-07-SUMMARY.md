---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 07
subsystem: apresentacao
tags: [contato, cubit, freezed, bottomNavigationBar, whatsapp, bloc_test, e2e]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "ContatarCorretorUseCase, LinkLauncherGateway e falhas tipadas (06-05, 06-06); CanalContato e DetalheImovel.canaisContato (06-04); ApiFalsa com POST de contato (06-03, 06-05)"
provides:
  - "ContatoCubit (@injectable) com contatar(imovelId, canal) e ContatoState (ocioso, enviando, falhou) + MotivoFalhaContato"
  - "BarraContato reutilizavel (legenda + botao do canal principal) em presentation/contato/widgets"
  - "Barra inferior fixa na pagina do imovel, so com detalhe carregado e canais, com legenda de preco D-07"
  - "rotulo/icone por canal e mensagem por motivo (strings D-14/D-15) em rotulos_contato.dart"
affects: [06-08, 06-09, 06-10]

plan_head_before: 3d54dc675abc462ec367da913ef0a37137013920
actuals:
  tokens: 6700   # chars/4 sobre as linhas alteradas (sem .freezed.dart e injection.config.dart)
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count 3d54dc6..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Um Cubit de contato sem imovelId no construtor (imovel vem em contatar), servindo pagina e perfil sem @factoryParam"
    - "Estado so com CanalContato/MotivoFalhaContato: link, numero e e-mail nunca entram no estado"
    - "Motivo da falha decidido por switch sobre o tipo da excecao, com isClosed antes e depois do await"
    - "Legenda da barra mede cada linha de preco com TextPainter dentro de LayoutBuilder (D-07)"

key-files:
  created:
    - lib/presentation/contato/contato_state.dart
    - lib/presentation/contato/contato_state.freezed.dart
    - lib/presentation/contato/contato_cubit.dart
    - lib/presentation/contato/rotulos_contato.dart
    - lib/presentation/contato/widgets/barra_contato.dart
    - test/presentation/contato_cubit_test.dart
  modified:
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/detalhe_navegacao_test.dart

key-decisions:
  - "BlocBuilder do detalhe sobe para envolver o Scaffold e bottomNavigationBar e null (nunca SizedBox) fora de DetalheCarregado com canais (D-03, D-08)"
  - "A barra nao depende de detalhe.corretor: a empresa pode ser o destino (Open Question 2)"
  - "getIt<ContatoCubit> so dentro de abrirDetalheImovel (decisao 04-01); BarraContato le o Cubit do contexto"
  - "Legenda D-07: todas as linhas do cabecalho quando cada uma cabe; so a principal em VENDA_E_ALUGUEL longo demais"

requirements-completed: [APP06-C2, APP06-C4, APP06-C6]

coverage:
  - id: D1
    description: "Ponta a ponta da vitrine: tocar em WhatsApp na pagina faz POST sem authorization/cookie com {canal: WHATSAPP} e entrega ao lancador exatamente o link capturado, sem SnackBar"
    requirement: APP06-C2
    verification:
      - kind: widget
        ref: "test/presentation/detalhe_navegacao_test.dart 'tocar em WhatsApp na pagina registra o contato sem login...'"
        status: pass
    human_judgment: false
  - id: D2
    description: "Cubit: sucesso, sete tipos de falha mapeados por tipo, toque duplo com uma so chamada, falhas seguidas emitem de novo, close durante o POST sem emitir nem lancar, Loading"
    requirement: APP06-C4
    verification:
      - kind: unit
        ref: "test/presentation/contato_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Barra inferior presente com canais (BarraContato no Scaffold) e preco repetido na legenda; DI real resolve ContatoCubit, LinkLauncherGateway, ContatoRepository e ContatoDataSource"
    requirement: APP06-C1
    verification:
      - kind: widget
        ref: "test/presentation/detalhe_navegacao_test.dart 'fluxo completo' e 'DI real'"
        status: pass
    human_judgment: false
  - id: D4
    description: "Aparencia real da barra (ordem visual, ellipsis e empilhamento da legenda em telas estreitas, icones Material) e abertura do WhatsApp em aparelho"
    requirement: APP06-C1
    verification: []
    human_judgment: true
    rationale: "Testes de widget nao julgam layout fino nem o app externo real; fica para a verificacao manual da fase (06-10) e os casos de widget do 06-09"
---

# Phase 6 Plan 07: Barra de contato na pagina do imovel Summary

**`ContatoCubit` + `BarraContato` reutilizaveis em `presentation/contato/`, plugados em `bottomNavigationBar` so quando o detalhe carregou com canais: tocar em WhatsApp faz o POST sem credencial e abre o link do servidor, provado da vitrine ate o lancador falso, com a maquina de estados travada por bloc_test.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-11-18
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 9 (6 criados, 3 modificados)

## Accomplishments

- `ContatoState` (freezed, `ocioso`/`enviando(canal)`/`falhou(motivo)`) e `enum MotivoFalhaContato`; o estado nunca carrega link, numero ou e-mail.
- `ContatoCubit` (`@injectable`): ignora `contatar` com Cubit fechado ou `ContatoEnviando` (D-13), `isClosed` depois do await, motivo por `switch` sobre o tipo (canalIndisponivel, imovelIndisponivel, limiteExcedido, semAplicativo, generico).
- `rotulos_contato.dart`: `rotulo`/`icone` por canal (Material: `chat`, `call`, `email_outlined`) e as cinco mensagens D-14/D-15 verbatim.
- `BarraContato`: `Material` + `SafeArea` + `Row` com a legenda e `FilledButton.icon` do canal principal (WhatsApp, Telefone, E-mail), desabilitado enquanto `ContatoEnviando`.
- Pagina do imovel: `BlocBuilder` envolvendo o `Scaffold`; `bottomNavigationBar` so em `DetalheCarregado` com `canaisContato` nao vazio (`null` nos demais, inclusive com corretor nulo); `_LegendaPrecoDaBarra` com `LayoutBuilder` + `TextPainter`; `abrirDetalheImovel` com `MultiBlocProvider` e `criarContatoCubit`.
- Tracer: o toque em "WhatsApp" na pagina faz um POST em `/api/publico/imoveis/<id>/contato/` com `{'canal': 'WHATSAPP'}`, sem `authorization`/`cookie`, e o lancador recebe exatamente o `link` de `contato_201_whatsapp.json`.

## Task Commits

1. **Task 1 (tracer): barra de contato na pagina do imovel** - `1055b0a` (feat)
2. **Task 2: estados do ContatoCubit** - `a1a57f5` (test)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Asserções pré-existentes reescritas

As asserções abaixo mudaram de sentido porque o `detalhe_casa.json` recapturado agora tem canais, logo a barra repete o preco do cabecalho. Nenhum teste foi apagado nem afrouxado: cada uma passou a afirmar o comportamento novo e mais preciso.

1. `fluxo completo`, preco `495.000` (`findsOneWidget` na pagina inteira): agora achado uma vez dentro do `CustomScrollView` (cabecalho) e uma vez dentro de `BarraContato` (legenda), pois a pagina inteira passou a ter duas ocorrencias.
2. `fluxo completo`, "Sem barra inferior fixa (D-12)" (`bottomNavigationBar` `isNull`): agora `isA<BarraContato>()` (barra de contato do APP 06, D-05); `persistentFooterButtons` continua nulo.
3. (Fora das duas previstas no plano, ver Deviations) `natureza no wire real`, lote, preco `235.000`: mesmo motivo do item 1, reescrita para cabecalho + barra.

## Verificacao

- `dart run build_runner build -d`: sem SEVERE; `injection.config.dart` registra `ContatoCubit`.
- `flutter test test/presentation/detalhe_navegacao_test.dart`: 16 passaram (o e2e `--plain-name "registra o contato sem login"` roda e passa). `detalhe_imovel_screen_test.dart` e `perfil_corretor_screen_test.dart`: passaram (41 no total do comando).
- `flutter test test/presentation/contato_cubit_test.dart`: 13 passaram. `flutter test test/presentation/`: 385 passaram. `flutter test` (suite inteira): 676 passaram. `flutter analyze`: sem issues.
- grep de `class _LegendaPrecoDaBarra`, `TextPainter` e `LayoutBuilder` na tela: presentes. `getIt<ContatoCubit>` aparece so em `abrirDetalheImovel`.
- Task 2 era de caracterizacao (os testes passaram de primeira com o Cubit do Task 1; nenhuma correcao no Cubit foi necessaria).
- Verificacao "spec-less probe fallback": pulada no planejamento, conforme registrado no proprio plano.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug de teste] Terceira asserção de preço do lote**
- **Found during:** Task 1 (rodando `detalhe_navegacao_test.dart`)
- **Issue:** `naPagina(find.textContaining('235.000'))` no teste do lote esperava um unico widget; com a barra de contato o preco aparece no cabecalho e na legenda (2 widgets). O plano listava so duas asserções a reescrever, mas esta tem a mesma causa.
- **Fix:** reescrita para exigir uma ocorrencia no `CustomScrollView` (cabecalho) e uma em `BarraContato`.
- **Files modified:** test/presentation/detalhe_navegacao_test.dart
- **Commit:** 1055b0a

**Total deviations:** 1 auto-fixed. **Impact:** so escopo de teste; nenhum comportamento de producao mudou alem do planejado.

## Known Stubs

None.

## Threat Flags

None - sem superficie nova alem da coberta pelo threat model (T-06-07-01 a T-06-07-05 mitigados: guarda `ContatoEnviando` + botao desabilitado, estado so com canal/motivo, `getIt` so em `abrirDetalheImovel`, `isClosed` antes/depois do await, e2e sem `authorization`/`cookie`).

## Issues Encountered

None.

## Self-Check: PASSED

- Arquivos criados presentes: contato_state.dart, contato_state.freezed.dart, contato_cubit.dart, rotulos_contato.dart, widgets/barra_contato.dart, contato_cubit_test.dart.
- Commits `1055b0a` e `a1a57f5` existem em feat/APP06; `git rev-list --count 3d54dc6..HEAD` = 2.
