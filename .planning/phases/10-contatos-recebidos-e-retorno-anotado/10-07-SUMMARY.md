---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 07
subsystem: presentation
tags: [apresentacao, item-contato, rodape, flutter_localizations, pt-BR, date-range-picker]

requires:
  - phase: 10-04
    provides: "ContatoRecebido, RetornoContato, CanalContato, PeriodoContatos"
  - phase: 10-06
    provides: "camada de dados da caixa (consumida a partir do 10-08)"
provides:
  - "apresentacao_contatos.dart: 5 textos fixos, textoSemRetorno, formatarDataHoraContato, textoAnotadoEm, rotuloImovelDoContato, NomeCanalContato.nomeExibicao, ApresentacaoRetornoContato.rotulo"
  - "ItemContato (Card + chip de retorno destacado para pendente, 'anotado em' so com retornoEm)"
  - "RodapePaginacaoLista.mensagemErro (padrao antigo preservado)"
  - "app em pt-BR no Material: flutter_localizations direto, app_localizacao.dart, MaterialApp em main.dart"
  - "seletor_periodo.dart: EscolherPeriodo, primeiraDataDoSeletor, escolherPeriodoComSeletor"
affects: [10-08, 10-09, 10-10]

commits: 4
plan_head_before: e3b25f197aa70c64b939be6eabb2803e8fdf17d1
plan_head_after: 6a94016fd0b848ad8623975bd85d9452c01e9515

estimate_actuals_note: "tokens = chars/4 sobre o diff do app e3b25f1..6a94016 fora de .planning e do pubspec.lock (26687 chars, inclui os testes)"
actuals:
  tokens: 6672
  tasks: 2
  commits: 4

tech-stack:
  added: ["flutter_localizations (pacote do SDK, ja transitivo; agora dependencia direta)"]
  patterns:
    - "Formatador de data sem locale (DateFormat('dd/MM/yyyy HH:mm')) para teste sem inicializar dados de locale"
    - "Configuracao de localizacao num arquivo unico compartilhado por main.dart e testes"
    - "Chip privado extraido como widget (sem metodos buildX)"

key-files:
  created:
    - lib/presentation/contatos/apresentacao_contatos.dart
    - lib/presentation/contatos/widgets/item_contato.dart
    - lib/presentation/contatos/widgets/seletor_periodo.dart
    - lib/app_localizacao.dart
    - test/presentation/apresentacao_contatos_test.dart
    - test/presentation/item_contato_test.dart
    - test/presentation/seletor_periodo_pt_br_test.dart
  modified:
    - lib/presentation/perfis/widgets/rodape_paginacao_lista.dart
    - lib/main.dart
    - pubspec.yaml
    - pubspec.lock
    - test/main_launch_routing_test.dart

key-decisions:
  - "ignore: deprecated_member_use em GlobalMaterialLocalizations.delegates (unico ponto): a obsolescencia aponta para material_ui, pacote nao adotado; evita um info novo que quebraria o gate do plano"
  - "Teste do seletor usa datas relativas a hoje (nao as fixas de novembro/2026 do <behavior>) para nao depender do relogio da maquina, ja que lastDate = hoje"
  - "Cor do chip 'Aguardando retorno' (tertiaryContainer/onTertiaryContainer) segue Claude's Discretion; confirmar no human-check do fim da fase"

requirements-completed: []

coverage:
  - id: D1
    description: "ItemContato mostra 'codigo — titulo' (ate 2 linhas), canal com icone e nome, data dd/MM/yyyy HH:mm, chip de retorno destacando 'Aguardando retorno' e 'anotado em ...' quando houver, sem corretor"
    requirement: "CXA-01"
    verification:
      - kind: test
        ref: "test/presentation/item_contato_test.dart"
        status: pass
    human_judgment: true
    rationale: "Cor/destaque do chip e a aparencia do item sao julgamento visual, confirmados no human-check do fim da fase"
  - id: D2
    description: "Textos fixos da caixa (numero sem retorno, vazio, sem resultado, erro, erro no rodape) e rotulos de canal e retorno iguais aos do site"
    requirement: "CXA-05"
    verification:
      - kind: test
        ref: "test/presentation/apresentacao_contatos_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Rodape de paginacao com mensagem de erro configuravel, preservando acervo, vitrine e perfis"
    requirement: "CXA-06"
    verification:
      - kind: test
        ref: "test/presentation/item_contato_test.dart#RodapePaginacaoLista.mensagemErro"
        status: pass
      - kind: test
        ref: "test/presentation/acervo_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "App em pt-BR no Material e seletor de periodo com 'Salvar'/'Selecione o intervalo', firstDate 2024, lastDate hoje, sem atalhos"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/seletor_periodo_pt_br_test.dart"
        status: pass
      - kind: test
        ref: "test/main_launch_routing_test.dart#o MaterialApp fala pt-BR"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 07: Apresentacao da caixa e pt-BR do Material Summary

**Textos fixos, rotulos de canal/retorno e data `dd/MM/yyyy HH:mm` sem locale, `ItemContato` com chip de retorno destacado, rodape com `mensagemErro`, e o app inteiro em pt-BR (`flutter_localizations` + `app_localizacao.dart`) com o seletor de periodo de `firstDate = 2024` ate hoje, sem atalhos.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2 (TDD: RED e GREEN commitados separados em cada uma)
- **Files:** 12 (7 criados, 5 modificados)

## Accomplishments

- `apresentacao_contatos.dart`: constantes `tituloCaixaContatos`, `textoCaixaVazia`, `textoCaixaSemResultado`, `textoErroCaixa`, `textoErroAoCarregarMaisContatos`; `textoSemRetorno` (zero/singular/plural), `formatarDataHoraContato` e `textoAnotadoEm` (puros, sem `toLocal`, `DateFormat` sem locale), `rotuloImovelDoContato`; `switch` exaustivo para `nomeExibicao` do canal e `rotulo` do retorno. Nenhum texto vem do servidor (T-10-19).
- `ItemContato`: `Card` + `InkWell(aoTocar)`; titulo em `titleMedium` com `maxLines: 2` e reticencias; icone do canal (so o `.icone` da F6) com o nome proprio; data; chip privado `_ChipRetorno` (`tertiaryContainer`/`onTertiaryContainer` para pendente, `surfaceContainerHighest`/`onSurfaceVariant` para os demais) e "anotado em ..." so quando ha `retornoEm`. Sem o corretor.
- `RodapePaginacaoLista.mensagemErro` com o texto antigo como padrao; testes de acervo e perfis seguem verdes.
- `flutter_localizations` declarado (`sdk: flutter`); o diff do `pubspec.lock` e uma unica linha (`transitive` -> `direct main`). `lib/app_localizacao.dart` exporta `delegatesDeLocalizacao` e `localesSuportados` (`[Locale('pt', 'BR')]`), usados em `main.dart` e nos testes; sem `locale:` fixo.
- `seletor_periodo.dart`: `EscolherPeriodo`, `primeiraDataDoSeletor = DateTime(2024)` e `escolherPeriodoComSeletor` (`lastDate` = hoje sem hora, sem `helpText`/`saveText`, sem atalhos). Testado: limites, "Salvar" e "Selecione o intervalo" (sem "Save"), sem "7 dias"/"30 dias", Salvar devolve os mesmos dias, "Fechar" devolve `null`.

## Task Commits

1. **Task 1 (RED)** - `e44d871` (test)
2. **Task 1 (GREEN)** - `4794336` (feat)
3. **Task 2 (RED)** - `6b71557` (test)
4. **Task 2 (GREEN)** - `6a94016` (feat)

**Plan metadata:** commit `docs(10-07)` (este SUMMARY + STATE + ROADMAP).

## Verification

- Testes dos 4 arquivos de apresentacao/item + acervo + perfis: verdes. Testes do seletor e do `main_launch_routing_test.dart`: verdes (13).
- Gate da onda 7 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 errors/warnings, 43 infos (41 pre-existentes + 2 do `material.dart` nos novos `item_contato.dart` e `seletor_periodo.dart`), 0 infos fora do `material.dart`. `flutter analyze --no-fatal-infos lib test`: 75 infos, 0 errors/warnings. `flutter test` inteiro: **1374 verdes** (1354 + 20 novos).
- Greps dos `<automated>` das duas tasks: todos passam (inclusive nenhum locale explicito sob `lib/presentation/contatos`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `GlobalMaterialLocalizations` obsoleto gerava info novo no analyze**
- **Found during:** Task 2 (gate do analyze)
- **Issue:** `GlobalMaterialLocalizations.delegates` esta marcado `deprecated_member_use` (aponta para `material_ui`), um info fora do padrao `material.dart` aceito pelo gate do plano.
- **Fix:** `// ignore: deprecated_member_use` na unica linha, com comentario explicando; nenhum pacote novo (`material_ui` nao foi adotado, o plano proibe outras dependencias).
- **Files modified:** `lib/app_localizacao.dart`
- **Commit:** `6a94016`

**2. [Rule 1 - Teste robusto] Datas relativas a hoje no teste do seletor**
- **Found during:** Task 2 (escrita do teste)
- **Issue:** o `<behavior>` cita `DateTime(2026, 11, 1)..DateTime(2026, 11, 22)`, mas `lastDate` = hoje: com o relogio antes de 22/11/2026 o `initialDateRange` violaria a asserção do picker.
- **Fix:** o teste usa `hoje - 20 dias` e `hoje - 1 dia`; a cobertura do comportamento e a mesma.
- **Files modified:** `test/presentation/seletor_periodo_pt_br_test.dart`
- **Commit:** `6b71557`

**Total deviations:** 2 auto-fixed (1 blocking, 1 de robustez de teste). **Impact:** nenhum no escopo ou nos contratos do plano.

## Issues Encountered

None.

## Known Stubs

None. `ItemContato` e `escolherPeriodoComSeletor` ainda nao sao usados por nenhuma tela: a montagem e do 10-08/10-09 (declarado no plano).

## Threat Flags

None - T-10-19 (todos os textos fixos do app, `switch` exaustivo) e T-10-SC (`flutter_localizations` e do SDK, nenhum outro pacote, lock com 1 linha alterada) mitigados.

## Next Phase Readiness

Pronto para o 10-08: textos, item, rodape e seletor existem e estao testados. O 10-09 usa `EscolherPeriodo`/`escolherPeriodoComSeletor` nos filtros. A cor do chip "Aguardando retorno" fica para o human-check do fim da fase. Nenhum `git push`.

## Self-Check: PASSED

- Os 12 arquivos existem; commits `e44d871`, `4794336`, `6b71557` e `6a94016` presentes na `feat/APP10`; `git rev-list --count e3b25f1..HEAD` = 4.
