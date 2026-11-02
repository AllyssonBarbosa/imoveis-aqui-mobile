---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 18
subsystem: docs
tags: [contrato, api-publica, antidrift, readme, gates-finais, e2e]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-02/05-04/05-05 (API: lote, allowlist, opções, seed), 05-06/05-07 (fixtures capturadas), 05-15 e 05-17 (app no wire real)"
provides:
  - "01-CONTRATO-API.md reescrito para o formato real (rotas, PageNumberPagination, params da W09, allowlist exata, erros, §11.5 a-l RESOLVIDO/PENDENTE, riscos aceitos)"
  - "6 contrato/*.example.json = cópias byte a byte das fixtures capturadas"
  - "test/data/contrato_lista_test.dart (novo) e contrato_detalhe_test.dart (ampliado): exemplo == fixture + chaves exatas de cidade, envelope, item, opções, detalhe e blocos das 4 naturezas"
  - "REQUIREMENTS API-03 e ROADMAP Fase 5 critérios 1, 3 e 4 com a rota e o texto reais"
  - "README: rodar contra a API real, recapturar fixtures e roteiro de verificação ponta a ponta"
  - "Banco de dev semeado e servidor provado para o Host 10.0.2.2:8000 (check humano pronto)"
affects: [verify-work, fim-de-fase]

plan_head_before: b2581482d8cf7011244b8ed29beb0711f4dc8db7
actuals:
  tokens: 60000
  tasks: 3
  commits: 3   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Exemplo do contrato = cópia byte a byte da fixture capturada; teste compara texto e JSON decodificado"
    - "Chaves exatas por objeto no app espelhando as do Django (VitrineAllowlistExataTests), com testes que provam que o teste morde"

key-files:
  created:
    - test/data/contrato_lista_test.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/bairros.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/caracteristicas.example.json
  modified:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe_lote.example.json
    - test/data/contrato_detalhe_test.dart
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - README.md

key-decisions:
  - "Contrato reescrito inteiro (não remendado): as propostas das Fases 1-4 foram superadas pelo formato real; o histórico fica no git"
  - "Itens a-k do §11.5 resolvidos pelo código; PENDENTE para a web: c (período do IPTU), g (exposição de contato/LGPD) e l (empresa_id) — l é novo, vindo da decisão opcao-a do 05-02"
  - "Checkboxes de API-03/API-07 e a tabela de rastreio NÃO foram tocados: a ferramenta de fim de fase é dona deles"

requirements-completed: []

coverage:
  - id: D1
    description: "Contrato descreve a API real e os 6 exemplos são cópias exatas das respostas capturadas; teste falha em qualquer divergência"
    requirement: API-03
    verification:
      - kind: unit
        ref: "test/data/contrato_lista_test.dart; test/data/contrato_detalhe_test.dart#exemplo do contrato == resposta capturada"
        status: pass
    human_judgment: false
  - id: D2
    description: "Chaves exatas de cidade, envelope, item, opções, detalhe e dos blocos casa/terreno/apartamento(+predio)/lote(+quadra,loteamento), com bloco único preenchido por natureza"
    requirement: API-07
    verification:
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#blocos de natureza + guarda do contrato"
        status: pass
    human_judgment: false
  - id: D3
    description: "Texto de API-03 e critérios 1, 3 e 4 da Fase 5 conferem com a rota real e com D-01/D-02; README ensina a rodar contra a API e recapturar fixtures"
    verification:
      - kind: other
        ref: "greps do <verify> da Task 2"
        status: pass
    human_judgment: false
  - id: D4
    description: "Gates finais: sem mock em lib/, flutter test (585) e flutter analyze verdes, suíte Django (331) verde em SQLite e no Postgres de dev, nada enviado por push"
    verification:
      - kind: integration
        ref: "flutter test; flutter analyze; manage.py test --noinput (SQLite :memory: e Postgres do Web/.env); git branch -r --contains HEAD"
        status: pass
    human_judgment: false
  - id: D5
    description: "Ambiente do check humano pronto: banco de dev semeado e servidor em 0.0.0.0:8000 responde para o Host 10.0.2.2:8000 com as 4 cidades; percurso das 4 naturezas no emulador"
    requirement: API-07
    verification:
      - kind: other
        ref: "curl -H 'Host: 10.0.2.2:8000' /api/publico/cidades/ (servidor parado depois)"
        status: pass
    human_judgment: true

duration: 35min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 18: Contrato real, textos e gates finais Summary

**01-CONTRATO-API.md reescrito para o formato real da `feat/APP05`, com exemplos que são as próprias respostas capturadas e testes de contrato que travam o drift entre os dois repositórios; rota e critérios 3/4 corrigidos em REQUIREMENTS/ROADMAP; README ensina a rodar e recapturar; todos os gates verdes e o ambiente do check humano pronto.**

## Git (política opcao-a + app-a de 05-01)

- App (`feat/APP05`): um commit local por task, nunca push.
  - `68d4635` docs(05-18): contrato da API no formato real (Task 1)
  - `0a25c75` docs(05-18): rota real, critérios 3 e 4 da Fase 5 e README para rodar contra a API (Task 2)
  - `10e7580` docs(05-18): roteiro de verificação ponta a ponta no emulador (Task 3)
- API (`../imoveis-aqui`, `feat/APP05`): **zero commits** (HEAD continua `0592176`); o working tree com o trabalho de 05-01..05-05 ficou intacto (17 entradas no `git status`, as mesmas). Nada de stash, reset ou checkout.
- `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` ficaram fora de todos os commits. Nenhum formatador rodado.

## Accomplishments

- **Contrato (`01-CONTRATO-API.md`)**: nota de histórico (Fases 1-4 superadas), tabela de rotas, §2 cidades (array, só as com vitrine, `id` como atributo de roteamento), §3 item da lista (13 chaves, área por natureza), §4 PageNumberPagination (`count`, `next` absoluto de mesma origem, page_size 20), §5 parâmetros da W09 e o mapeamento do app (`recentes`/`preco`/`-preco`/`area`/`-area`), §6 allowlist exata + deny-list + decisão do corretor, §8 riscos aceitos, §9-§10 opções, §11 detalhe com os blocos e suas chaves exatas, §11.5 itens a-l, §12 recaptura e antidrift.
- **Exemplos**: `cidades`, `imoveis` (lista p1), `imovel_detalhe` (apartamento 22), `imovel_detalhe_lote` (lote 24), `bairros` e `caracteristicas` copiados byte a byte das fixtures.
- **Testes de contrato** (46 testes nos dois arquivos): exemplo == fixture (texto e JSON), chaves exatas de cidade/envelope/item/característica, bairros como lista de strings, o exemplo parseia por `ImoveisEnvelopeModel`, e testes de guarda que provam que o teste morde.
- **Textos**: API-03 e critério 1 citam `GET /api/publico/cidades/<id>/imoveis/`; critérios 3 e 4 reescritos (D-01/D-02).
- **README**: seção da API reescrita (sem a frase do mock), "Subir o Django" na `feat/APP05`, "Fixtures de teste (JSON real)", "Verificação ponta a ponta (emulador)".

## Contrato: pendências e riscos registrados

PENDENTE para a frente web (no §11.5 e no §6): **(c)** período do `preco_iptu`; **(g)** exposição de contato do corretor/LGPD, com a lista exata de campos que qualquer visitante recebe sem token (`id`, `empresa_id`, `nome`, `foto`, `email`, `creci`, `telefone`, `whatsapp`, `apresentacao`); **(l)** `empresa_id` no payload público (decisão opcao-a do 05-02). Riscos aceitos no §8: vírgula em nome de bairro no CSV (A-05, 05-04), busca sensível a acento (Pitfall 3, D-14), `Cidade.id` como atributo de roteamento (A-01) e os dados de contato do corretor.

## Gates finais

| Gate | Resultado |
|------|-----------|
| `grep` de `MockDataSource` / `AcervoFixture` / `data/mocks/` em `lib/` | nenhum arquivo |
| `flutter test --timeout 60s` | 585 testes, todos verdes |
| `flutter analyze` | No issues found |
| Django `manage.py test --noinput`, `DATABASE_URL=sqlite://:memory:` | 331 testes OK |
| Django `manage.py test --noinput` no Postgres de dev (banco `test_*` do Django) | 331 testes OK (128 s) |
| Nenhum remoto contém o HEAD local da API | `git branch -r --contains HEAD` vazio (HEAD `0592176`) |
| Porta 8000 livre no fim | sim |

## Task 3: ambiente do check humano

**Autorização do usuário (repassada pelo orquestrador):** contra o Postgres de dev do `Web/.env` (container Docker em `127.0.0.1:5433`), (1) rodar `semear_vitrine_dev`, (2) rodar a suíte Django completa (no `test_*` do próprio Django) e (3) subir `runserver 0.0.0.0:8000 --noreload` em segundo plano só para os curls e pará-lo. Nada além disso foi feito nesse banco; o `Web/.env` nunca foi lido, impresso nem editado, e `DEBUG` não foi forçado.

- Seed: `Vitrine de desenvolvimento semeada: 4 cidades atendidas por 'Imobiliária Vitrine Demo (dev)', 36 imóveis garantidos.` (idempotente).
- Curl com `Host: 10.0.2.2:8000`: `/api/publico/cidades/` devolveu Campinas, Indaiatuba, Valinhos e Vinhedo; a lista de Campinas devolveu `count 24`, 20 itens e `next` em `http://10.0.2.2:8000/...?page=2`; bairros e características 200; id inexistente 404. Servidor parado em seguida.
- Observação: neste banco de dev o `id` de Campinas é **2** (nas fixtures é 1), exatamente por isso a cidade é identificada no app por `nome-uf` e o `id` vem da lista de cidades (A-01).

**Comandos para repetir o check humano (UAT de fim de fase):**

```bash
# terminal 1: API (banco de dev do Web/.env, já migrado e semeado)
cd /Users/georgelucas/Documents/projeto-mobile/imoveis-aqui/Web
.venv/bin/python manage.py runserver 0.0.0.0:8000     # Ctrl+C ao terminar

# terminal 2: app no Android (AVD) - base URL padrão http://10.0.2.2:8000
cd /Users/georgelucas/Documents/projeto-mobile/imovies-aqui-mobile
flutter emulators --launch Medium_Phone_API_36.0
flutter run

# ou no simulador iOS 17.5
open -a Simulator
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

O roteiro (7 passos) está no README, subseção "Verificação ponta a ponta (emulador)". O check humano em si **não** foi feito aqui (UAT de fim de fase).

## Deviations from Plan

### Auto-fixed / decisões

**1. [Decisão do orquestrador] Testes de contrato dos blocos de natureza.** O 05-17 (deviation 3) tinha adiado a ampliação do contrato dos blocos. Como `test/data/contrato_detalhe_test.dart` está em `files_modified` deste plano, `_exigirContrato` agora confere também, para cada detalhe capturado, que exatamente o bloco da `natureza` vem preenchido (os outros três `null`) com as chaves exatas: `casa` (14), `terreno` (9), `apartamento` (10) + `predio` (9), `lote` (8) + `quadra` (2) + `loteamento` (8), espelhando `CHAVES_*` de `VitrineAllowlistExataTests` (05-02). Mais três testes de guarda (chave extra/faltando no bloco, bloco de outra natureza preenchido, chave extra no loteamento) e três asserções negativas (`lote` sem `preco`/`vendido`, `apartamento` sem `numero`, `predio` sem `unidades_por_andar`).

**2. [Escopo] Item (l) acrescentado ao §11.5.** O plano pedia a/k; o `empresa_id` pendente do 05-02 virou o item (l), além de ser citado em (g) e no §6.

**3. [Processo] Um commit por task, com os `.planning` do plano dentro deles.** Os arquivos de documentação da Task 1 (contrato e exemplos) e da Task 2 (REQUIREMENTS/ROADMAP) estão em `files_modified`, então entraram nos commits de task; o commit do SUMMARY/STATE segue o fluxo do GSD.

### Não feito, por instrução

- Checkboxes de API-03/API-07 em REQUIREMENTS.md e a tabela de rastreio **não** foram marcados (a ferramenta de fim de fase é dona deles); só o texto da rota de API-03 mudou.

Sem auth gates, sem pacote instalado, sem teste apagado ou enfraquecido.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-18-01 mitigado (exemplos = cópias byte a byte + testes de igualdade e chaves exatas dos dois lados); T-05-18-02 aceito (servidor em 0.0.0.0 só durante os curls, dados fictícios, parado depois); T-05-18-03 mitigado (zero commits na API e nenhum remoto contém o HEAD); T-05-18-04 mitigado (`Web/.env` nunca lido).

## Self-Check: PASSED

- Commits `68d4635`, `0a25c75` e `10e7580` presentes em `feat/APP05`.
- `test/data/contrato_lista_test.dart`, `bairros.example.json` e `caracteristicas.example.json` existem; `01-CONTRATO-API.md` menciona `cidades/<id>/imoveis/`, `PageNumberPagination`, `caracteristicas/`, `corretor_responsavel` e as letras a-k ao lado de RESOLVIDO/PENDENTE.
- README contém "Verificação ponta a ponta (emulador)", `Medium_Phone_API_36.0` e `API_BASE_URL=http://127.0.0.1:8000`.
