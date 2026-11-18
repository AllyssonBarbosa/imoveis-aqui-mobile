---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
reviewed: 2026-11-18T20:39:01Z
depth: standard
files_reviewed: 47
files_reviewed_list:
  - ../imoveis-aqui/Web/.env.example
  - ../imoveis-aqui/Web/config/settings.py
  - ../imoveis-aqui/Web/contatos/api/views.py
  - ../imoveis-aqui/Web/contatos/servicos.py
  - ../imoveis-aqui/Web/contatos/tests.py
  - ../imoveis-aqui/Web/core/throttles.py
  - ../imoveis-aqui/Web/imoveis/api/serializers.py
  - ../imoveis-aqui/Web/imoveis/api/views.py
  - ../imoveis-aqui/Web/imoveis/tests.py
  - ../imoveis-aqui/Web/site_publico/tests.py
  - ../imoveis-aqui/Web/static/css/painel.css
  - ../imoveis-aqui/Web/templates/contas/painel_home.html
  - lib/data/datasources/contato_datasource.dart
  - lib/data/datasources/contato_remote_datasource.dart
  - lib/data/gateways/url_launcher_gateway_impl.dart
  - lib/data/models/canal_contato_api.dart
  - lib/data/models/contato_registrado_model.dart
  - lib/data/models/detalhe_imovel_model.dart
  - lib/data/repositories/contato_repository_impl.dart
  - lib/domain/entities/canal_contato.dart
  - lib/domain/entities/contato_do_imovel.dart
  - lib/domain/entities/detalhe_imovel.dart
  - lib/domain/gateways/link_launcher_gateway.dart
  - lib/domain/repositories/contato_repository.dart
  - lib/domain/usecases/contatar_corretor_usecase.dart
  - lib/presentation/contato/contato_cubit.dart
  - lib/presentation/contato/contato_state.dart
  - lib/presentation/contato/rotulos_contato.dart
  - lib/presentation/contato/widgets/barra_contato.dart
  - lib/presentation/contato/widgets/contato_bottom_sheet.dart
  - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
  - lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
  - pubspec.yaml
  - test/data/contato_remote_datasource_test.dart
  - test/data/contato_repository_impl_test.dart
  - test/data/contrato_contato_test.dart
  - test/data/contrato_detalhe_test.dart
  - test/data/detalhe_imovel_model_test.dart
  - test/data/url_launcher_gateway_impl_test.dart
  - test/domain/contatar_corretor_usecase_test.dart
  - test/presentation/barra_contato_test.dart
  - test/presentation/contato_cubit_test.dart
  - test/presentation/detalhe_imovel_screen_test.dart
  - test/presentation/detalhe_navegacao_test.dart
  - test/presentation/perfil_corretor_screen_test.dart
  - test/support/api_falsa.dart
  - tool/capturar_fixtures_api.py
findings:
  critical: 0
  warning: 5
  info: 7
  total: 12
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-11-18T20:39:01Z
**Depth:** standard
**Files Reviewed:** 47
**Status:** issues_found

## Narrative Findings (AI reviewer)

## Summary

The review covered the API side of the phase (uncommitted working tree on `feat/APP06` in `../imoveis-aqui`, on top of merge `7d4f5cd`) and the app side (commits from `08728f3^` to `HEAD`).

**Merge sanity (`painel.css`, `painel_home.html`):** The merge is clean. Neither file, and nothing else under `Web/`, contains conflict markers. In `painel.css`, the main side's `.filtros*` rules and W11's `.texto-suave` / `.filtros-contatos` / `.retorno-contato` rules both appear in full. In `painel_home.html`, main's "Imóveis da empresa" and "Loteamentos" links and W11's "Contatos da empresa" and "Meus contatos" links are all kept, each under the right profile.

**Overall:** The core flow is correct:
- Typed failures run end to end, from `DioException` to the `Failure` in the repository to the `MotivoFalhaContato` in the cubit and then the SnackBar.
- The client checks every link against an allowlist for its channel.
- The cubit blocks a double tap while a POST is in flight.
- The detail API exposes channel names only. `select_related("empresa")` keeps the number of queries flat.
- `%20` encoding and the separate throttle bucket are both tested.

No blockers. The warnings fall in three groups:
- The new contact throttle can be bypassed through the site's own form endpoint.
- The fixture-capture tool's default group now writes data.
- Some app edge cases: a duplicate contact across the two screens, and the bar overflowing at large text scales.

## Warnings

### WR-01: Contact throttle is bypassed by the unthrottled site form endpoint

**File:** `../imoveis-aqui/Web/contatos/api/views.py:30` (also `../imoveis-aqui/Web/core/throttles.py:16-25`; root cause is in `../imoveis-aqui/Web/site_publico/views.py:133-147`)
**Issue:** `ThrottleContatoPublico` was added because the public POST "grava na caixa do corretor" (writes to the broker's inbox) and has no login. The site's `site_publico:contato` view calls the same `registrar_contato()` with no throttle. Its only protection is CSRF, which a script gets past with one GET for the token and cookie, then as many POSTs as it likes. Anyone trying to flood a broker's inbox just switches endpoints. The API rate limit is therefore not a real control on how many `Contato` rows get written.
**Fix:** Apply the same per-IP limit on the site path, ideally in the shared code so both entry points hit the same bucket. Example in the site view:
```python
from core.throttles import ThrottleContatoPublico

@require_POST
def contato(request, pk):
    limite = ThrottleContatoPublico()
    if not limite.allow_request(request, None):
        return HttpResponse(status=429, headers={"Retry-After": str(int(limite.wait() or 60))})
    ...
```
`allow_request` needs a DRF-style request with `.user`. If that gets awkward, move the counter into a small helper in `contatos/servicos.py`, keyed on the client IP from `get_ident`, and call it from both views. Add a test that the site endpoint also returns 429 after N posts.

### WR-02: The capture tool's default group (`todos`) now writes Contato rows to whatever server it targets

**File:** `tool/capturar_fixtures_api.py:225-276, 286-297`
**Issue:** Before this phase, `--grupo todos` (the default) and the default URL `http://127.0.0.1:8000` only ran GETs. `todos` now includes `contato`, which sends three POSTs that each create a `Contato` row in a real broker's inbox. The warning that this must never run against the `Web/.env` database is only in the docstring. Running `python3 tool/capturar_fixtures_api.py` with no arguments while the normal dev server is up (Postgres from `.env`) writes fake contacts into that database.
**Fix:** Leave the write group out of `todos`, require an explicit opt-in, or both:
```python
GRUPOS_LEITURA = {"lista": capturar_lista, "detalhe": capturar_detalhe}
...
grupos = list(GRUPOS_LEITURA) if argumentos.grupo == "todos" else [argumentos.grupo]
if "contato" in grupos and not argumentos.permitir_gravacao:
    raise ErroCaptura("O grupo `contato` grava Contato no servidor; passe --permitir-gravacao (só SQLite temporário).")
```

### WR-03: The double-tap guard is per screen, so the detail page and the profile can register the same contact twice

**File:** `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:194-204`, `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart:39-42`
**Issue:** D-13 blocks a duplicate contact by disabling the buttons while a POST is in flight. The broker card in the detail body stays tappable during that time, though. `abrirPerfilCorretor` then builds a fresh `ContatoCubit` (state `ocioso`) for the profile. Sequence:
1. The visitor taps WhatsApp on the detail page.
2. While the POST is still in flight, they tap the broker card.
3. They tap WhatsApp again on the profile.

The result is two `Contato` rows and two `wa.me` launches, because `ContatarCorretorUseCase` still opens the first link after navigation (documented decision). The SnackBar from the first cubit can also show up on the profile screen.
**Fix:** Pass the page's existing `ContatoCubit` to the profile route instead of creating a new one, so a single "in flight" state covers both screens:
```dart
aoTocar: () => abrirPerfilCorretor(
  context,
  corretor,
  contato: ...,
  criarContatoCubit: null,
  cubitExistente: context.read<ContatoCubit>(), // BlocProvider.value in the route
),
```
Alternatively, disable `CartaoCorretor.aoTocar` while `ContatoCubit.state is ContatoEnviando`.

### WR-04: `BarraContato` has no flexible fallback for its action row and overflows at large text scales or narrow widths

**File:** `lib/presentation/contato/widgets/barra_contato.dart:43-96`
**Issue:** The outer `Row` holds `Expanded(legenda)`, a 16 px gap, and an inner `Row(mainAxisSize: min)` with the ⋮ `IconButton` and a `FilledButton.icon` whose label is not constrained. The legend can shrink to 0, but the action row cannot shrink at all. At large accessibility text sizes (iOS goes past 2x, and Android 14 allows 2x), or on a 320 dp device, "WhatsApp" or "Enviar e-mail" plus the ⋮ is wider than the bar, causing a `RenderFlex overflowed` error and clipping the primary CTA. The legend has a measured layout (`_LegendaPrecoDaBarra`), but the button side has none. None of the widget tests set `textScaler`.
**Fix:** Let the button shrink and ellipsize, for example by wrapping the `FilledButton.icon` in `Flexible` and giving the label `maxLines: 1, overflow: TextOverflow.ellipsis`. Or cap the legend with `Flexible(flex: …)` and allow the label to wrap. Add a widget test at `TextScaler.linear(2.0)` on a 320 px surface that checks `tester.takeException()` is null.

### WR-05: A default of 10 contacts per minute per IP will return 429 to legitimate mobile users behind carrier NAT

**File:** `../imoveis-aqui/Web/config/settings.py:148`, `../imoveis-aqui/Web/.env.example:12`
**Issue:** Brazilian mobile carriers make heavy use of CGNAT, so many subscribers share one public IPv4 address. With `NUM_PROXIES` set correctly, the throttle key is that shared carrier IP. Ten contact POSTs per minute across everyone behind it is the core conversion action of the app, and legitimate visitors will get "Muitas tentativas…" (too many attempts). The vitrine bucket is 120/min, so contact is the tighter limit by an order of magnitude.
**Fix:** Raise the default (for example `30/min`), or add a second, longer-window scope such as `100/hour`. Write down in `.env.example` that the value is per shared IP, so it should be sized for NAT and not for a single person. An abuse limit keyed per imóvel+IP would be stricter against flooding without hurting shared IPs.

## Info

### IN-01: `ThrottleContatoPublico` inherits from `ThrottleVitrinePublica`, coupling their rates through the `rate` attribute

**File:** `../imoveis-aqui/Web/core/throttles.py:16`, `../imoveis-aqui/Web/contatos/tests.py` (`test_contato_herda_a_taxa_alta_da_suite`)
**Issue:** The two buckets are meant to be independent, but `rate` set on the parent class is inherited, and the test suite depends on exactly that. If anyone later sets a class-level `rate` on `ThrottleVitrinePublica`, the contact throttle quietly takes 120/min.
**Fix:** Subclass `AnonRateThrottle` directly. In the test `VitrineBase.setUp`, patch the two classes separately.

### IN-02: `UrlLauncherGatewayImpl` catches `Error`, which hides programming bugs

**File:** `lib/data/gateways/url_launcher_gateway_impl.dart:26-28`
**Issue:** `on Error { return false; }` also swallows `StateError`, `TypeError` and `AssertionError`. A wiring bug then shows up as "Nenhum aplicativo para abrir este contato." (no app to open this contact), even though the contact was already registered.
**Fix:** Catch only `ArgumentError`, the documented iOS invalid-URL case, alongside `PlatformException`/`Exception`.

### IN-03: The link allowlist checks only the scheme for `tel:` and `mailto:`

**File:** `lib/data/repositories/contato_repository_impl.dart:61-65`
**Issue:** As defense in depth, `tel:` accepts any path, including USSD/MMI strings such as `tel:*21*...%23`, and `mailto:` accepts any header (`bcc`, `cc`, `attach`). WhatsApp already checks the host too.
**Fix:** Tighten the checks cheaply. Example: `CanalContato.telefone => uri.scheme == 'tel' && RegExp(r'^\+?\d+$').hasMatch(uri.path)`. For mailto, require that `uri.queryParameters.keys` is a subset of `{'subject', 'body'}`.

### IN-04: One non-string element in `canais_contato` makes the whole detail page fail

**File:** `lib/data/models/detalhe_imovel_model.dart:54-58` (generated `.g.dart:51-55`)
**Issue:** The generated `e as String` throws a `TypeError`. The repository maps that to `FormatException`, so the whole detail page shows an error state, not just a hidden contact area (D-03). Unknown string names are handled leniently, but non-string values are not.
**Fix:** Declare the field as `List<Object?>` and keep only strings in `paraEntidade()`, or use a custom `fromJson` for this key.

### IN-05: The `Loading` branches in the use case and cubit are dead code

**File:** `lib/domain/usecases/contatar_corretor_usecase.dart:36-37`, `lib/presentation/contato/contato_cubit.dart:35-36`
**Issue:** The repository never returns `Result.loading()`. If it ever did, the cubit would silently go back to `ocioso` with no feedback.
**Fix:** Treat `Loading` as an unexpected failure (`MotivoFalhaContato.generico`), or add a comment explaining why it can't happen.

### IN-06: `PerfilCorretorScreen.contato` is public but crashes without a `ContatoCubit` provider

**File:** `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart:56-66`
**Issue:** Building `PerfilCorretorScreen(contato: ...)` directly, outside `abrirPerfilCorretor`, throws `ProviderNotFoundException` on the first build. D-11 says the APP 07 rewrite of this screen will plug the component in, which makes this an integration trap.
**Fix:** Have `PerfilCorretorScreen` (or `BarraContato`) create its own `BlocProvider` when none is found above it. Or make the constructor private to the route helper and document the requirement at the public API.

### IN-07: Import grouping in `contatos/tests.py`

**File:** `../imoveis-aqui/Web/contatos/tests.py:20-23`
**Issue:** `from .api.views ...` and `from .servicos ...` sit apart from `from .models import Contato`, separated by a blank line. isort would merge them into one local group.
**Fix:** Put the three relative imports together in one block.

---

_Reviewed: 2026-11-18T20:39:01Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
