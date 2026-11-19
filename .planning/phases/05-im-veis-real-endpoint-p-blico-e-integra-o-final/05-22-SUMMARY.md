---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 22
subsystem: api
tags: [contract, docs, rate-limit, validation, flutter-test, antidrift]
gap_closure: true

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-19 (tetos e mensagens 400), 05-20 (teto de 20 caracteristicas), 05-21 (429 + Retry-After, VITRINE_TAXA_ANONIMA, NUM_PROXIES)"
provides:
  - "01-CONTRATO-API.md: formato e teto de cada parametro (§5), tabela campo -> mensagem dos 400, secao 'Erros 429 (limite de taxa)', 5 riscos novos no §8, nota de antidrift no §12"
  - "3 testes no app que provam 400/429 -> DioException -> Result.failure e 429 do detalhe != ImovelNaoEncontradoException, sem mudar lib/"
  - "README da API com tetos, bullet 'Limite de taxa', VITRINE_TAXA_ANONIMA/NUM_PROXIES e nota de deploy"
affects: [05-verify-work, uat-fim-de-fase]

plan_head_before: 2e403e8
actuals:
  tokens: 3300
  tasks: 2
  commits: 0

tech-stack:
  added: []
  patterns:
    - "Cada mensagem e teto do contrato conferido por grep contra views.py (lastro no codigo)"
    - "Testes de caracterizacao no app: erro novo da API cai no mesmo Result.failure sem codigo novo"

key-files:
  created: []
  modified:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - test/data/imovel_remote_datasource_test.dart
    - test/data/imovel_detalhe_repository_impl_test.dart
    - ../imoveis-aqui/README.md

key-decisions:
  - "Nenhum codigo commitado em nenhum dos dois repos (decisao do usuario: opcao-a na API; no app, contrato e testes aguardam o OK)"
  - "Nao rodar dart format nos testes existentes: o formatter local reescreve codigo antigo; novos testes escritos a mao no estilo do arquivo"

requirements-completed: [API-03, API-07]

coverage:
  - id: D1
    description: "Contrato descreve tetos, formato numerico e todas as mensagens 400 com lastro no views.py (SC3, D-02)"
    requirement: API-03
    verification:
      - kind: other
        ref: "grep -qF de cada mensagem/teto em 01-CONTRATO-API.md e em Web/imoveis/api/views.py (todos presentes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Secao 'Erros 429 (limite de taxa)': status, Retry-After, {detail}, escopo vitrine_publica nas 5 rotas, 120/min, NUM_PROXIES, comportamento do app"
    requirement: API-07
    verification:
      - kind: other
        ref: "grep Retry-After / VITRINE_TAXA_ANONIMA / NUM_PROXIES / 'Erros 429' no contrato"
        status: pass
    human_judgment: false
  - id: D3
    description: "400 e 429 da lista viram DioException e Result.failure; 429 do detalhe nao vira ImovelNaoEncontradoException (D-01, D-14, D-17)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "test/data/imovel_remote_datasource_test.dart#400 {campo: mensagem} da lista vira DioException e Result.failure sem codigo novo"
        status: pass
      - kind: unit
        ref: "test/data/imovel_remote_datasource_test.dart#429 da lista (limite de taxa) vira DioException e Result.failure sem codigo novo"
        status: pass
      - kind: unit
        ref: "test/data/imovel_detalhe_repository_impl_test.dart#429 (limite de taxa) vira o erro do dio, nunca ImovelNaoEncontradoException"
        status: pass
    human_judgment: false
  - id: D4
    description: "README da API documenta tetos, limite de taxa, variaveis e nota de deploy"
    requirement: API-07
    verification:
      - kind: other
        ref: "grep VITRINE_TAXA_ANONIMA / NUM_PROXIES / 429 / 9999999999.99 / 99999999.99 em ../imoveis-aqui/README.md"
        status: pass
    human_judgment: false
  - id: D5
    description: "Gates finais verdes nos dois repos; lib/ identico ao 425775c; API HEAD 0592176 sem push; app sem commit de codigo e sem push"
    requirement: API-03
    verification:
      - kind: integration
        ref: "manage.py test --noinput (353 OK) + makemigrations --check; flutter analyze; flutter test --timeout 60s (588 OK)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Check humano de fim de fase (emulador contra o Django semeado, roteiro de 7 passos do README do app)"
    verification: []
    human_judgment: true
    rationale: "Rede real, imagens, rolagem, latencia e aparencia so um emulador contra o Django prova; nao e gate deste plano (human_verify_mode = end-of-phase)"

duration: 20min
completed: 2026-11-16
status: complete
---

# Phase 5 Plan 22: Contrato sem drift — tetos, mensagens 400, 429 e gates finais Summary

**`01-CONTRATO-API.md` e o README da API passam a descrever cada teto, a tabela campo -> mensagem dos 400 e o 429 com `Retry-After` (120/min por IP, `VITRINE_TAXA_ANONIMA`, `NUM_PROXIES`), com cada mensagem conferida contra o `views.py`; 3 testes novos provam que o app já transforma 400/429 no estado de erro sem tocar em `lib/`; todos os gates dos dois repositórios ficam verdes.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-11-16
- **Tasks:** 2 (tracer + auto)
- **Files modified:** 4 (3 no repo do app, 1 no repo da API), todos só no working tree

## Accomplishments

- **Contrato §5:** `busca` (até 200 caracteres, NUL = 400), `quartos/suites/vagas` (inteiro ASCII 0..32767), `bairro` (até 20 itens de até 100 caracteres), `preco_*` (0..9999999999.99), `area_*` (0..99999999.99, teto da coluna, menor que o do preço), `caracteristicas` (até 20 ids distintos, subconsulta única); parágrafo de formato numérico (sem expoente/NaN/Infinity/sinal/espaço/sublinhado/dígito não ASCII; nada vira 500).
- **"Erros 400":** tabela campo -> mensagem exata com as 10 mensagens da view (`Informe um número válido.`, `O valor não pode ser negativo.`, `O valor passa do máximo permitido.`, `Opções válidas: ...`, `O texto tem um caractere inválido.`, `Use no máximo 200 caracteres.`, `Escolha no máximo 20 bairros.`, `Cada bairro tem no máximo 100 caracteres.`, `Informe os ids separados por vírgula.`, `Escolha no máximo 20 características.`), mantendo o exemplo da fixture e a frase do "Tentar de novo".
- **"Erros 429 (limite de taxa)":** 429, `Retry-After`, corpo `{detail}`, escopo `vitrine_publica` nas cinco rotas, 120/min por IP, `VITRINE_TAXA_ANONIMA`, `NUM_PROXIES` (padrão 0), API autenticada não limitada, comportamento do app (mesmo estado de erro, sem retry automático, detalhe nunca vira "não encontrado").
- **§8:** cinco riscos aceitos novos (área de 9 dígitos do app vs. teto 99999999.99; CGNAT/proxy sem `NUM_PROXIES`; `LocMemCache` por processo; app sem limite de busca/bairros/características; `corretores/<id>/` e `empresas/<id>/` sem limite, fora do escopo). **§12:** frase dizendo que `VitrineBuscaTests`, `VitrineLimiteDeTaxaTests` e os testes de 400/429 do app travam a superfície de erro.
- **Testes do app (só `test/`):** 400 e 429 da lista (`ApiFalsa` + fixtures `erro_400_natureza.json` / `erro_404_detalhe.json`) lançam `DioException` no datasource e viram `Failure` com a mesma `DioException` no `ImovelRepositoryImpl`; 429 do detalhe vira `Failure` com o erro do dio e não é `ImovelNaoEncontradoException`.
- **README da API:** frase das variáveis opcionais em "### 3. Variáveis de ambiente"; tetos/formatos em cada parâmetro da busca; linha "400 `{campo: mensagem}`, nunca 500 (inclusive NUL)"; bullet "Limite de taxa" com a nota de deploy (`NUM_PROXIES` atrás de proxy, cache compartilhado com vários workers).

## Task Commits

**Nenhum commit de código foi feito, por decisão do usuário, em nenhum dos dois repositórios.**

1. **Task 1: Tracer — contrato + testes 400/429 do app** — sem commit. Os 3 testes passam de primeira (são de caracterização: o app já tratava o erro; um teste vermelho aqui teria sido o sinal de um bug em `lib/`, que não aconteceu). Gate do tracer (auto mode): `<verify>` reexecutado de ponta a ponta antes da Task 2 — verde.
2. **Task 2: README da API + gates finais** — sem commit (API: opcao-a, HEAD segue `0592176`; nada enviado por push).

**Plan metadata:** commit `docs(05-22)` neste repo, somente `.planning/` (SUMMARY, STATE, ROADMAP e, se marcado, REQUIREMENTS). O contrato `01-CONTRATO-API.md` e os dois testes **não** entram nesse commit.

## Files Created/Modified

Repo do app (`/Users/georgelucas/Documents/projeto-mobile/imovies-aqui-mobile`) — **não commitados, aguardando OK do usuário**:
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — §5, "Erros 400", "Erros 429", §8, §12.
- `test/data/imovel_remote_datasource_test.dart` — 2 testes (400 e 429 da lista), imports de `dio`, `Result`, `ImovelRepositoryImpl`, `PaginaImoveis`.
- `test/data/imovel_detalhe_repository_impl_test.dart` — 1 teste (429 do detalhe).

Repo da API (`/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui`, feat/APP05, HEAD `0592176`) — **não commitado (opcao-a)**:
- `README.md` — mesmo arquivo que já tinha edições não commitadas de planos anteriores; as do 05-22 são as seções acima.

## Decisions Made

- Sem `dart format` nos arquivos de teste existentes: o formatter local reescreveu código antigo (estilo diferente do repo); os testes novos foram escritos à mão no estilo do arquivo, o diff ficou só de adições (+102 linhas).
- A tabela de 400 usa "`Opções válidas: ...`" para `natureza`/`finalidade`/`ordenar` (a lista de valores vem do servidor), com o exemplo exato da fixture mantido acima.

## Deviations from Plan

None - plan executed exactly as written.

(Fora do plano, apenas procedimento: um primeiro `dart format` nos dois testes reescreveu código antigo; os dois arquivos foram restaurados com `git checkout -- <arquivo>` e as adições reaplicadas sem o formatter. Sem efeito no resultado.)

## Issues Encountered

None.

## Gates finais

| Gate | Resultado |
|------|-----------|
| Django `manage.py test --noinput` (SQLite em memória) | 353 OK (baseline 353; nenhum teste Django novo neste plano) |
| `makemigrations --check --dry-run` | No changes detected |
| `flutter analyze` | No issues found |
| `flutter test --timeout 60s` | 588 OK (585 + 3 novos) |
| `contrato_lista_test` / `contrato_detalhe_test` | verdes, sem edição |
| `git diff --quiet 425775c -- lib` | sai 0 (lib/ intocado) |
| `git status -- contrato/ test/fixtures` | vazio (exemplos e fixtures intocados) |
| API: HEAD `0592176`, nenhum remoto o contém | OK |
| App: `git log 5f8dc69..HEAD -- lib test <contrato>` vazio; nenhum remoto contém o HEAD | OK |

Estado final do working tree:
- API (`git -C ../imoveis-aqui status --short`): `M README.md`, `M Web/.env.example`, `M Web/config/settings.py`, `M Web/empresas/tests.py`, `M Web/imoveis/api/serializers.py`, `M Web/imoveis/api/urls_publico.py`, `M Web/imoveis/api/views.py`, `M Web/imoveis/tests.py`, `M Web/imoveis/vitrine.py`, `M Web/localizacao/api/views.py`, `?? Web/core/throttles.py`, `?? Web/empresas/management/`.
- App (`git status --short`, antes do commit docs): `M .planning/phases/01-.../01-CONTRATO-API.md`, `M test/data/imovel_detalhe_repository_impl_test.dart`, `M test/data/imovel_remote_datasource_test.dart`, mais `M .gsd/dispatch-isolation-sentinel.json` e `M .planning/state.json` (artefatos do GSD, não commitados).

## Decisão pendente do usuário

Pode commitar no repo do app os 3 arquivos acima (contrato + 2 testes)? O 05-22 não está na política app-a (só 05-03 e 05-06..05-18). **Pendente.** Pode commitar o repo da API (opcao-a)? **Pendente**, como nos planos 05-19..05-21. Nenhum push em nenhum dos repos.

## Known Stubs

None.

## Threat Flags

None. O plano só documenta superfície existente e adiciona testes.

## User Setup Required

None - nenhuma configuração externa. Itens de deploy registrados no contrato e no README: `NUM_PROXIES` atrás de proxy reverso e cache compartilhado em produção.

## Next Phase Readiness

- Os quatro achados da re-verificação (CR-01, CR-02, WR-01, WR-02) estão corrigidos, documentados e travados por testes nos dois lados. Próximo passo: `/gsd-verify-work` (re-verificação dos gaps).
- **Check humano de fim de fase segue pendente para o UAT** (human_verify_mode = end-of-phase; não é gate deste plano): subir o Django com o banco de dev semeado e percorrer o roteiro de 7 passos do README do app no emulador (`Medium_Phone_API_36.0`) ou simulador iOS; opcionalmente os três `curl` (`busca=a%00b`, `preco_min=NaN`, `area_min=100000000`) devem imprimir 400 no Postgres. Nenhum 429 deve aparecer na navegação normal.
- Adiados conscientemente pelo usuário: WR-03..WR-06 e IN-01..IN-09 do 05-REVIEW.

## Self-Check: PASSED

- Arquivos: contrato, 2 testes e `../imoveis-aqui/README.md` existem e estão modificados no working tree.
- Contrato: todos os `grep -qF` de mensagens, tetos, `Retry-After`, `VITRINE_TAXA_ANONIMA`, `NUM_PROXIES`, `Erros 429` e do teto de área (`99999999.99` isolado) passam; cada mensagem e constante `MAXIMO_*` existe no `views.py`.
- Gates da tabela acima executados; nenhum commit de código (`commits: 0`).

---
*Phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final*
*Completed: 2026-11-16*
