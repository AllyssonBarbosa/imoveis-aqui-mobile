---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 02
subsystem: api
tags: [django, drf, throttle, rate-limit, contatos, whatsapp, urlencode]

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "feat/APP06 da API (main + WEB-11), POST público de contato e a política de git opcao-a + app-a"
provides:
  - "ThrottleContatoPublico (scope contato_publico, CONTATO_TAXA_ANONIMA, padrão 10/min por IP): 429 + Retry-After + {detail} sem gravar Contato"
  - "Baldes separados vitrine/contato, validação da taxa na partida, README e .env.example atualizados"
  - "link_whatsapp com urlencode(..., quote_via=quote): espaço vira %20, '+' literal vira %2B (API e site)"
affects: [06-03, 06-04, 06-05, 06-06, 06-07, 06-08, 06-09, 06-10]

plan_head_before: dbe0ab49653ce6a710224ddd915361dc16f520a8
actuals:
  tokens: 6500   # chars/4 sobre o diff realizado (throttle, settings, view, servicos, 10 testes, README, .env.example)
  tasks: 3
  commits: 0     # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): este plano não tem código no app. Repo da API: 0 commits (opcao-a), tudo no working tree.

tech-stack:
  added: []
  patterns:
    - "Throttle por subclasse: ThrottleContatoPublico herda de ThrottleVitrinePublica só o comportamento; o balde é outro (scope) e a taxa vem do settings"
    - "Taxa da suíte fixada em ThrottleVitrinePublica.rate é herdada pela subclasse; testes de isolamento fixam as duas taxas explicitamente"
    - "Uma só regra de codificação de link no servidor: WhatsApp e e-mail usam %20 (quote_via=quote)"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/core/throttles.py
    - ../imoveis-aqui/Web/config/settings.py
    - ../imoveis-aqui/Web/contatos/api/views.py
    - ../imoveis-aqui/Web/contatos/servicos.py
    - ../imoveis-aqui/Web/contatos/tests.py
    - ../imoveis-aqui/Web/site_publico/tests.py
    - ../imoveis-aqui/Web/.env.example
    - ../imoveis-aqui/README.md

key-decisions:
  - "Balde próprio para o POST de contato (decisão do usuário pós-pesquisa): scope contato_publico, 10/min por IP, validada na partida como a da vitrine"
  - "Correção do '+' no servidor, nunca no app (decisão do usuário pós-checagem): só link_whatsapp muda; link_email e link_telefone ficam"
  - "Uma asserção pré-existente do site (Casa+com+quintal) foi trocada pela forma equivalente e igualmente estrita Casa%20com%20quintal (ver Deviations)"

requirements-completed: [APP06-API-2, APP06-C6, APP06-C2]

coverage:
  - id: D1
    description: "POST público de contato acima da taxa responde 429 com Retry-After e {detail}, sem gravar Contato; a view segue sem login"
    requirement: APP06-API-2
    verification:
      - kind: unit
        ref: "contatos.tests.ContatoLimiteDeTaxaTests.test_passou_da_taxa_recebe_429_sem_gravar / test_view_usa_o_throttle_de_contato_sem_login / test_contato_herda_a_taxa_alta_da_suite"
        status: pass
    human_judgment: false
  - id: D2
    description: "Baldes isolados nos dois sentidos, taxa padrão do settings, X-Forwarded-For forjado não reinicia a contagem, taxa inválida para a partida"
    requirement: APP06-C6
    verification:
      - kind: unit
        ref: "ContatoLimiteDeTaxaTests (7 testes) + CONTATO_TAXA_ANONIMA=dez manage.py check imprime 'CONTATO_TAXA_ANONIMA inválida'"
        status: pass
    human_judgment: false
  - id: D3
    description: "Link do WhatsApp (POST da API e redirecionamento do site) com %20 entre palavras, sem '+', e '+' literal como %2B"
    requirement: APP06-C2
    verification:
      - kind: unit
        ref: "contatos.tests.MensagemDoWhatsAppComEspacosTests (3 testes) + manage.py shell com a == a%20b%2Bc"
        status: pass
      - kind: integration
        ref: "manage.py test --noinput (437 testes, SQLite em memória)"
        status: pass
    human_judgment: true

duration: 30min
completed: 2026-11-16
status: complete
---

# Phase 6 Plan 02: Limite do POST de contato e %20 no WhatsApp Summary

**POST público de contato com balde de taxa próprio por IP (`contato_publico`, 10/min, 429 + Retry-After sem gravar) e `link_whatsapp` com `%20` no lugar de `+`, ambos travados por testes Django antes do aparelho.**

## Performance

- **Duration:** ~30 min
- **Tasks:** 3 (1 tracer, 2 TDD)
- **Files modified:** 8 (todos no repo da API; nada no app)

## Accomplishments

- **Tracer (Task 1):** `ThrottleContatoPublico(ThrottleVitrinePublica)` com `scope = "contato_publico"`; `CONTATO_TAXA_ANONIMA` (padrão `10/min`) com a mesma validação de partida da vitrine; `ContatoPublicoAPIView.throttle_classes = [ThrottleContatoPublico]` só nesta view (a caixa de contatos autenticada segue sem limite; nenhum `DEFAULT_THROTTLE_CLASSES`). O terceiro POST acima de 2/min recebe 429 com `Retry-After` e `detail`, e `Contato.objects.count()` cresce exatamente 2. O gate do tracer foi cumprido: verificação ponta a ponta reexecutada e verde antes de seguir.
- **Isolamento (Task 2):** cota de contato esgotada não bloqueia o detalhe da vitrine e vitrine esgotada não bloqueia o POST (as duas taxas fixadas explicitamente nesse teste, porque a subclasse herda a taxa fixada na classe pai); `get_rate()` bate com `settings.CONTATO_TAXA_ANONIMA`; três POSTs com `X-Forwarded-For` diferentes dão `[201, 201, 429]` com `NUM_PROXIES=0`. `CONTATO_TAXA_ANONIMA=dez manage.py check` para a aplicação com a mensagem em português.
- **Docs:** `Web/.env.example` com `CONTATO_TAXA_ANONIMA=10/min`; README com a variável, o balde `contato_publico` e a regra do `%20`; a frase "Ainda não há limite de requisições por visitante no endereço público" foi substituída.
- **%20 (Task 3):** `link_whatsapp` agora usa `urlencode({'text': mensagem}, quote_via=quote)`. `link_whatsapp('11988887777', 'a b+c') == 'https://wa.me/5511988887777?text=a%20b%2Bc'`. O link da API e o redirecionamento do site trazem `%20` e nenhum `+`; `unquote` (que não converte `+` em espaço) devolve "Casa com quintal" e "CASA-INTERNO-1". `link_email` e `link_telefone` intocados; o app não muda.

## Task Commits

Nenhum commit de código neste plano, por política de git (06-01-SUMMARY.md):

| Repo | Escolha | Estado ao fim do 06-02 |
|------|---------|------------------------|
| API (`../imoveis-aqui`) | opcao-a | **sem commit**: tudo no working tree da `feat/APP06` (HEAD segue no merge `7d4f5cd`); nunca push |
| App | app-a | **sem commit de código**: este plano não toca o app. Só o commit de documentação deste SUMMARY/STATE |

Estado da API (sem commit) ao fim do plano: README.md, Web/.env.example, Web/config/settings.py, Web/contatos/api/views.py, Web/contatos/servicos.py, Web/contatos/tests.py, Web/core/throttles.py, Web/site_publico/tests.py (mais os 3 arquivos do 06-01: Web/imoveis/api/serializers.py, Web/imoveis/api/views.py, Web/imoveis/tests.py). Os três tasks: **sem commit**.

## Verificação

- `contatos.tests.ContatoLimiteDeTaxaTests`: 7 testes OK. `MensagemDoWhatsAppComEspacosTests`: 3 testes OK (RED visto antes: 3 falhas na codificação antiga; RED do tracer: erro de import da classe inexistente).
- `manage.py test contatos site_publico`: 72 testes OK. `manage.py test --noinput` (SQLite em memória): **437 testes, OK** (427 do 06-01 + 7 + 3).
- `manage.py check`: limpo.
- Web/.env nunca lido; .gitignore intocado.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug/premissa do plano] Asserção do site que fixava a codificação antiga**
- **Found during:** Task 3 (rodando `contatos site_publico`)
- **Issue:** o plano afirmava que nenhuma asserção existente lia o link de um modo dependente de `+`. Na verdade `site_publico.tests.WhatsAppTests.test_botao_chama_o_whatsapp_do_corretor_com_o_imovel_na_mensagem` fazia `assertIn("Casa+com+quintal", destino)`, que é exatamente a codificação que a decisão do usuário manda trocar. Reverter o código desfaria a tarefa.
- **Fix:** a asserção virou `assertIn("Casa%20com%20quintal", destino)` (mesma força: texto exato, só a forma nova), com um comentário de uma linha. Nenhuma outra asserção de `contatos` ou `site_publico` foi tocada; `startswith`, `parse_qs` e `unquote` seguiram verdes sem alteração.
- **Files modified:** ../imoveis-aqui/Web/site_publico/tests.py (sem commit, opcao-a)
- **Para o usuário:** é a única asserção pré-existente alterada. Se preferir tratar isso como decisão sua, basta reverter essa linha e a suíte do site volta a falhar nesse teste.

**Total deviations:** 1 (auto-corrigida, sem impacto de escopo).

## Issues Encountered

- A suíte completa passa de 120 s no SQLite em memória; foi rodada em segundo plano com a saída em arquivo. Uma primeira rodada completa, antes de ajustar a asserção acima, terminou com 1 falha (a do site) e foi descartada.

## Known Stubs

None.

## Threat Flags

None. T-06-02-01..04 e T-06-02-07 mitigadas e provadas por teste; T-06-02-05 (CGNAT) aceita e documentada (taxa configurável por env); T-06-02-06 aceita: o POST do site `/imovel/<id>/contato/` segue sem limite (fora do escopo por decisão do usuário), registrado abaixo para a Palloma.

## Recado para a Palloma (dona da W11) — pronto para enviar, o agente NÃO envia

> Palloma, na minha branch local `feat/APP06` do repo da API mexi em duas coisas da W11, sem commit e sem push. (1) `ContatoPublicoAPIView` ganhou `throttle_classes = [ThrottleContatoPublico]`: balde próprio por IP, configurado em `CONTATO_TAXA_ANONIMA` (padrão 10/min); acima disso responde 429 com `Retry-After` e não grava o contato. O POST do site `/imovel/<id>/contato/` continua sem limite, e a frase do README da W11 sobre "ainda não há limite de requisições" foi reescrita. (2) `link_whatsapp` em `contatos/servicos.py` agora usa `urlencode(..., quote_via=quote)`, como o `link_email`: espaço sai como `%20` (nunca `+`) e um `+` literal sai como `%2B`. Como é a mesma função, isso também muda os botões de WhatsApp das páginas de empresa/corretor do site. Travado por `MensagemDoWhatsAppComEspacosTests`. Nenhum teste da W11 ou do site foi alterado, com uma exceção: `site_publico.tests.WhatsAppTests` esperava `Casa+com+quintal` e passou a esperar `Casa%20com%20quintal`.

O usuário envia este recado no checkpoint do 06-10 (Task 2), onde fica registrado se foi enviado ou não. Estado do git das três tasks: **sem commit** (API opcao-a).

## Next Phase Readiness

- API da `feat/APP06` verde (437 testes) com o limite de contato e o `%20`. O app (06-03 em diante) pode capturar fixtures e consumir o POST: o link chega pronto, com `%20`, e o 429 já é o caso que o app mapeia para "Muitas tentativas..." (D-14).
- Confirmação do `%20` no aparelho fica para o checkpoint de fim de fase (06-10).

## Self-Check: PASSED

- Arquivos: `class ThrottleContatoPublico` em core/throttles.py, `CONTATO_TAXA_ANONIMA` em config/settings.py e `.env.example`, `throttle_classes = [ThrottleContatoPublico]` em contatos/api/views.py, `quote_via=quote` em link_whatsapp, `class ContatoLimiteDeTaxaTests` e `class MensagemDoWhatsAppComEspacosTests` em contatos/tests.py: todos presentes.
- API sem commits novos (HEAD = 7d4f5cd, `git branch -r --contains HEAD` vazio); app sem commits de código (`git rev-list dbe0ab4..HEAD` = 0 antes do commit do SUMMARY).
