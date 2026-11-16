# Phase 6: Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06) - Context

**Gathered:** 2026-11-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Card **APP 06** do Kanban (tarefa A06). O visitante fala com o corretor com um toque, sem
login e sem formulário. Na **página do imóvel** e no **perfil do corretor aberto a partir
de um imóvel**, o app mostra os canais que a API diz existir (WhatsApp, telefone, e-mail).
O toque dispara `POST /api/publico/imoveis/{id}/contato/` (WEB 11), que **registra o
contato** (imóvel, corretor, canal, data) e devolve o **link pronto** (`https://wa.me/...`
com a mensagem padrão montada pelo servidor, `tel:+55...` ou `mailto:...`). O app apenas
abre esse link.

Critérios de aceite do card (todos obrigatórios):
1. Botão de contato na página do imóvel e no perfil do corretor.
2. O botão abre o WhatsApp com a mensagem padrão já preenchida.
3. Telefone e e-mail como alternativas de contato.
4. O contato é registrado na API no momento em que o visitante o dispara.
5. O registro guarda o imóvel, o corretor e o canal usado.
6. Tudo funciona sem login.

Inclui uma mudança pequena no repo da API (`../imoveis-aqui`): expor `canais_contato` no
detalhe público. Fora do escopo: caixa de contatos do corretor e retorno anotado (APP 10),
perfil completo do corretor/empresa (APP 07), contato no card da vitrine.

</domain>

<decisions>
## Implementation Decisions

### Canais disponíveis
- **D-01:** O detalhe público `GET /api/publico/imoveis/{id}/` (`ImovelVitrineDetalheSerializer`)
  ganha **`canais_contato: ["WHATSAPP", "TELEFONE", "EMAIL"]`** (subconjunto, ordem fixa),
  calculado no servidor por `canais_disponiveis(imovel)` da W11 (`contatos/servicos.py`).
  Só os **nomes** dos canais são expostos, nunca número, e-mail nem link: o link (com o
  código interno do imóvel) só sai do servidor no POST, no momento do toque (mesma regra
  que a W11 usa no site). Com teste no padrão de `Web/imoveis/tests.py`, incluindo a
  allowlist (nenhum telefone, WhatsApp ou e-mail no JSON por causa disso).
  — **Reversibility:** costly — é um campo novo no contrato público compartilhado com a
  web; mudar depois mexe no serializer, no Model Dart e nos fixtures de teste.
- **D-02:** O app **nunca deduz canais** a partir dos dados do corretor. A regra "corretor
  desativado → contato vai para a empresa" e o fallback para os dados da empresa são do
  Django (W10/W11). Mantém a F5/D-16: telefone, WhatsApp e e-mail do corretor não entram
  em entidade de domínio.
- **D-03:** `canais_contato` vazio (ou ausente) → **a área de contato some** (F4/D-14).
- **D-04:** `canais_contato` **só no detalhe**. A lista da vitrine não muda.

### Layout na página do imóvel
- **D-05:** **Barra inferior fixa** (prevista desde a F4/D-12) com o **preço à esquerda** e,
  à direita, o **botão principal** (`FilledButton`) mais um **botão secundário ⋮** que abre
  um **bottom sheet** com os demais canais ("Ligar", "Enviar e-mail").
- **D-06:** **Botão principal = primeiro canal disponível na ordem fixa WhatsApp → Telefone
  → E-mail.** O ⋮ só aparece se sobrar algum canal além do principal.
- **D-07:** O preço da barra é o **mesmo texto de preço que o topo do detalhe e o
  `ImovelCard` já usam** (reaproveitar a formatação existente, sem regra nova). Em
  VENDA_E_ALUGUEL longo demais, a barra mostra o principal e o resto fica no topo.
- **D-08:** A barra **só aparece quando o detalhe carregou** (estado de sucesso, com
  canais). Não aparece na prévia (F4/D-16), no 404 nem no erro.

### Perfil do corretor
- **D-09:** O perfil do corretor mostra contato **somente quando foi aberto a partir de um
  imóvel**: a navegação passa o id (e o título) do imóvel e os canais já carregados. O
  toque usa o **mesmo** `POST /imoveis/{id}/contato/`. Assim o registro guarda imóvel,
  corretor e canal, sem mudar o model `Contato` da W11. Aberto sem imóvel (por exemplo,
  vindo da página da empresa do APP 07) → sem botões.
- **D-10:** No perfil, o contato usa **o mesmo componente de barra fixa**, com o texto
  **"Sobre: <título do imóvel>"** no lugar do preço.
- **D-11:** **Componente isolado e reutilizável**: o contato vira widget(s) + Cubit
  próprios em `presentation/` (sem depender da tela), plugados na página do imóvel e na
  **tela stub atual** do perfil (`perfil_corretor_screen.dart` na main). A branch
  `origin/feat/APP07` (Allysson, não mergeada, reescreve essa tela) **não é base** desta
  fase. Quem mergear por último encaixa o componente na tela do APP 07. O usuário avisa o
  Allysson.
  — **Reversibility:** reversible — o componente é autocontido; trocar a tela onde ele é
  plugado é local.

### API e falhas
- **D-12:** Repo da API: branch **`feat/APP06` local**, a partir da `main`, com **merge de
  `origin/WEB-11`** (ainda fora da main) e, por cima, o `canais_contato` (D-01) com testes.
  **Sem push/PR sem OK explícito** (mesmo esquema da F5/D-03). O usuário pode avisar a
  Palloma (dona da W11) para mergear a WEB-11 na main.
- **D-13:** **Toque → loading no próprio botão**: spinner e botão (e ⋮/bottom sheet)
  desabilitados durante o POST, o que evita contato duplicado num duplo toque. Estados
  explícitos no Cubit (padrão F4/D-17).
- **D-14:** **Falha no POST → nada abre e aparece uma SnackBar**, por tipo:
  rede/timeout/5xx → "Não foi possível abrir o contato. Tente de novo.";
  400 (canal indisponível) → "Este canal não está disponível para este imóvel.";
  404 → "Este imóvel não está mais disponível."; 429 → "Muitas tentativas. Aguarde um
  pouco e tente de novo."
- **D-15:** **POST ok, mas o aparelho não abre o link** (mailto sem app de e-mail, tel: em
  tablet) → SnackBar "Nenhum aplicativo para abrir este contato." **O registro não é
  desfeito**, porque o visitante tentou de fato. Sem `canLaunchUrl` prévio (e, portanto,
  sem `<queries>` obrigatório por causa disso). `wa.me` é https e cai no navegador se o
  WhatsApp não estiver instalado.
- **D-16:** Abrir links com **`url_launcher`** (dependência nova), atrás de uma interface
  em `domain/gateways/` com implementação em `data/gateways/` (mesmo padrão de
  `geolocator_gateway`/`geocoding_gateway`), para o Cubit ser testável com `mocktail`.

### Claude's Discretion
- Nomes de classes, arquivos e estados (ex.: `ContatoCubit`, `BarraContato`,
  `RegistrarContatoUseCase`, `CanalContato` enum no domínio).
- Ícones e rótulos exatos dos botões (WhatsApp, "Ligar", "Enviar e-mail") e do bottom
  sheet, confirmados no human-check de fim de fase.
- Como a barra fixa entra no `Scaffold` do detalhe (`bottomNavigationBar` vs. sobreposição)
  e o espaçamento para o conteúdo não ficar escondido.
- **Validação do link recebido** antes de abrir: aceitar só os esquemas `https` (host
  `wa.me`), `tel` e `mailto`; qualquer outro vira falha (SnackBar genérica de D-14). É
  defesa em profundidade, coerente com as defesas de origem já usadas nas DataSources.
- **Throttle do POST público**: a `ContatoPublicoAPIView` da W11 não declara
  `throttle_classes`. Avaliar na pesquisa aplicar `ThrottleVitrinePublica` (ou um throttle
  próprio de contato) na `feat/APP06` da API, já que é um POST sem login que grava
  registros. O app já trata o 429 (D-14).
- Formato do erro 400 da W11 (`{"canal": ["..."]}`) → `Failure` do app.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Card e escopo
- `../APP 06 · Contato com o corretor pelo WhatsApp.md` — texto do card APP 06 (Kanban) com os 6 critérios de aceite.
- `.planning/ROADMAP.md` § Phase 6 — goal e success criteria da fase.

### API — WEB 11 (branch `origin/WEB-11` do repo `../imoveis-aqui`, ainda não mergeada na main)
- `../imoveis-aqui/Web/contatos/servicos.py` (em `origin/WEB-11`) — `MENSAGEM_PADRAO`, `link_whatsapp`/`link_telefone`/`link_email`, `destino_do_contato` (fallback para a empresa), `canais_disponiveis`, `registrar_contato`, `CanalIndisponivel`.
- `../imoveis-aqui/Web/contatos/api/views.py` (em `origin/WEB-11`) — `ContatoPublicoAPIView`: `POST /api/publico/imoveis/<pk>/contato/`, `AllowAny`, sem autenticação; corpo `{"canal": ...}`; 201 `{"canal", "link"}`; 400 `{"canal": [...]}`; 404 fora da vitrine.
- `../imoveis-aqui/Web/contatos/api/serializers.py`, `.../models.py` (em `origin/WEB-11`) — `Contato.Canal` (`WHATSAPP|TELEFONE|EMAIL`), `NovoContatoSerializer`.
- `../imoveis-aqui/Web/contatos/tests.py` (em `origin/WEB-11`) — padrão de teste da W11.

### API — detalhe público (onde entra `canais_contato`)
- `../imoveis-aqui/Web/imoveis/api/serializers.py` — `ImovelVitrineDetalheSerializer` e serializers `*PublicoSerializer` (allowlist).
- `../imoveis-aqui/Web/imoveis/api/views.py` — `ImovelVitrineDetalheAPIView` e `ThrottleVitrinePublica` (`core/throttles.py`).
- `../imoveis-aqui/Web/imoveis/tests.py` — padrão de teste e teste de allowlist do público.

### Contrato e decisões anteriores do app
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — contrato público; adicionar adendo para `canais_contato` e `POST .../contato/`.
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json` — exemplo do detalhe a regerar com `canais_contato`.
- `.planning/phases/04-pagina-do-imovel-galeria-e-dados-da-natureza/04-CONTEXT.md` — D-12 (barra fixa adiada para o APP 06), D-14, D-15 (perfil stub), D-16, D-17, D-18.
- `.planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-CONTEXT.md` — D-03 (esquema de branch local na API), D-15, D-16 (só nome e foto do corretor no app), D-18 (sem mocks em `lib/`, fixtures de wire em `test/`).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart`: `Scaffold` do detalhe, onde a barra fixa entra (só no estado de sucesso).
- `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` + `widgets/cartao_corretor.dart`: stub do perfil (F4/D-15) e `abrirPerfilCorretor(...)`, que passa a receber o contexto do imóvel (id, título, canais).
- `lib/presentation/vitrine/apresentacao_imovel.dart`: formatação de preço já usada no card e no detalhe (D-07).
- `lib/data/models/detalhe_imovel_model.dart` + `lib/domain/entities/detalhe_imovel.dart`: ganham `canais_contato` → lista tipada de canal (enum no domínio, nunca `String` solta).
- `lib/data/datasources/imovel_detalhe_remote_datasource.dart`: padrão de DataSource `dio` com defesas de origem; o POST de contato segue o mesmo padrão.
- `lib/domain/gateways/` + `lib/data/gateways/` (`geolocator_gateway`, `geocoding_gateway`): padrão para o gateway de abrir link (`url_launcher`).

### Established Patterns
- Clean Architecture (`data/` → `domain/` → `presentation/`), DI com `get_it` + `injectable`, `freezed` para Models, entidades e estados, `Result` selado, Cubit com estados explícitos.
- Erros HTTP mapeados para `Failure` tipado na camada `data/` (inclui 400 e 429 desde a fase 5).
- Testes: `bloc_test` + `mocktail`, fixtures de wire JSON em `test/` (F5/D-18); widget tests e e2e de navegação em `test/presentation/`.

### Integration Points
- Detalhe (sucesso) → `BarraContato` (preço + principal + ⋮) → `ContatoCubit` → use case → repository → `POST /api/publico/imoveis/{id}/contato/` → gateway `url_launcher`.
- `CartaoCorretor.aoTocar` → `abrirPerfilCorretor` (com o contexto do imóvel) → `PerfilCorretorScreen` com a mesma barra ("Sobre: <título>").
- `pubspec.yaml`: adicionar `url_launcher`. Android/iOS: conferir se precisam de configuração para `https`/`tel`/`mailto` sem `canLaunchUrl`.

</code_context>

<specifics>
## Specific Ideas

- Layout de referência da barra (escolhido pelo usuário):
  ```
  │ R$ 450.000   [⋮] [◉ WhatsApp] │
  [⋮] → bottom sheet:  ☎ Ligar  /  ✉ Enviar e-mail
  ```
- O contato no site (W11, `templates/site_publico/imovel.html` em `origin/WEB-11`) também só mostra os botões de `canais_disponiveis`. O app fica coerente com o site.

</specifics>

<deferred>
## Deferred Ideas

- Botão de WhatsApp direto no card da vitrine (exigiria `canais_contato` na lista): fora do escopo do card.
- Contato pelo perfil do corretor **sem imóvel** (endpoint por corretor, `imovel` nullable no `Contato`): é mudança no model/caixa da W11, escopo da web.
- Encaixar o componente de contato na tela de perfil reescrita pelo APP 07: fica para quem mergear por último (D-11).

</deferred>

---

*Phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06*
*Context gathered: 2026-11-16*
