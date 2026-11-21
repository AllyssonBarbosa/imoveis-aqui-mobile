---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 01
subsystem: api
tags: [django, drf, pagination, token-auth, multitenant, acervo]

requires:
  - phase: 07
    provides: "POST /api/auth/login/ (token) e ImovelViewSet com EmpresaScopedQuerySetMixin no repo web"
provides:
  - "GET /api/imoveis/ do corretor: envelope {count,next,previous,results}, 20 por pagina, next absoluto"
  - "Item enxuto de 10 chaves (id, codigo, titulo, finalidade, preco_venda, preco_aluguel, foto_capa, situacao, meu_imovel, na_vitrine)"
  - "Busca (codigo OU titulo) e filtro por situacao via FiltroImovelForm, filtro invalido ignorado"
  - "Isolamento por empresa provado por testes (AC-5) e allowlist exata do item"
affects: [08-04 contrato §14, 08-05 app acervo, 08-02 auth app]

actuals:
  tokens: 4700
  tasks: 2
  commits: 2
plan_head_before: d9ddd8f0e69ee752c47e19cd36f4141944e963b5
plan_head_after: ed251b1c72e0b64fc9bc9dcf741599e25a25d2f8

tech-stack:
  added: []
  patterns:
    - "FotoCapaMixin compartilhado entre ImovelVitrineSerializer e ImovelAcervoSerializer"
    - "booleanos calculados no servidor: meu_imovel por corretor_responsavel_id (zero consultas) e na_vitrine por Exists(na_vitrine())"
    - "ordem de camadas no get_queryset: empresa (mixin) -> FiltroImovelForm -> anotacao -> order_by(-criado_em, -pk)"

key-files:
  created: []
  modified:
    - "C:/projetos/imoveis-aqui/Web/imoveis/api/views.py"
    - "C:/projetos/imoveis-aqui/Web/imoveis/api/serializers.py"
    - "C:/projetos/imoveis-aqui/Web/imoveis/tests.py"
    - "C:/projetos/imoveis-aqui/README.md"

key-decisions:
  - "Rota do acervo = ImovelViewSet.list adaptado (sem rota nova): so o app consome a lista (evidencia da pesquisa)"
  - "Emenda ao D-13: item leva tambem finalidade (10 chaves, nao 9), para o app reaproveitar linhasDePreco"
  - "Ordem fixa -criado_em, -pk (desempate estavel para paginar)"
  - "Filtro invalido (ex.: situacao=XXX) devolve a lista sem NENHUM filtro, como o painel do site; forms.py nao foi tocado"

patterns-established:
  - "Lista do acervo so mexe em action == list; retrieve/create/update/@action seguem com ImovelSerializer completo e sem paginacao"

requirements-completed: [API-10, ACV-01, ACV-02, ACV-03, ACV-04]

coverage:
  - id: D1
    description: "Acervo autenticado ponta a ponta: login real -> Authorization Token -> GET /api/imoveis/ paginado (20/pagina, next absoluto) com 10 chaves por item"
    requirement: "API-10"
    verification:
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_ponta_a_ponta_com_token_real_devolve_o_envelope_paginado"
        status: pass
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_pagina_de_20_com_next_absoluto"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoAllowlistExataTests.test_todo_item_da_lista_tem_as_chaves_exatas_e_nenhuma_proibida"
        status: pass
    human_judgment: false
  - id: D2
    description: "meu_imovel e na_vitrine calculados no Django (regra unica na_vitrine(), empresa ativa) e foto_capa absoluta"
    requirement: "ACV-01"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_meu_imovel_so_para_o_corretor_responsavel_e_os_dois_aparecem"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_na_vitrine_segue_a_regra_unica_publicado_disponivel_empresa_ativa"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_foto_capa_e_url_absoluta_da_capa_marcada_senao_a_primeira_senao_nula"
        status: pass
    human_judgment: false
  - id: D3
    description: "Busca por codigo ou titulo e filtro por situacao pelo FiltroImovelForm do site; filtro invalido ignorado sem erro"
    requirement: "ACV-02"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_busca_e_situacao_combinadas"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_situacao_invalida_nao_vira_erro_e_devolve_a_lista_sem_filtro"
        status: pass
    human_judgment: false
  - id: D4
    description: "Isolamento multitenant e perfis: nada de outra empresa (nem com busca/situacao/?empresa=/?corretor=), 404 pelo id, 403 gestor/admin, 401 sem token"
    requirement: "ACV-03"
    verification:
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_isolamento_busca_situacao_e_parametros_forcados_nao_trazem_imovel_de_fora"
        status: pass
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_detalhe_de_imovel_de_outra_empresa_da_404"
        status: pass
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_gestor_recebe_403_na_lista"
        status: pass
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_administrador_recebe_403_na_lista"
        status: pass
      - kind: integration
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_sem_credencial_recebe_401_na_lista"
        status: pass
    human_judgment: false
  - id: D5
    description: "Custo fixo por pagina (sem N+1) e ordem estavel; suite Django inteira verde"
    requirement: "ACV-04"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#AcervoApiTests.test_numero_de_consultas_da_pagina_nao_cresce_com_o_numero_de_imoveis"
        status: pass
      - kind: other
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput (719 testes, OK)"
        status: pass
    human_judgment: false

duration: 5min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 01: Acervo do corretor na API (web) Summary

**GET /api/imoveis/ virou o acervo do corretor no Django: envelope paginado (20 por pagina, next absoluto), item enxuto de 10 chaves com meu_imovel e na_vitrine calculados no servidor, busca/situacao pelo FiltroImovelForm do site e isolamento por empresa provado por 24 testes novos.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-11-21T12:52:39Z
- **Completed:** 2026-11-21T12:57:30Z
- **Tasks:** 2 (1 tracer + 1 tdd)
- **Files modified:** 4 (todos no repo web)

## Accomplishments

- Tracer ponta a ponta com token real: `POST api-login` -> `Authorization: Token` -> `GET imovel-list` devolve `{count,next,previous,results}`, 20 por pagina, `next` absoluto em `http://testserver/`.
- `ImovelAcervoSerializer` com exatamente 10 chaves; `meu_imovel` por `corretor_responsavel_id == request.user.pk` (zero consultas) e `na_vitrine` por `Exists(Imovel.objects.na_vitrine().filter(pk=OuterRef("pk")))` (regra unica: publicado + DISPONIVEL + empresa ativa); `FotoCapaMixin` extraido e compartilhado com a vitrine publica sem mudar o comportamento dela.
- `?busca=` (codigo OU titulo) e `?situacao=` combinados pela mesma `FiltroImovelForm(campos=["busca", "situacao"])` do painel do site; situacao invalida responde 200 com a lista sem filtro, nunca 400.
- Isolamento: com `?busca=FORA`, `?situacao=`, `?empresa=` e `?corretor=` nada da empresa B aparece; detalhe da B da 404; gestor e administrador 403; sem credencial 401.
- Numero de consultas da primeira pagina igual com 3 e com 25 imoveis (com fotos); ordem `-criado_em, -pk`.
- `retrieve`/`create`/`update` e as `@action` seguem com `ImovelSerializer` completo e sem paginacao.

## Task Commits

Commits no repo WEB (`C:/projetos/imoveis-aqui`), branch local `feat/APP08` (criada de `main@d9ddd8f`), sem push:

1. **Task 1: TRACER - acervo autenticado ponta a ponta** - `fe911fe` (feat)
2. **Task 2: Busca + situacao, isolamento, allowlist, consultas fixas e README** - `ed251b1` (feat)

**Plan metadata:** commit `docs(08-01)` no repo do app (SUMMARY + STATE/ROADMAP/REQUIREMENTS).

TDD: o RED foi visto nas duas tarefas antes da implementacao. Task 1: 10 erros (lista ainda e um array puro: `TypeError` ao ler `response.data["results"]`/`set(response.data)`). Task 2: 5 falhas (`test_busca_por_codigo`, `test_busca_por_titulo`, `test_filtro_por_situacao`, `test_busca_e_situacao_combinadas`, `test_busca_pagina_so_o_que_casou`); os testes de isolamento, perfis e consultas ja passavam porque o mixin da empresa e a permissao `EhCorretor` ja existiam (eram a regressao a travar). Task 1 e Task 2 foram um unico commit cada (RED + GREEN juntos), conforme o plano.

## Files Created/Modified

- `Web/imoveis/api/views.py` (web) - `PaginacaoAcervo`; `ImovelViewSet.pagination_class`, `get_serializer_class` e `get_queryset` (empresa -> FiltroImovelForm -> anotacao `na_vitrine` -> ordem); imports `Exists`, `OuterRef`, `FiltroImovelForm`, `ImovelAcervoSerializer`.
- `Web/imoveis/api/serializers.py` (web) - `FotoCapaMixin` e `ImovelAcervoSerializer`; `ImovelVitrineSerializer` herda do mixin.
- `Web/imoveis/tests.py` (web) - `AcervoApiTests` (23 testes) e `AcervoAllowlistExataTests` (1 teste), 24 novos no total; `ImovelApiTests.test_lista_apenas_da_propria_empresa` le `response.data["results"]`.
- `README.md` (web) - linhas `GET /api/imoveis/?busca=&situacao=&page=` e `POST /api/imoveis/`.

## Decisions Made

- Adaptar `ImovelViewSet.list` em vez de rota nova (so o app consome a lista); plano B barato registrado: `@action(detail=False, url_path="acervo")`.
- Emenda ao D-13: `finalidade` no item (10 chaves) - o §14 do 08-04 deve registrar.
- Nao tocar `Web/imoveis/forms.py`: o comportamento "campo invalido anula todos os filtros" e do site e fica documentado no §14 (T-08-06, accept).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Caminho do repo web desatualizado no PLAN**
- **Found during:** inicio da execucao (orientacao do orquestrador, confirmada)
- **Issue:** o PLAN cita `C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`, que nao existe.
- **Fix:** todo o trabalho foi feito em `C:/projetos/imoveis-aqui` (Django em `Web/`), `main@d9ddd8f` limpa, `feat/APP08` criada localmente. `git pull --ff-only origin main` retornou "Already up to date".
- **Files modified:** nenhum (so o caminho de trabalho; `key-files` deste SUMMARY ja usa o caminho real)
- **Commit:** n/a

**2. [Rule 3 - Blocking] Sem identidade git configurada**
- **Found during:** primeiro commit na web
- **Issue:** `git commit` falhou com "Author identity unknown" (nem global nem por repo; nenhuma variavel `GIT_*` de identidade no ambiente).
- **Fix:** os dois commits da web foram feitos com `-c user.name="Claude (GSD executor)" -c user.email="noreply@anthropic.com"` por comando, sem alterar nenhuma configuracao do git e sem usar a identidade pessoal do usuario. Os commits tem o trailer `Co-Authored-By`.
- **Verification:** `git log` mostra os dois commits; se o usuario preferir a identidade dele, basta reescrever o autor antes de qualquer push (`git rebase -r d9ddd8f --exec 'git commit --amend --reset-author --no-edit'`, depois de configurar `user.name`/`user.email`).
- **Commit:** `fe911fe`, `ed251b1`

**3. [Rule 3 - Blocking] Terminadores de linha misturados (CRLF/LF) no working tree da web**
- **Found during:** Task 1 (edicao de `tests.py`)
- **Issue:** os arquivos estao em CRLF no working tree e LF no indice (`core.autocrlf=true`); o `sed -i` do Git Bash normalizou `tests.py` para LF no working tree.
- **Fix:** nenhum efeito no commit (o indice e LF; os diffs ficaram limpos, 369 insercoes/12 delecoes no total); `views.py`, `serializers.py` e `README.md` foram editados preservando CRLF.
- **Commit:** n/a

---

**Total deviations:** 3 auto-fixed (todas Rule 3 - ambiente/bloqueio, nenhuma altera o comportamento entregue)
**Impact on plan:** nenhum no escopo; (1) e a substituicao de caminho ja pedida pelo orquestrador.

## Issues Encountered

None alem das deviations acima. Nenhum pacote foi instalado; `Web/requirements.txt` e `Web/imoveis/forms.py` identicos aos de `d9ddd8f`; nenhum `origin/feat/APP08` (sem push, sem PR, sem merge).

## Verification Results

- `manage.py test imoveis.tests.AcervoApiTests imoveis.tests.AcervoAllowlistExataTests imoveis.tests.ImovelApiTests --noinput` -> 34 testes, OK.
- `manage.py test --noinput` (suite completa, SQLite em memoria) -> **719 testes, OK** (linha de base 695 + 24 novos).
- Criterios de aceite das duas tasks reexecutados (greps das classes/literais, branch `feat/APP08`, `d9ddd8f` ancestral, README, arvore limpa, 2 commits sobre `d9ddd8f`, sem `origin/feat/APP08`): todos PASS.
- Fim da onda 1 (D-18): `flutter analyze lib` e `flutter test` no app ficam para o orquestrador depois do 08-02 (este plano nao tocou o app).

## Known Stubs

None.

## Threat Flags

None - nenhuma superficie nova alem da mapeada no `<threat_model>` (T-08-01..05 e T-08-SC mitigados por testes; T-08-06 aceito e documentado).

## User Setup Required

None - no external service configuration required. (Os testes usam `DATABASE_URL="sqlite://:memory:"`; nenhum `.env` foi criado, lido ou alterado.)

## Next Phase Readiness

- Contrato do servidor pronto para o §14 (08-04): envelope, 10 chaves (com a emenda `finalidade`), ordem, tamanho de pagina fixo 20, filtro invalido ignorado (anula todos os filtros), `next` absoluto.
- Pendente (fora deste plano): push/PR da `feat/APP08` da web so com autorizacao explicita do usuario; avisar a frente web da mudanca de formato de `GET /api/imoveis/` (lista -> envelope) no PR e no §14.8.

## Self-Check: PASSED

- Commits `fe911fe` e `ed251b1` presentes em `feat/APP08` (ancestrais de HEAD; `git rev-list --count d9ddd8f..HEAD` = 2).
- Arquivos modificados existem: `Web/imoveis/api/views.py`, `Web/imoveis/api/serializers.py`, `Web/imoveis/tests.py`, `README.md` (repo web).

---
*Phase: 08-login-e-rea-do-corretor-o-acervo*
*Completed: 2026-11-21*
