---
phase: 08-login-e-rea-do-corretor-o-acervo
verified: 2026-11-21T18:00:00Z
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
  - lib/di/injection.config.dart
  - lib/di/modulo_rede.dart
  - lib/domain/usecases/descartar_sessao_usecase.dart
  - lib/main.dart
  - lib/presentation/acervo/acervo_cubit.dart
  - lib/presentation/acervo/acervo_screen.dart
  - lib/presentation/login/login_cubit.dart
  - lib/presentation/priming/priming_screen.dart
  - lib/presentation/sessao/dialogo_sair.dart
  - lib/presentation/sessao/entrada_area_screen.dart
  - lib/presentation/sessao/rota_vitrine.dart
  - lib/presentation/sessao/sessao_cubit.dart
covered_digest: "v4:sha256:12349d8db257ce9a13febcc261df2b54f0fabe7f8175f816e9c121d7d1825565"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: human_needed
  previous_score: 6/6
  gaps_closed: []
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "Emulador Android contra o Django real da feat/APP08: abrir sem login, Entrar como corretor, ver Meu acervo, buscar, filtrar por situação, Sair. Repetir o Sair no primeiro uso (sem cidade salva) e com cidade salva"
    expected: "Abre na vitrine com o botão Entrar; o corretor cai em Meu acervo; fechar e reabrir mantém Meu acervo; Sair devolve ao anônimo, apaga o token e volta à vitrine (no primeiro uso, não ao priming); Sair com a rede cortada termina em até cerca de 5 s"
    why_human: "Fluxo ponta a ponta com servidor real e armazenamento seguro do aparelho; os testes usam ApiFalsa sobre o wire capturado, pilhas de rota simuladas e relógio simulado (fakeAsync). A navegação e o tempo dos WR-01 e WR-02 não foram exercitados em aparelho"
  - test: "Token no Keychain do iOS num Mac M1 (entrar, fechar e reabrir no simulador)"
    expected: "O token persiste; se não persistir, adicionar a capability Keychain Sharing pelo Xcode"
    why_human: "Exige Mac e entitlements keychain-access-groups; não há como provar no Windows"
  - test: "Isolamento com dados reais: corretor B (outra empresa) abre o acervo"
    expected: "Só vê DEMO-CASA-01 (Vendido, sem toque) e nenhum DEV-*; gestor e administrador caem em 'A área do gestor ainda não está no app.' com Sair"
    why_human: "O isolamento está provado por testes do Django (AcervoApiTests); a conferência com o banco semeado e o servidor de verdade é visual"
  - test: "Limite de tentativas: repetir o login errado até o 429 e decidir se 10/hour por e-mail e 30/hour por IP servem"
    expected: "Mensagem 'Muitas tentativas. Tente de novo em N minutos.' e valores de taxa aceitos pelo time"
    why_human: "Decisão de produto sobre taxa (LOGIN_TAXA_POR_EMAIL e LOGIN_TAXA_POR_IP)"
  - test: "Sair em dois aparelhos (token único por usuário). Conferir também que, ao expirar a sessão (401), o app volta à vitrine com o login e o aviso, sem reoferecer Meu acervo"
    expected: "O outro aparelho volta ao login com 'Sua sessão terminou. Entre de novo.' ao tocar em Meu acervo; depois, a vitrine mostra Entrar (e não Meu acervo)"
    why_human: "Exige dois aparelhos e servidor real; a salvaguarda T-08-49 (WR-03) só foi provada com armazenamento simulado"
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
**Re-verificação:** Sim, depois das correções do code review (WR-01, WR-02 e WR-03)

A fase abrange dois repositórios: o app em `C:/projetos/imoveis-aqui-mobile` (branch `feat/APP08`) e a API Django em `C:/projetos/imoveis-aqui` (branch `feat/APP08`, 4 commits locais sobre `d9ddd8f`, árvore limpa). Os PLANs citam um caminho antigo do OneDrive; foi usado `C:/projetos/imoveis-aqui`.

## O que mudou desde a verificação anterior

O relatório anterior ficou desatualizado porque o código mudou depois dele. Três commits do app, todos lidos no código (não só no `08-REVIEW-FIX.md`):

| Commit | Correção | O que existe no código agora |
|--------|----------|------------------------------|
| `a378670` | WR-01: Sair e sessão expirada voltam à vitrine | `lib/presentation/sessao/rota_vitrine.dart` (novo) define `nomeRotaVitrine`, `configuracaoRotaVitrine` e o predicado `eRotaDaVitrine` (rota nomeada ou primeira rota). `PrimingScreen` empurra a vitrine com `settings: configuracaoRotaVitrine`. `confirmarESair` usa `popUntil(eRotaDaVitrine)` e o 401 do acervo usa `pushAndRemoveUntil(..., eRotaDaVitrine)`. Não restou nenhum `isFirst` solto fora do predicado |
| `1e59281` | WR-02: Sair espera no máximo 5 s de verdade | `AutenticacaoRepositoryImpl.sair` faz `_dataSource.sair().timeout(esperaMaximaSair)` (5 s). O `TimeoutException` cai no `on Exception` e o `finally` apaga o token local; `sair()` continua sem lançar |
| `2c4587b` | WR-03: salvaguarda T-08-49 | `DescartarSessaoUseCase` (novo, injetável, registrado em `injection.config.dart`) chama `descartarSessaoLocal()`. `SessaoCubit.encerrarPorExpiracao()` descarta o token e termina anônimo no `finally`. O acervo (401 na lista) e a `EntradaAreaScreen` (`EntradaAreaSessaoExpirada`) chamam `encerrarPorExpiracao()` e só depois navegam ao login |

Os arquivos de código do app estão sem alteração pendente em relação ao `HEAD` (só `.gitignore`, `.gsd/` e `.planning/state.json` aparecem modificados). O repositório web não mudou.

## Conquista do objetivo

O objetivo continua alcançado no código, e nada regrediu. Não há lacuna bloqueante. O status segue `human_needed`: há conferências que só um aparelho, um servidor real ou uma decisão humana resolvem, e as três correções mexem em navegação, tempo e fluxo de sessão expirada que os testes cobrem só com simulação.

### Verdades observáveis (contrato do ROADMAP)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Login pelo aplicativo, com o token vindo da API | ✓ VERIFIED | `AutenticacaoRemoteDataSource.entrar` faz `POST /api/auth/login/` pelo Dio público; `AutenticacaoRepositoryImpl.entrar` guarda só o token; `EntrarUseCase` encadeia `entrar` e `obterPapel` com rollback via `descartarSessaoLocal()` (intacto). No Django, `LoginAPIView` devolve `{"token"}`. Testes: `login_cubit_test`, `login_fluxo_test`, `LoginApiTests` (dentro da suíte de 1065) |
| 2 | A sessão fica guardada; sair apaga o token do aparelho | ✓ VERIFIED | `flutter_secure_storage ^11.2.0` (`pubspec.yaml:50`), `android:allowBackup="false"`. `sair()` apaga o token no `finally`, agora também quando o servidor passa de 5 s (teste `fakeAsync`: completa em exatamente `esperaMaximaSair` e o token é apagado), com `PlatformException` e com datasource e `apagar()` falhando juntos. `SessaoCubit.sair` termina sempre anônimo. No servidor, `SairAPIView` apaga o `Token` (204) |
| 3 | Erro de login genérico, sem revelar se o e-mail existe | ✓ VERIFIED | `mensagemDeFalhaDoLogin` escolhe o texto só pelo tipo da falha; o repositório não carrega o corpo na falha (`_executar` não mudou). O 429 do servidor é igual para e-mail existente ou não |
| 4 | Lista do acervo com os imóveis do corretor e os da imobiliária, com busca e filtro por situação | ✓ VERIFIED | Sem alteração nos arquivos de acervo da fase além do tratamento do 401. `ImovelViewSet.get_queryset` (web) aplica empresa, `FiltroImovelForm` e `na_vitrine`; `AcervoCubit` não filtra nem ordena e segue o `next`. Testes: `AcervoApiTests`, `contrato_acervo_test`, `acervo_cubit_test`, `acervo_fluxo_test` |
| 5 | Imóvel de outra empresa não aparece nem forçando a consulta | ✓ VERIFIED | Lado web inalterado (mixin de empresa antes de tudo, `EhCorretor` com 403). `test_isolamento_busca_situacao_e_parametros_forcados_nao_trazem_imovel_de_fora` e `test_detalhe_de_imovel_de_outra_empresa_da_404` passaram na verificação anterior; o repositório web não foi tocado desde então |
| 6 | Sem login, o app continua abrindo direto na vitrine | ✓ VERIFIED | `main.dart:52` chama `unawaited(_sessao.carregar())`; o cubit só lê o aparelho. O Dio público não tem interceptor nem token. `PrimingScreen` só ganhou o nome da rota da vitrine; o fluxo de abertura não mudou. `login_fluxo_test` e `priming_screen_test` (reformatado e com caso novo) passam |

**Pontuação:** 6/6 verdades verificadas (0 presentes com comportamento não verificado).

As verdades que dependem de comportamento têm teste comportamental que passa, não só presença de símbolo. Para as três correções: pilha `[Priming, Vitrine, Acervo]` para Sair e para o 401 (`acervo_screen_test`), a rota do CTA do priming é a nomeada (`priming_screen_test`), Sair com relógio simulado (`autenticacao_repository_impl_test`), e `encerrarPorExpiracao` descarta o token, emite anônima e sobrevive a `apagar()` lançando `PlatformException` (`sessao_cubit_test`).

### Itens adiados

Nenhum. Não há fase posterior do milestone que cubra algo desta fase.

### Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `Web/contas/api/views.py` e `urls.py` | `LoginAPIView` endurecida, `EuAPIView`, `SairAPIView` | ✓ VERIFIED | Repositório web inalterado |
| `Web/core/throttles.py` | Limite por e-mail (hash SHA-256) e por IP | ✓ VERIFIED | Inalterado |
| `Web/imoveis/api/views.py` e `serializers.py` | Acervo paginado, filtrado e enxuto | ✓ VERIFIED | Inalterado |
| `lib/data/network/interceptador_sessao.dart` | Token só na mesma origem, 401 tipado | ✓ VERIFIED | Só o comentário mudou; compare-and-delete e `reject` com `SessaoExpiradaException` intactos |
| `lib/di/modulo_rede.dart` | Segundo Dio `@Named('autenticado')`, `followRedirects:false` | ✓ VERIFIED | Sem alteração |
| `lib/data/datasources/acervo_remote_datasource.dart` | `next` só da mesma origem | ✓ VERIFIED | Sem alteração |
| `lib/data/repositories/*_repository_impl.dart` | Falhas tipadas, `sair` nunca lança | ✓ VERIFIED | `sair` agora limitado a 5 s e ainda sem lançar |
| `lib/presentation/{login,sessao,acervo}/` | Telas e Cubits | ✓ VERIFIED | Sem regra de negócio nem rede na UI; `rota_vitrine.dart` e `encerrarPorExpiracao` só tratam navegação e sessão local |
| `lib/domain/usecases/descartar_sessao_usecase.dart` | Use case de descarte local | ✓ VERIFIED | Existe, injetável, ligado ao `SessaoCubit` no DI gerado |
| `.planning/.../01-CONTRATO-API.md` §14 e `test/fixtures/api/*.json` | Contrato e fixtures capturadas (API-09) | ✓ VERIFIED | Sem alteração; `contrato_acervo_test` verde |

### Verificação de ligações

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|----------|
| `main.dart` | `SessaoCubit` | `BlocProvider.value` acima do `MaterialApp` | ✓ WIRED | O construtor agora recebe 3 use cases; `injection.config.dart` passa `DescartarSessaoUseCase` |
| `BotaoSessaoTopo` | `LoginScreen` / `EntradaAreaScreen` | rótulo pelo estado da sessão | ✓ WIRED | Sem alteração |
| `EntradaAreaScreen` | 401 | `EntradaAreaSessaoExpirada` → `encerrarPorExpiracao()` → `pushReplacement(LoginScreen(aviso))` | ✓ WIRED | Verifica `navegador.mounted` depois do `await` |
| `AcervoScreen` | 401 | `BlocListener` → `encerrarPorExpiracao()` → `pushAndRemoveUntil(LoginScreen, eRotaDaVitrine)` | ✓ WIRED | Captura `Navigator` antes do `await` e checa `mounted` |
| `confirmarESair` | vitrine | `sair()` → `popUntil(eRotaDaVitrine)` | ✓ WIRED | Para na rota nomeada ou na primeira |
| `PrimingScreen` | rota da vitrine | `MaterialPageRoute(settings: configuracaoRotaVitrine)` | ✓ WIRED | Único ponto que empurra a vitrine por cima do priming |
| `SessaoCubit` | `AutenticacaoRepository` | `DescartarSessaoUseCase` → `descartarSessaoLocal()` → `_apagarTokenLocal()` | ✓ WIRED | Nunca lança |
| `AcervoScreen` | `AcervoCubit` → use case → repositório → datasource → Dio autenticado | injeção por `getIt` | ✓ WIRED | Sem alteração |
| `ImovelViewSet.list` | `FiltroImovelForm` + `na_vitrine` | `get_queryset` | ✓ WIRED | Sem alteração |

### Trilha de fluxo de dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `AcervoScreen` | `itens` | `GET /api/imoveis/` pelo Dio autenticado | Sim, JSON capturado do Django alimenta os Models em `contrato_acervo_test` | ✓ FLOWING |
| `BotaoSessaoTopo` | estado da sessão | `ArmazenamentoToken.ler()`, e `encerrarPorExpiracao` volta a `anonima` | Sim | ✓ FLOWING |
| `CartaoImovelAcervo` | `naVitrine`, `meuImovel` | campos calculados no Django | Sim, o app não recalcula | ✓ FLOWING |

### Spot-checks de comportamento

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Suíte Flutter inteira | `flutter test` | 1065 passando, 0 falhas (linha de base anterior 1059, +6 dos testes das correções) | ✓ PASS |
| Análise estática | `flutter analyze lib` | 38 `info`, todos `deprecated_member_use` (igual à linha de base); nenhum de outro tipo | ✓ PASS |
| Suíte Django inteira | `manage.py test --noinput` (em `Web`) | Não reexecutada: o repositório web não mudou desde a verificação anterior (743 testes, OK) | ✓ PASS (herdado, árvore web limpa) |
| Marcadores de dívida | `grep -E "TBD\|FIXME\|XXX\|TODO\|HACK"` nos arquivos tocados pelas correções | Nenhuma ocorrência | ✓ PASS |

### Execução de probes

Nenhum probe convencional (`scripts/*/tests/probe-*.sh`) foi declarado pela fase. Passo ignorado.

### Cobertura de requisitos

Os 12 IDs do pedido aparecem nos PLANs e no REQUIREMENTS.md; nenhum órfão. Todos estão `[x]` e `Complete`.

| Requisito | Plano de origem | Descrição | Status | Evidência |
|-----------|-----------------|-----------|--------|-----------|
| AUTH-01 | 08-05, 08-07, 08-10, 08-12 | Login por e-mail e senha no mesmo app | ✓ SATISFIED | `AutenticacaoRemoteDataSource.entrar`, `EntrarUseCase`, `LoginScreen` |
| AUTH-02 | 08-02, 08-03, 08-05, 08-07, 08-10, 08-12 | Sessão em `flutter_secure_storage`; Sair apaga o token mesmo sem rede e revoga no servidor | ✓ SATISFIED | `sair()` com `finally`, agora com limite real de 5 s (a ressalva do relatório anterior, WR-02, foi fechada) e `SairAPIView` |
| AUTH-03 | 08-03, 08-05, 08-10, 08-12 | Erro genérico, 429 e rede com mensagens próprias por tipo | ✓ SATISFIED | `apresentacao_login.dart`, `falhas_autenticacao.dart` |
| AUTH-04 | 08-07, 08-11, 08-12 | Sem login abre na vitrine; botão Entrar / Meu acervo sem atrasar a abertura | ✓ SATISFIED | `main.dart`, `BotaoSessaoTopo`, `SessaoCubit.carregar` |
| AUTH-05 | 08-03, 08-05, 08-07, 08-10, 08-11, 08-12 | Área do papel lida de `/api/auth/eu/`; gestor e administrador veem aviso; 401 volta ao login | ✓ SATISFIED | `EuAPIView`, `EntradaAreaCubit`, `AvisoAreaScreen`; o 401 agora também descarta o token local e volta à vitrine por baixo do login |
| AUTH-06 | 08-03, 08-12 | Limite por e-mail e IP com 429 e `Retry-After` | ✓ SATISFIED | `ThrottleLoginPorEmail`, `ThrottleLoginPorIp`, `LoginLimiteDeTentativasTests` |
| ACV-01 | 08-01, 08-06, 08-08, 08-09, 08-12 | Acervo paginado com rolagem infinita, cartão compacto com a marca "Seu" | ✓ SATISFIED | `PaginacaoAcervo`, `ImovelAcervoSerializer.meu_imovel`, `AcervoScreen` |
| ACV-02 | 08-01, 08-08, 08-09, 08-12 | Busca e situação no servidor com `FiltroImovelForm`, combináveis | ✓ SATISFIED | `get_queryset` e `parametros_consulta_acervo.dart` |
| ACV-03 | 08-01, 08-12 | Outra empresa não aparece; gestor e administrador não acessam; sem token é 401 | ✓ SATISFIED | Mixin de empresa, `EhCorretor`, testes de isolamento e de 403 |
| ACV-04 | 08-01, 08-06, 08-08, 08-09, 08-12 | Toque só abre se `na_vitrine` | ✓ SATISFIED | `cartao_imovel_acervo.dart` (`naVitrine && aoTocar != null`) |
| API-09 | 08-04, 08-12 | §14 do contrato congela as rotas, com fixtures capturadas e testes de contrato | ✓ SATISFIED | §14 do `01-CONTRATO-API.md`, `contrato_acervo_test.dart` |
| API-10 | 08-01, 08-03, 08-12 | Web entrega `eu`, `sair`, limite de login e acervo paginado, com testes | ✓ SATISFIED | `EuApiTests`, `SairApiTests`, `LoginLimiteDeTentativasTests`, `AcervoApiTests` |

### Anti-padrões encontrados

Nenhum marcador de dívida (`TBD`, `FIXME`, `XXX`) nos arquivos tocados pelas correções, e nenhum stub novo. O único `XXX` da fase continua sendo um literal de teste em `Web/imoveis/tests.py`.

Estado dos avisos do code review depois das correções:

| Achado | Estado | Observação |
|--------|--------|------------|
| WR-01 (Sair volta ao priming) | Corrigido, confirmado no código e nos testes | Falta só a conferência em aparelho |
| WR-02 (Sair até 10 s) | Corrigido, confirmado no código e no teste com `fakeAsync` | O `connectTimeout` real do Dio não foi exercitado contra rede de verdade |
| WR-03 (T-08-49 sem código) | Corrigido, confirmado no código e nos testes | Ver observação abaixo |
| WR-04 (balde por e-mail permite travar conta alheia) | Aberto | Decisão de taxa e desenho da API, entra no item humano das taxas |
| WR-05 (`LocMemCache` por processo) | Aberto | Decisão de produção da API |
| WR-06 (`next` absoluto atrás de proxy TLS) | Aberto | Decisão de produção da API |
| WR-07 (`SECRET_KEY` padrão) | Aberto, anterior à fase | Info |
| IN-01 a IN-05 | Abertos | Informativos |

Observação (informativa, não bloqueia): `encerrarPorExpiracao` apaga o token local sem a comparação "só apaga se for o mesmo token" que o interceptor faz. Um 401 tardio de um pedido antigo poderia, em tese, apagar um token novo. Na prática o acervo e a entrada só chamam isso a partir de um listener de tela viva, então o risco é muito baixo, e a escolha do corretor continua segura (o pior caso é pedir login de novo). Vale registrar, não corrigir agora.

### Verificação humana necessária

Os itens estão no frontmatter e são os mesmos da verificação anterior, com o texto dos dois primeiros e do quinto ampliado para cobrir as três correções (Sair no primeiro uso, tempo do Sair sem rede e sessão expirada voltando à vitrine). Em resumo, ficam para uma pessoa: o fluxo no emulador contra o Django real, o Keychain do iOS num Mac M1, o isolamento com o banco semeado, a decisão das taxas de login, o Sair em dois aparelhos, a aparência (incluindo 360 dp, autofill e as fraquezas do `08-UI-REVIEW`), e a autorização do push, do aviso ao time da web e da nota do `.claude/CLAUDE.md`.

### Resumo das lacunas

Não há lacunas que bloqueiem o objetivo. As seis verdades do ROADMAP, os 12 requisitos e os artefatos e ligações foram reconferidos contra o código atual: as três correções existem, estão ligadas e têm teste comportamental, e nada regrediu (1065 testes verdes, análise com a mesma linha de base de 38 `info`). Pontos que continuam para a pessoa decidir: (1) WR-04 a WR-06 são decisões de produção da API (taxa, cache compartilhado, proxy TLS) a resolver antes de publicar; (2) nenhum `git push` foi feito, então os commits do app e os 4 da web só existem localmente.

---

_Verificado: 2026-11-21_
_Verificador: Claude (gsd-verifier)_
