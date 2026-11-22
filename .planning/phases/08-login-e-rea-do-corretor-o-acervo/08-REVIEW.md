---
phase: 08-login-e-rea-do-corretor-o-acervo
reviewed: 2026-11-21T00:00:00Z
depth: standard
files_reviewed: 60
files_reviewed_list:
  - C:/projetos/imoveis-aqui-mobile/android/app/src/main/AndroidManifest.xml
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/acervo_datasource.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/acervo_remote_datasource.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/armazenamento_token.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/armazenamento_token_seguro.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/autenticacao_datasource.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/autenticacao_remote_datasource.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/datasources/parametros_consulta_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/models/acervo_envelope_model.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/models/eu_model.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/models/imovel_acervo_model.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/network/interceptador_sessao.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/network/mesma_origem.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/repositories/acervo_repository_impl.dart
  - C:/projetos/imoveis-aqui-mobile/lib/data/repositories/autenticacao_repository_impl.dart
  - C:/projetos/imoveis-aqui-mobile/lib/di/modulo_rede.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/entities/consulta_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/entities/imovel_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/entities/pagina_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/entities/papel.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/entities/situacao_imovel.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/repositories/acervo_repository.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/repositories/autenticacao_repository.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/repositories/falhas_autenticacao.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/usecases/buscar_acervo_usecase.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/usecases/entrar_usecase.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/usecases/ler_sessao_usecase.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/usecases/obter_papel_usecase.dart
  - C:/projetos/imoveis-aqui-mobile/lib/domain/usecases/sair_usecase.dart
  - C:/projetos/imoveis-aqui-mobile/lib/main.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/acervo_cubit.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/acervo_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/acervo_state.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/apresentacao_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/widgets/cartao_imovel_acervo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/acervo/widgets/chips_situacao.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/cidade_selecao/cidade_selecao_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/login/apresentacao_login.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/login/login_cubit.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/login/login_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/login/login_state.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/priming/priming_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/aviso_area_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/botao_sessao_topo.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/dialogo_sair.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/entrada_area_cubit.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/entrada_area_screen.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/entrada_area_state.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/sessao_cubit.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/sessao/sessao_state.dart
  - C:/projetos/imoveis-aqui-mobile/lib/presentation/vitrine/vitrine_screen.dart
  - C:/projetos/imoveis-aqui-mobile/pubspec.yaml
  - C:/projetos/imoveis-aqui-mobile/tool/capturar_fixtures_api.py
  - C:/projetos/imoveis-aqui/Web/.env.example
  - C:/projetos/imoveis-aqui/Web/config/settings.py
  - C:/projetos/imoveis-aqui/Web/contas/api/urls.py
  - C:/projetos/imoveis-aqui/Web/contas/api/views.py
  - C:/projetos/imoveis-aqui/Web/core/throttles.py
  - C:/projetos/imoveis-aqui/Web/imoveis/api/serializers.py
  - C:/projetos/imoveis-aqui/Web/imoveis/api/views.py
findings:
  critical: 0
  warning: 7
  info: 5
  total: 12
  necessity: 1
status: issues_found
---

# Phase 8: Code Review Report

**Reviewed:** 2026-11-21
**Depth:** standard
**Files Reviewed:** 60 (app Flutter + API Django)
**Status:** issues_found

## Summary

Revisei o login por token, a sessão, o acervo do corretor (app) e os endpoints correspondentes na API Django. A base é sólida: o token só viaja para a mesma origem da base URL (interceptor + guarda do `next`), o 401 vira exceção tipada, o isolamento por empresa vem do mixin e o `Exists(na_vitrine)` no servidor evita regra de negócio no celular. Não encontrei vulnerabilidade crítica nem perda de dados.

Os problemas reais são de fluxo e robustez: a navegação de "Sair"/"sessão expirada" usa `isFirst` e, no primeiro uso do app, devolve o usuário à tela de priming em vez da vitrine. O "Sair" pode travar por 10 s apesar do comentário de 5 s. Uma salvaguarda documentada (T-08-49) não existe no código. O limite de tentativas de login é contornável por multiplicidade de workers e permite bloquear a conta alheia. O `next` absoluto gerado pelo Django quebra a paginação do app atrás de proxy TLS.

## Narrative Findings (AI reviewer)

## Warnings

### WR-01: "Sair" e "sessão expirada" usam `isFirst` e levam ao priming no primeiro uso, não à vitrine

**File:** `lib/presentation/sessao/dialogo_sair.dart:39` (também `lib/presentation/acervo/acervo_screen.dart:97-101`, `lib/main.dart:112-117`, `lib/presentation/priming/priming_screen.dart:66-73`)
**Issue:** Sem cidade salva, a primeira rota (`_TelaInicial`) exibe a `PrimingScreen`, e a vitrine é uma rota empurrada por cima dela (`PrimingScreen._aoTocarUsarLocalizacao`). Pilha típica: `[Priming, Vitrine, Acervo]`. `confirmarESair` faz `popUntil((rota) => rota.isFirst)` e o 401 faz `pushAndRemoveUntil(..., (rota) => rota.isFirst)`. Nos dois casos a vitrine é descartada e o usuário cai na tela "Vamos te levar direto pra sua cidade" (ou, no 401, ela fica por baixo do login e o "voltar" do login leva a ela), apesar de os comentários e do AC-2 dizerem "volta à vitrine". Só funciona quando já existe cidade salva (aí a primeira rota é a vitrine). A cidade já foi escolhida, então a tela de priming é um passo regredido.
**Fix:** Não depender de `isFirst`. Marque a rota da vitrine com `RouteSettings(name: 'vitrine')` (em `PrimingScreen` e na `home` do caso `entraDireto`) e use `popUntil((r) => r.settings.name == 'vitrine' || r.isFirst)`. Alternativa: no fluxo do priming, trocar a rota com `pushReplacement` em vez de `push`, para a vitrine ser a primeira rota.

### WR-02: "Sair" pode ficar até 10 s sem feedback; o comentário promete 5 s

**File:** `lib/data/datasources/autenticacao_remote_datasource.dart:54-61` (consumido em `lib/presentation/sessao/dialogo_sair.dart:37`)
**Issue:** O `Options(sendTimeout: 5s, receiveTimeout: 5s)` não cobre a conexão: o `connectTimeout` de 10 s do `BaseOptions` (`modulo_rede.dart:29`) continua valendo e `Options` do Dio não permite sobrescrevê-lo por requisição. Com o servidor inalcançável, `SairUseCase` só retorna depois de ~10 s (o `finally` que apaga o token roda depois do `await _dataSource.sair()`), e `confirmarESair` só faz o `popUntil` depois disso. Durante esse tempo o diálogo já fechou, não há indicador de progresso e a tela de origem continua interativa (toque duplo dispara dois pedidos). O contrato "espera no máximo 5 s" documentado no datasource e em `AutenticacaoRepository.sair()` é falso.
**Fix:** Limitar a espera de verdade, por exemplo em `AutenticacaoRepositoryImpl.sair`:
```dart
try {
  await _dataSource.sair().timeout(const Duration(seconds: 5));
} on Exception { /* TimeoutException também é Exception */ }
```
(ou usar um `CancelToken` com `Timer`). Opcionalmente apagar o token local antes de pedir a revogação e mostrar um indicador enquanto `sair()` roda.

### WR-03: A salvaguarda T-08-49 (re-descartar a sessão local após falha ao apagar) não existe no código

**File:** `lib/data/network/interceptador_sessao.dart:61-69`; `lib/data/repositories/acervo_repository_impl.dart:43-48`; `lib/presentation/acervo/acervo_screen.dart:95-96`
**Issue:** O comentário do interceptor afirma que, se `apagar()` lançar `PlatformException`, "o repositório descarta a sessão local de novo ao receber a falha (T-08-49)". Nenhum caminho faz isso: `AcervoRepositoryImpl` não conhece o armazenamento, `AutenticacaoRepositoryImpl._executar` só devolve `SessaoExpiradaException`, e o único chamador de `descartarSessaoLocal()` é o rollback do `EntrarUseCase`. As telas só chamam `SessaoCubit.marcarAnonima()` (estado em memória). Além disso, o `onError` só apaga se `ler()` devolver o mesmo token, e `ler()` devolve `null` quando o Keystore falha. Resultado: se o armazenamento falhar nesse momento, o token revogado permanece gravado; na próxima abertura o botão volta a "Meu acervo", leva a 401 e a um novo login com aviso, em ciclo, até o armazenamento voltar.
**Fix:** Tornar o contrato real: ao receber `SessaoExpiradaException`, o `SessaoCubit` (ou um use case) chama `descartarSessaoLocal()` antes de `marcarAnonima()`. Por exemplo `SessaoCubit.marcarAnonima()` virar `Future<void> encerrarPorExpiracao()` que invoca um `DescartarSessaoUseCase` (que não lança, por contrato) e depois emite anônima. Corrigir o comentário se a decisão for não fazer.

### WR-04: Limite de login por e-mail permite bloquear a conta alheia e conta logins bem-sucedidos

**File:** `Web/core/throttles.py:18-39` (uso em `Web/contas/api/views.py:27`)
**Issue:** O balde `login_email` conta toda tentativa, de qualquer IP, com senha certa ou errada, e a chave é só o e-mail. Qualquer pessoa que conheça o e-mail de um corretor pode mandar 10 tentativas por hora e deixá-lo em 429 indefinidamente (negação de serviço dirigida; do mesmo IP dá para travar 3 contas por hora com `login_ip=30/hour`). Como logins bem-sucedidos também consomem o balde, um corretor que sai e entra várias vezes (ou testa em vários aparelhos) bloqueia a si mesmo. O bloqueio também não distingue "dono legítimo" de atacante, e o app só mostra "Muitas tentativas".
**Fix:** Contar só falhas (por exemplo, limpar/não registrar o histórico em caso de sucesso, sobrescrevendo `allow_request` e invalidando a chave no `post` quando a autenticação passa), e/ou combinar e-mail+IP na chave do balde por e-mail, mantendo o balde por IP isolado para o teto global. Documentar a escolha em `.env.example`.

### WR-05: Os limites de taxa dependem do cache padrão (LocMem) e não valem entre workers

**File:** `Web/config/settings.py:177-198` (sem `CACHES`); `Web/core/throttles.py`
**Issue:** O DRF guarda o histórico dos throttles no cache padrão do Django. `settings.py` não define `CACHES`, então vale `LocMemCache`, que é por processo: com gunicorn/uwsgi de N workers, a taxa efetiva do login vira até N × (10/hora por e-mail, 30/hora por IP), e qualquer reinício zera os contadores. Isso enfraquece justamente o controle de força bruta que esta fase adicionou, e o `check --deploy` (`core.W001`) só avisa de `NUM_PROXIES`, não do cache.
**Fix:** Configurar um cache compartilhado em produção (Redis/Memcached/`DatabaseCache`) via variável de ambiente e acrescentar uma verificação em `core/checks.py` que avise quando o backend for `LocMemCache` fora do `DEBUG`.

### WR-06: `next` absoluto montado pela requisição quebra a paginação do app atrás de proxy TLS

**File:** `Web/imoveis/api/views.py:69-72` e `Web/config/settings.py` (sem `SECURE_PROXY_SSL_HEADER`/`USE_X_FORWARDED_HOST`); guarda correspondente em `lib/data/datasources/acervo_remote_datasource.dart:35-43`
**Issue:** O `PageNumberPagination` monta `next` com `request.build_absolute_uri()`. Atrás de um proxy que termina TLS sem `SECURE_PROXY_SSL_HEADER`, o Django enxerga HTTP e devolve `next` com `http://`, enquanto `API_BASE_URL` do app é `https://`. `mesmaOrigem` compara scheme e porta, rejeita com `FormatException` e a segunda página nunca carrega (o rodapé fica preso em "Tentar de novo", e retry reproduz o mesmo erro). Em desenvolvimento funciona (mesmo host e porta), então o defeito só aparece em produção.
**Fix:** Configurar no Django `SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")` (condicionado ao ambiente) e documentar no `.env.example`. No app, opcionalmente reescrever o `next` para a origem da base URL (usar só `path` + `query` do `next`), em vez de rejeitar, já que a origem é validada de qualquer forma.

### WR-07: `SECRET_KEY` com valor padrão inseguro e `DEBUG` desligado por padrão

**File:** `Web/config/settings.py:19`
**Issue:** `env("DJANGO_SECRET_KEY", default="django-insecure-trocar-em-producao")` faz o servidor subir em produção, sem erro, com uma chave pública no repositório se a variável faltar (`DEBUG` padrão é `False`, então nada alerta). A chave assina sessões e CSRF do painel que divide o processo com a API de token. Não foi introduzido nesta fase (vem do commit W01/W02), mas está no arquivo revisado e a fase passou a expor a API a clientes móveis.
**Fix:** Exigir a variável quando `DEBUG` for falso:
```python
SECRET_KEY = env("DJANGO_SECRET_KEY", default="django-insecure-dev" if DEBUG else None)
if not SECRET_KEY:
    raise ImproperlyConfigured("DJANGO_SECRET_KEY é obrigatória fora do DEBUG.")
```
(ler `DEBUG` antes de `SECRET_KEY`).

## Info

### IN-01: Impossible-state guard — `on SessaoExpiradaException` direto nos repositórios

**File:** `lib/data/repositories/acervo_repository_impl.dart:43-44` (e `lib/data/repositories/autenticacao_repository_impl.dart:87-88`)
**Category:** necessity
**Issue:** O ramo `on SessaoExpiradaException` (exceção lançada crua) não ocorre nesta pilha: a única origem da exceção é `InterceptadorSessao.onError` (`interceptador_sessao.dart:70`), que a embrulha em `DioException.error`, e nenhuma DataSource a lança (busca em `lib/` não encontra outro `throw`). O tratamento relevante é o do `DioException` logo abaixo. Pode ser mantido como rede de segurança para DataSources trocáveis nos testes; é julgamento, não prova.
**Fix:** Remover o ramo direto, ou manter com comentário explicitando que existe para DataSources falsas.

### IN-02: Token no Keychain/Keystore sobrevive à reinstalação no iOS

**File:** `lib/di/modulo_rede.dart:69-70`, `lib/data/datasources/armazenamento_token_seguro.dart:14-38`
**Issue:** `const FlutterSecureStorage()` usa as opções padrão. No iOS, itens do Keychain persistem depois de desinstalar o app; o app reinstalado abre direto com "Meu acervo" e um token ainda válido (o servidor não o expira). Em aparelho revendido ou emprestado isso entrega a sessão do corretor. O padrão de acessibilidade também não é `...ThisDeviceOnly`.
**Fix:** Gravar um marcador de primeira execução em `SharedPreferences` (que é apagado na desinstalação) e apagar o token se o marcador não existir; considerar `IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device)`.

### IN-03: Token de API não expira e é único por usuário

**File:** `Web/contas/api/views.py:33-34`, `Web/contas/api/views.py:61-63`
**Issue:** `get_or_create` devolve sempre a mesma chave, sem validade. Um token vazado vale até alguém fazer Sair, e Sair em um aparelho desconecta todos os outros (documentado, mas surpreendente para o corretor com dois aparelhos). Trocar a senha também não invalida o token.
**Fix:** Decisão de produto; se mantida, registrar como risco aceito. Opções: token com validade/rotação por aparelho, ou apagar o token na troca de senha.

### IN-04: 403 no acervo e na entrada da área vira "Tentar de novo" eterno

**File:** `lib/presentation/acervo/acervo_cubit.dart:202-209`, `lib/presentation/sessao/entrada_area_cubit.dart:26-32`
**Issue:** O repositório converte 403 em `SemPermissaoException` (caso real: corretor promovido a gestor depois do login, ou o papel mudou), mas o Cubit trata qualquer falha que não seja 401 como erro genérico repetível. O usuário fica num ciclo de "Tentar de novo" que sempre falha, sem roteamento para o papel atual (que o `EntradaAreaScreen` resolveria reabrindo).
**Fix:** Tratar `SemPermissaoException` como estado próprio (ou reentrar pela `EntradaAreaScreen`) em vez do erro repetível.

### IN-05: Script de captura anuncia revogação de tokens que não faz e segue qualquer URL

**File:** `tool/capturar_fixtures_api.py:70-71`, `:365-369`, `:388-407`
**Issue:** O docstring diz que as chaves reais são "revogadas no fim (Sair)", mas só a do corretor é revogada; as de `token_outra` e `token_gestor` ficam ativas. O script aceita qualquer `URL_BASE` e envia o `Authorization` ao `next` devolvido pela resposta sem checar origem (o `urllib` ainda repassa o cabeçalho em redirecionamentos); apontado por engano para um ambiente real, ele logaria com credenciais reais e faria Sair, revogando a chave do usuário. A regra "nunca contra o banco do Web/.env" é só texto.
**Fix:** Revogar os três tokens no fim (`finally`), recusar `URL_BASE` que não seja `127.0.0.1`/`localhost` no grupo `acervo` (ou exigir `--permitir-host-remoto`), e conferir que `next` tem a mesma origem antes de reenviar o token.

---

_Reviewed: 2026-11-21_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
