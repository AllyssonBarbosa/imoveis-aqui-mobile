---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 17
subsystem: presentation
tags: [detalhe-imovel, natureza, lote, terreno, apartamento, predio, loteamento, rotulos, wire-real]
status: complete

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-14: DetalheImovelModel no wire da W09; 05-16: bordas do detalhe e corretor sem slug"
provides:
  - "DadosLote(entradaMinima, parcelasMaximas) sem preco; DadosLoteamento(infraestrutura List<String>, String? areasDeLazer)"
  - "LoteamentoModel com os 5 booleanos (asfalto, agua, energia, esgoto, iluminacao) traduzidos em data/ para rotulos na ordem fixa"
  - "DadosTerreno(lateralEsquerda, lateralDireita); DadosApartamento sem numero; DadosPredio(anoConstrucao) sem unidadesPorAndar"
  - "rotuloPosicaoSolar e rotuloUsoPermitido em presentation/ (codigo desconhecido sai como veio, vazio omite a linha)"
  - "CardQuadraLoteamento: infraestrutura em chips e 'Areas de lazer' como Text (titleSmall + bodyMedium)"
affects: [05-18]

plan_head_before: 40e0cae712fa4a2dbf3e80596ebd9d0656c625b6
actuals:
  tokens: 11800   # chars/4 sobre o diff realizado de lib/ e test/, sem os .freezed.dart/.g.dart
  tasks: 2
  commits: 2      # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Traducao de booleanos da API para rotulos em data/ (Model -> entidade); traducao de codigos de enum para rotulos em presentation/"
    - "Texto livre da API (areas_de_lazer) como Text simples, nunca dividido por virgula"
    - "Helper privado _codigo(rotulo, codigo, funcaoDeRotulo): nulo/branco omite, senao rotula"

key-files:
  created: []
  modified:
    - lib/domain/entities/dados_natureza.dart
    - lib/data/models/dados_natureza_model.dart
    - lib/presentation/detalhe_imovel/apresentacao_natureza.dart
    - lib/presentation/detalhe_imovel/widgets/cards_natureza.dart
    - test/data/detalhe_imovel_model_test.dart
    - test/presentation/apresentacao_natureza_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
    - test/presentation/detalhe_navegacao_test.dart

key-decisions:
  - "A-03 mantida: infraestrutura = so os booleanos verdadeiros, na ordem Asfalto, Agua, Energia, Esgoto, Iluminacao publica; areas_de_lazer em branco (apos trim) vira null"
  - "A-04 mantida: tabelas de rotulos pequenas em presentation/ com fallback para o codigo cru; vazio ou so espacos omite a linha (substitui F4/D-19 b)"
  - "Preco do lote saiu: o preco do lote e o preco de venda do imovel, mostrado no cabecalho (§11.5 d)"

requirements-completed: []  # API-07 so fecha em 05-18; o frontmatter do plano declara [API-07]

coverage:
  - id: D1
    description: "A pagina de um lote real mostra 'Sobre o lote' com numero, Entrada minima (moeda), Parcelas maximas e condicoes, e o card 'Quadra e loteamento' com a infraestrutura em chips (so os verdadeiros, ordem fixa) e as areas de lazer como texto corrido; 'Preco do lote' nao existe mais"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#natureza no wire real (D-17, A-03)"
        status: pass
      - kind: test
        ref: "test/data/detalhe_imovel_model_test.dart#loteamento do lote capturado (A-03)"
        status: pass
      - kind: test
        ref: "test/presentation/apresentacao_natureza_test.dart#lote e #quadraTemConteudo"
        status: pass
      - kind: test
        ref: "gate do plano: ! grep -rn 'Preço do lot[e]' lib"
        status: pass
    human_judgment: false
  - id: D2
    description: "Terreno mostra 'Lateral esquerda' e 'Lateral direita'; apartamento sem 'Unidade'; predio com 'Ano de construcao' e sem 'Unidades por andar'; campos que a API nao manda sairam do Model e da entidade"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/detalhe_imovel_model_test.dart#TERRENO capturado / apartamento.predio capturado"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#terreno capturado e #apartamento capturado"
        status: pass
      - kind: test
        ref: "gate do plano: ! grep -rnE 'unidadesPorAnda[r]|unidades_por_anda[r]|laterais' lib"
        status: pass
    human_judgment: false
  - id: D3
    description: "posicao_solar e uso_permitido chegam como codigo e a pagina mostra rotulos em portugues; desconhecido aparece como veio e vazio omite a linha"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/presentation/apresentacao_natureza_test.dart#posicao solar / uso permitido / rotuloPosicaoSolar e rotuloUsoPermitido"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_imovel_screen_test.dart#apartamento e terreno mostram rotulos em portugues"
        status: pass
    human_judgment: false
  - id: D4
    description: "Campo nulo omite a linha e secao vazia some inteira, inclusive o card da quadra sem linha, infraestrutura nem areas de lazer; nada e calculado no app"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/presentation/apresentacao_natureza_test.dart#quadraTemConteudo"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_imovel_screen_test.dart#quadra sem linhas e sem listas nao mostra o card"
        status: pass
    human_judgment: false
  - id: D5
    description: "Os campos de natureza que a W09 manda e o app ja tinha (casa: banheiros, salas, pavimentos, piscina, quintal, churrasqueira, mobiliada; terreno: topografia, murado, esquina, uso_permitido; apartamento: posicao_solar; predio: ano_construcao) entram como destaques e linhas, conferidos contra o JSON capturado"
    requirement: API-07
    verification:
      - kind: test
        ref: "test/data/detalhe_imovel_model_test.dart#CASA capturada vira DadosCasa com todos os campos"
        status: pass
      - kind: test
        ref: "test/presentation/detalhe_navegacao_test.dart#casa capturada"
        status: pass
    human_judgment: false

duration: 40min
completed: 2026-11-01
---

# Phase 5 Plan 17: Blocos de natureza no wire real Summary

**Lote, terreno, apartamento e predio seguem o JSON capturado da W09: lote com entrada minima/parcelas e o card de quadra com infraestrutura em chips (5 booleanos traduzidos em `data/`) e areas de lazer em texto corrido, terreno com duas laterais, predio com `ano_construcao`, e rotulos em portugues para os codigos de posicao solar e uso permitido (A-04).**

## O que mudou

- **Tracer (Task 1, lote):**
  - Dominio: `DadosLote` perdeu `preco` e ganhou `entradaMinima` (string decimal do servidor) e `parcelasMaximas` (int); `DadosLoteamento.areasLazer` (lista) virou `String? areasDeLazer`.
  - Data: `LoteModel` le `entrada_minima` e `parcelas_maximas`; `LoteamentoModel` declara `asfalto/agua/energia/esgoto/iluminacao` (`bool?`) e `areas_de_lazer` (`String?`). `paraEntidade()` monta `infraestrutura` com os rotulos dos verdadeiros (Asfalto, Água, Energia, Esgoto, Iluminação pública) e mapeia texto em branco para `null`.
  - Apresentacao: linhas do lote 'Número do lote', 'Entrada mínima' (`formatarPrecoBrl`), 'Parcelas máximas', 'Condições de parcelamento'; `quadraTemConteudo` considera linhas, infraestrutura ou `areasDeLazer != null`; `CardQuadraLoteamento` mostra 'Áreas de lazer' como titulo `titleSmall` mais `Text` simples (sem chips, sem dividir a frase).
- **Task 2 (auto, tdd, nature restante):**
  - Dominio/Model: `DadosTerreno(lateralEsquerda, lateralDireita)` (`lateral_esquerda`/`lateral_direita`); `DadosApartamento` sem `numero`; `DadosPredio(anoConstrucao)` (`ano_construcao`) sem `unidadesPorAndar`.
  - Apresentacao: `rotuloPosicaoSolar` e `rotuloUsoPermitido` junto de `rotuloTopografia`; helper privado `_codigo` (nulo/branco omite a linha); linhas 'Lateral esquerda', 'Lateral direita', 'Ano de construção'; linha 'Unidade' e 'Unidades por andar' removidas.

## Cobertura dos campos do carry-over (05-14, deviation 1), sobre o JSON capturado

| Campo que o wire real renomeou | Onde esta coberto |
|---|---|
| terreno `laterais` -> `lateral_esquerda`/`lateral_direita` | `detalhe_imovel_model_test` (terreno capturado: `'25.00'`/`'25.00'`; lateral nula isolada); `apresentacao_natureza_test` (duas linhas, sem 'Laterais', omissao por lado); `detalhe_navegacao_test` (terreno capturado: rotulos das duas laterais e ausencia de 'Laterais') |
| lote `preco` (removido) | `detalhe_imovel_model_test` (lote capturado traz `entradaMinima`/`parcelasMaximas`, entidade sem `preco`); `apresentacao_natureza_test` ('Preço do lote' inexistente); `detalhe_imovel_screen_test` (cabecalho usa o preco de venda; sem 'Preço do lote'); `detalhe_navegacao_test` (lote capturado: sem 'Preço do lote', cabecalho com R$ 235.000); gate `grep` em `lib` |
| lote `infraestrutura` como lista | `detalhe_imovel_model_test` ('loteamento do lote capturado': 5 booleanos -> 5 rotulos na ordem fixa; so os verdadeiros; nenhum verdadeiro -> vazia); `detalhe_navegacao_test` (um `Chip` por item) |
| lote `areas_lazer` como lista | `detalhe_imovel_model_test` (frase capturada como `areasDeLazer`; vazia/branca/nula -> `null`; virgula nao divide); `detalhe_imovel_screen_test` (Text, nao Chip); `detalhe_navegacao_test` (frase inteira como `Text`, fora de qualquer `Chip`) |
| predio `ano` -> `ano_construcao` (e `unidades_por_andar` removido) | `detalhe_imovel_model_test` (`anoConstrucao == 2013` no apartamento capturado); `apresentacao_natureza_test` ('Ano de construção', sem 'Unidades por andar'); `detalhe_imovel_screen_test`; `detalhe_navegacao_test` (apartamento capturado: card 'Prédio' com 'Ano de construção' = `ano_construcao` do JSON) |
| apartamento `numero` (removido) | `apresentacao_natureza_test` e `detalhe_navegacao_test` (sem linha 'Unidade') |

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `3e0ce75` feat(05-17): lote real na página do imóvel
2. **Task 2 (auto, tdd):** `10a2234` feat(05-17): terreno, apartamento e prédio no wire real com rótulos dos códigos

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas. `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` deixados como estavam. Nenhuma delecao de arquivo.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: `build_runner` (sem SEVERE), os quatro arquivos de teste, `flutter analyze` e o gate `! grep "Preço do lot[e]" lib` reexecutados e verdes antes da Task 2.

## Deviations from Plan

**1. [Rule 3 - Bloqueio] `detalhe_imovel_screen_test.dart` alterado ja na Task 1.** O arquivo nao esta em `files` da Task 1, mas usava `DadosNatureza.lote(preco: ...)` e `DadosLoteamento(areasLazer: [...])`; remover esses campos quebrou a compilacao. Os testes do lote foram reescritos para o novo modelo (entrada minima/parcelas, areas de lazer em `Text`, cabecalho com o preco de venda). Nenhum teste foi apagado sem substituto: o teste "lote com preco proprio" virou "lote mostra entrada minima e parcelas", e "lote sem preco proprio" virou "sem dados de parcelamento".

**2. [Detalhe] Task 2 em TDD com RED por compilacao.** Os testes novos referenciam getters que ainda nao existiam (`lateralEsquerda`, `anoConstrucao`), entao o RED foi falha de compilacao; GREEN apos a implementacao. Um unico commit por task (politica app-a), sem commits separados de RED/GREEN.

**3. [Detalhe] Contrato de chaves dos blocos de natureza nao ampliado.** O 05-14 (deviation 2) disse que os blocos casa/terreno/apartamento/lote ganhariam o conjunto exato de chaves no 05-17, mas `contrato_detalhe_test.dart` nao esta em `files_modified` deste plano e o carry-over pede cobertura por teste sobre o JSON capturado, nao o contrato. Fica como pendencia para o 05-18 (ou plano posterior) decidir: ampliar `_exigirContrato` com os quatro blocos.

Sem auth gates, sem pacotes adicionados, sem bloqueios. Arquivos fora de `files_modified`: `dados_natureza.freezed.dart`, `dados_natureza_model.freezed.dart` e `.g.dart` (saidas do build_runner, ja em `build_outputs`) e o `detalhe_imovel_screen_test.dart` da deviation 1.

**Total deviations:** 3 (1 bloqueio de compilacao em teste, 2 de processo/escopo). **Impact:** nenhum no escopo funcional.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-17-01 (texto livre `areas_de_lazer`/`condicoes_parcelamento` como `Text` simples), T-05-17-02 (rotulos com fallback para o codigo cru, natureza/topografia desconhecidas continuam tolerantes), T-05-17-03 (nenhuma conta com area, medida ou preco; gate de grep da linha 'Preço do lote') mitigados; T-05-17-SC (nenhum pacote) aceito.

## Verificacao

- `dart run build_runner build`: sem SEVERE. `flutter test --timeout 60s` completo: 559 testes, todos verdes. `flutter analyze`: sem problemas.
- Gates: `! grep "Preço do lot[e]" lib` e `! grep -E "unidadesPorAnda[r]|unidades_por_anda[r]|'laterai[s]'|'Laterai[s]'" lib` imprimem nada; `grep -c "'Unidade'"` em `apresentacao_natureza.dart` = 0; `'ano_construcao'` presente no `PredioModel`.
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Os quatro arquivos de `lib/` e os quatro de `test/` listados em `key-files` existem e foram modificados; nenhum arquivo removido.
- Commits `3e0ce75` e `10a2234` existem em feat/APP05; `git rev-list --count 40e0cae..HEAD` = 2 antes do commit do SUMMARY.
