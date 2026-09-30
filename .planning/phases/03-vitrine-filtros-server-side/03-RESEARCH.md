# Phase 3: Vitrine — Filtros Server-Side - Research

**Researched:** 2026-09-30
**Domain:** Flutter Clean Architecture — draft-then-apply filter modal, CSV/min-param query mapping over an in-memory mock "server", active-filter chips, pagination reset reuse
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Semântica dos filtros (regra do servidor, simulada pelo mock)
- **D-01:** Quartos, suítes e vagas significam **"N ou mais"**, com os params
  `quartos_min`, `suites_min` e `vagas_min` já presentes no contrato §5. Isso resolve,
  do lado do app, o item §7.1 do contrato e vira adendo para sign-off do E2.
  — **Reversibility:** costly — trocar para "exato" muda nomes de params no contrato,
  no mock, no mapeamento de params, nos rótulos dos chips ("2+") e nos testes.
- **D-02:** Finalidade é **inclusiva**. O filtro `finalidade=VENDA` traz `VENDA` e
  `VENDA_E_ALUGUEL`; `finalidade=ALUGUEL` traz `ALUGUEL` e `VENDA_E_ALUGUEL`. A UI só
  oferece Qualquer, Venda e Aluguel (FIL-01) e quem aplica a inclusão é o servidor/mock.
  Adendo ao contrato.
- **D-03:** `preco_min`/`preco_max` **dependem da finalidade**: com Venda comparam
  `preco_venda` e com Aluguel comparam `preco_aluguel`. **Sem finalidade escolhida, a
  faixa de preço fica desabilitada no modal**, para não misturar escalas (é o mesmo
  racional de F2/D-12). Com `finalidade=ALUGUEL`, a ordenação por preço passa a usar
  `preco_aluguel`, cumprindo o que F2/D-12 e o contrato §7.5 já previam. O mock
  implementa as duas regras. Adendo ao contrato.
- **D-04:** `caracteristicas` combina com **E**: o imóvel precisa ter todas as marcadas.
- **D-05:** `natureza` e `bairro` aceitam **multi-seleção com OU entre valores**
  (`natureza=CASA,APARTAMENTO` traz casa ou apartamento). Filtros diferentes combinam
  entre si com E. Adendo ao contrato: o §5 hoje trata os dois como singulares.
- **D-06:** Params multivalor (`natureza`, `bairro`, `caracteristicas`) usam **CSV numa
  única chave** (`?caracteristicas=Piscina,Quintal`). O mapeamento fica em
  `parametros_consulta_imoveis.dart`, isolado. Fica registrado um risco para o E2:
  vírgula dentro de um nome (bairro ou característica) exigiria escape ou identificador.
  — **Reversibility:** costly — mudar para params repetidos mexe no contrato, no
  mapeamento do app, no parser do mock e no filter backend do Django.

#### Modal de filtros (FIL-01..FIL-04)
- **D-07:** O modal é um **bottom sheet em tela cheia** (`showModalBottomSheet` com
  `isScrollControlled` e `useSafeArea`), com seções roláveis e **rodapé fixo com
  "Limpar" e "Ver imóveis"** (aplicar). É da mesma família do sheet de Ordenar (F2/D-10).
- **D-08:** O sheet edita um **rascunho local e só aplica no botão**. Mexer nos
  controles não dispara consulta. "Ver imóveis" aplica tudo de uma vez (uma consulta) e
  fechar o sheet sem aplicar descarta o rascunho. O rascunho vive num
  Cubit/estado próprio do sheet, imutável, e não no `VitrineState` aplicado.
- **D-09:** Faixas de preço e de área usam **dois campos numéricos, mín e máx**, com
  teclado numérico e máscara ("R$", "m²", e "/mês" para aluguel). Não é `RangeSlider`,
  porque não há endpoint de estatísticas que dê os limites do acervo.
- **D-10:** Quartos, suítes e vagas usam **`ChoiceChip` de seleção única**, com as
  opções "Qualquer", "1+", "2+", "3+" e "4+".
- **D-11:** Finalidade usa **`SegmentedButton`** (Qualquer | Venda | Aluguel, seleção
  única). Natureza usa **`FilterChip` multi** (Casa, Apartamento, Terreno, Lote).
- **D-12:** Mín maior que máx, ou valor inválido, mostra **erro inline (`errorText`) e
  desabilita "Ver imóveis"** até corrigir. É validação de formulário, não regra de
  negócio; o servidor revalida e responde 400 (o mock simula com `FormatException`,
  seguindo o padrão de `ordenacaoDoParametro`).
- **D-13:** Trocar a finalidade no modal **limpa a faixa de preço** do rascunho e troca
  máscara e sufixo.
- **D-14:** Trocar de cidade **mantém os filtros gerais** (finalidade, natureza, faixas,
  quartos/suítes/vagas, características) e **limpa os bairros**, que pertencem à cidade
  anterior. Busca e ordenação seguem o comportamento atual da F2.

#### Chips ativos (FIL-06)
- **D-15:** O botão **"Filtros" com contagem** ("Filtros (3)", usando `Badge` ou texto)
  fica **na mesma linha do botão "Ordenar"**, abaixo da `SearchBar` (espaço reservado
  em F2/D-10). Os chips ativos ficam numa **linha horizontal rolável logo abaixo**, que
  só aparece quando há filtro ativo.
- **D-16:** Os chips são **um por filtro, com texto resumido**, por exemplo "Venda",
  "Casa, Apto", "R$ 200 mil–500 mil", "2+ quartos", "Cambuí +1" e "Piscina +2". A
  contagem do botão Filtros é o número de filtros ativos, não de valores.
- **D-17:** O **"x" do chip remove aquele filtro e reconsulta na hora**, sem passar pelo
  "Ver imóveis", reiniciando a lista pelo mecanismo de F2/D-13. **Tocar no corpo do chip
  abre o sheet** com o rascunho inicializado a partir dos filtros aplicados.
- **D-18:** "Limpar filtros" existe em dois lugares: como **`ActionChip` no fim da linha
  de chips**, que aplica na hora, e como **"Limpar" no rodapé do sheet**, que zera só o
  rascunho (o visitante ainda precisa aplicar). Nenhum dos dois mexe na busca por texto
  nem na ordenação.
- **D-19:** Qualquer mudança de filtros aplicados (aplicar, remover chip, limpar) usa o
  **mesmo caminho de reinício da F2/D-13**: descarta o cursor, limpa os itens, mostra
  loading, volta o scroll ao topo e descarta respostas atrasadas por id de requisição.
  Resultado: zero cards duplicados ou embaralhados (critério 4).

#### Fonte das opções e estados (FIL-04, FIL-05)
- **D-20:** As listas de opções de **bairros e características vêm de endpoints
  próprios**, adicionados ao contrato como adendo:
  `GET /api/publico/caracteristicas/` (a partir do model `Caracteristica`) e
  `GET /api/publico/bairros/?cidade=<nome-uf>` (bairros com imóvel publicado na cidade).
  **Nesta fase uma DataSource mock responde a partir da fixture**; os endpoints reais
  entram na Fase 4 junto com `/imoveis`. O app nunca mantém lista fixa de opções.
  — **Reversibility:** costly — são dois endpoints novos no contrato com o E2; mudar
  a forma depois mexe no contrato, no mock, nos models e no Django.
- **D-21:** O bairro é escolhido numa **lista de `CheckboxListTile`** dentro de uma
  seção expansível do sheet, com um **campo que filtra só a lista de opções visível**
  (nunca o acervo). É multi-seleção (D-05).
- **D-22:** Filtros sem resultado ganham um **estado próprio**: "Nenhum imóvel com esses
  filtros", com a ação "Limpar filtros". Ele é distinto de `vazioNaCidade` e de
  `semResultado` da busca (F2/D-09). Com busca **e** filtros ativos, a mensagem cita os
  dois e oferece limpar ambos.
- **D-23:** Os filtros **não são persistidos**: valem só durante a sessão, como a busca
  e a ordenação. Só a cidade é guardada (F1/D-15).
- **D-24:** A fixture/mock precisa de **variedade suficiente** para exercitar cada
  filtro de forma determinística: todas as naturezas e finalidades, faixas de
  preço e área, 0 a 4+ quartos, suítes e vagas, vários bairros por cidade e
  combinações de características, incluindo pelo menos uma combinação que zera o
  resultado (D-22). Nada aleatório (F2/D-15).

### Claude's Discretion

- Forma do filtro no domínio (ex.: `FiltrosVitrine` freezed dentro de
  `ConsultaImoveis`, com `toQueryParameters` no `data/`, conforme o CLAUDE.md) e como o
  rascunho do sheet é modelado (Cubit próprio ou estado local imutável).
- Formato exato dos valores de faixa enviados (inteiro em reais ou decimal string) e
  como a máscara converte, desde que a conversão fique fora do widget.
- Loading e erro ao carregar as opções de bairros e características dentro do sheet
  (spinner na seção e retry), e se as opções são carregadas ao abrir o sheet ou
  pré-carregadas com a cidade.
- Layout fino do sheet (ordem das seções, seções expansíveis), rótulos exatos dos
  chips e abreviações ("Apto", "mil"), seguindo Material 3, a paleta verde/branco e o
  01-UI-SPEC.
- Nomes e forma dos endpoints de opções no adendo (paginação ou não, formato
  `{id, nome}` versus string), desde que registrados no contrato §9 (ou numa nova §10)
  para o E2.

### Deferred Ideas (OUT OF SCOPE)

- Prévia "Ver N imóveis" no botão aplicar: v2 (API-05), depende de contagem barata.
- Endpoints reais `/api/publico/caracteristicas/` e `/api/publico/bairros/`: Fase 4,
  junto com `/imoveis`.
- Persistir os filtros entre aberturas: descartado (D-23); reavaliar se virar pedido
  de usuário.
- `RangeSlider` para preço e área: descartado por falta de limites vindos do servidor;
  reavaliar se surgir um endpoint de estatísticas.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FIL-01 | Filtro por finalidade (venda / aluguel) | Pattern 1 (`FiltrosVitrine` freezed), Pattern 3 (`SegmentedButton` de 3 segmentos), Pitfall 1 |
| FIL-02 | Filtro por natureza (casa, apartamento, terreno, lote) | Pattern 1, Pattern 4 (`FilterChip` multi + CSV), D-05/D-06 adendo |
| FIL-03 | Filtros por faixa de preço, quartos, suítes e vagas | Pattern 1, Pattern 5 (campos mín/máx com validação inline), Pattern 6 (`ChoiceChip` "N+"), Pitfall 3 |
| FIL-04 | Filtros por bairro, faixa de área e características | Pattern 1, Pattern 7 (`OpcoesFiltroDataSource` mock trocável), Pattern 8 (lista filtrável de `CheckboxListTile`) |
| FIL-05 | Filtragem resolvida no servidor — o app nunca filtra localmente | `ImovelMockDataSource` estendido (Code Example 2), Architectural Responsibility Map |
| FIL-06 | Chips ativos, aplicar/limpar, reset de paginação sem duplicar/embaralhar | Pattern 2 (reuso do reinício F2/D-13), Pattern 9 (chips resumidos), Pitfall 2 |
</phase_requirements>

## Summary

Esta fase não introduz nenhuma tecnologia nova — é inteiramente construída sobre o que as Fases
1 e 2 já cravaram: `freezed` para modelar estado imutável, `flutter_bloc`/Cubit para orquestrar,
um `DataSource` mock que filtra sobre mapas de wire antes de parsear, e o mecanismo de reinício
de lista com token de versão (F2/D-13) que já resolve o critério de sucesso 4 ("sem cards
duplicados ou embaralhados") — ele só precisa ser **reusado**, não reinventado, para cada
mudança de filtro. A superfície nova é inteiramente app-local: um objeto de filtros imutável
(`FiltrosVitrine`), um mapeamento determinístico desse objeto para query params (extensão direta
de `parametrosDaConsulta`), um bottom sheet em tela cheia com rascunho próprio (D-08), uma linha
de chips resumidos, e a extensão do `ImovelMockDataSource` para aplicar 8 filtros adicionais
sobre as mesmas linhas de wire que ele já filtra por cidade e busca.

A parte que exige mais cuidado de design não é nenhum widget Material isolado (todos —
`SegmentedButton`, `FilterChip`/`ChoiceChip`, `Badge`, `CheckboxListTile`, `ExpansionTile` — são
widgets estáveis de `material.dart`, sem pacote extra), mas a modelagem do **rascunho** do sheet
(D-08): ele precisa ser um estado imutável próprio, inicializável a partir dos filtros já
aplicados (D-17, toque no corpo do chip), capaz de refletir reativamente a regra D-13 (trocar
finalidade limpa a faixa de preço do rascunho) sem nunca escrever no `VitrineState` até "Ver
imóveis" ser tocado. A segunda área de cuidado é o mapeamento de query params: `quartos_min` /
`suites_min` / `vagas_min` (D-01, "N ou mais"), `natureza`/`bairro`/`caracteristicas` em CSV numa
única chave (D-06) e `preco_min`/`preco_max` que trocam de campo-base (`preco_venda` vs.
`preco_aluguel`) conforme `finalidade` (D-03) — toda essa semântica vive isolada em
`parametros_consulta_imoveis.dart` e no `ImovelMockDataSource`, nunca em `presentation/`,
continuando o padrão já estabelecido na Fase 2.

**Primary recommendation:** Modelar `FiltrosVitrine` como uma classe `freezed` própria (campo
`filtros` em `ConsultaImoveis`, ao lado de `busca`/`ordenacao`), com um método
`Map<String,String> paraQueryParameters()` colocado em `data/` (não em `domain/`, para não vazar
formato de wire) — reaproveitando exatamente o padrão já usado por `parametrosDaConsulta`. Para
o rascunho do sheet, usar um `Cubit<FiltrosVitrine>` de vida curta (criado com `BlocProvider` no
próprio `showModalBottomSheet`, descartado ao fechar) em vez de `ValueNotifier`/`StatefulWidget`
cru — mantém a mesma disciplina de imutabilidade e testabilidade (`bloc_test`) que o resto do
projeto usa, evita re-inventar notificação de mudança para ~10 campos de filtro, e mapeia
diretamente para a extensão de `VitrineCubit` que recebe o rascunho finalizado em `aplicarFiltros
(FiltrosVitrine)`.

## Architectural Responsibility Map

> Clean Architecture mobile-only (sem tiers web/CDN). Tiers: **Presentation** (Widgets/Cubit),
> **Domain** (Entities/UseCases/interfaces), **Data** (Repositories/DataSources — mock nesta fase),
> **Django API** (fora de escopo nesta fase — Fase 4 implementa os endpoints reais e os adendos).

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Rascunho do modal de filtros (edição antes de aplicar) | Presentation (Cubit de vida curta do sheet) | — | É estado de UI efêmero (D-08), nunca toca `domain/` até "Ver imóveis" |
| Validação inline de faixas (mín > máx) | Presentation (Cubit do sheet) | — | Validação de formulário (D-12), não regra de negócio — o servidor/mock revalida de qualquer forma |
| Execução dos 8 filtros sobre o acervo | Data (`ImovelMockDataSource` hoje) | Django API (Fase 4) | "Nada é recalculado no aparelho" — mesma regra já aplicada a busca/ordenação na F2 |
| Mapeamento `FiltrosVitrine` → query params (CSV, `_min`, preço por finalidade) | Data (`parametros_consulta_imoveis.dart`) | — | Formato de wire é exclusivo de `data/`; `domain/`/`presentation/` só manipulam o objeto tipado |
| Fonte das opções de bairro/características | Data (`OpcoesFiltroMockDataSource` nesta fase) | Django API (Fase 4, dois endpoints novos) | App nunca mantém lista fixa (D-20) — mesmo racional da lista de cidades na F2 (D-16) |
| Reinício de paginação ao mudar filtro/ordenação/busca | Presentation (`VitrineCubit`, token de versão) | — | Mecanismo já existe (F2/D-13); esta fase só precisa chamá-lo a partir de mais gatilhos |
| Chips ativos e contagem do botão Filtros | Presentation (deriva de `FiltrosVitrine` aplicado) | — | Puramente apresentacional — nenhuma lógica de negócio, só resumo textual |

## Standard Stack

### Core

Nenhuma dependência nova. Todos os widgets exigidos pelas decisões (D-07, D-09..D-11, D-15,
D-18, D-21) já estão em `flutter/material.dart` da SDK Flutter instalada
(`environment.sdk: ^3.13.4` no `pubspec.yaml`), a mesma versão usada nas Fases 1/2:

| Widget/API | Já usado desde | Papel nesta fase |
|------------|-----------------|-------------------|
| `showModalBottomSheet` (`isScrollControlled`, `useSafeArea`) | F2 (`ordenacao_bottom_sheet.dart`, sem `useSafeArea`) | Base do sheet de filtros (D-07), agora com `useSafeArea: true` para o rodapé fixo não colidir com a barra de gestos/teclado |
| `SegmentedButton<T>` | Novo nesta fase | Finalidade (D-11) — `selected` é um `Set<T>`; ver Pitfall 1 sobre seleção vazia |
| `FilterChip` / `ChoiceChip` | Novo nesta fase | Natureza multi (D-11) / quartos·suítes·vagas único (D-10) |
| `CheckboxListTile` dentro de `ExpansionTile` | Novo nesta fase | Lista de bairros com campo de filtro local (D-21) |
| `Badge.count` [ASSUMED — ver Assumptions Log A4] | Novo nesta fase | Contagem no botão "Filtros (N)" (D-15) |
| `TextInputFormatter` (custom, `flutter/services.dart`) | Novo nesta fase | Máscara de moeda/área nos campos mín/máx (D-09) — ver Don't Hand-Roll |
| `RadioGroup<T>` (já usado no sheet de Ordenar) | F2 | Referência de padrão para o `ChoiceChip` de seleção única, se um `RadioGroup` fizer mais sentido que gerenciar seleção manual |

`freezed`/`freezed_annotation` (^4.0.1/^3.1.0), `json_serializable`/`json_annotation`
(^6.14.1/^4.12.0), `flutter_bloc` (^9.1.1), `get_it`/`injectable` (^9.3.0/^3.0.0), `intl`
(^0.20.3) — todos já instalados desde as Fases 1/2, reaproveitados sem mudança de versão.

### Supporting

Nenhuma biblioteca de suporte nova é necessária. Especificamente **evitada** por decisão de
design (ver Don't Hand-Roll): pacotes de máscara de moeda (`currency_text_input_formatter`,
`mask_text_input_formatter`, `flutter_multi_formatter`) — o projeto já hand-rola um `Debouncer`
(F2) em vez de `easy_debounce` pela mesma razão (CLAUDE.md "Alternatives Considered"); uma
máscara de moeda de ~2 campos é do mesmo porte de simplicidade.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `Cubit<FiltrosVitrine>` de vida curta para o rascunho do sheet | `ValueNotifier<FiltrosVitrine>` + `ValueListenableBuilder` | Mais leve (zero boilerplate de `Cubit`), mas quebra a convenção de estado/testes do projeto (`bloc_test`) só para este widget — o time já paga o custo do `flutter_bloc` em todo o resto do app; discrição do CONTEXT permite qualquer um dos dois |
| `TextInputFormatter` custom com `intl.NumberFormat` | `currency_text_input_formatter` / `mask_text_input_formatter` | Pacote resolveria em menos código, mas nenhum está no CLAUDE.md (que já rejeita dependências redundantes, ex. `equatable` sobre `freezed`); ~15-25 linhas de formatter hand-rolado é o mesmo porte do `Debouncer` já hand-rolado na F2 |
| CSV numa única chave (D-06, já travado) | Múltiplos params repetidos (`?bairro=A&bairro=B`) | Já descartado pela decisão travada — custoso reverter; citado aqui só para registrar que `Uri(queryParameters: {...})` do `dart:core` já serializa `List<String>` como params repetidos automaticamente, então o CSV precisa ser montado manualmente com `.join(',')`, não delegado ao `Uri` |

**Installation:**
```bash
# Nenhuma dependência nova — pubspec.yaml não muda nesta fase.
```

**Version verification:** Não aplicável — nenhum pacote novo. As versões já instaladas
(`freezed ^4.0.1`, `flutter_bloc ^9.1.1`, `intl ^0.20.3`, SDK `^3.13.4`) seguem as mesmas do
`pubspec.yaml` atual, verificadas em sessões anteriores (Fases 1/2) e ainda vigentes no lockfile
do projeto — não revalidadas nesta sessão por não haver mudança de dependência a auditar.

## Package Legitimacy Audit

> Esta fase **não instala pacotes externos** — toda a superfície nova é Flutter SDK (Material
> widgets built-in) + código do próprio app. O gate de legitimidade de pacotes (`gsd_run query
> package-legitimacy check`) não se aplica: não há nome de pacote novo para auditar.

**Packages removed due to [SLOP] verdict:** none — nenhum pacote novo proposto.
**Packages flagged as suspicious [SUS]:** none.

## Architecture Patterns

### System Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│ VitrineScreen (Presentation)                                              │
│  SearchBar ──> Row["Ordenar: X"  "Filtros (N)" Badge] ──> ChipsAtivos     │
│                                                    │ toque "Filtros"       │
│                                                    ▼                       │
│                                    mostrarFiltrosBottomSheet(contexto,     │
│                                      aplicados: state.filtros)             │
└───────────────┬─────────────────────────────┬────────────────────────────┘
                 │ eventos (aplicarFiltros,    │ abre sheet com
                 │ removerFiltro, limparFiltros)│ BlocProvider<RascunhoFiltrosCubit>
                 ▼                              ▼
┌────────────────────────────────┐  ┌───────────────────────────────────────┐
│ VitrineCubit (Presentation)     │  │ FiltrosBottomSheet (Presentation)      │
│  filtros: FiltrosVitrine        │  │  RascunhoFiltrosCubit (vida curta)     │
│  reusa _aplicarConsulta (D-19)  │  │  seções: Finalidade(SegmentedButton)   │
│  == F2/D-13 (token de versão)   │  │  Natureza(FilterChip) Preço(TextField+ │
└───────────────┬────────────────┘  │  TextInputFormatter) Quartos/Suítes/   │
                 │ chama             │  Vagas(ChoiceChip) Bairro(Checkbox     │
                 ▼                   │  ListTile+campo filtro) Característi-  │
┌────────────────────────────────┐  │  cas(FilterChip multi)                 │
│ BuscarImoveisUseCase (Domain)   │  │  rodapé fixo: Limpar | Ver imóveis     │
│ ──> ImovelRepository (interface)│  └────────────────┬────────────────────┬─┘
└───────────────┬────────────────┘                    │ "Ver imóveis"      │ onOpen
                 │ impl                                ▼                    │ (D-20)
                 ▼                          VitrineCubit.aplicarFiltros(    │
┌────────────────────────────────────────┐   rascunho.filtros)              │
│ ImovelRepositoryImpl (Data)              │                                 │
│ ──> ImovelMockDataSource (Data, D-14)    │◄────────────────────────────────┘
│   filtra cidade+busca+ordenacao (F2)     │        ObterBairrosUseCase /
│   + finalidade+natureza+preço+quartos/   │        ObterCaracteristicasUseCase
│   suítes/vagas+bairro+área+caracts (F3)  │        (Domain) ──> OpcoesFiltro
│   sobre mapas de wire, ANTES do parse    │        RepositoryImpl (Data) ──>
│   [Fase 4: troca por DataSource real +   │        OpcoesFiltroMockDataSource
│    endpoints GET /imoveis, /bairros,     │        (Data, D-20 — fixture)
│    /caracteristicas — fora de escopo]    │        [Fase 4: troca por Dio]
└──────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── domain/
│   ├── entities/
│   │   ├── filtros_vitrine.dart          # NOVO — classe imutável (D-01..D-06)
│   │   └── consulta_imoveis.dart         # ALTERADO — ganha campo `filtros`
│   ├── repositories/
│   │   └── opcoes_filtro_repository.dart # NOVO — interface (bairros/características)
│   └── usecases/
│       ├── obter_bairros_usecase.dart       # NOVO
│       └── obter_caracteristicas_usecase.dart # NOVO
├── data/
│   ├── datasources/
│   │   ├── parametros_consulta_imoveis.dart   # ALTERADO — mapeia FiltrosVitrine (D-01..D-06)
│   │   ├── imovel_mock_datasource.dart        # ALTERADO — aplica os 8 filtros (D-01..D-05)
│   │   └── opcoes_filtro_mock_datasource.dart # NOVO — bairros/características da fixture
│   ├── repositories/
│   │   └── opcoes_filtro_repository_impl.dart # NOVO
│   └── mocks/
│       └── imoveis_fixture.dart                # ALTERADO — variedade (D-24)
└── presentation/
    └── vitrine/
        ├── vitrine_cubit.dart              # ALTERADO — aplicarFiltros/removerFiltro/limparFiltros
        ├── vitrine_state.dart              # ALTERADO — campo `filtros`, novo ConteudoVitrine variant (D-22)
        ├── vitrine_screen.dart             # ALTERADO — botão Filtros + linha de chips
        └── widgets/
            ├── filtros_bottom_sheet.dart       # NOVO (D-07..D-14, D-21)
            ├── rascunho_filtros_cubit.dart      # NOVO — estado do sheet (D-08)
            ├── rascunho_filtros_state.dart      # NOVO
            ├── chip_filtro_ativo.dart           # NOVO — resumo textual por filtro (D-16)
            └── mascara_numerica.dart            # NOVO — TextInputFormatter de moeda/área (D-09)
```

### Pattern 1: `FiltrosVitrine` como objeto de domínio imutável, mapeamento isolado em `data/`
**What:** Uma classe `freezed` `FiltrosVitrine` em `domain/entities/`, campo novo em
`ConsultaImoveis`, com TODOS os valores já normalizados (ex. `Set<NaturezaImovel>`, não strings
soltas) — o mapeamento para o formato de wire exato do contrato (CSV, `_min`, nomes de campo)
fica inteiramente em `data/parametros_consulta_imoveis.dart`, nunca no objeto de domínio.
**When to use:** Sempre — é a extensão direta do padrão já usado por `ConsultaImoveis`/
`parametrosDaConsulta` na Fase 2 (ver `lib/domain/entities/consulta_imoveis.dart:7-17` e
`lib/data/datasources/parametros_consulta_imoveis.dart:15-25`, ambos lidos nesta sessão).
**Example:**
```dart
// domain/entities/filtros_vitrine.dart — campos tipados, sem noção de wire format
@freezed
abstract class FiltrosVitrine with _$FiltrosVitrine {
  const factory FiltrosVitrine({
    FinalidadeFiltro? finalidade,           // null = "Qualquer" (D-11)
    @Default(<NaturezaImovel>{}) Set<NaturezaImovel> natureza, // OU entre valores (D-05)
    String? precoMin,
    String? precoMax,
    int? quartosMin,                        // "N ou mais" (D-01)
    int? suitesMin,
    int? vagasMin,
    @Default(<String>{}) Set<String> bairros,       // OU entre valores (D-05)
    String? areaMin,
    String? areaMax,
    @Default(<String>{}) Set<String> caracteristicas, // E entre valores (D-04)
  }) = _FiltrosVitrine;

  const FiltrosVitrine._();

  /// Número de filtros ATIVOS (não de valores) — contagem do botão (D-16).
  int get quantidadeAtiva => [
    finalidade != null,
    natureza.isNotEmpty,
    precoMin != null || precoMax != null,
    quartosMin != null,
    suitesMin != null,
    vagasMin != null,
    bairros.isNotEmpty,
    areaMin != null || areaMax != null,
    caracteristicas.isNotEmpty,
  ].where((ativo) => ativo).length;
}

// data/datasources/parametros_consulta_imoveis.dart — único lugar que conhece o wire format
Map<String, String> parametrosDaConsulta(ConsultaImoveis consulta) {
  final params = <String, String>{
    'cidade': '${consulta.cidade.nome}-${consulta.cidade.uf}',
    'ordenacao': consulta.ordenacao.valorApi,
  };
  // ... busca já existente ...
  final f = consulta.filtros;
  if (f.finalidade != null) params['finalidade'] = f.finalidade!.valorApi;
  if (f.natureza.isNotEmpty) {
    params['natureza'] = f.natureza.map((n) => n.valorApi).join(','); // D-06 CSV
  }
  if (f.precoMin != null) params['preco_min'] = f.precoMin!;
  if (f.precoMax != null) params['preco_max'] = f.precoMax!;
  if (f.quartosMin != null) params['quartos_min'] = '${f.quartosMin}';
  if (f.suitesMin != null) params['suites_min'] = '${f.suitesMin}';
  if (f.vagasMin != null) params['vagas_min'] = '${f.vagasMin}';
  if (f.bairros.isNotEmpty) params['bairro'] = f.bairros.join(','); // D-06 CSV
  if (f.areaMin != null) params['area_min'] = f.areaMin!;
  if (f.areaMax != null) params['area_max'] = f.areaMax!;
  if (f.caracteristicas.isNotEmpty) {
    params['caracteristicas'] = f.caracteristicas.join(',');
  }
  return params;
}
```
Fonte: extensão direta do código real lido nesta sessão (`lib/domain/entities/consulta_imoveis.dart`,
`lib/data/datasources/parametros_consulta_imoveis.dart`) — não de doc externa.

### Pattern 2: Reusar o reinício de paginação da F2 (D-19), nunca duplicá-lo
**What:** `VitrineCubit._aplicarConsulta` (já existe, `lib/presentation/vitrine/vitrine_cubit.dart:193-242`)
já incrementa o token de versão, emite um único `carregando`, descarta respostas obsoletas e
busca a primeira página. `aplicarFiltros`, `removerFiltro` e `limparFiltros` (novos métodos) só
precisam montar o novo `FiltrosVitrine` e delegar a ele — nenhum dos três reimplementa reinício.
**When to use:** Toda mudança de filtro aplicado (D-19) — exatamente a mesma garantia que já
resolve VIT-05 critério 4 na F2 para busca/ordenação.
**Example:**
```dart
// vitrine_cubit.dart — extensão, não reescrita, de _aplicarConsulta
Future<void> aplicarFiltros(FiltrosVitrine filtros) => _aplicarConsulta(
  ordenacao: state.ordenacao,
  termoBusca: state.termoBusca,
  filtros: filtros,
);

Future<void> removerFiltro(FiltroRemovivel qual) => aplicarFiltros(
  state.filtros.removendo(qual), // método puro em FiltrosVitrine, fora do widget
);

Future<void> limparFiltros() => aplicarFiltros(const FiltrosVitrine());

// _aplicarConsulta ganha o parâmetro `filtros` (default: state.filtros) e passa
// adiante para ConsultaImoveis — o corpo do método (token de versão, emit único
// de carregando, switch Success/Failure) não muda.
```

### Pattern 3: `SegmentedButton` de 3 segmentos para "Qualquer | Venda | Aluguel" (D-11)
**What:** `SegmentedButton<FinalidadeFiltro>` com **três** `ButtonSegment`s, incluindo um
segmento explícito para "Qualquer" — não usar dois segmentos (Venda/Aluguel) com
`emptySelectionAllowed: true` para representar "Qualquer" como seleção vazia.
**When to use:** Sempre que D-11 pedir "Qualquer" como opção do `SegmentedButton` — ver Pitfall 1.
**Example:**
```dart
// Source: api.flutter.dev/flutter/material/SegmentedButton-class.html (fetched nesta sessão via
// WebFetch e cross-checado via WebSearch independente — `gsd_run query classify-confidence
// --provider websearch --verified` = MEDIUM para esta claim)
// "selected: The set of ButtonSegment.values that indicate which segments are selected."
// "emptySelectionAllowed: Determines if having no selected segments is allowed." (default false)
enum FinalidadeFiltro { qualquer, venda, aluguel }

SegmentedButton<FinalidadeFiltro>(
  segments: const [
    ButtonSegment(value: FinalidadeFiltro.qualquer, label: Text('Qualquer')),
    ButtonSegment(value: FinalidadeFiltro.venda, label: Text('Venda')),
    ButtonSegment(value: FinalidadeFiltro.aluguel, label: Text('Aluguel')),
  ],
  selected: {rascunho.finalidadeUi}, // SEMPRE exatamente 1 elemento — default single-select
  onSelectionChanged: (novo) => cubitDoRascunho.definirFinalidade(novo.first),
)
```

### Pattern 4: `FilterChip` multi-seleção com mapeamento para CSV (D-11, D-06)
**What:** Cada `FilterChip` alterna presença num `Set<NaturezaImovel>` do rascunho; o join CSV
só acontece em `data/` (Pattern 1), nunca no widget.
**Example:**
```dart
Wrap(
  spacing: 8,
  children: [
    for (final natureza in NaturezaImovel.values)
      FilterChip(
        label: Text(rotuloNatureza(natureza)),
        selected: rascunho.natureza.contains(natureza),
        onSelected: (marcado) => cubitDoRascunho.alternarNatureza(natureza, marcado),
      ),
  ],
)
```

### Pattern 5: Campos mín/máx com validação inline e `TextInputFormatter` próprio (D-09, D-12)
**What:** Dois `TextField`s (`errorText` condicional), com um `TextInputFormatter` hand-rolado
que aplica `intl.NumberFormat` a cada `onChanged` — sem depender de pacote de máscara externo
(ver Don't Hand-Roll). O valor "cru" (sem formatação) é o que vai para `FiltrosVitrine`; a
formatação vive só na apresentação do campo, espelhando a disciplina já usada por
`apresentacao_imovel.dart` (conversão fora do widget).
**Example:**
```dart
// mascara_numerica.dart — formatter simples, mesmo porte do Debouncer hand-rolado na F2
class MascaraMoeda extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return newValue.copyWith(text: '');
    final valor = int.parse(digitos) / 100;
    final formatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }
}

// Validação inline (D-12) — erro de formulário, nunca regra de negócio
String? _erroFaixa(String? minStr, String? maxStr) {
  final min = double.tryParse(minStr ?? '');
  final max = double.tryParse(maxStr ?? '');
  if (min != null && max != null && min > max) {
    return 'Valor mínimo maior que o máximo';
  }
  return null;
}
```

### Pattern 6: `ChoiceChip` "N ou mais" para quartos/suítes/vagas (D-01, D-10)
**What:** Seleção única entre "Qualquer", "1+", "2+", "3+", "4+"; o valor enviado ao servidor
(`quartos_min`) é `null` para "Qualquer" ou o número (1..4) para as demais — nunca "exatamente N".
**Example:**
```dart
Wrap(
  spacing: 8,
  children: [
    for (final opcao in [null, 1, 2, 3, 4])
      ChoiceChip(
        label: Text(opcao == null ? 'Qualquer' : '$opcao+'),
        selected: rascunho.quartosMin == opcao,
        onSelected: (_) => cubitDoRascunho.definirQuartosMin(opcao),
      ),
  ],
)
```

### Pattern 7: Fronteira trocável para opções de bairro/características (D-20, espelha API-04)
**What:** Mesma disciplina de `ImovelDataSource`/`ImovelRepository` (interface em `domain/`,
implementação mock em `data/`, `@LazySingleton(as: ...)` via `injectable`) para um novo par
`OpcoesFiltroRepository`/`OpcoesFiltroMockDataSource` — trocável por uma implementação Dio real
na Fase 4 sem tocar `domain/`/`presentation/`.
**When to use:** Sempre — D-20 exige que o app "nunca mantenha lista fixa de opções", e a Fase 2
já provou esse padrão funcionando para `ImovelDataSource`.
**Example:**
```dart
// domain/repositories/opcoes_filtro_repository.dart
abstract class OpcoesFiltroRepository {
  Future<Result<List<String>>> bairrosPorCidade(Cidade cidade);
  Future<Result<List<String>>> caracteristicas();
}

// data/datasources/opcoes_filtro_mock_datasource.dart
@LazySingleton(as: OpcoesFiltroDataSource)
class OpcoesFiltroMockDataSource implements OpcoesFiltroDataSource {
  // Deriva as opções das MESMAS linhas de `imoveis_fixture.dart` (nunca uma lista
  // fixa paralela — D-20 exige fonte única), com a mesma latência artificial
  // do `ImovelMockDataSource` para exercitar loading/retry no sheet.
}
```

### Pattern 8: Lista de bairros filtrável localmente (D-21) — filtra as OPÇÕES, nunca o acervo
**What:** Um `TextField` dentro da seção expansível de bairros filtra a **lista de opções já
carregada** via `normalizarTexto` (reusa `core/texto_normalizado.dart`, já usado por busca e
`Cidade.chaveNatural`) — nunca dispara uma nova consulta ao acervo.
**When to use:** D-21. Distinção importante: isto é filtro-de-lista-de-opções (client-side,
inofensivo), diferente da regra geral do projeto que proíbe filtrar o ACERVO no app.
**Example:**
```dart
final opcoesVisiveis = todasAsOpcoes.where(
  (bairro) => normalizarTexto(bairro).contains(normalizarTexto(termoFiltro)),
).toList();
```

### Pattern 9: Chips resumidos e "x" com efeito imediato (D-16, D-17)
**What:** Cada chip deriva seu texto de `FiltrosVitrine` aplicado (nunca do rascunho); o "x"
chama `VitrineCubit.removerFiltro` diretamente (reconsulta imediata, D-17), o corpo do chip abre
o sheet com `rascunho inicial = FiltrosVitrine aplicado` (não um rascunho vazio).
**Example:**
```dart
String rotuloFaixaPreco(String? min, String? max) {
  if (min == null && max == null) return '';
  if (min != null && max == null) return 'A partir de ${formatarPrecoBrl(min)}';
  if (min == null && max != null) return 'Até ${formatarPrecoBrl(max!)}';
  return '${formatarPrecoBrl(min!)}–${formatarPrecoBrl(max!)}';
}

String rotuloMultiSelecao(Set<String> valores, String Function(String) rotulo) {
  if (valores.isEmpty) return '';
  final primeiro = rotulo(valores.first);
  final resto = valores.length - 1;
  return resto == 0 ? primeiro : '$primeiro +$resto';
}
```

### Anti-Patterns to Avoid
- **Filtrar em `presentation/` "só para mostrar rápido" enquanto a consulta real corre:** viola
  FIL-05 e a regra não-negociável do projeto (nada de filtro/regra no app) — mesmo um filtro
  "temporário" client-side, ainda que depois substituído pela resposta do servidor, já conta
  como regra de negócio decidida no celular.
- **`emptySelectionAllowed: true` + 2 segmentos para simular "Qualquer" no `SegmentedButton` de
  finalidade:** funciona, mas contraria D-11 (que já especifica 3 segmentos incluindo
  "Qualquer") e complica a leitura do valor selecionado (`Set` vazio vs. `Set` de 1) sem
  necessidade — ver Pattern 3.
- **CSV montado no widget (`.join(',')` dentro do `FilterChip`/`onSelected`):** quebra a
  separação já estabelecida (Pattern 1) — o `Set<T>` tipado é o que cruza `presentation/` →
  `domain/`; o CSV só nasce em `data/parametros_consulta_imoveis.dart`.
- **Reimplementar o token de versão / reinício de lista dentro de `aplicarFiltros`:** já existe
  em `_aplicarConsulta` (F2/D-13) — duplicar essa lógica é exatamente o tipo de divergência
  silenciosa que os Pitfalls desta e da fase anterior alertam contra.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Formatação de moeda/área nos campos mín/máx (D-09) | Um parser de string manual com `RegExp` ad-hoc espalhado pela UI | `TextInputFormatter` próprio (Pattern 5) usando `intl.NumberFormat` (já no stack) | `intl` já resolve a formatação `pt_BR`; só o *encaixe* como `TextInputFormatter` é código novo — pequeno e único, mesmo porte do `Debouncer` hand-rolado na F2 |
| Notificação de mudança do rascunho do sheet (~10 campos) | `ChangeNotifier` customizado ou `setState` espalhado em múltiplos `StatefulWidget`s aninhados | `Cubit<FiltrosVitrine>` de vida curta (mesma disciplina de `bloc_test` do resto do app) | Projeto já mandata `flutter_bloc`; um segundo padrão de estado só para o sheet duplica conceitos sem necessidade |
| Normalização de texto para o campo-filtro de bairros (D-21) | Uma segunda função de normalização de acento/caixa | `core/texto_normalizado.dart` (já existe, já usada por busca e `Cidade.chaveNatural`) | Evita exatamente o risco de divergência que o próprio código já documenta (`normalizarTexto` comment: "evitando que as duas implementações divirjam silenciosamente") |
| Contagem de filtros ativos para o `Badge` (D-15) | Contar manualmente em cada call site da UI | Getter `FiltrosVitrine.quantidadeAtiva` (Pattern 1) — uma fonte única | Evita contagens divergentes entre o texto do botão e os chips renderizados |

**Key insight:** Esta fase não tem nenhum "problema deceptively complex" que justifique um
pacote novo — toda a complexidade real é de **modelagem de estado e mapeamento de contrato**
(quantos campos, como combinam, como viram query params), que é trabalho de domínio do projeto,
não algo que uma lib resolveria melhor. O único candidato a pacote (máscara de moeda) já tem
precedente explícito de rejeição no CLAUDE.md para o mesmo tipo de trade-off (`easy_debounce`).

## Common Pitfalls

### Pitfall 1: `SegmentedButton` lança assert se `selected` ficar vazio sem `emptySelectionAllowed`
**What goes wrong:** Se "Qualquer" for modelado como ausência de seleção (Set vazio) em vez de
um `ButtonSegment` próprio, o widget quebra em runtime (`selected.isNotEmpty` é exigido por
padrão) assim que o rascunho inicializar sem finalidade.
**Why it happens:** A API do `SegmentedButton` (verificado via `api.flutter.dev` nesta sessão)
tem seleção única não-vazia como comportamento padrão — `emptySelectionAllowed` existe
justamente para o caso contrário, mas não é o que D-11 pede.
**How to avoid:** Seguir Pattern 3 — "Qualquer" é um `ButtonSegment<FinalidadeFiltro>` normal,
`selected` nunca fica vazio.
**Warning signs:** Crash ao abrir o sheet pela primeira vez (antes de qualquer filtro aplicado).

### Pitfall 2: Reimplementar o reinício de paginação em vez de reusar `_aplicarConsulta`
**What goes wrong:** Se `aplicarFiltros`/`removerFiltro`/`limparFiltros` cada um escrever seu
próprio fluxo de "zera cursor, emite loading, busca", o token de versão (guarda contra respostas
atrasadas, F2/D-13) fica fácil de esquecer em um dos três caminhos — reintroduzindo exatamente o
bug "cards duplicados/embaralhados" que a F2 já resolveu, agora só para o caminho de filtros.
**Why it happens:** Os três métodos parecem simples o bastante para "só chamar o repositório
direto", mas cada um dispara uma nova consulta de primeira página, com a mesma janela de corrida
que busca/ordenação já têm.
**How to avoid:** Todo caminho de mudança de filtro passa por `_aplicarConsulta` (Pattern 2) —
nunca por uma chamada direta ao `UseCase`/repositório.
**Warning signs:** Teste manual: aplicar um filtro, remover outro rapidamente antes da primeira
resposta chegar — se a lista final não corresponder ao ÚLTIMO estado de filtros, o bug voltou.

### Pitfall 3: `quartos_min`/`suites_min`/`vagas_min` tratado como "exato" no mock ou na UI
**What goes wrong:** O contrato (§7 item 1) deixava isso genuinamente em aberto entre "mínimo" e
"exato"; D-01 resolveu para "mínimo" só do lado do app (é uma proposta de trabalho, "vira adendo
para sign-off do E2" — não está confirmado pelo backend real ainda). Implementar comparação
`==` em vez de `>=` no mock, ou rotular os `ChoiceChip`s como "1", "2", "3" sem o "+", entrega
uma semântica incompatível com o que o adendo vai propor ao E2.
**Why it happens:** O nome do param já tinha sufixo `_min` desde a Fase 1 (o que sugeria
"mínimo"), mas nunca foi confirmado — fácil assumir que já era "mínimo" sem checar D-01
explicitamente.
**How to avoid:** `ImovelMockDataSource` compara com `>=`; rótulos sempre com "+" (Pattern 6);
e o PLAN.md desta fase deve registrar D-01 como adendo formal ao contrato (`01-CONTRATO-API.md
§7` → mover de "pendente" para "proposta de trabalho do app", mesmo padrão já usado para D-11
`ordenacao` na Fase 2).
**Warning signs:** Teste com um imóvel de `quartos == 2` e filtro `quartos_min = 2` que não
aparece (comparação `==` estrita em vez de `>=`).

### Pitfall 4: Vírgula dentro de um nome de bairro/característica quebra o parsing CSV (D-06, risco já registrado)
**What goes wrong:** `natureza`/`bairro`/`caracteristicas` em CSV numa única chave (`D-06`)
assume que nenhum valor contém vírgula. Nenhuma linha da fixture atual tem vírgula em `bairro`
ou em `caracteristicas` (confirmado por leitura de `imoveis_fixture.dart` nesta sessão — listas
`_bairrosCampinas`/`_bairrosValinhos`/`_bairrosVinhedo`/`_caracteristicasDisponiveis`, nenhuma
com vírgula), então o bug não aparece nos testes desta fase — mas o parser inverso
(`bairroDoParametro`/`caracteristicasDoParametro`, análogos a `cidadeDoParametro`) que decodifica
o CSV recebido em `seguir()` vai quebrar silenciosamente (split incorreto) se um nome real algum
dia tiver vírgula.
**Why it happens:** É uma decisão já travada como "custosa de reverter" (D-06) — o risco é
aceito conscientemente, não um erro de implementação.
**How to avoid:** Documentar o risco no PLAN.md (D-06 já pede isso — "registrado um risco para o
E2"); garantir que a fixture expandida (D-24) continue sem vírgulas nesses campos, para não
mascarar silenciosamente o bug nos testes automatizados desta fase.
**Warning signs:** Nenhum nesta fase (a fixture controla os dados) — risco é para quando dados
reais chegarem na Fase 4.

### Pitfall 5: Faixa de preço habilitada sem finalidade escolhida (viola D-03)
**What goes wrong:** Sem `finalidade` selecionada no rascunho, não há como saber se `preco_min`/
`preco_max` devem comparar com `preco_venda` ou `preco_aluguel` — D-03 exige que o campo de
faixa de preço fique **desabilitado** nesse estado, não que assuma um dos dois por padrão.
**Why it happens:** É tentador deixar os campos sempre habilitados e só decidir o campo-base no
mapeamento para query params — mas isso permite ao visitante digitar uma faixa de preço "sem
sentido" (comparando venda com aluguel silenciosamente) antes de escolher finalidade.
**How to avoid:** O rascunho do sheet desabilita (`enabled: false` nos `TextField`s) a seção de
preço enquanto `finalidade == null`; ao trocar de finalidade, D-13 exige limpar a faixa (não
apenas re-habilitar com o valor antigo, que poderia ter sido digitado pensando em outra escala).
**Warning signs:** Um filtro de preço aplicado sem finalidade correspondente chegando ao mock.

### Pitfall 6: Estado "sem resultado com filtros" (D-22) colidindo com os vazios já existentes
**What goes wrong:** A F2 já tem dois vazios distintos (`vazioNaCidade`, `semResultado` de
busca) no `ConteudoVitrine` sealed (`lib/presentation/vitrine/vitrine_state.dart:24-50`, lido
nesta sessão). Adicionar o terceiro vazio (D-22, "Nenhum imóvel com esses filtros") sem
considerar a combinação "busca E filtros" pode fazer a mensagem errada aparecer (ex.: mostrar
"sem resultado de busca" quando na verdade os FILTROS zeraram o resultado, ou vice-versa).
**Why it happens:** `VitrineCubit._aplicarConsulta` hoje decide entre `semResultado`/
`vazioNaCidade` só olhando `termoBusca != null` — precisa também olhar `filtros.quantidadeAtiva`
para produzir a mensagem certa quando os dois estão ativos (D-22 exige citar os dois nesse caso).
**How to avoid:** Estender o `switch` de decisão de vazio em `_aplicarConsulta` para as 4
combinações (nem busca nem filtro / só busca / só filtro / os dois) — não só bifurcar em 2.
**Warning signs:** Teste manual com busca "erro"-like + filtro que também zera: só um dos dois é
mencionado na mensagem.

## Code Examples

### Extensão do mock para os filtros (D-01..D-05) sobre mapas de wire
```dart
// imovel_mock_datasource.dart — mesma pipeline que já filtra cidade+busca (D-05/D-06 da F2),
// estendida com mais predicados compostos por AND entre filtros, OU dentro de cada multi-valor
bool _linhaCasaComFiltros(Map<String, Object?> linha, FiltrosVitrine filtros) {
  if (filtros.finalidade != null) {
    final finalidadeLinha = linha['finalidade']! as String;
    final aceitas = _finalidadesAceitas(filtros.finalidade!); // D-02: inclui VENDA_E_ALUGUEL
    if (!aceitas.contains(finalidadeLinha)) return false;
  }
  if (filtros.natureza.isNotEmpty) {
    final naturezaLinha = linha['natureza'] as String?;
    if (naturezaLinha == null || !filtros.natureza.any((n) => n.valorApi == naturezaLinha)) {
      return false; // OU entre valores (D-05)
    }
  }
  if (filtros.quartosMin != null) {
    final quartos = linha['quartos'] as int? ?? 0;
    if (quartos < filtros.quartosMin!) return false; // "N ou mais" (D-01)
  }
  if (filtros.caracteristicas.isNotEmpty) {
    final caracteristicasLinha = (linha['caracteristicas'] as List).cast<String>().toSet();
    if (!filtros.caracteristicas.every(caracteristicasLinha.contains)) {
      return false; // E entre valores (D-04)
    }
  }
  // preço (D-03, campo-base por finalidade), suítes/vagas (D-01), bairro (D-05 OU),
  // área (faixa) seguem o mesmo formato — omitidos aqui por repetição.
  return true;
}

// _paginar() já existente passa a compor: cidade -> busca -> ESTE novo predicado -> ordena -> corta.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `RadioListTile.groupValue`/`onChanged` (deprecated) | `RadioGroup<T>` envolvendo `RadioListTile`s sem `groupValue` próprio | Já adotado na F2 (`ordenacao_bottom_sheet.dart`) | Se o sheet de filtros usar algum `Radio`/`RadioListTile` (ex. como alternativa ao `ChoiceChip` de D-10), seguir o mesmo padrão `RadioGroup` já em produção — `flutter analyze` trata deprecation info como fatal neste projeto |

**Deprecated/outdated:** nenhum item específico desta fase além do já registrado acima (herdado
da F2, não uma mudança nova encontrada nesta sessão).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|----------------|
| A1 | `Cubit<FiltrosVitrine>` de vida curta é a melhor forma de modelar o rascunho do sheet (vs. `ValueNotifier`) | Summary, Pattern-escolha do rascunho | Baixo — CONTEXT já deixa a decisão como discrição do Claude; se o planner preferir `ValueNotifier`, a mudança é isolada ao widget do sheet, sem afetar `domain/`/`data/` |
| A2 | Nomear a entidade `OpcoesFiltroRepository`/`OpcoesFiltroMockDataSource` (em vez de repositórios separados para bairros e características) | Pattern 7, Project Structure | Baixo — é nomeação interna; CONTEXT deixa "nomes e forma dos endpoints" como discrição |
| A3 | `TextInputFormatter` hand-rolado (não um pacote de máscara) é preferível para os campos de preço/área | Don't Hand-Roll, Pattern 5 | Médio — se o planner preferir um pacote (`mask_text_input_formatter` está ativamente mantido no pub.dev), a decisão do CLAUDE.md de evitar dependências redundantes ainda favorece hand-roll, mas vale confirmar com o usuário se a complexidade da máscara crescer além de moeda/área simples |
| A4 | `Badge.count(count, child)` é a API atual e correta para a contagem do botão "Filtros (N)" (D-15) | Standard Stack, D-15 | Baixo — fonte única (`api.flutter.dev` via WebFetch, sem cross-check por WebSearch independente; `gsd_run query classify-confidence --provider webfetch` = LOW mesmo com `--verified`); se a API tiver mudado de nome, o planner/executor descobre no `flutter analyze` (erro de compilação), sem risco silencioso |

**Nenhuma claim de fato do contrato da API está nesta tabela** — todas as decisões D-01..D-24
vêm de CONTEXT.md (usuário já decidiu) e são tratadas como travadas, não assumidas.

## Open Questions

1. **Formato exato dos dois novos endpoints de opções (`/api/publico/bairros/`,
   `/api/publico/caracteristicas/`) no adendo ao contrato**
   - What we know: D-20 já define os caminhos e o racional (bairros com imóvel publicado na
     cidade; características a partir do model `Caracteristica`).
   - What's unclear: formato de item (`{id, nome}` vs. string simples) e se são paginados —
     CONTEXT deixa isso como discrição do Claude, "desde que registrados no contrato §9/§10".
   - Recommendation: o planner deve registrar a escolha como um novo adendo explícito (mesmo
     processo de sign-off já usado para D-01..D-06 e para os adendos da F2 em §9), não como uma
     decisão silenciosa — é o mesmo padrão já em uso no `01-CONTRATO-API.md`.

2. **`Imovel` (entidade de domínio) não carrega `suites`, `vagas`, `area`, `caracteristicas`**
   - What we know: `ImovelModel.paraEntidade()` (lido nesta sessão,
     `lib/data/models/imovel_model.dart:43-56`) já recebe esses campos do JSON mas não os repassa
     para `Imovel` — só `natureza` e `quartos` cruzam para o domínio hoje.
   - What's unclear: se esta fase precisa desses campos na entidade de domínio. A resposta desta
     pesquisa é **não**: a filtragem acontece inteiramente sobre os MAPAS DE WIRE dentro do mock
     (antes do parse, ver `ImovelMockDataSource._paginar`), e os chips derivam de `FiltrosVitrine`
     aplicado, não de `Imovel`. Nenhum requisito desta fase pede exibir suítes/vagas/área no
     card (fora de escopo de VIT-02/FIL).
   - Recommendation: não expandir `Imovel`/`ImovelModel.paraEntidade()` nesta fase — deixar como
     está; revisitar só se uma fase futura pedir esses campos visíveis no card ou na tela de
     detalhe (DET-01, v2).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Toda a fase (widgets Material 3 novos) | ✓ | `^3.13.4` (pubspec `environment.sdk`, inalterado desde F1/F2) | — |
| `flutter test` / `flutter analyze` | Validation Architecture (abaixo) | ✓ | já usados nas Fases 1/2 (README.md §Testes) | — |

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** nenhuma — esta fase não introduz nenhuma dependência de
ambiente nova (sem Docker, sem serviço externo, sem API real ainda — Fase 4).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (SDK) + `bloc_test ^10.0.0` + `mocktail ^1.0.5` — já configurados desde a F1/F2 |
| Config file | nenhum arquivo de config dedicado — `flutter test` roda `test/**_test.dart` por convenção padrão do SDK |
| Quick run command | `flutter test test/data/imovel_mock_datasource_test.dart test/presentation/vitrine_cubit_test.dart` (arquivos que crescem nesta fase) |
| Full suite command | `flutter test && flutter analyze` (mesmo par usado pela F1/F2, README.md §43/§105/§109) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|---------------------|--------------|
| FIL-01 | Finalidade filtra e é inclusiva (D-02) | unit (mock) | `flutter test test/data/imovel_mock_datasource_test.dart` | ✅ (arquivo existe, ganha novo `group`) |
| FIL-01 | `SegmentedButton` de 3 segmentos nunca fica com seleção vazia | widget | `flutter test test/presentation/filtros_bottom_sheet_test.dart` | ❌ Wave 0 |
| FIL-02 | Natureza multi-seleção OU (D-05) + CSV (D-06) | unit (mock + params) | `flutter test test/data/imovel_mock_datasource_test.dart test/data/parametros_consulta_imoveis_test.dart` | ⚠️ segunda parcialmente — `parametros_consulta_imoveis.dart` hoje só é exercitado indiretamente (via `imovel_mock_datasource_test.dart`/`cidade`); ❌ Wave 0 para um arquivo dedicado |
| FIL-03 | `quartos_min`/`suites_min`/`vagas_min` "N ou mais" (D-01), faixa de preço por finalidade (D-03) | unit (mock) | `flutter test test/data/imovel_mock_datasource_test.dart` | ✅ ganha novo `group` |
| FIL-03 | Validação inline mín > máx desabilita "Ver imóveis" (D-12) | widget | `flutter test test/presentation/filtros_bottom_sheet_test.dart` | ❌ Wave 0 |
| FIL-04 | Bairro (OU, D-05), área (faixa), características (E, D-04) | unit (mock) | `flutter test test/data/imovel_mock_datasource_test.dart` | ✅ ganha novo `group` |
| FIL-04 | Opções de bairro/características vêm do `OpcoesFiltroMockDataSource`, nunca lista fixa | unit | `flutter test test/data/opcoes_filtro_mock_datasource_test.dart` | ❌ Wave 0 |
| FIL-05 | Nenhum filtro é resolvido em `presentation/`/`domain/` (grep estático, mesmo padrão do plano F2 para `RadioGroup`) | static/manual | `grep -rn "\.where(" lib/presentation lib/domain` (deve retornar vazio para filtragem de acervo) | ✅ técnica já usada na F2 (ver `ordenacao_bottom_sheet_test.dart:86-90`, comentário "verificado por grep estático") |
| FIL-06 | Chips resumidos, contagem, "x" reconsulta na hora, reinício sem duplicar (D-16..D-19) | bloc_test + widget | `flutter test test/presentation/vitrine_cubit_test.dart test/presentation/vitrine_screen_test.dart` | ✅ ambos existem, ganham novos casos |
| FIL-06 | Estado "sem resultado com filtros" distinto (D-22) | bloc_test | `flutter test test/presentation/vitrine_cubit_test.dart` | ✅ existe, ganha novo `group` |

### Sampling Rate
- **Per task commit:** `flutter test <arquivos tocados pela task>` (padrão já usado nas Fases 1/2)
- **Per wave merge:** `flutter test && flutter analyze`
- **Phase gate:** suíte completa verde antes de `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/presentation/filtros_bottom_sheet_test.dart` — cobre FIL-01 (SegmentedButton), FIL-03
      (validação inline), D-07/D-08 (rascunho/rodapé fixo), D-13 (troca de finalidade limpa preço)
- [ ] `test/data/parametros_consulta_imoveis_test.dart` — cobre o mapeamento CSV/`_min`/preço-por-
      finalidade isoladamente (hoje só testado indiretamente via `ImovelMockDataSource`); vale a
      pena isolar porque esta fase adiciona ~8 campos novos ao mapeamento
- [ ] `test/data/opcoes_filtro_mock_datasource_test.dart` — cobre FIL-04 (fonte de bairros/
      características, D-20)
- [ ] `test/presentation/rascunho_filtros_cubit_test.dart` (se a discrição A1 optar por Cubit) —
      cobre D-08/D-13 isoladamente do widget, no mesmo padrão `bloc_test` de `vitrine_cubit_test.dart`
- Framework install: nenhum — `bloc_test`/`mocktail` já instalados desde F1/F2.

## Security Domain

> `security_enforcement: true`, `security_asvs_level: 1` (`.planning/config.json`, lido nesta
> sessão). App sem login (constraint não-negociável do projeto) — a maior parte das categorias
> ASVS de autenticação/sessão não se aplica; o app também nunca faz a chamada HTTP real ainda
> (mock em memória), o que limita a superfície de ataque real desta fase especificamente ao
> código Dart do app, não a uma API em produção.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|--------------------|
| V2 Authentication | não | App sem login (constraint do projeto) — nenhum filtro desta fase toca autenticação |
| V3 Session Management | não | Sem sessão/token — filtros não persistem (D-23), vivem só em memória durante a sessão de navegação |
| V4 Access Control | não | Endpoint público, sem escopo por usuário (mesma allowlist do contrato §6, já auditada na F1) |
| V5 Input Validation | sim | Validação inline de formulário (D-12, `errorText` + desabilitar "Ver imóveis") nos campos numéricos; parsing defensivo do lado do mock com `FormatException` para valores malformados, seguindo o padrão já estabelecido por `cidadeDoParametro`/`ordenacaoDoParametro` (`lib/data/datasources/parametros_consulta_imoveis.dart:31-50`, lido nesta sessão) |
| V6 Cryptography | não | Nenhum dado sensível manipulado por esta fase (filtros de imóvel são dados públicos) |

### Known Threat Patterns for este stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|------------------------|
| Parâmetro de filtro malformado (ex. `preco_min=abc`, `cursor` de `seguir()` com CSV corrompido) derruba o parser sem tratamento | Denial of Service (local, não distribuído — é o app derrubando a própria tela) | Mesmo padrão já usado por `cidadeDoParametro`/`ordenacaoDoParametro`: lançar `FormatException` explícito, nunca deixar uma exceção genérica não tratada subir até a UI (`ImovelRepositoryImpl` já captura `on Exception catch` e converte em `Result.failure`, ver `lib/data/repositories/imovel_repository_impl.dart:21-28`) |
| Vírgula dentro de um valor CSV (bairro/característica) quebra o parsing inverso (D-06, Pitfall 4) | Tampering (integridade do parsing, não de dados de terceiros — é um bug de encoding, não uma injeção) | Registrado como risco aceito e documentado (D-06) — não é uma vulnerabilidade de segurança em si (o mock/servidor real sempre valida/filtra por allowlist de bairros conhecidos, contrato §6), mas pode causar resultados incorretos silenciosos; mitigação real (escape ou identificador) fica para o E2 decidir na Fase 4 |
| Filtro "vazando" regra de negócio para o cliente (ex. calcular no app quais imóveis aparecem) | Tampering / Information Disclosure indireto (o app deixaria de refletir mudanças de regra do servidor, ex. novo critério de "publicado") | FIL-05 já é a mitigação: toda filtragem fica em `data/` sobre mapas de wire, nunca client-side de fato — grep estático (Validation Architecture) verifica isso no CI/local |

## Sources

### Primary (HIGH confidence)
- `lib/**/*.dart` (código real do projeto, lido integralmente nesta sessão: `consulta_imoveis.dart`,
  `parametros_consulta_imoveis.dart`, `imovel_mock_datasource.dart`, `imoveis_fixture.dart`,
  `ordenacao_bottom_sheet.dart`, `vitrine_cubit.dart`, `vitrine_state.dart`, `vitrine_screen.dart`,
  `result.dart`, `imovel.dart`, `imovel_repository.dart`, `imovel_repository_impl.dart`,
  `imovel_model.dart`, `imovel_datasource.dart`, `pagina_imoveis.dart`, `imoveis_envelope_model.dart`,
  `ordenacao_vitrine.dart`, `cidade.dart`, `texto_normalizado.dart`, `injection.dart`) —
  `[VERIFIED: código-fonte lido nesta sessão]`
- `.planning/phases/01-.../01-CONTRATO-API.md` (contrato congelado, lido integralmente nesta
  sessão) — `[VERIFIED: documento do projeto]`
- `.planning/phases/02-.../02-RESEARCH.md` (padrões já estabelecidos e verificados na F2, lido
  nesta sessão) — `[VERIFIED: documento do projeto]`
- `api.flutter.dev/flutter/material/SegmentedButton-class.html` (fetched nesta sessão via
  WebFetch — parâmetros `selected`, `emptySelectionAllowed`, `multiSelectionEnabled` citados
  verbatim) **cross-checado** por WebSearch independente sobre o mesmo widget — seam
  `classify-confidence --provider websearch --verified` = MEDIUM — `[CITED: api.flutter.dev,
  cross-checado]`
- `pubspec.yaml` do projeto (lido nesta sessão — confirma SDK `^3.13.4` e todas as versões já
  instaladas, sem necessidade de nova verificação de registry por não haver dependência nova)
  — `[VERIFIED: pubspec.yaml do projeto]`

### Secondary (MEDIUM confidence)
- WebSearch "Flutter TextField currency input mask TextInputFormatter pattern without external
  package" — confirma que a abordagem hand-rolada com `TextInputFormatter` + `NumberFormat` é um
  padrão reconhecido (vs. pacotes dedicados), usado para embasar a recomendação Don't Hand-Roll
  — `[CITED: resultados de busca, múltiplas fontes]`
- WebSearch "Flutter showModalBottomSheet isScrollControlled useSafeArea full-height sheet fixed
  footer" — confirma o papel de `useSafeArea` combinado com `isScrollControlled` para rodapé
  fixo + teclado — `[CITED: resultados de busca]`

### Tertiary (LOW confidence)
- `api.flutter.dev/flutter/material/Badge-class.html` (fetched nesta sessão via WebFetch,
  fonte única — sem cross-check por WebSearch independente; seam
  `classify-confidence --provider webfetch` = LOW mesmo com `--verified` neste ambiente) —
  `[ASSUMED — ver Assumptions Log A4]`. As duas entradas de WebSearch puro (bottom sheet
  `isScrollControlled`/`useSafeArea`, `FilterChip`/`ChoiceChip`) também ficaram em LOW
  (`classify-confidence --provider websearch` sem `--verified`) — usadas só para confirmar
  padrões já conhecidos de APIs estáveis do Flutter SDK, nunca para descobrir nome de pacote.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero pacotes novos; toda a superfície é Flutter SDK (Material 3,
  estável há várias versões) + extensão de código já lido e verificado nesta sessão.
- Architecture: HIGH — todos os padrões (Pattern 1, 2, 7) são extensões diretas de código real
  já em produção nas Fases 1/2, lido integralmente nesta sessão.
- Pitfalls: HIGH para Pitfalls 1-2 e 5-6 (derivados de leitura direta do código + docs oficiais);
  MEDIUM para Pitfall 3-4 (derivados de decisões do CONTEXT marcadas como "risco registrado" /
  "proposta de trabalho", não de um bug observado em execução real).

**Research date:** 2026-09-30
**Valid until:** 30 dias (stack estável — Material 3/Flutter SDK muda pouco nesse intervalo;
revalidar se a Fase 4 trouxer uma versão nova de Flutter/Dart antes disso)
