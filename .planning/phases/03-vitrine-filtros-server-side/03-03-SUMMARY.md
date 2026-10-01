---
phase: 03-vitrine-filtros-server-side
plan: 03
subsystem: data
tags: [flutter, freezed, flutter_bloc, cubit, text-input-formatter, query-params, price-range]

requires:
  - phase: 03-vitrine-filtros-server-side
    provides: "FiltrosVitrine (precoMin/precoMax/areaMin/areaMax já no freezed), RascunhoFiltrosCubit, filtros_bottom_sheet.dart com Finalidade/Tipo de imóvel/Quartos-Suítes-Vagas, ImovelMockDataSource filtrando natureza/bairro/características/mínimos sobre mapas de wire (03-01, 03-02)"
provides:
  - "parametrosDaConsulta/filtrosDosParametros estendidos com preco_min/preco_max/area_min/area_max (inteiroNaoNegativoDoParametro), validando faixa invertida e preço sem finalidade como FormatException (D-03, D-12, simula o 400)"
  - "ImovelMockDataSource._linhaCasaComFiltros filtra por preco_venda ou preco_aluguel conforme a finalidade aplicada, e por area (com ou sem finalidade), excluindo linhas com campo-base nulo enquanto a faixa está ativa"
  - "_comparadorDe usa preco_aluguel para preco_asc/preco_desc quando a finalidade é ALUGUEL (D-03, contrato §7.5), preservando o comportamento de preco_venda para VENDA/sem finalidade"
  - "MascaraMilhares (TextInputFormatter hand-rolado) + inteiroDoTextoMascarado/textoMascaradoDe (conversão fora do widget) — sem dependência nova"
  - "Sheet ganha as seções Preço (trava sem finalidade, D-03/D-13) e Área (sempre habilitada), com erro inline e 'Ver imóveis' desabilitado enquanto a faixa estiver invertida (D-12) — FIL-03/FIL-04 completos via pilha real"
affects: [03-04, 03-05]

# Measured (#3968) — git rev-list --count 1068b3d4..HEAD, not narrated.
commits: 4
plan_head_before: 1068b3d4010b8cf8fae6b1383ad608141763c819

actuals:
  tokens: 19107
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Núcleo de validação inteira não-negativa compartilhado via helper privado (_inteiroNaoNegativo) entre minimoDoParametro (limiar N-ou-mais) e inteiroNaoNegativoDoParametro (faixas) — mesma regra, rótulo de erro diferente, nunca duas implementações divergentes"
    - "Validação de FORMULÁRIO (erroFaixaPreco/erroFaixaArea/podeAplicar) mora numa extension on FiltrosVitrine dentro do próprio arquivo do Cubit do rascunho — nunca substitui a validação do servidor simulado, que revalida de forma independente em data/"
    - "StatefulWidget só para hospedar TextEditingControllers quando um sheet precisa de campos de texto mascarados — a fonte da verdade continua sendo o Cubit (BlocBuilder/BlocListener), os controllers só espelham texto já formatado"

key-files:
  created:
    - lib/presentation/vitrine/widgets/mascara_numerica.dart
    - test/presentation/mascara_numerica_test.dart
  modified:
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - test/data/parametros_consulta_imoveis_test.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Task 1 e Task 2 seguiram TDD explícito (tdd=\"true\"): cada uma teve um commit RED (test(03-03), falha confirmada via flutter test — compilação para `inteiroNaoNegativoDoParametro` inexistente na Task 1, e asserções de filtro/ordenação/widget ainda não implementadas na Task 2) antes do commit GREEN (feat(03-03)); nenhum REFACTOR commit foi necessário em nenhuma das duas (o código já saiu limpo na primeira implementação)."
  - "inteiroNaoNegativoDoParametro reusa o mesmo núcleo de minimoDoParametro (helper privado _inteiroNaoNegativo com rótulo de mensagem parametrizado) em vez de duplicar a validação — mesma regra (inteiro não-negativo), dois nomes públicos para dois contextos semânticos (limiar N-ou-mais vs. faixa)."
  - "Os e2e da vitrine completa (vitrine_fluxo_test.dart) localizam os campos de preço/área pelo rótulo ('Mínimo'/'Máximo' via find.widgetWithText), nunca por índice cru de TextField — a tela cheia da vitrine tem sua própria SearchBar, que também é implementada como TextField internamente, deslocando qualquer índice fixo."

patterns-established:
  - "Toda faixa nova (preço, área) estende parametrosDaConsulta E filtrosDosParametros simetricamente, com validação de inversão (mín > máx) e de pré-requisito (preço exige finalidade) dentro de filtrosDosParametros — nunca dependendo só da validação de formulário do sheet."
  - "_SecaoFaixa (widget privado do sheet) reusado por Preço e Área — uma única implementação de par de TextFields com máscara, habilitação condicional e erro inline no campo Máximo, nunca duas cópias."

requirements-completed: [FIL-03, FIL-04, FIL-05]

coverage:
  - id: D1
    description: "Faixa de preço (mín/máx) filtrada pelo servidor simulado comparando preco_venda (Venda) ou preco_aluguel (Aluguel), com faixa invertida ou preço sem finalidade rejeitados como FormatException (400 simulado), ponta a ponta via sheet -> rascunho -> query params -> mock (FIL-03, D-03, D-12)"
    requirement: "FIL-03"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> Venda + preço 250.000..300.000 -> Ver imóveis filtra pela pilha real..."
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#Venda + preço 250000..300000 devolve exatamente as linhas VENDA ou VENDA_E_ALUGUEL..."
        status: pass
      - kind: unit
        ref: "test/data/parametros_consulta_imoveis_test.dart#preco_min sem finalidade lança FormatException (D-03)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Faixa de área (mín/máx) filtrada pelo servidor simulado comparando area, funcionando com ou sem finalidade escolhida, excluindo imóveis sem área enquanto a faixa está ativa (FIL-04, D-09)"
    requirement: "FIL-04"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> área 80..120 (sem finalidade) -> Ver imóveis filtra pela pilha real..."
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#área 80..120 devolve exatamente as linhas com área não-nula no intervalo..."
        status: pass
    human_judgment: false
  - id: D3
    description: "Ordenação por preço usa preco_aluguel (nulls-last) quando a finalidade aplicada é ALUGUEL, preservando preco_venda para VENDA/sem finalidade — regra do servidor simulado, nunca do app (D-03, contrato §7.5, FIL-05)"
    requirement: "FIL-05"
    verification:
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#com finalidade ALUGUEL, preco_asc ordena por preco_aluguel ascendente, nulls last"
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#com finalidade VENDA, preco_asc continua ordenando por preco_venda (comportamento da Fase 2 inalterado)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Campos de preço/área com máscara de milhares (MascaraMilhares), preço travado (desabilitado + mensagem) sem finalidade, texto limpo ao trocar finalidade (D-13), erro inline no campo Máximo bloqueando 'Ver imóveis' até corrigir (D-12)"
    requirement: "FIL-03"
    verification:
      - kind: unit
        ref: "test/presentation/mascara_numerica_test.dart (11 testes: formatação, caret, dígitos limitados, conversões)"
        status: pass
      - kind: unit
        ref: "test/presentation/rascunho_filtros_cubit_test.dart#ValidacaoRascunho (D-12) — erroFaixaPreco/erroFaixaArea/podeAplicar"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/filtros_bottom_sheet_test.dart#mínimo de preço maior que o máximo mostra erro inline no campo Máximo e desabilita \"Ver imóveis\"; corrigir reabilita (D-12)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/filtros_bottom_sheet_test.dart#trocar de Venda para Aluguel limpa o texto já digitado nos campos de preço (D-13)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Layout visual das novas seções do sheet (Preço, Área — espaçamento, alinhamento dos dois campos lado a lado, mensagem de ajuda quando desabilitado) segue Material 3 / paleta verde-branco na tela real do dispositivo"
    human_judgment: true
    rationale: "Testes de widget verificam estrutura/texto/comportamento (TextField habilitado/desabilitado, errorText, prefixo/sufixo), não aparência visual final (alinhamento do Row em telas estreitas, contraste do texto de ajuda) — mesmo padrão de D6 em 03-02, julgamento humano necessário no app rodando"

duration: ~35min
completed: 2026-09-30
status: complete
---

# Phase 3 Plan 3: Faixas de Preço e Área Summary

**Servidor simulado ganha faixas de preço (por finalidade: `preco_venda` ou `preco_aluguel`) e de área, com validação 400 simulada e ordenação por `preco_aluguel` sob Aluguel; o sheet ganha campos mín/máx mascarados em milhares, trava de preço sem finalidade (D-03/D-13) e erro inline (D-12), ponta a ponta.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 2
- **Files modified/created:** 11 (2 novos, 9 alterados) — 4 em `lib/`, 7 em `test/`

## Accomplishments

- `parametrosDaConsulta`/`filtrosDosParametros` ganham `preco_min`/`preco_max`/`area_min`/`area_max` (novo parser `inteiroNaoNegativoDoParametro`, que reusa o mesmo núcleo de `minimoDoParametro`), com validação server-side: preço sem finalidade e qualquer faixa invertida (mín > máx) lançam `FormatException` (simulando o 400); mínimo IGUAL ao máximo é aceito (faixa de um único valor).
- `ImovelMockDataSource._linhaCasaComFiltros` compara a faixa de preço com `preco_venda` (Venda) ou `preco_aluguel` (Aluguel) conforme a finalidade aplicada — nunca enviada sem finalidade, já garantido pela validação acima — e a faixa de área com `area`, funcionando com ou sem finalidade; em ambos os casos uma linha com o campo-base nulo fica fora do resultado enquanto a faixa está ativa. `_comparadorDe` passa a usar `preco_aluguel` para `preco_asc`/`preco_desc` quando a finalidade aplicada é `ALUGUEL` (D-03, contrato §7.5), preservando `preco_venda` para Venda/sem finalidade (comportamento da Fase 2 inalterado).
- `lib/presentation/vitrine/widgets/mascara_numerica.dart` (novo): `MascaraMilhares` — `TextInputFormatter` hand-rolado sobre `intl.NumberFormat` (sem pacote novo) que converte dígitos em texto com separador de milhar pt_BR, descarta letras/símbolos e zeros à esquerda (um "0" isolado permanece), limita a 9 dígitos e mantém o caret no fim; `inteiroDoTextoMascarado`/`textoMascaradoDe` fazem a conversão para/de `int` FORA do widget.
- `RascunhoFiltrosCubit` ganha `definirPrecoMin`/`definirPrecoMax` (no-op enquanto a finalidade é `null`, D-03) e `definirAreaMin`/`definirAreaMax` (sempre aplicam); a extensão `ValidacaoRascunho on FiltrosVitrine` expõe `erroFaixaPreco`/`erroFaixaArea`/`podeAplicar` — validação de FORMULÁRIO, nunca substituindo a revalidação do servidor simulado (Task 1).
- O sheet de filtros vira um `StatefulWidget` hospedando os 4 `TextEditingController`s; ganha a seção "Preço" (desabilitada com mensagem de ajuda sem finalidade; prefixo "R$ "; sufixo "/mês" só no Aluguel; texto limpo ao trocar de finalidade, D-13) e a seção "Área" (sempre habilitada, sufixo "m²"); erro inline aparece no campo Máximo de cada faixa e desabilita "Ver imóveis" enquanto a faixa estiver invertida (D-12); "Limpar" zera rascunho E os quatro controllers.

## Task Commits

Task 1 e Task 2 são `type="auto" tdd="true"`, cada uma executada em RED -> GREEN (sem REFACTOR necessário):

1. **Task 1 RED: testes falhando para faixas de preço/área e ordenação por aluguel** — `03fb061` (test)
2. **Task 1 GREEN: servidor simulado aplica faixas por finalidade/área, revalida como 400 e ordena por aluguel** — `36e4a7e` (feat)
3. **Task 2 RED: testes falhando para máscara, travas de preço e erro inline** — `f744131` (test)
4. **Task 2 GREEN: sheet ganha campos de preço/área mascarados ponta a ponta** — `91f5d33` (feat)

**Plan metadata:** commit pendente (este commit)

## Files Created/Modified

- `lib/data/datasources/parametros_consulta_imoveis.dart` - `preco_min`/`preco_max`/`area_min`/`area_max`, `inteiroNaoNegativoDoParametro`, validação de faixa invertida e preço sem finalidade
- `lib/data/datasources/imovel_mock_datasource.dart` - `_linhaCasaComFiltros` ganha predicados de preço (por finalidade) e área; `_comparadorDe` usa `preco_aluguel` sob Aluguel
- `lib/presentation/vitrine/widgets/mascara_numerica.dart` (novo) - `MascaraMilhares`, `inteiroDoTextoMascarado`, `textoMascaradoDe`
- `lib/presentation/vitrine/rascunho_filtros_cubit.dart` - `definirPrecoMin/Max`, `definirAreaMin/Max`, extension `ValidacaoRascunho`
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` - `StatefulWidget` com 4 controllers, seções Preço/Área, `_SecaoFaixa` privado reusado pelas duas
- Testes: `test/presentation/mascara_numerica_test.dart` (novo); `test/data/parametros_consulta_imoveis_test.dart`, `test/data/imovel_mock_datasource_test.dart`, `test/presentation/rascunho_filtros_cubit_test.dart`, `test/presentation/filtros_bottom_sheet_test.dart`, `test/presentation/vitrine_fluxo_test.dart` (estendidos)

## Decisions Made

- TDD explícito nas Tasks 1 e 2: RED confirmado via `flutter test` (erro de compilação para `inteiroNaoNegativoDoParametro` ainda inexistente na Task 1; asserções de filtro/ordenação/widget ainda não implementadas na Task 2) antes de cada GREEN; nenhum REFACTOR commit foi necessário em nenhuma das duas — o código já saiu limpo na primeira implementação.
- `inteiroNaoNegativoDoParametro` reusa o mesmo núcleo de `minimoDoParametro` (helper privado `_inteiroNaoNegativo` parametrizado pelo rótulo da mensagem de erro) em vez de duplicar a validação de "inteiro não-negativo" — mesma regra, dois nomes públicos para dois contextos semânticos diferentes (limiar "N ou mais" vs. faixa de preço/área).
- Os dois novos e2e de `vitrine_fluxo_test.dart` localizam os campos de preço/área pelo rótulo (`find.widgetWithText(TextField, 'Mínimo'/'Máximo')`), nunca por índice cru de `TextField` — a tela cheia da vitrine tem sua própria `SearchBar`, que internamente também é implementada como `TextField`, deslocando qualquer índice fixo usado no teste isolado do sheet (`filtros_bottom_sheet_test.dart`, que não tem `SearchBar` e pôde continuar usando índice cru).

## Deviations from Plan

None - plan executado exatamente como escrito. O único ajuste foi de arnês de teste (ver "Decisions Made" acima: localização por rótulo em vez de índice no e2e completo), não uma mudança na implementação sob teste.

## Issues Encountered

- `camposArea.every((c) => c.enabled)` falhou no `flutter analyze` porque `TextField.enabled` é `bool?` e `Iterable.every` exige um predicado `bool` não-nulo — corrigido para `c.enabled != false` antes do commit GREEN (nenhum impacto no comportamento sob teste, só no arnês).

## User Setup Required

None - nenhuma configuração de serviço externo necessária (mock-first, nenhum pacote novo, nenhum endpoint real criado nesta fase).

## Next Phase Readiness

- A semântica server-side de preço-por-finalidade e área já está completa no mock, incluindo a ordenação por `preco_aluguel` — os planos 03-04/03-05 (bairro/características) não dependem de nada aqui e podem prosseguir sem tocar em `_linhaCasaComFiltros`/`_comparadorDe` além de seus próprios predicados.
- `MascaraMilhares`/`_SecaoFaixa` ficam disponíveis como padrão reusável caso algum filtro futuro precise de campo numérico mascarado.
- Nenhum bloqueio conhecido para os planos seguintes da fase.

---
*Phase: 03-vitrine-filtros-server-side*
*Completed: 2026-09-30*

## Self-Check: PASSED

- All 2 new key-files (`lib/presentation/vitrine/widgets/mascara_numerica.dart`, `test/presentation/mascara_numerica_test.dart`) and all 9 modified key-files verified present on disk via `[ -f ]`.
- All 4 task commits (`03fb061`, `36e4a7e`, `f744131`, `91f5d33`) verified present via `git log --oneline --all`.
- Plan-level `<verification>` re-run: `flutter test` (338 passed), `flutter analyze` (no issues found).
- Task 1/2 `<acceptance_criteria>` re-verified via targeted grep/test commands — all pass, including the grep gate `! grep -nE "\.where\(|\.sort\(" lib/presentation/vitrine/rascunho_filtros_cubit.dart lib/presentation/vitrine/widgets/mascara_numerica.dart` (0 matches) and `pubspec.yaml` unchanged (no new dependency).
