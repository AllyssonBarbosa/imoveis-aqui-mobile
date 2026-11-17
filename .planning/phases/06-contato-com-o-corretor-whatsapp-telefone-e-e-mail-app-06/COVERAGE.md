# API Coverage — Contato da W11 (`/api/publico/imoveis/{id}/contato/`, repo `../imoveis-aqui/Web`) e `url_launcher`

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

**Generated:** 2026-11-16 (plan-phase 6)
**Checkpoint:** Full API Coverage by Default — Opt Out, Never Opt In.

O detector determinístico (`api-coverage.cjs`) respondeu `detected: false` para o escopo dos planos 06-01..06-10, mas
a fase consome por rede um endpoint novo da API do projeto (o POST de contato da W11, mais o campo `canais_contato`
do detalhe) e adota um SDK novo (`url_launcher`). Pela mesma razão da Fase 5 (`05-.../COVERAGE.md`), a decisão
honesta é registrar a matriz completa das duas superfícies em vez de declarar "sem API externa". Superfície da API:
branch `feat/APP06` (main + merge de `origin/WEB-11` + `canais_contato` + throttle próprio). Superfície do SDK:
`url_launcher` 6.3.3 / `url_launcher_platform_interface` 2.3.2.

## Superfície da W11 (contatos) e do detalhe público

| capability | decision | reason |
|---|---|---|
| POST /api/publico/imoveis/{id}/contato/ (sem login, sem CSRF) | INTEGRATE | |
| corpo `canal` = WHATSAPP | INTEGRATE | |
| corpo `canal` = TELEFONE | INTEGRATE | |
| corpo `canal` = EMAIL | INTEGRATE | |
| resposta 201 `canal` | INTEGRATE | |
| resposta 201 `link` (wa.me / tel: / mailto:, mensagem montada pelo servidor) | INTEGRATE | |
| resposta 400 `{canal: [...]}` (status) | INTEGRATE | |
| resposta 400: texto da mensagem do servidor | OPT-OUT | not needed — D-14 fixa o texto em português por tipo de falha; o app nunca mostra mensagem do servidor |
| resposta 404 (fora da vitrine) | INTEGRATE | |
| resposta 429 (balde `contato_publico`, status) | INTEGRATE | |
| resposta 429: cabeçalho `Retry-After` | OPT-OUT | not needed — D-14 só pede "Aguarde um pouco"; sem nova tentativa automática (regra F5/D-14) |
| resposta 405 (GET no endereço de contato) | OPT-OUT | not needed — o app só faz POST nessa rota |
| GET /api/publico/imoveis/{id}/ campo `canais_contato` | INTEGRATE | |
| GET /api/contatos/?imovel=&de=&ate= (caixa de contatos, autenticada) | OPT-OUT | explicitly out of scope — caixa do corretor é o APP 10 e exige login (CONTEXT, domain) |
| PATCH /api/contatos/{id}/ (anotar retorno) | OPT-OUT | explicitly out of scope — APP 10 |
| POST /imovel/{id}/contato/ (site) e /painel/contatos/ (painel) | OPT-OUT | not needed — rotas HTML do site/painel, não são API do app |
| GET /api/publico/corretores/{id}/ (perfil público do corretor) | OPT-OUT | explicitly out of scope — perfil completo é o APP 07; nesta fase o perfil abre com os dados em memória (D-09, F5/D-16) |
| detalhe: `corretor_responsavel.whatsapp/telefone/email` | OPT-OUT | explicitly out of scope — o app nunca deduz canal nem guarda contato do corretor (D-02, F5/D-16) |
| contato sem imóvel (endpoint por corretor) | OPT-OUT | explicitly out of scope — Deferred Ideas do CONTEXT (mudança no model da W11, escopo da web) |

## Superfície do `url_launcher`

| capability | decision | reason |
|---|---|---|
| launchUrl(Uri, mode: LaunchMode.externalApplication) | INTEGRATE | |
| esquemas https (wa.me), tel, mailto | INTEGRATE | |
| canLaunchUrl | OPT-OUT | not needed — D-15 proíbe a checagem prévia (falso-negativo sem queries/LSApplicationQueriesSchemes) |
| LaunchMode.platformDefault / inAppBrowserView / inAppWebView | OPT-OUT | not needed — abririam wa.me dentro do app (RESEARCH Pitfall 1) |
| LaunchMode.externalNonBrowserApplication | OPT-OUT | not needed — falharia sem WhatsApp instalado; D-15 quer cair no navegador |
| supportsLaunchMode / supportsCloseForLaunchMode | OPT-OUT | not needed — um único modo fixo |
| closeInAppWebView, WebViewConfiguration, BrowserConfiguration | OPT-OUT | not needed — nenhuma web view interna |
| widget Link (url_launcher/link.dart) | OPT-OUT | not needed — o link só existe depois do POST; não há link estático na tela |
| API legada launch(String) / canLaunch(String) | OPT-OUT | not needed — deprecada; usa-se só a API de Uri |
