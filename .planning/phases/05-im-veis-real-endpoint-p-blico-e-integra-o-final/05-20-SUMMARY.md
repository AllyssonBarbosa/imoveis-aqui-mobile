---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 20
subsystem: api
tags: [django, drf, dos, orm-subquery, m2m, input-hardening]
gap_closure: true

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-19: helpers de entrada com allowlist ASCII por fullmatch e suíte de 341 testes"
provides:
  - "_ids_de_caracteristicas: ids de característica só inteiro ASCII positivo, repetidos contam uma vez, teto MAXIMO_CARACTERISTICAS = 20"
  - "Filtro 'tem todas' por uma única subconsulta agregada na tabela M2M (GROUP BY imovel_id HAVING COUNT DISTINCT = n), sem JOIN por id"
  - "6 testes novos em VitrineBuscaTests (incluindo trava do formato do SQL)"
affects: [05-21, 05-22]

plan_head_before: 0592176
actuals:
  tokens: 2100
  tasks: 2
  commits: 0

tech-stack:
  added: []
  patterns:
    - "Filtro 'tem todas' em M2M = pk__in de subconsulta values(fk).annotate(Count distinct).filter(total=n).values(fk), nunca filter() encadeado por id"
    - "Teste de forma do SQL com CaptureQueriesContext comparando ocorrências da tabela por consulta"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py

key-decisions:
  - "Teto de 20 ids distintos (MAXIMO_CARACTERISTICAS), constante local reversível; risco aceito no app (marcar 21+ vira o estado de erro com 'Tentar de novo'), a registrar no contrato pelo 05-22"
  - "Regra de negócio inalterada ('tem todas', D-13/D-14); só a forma da consulta muda"

patterns-established:
  - "Mesmo padrão de allowlist [0-9]+ com fullmatch do 05-19 para ids; int() nunca valida sozinho"

requirements-completed: [API-03]

coverage:
  - id: D1
    description: "caracteristicas com 21+ ids distintos responde 400 'Escolha no máximo 20 características.' antes de consultar os imóveis; 20 ids responde 200 (CR-01, gap 2)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_caracteristicas_demais_da_400"
        status: pass
    human_judgment: false
  - id: D2
    description: "ids 0, -1, 1_0, dígito não ASCII, 1.0, abc, item inválido no meio ou NUL respondem 400 'Informe os ids separados por vírgula.'; repetidos e vazios são ignorados"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_id_de_caracteristica_fora_do_formato_da_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_ids_repetidos_e_vazios_sao_ignorados"
        status: pass
    human_judgment: false
  - id: D3
    description: "'Tem todas' preservado: A,B só com as duas; A com todos que têm A; id inexistente junto de existente deixa a lista vazia com count 0; paginação sem linha duplicada"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_filtro_caracteristicas_exige_todas (sem edição)"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_caracteristica_inexistente_junto_de_existente_nao_traz_nada"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_paginacao_com_filtro_de_caracteristicas_nao_duplica_linha"
        status: pass
    human_judgment: false
  - id: D4
    description: "O SQL do filtro não cresce com a quantidade de ids: a tabela M2M aparece uma vez por consulta com 2 e com 20 ids e nenhuma consulta faz JOIN dela"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineBuscaTests.test_filtro_caracteristicas_usa_uma_so_subconsulta_qualquer_que_seja_a_quantidade"
        status: pass
    human_judgment: false

duration: 10min
completed: 2026-11-16
status: complete
---

# Phase 5 Plan 20: Teto e subconsulta única no filtro de características (CR-01) Summary

**`?caracteristicas=` passa a aceitar só ids inteiros ASCII positivos, no máximo 20 distintos (400 antes de consultar), e o "tem todas" vira uma única subconsulta agregada na tabela M2M (GROUP BY imóvel HAVING COUNT DISTINCT = n) em vez de um JOIN por id.**

## Performance

- **Duration:** ~10 min
- **Completed:** 2026-11-16
- **Tasks:** 2 (tracer + auto, ambas TDD)
- **Files modified:** 2 (ambos no repo da API, sem commit)

## Accomplishments

- **CR-01 fechado.** Antes, cada id somava um `.filter()` encadeado sobre o M2M (um JOIN por id) e não havia teto: uma requisição anônima com milhares de ids travou o Postgres por mais de 2 minutos no review. Agora `_ids_de_caracteristicas` recusa mais de 20 ids distintos com `{"caracteristicas": "Escolha no máximo 20 características."}` antes de qualquer consulta aos imóveis (o teste captura as queries e prova isso), e o filtro é um único `pk__in` sobre `Imovel.caracteristicas.through` com `values("imovel_id").annotate(total=Count("caracteristica_id", distinct=True)).filter(total=len(ids)).values("imovel_id")`.
- **Formato dos ids.** `[0-9]+` com `fullmatch` mais valor positivo: `0`, `-1`, `1_0`, `٣`, `1.0`, `abc`, item inválido no meio da lista e NUL dão 400 `"Informe os ids separados por vírgula."` (mensagem que já existia). Repetidos contam uma vez; itens vazios (`,1,,`) são ignorados.
- **"Tem todas" intacto (D-13, F3/D-04).** `test_filtro_caracteristicas_exige_todas` passa sem nenhuma edição; id que ninguém tem junto de um existente deixa a lista vazia (`count == 0`); paginação com page_size 1 traz `count == 2` e páginas diferentes.
- **Trava de regressão do SQL.** O teste com `CaptureQueriesContext` compara, por consulta, quantas vezes ela cita a tabela M2M com 2 e com 20 ids (conjuntos iguais, valor 1) e afirma ausência de `JOIN "<tabela>"`.
- Suíte Django inteira: **347 testes OK** (341 do fim do 05-19 + 6 novos). `makemigrations --check --dry-run`: "No changes detected".

## Task Commits

**Nenhum commit de código foi feito, por decisão do usuário (opcao-a do 05-01-SUMMARY.md; o CLAUDE.md do repo da API também proíbe commit sem autorização).** As mudanças de `views.py` e `tests.py` ficam no working tree da `feat/APP05` do repo da API, cujo HEAD continua `0592176`; nada foi enviado por push.

1. **Task 1: Tracer — 21 ids ou id fora do formato viram 400 (CR-01, D-13)** — sem commit. RED: 6 falhas (`demais_da_400`, 4 subTests de formato, teste de SQL) nos 6 testes escritos antes da implementação; GREEN: `_FORMATO_ID`, `MAXIMO_CARACTERISTICAS = 20`, `_ids_de_caracteristicas`; `VitrineBuscaTests` verde exceto o teste de SQL (da Task 2).
2. **Task 2: Uma subconsulta agregada no lugar dos JOINs (CR-01, D-13)** — sem commit. `Count` importado; laço de `.filter(caracteristicas=id)` trocado pela subconsulta. GREEN: `VitrineBuscaTests` + `VitrineMultiSelecaoTests` + `VitrineOpcoesTests` = 50 testes OK; suíte inteira 347 OK.

**Plan metadata:** commit `docs(05-20)` no repo do app (somente `.planning/`).

## Files Created/Modified

- `../imoveis-aqui/Web/imoveis/api/views.py` — `_FORMATO_ID`, `MAXIMO_CARACTERISTICAS = 20`, `_ids_de_caracteristicas(params)`, import de `Count`; `get_queryset` usa o helper e a subconsulta agregada (o `try/except ValueError` e o laço de filtros saíram).
- `../imoveis-aqui/Web/imoveis/tests.py` — imports de `connection` e `CaptureQueriesContext`; em `VitrineBuscaTests`: helper `_ids_inexistentes` e 6 testes (`test_caracteristicas_demais_da_400`, `test_id_de_caracteristica_fora_do_formato_da_400`, `test_ids_repetidos_e_vazios_sao_ignorados`, `test_caracteristica_inexistente_junto_de_existente_nao_traz_nada`, `test_filtro_caracteristicas_usa_uma_so_subconsulta_qualquer_que_seja_a_quantidade`, `test_paginacao_com_filtro_de_caracteristicas_nao_duplica_linha`).

## Decisions Made

- A ordem `values/annotate/filter/values` do plano funcionou de primeira no Django do projeto (nenhum ajuste de `pk__in` com mais de uma coluna foi necessário).
- O teto de 20 e a regra "tem todas" ficam como constante local reversível. Risco aceito, a registrar no contrato pelo 05-22 (lib/ não muda, D-01): com catálogo maior que 20, marcar 21+ características vira o estado de erro com "Tentar de novo".
- A mensagem nova a listar no contrato pelo 05-22: "Escolha no máximo 20 características."

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Teste de formato do SQL comparava o total da requisição, não a forma de cada consulta**
- **Found during:** Task 2 (primeiro GREEN)
- **Issue:** o teste somava as ocorrências da tabela M2M em todas as consultas capturadas. Com 20 ids a lista é vazia, o DRF não roda a consulta de listagem (só o count), então o total era 1 contra 2 com 2 ids, apesar de o SQL estar correto.
- **Fix:** o teste passou a comparar o conjunto de ocorrências por consulta (`{1}` nos dois casos) e a afirmar ausência de `JOIN "<tabela>"`; a exigência do plano (mesma contagem com 2 e 20 ids, sem JOIN) fica provada de forma independente de a lista rodar.
- **Files modified:** `../imoveis-aqui/Web/imoveis/tests.py`
- **Verification:** teste verde; falhava (RED) com o laço antigo de JOINs.
- **Committed in:** sem commit (opcao-a)

### Additions

- Teste extra `test_paginacao_com_filtro_de_caracteristicas_nao_duplica_linha` (page_size 1, `count == 2`, páginas diferentes), exigido pelo bloco `<behavior>` da Task 2 mas não listado nos artefatos do plano.
- O teste de 21 ids também prova, por captura de queries, que nenhuma consulta a `imoveis_imovel` roda antes do 400.

---

**Total deviations:** 1 auto-fixed (Rule 1, só em teste)
**Impact on plan:** nenhum no escopo nem no código de produção.

## Issues Encountered

Um `sed -i` com `\n` falhou no sed do macOS (BSD) ao editar os imports de `tests.py`; refeito com o Edit. Nenhum efeito no código.

## Known Stubs

None.

## Threat Flags

None. Nenhuma superfície nova: o plano só reduz a existente (T-05-20-01..03 mitigados por teste).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-21 (limite de taxa do WR-02) e 05-22 (contrato §5/§8 e gates finais) seguem. O 05-22 deve registrar a mensagem "Escolha no máximo 20 características." e o risco aceito do teto de 20.
- Pendência do usuário: as mudanças deste plano (e as anteriores da opcao-a) continuam só no working tree de `../imoveis-aqui` (feat/APP05, HEAD 0592176); o commit no repo da API fica para o usuário decidir.

## Self-Check: PASSED

- `views.py`: `MAXIMO_CARACTERISTICAS = 20`, `def _ids_de_caracteristicas`, `Escolha no máximo {MAXIMO_CARACTERISTICAS} características.`, `caracteristicas.through` e `Count("caracteristica_id", distinct=True)` presentes (grep).
- Suíte inteira: 347 testes OK; `makemigrations --check`: sem mudanças; HEAD da API ainda `0592176`.

---
*Phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final*
*Completed: 2026-11-16*
