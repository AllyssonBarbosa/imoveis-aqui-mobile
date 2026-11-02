---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
verified: 2026-11-01T00:00:00Z
status: gaps_found
score: 4/6 must-haves verified
covered_files:
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-01-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-01-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-02-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-02-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-03-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-03-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-04-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-04-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-05-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-05-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-06-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-06-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-07-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-07-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-08-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-08-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-09-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-09-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-10-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-10-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-11-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-11-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-12-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-12-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-13-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-13-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-14-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-14-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-15-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-15-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-16-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-16-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-17-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-17-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-18-PLAN.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-18-SUMMARY.md
  - .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-REVIEW.md
  - lib/data/datasources/cidade_remote_datasource.dart
  - lib/data/datasources/imovel_detalhe_remote_datasource.dart
  - lib/data/datasources/imovel_remote_datasource.dart
  - lib/data/datasources/opcoes_filtro_remote_datasource.dart
  - lib/data/datasources/parametros_consulta_imoveis.dart
  - lib/di/injection.config.dart
covered_digest: "v1:sha256:acdadf194761e0f0d71cdebefc6bace740625827aff8ba5a5584472f20917610"
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "SC3 — a resposta segue o contrato do formato real, sem drift silencioso (o contrato diz: valor inválido de filtro numérico responde 400 {campo: mensagem})"
    status: partial
    reason: "CR-02 do 05-REVIEW, confirmado no código: `_numero` (views.py) faz `Decimal(valor)` e depois `numero < 0` fora do try. `preco_min=NaN` / `area_min=sNaN` lança decimal.InvalidOperation (reproduzido: `Decimal('NaN') < 0` -> InvalidOperation) e `Infinity` chega ao ORM e quebra com ValidationError do Django: HTTP 500 em vez do 400 prometido pelo contrato. Nenhum teste cobre essas entradas, então o drift é silencioso, exatamente o que o critério 3 proíbe."
    artifacts:
      - path: "../imoveis-aqui/Web/imoveis/api/views.py"
        issue: "_numero() (linhas ~315-326) aceita NaN/sNaN/Infinity/'1_0' e não rejeita não-finitos; 500 no endpoint público"
      - path: "../imoveis-aqui/Web/imoveis/tests.py"
        issue: "VitrineBuscaTests não tem caso para NaN, sNaN, Infinity, 1e400"
    missing:
      - "Rejeitar `not numero.is_finite()` com ValidationError (400) em _numero; opcionalmente limitar ao máximo do campo e rejeitar '_'"
      - "Testes em VitrineBuscaTests para NaN, sNaN, Infinity e 1e400 afirmando 400"
  - truth: "O endpoint público sem token é seguro de expor (consulta limitada, sem DoS por um único pedido) — derivado do goal (endpoint público real) e do ASVS citado nos planos 05-02/05-04"
    status: failed
    reason: "CR-01 do 05-REVIEW, confirmado no código: o filtro `caracteristicas` (views.py ~419-427) faz `queryset.filter(caracteristicas=id)` num `for` sobre ids sem teto; cada .filter() encadeado numa M2M soma um JOIN. O revisor reproduziu uma requisição com milhares de ids deixando o backend Postgres ocupado por mais de 2 minutos. `int()` também aceita -1. Sem throttle (WR-02) e sem limite de ids/bairros/tamanho de busca. Os 331 testes não cobrem entrada hostil."
    artifacts:
      - path: "../imoveis-aqui/Web/imoveis/api/views.py"
        issue: "loop de .filter(caracteristicas=...) sem limite; bairro CSV e busca também sem teto"
    missing:
      - "Limitar a quantidade de ids (<= tamanho do catálogo, ex. 20) e rejeitar ids <= 0 com 400"
      - "Trocar JOINs encadeados por uma única agregação (semântica 'tem todas' preservada)"
      - "Teste: 21+ ids devolve 400; caracteristicas=1,2 continua exigindo as duas"
      - "Recomendado: throttle anônimo e teto para bairro/busca (WR-02)"
human_verification:
  - test: "Verificação ponta a ponta no emulador (README, seção 'Verificação ponta a ponta (emulador)'; 05-18-SUMMARY): subir o runserver 0.0.0.0:8000 no banco de dev semeado, rodar o app (Android AVD Medium_Phone_API_36.0 com base URL padrão http://10.0.2.2:8000, ou iOS com --dart-define=API_BASE_URL=http://127.0.0.1:8000) e percorrer: (1) Campinas, rolar a lista inteira, duas páginas, sem card repetido; (2) buscar 'Cambuí' e depois texto sem resultado; (3) ordenar por 'Maior preço'; (4) Filtros: Casa e Lote, um bairro, 'Piscina', faixa de preço, aplicar, remover chip, 'Limpar filtros'; (5) abrir uma casa, um apartamento, um terreno e um lote (galeria começando pela capa 'N/M', blocos 'Sobre a ...', lote sem 'Preço do lote', posição solar e uso permitido em português), tocar no cartão do corretor; (6) abrir o imóvel sem fotos e o sem corretor; (7) trocar para Valinhos com filtro ativo."
    expected: "A vitrine mostra, busca, ordena e filtra imóveis reais; fotos carregam pela rede; rolagem e latência normais; os blocos das 4 naturezas aparecem no detalhe; textos legíveis em português a 360 dp, Material 3 verde e branco. Este é o check humano de fim de fase (human_verify_mode=end-of-phase; critérios 4 e 5 do ROADMAP) e ainda NÃO foi feito."
    why_human: "Rede real, carga de imagens, rolagem, latência e aparência só um emulador contra o Django prova; os testes automatizados usam JSON capturado servido por ApiFalsa, não um servidor vivo."
---

# Fase 5: Imóveis Real — Endpoint Público e Integração Final — Relatório de Verificação

**Objetivo da fase:** A API expõe o acervo real de imóveis com busca, ordenação, filtros e paginação resolvidos no servidor, sem dado interno; o app troca a DataSource mock pela real, e a vitrine com filtros passa a funcionar ponta a ponta com dados reais.
**Verificado em:** 2026-11-01
**Status:** gaps_found
**Re-verificação:** Não — verificação inicial

## Resumo

O objetivo funcional foi atingido no código dos dois repositórios: a API expõe lista, detalhe, bairros e catálogo de características públicos, sem token, com a regra única `na_vitrine`, allowlist exata e isolamento; o app usa as DataSources remotas via DI, sem nenhum mock em `lib/`, e a adaptação ao formato real ficou em `data/` e na UI. Os gates automáticos estão verdes (reexecutados por mim). **O status é `gaps_found`, e não `human_needed`, por causa dos dois achados críticos do code review (CR-01 e CR-02), que confirmei lendo o código e reproduzindo o comportamento do `Decimal`:** ambos estão no endpoint público novo da fase, um viola o contrato de erros 400 (critério 3) e o outro permite negação de serviço com uma única requisição. Os dois são correções pequenas e localizadas em `views.py`. O check humano de emulador (critérios 4 e 5) continua pendente e está listado em `human_verification`.

## Verdades Observáveis

| # | Verdade (critério do ROADMAP) | Status | Evidência |
|---|-------------------------------|--------|-----------|
| 1 | SC1: `GET /api/publico/cidades/<id>/imoveis/?filtros` responde sem token, só com publicados, com busca/ordenação/filtros/paginação no servidor | VERIFICADO | `VitrineCidadeAPIView` (`views.py`): `AllowAny` + `authentication_classes = []`, parte de `imoveis_da_vitrine()` (`vitrine.py` -> `Imovel.objects.na_vitrine()` = publicado + DISPONÍVEL + empresa ativa). Busca em titulo/bairro/descricao, `finalidade`, `natureza` CSV, faixas de preço/área, mínimos de quartos/suítes/vagas, `bairro` CSV iexact, `caracteristicas`, `ordenar` (5 valores, desempate `-id`), `PaginacaoVitrine` (20). Rotas registradas em `urls_publico.py` e `config/urls.py:17`. Suíte Django 331 OK. (Entrada hostil: ver gaps.) |
| 2 | SC2: serializer público com allowlist explícita, sem proprietário/documento/dado interno; sem quebrar isolamento (nenhum imóvel de outra empresa ou não publicado aparece) | VERIFICADO | `serializers.py` 422-590: `fields` listados um a um em todos os serializers públicos (`ImovelVitrineSerializer`, `ImovelVitrineDetalheSerializer`, endereço sem `complemento`, apartamento sem número, lote sem `vendido`/preço). `VitrineAllowlistExataTests` (igualdade exata de chaves), `VitrineSemTokenESemVazamentoTests` (`CHAVES_PROIBIDAS` + `VALORES_PROIBIDOS`), `VitrineSituacaoTests` (reservado/vendido/alugado somem da lista e dão o mesmo 404 do id inexistente; cidade sem vitrine some de `/cidades/`). Ressalva aceita e registrada: contatos e `empresa_id` do corretor público (checkpoint do 05-02; revisão LGPD adiada para a web, pendência c/g/l do contrato). |
| 3 | SC3: resposta segue o contrato real (01-CONTRATO-API.md reescrito, exemplos copiados de respostas capturadas, testes de contrato nos dois repositórios), sem drift silencioso | FALHOU (parcial) | O que existe e passa: `01-CONTRATO-API.md` reescrito; 6 `contrato/*.example.json` = cópias byte a byte das 15 fixtures capturadas em `test/fixtures/api/` por `tool/capturar_fixtures_api.py`; `test/data/contrato_lista_test.dart` e `contrato_detalhe_test.dart` no app, `VitrineAllowlistExataTests` na API. O que falha: o contrato (§5 e "Erros 400") promete 400 para valor inválido, mas `preco_min/max` e `area_min/max` com `NaN`/`sNaN`/`Infinity` dão HTTP 500 (CR-02) e nenhum teste trava isso: drift silencioso no próprio endpoint novo. Ver gap 1. |
| 4 | SC4: app troca as DataSources mock pelas reais via DI; adaptação em `data/` e UI, Cubits/domain só o mínimo (D-01); ponta a ponta o visitante vê, busca, ordena e filtra imóveis reais | VERIFICADO no código; ponta a ponta HUMANO PENDENTE | `lib/di/injection.config.dart` registra `ImovelRemoteDataSource`, `ImovelDetalheRemoteDataSource`, `OpcoesFiltroRemoteDataSource` e `CidadeRemoteDataSource` sobre o mesmo `Dio` (linhas 97-136); não há classe mock em `lib/data/datasources/` nem arquivo `*mock*` no projeto. `parametros_consulta_imoveis.dart` concentra os nomes de parâmetro da W09 (cidade no caminho pelo id, `ordenar`, `busca` com trim, CSV ordenado, ids de característica); `ImovelRemoteDataSource` segue o `next` só se tiver a mesma origem da base URL; o Cubit só dedupe ids repetidos e não refiltra/reordena (D-14). `flutter analyze` sem avisos; `flutter test` 585/585. Falta o run no emulador (human_verification). |
| 5 | SC5: detalhe `GET /api/publico/imoveis/{id}/` vem da API real, incluindo dados de natureza; página do imóvel da Fase 4 funciona ponta a ponta | VERIFICADO no código; ponta a ponta HUMANO PENDENTE | `ImovelDetalheRemoteDataSource` (`caminhoDetalheImovelPublico`) via DI; `DetalheImovelModel`/`DadosNaturezaModel` lidos contra os 4 detalhes capturados (+ sem fotos, sem corretor, 404); testes `contrato_detalhe_test`, `detalhe_imovel_model_test`, `detalhe_imovel_screen_test`, `detalhe_navegacao_test` passam. Lote adicionado na API (`LotePublicoSerializer`, 05-02). |
| 6 | Derivada do goal/ASVS: o endpoint público é seguro de expor (consulta limitada) | FALHOU | CR-01 confirmado em `views.py`: `for caracteristica_id in ids: queryset = queryset.filter(caracteristicas=caracteristica_id)` sem teto e sem validação de sinal; sem throttle. Ver gap 2. |

**Pontuação:** 4/6 verdades verificadas (SC1, SC2, SC4 e SC5 no código; 2 delas dependem ainda do check humano de emulador para a parte "ponta a ponta"). 0 truths marcadas `PRESENT_BEHAVIOR_UNVERIFIED`: a parte ao vivo está coberta pelo item de `human_verification`.

## Artefatos Obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `../imoveis-aqui/Web/imoveis/vitrine.py` | `imoveis_da_vitrine()` sobre `na_vitrine()` | VERIFICADO | `Imovel.objects.na_vitrine()`, LOTE nas anotações (`lote__area`). `na_vitrine` definido em `models.py:15`. |
| `../imoveis-aqui/Web/imoveis/api/urls_publico.py` | 4 rotas públicas | VERIFICADO | `publico-vitrine-cidade`, `publico-bairros-cidade`, `publico-caracteristicas`, `publico-imovel`; incluído uma vez em `config/urls.py`. |
| `../imoveis-aqui/Web/imoveis/api/serializers.py` | serializers públicos com allowlist | VERIFICADO | Lote/Quadra/Loteamento públicos, galeria com capa primeiro (view usa `order_by("-capa","ordem","id")`). |
| `../imoveis-aqui/Web/imoveis/api/views.py` | views públicas | VERIFICADO (com gaps CR-01/CR-02) | Funcional; endurecimento ausente. |
| `../imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py` | seed idempotente, só `DEBUG=True` | VERIFICADO | Guarda de `DEBUG` (linha 137), `SemearVitrineDevTests` + `SemearVitrineDevDebugDesligadoTests`. Ressalvas WR-04/WR-05. |
| `../imoveis-aqui/Web/.env.example` | `ALLOWED_HOSTS` com `10.0.2.2` | VERIFICADO | Arquivo modificado (`Web/.env` nunca lido). |
| `test/fixtures/api/*.json` (15 arquivos) | capturas reais de lista, opções, detalhes e erros | VERIFICADO | Lista p1/p2/vazia/CASA+LOTE, bairros, características, cidades, 4 detalhes + sem fotos + sem corretor, 400 e 404. |
| `tool/capturar_fixtures_api.py` | captura reexecutável | VERIFICADO | Ressalvas IN-07 (informativas). |
| `lib/data/datasources/{imovel,imovel_detalhe,opcoes_filtro,cidade}_remote_datasource.dart` + `parametros_consulta_imoveis.dart` | DataSources reais | VERIFICADO | Substantivos e ligados no DI. |
| `lib/domain/entities/imovel.dart`, `cidade.dart` | `Imovel` sem cidade; `Cidade` com `id` fora da igualdade | VERIFICADO | Testes de ida e volta no prefs. |
| `01-CONTRATO-API.md` + `contrato/*.example.json` + testes de contrato | contrato real e antidrift | VERIFICADO (conteúdo); contrato de 400 contradito pelo comportamento (gap 1) | |

## Verificação de Ligações-Chave

| De | Para | Via | Status |
|----|------|-----|--------|
| `vitrine.py` | `models.py` | `imoveis_da_vitrine()` -> `na_vitrine()` | LIGADO |
| `localizacao/api/views.py` | `vitrine.py` | cidades atendidas filtram por `imoveis_da_vitrine()` | LIGADO (conforme 05-01; suíte verde) |
| `views.py` (Bairros) | `vitrine.py` | `imoveis_da_vitrine().filter(cidade_anuncio=...)` | LIGADO |
| `injection.config.dart` | `ImovelRemoteDataSource` | `lazySingleton<ImovelDataSource>` | LIGADO |
| `imovel_remote_datasource.dart` | `parametros_consulta_imoveis.dart` | `caminhoImoveisDaCidade(...)` + `parametrosDaApi(...)` | LIGADO |
| `detalhe_imovel_screen.dart` | `apresentacao_imovel.dart` | `rotuloLocalizacao` com cidade anulável | LIGADO (05-03) |
| `contrato/*.example.json` | `test/fixtures/api/*.json` | cópia byte a byte comparada em teste | LIGADO |

## Fluxo de Dados (Nível 4)

| Artefato | Dado | Fonte | Dados reais? | Status |
|----------|------|-------|--------------|--------|
| `VitrineCidadeAPIView` | lista de imóveis | ORM (`imoveis_da_vitrine()`), 4 consultas por página de 5 itens (medido no review) | Sim | FLUINDO |
| `ImovelRemoteDataSource` | itens da vitrine | `Dio.get` na rota real; modelos validados contra JSON capturado do Django semeado | Sim | FLUINDO (provado por fixtures reais; live pendente no emulador) |
| `OpcoesFiltroRemoteDataSource` | bairros/características | rotas reais de opções | Sim | FLUINDO |
| `ImovelDetalheRemoteDataSource` | detalhe + natureza | `GET /api/publico/imoveis/{id}/` | Sim | FLUINDO |

## Spot-checks Comportamentais

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Suíte do app | `flutter test --timeout 60s` | 585/585 passam | PASSOU |
| Análise estática | `flutter analyze` | No issues found | PASSOU |
| Suíte Django inteira | `DATABASE_URL="sqlite://:memory:" .venv/bin/python manage.py test` | 331 testes OK | PASSOU |
| Migrações em dia | `makemigrations --check --dry-run` | No changes detected | PASSOU |
| `Decimal("NaN") < 0` (base do CR-02) | `python3 -c ...` | `InvalidOperation` (não tratado em `_numero`) | CONFIRMA O GAP |
| Débito (TBD/FIXME/XXX) em `lib/`, `tool/`, `test/` e arquivos de API da fase | `grep -E` | nenhum marcador | PASSOU |
| Servidor vivo / DoS real | não executado (regra: não subir servidor contra o banco de dev) | confiado no relato e no código do review | N/A |

## Probes

Sem probes `probe-*.sh` declarados nos planos desta fase. Etapa pulada.

## Cobertura de Requisitos

| Requisito | Planos | Descrição | Status | Evidência |
|-----------|--------|-----------|--------|-----------|
| API-03 | 05-01, 02, 03, 04, 05, 06, 08..13, 15, 18 | `GET /api/publico/cidades/<id>/imoveis/?filtros`: público, sem token, busca/ordenação/filtros/paginação no servidor, só publicados, allowlist, isolamento | SATISFEITO no comportamento funcional; endurecimento pendente (gaps 1 e 2) | Truths 1, 2 e 4; checkbox intencionalmente não marcado (dono: ferramenta de fim de fase). |
| API-07 | 05-01, 02, 05, 07, 14, 16, 17, 18 | `GET /api/publico/imoveis/{id}/`: público, só publicados, 404 igual para inexistente e não publicado, allowlist do §11, DataSource do detalhe por DI | SATISFEITO | `test_detalhe_fora_da_vitrine_responde_o_mesmo_404_de_id_inexistente`, `VitrineAllowlistExataTests`, `ImovelDetalheRemoteDataSource` no DI; checkbox intencionalmente não marcado. |

Todos os IDs de frontmatter dos 18 planos (API-03, API-07) constam em REQUIREMENTS.md e estão mapeados à Fase 5 (linhas 50, 53, 111, 112). Sem requisitos órfãos: nenhum outro ID de REQUIREMENTS.md aponta para a Fase 5.

## Anti-padrões Encontrados

| Arquivo | Padrão | Severidade | Impacto |
|---------|--------|------------|---------|
| `imoveis/api/views.py` ~419-427 | JOIN M2M por id, sem teto (CR-01) | BLOQUEADOR | DoS com uma requisição em endpoint público |
| `imoveis/api/views.py` ~315-326 | `Decimal` não-finito não rejeitado (CR-02) | BLOQUEADOR | 500 no lugar de 400, contradiz o contrato |
| `imoveis/api/views.py` 365-371, 411-417 | byte NUL em `busca`/`bairro` -> 500 (WR-01) | AVISO | mesma classe do CR-02 |
| `config/settings.py` (REST_FRAMEWORK) | sem throttle nos endpoints anônimos (WR-02) | AVISO | agrava o CR-01 |
| `imoveis/api/views.py` 411-417 e 447-458 | opção de `/bairros/` pode não casar com `?bairro=` (espaços/caixa) (WR-03) | AVISO | quebra a promessa "nunca leva a busca vazia" |
| `empresas/management/commands/semear_vitrine_dev.py` | apartamento com bairro do título diferente do `bairro` da API (WR-04); guarda só olha `DEBUG` (WR-05) | AVISO | dado de dev incoerente congelado nas fixtures; README promete mais isolamento do que existe |
| `test/data/contrato_*_test.dart` | testes leem `.planning/` (WR-06) | AVISO | quebra se a Fase 1 for arquivada |
| IN-01..IN-09 do review | formatação "1.000 mil", andar 0 como "0º", comentários desatualizados, código morto etc. | INFO | sem impacto no objetivo |

## Verificação Humana Necessária

### 1. Verificação ponta a ponta no emulador (fim de fase)

**Teste:** roteiro do README, seção "Verificação ponta a ponta (emulador)" (7 passos, resumidos no frontmatter): Campinas com rolagem completa; busca e estado sem resultado; ordenação por maior preço; Filtros (Casa+Lote, bairro, Piscina, faixa de preço, remover chip, Limpar filtros); detalhe das 4 naturezas e perfil do corretor; imóvel sem fotos e sem corretor; troca para Valinhos com filtro ativo. Ambiente: `runserver 0.0.0.0:8000` no banco de dev já migrado e semeado (05-18 provou o Host `10.0.2.2:8000`); Android com base URL padrão ou iOS com `--dart-define=API_BASE_URL=http://127.0.0.1:8000`.
**Esperado:** cada etapa mostra o que está entre parênteses no README; textos legíveis em português a 360 dp, Material 3 verde e branco.
**Por que humano:** rede real, imagens, rolagem e latência não são exercitadas pelos testes (usam JSON capturado via `ApiFalsa`).

## Resumo das Lacunas

O núcleo da fase está entregue e coerente entre os dois repositórios, mas o endpoint público novo ainda aceita entrada hostil que derruba ou trava a resposta. As duas correções (CR-01: limitar/validar ids de características e usar uma única agregação; CR-02: rejeitar valores não-finitos em `_numero`, com testes) são localizadas em `Web/imoveis/api/views.py` e `Web/imoveis/tests.py`, e o ideal é fazê-las junto de WR-01 e WR-02 (mesmo arquivo, mesma classe de falha) via `/gsd-plan-phase --gaps`. Depois delas, rodar o check humano de emulador. WR-03..WR-06 e os informativos não bloqueiam o objetivo e podem ser tratados na mesma rodada ou adiados conscientemente. Nenhum item foi filtrado como "adiado" para fase posterior: as Fases 6/7 tratam contato e perfil do corretor, não endurecimento da lista pública.

Observação sobre o git: o trabalho da API estar não commitado no working tree (mais o merge `0592176`) é a escolha `opcao-a` do usuário e não foi tratado como lacuna.

---

_Verificado: 2026-11-01_
_Verificador: Claude (gsd-verifier)_
