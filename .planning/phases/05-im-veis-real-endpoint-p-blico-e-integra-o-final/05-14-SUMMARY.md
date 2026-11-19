---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 14
subsystem: data
tags: [detalhe-imovel, api-publica, endereco, corretor-responsavel, contrato, apifalsa, remocao-do-mock]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-07: detalhe_*.json capturados; 05-12: CaracteristicaModel e fim do mock das opcoes"
provides:
  - "ImovelDetalheRemoteDataSource (dio) registrada no DI: GET /api/publico/imoveis/<id>/"
  - "DetalheImovelModel no wire real da W09 (EnderecoPublicoModel completo, fotos imagem/ordem/capa, caracteristicas {id, nome}, corretor_responsavel so id/nome/foto)"
  - "DetalheImovel.cidade nula (endereco nulo tolerado)"
  - "ApiFalsa serve /api/publico/imoveis/<id>/ (detalhe_*.json pelo id, senao 404 com erro_404_detalhe.json)"
  - "Teste de contrato com chaves exatas por objeto, igual a allowlist Django do 05-02"
  - "lib/data/mocks/ removido: nenhum servidor simulado nem fixture de acervo no app (D-18)"
affects: [05-15, 05-16, 05-17]

plan_head_before: ab2180eae9fa23cf2783b0ad007b61ffe83bb088
actuals:
  tokens: 14000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "DataSource remota do detalhe exige objeto JSON (senao FormatException) e deixa a DioException subir; o repositorio traduz 404/TypeError/Exception"
    - "Testes de erro do detalhe usam copias do JSON capturado com uma chave alterada, nunca mapa escrito a mao"
    - "Contrato = conjunto exato de chaves por objeto lido de test/fixtures/api/ (helper provado por casos que devem falhar)"

key-files:
  created:
    - lib/data/datasources/imovel_detalhe_remote_datasource.dart
  modified:
    - lib/domain/entities/detalhe_imovel.dart
    - lib/data/models/detalhe_imovel_model.dart
    - lib/data/datasources/imovel_detalhe_datasource.dart
    - lib/data/repositories/imovel_detalhe_repository_impl.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart
    - test/data/detalhe_imovel_model_test.dart
    - test/data/imovel_detalhe_repository_impl_test.dart
    - test/data/contrato_detalhe_test.dart
    - test/presentation/detalhe_navegacao_test.dart
  deleted:
    - lib/data/datasources/imovel_detalhe_mock_datasource.dart
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - lib/data/mocks/imoveis_fixture.dart
    - test/data/imovel_detalhe_mock_datasource_test.dart

key-decisions:
  - "A entidade ganha so Cidade? cidade (D-15 minimo): logradouro, numero e CEP sao lidos pelo Model mas nao sobem ao dominio; a pagina continua com 'bairro · cidade, UF' (D-01)"
  - "endereco nulo vira bairro '' e cidade nula na entidade; rotuloLocalizacao ja aceitava cidade nula, sem mudanca na apresentacao"
  - "CorretorModel declara so id, nome e foto; slug saiu do Model (a entidade ainda tem slug nulo ate o 05-16)"
  - "Contrato cobre raiz, endereco, cidade, foto, caracteristica e corretor; os blocos de natureza ficam para o 05-17 (que renomeia os campos)"

requirements-completed: []  # API-07 so fecha em 05-18 (orientacao do coordenador); o frontmatter do plano declara [API-07]

coverage:
  - id: D1
    description: "Tocar num card real abre a pagina com a previa e, em seguida, o detalhe de GET /api/publico/imoveis/<id>/ servido pela ImovelDetalheRemoteDataSource: descricao, caracteristicas pelo nome, corretor com nome e foto, 'bairro · cidade, UF'"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#tracer"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#DI real"
        status: pass
    human_judgment: false
  - id: D2
    description: "O Model segue o JSON real: endereco completo e anulavel, fotos imagem/ordem/capa na ordem recebida, caracteristicas {id, nome}, corretor_responsavel nulo tolerado, blocos casa/apartamento/terreno/lote"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/detalhe_imovel_model_test.dart#detalhe_casa.json no wire real"
        status: pass
      - kind: test
        ref: "test/data/detalhe_imovel_model_test.dart#tolerância do endereco"
        status: pass
    human_judgment: false
  - id: D3
    description: "O corretor fica em nome e foto: contato, CRECI, apresentacao e empresa_id do wire sao ignorados pelo parser e nunca guardados"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/contrato_detalhe_test.dart#o Model não guarda o contato do corretor"
        status: pass
      - kind: test
        ref: "gate do plano: grep de campos de contato em detalhe_imovel_model.dart imprime nada"
        status: pass
    human_judgment: false
  - id: D4
    description: "Nenhum servidor simulado nem fixture de acervo resta em lib/ e o DI registra so DataSources dio reais"
    requirement: API-07
    verification:
      - kind: test
        ref: "gate do plano: test ! -d lib/data/mocks && ! grep -rnE 'MockDataSource|AcervoFixture|data/mocks/' lib test"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#DI real"
        status: pass
    human_judgment: false
  - id: D5
    description: "Os gatilhos 338/339 do mock viraram testes com DataSource mockada: 404 -> nao encontrado, 500 -> DioException, TypeError -> FormatException"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/imovel_detalhe_repository_impl_test.dart#buscarDetalhe"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#outros cards da vitrine (404) e #retry (500)"
        status: pass
    human_judgment: false
  - id: D6
    description: "O contrato do detalhe compara o app com o JSON capturado: cada detalhe parseia e o conjunto de chaves de cada objeto publico e igual ao da allowlist Django do 05-02; chave extra ou faltando quebra"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/contrato_detalhe_test.dart#cada detalhe capturado"
        status: pass
      - kind: test
        ref: "test/data/contrato_detalhe_test.dart#guarda do contrato (prova de que o teste morde)"
        status: pass
    human_judgment: false

duration: 45min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 14: Pagina do imovel na API real e fim do ultimo servidor simulado Summary

**`ImovelDetalheRemoteDataSource` (dio, no DI) serve `GET /api/publico/imoveis/<id>/` para a pagina do imovel, o Model segue o JSON da W09 (endereco completo, fotos `imagem/ordem/capa`, caracteristicas `{id, nome}`, `corretor_responsavel` so com id/nome/foto), o mock do detalhe e as fixtures de acervo saíram de `lib/` e um teste de contrato trava as chaves de cada objeto contra a captura real.**

## O que mudou

- **Tracer (Task 1):**
  - Dominio: `DetalheImovel.cidade` virou `Cidade?`. A entidade nao ganhou logradouro, numero nem CEP (a pagina continua com "bairro · cidade, UF", D-01).
  - Model: `EnderecoPublicoModel` (logradouro, numero, bairro, cep, cidade, latitude, longitude, tudo anulavel) em `endereco`; `FotoImovelModel` le `imagem` em `url`, mais `ordem` e `capa`; `caracteristicas` e `List<CaracteristicaModel>` mapeada para os nomes; `@JsonKey(name: 'corretor_responsavel') CorretorModel?` com `id`, `nome` e `foto`. `paraEntidade()` usa `endereco?.bairro ?? ''`, `endereco?.cidade?.paraEntidade()` e coordenadas do endereco; fotos e foto do corretor continuam filtradas por `urlHttpOuNula`, na ordem recebida.
  - DataSource: `ImovelDetalheRemoteDataSource` (`@LazySingleton(as: ImovelDetalheDataSource)`) exige objeto JSON e deixa a `DioException` (404 inclusive) subir. `build_runner` registra so DataSources dio no DI.
  - Remocao (`git rm`): `imovel_detalhe_mock_datasource.dart`, `imoveis_detalhe_fixture.dart`, `imoveis_fixture.dart` (o diretorio `lib/data/mocks/` sumiu) e `imovel_detalhe_mock_datasource_test.dart`. O repositorio perdeu o `catch` que so o mock exercitava.
  - `ApiFalsa` ganhou a rota do detalhe: serve o `detalhe_*.json` cujo `id` bate, senao 404 com `erro_404_detalhe.json`.
  - Testes sobre JSON capturado: Model (casa/apartamento/terreno/lote/sem fotos/sem corretor, endereco nulo, logradouro/numero/CEP nulos, foto sem `ordem` = `TypeError`, URLs inseguras, blocos de natureza), repositorio (mocktail + cadeia dio real sobre a `ApiFalsa`), contrato e navegacao (previa com spinner, Descricao, cidade, corretor, perfil, 404, retry 500, DI).
- **Task 2 (auto, tdd):** contrato e erros tipados fechados: foto sem `ordem` pela cadeia dio real vira `Failure(FormatException)` e endereco sem logradouro/numero/CEP continua `Success`.

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `7d2d447` feat(05-14): página do imóvel na API real via DI
2. **Task 2 (auto, tdd):** `38098eb` test(05-14): contrato do detalhe e erros tipados sobre o JSON capturado

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas. `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` deixados como estavam.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: `build_runner`, os quatro testes listados, `flutter analyze`, o gate de remocao e o de DI reexecutados e verdes antes da Task 2.

## Deviations from Plan

**1. [Rule 3 - Bloqueio] Testes do Model e do contrato reescritos sem o acervo.** `detalhe_imovel_model_test.dart` e `contrato_detalhe_test.dart` dependiam de `detalhesAcervoFixture()`/`linhasAcervoFixture()` e dos exemplos da Fase 1 no formato antigo (`bairro`/`cidade`/`corretor` no topo, foto `url`), que nao parseiam mais no wire real. Foram reescritos sobre `test/fixtures/api/`. Os testes de natureza que dependiam de campos do acervo que a API real nao manda do mesmo jeito (terreno `laterais`, apartamento `numero`, lote `preco`, `infraestrutura`/`areas_lazer` em lista, `ano` do predio) nao foram portados: o wire real os renomeou, e quem cobre os campos novos e o 05-17. Os testes que continuam validos (casa completa, `area_livre` sem calculo, topografia, `posicao_solar` como texto, predio, quadra/loteamento nulos, bloco vazio, natureza desconhecida, bloco ausente) foram mantidos sobre os blocos capturados. Os exemplos da Fase 1 em `.planning/.../contrato/` continuam no disco, sem uso nos testes.

**2. [Detalhe] Contrato sem os blocos de natureza.** O plano lista os conjuntos exatos de chaves de raiz, endereco, cidade, foto, caracteristica e corretor; os blocos casa/terreno/apartamento/lote nao estao na lista e ganham o seu conjunto no 05-17, junto com a renomeacao dos campos.

**3. [Detalhe] Latencia do detalhe em `ApiFalsa` propria.** Para a previa ficar de pe o tempo de testar o spinner, o detalhe usa uma segunda `ApiFalsa(latencia: ...)` (mesmas fixtures), enquanto a vitrine usa a `ApiFalsa` sem latencia.

**4. [Detalhe] Task 2 nasceu verde.** A implementacao da Task 1 ja mapeava 404/500/`TypeError`/endereco anulavel; os testes da Task 2 (foto sem `ordem` pela cadeia real, endereco sem logradouro/numero/CEP, chave extra/faltando no contrato) servem de regressao, sem etapa RED.

Sem auth gates, sem pacotes adicionados, sem bloqueios. Nenhum arquivo fora de `files_modified` (alem de `detalhe_imovel.freezed.dart`, `detalhe_imovel_model.freezed.dart`/`.g.dart` e `injection.config.dart`, saidas do build_runner listadas em `build_outputs`, e `imovel_detalhe_datasource.dart`, cujo comentario sobre o mock foi ajustado).

**Total deviations:** 4 (reorganizacao de testes). **Impact:** nenhum no escopo nem nos contratos; os campos de natureza renomeados ficam cobertos pelo 05-17.

## Known Stubs

Nenhum. `CorretorResponsavel.slug` continua na entidade, sempre nulo agora que o wire real nao o manda; o 05-16 o remove.

## Threat Flags

Nenhum. T-05-14-01 (`CorretorModel` so com id/nome/foto, gate de grep vazio), T-05-14-02 (`urlHttpOuNula` em toda URL de imagem), T-05-14-03 (TypeError/Exception -> falha tipada -> "Tentar de novo"), T-05-14-05 (contrato de chaves exatas) mitigados; T-05-14-04 (endereco exato no Model, nao exibido) e T-05-14-SC (nenhum pacote) aceitos.

## Verificacao

- `dart run build_runner build`: sem SEVERE. `flutter test` completo: 521 testes, todos verdes (de 519 antes da Task 2). `flutter analyze`: sem problemas.
- Gate de remocao: `lib/data/mocks` inexistente e nenhuma referencia a `MockDataSource`/`AcervoFixture`/`data/mocks/` em lib e test. `ImovelDetalheRemoteDataSource` presente em `injection.config.dart`. Grep de campos de contato em `detalhe_imovel_model.dart` imprime nada.
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- `imovel_detalhe_remote_datasource.dart` existe; os quatro arquivos removidos nao existem mais; `lib/data/mocks/` nao existe.
- Commits `7d2d447` e `38098eb` existem em feat/APP05; `git rev-list --count ab2180e..HEAD` = 2 antes do commit do SUMMARY.
