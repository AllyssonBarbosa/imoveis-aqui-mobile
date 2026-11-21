---
phase: 08-login-e-rea-do-corretor-o-acervo
verified: 2026-11-21T16:30:00Z
status: human_needed
score: 6/6 must-haves verified
covered_files:
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-01-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-01-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-02-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-02-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-03-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-03-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-04-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-04-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-05-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-05-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-06-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-06-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-07-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-07-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-08-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-08-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-09-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-09-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-10-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-10-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-11-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-11-SUMMARY.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-12-PLAN.md
  - .planning/phases/08-login-e-rea-do-corretor-o-acervo/08-12-SUMMARY.md
  - lib/data/datasources/acervo_remote_datasource.dart
  - lib/data/datasources/autenticacao_remote_datasource.dart
  - lib/data/network/interceptador_sessao.dart
  - lib/data/repositories/acervo_repository_impl.dart
  - lib/data/repositories/autenticacao_repository_impl.dart
  - lib/di/modulo_rede.dart
  - lib/main.dart
  - lib/presentation/acervo/acervo_cubit.dart
  - lib/presentation/acervo/acervo_screen.dart
  - lib/presentation/login/login_cubit.dart
  - lib/presentation/sessao/dialogo_sair.dart
  - lib/presentation/sessao/sessao_cubit.dart
covered_digest: "v4:sha256:7c4dc66ab8952b655baedf9d6d6040cdb162bc210f89f0c6a019b5034dfcab9b"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Emulador Android contra o Django real da feat/APP08: abrir sem login, Entrar como corretor, ver Meu acervo, buscar, filtrar por situação, Sair"
    expected: "Abre na vitrine com o botão Entrar; o corretor cai em Meu acervo; fechar e reabrir mantém Meu acervo; Sair devolve ao anônimo e apaga o token"
    why_human: "Fluxo ponta a ponta com servidor real e armazenamento seguro do aparelho; os testes usam ApiFalsa sobre o wire capturado"
  - test: "Token no Keychain do iOS num Mac M1 (entrar, fechar e reabrir no simulador)"
    expected: "O token persiste; se não persistir, adicionar a capability Keychain Sharing pelo Xcode"
    why_human: "Exige Mac e entitlements keychain-access-groups; não há como provar no Windows"
  - test: "Isolamento com dados reais: corretor B (outra empresa) abre o acervo"
    expected: "Só vê DEMO-CASA-01 (Vendido, sem toque) e nenhum DEV-*; gestor e administrador caem em 'A área do gestor ainda não está no app.' com Sair"
    why_human: "O isolamento está provado por testes do Django (AcervoApiTests); a conferência com o banco semeado e o servidor de verdade é visual"
  - test: "Limite de tentativas: repetir o login errado até o 429 e decidir se 10/hour por e-mail e 30/hour por IP servem"
    expected: "Mensagem 'Muitas tentativas. Tente de novo em N minutos.' e valores de taxa aceitos pelo time"
    why_human: "Decisão de produto sobre taxa (LOGIN_TAXA_POR_EMAIL e LOGIN_TAXA_POR_IP)"
  - test: "Sair em dois aparelhos (token único por usuário)"
    expected: "O outro aparelho volta ao login com 'Sua sessão terminou. Entre de novo.' ao tocar em Meu acervo"
    why_human: "Exige dois aparelhos e servidor real"
  - test: "Aparência (login, aviso, acervo, cartão compacto), autofill do gerenciador de senhas e o botão do topo em 360 dp"
    expected: "Material 3 verde e branco; Entrar / Meu acervo ao lado do seletor de cidade sem truncar; oferta de preenchimento no login"
    why_human: "Julgamento visual; o 08-UI-REVIEW (18/24) já aponta chips sem pista de rolagem, situações sem cor e preço sem peso"
  - test: "Push das branches feat/APP08 dos dois repositórios, aviso ao time da web e nota do .claude/CLAUDE.md"
    expected: "Autorização do usuário; time da web ciente de que GET /api/imoveis/ virou envelope paginado; nota sobre flutter_secure_storage atualizada ou recusada"
    why_human: "Ação externa e irreversível que depende de autorização explícita; nenhum plano fez push"
---

# Fase 8: Login e Área do Corretor — o Acervo — Relatório de Verificação

**Objetivo da fase:** Como corretor, eu quero entrar no aplicativo para ver os imóveis que eu e a imobiliária temos, de onde eu estiver. O login é do mesmo aplicativo (não existe app separado). Quem entra vê a área do seu papel; o visitante continua usando o app sem login. O corretor vê os imóveis dele e os da imobiliária, com busca e filtro por situação. Imóvel de outra empresa não aparece, de jeito nenhum.
**Verificado em:** 2026-11-21
**Status:** human_needed
**Re-verificação:** Não, verificação inicial

A fase abrange dois repositórios: o app em `C:/projetos/imoveis-aqui-mobile` (branch `feat/APP08`) e a API Django em `C:/projetos/imoveis-aqui` (branch `feat/APP08`, 4 commits locais sobre `d9ddd8f`). Os PLANs citam um caminho antigo do OneDrive; foi usado `C:/projetos/imoveis-aqui`.

## Conquista do objetivo

O objetivo foi alcançado no código. Li os arquivos reais, não os SUMMARYs, e rodei as suítes dos dois lados. Não há lacuna bloqueante. O status é `human_needed` porque o próprio 08-12-SUMMARY lista conferências que só um aparelho, um servidor real ou uma decisão humana resolvem, e porque o code review deixou 7 avisos abertos que merecem triagem.

### Verdades observáveis (contrato do ROADMAP)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Login pelo aplicativo, com o token vindo da API | ✓ VERIFIED | `AutenticacaoRemoteDataSource.entrar` faz `POST /api/auth/login/` pelo Dio público e lê `token`; `AutenticacaoRepositoryImpl.entrar` guarda só o token; `EntrarUseCase` encadeia `entrar` e `obterPapel` com rollback. No Django, `LoginAPIView` devolve `{"token"}` (`Web/contas/api/views.py`). Testes: `login_cubit_test`, `login_fluxo_test` (7), `LoginApiTests`. |
| 2 | A sessão fica guardada; sair apaga o token do aparelho | ✓ VERIFIED | `ArmazenamentoTokenSeguro` sobre `flutter_secure_storage ^11.2.0` (`pubspec.yaml:50`); `android:allowBackup="false"` (`AndroidManifest.xml:15`). `AutenticacaoRepositoryImpl.sair` apaga o token no `finally` (mesmo com rede fora, 401 ou `PlatformException`) e `SessaoCubit.sair` termina sempre anônimo. No servidor `SairAPIView` apaga o `Token` (204). Testes: `sair_usecase_test`, `SairApiTests`, `acervo_fluxo_test` (Sair também com 500). |
| 3 | Erro de login genérico, sem revelar se o e-mail existe | ✓ VERIFIED | `mensagemDeFalhaDoLogin` escolhe o texto só pelo tipo da falha: 'E-mail ou senha inválidos.' para 400, texto próprio para 429 e para rede; nunca usa o corpo do servidor (`apresentacao_login.dart`). O repositório não carrega o corpo na falha. O 429 do servidor é igual para e-mail existente ou não (`test_429_e_igual_para_email_existente_e_inexistente`). |
| 4 | Lista do acervo com os imóveis do corretor e os da imobiliária, com busca e filtro por situação | ✓ VERIFIED | `ImovelViewSet.get_queryset` aplica o mixin de empresa, depois `FiltroImovelForm(campos=["busca","situacao"])` (a mesma regra do painel do site), `Exists(na_vitrine)` e ordem `-criado_em,-pk`; lista paginada em 20 com `ImovelAcervoSerializer` de 10 chaves e `meu_imovel` calculado no servidor. No app, `parametrosDaConsultaAcervo` só traduz `busca` e `situacao` para a URL; `AcervoCubit` não filtra nem ordena e segue o `next`. Testes: `AcervoApiTests`, `contrato_acervo_test`, `acervo_cubit_test`, `acervo_fluxo_test`. |
| 5 | Imóvel de outra empresa não aparece nem forçando a consulta | ✓ VERIFIED | O mixin filtra por `empresa=request.user.empresa` antes de tudo. `test_isolamento_busca_situacao_e_parametros_forcados_nao_trazem_imovel_de_fora` tenta `busca`, `situacao`, `empresa` e `corretor` de fora e confirma que `FORA` nunca vem; `test_detalhe_de_imovel_de_outra_empresa_da_404`; `EhCorretor` dá 403 a gestor e administrador. A suíte Django completa passou (743). |
| 6 | Sem login, o app continua abrindo direto na vitrine | ✓ VERIFIED | `main.dart` chama `SessaoCubit.carregar()` com `unawaited`; o cubit só lê o aparelho, nunca a rede. O botão do topo fica sem rótulo até a leitura terminar. O Dio público (vitrine) não tem interceptor nem token. `login_fluxo_test` prova que a abertura sem sessão não faz pedido a `/api/auth/` nem a `/api/imoveis/`. |

**Pontuação:** 6/6 verdades verificadas (0 presentes com comportamento não verificado).

As verdades que dependem de comportamento (isolamento, revogação do token, 401 voltando ao login, token só na mesma origem) têm teste comportamental que passa, não só presença de símbolo.

### Itens adiados

Nenhum. Não há fase posterior do milestone que cubra algo desta fase.

### Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `Web/contas/api/views.py` e `urls.py` | `LoginAPIView` endurecida, `EuAPIView`, `SairAPIView` | ✓ VERIFIED | Rotas `auth/login/`, `auth/eu/`, `auth/sair/` registradas; `authentication_classes=[]` no login |
| `Web/core/throttles.py` | Limite por e-mail (hash SHA-256) e por IP | ✓ VERIFIED | Taxas vêm de `LOGIN_TAXA_POR_EMAIL` e `LOGIN_TAXA_POR_IP` no `settings.py`, validadas no boot |
| `Web/imoveis/api/views.py` e `serializers.py` | Acervo paginado, filtrado e enxuto | ✓ VERIFIED | `PaginacaoAcervo`, `ImovelAcervoSerializer` (10 chaves) |
| `lib/data/network/interceptador_sessao.dart` | Token só na mesma origem, 401 tipado | ✓ VERIFIED | Remove `Authorization` fora da origem; compare-and-delete no 401 |
| `lib/di/modulo_rede.dart` | Segundo Dio `@Named('autenticado')`, `followRedirects:false` | ✓ VERIFIED | Dio público intacto, sem interceptor |
| `lib/data/datasources/acervo_remote_datasource.dart` | `next` só da mesma origem | ✓ VERIFIED | Lança `FormatException` para origem diferente |
| `lib/data/repositories/*_repository_impl.dart` | Falhas tipadas, `sair` nunca lança | ✓ VERIFIED | 400, 429, 403, 401, rede mapeados por tipo |
| `lib/presentation/{login,sessao,acervo}/` | Telas e Cubits | ✓ VERIFIED | Sem regra de negócio nem rede na UI |
| `.planning/.../01-CONTRATO-API.md` §14 e `test/fixtures/api/acervo_*.json`, `eu_*.json`, `erro_*.json` | Contrato e fixtures capturadas (API-09) | ✓ VERIFIED | §14.1 a §14.9 presentes; 13 fixtures; `contrato_acervo_test` verde |

### Verificação de ligações

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|----------|
| `main.dart` | `SessaoCubit` | `BlocProvider.value` acima do `MaterialApp` | ✓ WIRED | Singleton compartilhado por todas as rotas |
| `BotaoSessaoTopo` | `LoginScreen` / `EntradaAreaScreen` | rótulo pelo estado da sessão | ✓ WIRED | Presente em `PrimingScreen` e `CidadeSelecaoScreen` |
| `EntradaAreaScreen` | papel (`/api/auth/eu/`) | `EntradaAreaCubit` | ✓ WIRED | 401 vira login com aviso; corretor vai ao acervo; gestor e administrador ao aviso |
| `AcervoScreen` | `AcervoCubit` → use case → repositório → datasource → Dio autenticado | injeção por `getIt` | ✓ WIRED | Provado de ponta a ponta por `PilhaReal` com o DI de produção |
| `AcervoScreen` | 401 | `BlocListener` → `marcarAnonima` + `LoginScreen(aviso)` | ✓ WIRED | `acervo_fluxo_test` cobre o caso |
| `ImovelViewSet.list` | `FiltroImovelForm` + `na_vitrine` | `get_queryset` | ✓ WIRED | Empresa primeiro, depois filtro |

### Trilha de fluxo de dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `AcervoScreen` | `itens` | `GET /api/imoveis/` pelo Dio autenticado | Sim, JSON capturado do Django alimenta os Models em `contrato_acervo_test` | ✓ FLOWING |
| `BotaoSessaoTopo` | estado da sessão | `ArmazenamentoToken.ler()` | Sim | ✓ FLOWING |
| `CartaoImovelAcervo` | `naVitrine`, `meuImovel` | campos calculados no Django | Sim, o app não recalcula | ✓ FLOWING |

### Spot-checks de comportamento

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Suíte Django inteira | `DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` (em `Web`) | 743 testes, OK | ✓ PASS |
| Suíte Flutter inteira | `flutter test` | 1059 passando, 0 falhas | ✓ PASS |
| Análise estática | `flutter analyze lib` | 38 `info`, todos `deprecated_member_use` (linha de base aceita); nenhum outro tipo | ✓ PASS |
| Isolamento forçado | `AcervoApiTests` (dentro da suíte) | `FORA` nunca aparece | ✓ PASS |

### Execução de probes

Nenhum probe convencional (`scripts/*/tests/probe-*.sh`) foi declarado pela fase. Passo ignorado.

### Cobertura de requisitos

Os 12 IDs do pedido aparecem nos PLANs e no REQUIREMENTS.md; nenhum órfão. Todos estão marcados `[x]` e `Complete` no REQUIREMENTS.md, e conferi a implementação de cada um.

| Requisito | Plano de origem | Descrição | Status | Evidência |
|-----------|-----------------|-----------|--------|-----------|
| AUTH-01 | 08-05, 08-07, 08-10, 08-12 | Login por e-mail e senha no mesmo app | ✓ SATISFIED | `AutenticacaoRemoteDataSource.entrar`, `EntrarUseCase`, `LoginScreen` |
| AUTH-02 | 08-02, 08-03, 08-05, 08-07, 08-10, 08-12 | Sessão em `flutter_secure_storage`; Sair apaga o token mesmo sem rede e revoga no servidor | ✓ SATISFIED | `armazenamento_token_seguro.dart`, `repository.sair()` com `finally`, `SairAPIView`. Ressalva: o limite de 5 s do Sair não vale com o servidor inalcançável (WR-02) |
| AUTH-03 | 08-03, 08-05, 08-10, 08-12 | Erro genérico, 429 e rede com mensagens próprias por tipo | ✓ SATISFIED | `apresentacao_login.dart`, `falhas_autenticacao.dart` |
| AUTH-04 | 08-07, 08-11, 08-12 | Sem login abre na vitrine; botão Entrar / Meu acervo sem atrasar a abertura | ✓ SATISFIED | `main.dart`, `BotaoSessaoTopo`, `SessaoCubit.carregar` |
| AUTH-05 | 08-03, 08-05, 08-07, 08-10, 08-11, 08-12 | Área do papel lida de `/api/auth/eu/`; gestor e administrador veem aviso; 401 volta ao login | ✓ SATISFIED | `EuAPIView`, `EntradaAreaCubit`, `AvisoAreaScreen` |
| AUTH-06 | 08-03, 08-12 | Limite por e-mail e IP com 429 e `Retry-After` | ✓ SATISFIED | `ThrottleLoginPorEmail`, `ThrottleLoginPorIp`, `LoginLimiteDeTentativasTests` |
| ACV-01 | 08-01, 08-06, 08-08, 08-09, 08-12 | Acervo paginado com rolagem infinita, cartão compacto com a marca "Seu" | ✓ SATISFIED | `PaginacaoAcervo`, `ImovelAcervoSerializer.meu_imovel`, `AcervoScreen` |
| ACV-02 | 08-01, 08-08, 08-09, 08-12 | Busca e situação no servidor com `FiltroImovelForm`, combináveis | ✓ SATISFIED | `get_queryset` e `parametros_consulta_acervo.dart` |
| ACV-03 | 08-01, 08-12 | Outra empresa não aparece; gestor e administrador não acessam; sem token é 401 | ✓ SATISFIED | Mixin de empresa, `EhCorretor`, testes de isolamento e de 403 |
| ACV-04 | 08-01, 08-06, 08-08, 08-09, 08-12 | Toque só abre se `na_vitrine` | ✓ SATISFIED | `cartao_imovel_acervo.dart` (`naVitrine && aoTocar != null`) |
| API-09 | 08-04, 08-12 | §14 do contrato congela as rotas, com fixtures capturadas e testes de contrato | ✓ SATISFIED | §14 do `01-CONTRATO-API.md`, `contrato_acervo_test.dart` |
| API-10 | 08-01, 08-03, 08-12 | Web entrega `eu`, `sair`, limite de login e acervo paginado, com testes | ✓ SATISFIED | `EuApiTests`, `SairApiTests`, `LoginLimiteDeTentativasTests`, `AcervoApiTests` |

### Anti-padrões encontrados

Nenhum marcador de dívida (`TBD`, `FIXME`, `XXX`) nos arquivos da fase. O único `XXX` achado é um literal de teste (situação inválida) em `Web/imoveis/tests.py:3671`. Nenhum stub: nenhum `return null` ou lista vazia fixa chega à tela sem fonte real de dados.

Os avisos do code review (`08-REVIEW.md`, 0 críticos, 7 avisos, 5 informativos) continuam todos com disposição `open`. Conferi no código os que tocam o comportamento da fase:

| Arquivo | Linha | Padrão | Gravidade | Impacto |
|---------|-------|--------|-----------|---------|
| `lib/presentation/sessao/dialogo_sair.dart` | 39 | `popUntil(isFirst)` (WR-01, confirmado) | ⚠️ Aviso | No primeiro uso, sem cidade salva, a pilha é `[Priming, Vitrine, Acervo]`; Sair volta ao priming, não à vitrine. O token é apagado do mesmo jeito, então o critério 2 vale |
| `lib/data/datasources/autenticacao_remote_datasource.dart` | 54-61 | `connectTimeout` de 10 s não é sobrescrito (WR-02) | ⚠️ Aviso | Com o servidor inalcançável, Sair espera ~10 s, não 5 s; o token local é apagado depois. A promessa "até 5 s" do PLAN 08-05 é falsa nesse caso |
| `lib/data/network/interceptador_sessao.dart` | 61-69 | Comentário cita T-08-49 sem código que o cumpra (WR-03, confirmado) | ⚠️ Aviso | Só o `EntrarUseCase` chama `descartarSessaoLocal()`. A mitigação real do PLAN (try/catch e `reject` sempre) existe; o "descarta de novo" do comentário não |
| `Web/core/throttles.py` | 18-39 | Balde por e-mail conta logins bem-sucedidos e permite travar a conta alheia (WR-04) | ⚠️ Aviso | Decisão de taxa e desenho; entra no item humano sobre as taxas |
| `Web/config/settings.py` | 177-198 | Sem `CACHES`, vale `LocMemCache` por processo (WR-05) | ⚠️ Aviso | Com vários workers o limite efetivo é maior; reinício zera os contadores |
| `Web/imoveis/api/views.py` + `settings.py` | 69-72 | `next` absoluto atrás de proxy TLS sem `SECURE_PROXY_SSL_HEADER` (WR-06) | ⚠️ Aviso | Em produção atrás de proxy, a página 2 pode ser rejeitada pela guarda de origem; em desenvolvimento funciona |
| `Web/config/settings.py` | 19 | `SECRET_KEY` com padrão inseguro (WR-07) | ℹ️ Info | Anterior a esta fase (W01/W02) |

Nenhum deles invalida os seis critérios do ROADMAP. Os dois que atingem requisitos (WR-02 sobre AUTH-02 e WR-01 sobre a volta à vitrine) são defeitos de acabamento, com o comportamento principal (token apagado) preservado. Recomendo tratá-los com `/gsd-plan-phase --gaps` ou como correção rápida antes do PR, e registrar a triagem em `08-REVIEW-DISPOSITION.md`.

### Verificação humana necessária

Os itens estão no frontmatter. Em resumo, ficam para uma pessoa: o fluxo no emulador contra o Django real, o Keychain do iOS num Mac M1, o isolamento com o banco semeado, a decisão das taxas de login, o Sair em dois aparelhos, a aparência (incluindo 360 dp, autofill e as fraquezas do `08-UI-REVIEW`), e a autorização do push, do aviso ao time da web e da nota do `.claude/CLAUDE.md`.

### Resumo das lacunas

Não há lacunas que bloqueiem o objetivo. As seis verdades do ROADMAP, os 12 requisitos e os artefatos e ligações principais foram confirmados no código e nas duas suítes (Django 743, Flutter 1059). Pontos de atenção para a pessoa decidir: (1) WR-01 e WR-02 afetam o acabamento do Sair; (2) WR-04 a WR-06 são decisões de produção da API (taxa, cache compartilhado, proxy TLS) a resolver antes de publicar; (3) nenhum `git push` foi feito, então 37 commits do app e 4 da web só existem localmente.

---

_Verificado: 2026-11-21_
_Verificador: Claude (gsd-verifier)_
