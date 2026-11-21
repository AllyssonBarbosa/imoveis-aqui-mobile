---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 06
subsystem: acervo
tags: [flutter, freezed, json_serializable, clean-architecture, acervo]

requires:
  - phase: 08-login-e-rea-do-corretor-o-acervo
    provides: "08-04 — wire do acervo congelado no §14 do contrato, fixtures reais em test/fixtures/api/ e test/data/contrato_acervo_test.dart"
provides:
  - "Entidades de domínio do acervo: SituacaoImovel, ImovelAcervo (com paraPrevia()), PaginaAcervo, ConsultaAcervo"
  - "ImovelAcervoModel (10 chaves do §14.5) e AcervoEnvelopeModel com paraPagina()"
  - "Todas as fixtures acervo_*.json lidas pelos Models (contrato_acervo_test)"
affects: [08-08 DataSource/repositório/use case do acervo, 08-09 AcervoCubit, telas do acervo]

actuals:
  tokens: 14000
  tasks: 2
  commits: 2

plan_head_before: 35cf4272c98e208c8c69248549285649c30b4945
plan_head_after: 153862151d018a95ae2e48d88ed1951d49b372dd

tech-stack:
  added: []
  patterns:
    - "Entidade de domínio sem freezed, com ==/hashCode manuais e imports relativos (molde Imovel/PaginaImoveis)"
    - "Model freezed + json_serializable com mapeamento defensivo em paraEntidade() (situação desconhecida -> null, finalidade desconhecida -> FormatException)"
    - "Envelope não-genérico por feature (molde ImoveisEnvelopeModel)"

key-files:
  created:
    - lib/domain/entities/situacao_imovel.dart
    - lib/domain/entities/imovel_acervo.dart
    - lib/domain/entities/pagina_acervo.dart
    - lib/domain/entities/consulta_acervo.dart
    - lib/data/models/imovel_acervo_model.dart
    - lib/data/models/imovel_acervo_model.freezed.dart
    - lib/data/models/imovel_acervo_model.g.dart
    - lib/data/models/acervo_envelope_model.dart
    - lib/data/models/acervo_envelope_model.freezed.dart
    - lib/data/models/acervo_envelope_model.g.dart
    - test/domain/imovel_acervo_test.dart
    - test/data/imovel_acervo_model_test.dart
  modified:
    - test/data/contrato_acervo_test.dart

key-decisions:
  - "ConsultaAcervo.copyWith usa o flag limparSituacao para voltar a Todas, porque situacao: null em copyWith significa nao mudar (tipagem forte, sem sentinela Object?)"
  - "PaginaAcervo nao e const: copia os itens com List.unmodifiable para garantir imutabilidade (comportamento exigido no plano)"
  - "meuImovel e naVitrine sao apenas lidos do servidor; nenhuma entidade ou Model compara ids ou olha publicado/situacao (D-06, D-07, T-08-32)"

patterns-established:
  - "Defesa no Model: valor de enum desconhecido vira null quando decorativo (situacao) e FormatException quando estrutural (finalidade)"

requirements-completed: [ACV-01, ACV-04]

coverage:
  - id: D1
    description: "Entidades imutáveis do acervo (ImovelAcervo com paraPrevia, PaginaAcervo com lista imutável, ConsultaAcervo com igualdade por valor, SituacaoImovel)"
    requirement: "ACV-01"
    verification:
      - kind: unit
        ref: "test/domain/imovel_acervo_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Models das 10 chaves e envelope do acervo mapeando situação/finalidade/capa de forma defensiva, com meuImovel e naVitrine só lidos do servidor"
    requirement: "ACV-04"
    verification:
      - kind: unit
        ref: "test/data/imovel_acervo_model_test.dart"
        status: pass
      - kind: integration
        ref: "test/data/contrato_acervo_test.dart#Models do acervo leem toda fixture capturada"
        status: pass
    human_judgment: false

duration: 4min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 06: Entidades e Models do acervo do corretor Summary

**Entidades de domínio (ImovelAcervo, PaginaAcervo, ConsultaAcervo, SituacaoImovel) e Models freezed das 10 chaves do §14.5, com as cinco fixtures reais do Django lidas sem erro e as marcas "Seu"/"na vitrine" só repassadas do servidor.**

## Performance

- **Duration:** 4 min
- **Started:** 2026-11-21T14:32:11Z
- **Completed:** 2026-11-21T14:36:15Z
- **Tasks:** 2
- **Files modified:** 13 (12 criados, 1 alterado)

## Accomplishments
- Domínio do acervo imutável e sem dependência de `data/` nem de `flutter`; `ImovelAcervo.paraPrevia()` monta o `Imovel` que `abrirDetalheImovel` já aceita.
- `ImovelAcervoModel` e `AcervoEnvelopeModel` com as 10 chaves exatas; situação desconhecida vira `null`, finalidade desconhecida lança `FormatException`, `foto_capa` fora de http(s) vira `null`.
- `contrato_acervo_test.dart` agora também passa toda `acervo_*.json` pelos Models (20 + 16 + 1 + 0 + 1 itens).
- `flutter test` inteiro verde (883 testes); `flutter analyze lib` sem nenhum item novo.

## Task Commits

1. **Task 1: Entidades do acervo** - `dbe7389` (feat)
2. **Task 2: Models das 10 chaves e envelope do acervo** - `1538621` (feat)

**Plan metadata:** commit docs(08-06) a seguir.

_Nota TDD: o RED de cada tarefa foi observado (Task 1: as classes não existiam, o teste não carregava; Task 2: idem para os Models), mas o teste só foi commitado junto da implementação para não deixar a suíte quebrada entre commits; o plano pede um commit por tarefa (type execute)._

## Files Created/Modified
- `lib/domain/entities/situacao_imovel.dart` - enum DISPONIVEL/RESERVADO/VENDIDO/ALUGADO
- `lib/domain/entities/imovel_acervo.dart` - item do acervo com as 10 chaves em camelCase e `paraPrevia()`
- `lib/domain/entities/pagina_acervo.dart` - página com itens imutáveis e cursor opaco
- `lib/domain/entities/consulta_acervo.dart` - busca + situação (Todas = nula), `copyWith`
- `lib/data/models/imovel_acervo_model.dart` (+ `.freezed.dart`, `.g.dart`) - Model do item e `paraEntidade()`
- `lib/data/models/acervo_envelope_model.dart` (+ `.freezed.dart`, `.g.dart`) - envelope e `paraPagina()`
- `test/domain/imovel_acervo_test.dart`, `test/data/imovel_acervo_model_test.dart` - testes novos
- `test/data/contrato_acervo_test.dart` - grupo novo de parse pelos Models

## Decisions Made
- `ConsultaAcervo.copyWith` ganhou `limparSituacao` para voltar a "Todas", pois `situacao: null` em `copyWith` significa "manter" (evita sentinela `Object?`).
- `PaginaAcervo` não é `const` porque copia os itens com `List.unmodifiable` (imutabilidade exigida no `<behavior>`).
- Nenhuma lógica de decisão local para `meuImovel`/`naVitrine` (D-06, D-07, T-08-32).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Caminho do repositório web desatualizado**
- **Found during:** leitura inicial (nota do orquestrador)
- **Issue:** os PLANs citam `C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`, que não existe; o repositório web está em `C:/projetos/imoveis-aqui`.
- **Fix:** nenhum arquivo do repositório web é tocado por este plano, então a substituição não teve efeito prático.
- **Files modified:** nenhum

**2. [Rule 1 - Bug de teste] `PaginaAcervo` não pode ser `const`**
- **Found during:** Task 1
- **Issue:** os testes escritos primeiro usavam `const PaginaAcervo(...)`, incompatível com a cópia imutável da lista.
- **Fix:** removido o `const` nos testes.
- **Files modified:** `test/domain/imovel_acervo_test.dart`
- **Committed in:** `dbe7389`

---

**Total deviations:** 2 (1 blocking informativa, 1 ajuste de teste)
**Impact on plan:** nenhum impacto de escopo.

## Issues Encountered
- `dart run build_runner build -d` regravou 30 arquivos gerados antigos só com fim de linha (CRLF); verificado que não havia diferença de conteúdo (`git diff --ignore-space-at-eol` vazio) e restaurados com `git checkout --` por caminho explícito. Um primeiro laço em lote foi bloqueado pelo classificador de permissões, e foi refeito com a lista explícita de arquivos.
- `dart format` reformatou `lib/domain/entities/caracteristica.dart` (fora do escopo); revertido.
- `flutter analyze lib` continua com os 30 itens `info` `deprecated_member_use` já existentes (material.dart na Flutter 3.47) em arquivos fora desta fase; nenhum arquivo do acervo aparece na lista.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum — sem nova superfície de rede, autenticação ou acesso a arquivos; mitigações T-08-31 (capa com `urlHttpOuNula`, teste com `javascript:`), T-08-32 (booleanos só lidos), T-08-33 (situação desconhecida -> `null`) aplicadas e testadas.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- 08-08 (DataSource, repositório e use case do acervo) e 08-09 (`AcervoCubit`) podem consumir `ConsultaAcervo`, `PaginaAcervo`, `ImovelAcervo` e `AcervoEnvelopeModel` diretamente.
- Ao converter `FormatException` em `Failure`, o repositório (08-08) deve cobrir a finalidade desconhecida (T-08-33).

## Self-Check: PASSED

- Arquivos criados conferidos no disco; commits `dbe7389` e `1538621` presentes no histórico da branch `feat/APP08`.
- Critérios de aceitação das duas tarefas reexecutados: testes (52 nos três arquivos) verdes, greps do plano OK, `flutter analyze lib` sem item novo, `flutter test` inteiro verde (883), nenhum gerado sobrando modificado.

---
*Phase: 08-login-e-rea-do-corretor-o-acervo*
*Completed: 2026-11-21*
