# Phase 6: Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06) - Research

**Researched:** 2026-11-16
**Domain:** Flutter (Clean Architecture, dio, freezed, injectable, flutter_bloc) + `url_launcher` + pequena extensão da API Django/DRF (`../imoveis-aqui`, WEB-11 + `canais_contato`)
**Confidence:** HIGH para o contrato do POST da W11, para o comportamento do `url_launcher` (código-fonte lido no pub-cache) e para o estado do app; MEDIUM para o merge da WEB-11 na `main` da API (só `git merge-tree` foi rodado, nenhum teste do Django) e para o comportamento do WhatsApp em aparelho real (só o human-check confirma).

> Pesquisa somente-leitura: nenhum arquivo de código foi alterado, nenhum commit/push/checkout/merge foi feito em nenhum dos dois repositórios. `git merge-tree --write-tree` grava objetos soltos no `.git` da API (não mexe em refs nem na árvore de trabalho). O repo da API continua em `main`, limpo.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Canais disponíveis**
- **D-01:** O detalhe público `GET /api/publico/imoveis/{id}/` (`ImovelVitrineDetalheSerializer`) ganha **`canais_contato: ["WHATSAPP", "TELEFONE", "EMAIL"]`** (subconjunto, ordem fixa), calculado no servidor por `canais_disponiveis(imovel)` da W11 (`contatos/servicos.py`). Só os **nomes** dos canais são expostos, nunca número, e-mail nem link: o link (com o código interno do imóvel) só sai do servidor no POST, no momento do toque (mesma regra que a W11 usa no site). Com teste no padrão de `Web/imoveis/tests.py`, incluindo a allowlist (nenhum telefone, WhatsApp ou e-mail no JSON por causa disso). — **Reversibility:** costly — é um campo novo no contrato público compartilhado com a web; mudar depois mexe no serializer, no Model Dart e nos fixtures de teste.
- **D-02:** O app **nunca deduz canais** a partir dos dados do corretor. A regra "corretor desativado → contato vai para a empresa" e o fallback para os dados da empresa são do Django (W10/W11). Mantém a F5/D-16: telefone, WhatsApp e e-mail do corretor não entram em entidade de domínio.
- **D-03:** `canais_contato` vazio (ou ausente) → **a área de contato some** (F4/D-14).
- **D-04:** `canais_contato` **só no detalhe**. A lista da vitrine não muda.

**Layout na página do imóvel**
- **D-05:** **Barra inferior fixa** (prevista desde a F4/D-12) com o **preço à esquerda** e, à direita, o **botão principal** (`FilledButton`) mais um **botão secundário ⋮** que abre um **bottom sheet** com os demais canais ("Ligar", "Enviar e-mail").
- **D-06:** **Botão principal = primeiro canal disponível na ordem fixa WhatsApp → Telefone → E-mail.** O ⋮ só aparece se sobrar algum canal além do principal.
- **D-07:** O preço da barra é o **mesmo texto de preço que o topo do detalhe e o `ImovelCard` já usam** (reaproveitar a formatação existente, sem regra nova). Em VENDA_E_ALUGUEL longo demais, a barra mostra o principal e o resto fica no topo.
- **D-08:** A barra **só aparece quando o detalhe carregou** (estado de sucesso, com canais). Não aparece na prévia (F4/D-16), no 404 nem no erro.

**Perfil do corretor**
- **D-09:** O perfil do corretor mostra contato **somente quando foi aberto a partir de um imóvel**: a navegação passa o id (e o título) do imóvel e os canais já carregados. O toque usa o **mesmo** `POST /imoveis/{id}/contato/`. Assim o registro guarda imóvel, corretor e canal, sem mudar o model `Contato` da W11. Aberto sem imóvel (por exemplo, vindo da página da empresa do APP 07) → sem botões.
- **D-10:** No perfil, o contato usa **o mesmo componente de barra fixa**, com o texto **"Sobre: <título do imóvel>"** no lugar do preço.
- **D-11:** **Componente isolado e reutilizável**: o contato vira widget(s) + Cubit próprios em `presentation/` (sem depender da tela), plugados na página do imóvel e na **tela stub atual** do perfil (`perfil_corretor_screen.dart` na main). A branch `origin/feat/APP07` (Allysson, não mergeada, reescreve essa tela) **não é base** desta fase. Quem mergear por último encaixa o componente na tela do APP 07. O usuário avisa o Allysson. — **Reversibility:** reversible.

**API e falhas**
- **D-12:** Repo da API: branch **`feat/APP06` local**, a partir da `main`, com **merge de `origin/WEB-11`** (ainda fora da main) e, por cima, o `canais_contato` (D-01) com testes. **Sem push/PR sem OK explícito** (mesmo esquema da F5/D-03). O usuário pode avisar a Palloma (dona da W11) para mergear a WEB-11 na main.
- **D-13:** **Toque → loading no próprio botão**: spinner e botão (e ⋮/bottom sheet) desabilitados durante o POST, o que evita contato duplicado num duplo toque. Estados explícitos no Cubit (padrão F4/D-17).
- **D-14:** **Falha no POST → nada abre e aparece uma SnackBar**, por tipo: rede/timeout/5xx → "Não foi possível abrir o contato. Tente de novo."; 400 (canal indisponível) → "Este canal não está disponível para este imóvel."; 404 → "Este imóvel não está mais disponível."; 429 → "Muitas tentativas. Aguarde um pouco e tente de novo."
- **D-15:** **POST ok, mas o aparelho não abre o link** (mailto sem app de e-mail, tel: em tablet) → SnackBar "Nenhum aplicativo para abrir este contato." **O registro não é desfeito**, porque o visitante tentou de fato. Sem `canLaunchUrl` prévio (e, portanto, sem `<queries>` obrigatório por causa disso). `wa.me` é https e cai no navegador se o WhatsApp não estiver instalado.
- **D-16:** Abrir links com **`url_launcher`** (dependência nova), atrás de uma interface em `domain/gateways/` com implementação em `data/gateways/` (mesmo padrão de `geolocator_gateway`/`geocoding_gateway`), para o Cubit ser testável com `mocktail`.

### Claude's Discretion
- Nomes de classes, arquivos e estados (ex.: `ContatoCubit`, `BarraContato`, `RegistrarContatoUseCase`, `CanalContato` enum no domínio).
- Ícones e rótulos exatos dos botões (WhatsApp, "Ligar", "Enviar e-mail") e do bottom sheet, confirmados no human-check de fim de fase.
- Como a barra fixa entra no `Scaffold` do detalhe (`bottomNavigationBar` vs. sobreposição) e o espaçamento para o conteúdo não ficar escondido.
- **Validação do link recebido** antes de abrir: aceitar só os esquemas `https` (host `wa.me`), `tel` e `mailto`; qualquer outro vira falha (SnackBar genérica de D-14). É defesa em profundidade, coerente com as defesas de origem já usadas nas DataSources.
- **Throttle do POST público**: a `ContatoPublicoAPIView` da W11 não declara `throttle_classes`. Avaliar na pesquisa aplicar `ThrottleVitrinePublica` (ou um throttle próprio de contato) na `feat/APP06` da API, já que é um POST sem login que grava registros. O app já trata o 429 (D-14).
- Formato do erro 400 da W11 (`{"canal": ["..."]}`) → `Failure` do app.

### Deferred Ideas (OUT OF SCOPE)
- Botão de WhatsApp direto no card da vitrine (exigiria `canais_contato` na lista): fora do escopo do card.
- Contato pelo perfil do corretor **sem imóvel** (endpoint por corretor, `imovel` nullable no `Contato`): é mudança no model/caixa da W11, escopo da web.
- Encaixar o componente de contato na tela de perfil reescrita pelo APP 07: fica para quem mergear por último (D-11).
</user_constraints>

<phase_requirements>
## Phase Requirements

Nenhum ID de requisito está mapeado em REQUIREMENTS.md para esta fase (`Requirements: TBD`). Os 6 critérios de aceite do card APP 06 são o conjunto de requisitos; os IDs `APP06-C1..C6` abaixo são só rótulos desta pesquisa (o planner pode renomear). `APP06-API-1/2` cobrem a mudança no repo da API (D-01, D-12, throttle). **Atualização (revisão 2 dos planos, checker W3):** os oito IDs (`APP06-C1..C6`, `APP06-API-1/2`) foram adicionados ao `.planning/REQUIREMENTS.md` (seção "Contato com o corretor (APP06)" e linhas de rastreabilidade para a Phase 6).

| ID | Descrição | Research Support |
|----|-----------|------------------|
| APP06-C1 | Botão de contato na página do imóvel e no perfil do corretor | `BarraContato` única, plugada via `Scaffold.bottomNavigationBar` no detalhe e no stub do perfil (Architecture Patterns 2 e 5) |
| APP06-C2 | O botão abre o WhatsApp com a mensagem padrão já preenchida | A mensagem vem pronta no `link` do POST (`https://wa.me/<num>?text=...`, `servicos.py`); app abre com `LaunchMode.externalApplication` (Pattern 3, Pitfall 1) |
| APP06-C3 | Telefone e e-mail como alternativas | `canais_contato` + bottom sheet (D-05/D-06); links `tel:+55...` e `mailto:...` do servidor |
| APP06-C4 | O contato é registrado na API no momento do disparo | `POST /api/publico/imoveis/{id}/contato/` antes de abrir o link; registro não desfeito se o aparelho não abrir (D-15) |
| APP06-C5 | O registro guarda imóvel, corretor e canal | Garantido pelo servidor (`registrar_contato` cria `Contato(imovel, corretor, canal)`); app só envia id do imóvel + canal. Teste de contrato no Django já existe na W11 |
| APP06-C6 | Tudo funciona sem login | View com `permission_classes = [AllowAny]` e `authentication_classes = []` (sem token, sem CSRF); app não envia credencial |
| APP06-API-1 | `canais_contato` no detalhe público (D-01) | `SerializerMethodField` + `canais_disponiveis` (Pattern 6); allowlist exata nos dois repos precisa ser atualizada (Pitfall 4) |
| APP06-API-2 | Limite de taxa no POST público | Throttle próprio herdando de `ThrottleVitrinePublica` (Pattern 7); **decisão do usuário recomendada** (Open Question 1) |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Extraído de `./.claude/CLAUDE.md` (o `.claude/skills/flutter-frontend/skill` é só um arquivo `skill` sem `SKILL.md`; ver nota nos Sources):

- **Clean Architecture** `data/` → `domain/` → `presentation/`; nenhum Widget faz lógica de negócio nem chamada de rede (não negociável). Por isso o gateway do `url_launcher` e o POST ficam atrás de interfaces; o widget só dispara `cubit.contatar(...)`.
- **Estado:** `Cubit` (flutter_bloc), estados imutáveis (freezed). **Erros:** `Result`/sealed, sem `try/catch` genérico na UI.
- **Models:** todo JSON em Model imutável (freezed + json_serializable), nunca `dynamic` onde a tipagem couber (por isso `CanalContato` é enum, nunca `String` solta).
- **UI:** Material 3 estrito, `ColorScheme.fromSeed`, widgets nativos (`FilledButton`, `SnackBar`, `showModalBottomSheet`), tipografia via `Theme.of(context).textTheme`. Paleta verde e branco.
- **Regra de negócio:** nada que valha dinheiro/mude estado é decidido no app. Aqui: o app não monta a mensagem, não escolhe destinatário, não deduz canais.
- **Idioma:** código, variáveis e comentários em português. **Branch:** `feat/APP06` (já é a atual).
- **Mocks:** `mocktail` (nunca `mockito`); `equatable` não (freezed já cobre); `http` não (dio).
- **GSD enforcement:** edições de arquivo só via fluxo GSD (`/gsd-execute-phase`).
- Memória do usuário: **nunca commitar sem OK explícito**; perguntar antes; explicar em português. Vale para os dois repos.

## Summary

O contrato do POST está fechado e é simples: `POST /api/publico/imoveis/<pk>/contato/` (sob `api/publico/`), corpo JSON `{"canal": "WHATSAPP"|"TELEFONE"|"EMAIL"}`, sem autenticação nem CSRF, e devolve **201 `{"canal", "link"}`**; 400 `{"canal": ["<mensagem>"]}` (canal inválido ou sem destino), 404 para imóvel fora da vitrine, e hoje **nenhum throttle** (o próprio README da WEB-11 diz "Ainda não há limite de requisições por visitante no endereço público"). O link vem 100% pronto do servidor (`https://wa.me/55...?text=...`, `tel:+55...`, `mailto:...?subject=&body=` com `%20`), então o app só valida o esquema e abre. A mensagem contém o **código interno do imóvel** e o link do anúncio — de propósito (decisão da W11), e o app não deve logar nem exibir o link.

Do lado do Flutter, `url_launcher` 6.3.3 (publisher `flutter.dev`, no pub-cache e resolvido por `flutter pub add --dry-run` sem conflito com o SDK 3.13.4/Flutter 3.47.5) cobre tudo. **Dois achados mudam o plano**: (1) `LaunchMode.platformDefault` abre `https` **dentro do app** (Custom Tab/SFSafariViewController), o que quebra o objetivo de abrir o WhatsApp — o gateway precisa usar **`LaunchMode.externalApplication`** para os três esquemas; (2) no Android, `launchUrl` **lança `PlatformException(ACTIVITY_NOT_FOUND)`** em vez de devolver `false` quando nada resolve o intent (no iOS devolve `false`), então o gateway deve capturar a exceção e normalizar para `false`. Como D-15 dispensa `canLaunchUrl`, **nenhuma mudança** em `AndroidManifest.xml` (`<queries>`) nem em `Info.plist` (`LSApplicationQueriesSchemes`) é necessária — a doc só exige isso para `canLaunchUrl`/`supportsLaunchMode`.

O principal risco do plano não é Flutter, é a **cadeia de contrato e fixtures**: acrescentar `canais_contato` ao detalhe quebra por desenho as allowlists exatas dos dois repos (`VitrineAllowlistExataTests` no Django e `_chavesDetalhe` em `test/data/contrato_detalhe_test.dart`), exige **recapturar** os fixtures de detalhe com o script `tool/capturar_fixtures_api.py` (fixtures de wire nunca são escritos à mão — F5/D-18) e estender o script e o `ApiFalsa` (hoje só GET, ignora método e corpo) para o POST. Além disso, o merge de `origin/WEB-11` na `main` da API dá **conflito textual em 3 arquivos** (README.md, `painel.css`, `painel_home.html`), todos aditivos. O perfil público do corretor existe na API (`GET /api/publico/corretores/<pk>/`), mas **não é usado nesta fase** (D-09/F5-D-16: o stub abre com dados em memória); no app só existe o stub.

**Primary recommendation:** Um único `ContatoCubit` + `ContatarCorretorUseCase` (registra via repositório, depois abre via gateway `url_launcher` com `externalApplication`), `BarraContato` em `presentation/contato/` plugada em `Scaffold.bottomNavigationBar` (detalhe, só no sucesso) e no stub do perfil (só com contexto de imóvel); na API, `feat/APP06` = `main` + merge de `origin/WEB-11` + `canais_contato` + throttle próprio herdado de `ThrottleVitrinePublica`; fixtures e allowlists regenerados antes de qualquer teste de UI.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Quais canais existem para o imóvel | API (Django, `canais_disponiveis`) | `data/` (Model parseia nomes) | D-01/D-02: regra do fallback corretor→empresa é do servidor; o app só lê nomes |
| Montar mensagem padrão e link (`wa.me`, `tel:`, `mailto:`) | API (`servicos._links`) | — | Mensagem usa código interno do imóvel, que não pode estar no app; "nada de regra no celular" |
| Registrar o contato (imóvel, corretor, canal, data) | API (`registrar_contato`) | `data/` (POST via dio) | Critérios C4/C5: o registro e o corretor destinatário são decididos no servidor |
| Validar esquema/host do link recebido | `data/` (repositório) | — | Defesa em profundidade na fronteira de dados não confiável (padrão `urlHttpOuNula`, `data/models/url_segura.dart`) |
| Abrir o link no aplicativo do aparelho | `data/gateways/` (`url_launcher`) | `domain/gateways/` (interface) | Plugin de plataforma atrás de interface mockável (D-16) |
| Orquestrar "registra, depois abre" e a regra "registro não é desfeito" | `domain/usecases/` | — | Mesmo papel de `detectar_cidade_usecase` (orquestra gateways); mantém o Cubit fino |
| Estado de loading/falha, anti-duplo-toque | `presentation/` (`ContatoCubit`) | — | D-13; estados explícitos |
| Texto das SnackBars, ícones, rótulos PT | `presentation/` | — | Apresentação pura; domínio só tem tipos de falha |
| Barra fixa, bottom sheet, SnackBar | `presentation/` (widgets) | — | Material 3; sem lógica |
| Limite de taxa do POST público | API (DRF throttle) | `presentation/` (SnackBar do 429) | O servidor protege a escrita; app só traduz o 429 |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `url_launcher` | `^6.3.3` (6.3.3, publicada 2026-10-02) | Abrir `https://wa.me/...`, `tel:`, `mailto:` | Pacote oficial `flutter.dev`; D-16 já decidido. Requer `sdk ^3.11.0`, `flutter >=3.41.0` — compatível com o projeto (`sdk: ^3.13.4`, Flutter 3.47.5) [VERIFIED: pub.dev API + `flutter pub add url_launcher --dry-run` resolveu 6.3.3 sem conflito, sem alterar o pubspec] |

Já presentes e reaproveitados (sem mudança): `dio ^5.11.1`, `flutter_bloc ^9.1.1`, `freezed_annotation ^3.1.0`/`freezed ^4.0.1`, `json_serializable`, `get_it ^9.3.0`/`injectable ^3.0.0`, `bloc_test ^10.0.0`, `mocktail ^1.0.5`, `intl` [VERIFIED: pubspec.yaml lido].

### Supporting (somente dev, para testar o gateway real)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `url_launcher_platform_interface` | `^2.3.2` (já transitivo, lock 2.3.2) | `UrlLauncherPlatform` + `LaunchOptions`/`PreferredLaunchMode` para o teste do gateway | Declarar em `dev_dependencies` porque o teste importa direto (mesmo precedente de `shared_preferences_platform_interface`) |
| `plugin_platform_interface` | `^2.1.8` (já transitivo, lock 2.1.8) | `MockPlatformInterfaceMixin` para registrar o falso em `UrlLauncherPlatform.instance` | idem |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Gateway próprio sobre `launchUrl` | Mockar o canal `plugins.flutter.io/url_launcher` | Frágil e específico de plataforma; o gateway + `UrlLauncherPlatform` fake é o caminho documentado no próprio pacote |
| `LaunchMode.externalApplication` | `platformDefault` (padrão) | `platformDefault` abre https em Custom Tab/Safari VC — wa.me abriria numa aba interna, não no app. **Não usar** |
| `LaunchMode.externalNonBrowserApplication` | — | Falharia justamente quando o WhatsApp não está instalado (D-15 quer cair no navegador). **Não usar** |
| `canLaunchUrl` antes de abrir | — | D-15 proíbe; devolve falso-negativo sem `<queries>`/`LSApplicationQueriesSchemes` |

**Installation:**
```bash
flutter pub add url_launcher
flutter pub add --dev url_launcher_platform_interface plugin_platform_interface
dart run build_runner build -d   # regenera *.freezed.dart / *.g.dart / injection.config.dart
```

**Version verification:**
- `url_launcher` 6.3.3, `url_launcher_android` 6.3.33, `url_launcher_ios` 6.4.2, `url_launcher_macos` 3.2.6, `url_launcher_platform_interface` 2.3.2 — saída do `flutter pub add url_launcher --dry-run` ("Would change 8 dependencies") e `curl https://pub.dev/api/packages/url_launcher` (latest 6.3.3, 2026-10-02) [VERIFIED: pub.dev API, 2026-11-16]. Os fontes dessas versões já estão em `~/.pub-cache/hosted/pub.dev` e foram lidos.

## Package Legitimacy Audit

> O seam `gsd-tools query package-legitimacy check` só aceita `npm|pypi|crates`; rodá-lo com `--ecosystem pypi url_launcher` devolveu `SLOP / does-not-exist` — **isso é o ecossistema errado, não um achado** (o pacote não está no PyPI). A verificação foi feita direto na API do pub.dev (registro oficial do ecossistema Dart).

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `url_launcher` | pub.dev | 130 versões publicadas; `is:flutter-favorite` | 9.84M/30 dias; 8192 likes | github.com/flutter/packages (`packages/url_launcher/url_launcher`); publisher `flutter.dev` | OK (verificação manual em pub.dev) | Approved — já decidido por D-16; o usuário nomeou o pacote |
| `url_launcher_platform_interface` | pub.dev | transitivo oficial do mesmo monorepo | — | flutter/packages | OK (transitivo já resolvido no lock) | Approved (dev, para teste) |
| `plugin_platform_interface` | pub.dev | transitivo oficial (já no lock 2.1.8) | — | flutter/packages | OK | Approved (dev, para teste) |

**Packages removed due to [SLOP] verdict:** none (o "SLOP" do seam foi ecossistema errado, descartado).
**Packages flagged as suspicious [SUS]:** none.
Etiqueta: `url_launcher` foi nomeado pelo usuário em D-16 e confirmado em docs oficiais (pub.dev, publisher `flutter.dev`) → `[VERIFIED: pub.dev]`. Os dois pacotes `*_platform_interface` já estão no `pubspec.lock` (transitivos) → só mudam de transitivo para dev direto.

## Architecture Patterns

### System Architecture Diagram

```
 Toque no botão (BarraContato)                       API Django (feat/APP06 = main + WEB-11 + canais_contato)
          │                                                       ▲
          ▼                                                       │
 ContatoCubit.contatar(imovelId, canal)                           │ POST /api/publico/imoveis/{id}/contato/
   │ (ignora se já ContatoEnviando)                               │   body {"canal":"WHATSAPP"}  (sem auth, sem CSRF)
   │ emit ContatoEnviando(canal)  ◄── spinner + tudo desabilitado │   throttle próprio  ──► 429 {"detail"}
   ▼                                                              │   404 (fora da vitrine) / 400 {"canal":[..]} / 201 {"canal","link"}
 ContatarCorretorUseCase  ───────────────►  ContatoRepositoryImpl ┘
   │                                         │ dio POST → ContatoRegistradoModel{canal, link}
   │                                         │ DioException 400/404/429/outros → falha tipada
   │                                         │ valida link por canal (https+wa.me | tel | mailto) → Uri
   │  Result<Uri>                            ▼
   ├─ Failure ──► Cubit: emit ContatoFalhou(motivo) ─► BlocListener ─► SnackBar (texto D-14)  ─► volta a ContatoOcioso
   │
   └─ Success(Uri) ──► LinkLauncherGateway.abrir(Uri)   (data/gateways: url_launcher, externalApplication)
                          │ launchUrl → true / false / PlatformException(ACTIVITY_NOT_FOUND) → normalizado em false
                          ├─ false ─► Failure(SemAplicativo) ─► SnackBar "Nenhum aplicativo..."  (registro NÃO desfeito)
                          └─ true  ─► Success ─► Cubit: emit ContatoOcioso (app externo assumiu a tela)

 Origem dos canais:  GET /api/publico/imoveis/{id}/ ──► DetalheImovelModel.canaisContato ──► DetalheImovel.canaisContato
                     ──► BarraContato (principal = 1º na ordem WHATSAPP→TELEFONE→EMAIL; ⋮ = demais)
 Plugagem: DetalheImovelScreen (só em DetalheCarregado com canais) e PerfilCorretorScreen (só com contexto de imóvel)
```

### Recommended Project Structure
```
lib/
├── domain/
│   ├── entities/canal_contato.dart            # enum CanalContato { whatsapp, telefone, email } (ordem = D-06)
│   ├── entities/detalhe_imovel.dart           # + canaisContato (@Default([]))
│   ├── entities/contato_do_imovel.dart        # (id, titulo, canais) p/ navegar ao perfil (D-09) — freezed
│   ├── gateways/link_launcher_gateway.dart    # abstract: Future<bool> abrir(Uri)
│   ├── repositories/contato_repository.dart   # Future<Result<Uri>> registrarContato(int, CanalContato) + falhas tipadas
│   └── usecases/contatar_corretor_usecase.dart
├── data/
│   ├── datasources/contato_datasource.dart + contato_remote_datasource.dart   # POST dio
│   ├── gateways/url_launcher_gateway_impl.dart
│   ├── models/contato_registrado_model.dart   # {canal, link} freezed+json
│   ├── models/detalhe_imovel_model.dart       # + canais_contato (tolerante a desconhecidos)
│   └── repositories/contato_repository_impl.dart
└── presentation/contato/
    ├── contato_cubit.dart / contato_state.dart
    ├── rotulos_contato.dart                   # extension: rotulo, icone, mensagemDeFalha
    └── widgets/barra_contato.dart + contato_bottom_sheet.dart
test/
├── data/ (contato_remote_datasource_test, contato_repository_impl_test, url_launcher_gateway_impl_test, detalhe_imovel_model_test+)
├── domain/contatar_corretor_usecase_test.dart
├── presentation/ (contato_cubit_test, barra_contato_test, + ajustes em detalhe_imovel_screen_test / perfil_corretor_screen_test / detalhe_navegacao_test)
└── fixtures/api/ (detalhe_*.json recapturados; contato_201_whatsapp.json, contato_201_telefone.json, contato_201_email.json, erro_400_canal_contato.json capturados)
```
Tudo novo do componente fica em `presentation/contato/` (não dentro de `detalhe_imovel/`) para que o merge com o APP07 (que move o perfil para `presentation/perfis/` e mexe ~5 linhas em `detalhe_imovel_screen.dart`) toque o mínimo possível [VERIFIED: `git diff main origin/feat/APP07 --stat -- lib/presentation/detalhe_imovel`; no APP07 `perfil_corretor_screen.dart` virou `export '../perfis/perfil_corretor_screen.dart';`].

### Pattern 1: Contrato do POST (W11) — fonte de verdade

`Web/contatos/api/views.py` e `servicos.py` em `origin/WEB-11` (lidos via `git show`):

```python
class ContatoPublicoAPIView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request, pk):
        imovel = get_object_or_404(
            imoveis_da_vitrine().select_related("empresa", "corretor_responsavel__empresa"), pk=pk
        )
        serializer = NovoContatoSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        canal = serializer.validated_data["canal"]
        ...
        except CanalIndisponivel as erro:
            return Response({"canal": [str(erro)]}, status=status.HTTP_400_BAD_REQUEST)
        return Response({"canal": canal, "link": link}, status=status.HTTP_201_CREATED)
```
[VERIFIED: `git show origin/WEB-11:Web/contatos/api/views.py`]

Rota: `path("imoveis/<int:pk>/contato/", ContatoPublicoAPIView.as_view(), name="publico-imovel-contato")` incluída em `config/urls.py` como `path('api/publico/', include('contatos.api.urls_publico'))` [VERIFIED: `origin/WEB-11:Web/contatos/api/urls_publico.py` e `grep contato Web/config/urls.py`] → URL final `/api/publico/imoveis/{id}/contato/`.

Valores de canal: `WHATSAPP = "WHATSAPP", "WhatsApp"`, `TELEFONE = "TELEFONE", "Telefone"`, `EMAIL = "EMAIL", "E-mail"` [VERIFIED: `origin/WEB-11:Web/contatos/models.py`, classe `Canal`]. Corpo: `canal = serializers.ChoiceField(choices=Contato.Canal.choices)` ("Corpo do POST público: só o canal. Nenhum dado do visitante é aceito.").

Tabela de respostas (o que o app precisa mapear):

| Status | Corpo | Quando | Falha tipada no app |
|--------|-------|--------|---------------------|
| 201 | `{"canal": "WHATSAPP", "link": "https://wa.me/55...?text=..."}` | sucesso, contato gravado | `Success(Uri)` |
| 400 | `{"canal": ["Este imóvel não tem contato disponível por esse canal."]}` | destino sem número/e-mail para o canal (nada é gravado) | `CanalIndisponivel` |
| 400 | `{"canal": ["\"X\" não é um escolha válida."]}` (texto do DRF) | valor fora do enum — o app nunca envia | mesmo `CanalIndisponivel` |
| 404 | `{"detail": ...}` | id inexistente, rascunho, empresa inativa, e (após o merge com a `main`) reservado/vendido/alugado | reaproveitar `ImovelNaoEncontradoException` (já existe, `domain/repositories/imovel_detalhe_repository.dart`) |
| 405 | — | GET no endereço | não ocorre |
| 429 | `{"detail": "..."}` + `Retry-After` | só depois que o throttle da Pattern 7 existir | `LimiteExcedido` |
| rede/timeout/5xx | — | — | falha genérica |

Links gerados (todos com `55` prefixado quando o número tem ≤ 11 dígitos):
```python
return f"https://wa.me/{digitos}?{urlencode({'text': mensagem})}"      # urlencode padrão: espaço vira "+" (na WEB-11; o 06-02 troca para quote_via=quote -> %20, ver Pitfall 7)
return f"tel:+{digitos}" if digitos else None
return f"mailto:{email}?{urlencode({'subject': assunto, 'body': corpo}, quote_via=quote)}"  # %20
```
[VERIFIED: `origin/WEB-11:Web/contatos/servicos.py`]. Mensagem: `'Olá! Vi no Imóveis Aqui o imóvel "{titulo}" (código {codigo}) e gostaria de mais informações. {url}'`. O `{url}` é `request.build_absolute_uri(reverse("site_publico:imovel", ...))`, ou seja, depende do `Host` da requisição (em dev pelo emulador será `http://10.0.2.2:8000/imovel/<id>/` — esperado, só aparece no texto).

`Contato.corretor` é `None` quando o corretor responsável está desativado (contato vai para a empresa, "só o gestor enxerga") [VERIFIED: models.py docstring]. Isso casa com o detalhe: `get_corretor_responsavel` devolve `None` para corretor inativo, então **nesse caso o card/perfil do corretor nem aparece, mas `canais_contato` pode continuar não vazio** (canais da empresa) — a barra de contato na página do imóvel deve funcionar mesmo com `corretor == null` (não condicionar a barra a `detalhe.corretor != null`).

### Pattern 2: Gateway do `url_launcher` (domain interface + data impl)

```dart
// domain/gateways/link_launcher_gateway.dart
abstract class LinkLauncherGateway {
  /// true se o sistema aceitou abrir o link; false se nenhum aplicativo o trata.
  Future<bool> abrir(Uri link);
}

// data/gateways/url_launcher_gateway_impl.dart
@LazySingleton(as: LinkLauncherGateway)
class UrlLauncherGatewayImpl implements LinkLauncherGateway {
  @override
  Future<bool> abrir(Uri link) async {
    try {
      // externalApplication: wa.me abre no app do WhatsApp (ou no navegador externo),
      // nunca na Custom Tab/SFSafariViewController que o platformDefault usaria p/ https.
      return await launchUrl(link, mode: LaunchMode.externalApplication);
    } on Exception {
      // Android lança PlatformException(ACTIVITY_NOT_FOUND) em vez de devolver false;
      // iOS lança PlatformException para URL inválida. Para o domínio é tudo "não abriu".
      return false;
    }
  }
}
```
Evidência: em `url_launcher_android-6.3.33/lib/url_launcher_android.dart` — `case PreferredLaunchMode.platformDefault: ... inApp = url.startsWith('http:') || url.startsWith('https:');` e `case PreferredLaunchMode.externalApplication: inApp = false;`, e `if (!succeeded) { throw PlatformException(code: 'ACTIVITY_NOT_FOUND', message: 'No Activity found to handle intent { $url }'); }`; no Java, `catch (ActivityNotFoundException e) { return false; }`. No iOS (`url_launcher_ios-6.4.2/lib/url_launcher_ios.dart`), `externalApplication` → `_hostApi.launchUrl(...)` e `LaunchResult.failure → false`, `invalidUrl → throw`. [VERIFIED: fontes lidos em `~/.pub-cache/hosted/pub.dev/` nesta sessão]

### Pattern 3: Repositório — mapeamento de falhas e validação do link

Segue exatamente `ImovelDetalheRepositoryImpl` (`on DioException` → `statusCode`; `on TypeError` → `FormatException`; `on Exception` genérico):

```dart
@override
Future<Result<Uri>> registrarContato(int imovelId, CanalContato canal) async {
  try {
    final modelo = await _dataSource.registrar(imovelId, canal);
    final link = _linkSeguro(modelo.link, canal);   // null => inválido
    return link == null
        ? Result.failure(const LinkContatoInvalidoException())
        : Result.success(link);
  } on DioException catch (erro) {
    return Result.failure(switch (erro.response?.statusCode) {
      400 => const CanalIndisponivelException(),
      404 => const ImovelNaoEncontradoException(),
      429 => const ContatoLimiteExcedidoException(),
      _ => erro,                                   // rede/timeout/5xx
    });
  } on TypeError catch (erro) {
    return Result.failure(FormatException('contato malformado: $erro'));
  } on Exception catch (erro) {
    return Result.failure(erro);
  }
}
```
Validação por canal (mais estrita que a sugestão de CONTEXT, mesmo custo): `WHATSAPP` → `scheme == 'https' && host == 'wa.me'`; `TELEFONE` → `scheme == 'tel'`; `EMAIL` → `scheme == 'mailto'`. `Uri.parse` já normaliza esquema e host para minúsculas (testado: `HTTPS://WA.ME/5511` → `https | wa.me`) [VERIFIED: execução de `dart run` no scratchpad]; `javascript:` e `https://evil.com` são rejeitados pela checagem. `Uri.parse` pode lançar `FormatException` → cai em `on Exception`.

**Correção a CONTEXT.md (canonical_refs/code_context):** "Erros HTTP mapeados para `Failure` tipado na camada `data/` (inclui 400 e 429 desde a fase 5)" **não bate com o código**: `grep` por `429`/`400`/`statusCode` em `lib/` só acha o 404 em `imovel_detalhe_repository_impl.dart`; 400 e 429 chegam à UI como `DioException` genérica ("falha como qualquer outra", contrato §Erros 429, "No app (D-14): ... Nenhuma mudança em `lib/`"). Logo, **o mapeamento 400/429 → falha tipada é código novo desta fase**, não reaproveitável.

### Pattern 4: Use case que orquestra registro + abertura (D-15)

```dart
@injectable
class ContatarCorretorUseCase {
  ContatarCorretorUseCase(this._repositorio, this._gateway);
  final ContatoRepository _repositorio;
  final LinkLauncherGateway _gateway;

  Future<Result<void>> call(int imovelId, CanalContato canal) async {
    final registro = await _repositorio.registrarContato(imovelId, canal);
    switch (registro) {
      case Success(:final data):
        final abriu = await _gateway.abrir(data);
        // O contato JÁ foi gravado: não existe "desfazer" (D-15).
        return abriu ? const Result.success(null) : Result.failure(const ContatoSemAplicativoException());
      case Failure(:final erro): return Result.failure(erro);
      case Loading(): return const Result.loading();
    }
  }
}
```
`Result<void>`: `Result.success(null)` compila com `T = void` (padrão do Dart 3); alternativa: `Result<Unit>`-like não existe no projeto — usar `void` mesmo.

### Pattern 5: Cubit com estados que sempre alternam (SnackBar confiável)

```dart
@freezed
sealed class ContatoState with _$ContatoState {
  const factory ContatoState.ocioso() = ContatoOcioso;
  const factory ContatoState.enviando(CanalContato canal) = ContatoEnviando;   // spinner no botão do canal
  const factory ContatoState.falhou(MotivoFalhaContato motivo) = ContatoFalhou; // BlocListener -> SnackBar
}
enum MotivoFalhaContato { generico, canalIndisponivel, imovelIndisponivel, limiteExcedido, semAplicativo }
```
- `contatar(int imovelId, CanalContato canal)`: `if (isClosed || state is ContatoEnviando) return;` → `emit(enviando(canal))` → `await _contatar(...)` → `if (isClosed) return;` (**não abrir nada se o usuário já saiu da tela durante o POST** — o use case já abriu o link antes de voltar; para evitar isso, se quiser honrar o "usuário saiu", separe registro e abertura no Cubit; ver Open Question 3) → `emit(falhou(motivo))` ou `emit(ocioso())`.
- Todo toque passa por `enviando`, então a sequência `enviando → falhou → enviando → falhou` **nunca emite dois `falhou` iguais seguidos** (o Bloc descartaria o segundo por igualdade) e o `BlocListener` dispara a SnackBar a cada falha. Após `falhou`, o próximo toque reinicia o ciclo; **não** é preciso "consumir" o estado.
- O motivo é decidido **só pelo tipo** da falha (nunca por mensagem), igual ao `DetalheImovelCubit` (`erro is ImovelNaoEncontradoException`).
- `@injectable` sem parâmetros: o `imovelId` vai no método, então um Cubit serve a página e outro ao perfil sem `@factoryParam`.

### Pattern 6: Onde o Cubit é fornecido (regra F4/04-01 "DI só no toque")

`abrirDetalheImovel` já é o único ponto que toca o `getIt` para o detalhe (decisão `[Phase 4] 04-01`). Estender o mesmo padrão:
- `abrirDetalheImovel(context, previa, {criarCubit, criarContatoCubit})` empurra `MultiBlocProvider(DetalheImovelCubit, ContatoCubit)`.
- `abrirPerfilCorretor(context, corretor, {ContatoDoImovel? contato, criarContatoCubit, construirImagemDeRede})` cria `BlocProvider<ContatoCubit>` **só quando `contato != null`** (a rota do perfil é uma subárvore nova: não herda o provider da rota do detalhe).
- Parâmetros novos **opcionais e nomeados** → os 30 usos de testes existentes e `perfil_corretor_screen_test.dart` continuam compilando; sem `contato`, o perfil não toca DI e continua sem texto "whatsapp/telefone/e-mail" (o teste `não mostra nenhum dado de contato (T-04-08-01)` segue válido).
- O widget `BarraContato` recebe `imovelId`, `canais`, `legenda` (widget/texto à esquerda) e lê o Cubit com `context.read`; ele próprio contém o `BlocListener` da SnackBar, então os dois pontos de uso ganham a mesma SnackBar sem duplicar código.

### Pattern 7: Barra fixa e visibilidade (D-05..D-10)

- Plugar em `Scaffold.bottomNavigationBar`. O `Scaffold` do detalhe hoje está **fora** do `BlocBuilder` (o builder é o `body`); a barra precisa do estado → envolver o `Scaffold` num `BlocBuilder<DetalheImovelCubit, DetalheImovelState>` (mudança mecânica) e passar `bottomNavigationBar: switch (state) { DetalheCarregado(:final detalhe) when detalhe.canaisContato.isNotEmpty => BarraContato(...), _ => null }`. **Passar `null`, não um `SizedBox.shrink()`**: o `Scaffold` ajusta o padding do corpo conforme existe ou não barra inferior `[ASSUMED]`, e o `SliverPadding` final do detalhe usa `MediaQuery.paddingOf(context).bottom + 24` — com a barra presente esse padding inferior seguro é consumido pela barra (verificar no teste de widget e no human-check que a última seção não fica sob a barra nem sobra espaço duplo).
- Texto à esquerda no detalhe: **a mesma lista `linhasDePrecoPorFinalidade(...)` que o `_Cabecalho` usa** (D-07; função pura em `lib/presentation/vitrine/apresentacao_imovel.dart`: `VENDA_E_ALUGUEL` devolve duas linhas "Venda R$ …" / "Aluguel R$ …/mês"). Pela D-07, a barra mostra todas as linhas (empilhadas, como no topo) quando cabem e, em `VENDA_E_ALUGUEL` longo demais, só a principal (a primeira), com o resto no topo — checagem de largura com `LayoutBuilder` + `TextPainter`, cada linha com `maxLines: 1`/`TextOverflow.ellipsis` (revisão 2 dos planos, checker W1). Sem preço: a função devolve `['Preço sob consulta']`. No perfil: `Text('Sobre: ${contato.titulo}', maxLines: 2, overflow: ellipsis)`.
- Botão principal: `FilledButton.icon` com o rótulo do primeiro canal na ordem do **enum** (`WHATSAPP`, `TELEFONE`, `EMAIL`), não na ordem recebida (robustez; o servidor já manda na ordem fixa). ⋮: `IconButton` (ou `IconButton.filledTonal`) que chama `showModalBottomSheet` (mesmo padrão de `mostrarOrdenacaoBottomSheet`: `showDragHandle: true`, `SafeArea`; **callback capturado do contexto da TELA antes de abrir**, porque a rota do modal fica fora do `BlocProvider` — comentário já existente em `ordenacao_bottom_sheet.dart`). Tocar numa opção fecha o sheet e chama `cubit.contatar(...)`.
- Em `ContatoEnviando`: o botão do canal em andamento mostra `CircularProgressIndicator` pequeno; **todos** os botões ficam com `onPressed: null` (D-13). Além do `onPressed: null`, o guard `state is ContatoEnviando` no Cubit é a proteção real contra duplo toque no mesmo frame.
- Ícones Material (sem pacote de ícones novo): WhatsApp não existe em `Icons` — usar `Icons.chat` (ou `chat_bubble`) e rótulo "WhatsApp"; telefone `Icons.call`; e-mail `Icons.email_outlined`. Rótulos/ícones são Claude's Discretion e vão ao human-check.

### Pattern 8 (API): `canais_contato` no detalhe — mudança mínima

Em `Web/imoveis/api/serializers.py` (`main`, `ImovelVitrineDetalheSerializer`, que já tem `corretor_responsavel = serializers.SerializerMethodField()` e `fields = [..., "fotos", "corretor_responsavel"]`):

```python
canais_contato = serializers.SerializerMethodField()
# fields: acrescentar "canais_contato" (depois de "corretor_responsavel")

def get_canais_contato(self, imovel):
    # só os nomes ("WHATSAPP"...), nunca número/e-mail/link — o link sai no POST
    return canais_disponiveis(imovel)   # from contatos.servicos import canais_disponiveis
```
`canais_disponiveis` devolve `[canal for canal, link in _links(imovel, "").items() if link]` na ordem do dict (`WHATSAPP`, `TELEFONE`, `EMAIL`) [VERIFIED: servicos.py]; `Contato.Canal.X` é `str` (TextChoices) e serializa como `"WHATSAPP"`. O detalhe já faz `select_related("corretor_responsavel__empresa")`, então o caso normal não gera consulta extra; com corretor desativado o `destino_do_contato` lê `imovel.empresa` (1 consulta a mais, aceitável no detalhe). Import circular: `contatos/servicos.py` importa `contas.models`, `core.validators`, `imoveis.vitrine` (que só importa `localizacao.models` e `.models`) e `.models` do próprio app — sem volta para `imoveis.api` [VERIFIED: `grep ^import/^from` em `imoveis/vitrine.py`]; se o executor ainda esbarrar em ciclo, importar dentro do método.

### Pattern 9 (API): throttle do POST público

`ThrottleVitrinePublica` está só na `main` (`Web/core/throttles.py` existe no disco e **não** em `origin/WEB-11`: `git show origin/WEB-11:Web/core/throttles.py` → "existe no disco, mas não em 'origin/WEB-11'"), e hoje é aplicado explicitamente nas 5 rotas públicas da vitrine (`throttle_classes = [ThrottleVitrinePublica]`) com escopo único `vitrine_publica` (120/min, `VITRINE_TAXA_ANONIMA`) [VERIFIED: `git show main:Web/imoveis/api/views.py`, `main:Web/core/throttles.py`, `main:Web/config/settings.py`]. Recomendação: **subclasse com escopo próprio**:

```python
# core/throttles.py
class ThrottleContatoPublico(ThrottleVitrinePublica):
    """POST público de contato: grava registro na caixa do corretor, então tem balde e taxa próprios."""
    scope = "contato_publico"
# settings: DEFAULT_THROTTLE_RATES += {'contato_publico': CONTATO_TAXA_ANONIMA}  (validar o formato como VITRINE_TAXA_ANONIMA)
# ContatoPublicoAPIView: throttle_classes = [ThrottleContatoPublico]
```
Por quê subclasse: (a) balde separado — navegar na vitrine não consome a cota de contato e um robô no POST não derruba a vitrine; (b) a suíte do Django já "pina" `ThrottleVitrinePublica.rate` como atributo de classe (`mock.patch.object(ThrottleVitrinePublica, "rate", "100000/min", create=True)` em `fixar_taxa_alta`), e o `SimpleRateThrottle.__init__` só chama `get_rate()` quando `rate` não existe (`if not getattr(self, 'rate', None): self.rate = self.get_rate()`) [VERIFIED: `Web/.venv/lib/python*/site-packages/rest_framework/throttling.py:68-71`], logo a subclasse **herda a taxa alta dos testes** e os testes de contato da W11 que fazem muitos POSTs não tomam 429. Teste de 429 próprio: `mock.patch.object(ThrottleContatoPublico, "rate", "2/min", create=True)`, no padrão de `VitrineLimiteDeTaxaTests` (`main:Web/imoveis/tests.py` ~linhas 1181-1237, que também checa `view.throttle_classes`/`scope`). Valor padrão sugerido de `CONTATO_TAXA_ANONIMA`: **`10/min`** `[ASSUMED]` (um visitante toca no máximo algumas vezes por minuto; 120/min = 7200 registros/h numa caixa de corretor seria spam). **Decisão do usuário recomendada** (Open Question 1): é política de produto/segurança, e há a alternativa mínima de só reaproveitar `ThrottleVitrinePublica` (zero configuração, mesmo balde de 120/min).

### Anti-Patterns to Avoid
- **`canLaunchUrl` antes de `launchUrl`:** falso-negativo no Android 11+/iOS sem `<queries>`/`LSApplicationQueriesSchemes`; D-15 proíbe. Não adicionar `<queries>` "por precaução".
- **`LaunchMode.platformDefault`** para `wa.me`: abre Custom Tab/Safari VC (ver Pattern 2).
- **Montar link/mensagem no app** (mesmo "só um fallback"): quebra "nada de regra no celular" e vazaria o código interno do imóvel para o código-fonte do app.
- **Reconstruir o link com `Uri(queryParameters: ...)` ou `Uri.encodeFull`**: reencoda o `%20`/`+` que o servidor já definiu (a doc do pacote avisa que `queryParameters` converte espaço em `+` em `mailto:`). O app deve usar `Uri.parse(linkDoServidor)` e **não** alterar nada.
- **Logar ou exibir o `link`** (contém o código interno e o texto da mensagem): não imprimir, não colocar em SnackBar, não guardar em estado do Cubit (estado só carrega `CanalContato`/motivo).
- **Guardar `Uri`/link no estado ou na entidade `DetalheImovel`:** só nomes de canal no domínio (D-01/D-02).
- **Fazer o app deduzir canais por `corretor.telefone`/`whatsapp`:** o JSON do corretor já traz esses campos (ver "Fato lateral" em Common Pitfalls) mas o `CorretorModel` os ignora de propósito (D-16 F5); manter.
- **Resolver `getIt` em `build`:** só nas funções `abrirDetalheImovel`/`abrirPerfilCorretor` (decisão 04-01).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Abrir WhatsApp/telefone/e-mail | `MethodChannel` próprio ou `Intent` nativo | `url_launcher` (`launchUrl`, `LaunchMode.externalApplication`) | Intents/Universal Links por plataforma, tratamento de falha de Activity |
| Mensagem do WhatsApp, codificação de URL, prefixo `55`, fallback empresa | Qualquer montagem no Dart | O `link` pronto do POST | Regra de negócio + código interno do imóvel só no servidor |
| Decidir canais disponíveis | Inferir de campos do corretor | `canais_contato` do detalhe (`canais_disponiveis`) | D-02 |
| Anti-duplo-toque | Debounce/Timer | Estado `ContatoEnviando` + guard no Cubit | Determinístico e testável (D-13) |
| Mock do `launchUrl` estático | Fake do canal de plataforma | Gateway + `UrlLauncherPlatform` fake com `MockPlatformInterfaceMixin` | Caminho oficial (o próprio pacote testa assim: `class MockUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform`) [VERIFIED: `url_launcher-6.3.3/test/mocks/mock_url_launcher_platform.dart`] |
| Fixtures de wire do POST | JSON escrito à mão | Estender `tool/capturar_fixtures_api.py` (grupo `contato`) contra a API real | Regra F5/D-02/D-18: fixture de wire nunca é manual |
| Throttle do POST | Contador próprio | DRF `AnonRateThrottle` (subclasse de `ThrottleVitrinePublica`) | Cache/ident/Retry-After prontos |

**Key insight:** o app é "uma tela sobre os dados" — esta fase é quase toda orquestração (registrar → validar → abrir) e UI de estados. Qualquer lógica que pareça "decidir" algo (canal, destinatário, texto) já está pronta no servidor.

## Common Pitfalls

### Pitfall 1: WhatsApp abre dentro do app (aba interna) em vez do aplicativo
**What goes wrong:** `launchUrl(Uri.parse(link))` sem `mode` → `platformDefault` → `https` abre em Custom Tab (Android) / SFSafariViewController (iOS), o visitante vê a página web do wa.me em vez de cair direto no WhatsApp.
**Why it happens:** `inApp = url.startsWith('http:') || url.startsWith('https:')` no `platformDefault` [VERIFIED: código lido].
**How to avoid:** sempre `mode: LaunchMode.externalApplication` no gateway; teste do gateway afirma o `PreferredLaunchMode.externalApplication` recebido pelo `UrlLauncherPlatform` falso.
**Warning signs:** no human-check, o link abre numa tela com barra do navegador por cima do app.

### Pitfall 2: Falha de abertura vira exceção não tratada (Android)
**What goes wrong:** `mailto:`/`tel:` sem app: Android lança `PlatformException(ACTIVITY_NOT_FOUND)`; o cubit trava em `enviando` ou o app dá erro não tratado. No iOS devolve `false` (e simulador não tem Mail/Telefone — a própria doc diz isso), então o código "funciona" no iOS e quebra no Android.
**How to avoid:** capturar `Exception` no gateway e normalizar para `false` (Pattern 2); teste do gateway cobre as duas formas (retorna `false` e lança `PlatformException`).

### Pitfall 3: Estado `falhou` repetido não dispara a SnackBar
**What goes wrong:** se o Cubit emitisse `falhou(rede)` duas vezes seguidas sem passar por outro estado, o Bloc descarta o segundo `emit` (igualdade) e a SnackBar não reaparece.
**How to avoid:** todo toque emite `enviando` antes; teste `blocTest` verifica a sequência `[enviando, falhou, enviando, falhou]` ao chamar `contatar` duas vezes.

### Pitfall 4: A allowlist exata quebra nos dois repositórios ao acrescentar `canais_contato`
**What goes wrong:** `VitrineAllowlistExataTests` (Django) e `_chavesDetalhe` em `test/data/contrato_detalhe_test.dart` travam o conjunto exato de chaves do detalhe (a segunda lista as chaves `id … corretor_responsavel` sem `canais_contato`) [VERIFIED: `test/data/contrato_detalhe_test.dart:18-36`; contrato §12: "travam as chaves exatas de cidade, envelope, item, opções, detalhe e dos blocos"]. Sem atualizar os dois, a suíte do app e a do Django ficam vermelhas por desenho.
**How to avoid:** na ordem — (1) API: serializer + atualizar a allowlist exata + teste de `canais_contato`; (2) subir seed em SQLite temporário e **recapturar** `detalhe_*.json` (e os `contrato/imovel_detalhe*.example.json` copiados byte a byte, contrato §12); (3) atualizar `_chavesDetalhe`; (4) só então código de UI. Não editar os JSONs capturados à mão.

### Pitfall 5: `ApiFalsa` não suporta POST (ignora método e corpo)
**What goes wrong:** `_AdaptadorApiFalsa.fetch` chama `_api._atender(options.uri)` — descarta `options.method` e o corpo; um POST em `/api/publico/imoveis/<id>/contato/` cai no `404 {}` final (a regex do detalhe é `^/api/publico/imoveis/(\d+)/$` e não casa `.../contato/`) [VERIFIED: `test/support/api_falsa.dart` lido].
**How to avoid:** Wave 0: estender o `ApiFalsa` para registrar `(método, uri, corpo)` e servir `contato_201_*.json` por canal / `erro_400_canal_contato.json` / `erro_404_detalhe.json` por rota POST, mantendo `requisicoes` (lista de `Uri`) compatível com os ~30 usos existentes. O 429 e o 5xx usam o mecanismo existente `falharProximas(caminho, status: 429)` e `responder(...)`.

### Pitfall 6: Merge da WEB-11 na `main` da API tem conflito textual e risco de testes
**What goes wrong:** `git merge-tree --write-tree main origin/WEB-11` reportou conflito em `README.md`, `Web/static/css/painel.css` e `Web/templates/contas/painel_home.html`; `settings.py` e `urls.py` mesclam sozinhos [VERIFIED: saída do merge-tree]. Os 3 conflitos são aditivos: README (seção "Seed de desenvolvimento" da `main` vs. seção "Contatos (W11)" da WEB-11 → manter as duas), `painel_home.html` (dois links `<p><a class="botao secundario" ...>`: "Imóveis da empresa" da `main` e "Contatos da empresa" da WEB-11 → manter os dois), `painel.css` (dois blocos no mesmo ponto → manter os dois).
**Risco não verificado:** `contatos/tests.py` importa helpers de `imoveis.tests` (`VitrineBase`, `criar_imovel`, ...) que mudaram na `main` (APP05: situação, `cache.clear()`, `fixar_taxa_alta`, lote). A migration `contatos/0001` depende de `('imoveis', '0004_predio_apartamento')`; a `main` está em `0006`, linear — **sem** segundo nó folha (contatos é app novo) `[ASSUMED: não rodei migrate]`.
**How to avoid:** primeira tarefa da API: criar `feat/APP06` a partir da `main`, `git merge origin/WEB-11`, resolver os 3 arquivos, `python manage.py makemigrations --check --dry-run` e rodar `manage.py test contatos imoveis` **antes** de acrescentar `canais_contato`. Sem push/PR sem OK (D-12).

### Pitfall 7: Mensagem do WhatsApp com `+` no lugar de espaço
**What goes wrong:** o servidor monta `?text=` com `urlencode` padrão (espaço → `+`) enquanto o `mailto` usa `quote_via=quote` (`%20`) "porque o `+` apareceria no texto". Se o WhatsApp não interpretar `+` como espaço, a mensagem aparece com `+` entre as palavras.
**Status:** ~~`[ASSUMED]` que `wa.me` e o app tratam `+` como espaço~~ — **RESOLVED (decisão do usuário pós-checagem dos planos):** em vez de depender da suposição, o conserto foi feito na API: o plano 06-02 (Task 3) troca `link_whatsapp` para `urlencode(..., quote_via=quote)` (espaço vira `%20`, `+` literal vira `%2B`, igual ao `mailto`), travado pelo teste Django `MensagemDoWhatsAppComEspacosTests` (`%20` presente e nenhum `+` no link da API e do site); a captura do 06-03 recusa link do WhatsApp com `+` e o `contrato_contato_test` do 06-04 trava o `%20`; o device check do 06-10 só **confirma** os espaços no WhatsApp real. Nada muda no app. Recado para a Palloma (dona da W11) pronto para enviar no 06-02-SUMMARY (o usuário envia no checkpoint do 06-10).

### Pitfall 8: Fato lateral — `corretor_responsavel` já expõe telefone/WhatsApp/e-mail no detalhe público
O teste existente `test_detalhe_da_casa` na `main` assere `dados["corretor_responsavel"]["whatsapp"] == self.corretor.whatsapp` e o contrato do app lista `email`, `telefone`, `whatsapp`, `creci`, `empresa_id` em `_chavesCorretor` (pendente de revisão LGPD pela web, 05-02/05-18). Logo, o argumento de D-01 "nunca expor número" vale para **o novo campo** (o teste da allowlist de `canais_contato` deve afirmar que o campo contém só nomes de canal), mas o número do corretor **já está** no JSON por outro caminho (decisão e pendência da web, fora do escopo). Não mexer; apenas **não** escrever teste novo que afirme "o detalhe não contém nenhum telefone" (falharia).

### Pitfall 9: Barra some ou desloca o conteúdo
`bottomNavigationBar` pede `null` quando não há canais/estado de sucesso (D-03/D-08); o `SliverPadding` final do detalhe (`MediaQuery.paddingOf(context).bottom + 24`) deve ser revisado — com `bottomNavigationBar` o corpo recebe o espaço restante, então o padding "seguro" extra pode ser dispensável. Cobrir em widget test com altura baixa (como `pumpEstado(altura: ...)` já faz) e no human-check.

## Code Examples

### Teste do gateway real contra um `UrlLauncherPlatform` falso
```dart
// Source: padrão do próprio pacote (url_launcher-6.3.3/test/mocks/mock_url_launcher_platform.dart)
class _LauncherFalso extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? ultimaUrl;
  PreferredLaunchMode? ultimoModo;
  Object? lancar;             // PlatformException(code:'ACTIVITY_NOT_FOUND') para simular o Android
  bool resposta = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    ultimaUrl = url;
    ultimoModo = options.mode;
    if (lancar != null) throw lancar!;
    return resposta;
  }
}
// setUp: UrlLauncherPlatform.instance = falso;
// expect(falso.ultimoModo, PreferredLaunchMode.externalApplication);
// expect(await gateway.abrir(Uri.parse('mailto:a@b.com')), isFalse) quando lançar PlatformException
```
`UrlLauncherPlatform.launchUrl(String url, LaunchOptions options)` e `LaunchOptions({mode = PreferredLaunchMode.platformDefault, ...})` [VERIFIED: `url_launcher_platform_interface-2.3.2/lib/src/url_launcher_platform.dart` e `types.dart`, lidos].

### Model do detalhe com canais tolerantes
```dart
// detalhe_imovel_model.dart — campo novo no @freezed factory
@JsonKey(name: 'canais_contato') @Default(<String>[]) List<String> canaisContato,

// paraEntidade(): ordem do enum, sem duplicata, desconhecido descartado (nunca derruba o parse, F4/D-14)
canaisContato: CanalContato.values
    .where((canal) => canaisContato.contains(canal.valorApi))   // valorApi: 'WHATSAPP'|'TELEFONE'|'EMAIL' (extension em data/)
    .toList(),
```

### Corpo e chamada do POST no DataSource
```dart
final resposta = await _dio.post<Object?>(
  caminhoContatoImovelPublico(imovelId),   // '/api/publico/imoveis/$id/contato/'
  data: <String, Object?>{'canal': canal.valorApi},   // dio serializa como application/json
);
final corpo = resposta.data;
if (corpo is! Map<String, dynamic>) throw const FormatException('Corpo do contato não é um objeto JSON.');
return ContatoRegistradoModel.fromJson(corpo);   // {canal, link}; chaves extras ignoradas
```
`Dio` padrão aceita 2xx (o 201 passa) e lança `DioException` com `response.statusCode` nos demais [VERIFIED: padrão já usado em `imovel_detalhe_remote_datasource.dart` e testado com 404]. `BaseOptions` do `ModuloRede` já tem timeouts de 10 s.

### Capturar o POST como fixture real (extensão do script)
O `tool/capturar_fixtures_api.py` só tem `obter` (GET) e grupos `lista|detalhe|todos`; acrescentar `postar(url, corpo, status_esperado)` e um grupo `contato` que, com o servidor temporário semeado (`semear_vitrine_dev`; corretor demo tem telefone, WhatsApp e e-mail [VERIFIED: seed na `main`]), POSTa `WHATSAPP`, `TELEFONE`, `EMAIL` num imóvel de Campinas e salva `contato_201_<canal>.json`; e POSTa `{"canal": "SMS"}` para capturar o 400 real do DRF (`erro_400_canal_contato.json`) sem precisar de imóvel sem canal. 404 reaproveita `erro_404_detalhe.json` (mesmo `{detail}`). Cada POST **grava um `Contato`** no SQLite temporário (inofensivo; nunca rodar contra o banco do `Web/.env`, regra do docstring do script).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `launch(String url, forceSafariVC:..., forceWebView:...)` (API legada de `url_launcher`) | `launchUrl(Uri, mode: LaunchMode.*)` + `canLaunchUrl(Uri)` | `url_launcher` 6.1+ | Usar só `Uri` + `LaunchMode`; sem API legada (deprecada) |
| Abrir https sempre em navegador externo | `platformDefault` abre web em app (Custom Tab/SafariVC) | url_launcher 6.x | Obriga declarar `externalApplication` para wa.me |
| Declarar `<queries>`/`LSApplicationQueriesSchemes` "sempre" | Só necessário para `canLaunchUrl`/`supportsLaunchMode(inAppBrowserView)` | Android 11 (API 30) / iOS | Sem `canLaunchUrl` → nada a declarar (D-15) |

**Deprecated/outdated:** `launch`, `canLaunch(String)` (API de string) — evitar. `LaunchMode.inAppWebView` (WebView) — não usar.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `wa.me`/WhatsApp tratam `+` do `?text=` (gerado por `urlencode`) como espaço | Pitfall 7 | **RESOLVED — não depende mais da suposição:** 06-02 Task 3 troca `link_whatsapp` para `quote_via=quote` (`%20`) com teste Django; device check do 06-10 confirma; recado para a Palloma pronto para enviar no 06-02-SUMMARY (o usuário envia no checkpoint do 06-10) |
| A2 | No Android, `https://wa.me/...` aberto com `externalApplication` vai direto ao app WhatsApp quando instalado (App Links verificados) e ao navegador quando não | Summary/D-15 | Pode aparecer seletor de apps ou página intermediária do wa.me; ajustar texto/expectativa no human-check |
| A3 | `Scaffold` com `bottomNavigationBar: null` preserva o padding inferior do corpo; com barra, o corpo não precisa do `SafeArea` extra; SnackBar flutua acima da barra | Pattern 7 / Pitfall 9 | Espaço duplo ou conteúdo sob a barra; resolvido em widget test + human-check |
| A4 | Taxa padrão do throttle de contato `10/min` por IP e política de balde separado | Pattern 9 | Taxa baixa demais bloqueia escritório/NAT compartilhado (muitos visitantes atrás de um IP); alta demais não protege. Política de produto → confirmar com o usuário. **RESOLVED:** usuário confirmou balde próprio e `10/min` (Open Question 1; 06-02) |
| A5 | O merge `origin/WEB-11` → `feat/APP06` (a partir da `main`) resolve só nos 3 arquivos aditivos, a migration `contatos/0001` aplica linear sobre `imoveis/0006` e `contatos/tests.py` continua verde com os helpers novos da `main` | Pitfall 6 | Retrabalho no merge; a primeira tarefa da API deve rodar `manage.py test contatos imoveis` antes de seguir |
| A6 | Em produção o `{url}` da mensagem usa o host público (`build_absolute_uri`), não `10.0.2.2` | Pattern 1 | Texto da mensagem com link inalcançável fora do dev; configuração do proxy/`ALLOWED_HOSTS` da web |
| A7 | Seed demo: corretor tem os 3 canais; corretor desativado usa a empresa (whatsapp e e-mail preenchidos; telefone não confirmado) | Code Examples (captura) | Pode não haver fixture com subconjunto de canais; derivar o caso "só alguns canais"/"vazio" de uma cópia do JSON em teste (`ApiFalsa.responder(corpo: ...)`), como o app já faz |

## Open Questions (RESOLVED)

1. **Throttle do POST: balde próprio ou o mesmo da vitrine, e qual taxa?** — **RESOLVED (decisão do usuário pós-pesquisa):** balde próprio `ThrottleContatoPublico(ThrottleVitrinePublica)`, escopo `contato_publico`, `CONTATO_TAXA_ANONIMA` padrão `10/min`, validada na partida — implementado no plano 06-02 (Tasks 1-2); recado para a Palloma pronto para enviar no 06-02-SUMMARY (o usuário envia no checkpoint do 06-10).
   - What we know: o POST grava registro sem login; a W11 admite "Ainda não há limite de requisições por visitante" (README da WEB-11). `ThrottleVitrinePublica` existe só na `main`; subclasse com escopo próprio herda a taxa alta dos testes.
   - What's unclear: política (10/min? 20/min?) e se aceita mais uma variável de ambiente (`CONTATO_TAXA_ANONIMA`).
   - Recommendation: subclasse `ThrottleContatoPublico` + `CONTATO_TAXA_ANONIMA` default `10/min`, validada na partida como a existente. **Pedir OK ao usuário** (e avisar a Palloma, dona da W11) antes de commitar; se preferir o mínimo, só `throttle_classes = [ThrottleVitrinePublica]`.

2. **O fallback do contato "só empresa" precisa de UI diferente?** (corretor desativado → `corretor_responsavel` nulo no detalhe, mas `canais_contato` presente) — **RESOLVED:** sem UI diferente; a barra não depende de `detalhe.corretor`. Coberto por teste: 06-03 Task 1 (`detalhe_sem_corretor.json` recapturado com lista não vazia) e 06-09 Task 2 (widget test "detalhe sem corretor com canais mostra `BarraContato`").
   - What we know: o app mostra a barra independentemente de `detalhe.corretor` (Pattern 1); o card/perfil do corretor some porque não há corretor.
   - What's unclear: nada técnico; só garantir teste (detalhe sem corretor **com** canais mostra barra). A fixture `detalhe_sem_corretor.json` recapturada cobrirá isso.
   - Recommendation: um teste de widget explícito.

3. **Se o usuário sair da tela durante o POST, abrir o link mesmo assim?** — **RESOLVED (planejamento):** abre mesmo assim — o contato já foi gravado e o visitante pediu. Decidido e registrado no dartdoc de `ContatarCorretorUseCase` (06-06 Task 1); o Cubit só protege o `emit` com `isClosed` (06-07).
   - What we know: o use case proposto registra e abre em sequência; `isClosed` só protege o `emit`.
   - What's unclear: se importa abrir o WhatsApp depois que o visitante voltou à vitrine (caso raro; POST com timeout de 10 s).
   - Recommendation: aceitar (o registro já existe e o visitante pediu o contato). Se não, separar `registrar` e `abrir` no Cubit e checar `isClosed` entre os dois — o custo é só a fronteira do use case. Decidir no planejamento.

4. **Rótulo/ícone do WhatsApp sem ícone oficial no Material:** `Icons.chat` + texto "WhatsApp" é o padrão proposto (sem pacote novo). Confirmar no human-check (Claude's Discretion). — **RESOLVED (adotado, confirmação no aparelho):** `Icons.chat` + "WhatsApp" implementado em `rotulos_contato.dart` (06-07 Task 1); veredito do usuário é item explícito do device check (06-10 Task 2, passo 2) e fica no 06-10-SUMMARY; troca pedida vira item aberto, não bloqueia a fase.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter / Dart | todo o app | ✓ | Flutter 3.47.5 (stable), Dart conforme SDK; `flutter test`: **588 verdes em ~28 s**, `flutter analyze`: sem issues | — |
| `url_launcher` (+ plataformas) | gateway | ✓ (já no `~/.pub-cache`; `pub add --dry-run` ok) | 6.3.3 / android 6.3.33 / ios 6.4.2 | — |
| Python (API) | extensão da API, testes Django | ✓ `Web/.venv` (Python 3.13.18); Django e DRF instalados | — | — |
| Banco do Django para testes | `manage.py test` | `Web/.env` existe (`DATABASE_URL` por env); `psql`/`pg_isready` **não** estão no PATH; Phase 5 usou Postgres | ? | `DATABASE_URL=sqlite:///.../x.sqlite3` (como o procedimento de captura do script) — **não rodei os testes Django** |
| Python 3 do sistema (script de captura) | `tool/capturar_fixtures_api.py` | ✓ 3.9.6 (só stdlib) | — | — |
| Dispositivo para o human-check | verificar wa.me/tel/mailto de verdade | **parcial**: `flutter devices` lista só macOS (desktop) e Chrome; nenhum emulador/aparelho conectado | — | macOS abre `mailto:` (Mail), `tel:` (FaceTime) e `https` (navegador); WhatsApp real exige aparelho/emulador com o app — human-check precisa de aparelho |
| Repo da API em `main` limpo, `origin/WEB-11` buscado | merge | ✓ (`origin/WEB-11` presente; `main` = `71ffeed`) | — | — |

**Missing dependencies with no fallback:** nenhum bloqueante para o código; para **C2** (mensagem abre no WhatsApp) é necessário um aparelho/emulador com WhatsApp no human-check de fim de fase.
**Missing dependencies with fallback:** banco do Django (usar SQLite temporário se o Postgres do `.env` não estiver de pé).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework (app) | `flutter_test` + `bloc_test ^10.0.0` + `mocktail ^1.0.5` (+ `fake_async`); DI manual com `getIt.registerFactory` nos testes de navegação |
| Framework (API) | Django `APITestCase`/`TestCase` (`manage.py test`), padrão `VitrineBase` de `Web/imoveis/tests.py` e `ContatoBase` de `Web/contatos/tests.py` |
| Config file | app: nenhum (`test/**_test.dart`); API: nenhum |
| Quick run (app) | `flutter test test/presentation/contato_cubit_test.dart test/data/contato_repository_impl_test.dart test/presentation/barra_contato_test.dart` (arquivos tocados) |
| Full suite (app) | `flutter test && flutter analyze` — **baseline medida hoje: 588 verdes, analyze limpo** |
| Quick run (API) | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test contatos imoveis.tests.VitrineDetalheTests -v 1` (com `DATABASE_URL` válido) |
| Full suite (API) | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test` |
| Codegen | `dart run build_runner build -d` antes dos testes (freezed, json, `injection.config.dart`) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| APP06-API-1 | Detalhe traz `canais_contato` só com nomes, na ordem fixa; vazio sem destino; corretor inativo → canais da empresa; allowlist exata atualizada | Django | `manage.py test imoveis.tests.VitrineDetalheTests imoveis.tests.VitrineAllowlistExataTests` | ❌ Wave 0 (casos novos) |
| APP06-API-2 | POST além da taxa → 429 com `Retry-After`; rotas da vitrine continuam em balde separado | Django | `manage.py test contatos` (classe nova de limite) | ❌ Wave 0 |
| APP06-C4/C5/C6 (servidor) | POST sem token grava `Contato(imovel, corretor, canal)`; 400 sem destino; 404 fora da vitrine | Django | `manage.py test contatos` (já existem na W11: `test_api_devolve_o_link_pronto_para_o_app`, `test_site_e_api_gravam_sem_login`) | ✅ (rodar após o merge) |
| APP06-C2/C3 (contrato) | App parseia `contato_201_*` capturado; link validado por canal; esquemas/hosts inválidos rejeitados | Flutter unit | `flutter test test/data/contato_repository_impl_test.dart test/data/contato_remote_datasource_test.dart` | ❌ Wave 0 |
| APP06-C3 | `canais_contato` do detalhe capturado vira `List<CanalContato>` na ordem do enum; desconhecido descartado; ausente → `[]` | Flutter unit | `flutter test test/data/detalhe_imovel_model_test.dart test/data/contrato_detalhe_test.dart` | ✅ existem — ❌ casos novos + `_chavesDetalhe` |
| APP06-C4 | Use case: registra antes de abrir; falha do registro não abre; abertura falhando devolve `ContatoSemAplicativo` sem desfazer | Flutter unit | `flutter test test/domain/contatar_corretor_usecase_test.dart` | ❌ Wave 0 |
| APP06-C2 | Gateway pede `externalApplication`; `PlatformException`/`false` viram `false` | Flutter unit | `flutter test test/data/url_launcher_gateway_impl_test.dart` | ❌ Wave 0 (+ 2 dev deps) |
| APP06-C4/D-13 | Cubit: `[enviando, ocioso]`, `[enviando, falhou(motivo)]` por tipo (rede/400/404/429/semAplicativo); ignora toque durante `enviando`; sequência repetida emite 2 falhas | bloc_test | `flutter test test/presentation/contato_cubit_test.dart` | ❌ Wave 0 |
| APP06-C1/C3 | `BarraContato`: principal = 1º canal na ordem fixa; ⋮ só se sobrar canal; sheet lista os demais; loading desabilita tudo; SnackBar por motivo (textos de D-14/D-15) | widget | `flutter test test/presentation/barra_contato_test.dart` | ❌ Wave 0 |
| APP06-C1 | Detalhe: barra só em `DetalheCarregado` com canais; ausente em carregando/erro/404/sem canais; com corretor nulo ainda mostra a barra; texto de preço = linhas existentes | widget | `flutter test test/presentation/detalhe_imovel_screen_test.dart` | ✅ existe — ❌ casos novos |
| APP06-C1 | Perfil: barra "Sobre: <título>" só com contexto de imóvel; sem contexto, sem botões (teste T-04-08-01 segue verde) | widget | `flutter test test/presentation/perfil_corretor_screen_test.dart` | ✅ existe — ❌ casos novos |
| APP06-C1..C6 | Ponta a ponta: vitrine → detalhe (JSON capturado) → tocar WhatsApp → POST na `ApiFalsa` (corpo `{"canal":"WHATSAPP"}`, sem cabeçalho de auth) → gateway falso recebe o `https://wa.me/...` do fixture | widget e2e | `flutter test test/presentation/detalhe_navegacao_test.dart` | ✅ existe — ❌ casos novos + registro DI (`ContatoCubit`, repositório, gateway falso) |
| DI | `configureDependencies()` real resolve `ContatoCubit` / `LinkLauncherGateway` / `ContatoRepository` | unit | idem (padrão do teste em `detalhe_navegacao_test.dart` ~l.765-775) | ❌ Wave 0 |
| C2 (real) | Mensagem pré-preenchida no WhatsApp, `tel:` abre discador, `mailto:` abre e-mail com assunto/corpo | **manual-only** (human-check fim de fase) | — | Justificativa: depende de aparelho com WhatsApp; também confirma Pitfall 7 (`+`) e rótulos/ícones |

### Sampling Rate
- **Per task commit:** testes dos arquivos tocados (quick run); tarefas de API: `manage.py test contatos` + classe de imóveis tocada.
- **Per wave merge:** `flutter test && flutter analyze` (app) e `manage.py test` completo (API).
- **Phase gate:** as duas suítes verdes + human-check com aparelho antes de `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] **API:** branch `feat/APP06` = `main` + merge `origin/WEB-11` (3 conflitos aditivos) + `manage.py test contatos imoveis` verde antes de qualquer mudança.
- [ ] **API:** `canais_contato` + testes (incluindo allowlist exata e "só nomes"); throttle conforme decisão da Open Question 1.
- [ ] **App:** `flutter pub add url_launcher` + 2 dev deps; `build_runner`.
- [ ] **Fixtures:** `capturar_fixtures_api.py` ganha `postar` + grupo `contato`; recapturar `detalhe_*.json` e `contrato/imovel_detalhe*.example.json` (cópia byte a byte); atualizar `_chavesDetalhe`; adendo no `01-CONTRATO-API.md` (campo `canais_contato` no §11 e novo item "POST contato" com 201/400/404/429, e §12 listando os novos fixtures).
- [ ] **`test/support/api_falsa.dart`:** suporte a POST (método + corpo registrados; rotas `.../contato/`).
- [ ] Arquivos de teste novos listados no mapa acima; ajuste de `detalhe_navegacao_test.dart` (registrar `ContatoCubit`/gateway falso em `getIt`) e de `detalhe_imovel_screen_test.dart`/`perfil_corretor_screen_test.dart` (prover `ContatoCubit` falso quando houver canais).

## Security Domain

`security_enforcement` não está desligado (padrão = ligado; `security_asvs_level: 1`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (sem login por requisito C6) | endpoint com `authentication_classes = []`; app não envia credencial |
| V3 Session Management | no | sem sessão, sem cookie, sem CSRF (por isso `authentication_classes = []`) |
| V4 Access Control | yes (servidor) | só imóvel da vitrine recebe contato (`imoveis_da_vitrine()`); app não decide destinatário |
| V5 Input Validation | yes | `ChoiceField` no servidor; no app, enum `CanalContato` (nunca string livre); `id` inteiro na URL; validação do `link` por canal antes de abrir |
| V6 Cryptography | no | HTTPS fica por conta do deploy; sem segredo no app |
| V12/V13 (arquivos/API) | yes | URL recebida do servidor é dado não confiável → só `https://wa.me`, `tel:`, `mailto:` |

### Known Threat Patterns for Flutter + url_launcher + DRF público

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Link malicioso/injetado no JSON (`javascript:`, `intent:`, `file:`, https para outro host) abre algo inesperado | Tampering / Elevation | Allowlist de esquema/host **por canal** no repositório (Pattern 3); qualquer outro → falha genérica; `externalApplication` nunca com esquema livre |
| Vazamento do código interno do imóvel (vai dentro do link/mensagem) | Information Disclosure | App não loga, não persiste e não exibe o `link`; estado do Cubit só tem canal/motivo; sem `print`/analytics do link |
| Inundar a caixa do corretor com POSTs (sem login, grava registro) | DoS / Repudiation | Throttle por IP no POST (Pattern 9), `NUM_PROXIES` correto atrás de proxy (senão todos os visitantes caem no IP do proxy — aviso `core.W001` já existente); servidor não aceita dado do visitante |
| Duplo toque cria dois contatos | Tampering (integridade do registro) | Guard `ContatoEnviando` no Cubit + botões desabilitados (D-13); servidor não deduplica (limitação conhecida da W11) |
| `intent:`/`tel:` com caracteres de controle | Tampering | `tel:` só vindo do servidor e validado por esquema; `Uri.parse` rejeita malformado (→ falha) |
| Cleartext HTTP | Info Disclosure | Já tratado na F1/F2 (cleartext só no manifest debug; ATS só rede local no iOS); sem mudança nesta fase |

## Sources

### Primary (HIGH confidence)
- Código da API lido via `git show origin/WEB-11:` / `main:` (repo `../imoveis-aqui`): `Web/contatos/api/{views,serializers,urls_publico}.py`, `servicos.py`, `models.py`, `migrations/0001_initial.py`, `tests.py`; `Web/config/urls.py`, `settings.py`; `Web/imoveis/api/{serializers,views,urls_publico}.py`; `Web/imoveis/tests.py` (VitrineBase, `fixar_taxa_alta`, allowlist, limite de taxa); `Web/core/throttles.py`; `Web/contas/api/{views,urls_publico}.py`; `Web/empresas/management/commands/semear_vitrine_dev.py`; `git merge-tree` main × WEB-11.
- Código do app lido nesta sessão: `lib/**` (camadas data/domain/presentation/di), `test/**`, `test/support/api_falsa.dart`, `tool/capturar_fixtures_api.py`, `pubspec.yaml`/`pubspec.lock`, `AndroidManifest.xml`, `Info.plist`, `.claude/CLAUDE.md`, planos/contexto das fases 1, 4 e 5.
- `url_launcher` 6.3.3 / android 6.3.33 / ios 6.4.2 / platform_interface 2.3.2: fontes em `~/.pub-cache/hosted/pub.dev/` (`url_launcher_android.dart`, `UrlLauncher.java`, `url_launcher_ios.dart`, `URLLauncherPlugin.swift`, `url_launcher_platform.dart`, `types.dart`, `test/mocks/mock_url_launcher_platform.dart`).
- pub.dev API: `https://pub.dev/api/packages/url_launcher` (versão, publisher `flutter.dev`, ambiente SDK) [VERIFIED].
- `https://pub.dev/packages/url_launcher` e `.../documentation/url_launcher/latest/url_launcher/launchUrl.html`: `<queries>`/`LSApplicationQueriesSchemes` só para `canLaunchUrl`/`supportsLaunchMode`; `canLaunchUrl` pode dar falso-negativo; simulador iOS sem Mail/Telefone; `launchUrl` devolve `false` ou lança `PlatformException`; `ArgumentError` para modos in-app com esquema não-http [CITED].
- DRF: `Web/.venv/lib/python*/site-packages/rest_framework/throttling.py:68-71` (`__init__` do `SimpleRateThrottle`) [VERIFIED].
- Execução local: `flutter test` (588 verdes), `flutter analyze` (limpo), `flutter pub add url_launcher --dry-run`, `dart run` de `Uri.parse` nos links de exemplo.

### Secondary (MEDIUM confidence)
- Comportamento de `Scaffold.bottomNavigationBar`/SnackBar (A3) e do Android com `wa.me` (A2): conhecimento do framework, sem execução em dispositivo.

### Tertiary (LOW confidence)
- Nenhuma fonte só-WebSearch. Nota: `.claude/skills/flutter-frontend/` contém um arquivo chamado `skill` (1889 bytes) e **nenhum `SKILL.md`**; o conteúdo não foi lido como skill do projeto (o CLAUDE.md também diz "No project skills found"). Os padrões do projeto vieram do código e das fases anteriores.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — pacote oficial, versão e compatibilidade verificadas por dry-run e pub-cache.
- Contrato da API: HIGH — fonte lida; o que falta é rodar os testes Django pós-merge (MEDIUM para o merge).
- Architecture: HIGH — segue padrões existentes verificados no código (gateways, use cases, repositório, Cubit, `abrirDetalheImovel`).
- Pitfalls: HIGH para launcher/estado/allowlist/ApiFalsa (verificados no código); MEDIUM para `+` no WhatsApp e layout do Scaffold (precisam de aparelho/teste).

**Research date:** 2026-11-16
**Valid until:** 30 dias (stack estável); revalidar antes se a Palloma mergear a WEB-11 na `main` (o passo de merge some e o contrato pode mudar) ou se a branch `origin/feat/APP07` for mergeada primeiro (o ponto de plugagem do perfil muda de arquivo).
