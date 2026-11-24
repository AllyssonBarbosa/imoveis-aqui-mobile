---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 06
subsystem: data
tags: [dio, datasource, repository, usecases, caixa-contatos, apifalsa, injectable]

requires:
  - phase: 10-05
    provides: "Models da caixa (ContatoRecebidoModel, ContatosEnvelopeModel, ResumoContatosModel, ImovelComContatoModel)"
  - phase: 10-04
    provides: "CaixaContatosRepository, ContatoNaoEncontradoException, ConsultaContatos, PeriodoContatos, RetornoContato"
provides:
  - "parametrosDaConsultaContatos (imovel, de, ate; sem UTC)"
  - "CaixaContatosDataSource + CaixaContatosRemoteDataSource no Dio @Named('autenticado') (buscar, seguir, contarSemRetorno, listarImoveis, anotarRetorno)"
  - "CaixaContatosRepositoryImpl com _executar unico (401/403/404 so no PATCH/generica; nada lanca)"
  - "BuscarContatosUseCase, ObterSemRetornoUseCase, ListarImoveisDosContatosUseCase, AnotarRetornoUseCase (@injectable)"
  - "Rotas da caixa na ApiFalsa (4 rotas, token, resumo cai apos PATCH aceito, ultimaRequisicaoDaCaixa)"
affects: [10-07, 10-08, 10-09, 10-10]

commits: 4
plan_head_before: a064eb4d16bc1e3232cca59d8961cde8983e3a42
plan_head_after: 226f57429c692daf06d4293d6f184329c78e98bf

estimate_actuals_note: "tokens = chars/4 sobre o diff do app a064eb4..226f574 fora de .planning (52751 chars, inclui os testes)"
actuals:
  tokens: 13188
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "DataSource fino no Dio autenticado: nao captura DioException, nao loga, next so de mesma origem"
    - "Repositorio com _executar<M, T> generico e flag notFoundEhContato (404 tipado so no PATCH)"
    - "ApiFalsa com estado privado (_retornoAnotado) para o resumo cair depois de um PATCH aceito"

key-files:
  created:
    - lib/data/datasources/parametros_consulta_contatos.dart
    - lib/data/datasources/caixa_contatos_datasource.dart
    - lib/data/datasources/caixa_contatos_remote_datasource.dart
    - lib/data/repositories/caixa_contatos_repository_impl.dart
    - lib/domain/usecases/buscar_contatos_usecase.dart
    - lib/domain/usecases/obter_sem_retorno_usecase.dart
    - lib/domain/usecases/listar_imoveis_dos_contatos_usecase.dart
    - lib/domain/usecases/anotar_retorno_usecase.dart
    - test/data/parametros_consulta_contatos_test.dart
    - test/data/caixa_contatos_remote_datasource_test.dart
    - test/data/caixa_contatos_repository_impl_test.dart
    - test/domain/caixa_contatos_usecases_test.dart
  modified:
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart

key-decisions:
  - "O mapeamento do Model (paraPagina/paraEntidade) roda dentro do try do _executar: wire malformado (canal/retorno desconhecido, TypeError) vira Failure em vez de escapar (T-10-17)"
  - "404 vira ContatoNaoEncontradoException so no anotarRetorno (flag notFoundEhContato); nos demais metodos continua DioException generica"
  - "Em lista de imoveis, o corpo e validado elemento a elemento (List de Map) antes do fromJson; formato errado lanca FormatException no DataSource"

requirements-completed: []

coverage:
  - id: D1
    description: "Consulta da caixa vira imovel/de/ate sem UTC e chega ao servidor pelo Dio autenticado, com paginacao so de mesma origem"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/data/parametros_consulta_contatos_test.dart"
        status: pass
      - kind: test
        ref: "test/data/caixa_contatos_remote_datasource_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Resumo (sem retorno) e opcoes de imovel lidos das rotas da caixa; resumo cai pelo servidor apos PATCH aceito"
    requirement: "CXA-05"
    verification:
      - kind: test
        ref: "test/data/caixa_contatos_remote_datasource_test.dart#contarSemRetorno"
        status: pass
    human_judgment: false
  - id: D3
    description: "PATCH do retorno em /api/contatos/<id>/ (barra final, corpo {retorno}) e falhas tipadas 401/403/404/generica em todos os metodos"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/data/caixa_contatos_repository_impl_test.dart"
        status: pass
      - kind: test
        ref: "test/domain/caixa_contatos_usecases_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "401 vira SessaoExpiradaException tipada em cada um dos 5 metodos (o Cubit do 10-08 encerra a sessao)"
    requirement: "CXA-06"
    verification:
      - kind: test
        ref: "test/data/caixa_contatos_repository_impl_test.dart#pilha real sem token"
        status: pass
    human_judgment: false

duration: 30min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 06: Acesso a dados da caixa de contatos Summary

**Camada de dados completa da caixa: parametros imovel/de/ate sem UTC, `CaixaContatosRemoteDataSource` no Dio autenticado (next so de mesma origem, PATCH com barra final), `CaixaContatosRepositoryImpl` com cadeia unica que traduz 401/403/404-do-PATCH/generica sem nunca lancar, 4 use cases injetaveis e as 4 rotas da caixa na `ApiFalsa` com o wire real.**

## Performance

- **Duration:** ~30 min
- **Tasks:** 2 (TDD: RED e GREEN commitados separados em cada uma)
- **Files:** 14 (12 criados, 2 modificados)

## Accomplishments

- `parametrosDaConsultaContatos` formata `de`/`ate` com `DateFormat('yyyy-MM-dd')` no `DateTime` local, sem `toUtc` (converter deslocaria o dia; o servidor le como dia de Sao Paulo).
- `CaixaContatosRemoteDataSource` usa so o `@Named('autenticado')`, confere `mesmaOrigem` antes de seguir o `next` (outra origem: `FormatException` sem requisicao) e faz o PATCH em `'/api/contatos/$id/'`.
- `ApiFalsa` serve `GET /api/contatos/`, `/resumo/`, `/imoveis/` e `PATCH /api/contatos/<id>/` com token obrigatorio (senao 401), 400/200/404 conforme o corpo e o id, resumo `_apos` depois do PATCH aceito e getter `ultimaRequisicaoDaCaixa`; o comentario de cabecalho cita as rotas e o aviso de `falharProximas` casar por prefixo.
- `CaixaContatosRepositoryImpl._executar<M, T>`: sessao direta ou em `DioException.error` -> `SessaoExpiradaException`; 403 -> `SemPermissaoException`; 404 so no `anotarRetorno` -> `ContatoNaoEncontradoException`; resto -> `Failure`. Testado por metodo (5 x 9 casos) e contra a pilha real sem token.
- Os 4 use cases sao repasses puros (`@injectable`); `lib/di/injection.config.dart` registra tudo.

## Task Commits

1. **Task 1 (RED)** - `bae39aa` (test)
2. **Task 1 (GREEN)** - `35dd5f1` (feat)
3. **Task 2 (RED)** - `fc3e5c5` (test)
4. **Task 2 (GREEN)** - `226f574` (feat)

**Plan metadata:** commit `docs(10-06)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test` dos 4 arquivos novos + `acervo_remote_datasource_test.dart`: verdes.
- Gate da onda 6 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 errors/warnings, 0 infos fora das 41 `deprecated_member_use` de `material.dart`; `flutter analyze --no-fatal-infos lib test` sai 0 (71 infos, nenhuma nos arquivos deste plano); `flutter test` inteiro: **1354 verdes** (1279 + 75 novos).
- Greps dos `<automated>`: classe do datasource, `@Named('autenticado')`, `mesmaOrigem(`, caminho do PATCH com barra final, rota `/api/contatos/resumo/` na ApiFalsa, registros no `injection.config.dart`, sem interceptor de log em `lib`, sem `toUtc`.

## Deviations from Plan

None - plan executed exactly as written.

Detalhe de execucao: `dart run build_runner build -d` reescreveu com LF todos os gerados pre-existentes; foram restaurados com `git checkout --` (D-29) e o `lib/di/injection.config.dart` (unico gerado legitimamente alterado) teve o CRLF restaurado antes do commit. Nenhum `.freezed.dart`/`.g.dart` ficou sujo; nenhum arquivo foi deletado pelos commits.

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None - T-10-13 (next de outra origem, teste sem requisicao gravada), T-10-14 (so o Dio autenticado, cabecalho `Authorization` conferido, sem interceptor de log), T-10-15 (caminho fixo com barra final, `followRedirects: false`), T-10-16 (`SessaoExpiradaException` testada por metodo), T-10-17 (toda excecao vira `Failure`, inclusive `TypeError`) e T-10-SC (nenhum pacote novo) mitigados.

## Next Phase Readiness

Pronto para o 10-07 em diante: o Cubit da caixa so chama os 4 use cases e decide pelo tipo do `Result`. Nenhum `git push`.

## Self-Check: PASSED

- Os 14 arquivos existem; commits `bae39aa`, `35dd5f1`, `fc3e5c5` e `226f574` presentes na `feat/APP10`; `git rev-list --count a064eb4..HEAD` = 4.
