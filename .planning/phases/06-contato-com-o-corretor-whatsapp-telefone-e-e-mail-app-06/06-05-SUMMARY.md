---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 05
subsystem: dados
tags: [contato, dio, post, repository, result, allowlist, link, apifalsa]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "fixtures capturadas do POST de contato (06-03); CanalContato e valorApi (06-04)"
provides:
  - "ContatoRemoteDataSource: POST /api/publico/imoveis/{id}/contato/ com {'canal': valorApi}, sem cabecalho nem cookie"
  - "ContatoRepository.registrarContato(imovelId, canal) -> Result<Uri> com link validado por canal"
  - "CanalIndisponivelException (400), ContatoLimiteExcedidoException (429), LinkContatoInvalidoException; 404 reaproveita ImovelNaoEncontradoException"
  - "ApiFalsa com POST: ChamadaApiFalsa (metodo, uri, corpo, cabecalhos) e rota de contato 201/400/404/405 sobre as fixtures"
affects: [06-06, 06-07, 06-08, 06-09, 06-10]

plan_head_before: ca9550b7694d218b5be5af350e2c28569766c526
actuals:
  tokens: 9500   # chars/4 sobre codigo e testes alterados (model, 2 datasources, repo, dominio, ApiFalsa, 2 testes)
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count ca9550b..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Link do servidor so como Uri.tryParse: sem Uri(...), sem encodeFull, sem log; toString() devolve o texto recebido"
    - "Falhas de dominio tipadas so em data/ por switch no statusCode; presentation decide pelo tipo"
    - "ApiFalsa grava ChamadaApiFalsa em paralelo a requisicoes (List<Uri> intacta)"

key-files:
  created:
    - lib/data/models/contato_registrado_model.dart
    - lib/data/datasources/contato_datasource.dart
    - lib/data/datasources/contato_remote_datasource.dart
    - lib/domain/repositories/contato_repository.dart
    - lib/data/repositories/contato_repository_impl.dart
    - test/data/contato_remote_datasource_test.dart
    - test/data/contato_repository_impl_test.dart
  modified:
    - test/support/api_falsa.dart
    - lib/di/injection.config.dart

key-decisions:
  - "ContatoRegistradoModel sobrescreve toString() sem o link (freezed respeita o toString do usuario): o link leva o codigo interno e a mensagem do visitante e nao pode vazar por log de objeto"
  - "Validacao do link por canal: WhatsApp https + host wa.me; Telefone tel; E-mail mailto; mais igualdade entre o canal da resposta e o pedido"

requirements-completed: [APP06-C4, APP06-C6, APP06-C2, APP06-C3]

coverage:
  - id: D1
    description: "POST de contato com corpo {canal} vindo do enum, sem Authorization nem Cookie, resposta lida do JSON capturado"
    requirement: APP06-C6
    verification:
      - kind: unit
        ref: "test/data/contato_remote_datasource_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Falhas 400/404/429 tipadas, rede/5xx como DioException, JSON malformado como FormatException"
    requirement: APP06-C4
    verification:
      - kind: unit
        ref: "test/data/contato_repository_impl_test.dart grupo 'falhas do datasource (D-14)'"
        status: pass
    human_judgment: false
  - id: D3
    description: "Link fora da lista do canal (http, host falso, javascript:, intent:, canal trocado, link ilegivel) vira LinkContatoInvalidoException; link valido fica byte a byte igual ao capturado"
    requirement: APP06-C3
    verification:
      - kind: unit
        ref: "test/data/contato_repository_impl_test.dart grupos 'link validado por canal' e 'cadeia real'"
        status: pass
    human_judgment: false
---

# Phase 6 Plan 05: Caminho de dados do toque de contato Summary

**POST de contato por dio (corpo so `{canal}`, sem credencial) e repositorio que devolve um `Uri` validado por canal (wa.me/tel/mailto) ou uma falha de dominio tipada, tudo provado sobre as fixtures capturadas via ApiFalsa agora com POST.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-11-16
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 11 (7 criados, 2 modificados, 2 gerados pelo build_runner)

## Accomplishments

- `ApiFalsa` passa o `RequestOptions` inteiro a `_atender`, grava `ChamadaApiFalsa` (metodo, uri, corpo, cabecalhos) e atende `POST /api/publico/imoveis/<id>/contato/`: 201 com `contato_201_<canal>.json` quando o canal esta em `canais_contato` do detalhe, 400 com `erro_400_canal_contato.json` quando nao esta, 404 para id sem fixture, 405 para outro metodo. `requisicoes` segue `List<Uri>`; os usuarios existentes da ApiFalsa continuam verdes.
- `ContatoRemoteDataSource`: `_dio.post<Object?>` com `{'canal': canal.valorApi}`, sem `Options` nem cabecalho (C6); corpo que nao e objeto vira `FormatException`.
- `ContatoRepositoryImpl`: `switch` no status (400/404/429), `TypeError` -> `FormatException`, e `_linkSeguro` com allowlist por canal; o `Uri` e usado como recebido.
- Teste do datasource prova metodo, caminho, corpo e ausencia de `authorization`/`cookie`; teste do repositorio cobre as falhas, nove casos negativos de link e a cadeia real sobre a ApiFalsa para os tres canais (`uri.toString()` igual ao link capturado).

## Task Commits

1. **Task 1 (tracer): POST de contato no ContatoRemoteDataSource e ApiFalsa com POST** - `e0e67f0` (feat)
2. **Task 2: ContatoRepository com falhas tipadas e link validado por canal** - `6321d97` (feat)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificacao

- Gate do tracer: `flutter test` do datasource (8 passaram) e dos usuarios existentes da ApiFalsa (detalhe_navegacao, imovel_detalhe_remote_datasource, imovel_remote_datasource) passaram antes de seguir para a Task 2.
- `dart run build_runner build -d`: sem SEVERE; `injection.config.dart` registra `ContatoRemoteDataSource` como `ContatoDataSource` e `ContatoRepositoryImpl` como `ContatoRepository`.
- `flutter test test/data/contato_repository_impl_test.dart test/data/contato_remote_datasource_test.dart`: 32 passaram. `flutter test test/data`: 240 passaram. `flutter test` (suite inteira): 647 passaram. `flutter analyze`: sem issues.
- `contato_repository_impl.dart` nao tem `Uri(` nem `encodeFull`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical] toString() do ContatoRegistradoModel sem o link**
- **Found during:** Task 1
- **Issue:** o `toString()` gerado pelo freezed imprimiria o link (codigo interno do imovel + mensagem do visitante) em qualquer log ou mensagem de falha de teste, contra T-06-05-02 e a proibicao de o link aparecer em log.
- **Fix:** `toString()` explicito mostrando so o canal (freezed respeita o override).
- **Files modified:** lib/data/models/contato_registrado_model.dart
- **Commit:** e0e67f0

**2. [Rule 1 - Bug de teste] Link "ilegivel" do teste**
- **Found during:** Task 2 (GREEN)
- **Issue:** `https://wa.me:99999999/x` nao e rejeitado por `Uri.tryParse` (so a porta nao-numerica e), entao o caso de link ilegivel do plano falhava na asserção de premissa.
- **Fix:** o teste usa `https://wa.me:abc/x`, que `Uri.tryParse` realmente rejeita (a premissa e asserida no proprio teste).
- **Files modified:** test/data/contato_repository_impl_test.dart
- **Commit:** 6321d97

**Observacao sem desvio de escopo:** `dart format` sobre `lib/data` reformatou seis arquivos alheios ao plano; foram revertidos com `git checkout -- <arquivo>` antes do commit. O formatador tambem reformatou trechos antigos de `api_falsa.dart` (so estilo, sem mudanca de comportamento).

## Known Stubs

None.

## Threat Flags

None - nenhuma superficie nova alem das cobertas pelo threat model do plano.

## Issues Encountered

None.

## Next Phase Readiness

06-06 pode consumir `ContatoRepository.registrarContato` em um caso de uso: ele ja devolve `Result<Uri>` com link seguro ou as falhas tipadas (`CanalIndisponivelException`, `ImovelNaoEncontradoException`, `ContatoLimiteExcedidoException`, `LinkContatoInvalidoException`, `FormatException`, `DioException`) que os SnackBars de D-14 precisam.

## Self-Check: PASSED

- Arquivos criados existem (model, datasource, remote datasource, repositorio de dominio, impl, dois testes); commits `e0e67f0` e `6321d97` presentes em `git log`.
