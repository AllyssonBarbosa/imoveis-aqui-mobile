---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 06
subsystem: data
tags: [flutter, freezed, injectable, mock-datasource, cursor-pagination, contrato-12]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "contrato §12 (07-03), perfis_fixture com empresa_id (07-01/07-05), canario de DI (07-05)"
provides:
  - "AnuncianteRef (freezed sealed): corretor(id) | empresa(id)"
  - "parametrosDoAnunciante / anuncianteDosParametros simetricas + interface VitrineAnuncianteDataSource"
  - "VitrineAnuncianteMockDataSource: servidor simulado do §12 com cursor, derivado das fixtures"
  - "VitrineAnuncianteRepositoryImpl -> Result<PaginaImoveis> e BuscarImoveisDoAnuncianteUseCase"
affects: [07-08 pagina do corretor, 07-12 pagina da empresa, Phase 5 endpoint real]

actuals:
  tokens: 22000
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "DataSource trocavel mock->real com parametros simetricos (ida e volta) e validacao sincrona antes do await"
    - "Vinculo imovel-corretor tem fonte unica no detalhe (nunca replica id % 3)"

key-files:
  created:
    - lib/domain/entities/anunciante_ref.dart
    - lib/domain/entities/anunciante_ref.freezed.dart
    - lib/domain/repositories/vitrine_anunciante_repository.dart
    - lib/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart
    - lib/data/datasources/vitrine_anunciante_datasource.dart
    - lib/data/datasources/vitrine_anunciante_mock_datasource.dart
    - lib/data/repositories/vitrine_anunciante_repository_impl.dart
    - test/data/vitrine_anunciante_mock_datasource_test.dart
  modified:
    - lib/di/injection.config.dart
    - test/di/injection_perfis_test.dart

key-decisions:
  - "O mock le linhasAcervoFixture/detalhesAcervoFixture/corretoresPerfisFixture no construtor padrao; os testes calculam o esperado das fixtures em tempo de execucao, entao independem da ordem de merge do 07-07."
  - "Detalhe sem corretor (ou ausente, como o 339) fica fora de qualquer vitrine de anunciante."
  - "Chaves corretor/empresa/proprietario sao removidas das linhas servidas, por seguranca, mesmo que uma fixture as carregue."

requirements-completed: [PERF-03, API-08]

coverage:
  - id: D1
    description: "AnuncianteRef e parametros simetricos corretor=<id> / empresa=<id>, sem cidade/ordenacao/busca"
    requirement: API-08
    verification:
      - kind: unit
        ref: "test/data/vitrine_anunciante_mock_datasource_test.dart#parametros (§12.2, §12.6)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Servidor simulado do §12: recorte do corretor e da empresa, mais recentes, paginas de 10 sem repeticao, vazio para corretor 10/ids desconhecidos, 339 fora, cursor invalido"
    requirement: PERF-03
    verification:
      - kind: unit
        ref: "test/data/vitrine_anunciante_mock_datasource_test.dart#servidor simulado (§12.3-§12.5)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Pilha use case -> repositorio -> mock e registro no DI"
    requirement: API-08
    verification:
      - kind: unit
        ref: "test/data/vitrine_anunciante_mock_datasource_test.dart#pilha use case -> repositorio -> mock"
        status: pass
      - kind: unit
        ref: "test/di/injection_perfis_test.dart"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-08
status: complete
plan_head_before: c18c3ed0e2492b060066dde98cb915c40f6e0fb3
plan_head_after: 62ea585
---

# Phase 7 Plan 06: Vitrine do anunciante (camada de dados) Summary

**Servidor simulado do contrato §12 (recorte por corretor/empresa derivado do detalhe, cursor, mais recentes) atras de uma DataSource trocavel, com repositorio, use case e DI.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2
- **Files modified:** 10 (8 criados, 2 alterados)

## Accomplishments
- `AnuncianteRef` freezed sealed e funcoes simetricas `parametrosDoAnunciante`/`anuncianteDosParametros`: o app so envia `corretor=<id>` ou `empresa=<id>`.
- `VitrineAnuncianteMockDataSource` (`.paraTeste` injeta linhas, detalhes, corretores, latencia e tamanho de pagina): corretor = linhas cujo detalhe tem `corretor.id`; empresa = uniao dos corretores com `empresa_id`; ordem `criado_em` desc/`id` desc; cursor `base64Url('o=<offset>')`; vazio (nunca erro) para o corretor 10 e ids desconhecidos; parametros/cursor invalidos lancam `FormatException` sincronamente.
- `VitrineAnuncianteRepositoryImpl` (`_executar`: `TypeError` -> `FormatException`, `Exception` -> `Failure`) e `BuscarImoveisDoAnuncianteUseCase` so delegam, sem filtrar nem reordenar.
- DI regenerado (`injection.config.dart`) e canario de DI estendido.

## Task Commits

1. **Task 1: AnuncianteRef e parametros simetricos do §12** - `8ab0c3f` (feat)
2. **Task 2: servidor simulado, repositorio e use case** - `62ea585` (feat)

## Decisions Made
Ver `key-decisions`. Excecao dev-only do §12.9 documentada no doc da classe do mock: o recorte roda em `data/` no aparelho ate o endpoint existir (Phase 5).

## Deviations from Plan

None - plan executed exactly as written.

Observacao: os testes e o codigo de producao foram commitados juntos por tarefa (um commit `feat` por tarefa), nao em commits RED/GREEN separados, conforme o formato de 2 commits do plano.

## Issues Encountered
- Durante o desenvolvimento do teste, o primeiro rascunho assumia `corretor` nao nulo em todo detalhe; varios detalhes gerados nao o trazem. O teste foi corrigido para tratar `corretor` nulo como o mock faz (fora de qualquer vitrine).
- O build_runner reescreveu ~25 arquivos gerados nao relacionados apenas com diferencas CRLF; foram restaurados com `git checkout -- <caminho>` e nao commitados.
- O teste de allowlist (`corretor`/`empresa`/`proprietario`) verifica o que o app enxerga via `ImovelModel`, que ja descarta chaves desconhecidas; a sanitizacao em si fica no mock e e defensiva.

## Known Stubs
Nenhum. O mock e dev-only por desenho (retirado com a Phase 5) e esta declarado no §12.9.

## Threat Flags
Nenhum. T-07-19 (mitigate): linhas da lista + remocao defensiva de chaves + `ImovelModel` so com campos do card. T-07-21 (mitigate): `FormatException` sincrona -> `Failure`.

## Next Phase Readiness
Pronto para o 07-08 ligar a pagina do corretor ('Imoveis de {nome}') e o 07-12 a da empresa a `BuscarImoveisDoAnuncianteUseCase`. Sem bloqueios. Pendencia web registrada no §12.8 (endpoint e `cidade` opcional).

## Self-Check: PASSED

- Arquivos criados existem (8/8); commits `8ab0c3f` e `62ea585` presentes em HEAD.
- `flutter analyze`: sem problemas; testes do mock, do DI e de `imovel_mock_datasource_test.dart`: 93 passam; guardas de `lib/domain` e de diff da vitrine da cidade passam.
