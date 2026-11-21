# Phase 8: Login e Área do Corretor — o Acervo - Context

**Gathered:** 2026-11-20
**Status:** Ready for planning
**Source:** card APP 08 (`08-CARD-APP08.md`, usado como PRD) + discuss-phase

<domain>
## Phase Boundary

O corretor entra no **mesmo app** (sem app separado) com e-mail e senha, recebe o token da API, e
vê o **acervo**: os imóveis dele e os da imobiliária, com busca e filtro por situação. Imóvel de
outra empresa nunca aparece. A sessão fica guardada no aparelho; Sair apaga o token do aparelho e o
revoga no servidor. Gestor e administrador conseguem entrar, mas veem só uma tela de aviso com Sair
(a área deles é da APP-12). O visitante continua usando o app sem login, que sempre abre na vitrine.

A fase entrega nos dois repositórios:

1. **Web** (Django, branch `feat/APP08` do repo web): rota "quem sou eu", busca + situação +
   paginação + lista enxuta na rota do acervo do corretor, limite de tentativas no login, e Sair
   que revoga o token, todos com testes.
2. **App** (Flutter, branch `feat/APP08`): tela de login, sessão em `flutter_secure_storage`, botão
   "Entrar"/"Meu acervo" no topo da vitrine, tela do acervo com busca, chips de situação e rolagem
   infinita, tela de aviso para gestor/admin, e Sair.

Os 6 critérios de aceite do card são o checklist da fase:
AC-1 login com token da API · AC-2 sessão guardada, sair apaga o token · AC-3 erro de login
genérico · AC-4 acervo (corretor + imobiliária) com busca e filtro por situação · AC-5 imóvel de
outra empresa não aparece nem forçando · AC-6 sem login o app continua abrindo na vitrine.

</domain>

<decisions>
## Implementation Decisions

### Travadas no card, antes da discussão (D-A..D-E — não perguntar de novo)
- **D-A · Escopo web = necessário + segurança:** No repo web, branch `feat/APP08`: endpoint "quem
  sou eu", busca + situação + paginação na rota do corretor reaproveitando
  `FiltroImovelForm(campos=["busca", "situacao"])`, lista enxuta para o cartão, limite de tentativas
  no login, e um Sair que revoga o token no servidor (além de apagar do aparelho).
- **D-B · Gestor/administrador no app:** o login funciona e abre uma tela de aviso ("a área do
  gestor ainda não está no app") com Sair. A APP-12 troca essa tela depois, sem mexer no login.
- **D-C · Abertura:** o app continua abrindo na vitrine para todo mundo; com sessão, o botão do topo
  vira "Meu acervo"; sem sessão, "Entrar".
- **D-D · Token em `flutter_secure_storage`:** (Keychain/Keystore). A nota do CLAUDE.md que descartava
  o pacote valia só enquanto o app não guardava credencial.
- **D-E · Fluxo completo de planejamento:** pesquisa → padrões → planejador → verificador.

### Tela de login
- **D-01:** Tela própria, aberta por `Navigator.push` a partir do botão "Entrar" no topo da
  vitrine. Campos: e-mail (teclado de e-mail, autofill) e senha (oculta, com botão de
  mostrar/ocultar). Um `FilledButton` "Entrar" mostra o carregamento e fica desabilitado enquanto o
  pedido está em curso. O app só barra campo vazio; formato de e-mail e credencial são do servidor.
- **D-02:** Depois de entrar, o corretor vai **direto ao "Meu acervo"**. A rota de login é
  substituída, então o "voltar" leva à vitrine (que já mostra "Meu acervo"), nunca de volta ao login.
  O papel vem da rota "quem sou eu", chamada logo após o login (o login só devolve o token).
  Gestor/admin vão para a tela de aviso (D-B).
- **D-03:** Credencial inválida (400) → o app mostra o **texto fixo dele**: "E-mail ou senha
  inválidos." (as mesmas palavras do site), nunca a string que o servidor mandar. Rede, timeout ou
  5xx → "Não foi possível entrar agora. Tente de novo." As duas são falhas tipadas diferentes na
  camada de dados. Nenhum texto revela se o e-mail existe (AC-3).
- **D-04:** Limite de tentativas (429) → "Muitas tentativas. Tente de novo em N minutos.", com N
  lido do cabeçalho `Retry-After` que o DRF manda (segundos arredondados para minutos para cima,
  mínimo 1). Sem o cabeçalho: "Tente de novo em alguns minutos." O limite em si é do Django (D-A).

### Cartão do acervo e toque
- **D-05:** **Cartão compacto em linha**, widget novo: miniatura quadrada à esquerda (`ImagemRede`,
  com placeholder); à direita código + título (até 2 linhas), preço (reaproveitando
  `linhasDePreco`/`apresentacao_imovel.dart`) e as marcas. Material 3, cores só do `ColorScheme`,
  texto do `textTheme`.
- **D-06:** As marcas seguem só o que o card pede. O Allysson pediu: "faça tudo de acordo com os
  detalhes da fase que te mandei". Entram:
  - **chip de situação** (Disponível / Reservado / Vendido / Alugado), porque é o filtro do card;
  - **código**, porque a busca do site procura por código ou título;
  - **marca "Seu"** quando o imóvel é do corretor logado, porque o card separa "os do corretor e os
    da imobiliária". Vem como booleano **calculado no Django** (`corretor_responsavel` == usuário
    logado); o app nunca compara ids.

  **Não** entra a marca "Não publicado", nem qualquer outra marca fora do card.
- **D-07:** Toque: a lista enxuta traz um booleano calculado no Django pela **mesma regra da
  vitrine pública**: publicado + `DISPONIVEL` + empresa ativa, a regra do `ImovelQuerySet` em
  `imoveis/models.py`. Verdadeiro → o toque abre a página do imóvel que já existe
  (`abrirDetalheImovel`). Falso → o cartão não reage ao toque (sem `onTap`, sem ripple). O app
  nunca decide isso olhando `publicado`/`situacao`.

### Busca e filtro por situação
- **D-08:** `SearchBar` "Buscar por código ou título", resolvida no servidor (parâmetro `busca`),
  com o mesmo atraso de digitação da vitrine (400 ms, `vitrine_cubit.dart`).
- **D-09:** Abaixo da busca, uma **linha de chips de escolha única**: Todas, Disponível, Reservado,
  Vendido, Alugado → parâmetro `situacao` com os valores do enum `Imovel.Situacao` (`DISPONIVEL`,
  `RESERVADO`, `VENDIDO`, `ALUGADO`). "Todas" não manda o parâmetro. Busca e situação se combinam.
- **D-10:** A ordem é a que o Django devolver; não há botão de ordenar. Paginação por página
  (`PageNumberPagination`, como a APP-05), com rolagem infinita e rodapés de
  carregando/erro/fim no padrão que já existe.
- **D-11:** No servidor, a regra é `FiltroImovelForm(campos=["busca", "situacao"])`, a mesma do
  painel do corretor no site. Filtro inválido é ignorado, não vira erro (D-A).

### Web (detalhes do D-A)
- **D-12:** Repo web em `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui` (pasta `Web` =
  Django), **não** `../imoveis-aqui/Web`. Branch `feat/APP08` criada da `main` atualizada (estava em
  `d9ddd8f` em 2026-11-20). Commits locais do GSD liberados nos dois repos; **push só com
  autorização explícita** (nenhum plano faz `git push`).
- **D-13:** A lista enxuta do acervo traz só o que o cartão e o toque usam: id, código, título,
  preços no mesmo formato do cartão público (para reaproveitar `linhasDePreco`), foto de capa,
  situação, o booleano "Seu" (D-06) e o booleano "está na vitrine" (D-07). Nada de proprietário,
  pendências de publicação ou detalhe por natureza. Os nomes de campo ficam para a pesquisa e o
  plano, e são congelados no contrato (D-15).
- **D-14:** Isolamento (AC-5) é garantido e testado **no Django**: corretor da empresa A não vê
  imóvel da empresa B na lista (nem com `busca`/`situacao`) e recebe 404 pelo id. O app não filtra
  nada.

### Contrato e rastreabilidade
- **D-15:** Novo **§14** em `01-CONTRATO-API.md` no padrão do §13: login, "quem sou eu", Sair, lista
  do acervo (parâmetros, envelope paginado, campos enxutos), 400/401/429 e o efeito do Sair em
  outros aparelhos (ver Claude's Discretion → Sessão).
- **D-16:** Novos IDs em `REQUIREMENTS.md` (seção "Login e acervo (APP08)"), mapeados para a
  Phase 8 no ROADMAP (`**Requirements**:`) e na tabela de rastreabilidade, cobrindo AC-1..AC-6 e as
  rotas da web, como a Phase 7 fez (F7/D-17). Os nomes exatos dos IDs ficam para o planejador.

### Regras do projeto (carregadas das fases anteriores)
- **D-17 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado freezed,
  `Result`/falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e branco,
  código e comentários em português; `Navigator.push` + `MaterialPageRoute`, sem go_router
  (F4/D-18, F7/D-07).
- **D-18 [informational]:** `flutter analyze` limpo e `flutter test` verde **rodados à mão a cada
  onda**: o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter.
  `python manage.py test` verde no repo web. Arquivos gerados que o `build_runner` reescreve só com
  CRLF são restaurados com `git checkout --`. `workflow.use_worktrees=false`.

### Claude's Discretion
- **Sessão e Sair** (área não escolhida para discussão; seguir estas recomendações, a menos que a
  pesquisa ache problema):
  - Na abertura, o app lê o token do `flutter_secure_storage` só para decidir o rótulo do botão
    ("Meu acervo" ou "Entrar"); a vitrine não espera rede de sessão para abrir (AC-6).
  - Ao tocar em "Meu acervo", o app chama "quem sou eu" e roteia pelo papel. **Qualquer 401** (nessa
    chamada ou na lista do acervo) apaga o token local, volta o botão para "Entrar" e abre o login
    com o aviso "Sua sessão terminou. Entre de novo." Tratamento centralizado na camada de dados
    (por exemplo, uma falha tipada de sessão expirada).
  - O cabeçalho `Authorization: Token <chave>` vai **só** nas rotas autenticadas; as rotas públicas
    da vitrine continuam sem token. O token nunca é logado.
  - Sair fica na barra do acervo e na tela de aviso (D-B), com um diálogo simples de confirmação.
    Chama a revogação no servidor como melhor esforço e **apaga o token do aparelho mesmo se a
    chamada falhar** (AC-2); depois volta à vitrine com "Entrar".
  - **Atenção (registrar no §14 e no UAT):** o login usa `Token.objects.get_or_create`, então cada
    usuário tem **um token só, compartilhado entre os aparelhos**. Revogar no Sair (D-A) desconecta
    os outros aparelhos do mesmo corretor. O site usa sessão e não é afetado. É consequência aceita
    do D-A, a menos que a pesquisa ache uma alternativa barata sem dependência nova.
- **Rota do acervo:** a pesquisa precisa confirmar quem mais consome `GET /api/imoveis/` (lista).
  Se só o app usa a lista, adaptar o `ImovelViewSet.list` (filtros, paginação e serializer enxuto
  só na listagem). Se outro cliente usa, criar uma rota própria do acervo com a mesma permissão
  `EhCorretor` e o `EmpresaScopedQuerySetMixin`.
- **"Quem sou eu":** nome e caminho no padrão de `contas/api/urls.py` (o card sugere
  `GET /api/auth/eu/`); devolve pelo menos o papel (`CORRETOR`/`GESTOR`/`ADMINISTRADOR`). Campos a
  mais (nome para saudação, empresa) só se a tela usar.
- **Limite de tentativas no login:** taxa e escopo (por IP, por e-mail ou os dois) ficam para a
  pesquisa propor, com `ScopedRateThrottle`/classe em `core/throttles.py` e taxa em `settings.py`,
  como a vitrine pública fez.
- **Sair no servidor:** forma da rota (`POST /api/auth/sair/` ou nome equivalente no padrão do repo).
- **Textos** de acervo vazio, nenhum resultado para a busca/filtro, título da tela ("Meu acervo"),
  ícones, e o texto exato da tela de aviso (D-B).
- **Estrutura de pastas** (sugestão: `lib/presentation/acervo/`, `lib/presentation/login/`,
  `lib/presentation/sessao/`, arquivos novos em `data/` e `domain/`) e quantos Cubits (sessão, login,
  acervo).
- **UI-SPEC:** como na F4/D-20 e na F7/D-16, as decisões D-01..D-11 podem servir de contrato de UI,
  com confirmação no human-check de fim de fase; `/gsd-ui-phase 8` é opcional.
- `flutter_secure_storage` exige configuração nativa (por exemplo, `minSdkVersion` do Android): a
  pesquisa confere o que o projeto precisa mudar.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Fonte da fase
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-CARD-APP08.md` — texto oficial do card (história + 6 critérios), o que a API já entrega, lacunas da web e as decisões D-A..D-E
- `.planning/ROADMAP.md` — Phase 8 (goal + 6 critérios de sucesso)
- `.planning/REQUIREMENTS.md` — onde entram os IDs novos (D-16)
- `.planning/PROJECT.md` — regras (nada de regra de negócio no app, isolamento multitenant como critério de maior peso)

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — §4 paginação por página, "Erros 429", §6 allowlist, §7 isolamento, §12 sincronização e antidrift, §13 (modelo para o novo §14, D-15)

### Fases anteriores (padrões a seguir)
- `.planning/phases/07.1-integra-o-da-app-07-com-a-api-real/07.1-CONTEXT.md` — como uma fase trabalhou nos dois repos (branch na web, testes, UAT com `semear_vitrine_dev`)
- `.planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-CONTEXT.md` — falhas tipadas, Cubits com estados explícitos, rolagem infinita com rodapés
- `.planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-CONTEXT.md` — DataSource real com Dio, `PageNumberPagination`, 429

### Django (repo web `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web`, `main` em `d9ddd8f`)
- `contas/api/views.py`, `contas/api/urls.py`, `contas/api/serializers.py` — `LoginAPIView` (`Token.get_or_create`, erro único), onde entram "quem sou eu" e Sair
- `contas/models.py` — `Usuario.Perfil` (`ADMINISTRADOR`, `GESTOR`, `CORRETOR`)
- `imoveis/api/views.py`, `imoveis/api/serializers.py`, `imoveis/api/urls.py` — `ImovelViewSet` (`EhCorretor`, `EmpresaScopedQuerySetMixin`, `ImovelSerializer` completo)
- `imoveis/forms.py` — `FiltroImovelForm` (regra única de `busca`/`situacao`, D-11)
- `imoveis/views.py` — `ImovelListView` (painel do corretor no site, como usa o form)
- `imoveis/models.py` — `Imovel` (`codigo`, `corretor_responsavel`, `publicado`, `situacao`), `ImovelQuerySet` (regra da vitrine pública, D-07)
- `imoveis/vitrine.py`, `imoveis/api/urls_publico.py` — serializer/cartão público (formato dos preços, D-13)
- `core/permissions.py` (`EhCorretor`), `core/mixins.py` (`EmpresaScopedQuerySetMixin`), `core/throttles.py` — permissões, isolamento, limite de taxa
- `config/settings.py` (`REST_FRAMEWORK`: autenticação Token + Session, `DEFAULT_THROTTLE_RATES`), `config/urls.py`
- `imoveis/tests.py`, `contas/tests.py`, `core/tests.py` — como a web testa isolamento, API e limites

### App (este repo)
- `lib/di/modulo_rede.dart` — `Dio` único, sem interceptors nem autenticação hoje (onde entra o token só nas rotas autenticadas)
- `lib/core/result.dart` — `Result` sealed
- `lib/presentation/vitrine/vitrine_screen.dart`, `vitrine_cubit.dart`, `vitrine_state.dart` — busca com atraso de 400 ms, paginação por página, onde fica o topo
- `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart` — topo da vitrine, onde entra o botão "Entrar"/"Meu acervo" (D-C)
- `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart`, `sliver_imoveis_anunciante.dart` — rodapés e rolagem infinita reaproveitáveis
- `lib/presentation/vitrine/apresentacao_imovel.dart` (`linhasDePreco`), `lib/presentation/comum/imagem_rede.dart` — preço e imagem do cartão compacto (D-05)
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` — `abrirDetalheImovel` (toque, D-07)
- `lib/main.dart` — abertura (`_TelaInicial`), onde entra a leitura do token (D-C, AC-6)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ImagemRede` (`lib/presentation/comum/imagem_rede.dart`): miniatura do cartão compacto, com placeholder e erro.
- `linhasDePreco` e os rótulos de `apresentacao_imovel.dart`: preço do cartão do acervo, desde que a lista enxuta traga os preços no formato do cartão público.
- `RodapePaginacaoLista` + o padrão de rolagem infinita da vitrine/vitrine do anunciante (carregar mais a 90% da rolagem, pedir a próxima página se a primeira não enche a tela).
- `SearchBar` + atraso de 400 ms do `VitrineCubit`: mesmo comportamento para a busca do acervo.
- `abrirDetalheImovel`: abre a página pública do imóvel a partir do toque (D-07).
- `Result` sealed (`lib/core/result.dart`) e o padrão de falhas tipadas por status HTTP dos DataSources remotos (404, 429).

### Established Patterns
- DataSource remoto com `Dio` injetado + Model freezed/json_serializable + entidade de domínio + UseCase + Cubit com estado freezed; DI por `injectable` (`dart run build_runner build -d`).
- Testes: `bloc_test` + `mocktail`; DataSources testados com Dio mockado e fixtures de wire; e2e com a API falsa de `test/support`.
- Hoje o `Dio` não tem interceptor nem cabeçalho de autenticação, e o app inteiro é público. O token entra só nas rotas autenticadas novas.
- Primeira dependência nova desde a APP-01: `flutter_secure_storage` (D-D).

### Integration Points
- Topo da vitrine (`SeletorCidadeTopo` / `VitrineScreen`): botão "Entrar"/"Meu acervo" (D-C).
- Abertura (`main.dart`, `_TelaInicial`): lê o token para o rótulo do botão, sem atrasar a vitrine (AC-6).
- `lib/di/modulo_rede.dart` / `injection.dart`: registro do armazenamento seguro, dos DataSources de autenticação e acervo, e do jeito de anexar o token.
- Repo web: `contas/api/urls.py` (eu, sair, limite no login) e `imoveis/api/` (acervo com filtros, paginação e serializer enxuto).

</code_context>

<specifics>
## Specific Ideas

- Pedido do Allysson para o cartão: "faça tudo de acordo com os detalhes da fase que te mandei". Nada além do card; marcas e telas extras ficam fora (D-06).
- Textos fixos decididos: "E-mail ou senha inválidos." · "Não foi possível entrar agora. Tente de novo." · "Muitas tentativas. Tente de novo em N minutos." / "Tente de novo em alguns minutos." · placeholder da busca "Buscar por código ou título" · chips "Todas", "Disponível", "Reservado", "Vendido", "Alugado".
- Testar no emulador exige o Django rodando: `runserver 0.0.0.0:8000` e `10.0.2.2` no `ALLOWED_HOSTS` do `Web\.env`; `semear_vitrine_dev` para os dados. O UAT vai precisar de usuários corretor e gestor com senha conhecida em empresas diferentes (para o AC-5); a pesquisa confere se o seed já cria isso ou se o UAT usa o admin/shell.
- Exemplo real da busca por código: `DEV-CAMPINAS-14` = "Apartamento no bairro Barão Geraldo".

</specifics>

<deferred>
## Deferred Ideas

- **Detalhe do acervo:** tela só leitura que abre qualquer imóvel do acervo (via `GET /api/imoveis/<id>/`), inclusive os não publicados. O card só pede a lista; fica para uma fase futura.
- **Marca "Não publicado"** no cartão do acervo: fora do card (D-06).
- **Área do gestor/administrador no app:** APP-12 troca a tela de aviso (D-B).
- **Token por aparelho** (Sair que não desconecta os outros aparelhos): exigiria trocar o `Token` único do DRF por outro esquema; só se a desconexão geral virar problema.

</deferred>

---

*Phase: 08-login-e-rea-do-corretor-o-acervo*
*Context gathered: 2026-11-20*
