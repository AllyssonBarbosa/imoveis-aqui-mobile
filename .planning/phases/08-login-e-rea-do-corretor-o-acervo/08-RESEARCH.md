# Phase 8: Login e Área do Corretor — o Acervo - Research

**Researched:** 2026-11-20
**Domain:** Autenticação por token DRF (login, "quem sou eu", Sair) + acervo autenticado, paginado e filtrado no Django, consumidos por um app Flutter (Clean Architecture + Cubit) com sessão em `flutter_secure_storage`
**Confidence:** HIGH no lado web e no wiring do app (código lido e experimentos de leitura rodados nesta sessão); MEDIUM em iOS/Keychain (sem Mac aqui) e nas taxas do limite de tentativas (decisão de produto)

**Repos lidos:** app `C:/projetos/imoveis-aqui-mobile` (branch `feat/APP08`, HEAD `7301fea`); web `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` na branch `main`, commit `d9ddd8f` (árvore limpa, `git status` sem alterações). Nada foi alterado nos dois repos.

**Linha de base medida nesta sessão (para o gate de cada onda):** Django `695 tests ... OK` (18 s, SQLite em memória); app `flutter analyze lib` → `No issues found!`; app `flutter test` → `All tests passed!` (774 testes).

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Travadas no card, antes da discussão (D-A..D-E — não perguntar de novo)**
- **D-A · Escopo web = necessário + segurança.** No repo web, branch `feat/APP08`: endpoint "quem sou eu", busca + situação + paginação na rota do corretor reaproveitando `FiltroImovelForm(campos=["busca", "situacao"])`, lista enxuta para o cartão, limite de tentativas no login, e um Sair que revoga o token no servidor (além de apagar do aparelho).
- **D-B · Gestor/administrador no app:** o login funciona e abre uma tela de aviso ("a área do gestor ainda não está no app") com Sair. A APP-12 troca essa tela depois, sem mexer no login.
- **D-C · Abertura:** o app continua abrindo na vitrine para todo mundo; com sessão, o botão do topo vira "Meu acervo"; sem sessão, "Entrar".
- **D-D · Token em `flutter_secure_storage`** (Keychain/Keystore). A nota do CLAUDE.md que descartava o pacote valia só enquanto o app não guardava credencial.
- **D-E · Fluxo completo de planejamento:** pesquisa → padrões → planejador → verificador.

**Tela de login**
- **D-01:** Tela própria, aberta por `Navigator.push` a partir do botão "Entrar" no topo da vitrine. Campos: e-mail (teclado de e-mail, autofill) e senha (oculta, com botão de mostrar/ocultar). Um `FilledButton` "Entrar" mostra o carregamento e fica desabilitado enquanto o pedido está em curso. O app só barra campo vazio; formato de e-mail e credencial são do servidor.
- **D-02:** Depois de entrar, o corretor vai **direto ao "Meu acervo"**. A rota de login é substituída, então o "voltar" leva à vitrine (que já mostra "Meu acervo"), nunca de volta ao login. O papel vem da rota "quem sou eu", chamada logo após o login (o login só devolve o token). Gestor/admin vão para a tela de aviso (D-B).
- **D-03:** Credencial inválida (400) → o app mostra o **texto fixo dele**: "E-mail ou senha inválidos." (as mesmas palavras do site), nunca a string que o servidor mandar. Rede, timeout ou 5xx → "Não foi possível entrar agora. Tente de novo." As duas são falhas tipadas diferentes na camada de dados. Nenhum texto revela se o e-mail existe (AC-3).
- **D-04:** Limite de tentativas (429) → "Muitas tentativas. Tente de novo em N minutos.", com N lido do cabeçalho `Retry-After` que o DRF manda (segundos arredondados para minutos para cima, mínimo 1). Sem o cabeçalho: "Tente de novo em alguns minutos." O limite em si é do Django (D-A).

**Cartão do acervo e toque**
- **D-05:** **Cartão compacto em linha**, widget novo: miniatura quadrada à esquerda (`ImagemRede`, com placeholder); à direita código + título (até 2 linhas), preço (reaproveitando `linhasDePreco`/`apresentacao_imovel.dart`) e as marcas. Material 3, cores só do `ColorScheme`, texto do `textTheme`.
- **D-06:** As marcas seguem só o que o card pede. O Allysson pediu: "faça tudo de acordo com os detalhes da fase que te mandei". Entram:
  - **chip de situação** (Disponível / Reservado / Vendido / Alugado), porque é o filtro do card;
  - **código**, porque a busca do site procura por código ou título;
  - **marca "Seu"** quando o imóvel é do corretor logado, porque o card separa "os do corretor e os da imobiliária". Vem como booleano **calculado no Django** (`corretor_responsavel` == usuário logado); o app nunca compara ids.

  **Não** entra a marca "Não publicado", nem qualquer outra marca fora do card.
- **D-07:** Toque: a lista enxuta traz um booleano calculado no Django pela **mesma regra da vitrine pública**: publicado + `DISPONIVEL` + empresa ativa, a regra do `ImovelQuerySet` em `imoveis/models.py`. Verdadeiro → o toque abre a página do imóvel que já existe (`abrirDetalheImovel`). Falso → o cartão não reage ao toque (sem `onTap`, sem ripple). O app nunca decide isso olhando `publicado`/`situacao`.

**Busca e filtro por situação**
- **D-08:** `SearchBar` "Buscar por código ou título", resolvida no servidor (parâmetro `busca`), com o mesmo atraso de digitação da vitrine (400 ms, `vitrine_cubit.dart`).
- **D-09:** Abaixo da busca, uma **linha de chips de escolha única**: Todas, Disponível, Reservado, Vendido, Alugado → parâmetro `situacao` com os valores do enum `Imovel.Situacao` (`DISPONIVEL`, `RESERVADO`, `VENDIDO`, `ALUGADO`). "Todas" não manda o parâmetro. Busca e situação se combinam.
- **D-10:** A ordem é a que o Django devolver; não há botão de ordenar. Paginação por página (`PageNumberPagination`, como a APP-05), com rolagem infinita e rodapés de carregando/erro/fim no padrão que já existe.
- **D-11:** No servidor, a regra é `FiltroImovelForm(campos=["busca", "situacao"])`, a mesma do painel do corretor no site. Filtro inválido é ignorado, não vira erro (D-A).

**Web (detalhes do D-A)**
- **D-12:** Repo web em `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui` (pasta `Web` = Django), **não** `../imoveis-aqui/Web`. Branch `feat/APP08` criada da `main` atualizada (estava em `d9ddd8f` em 2026-11-20). Commits locais do GSD liberados nos dois repos; **push só com autorização explícita** (nenhum plano faz `git push`).
- **D-13:** A lista enxuta do acervo traz só o que o cartão e o toque usam: id, código, título, preços no mesmo formato do cartão público (para reaproveitar `linhasDePreco`), foto de capa, situação, o booleano "Seu" (D-06) e o booleano "está na vitrine" (D-07). Nada de proprietário, pendências de publicação ou detalhe por natureza. Os nomes de campo ficam para a pesquisa e o plano, e são congelados no contrato (D-15).
- **D-14:** Isolamento (AC-5) é garantido e testado **no Django**: corretor da empresa A não vê imóvel da empresa B na lista (nem com `busca`/`situacao`) e recebe 404 pelo id. O app não filtra nada.

**Contrato e rastreabilidade**
- **D-15:** Novo **§14** em `01-CONTRATO-API.md` no padrão do §13: login, "quem sou eu", Sair, lista do acervo (parâmetros, envelope paginado, campos enxutos), 400/401/429 e o efeito do Sair em outros aparelhos (ver Claude's Discretion → Sessão).
- **D-16:** Novos IDs em `REQUIREMENTS.md` (seção "Login e acervo (APP08)"), mapeados para a Phase 8 no ROADMAP (`**Requirements**:`) e na tabela de rastreabilidade, cobrindo AC-1..AC-6 e as rotas da web, como a Phase 7 fez (F7/D-17). Os nomes exatos dos IDs ficam para o planejador.

**Regras do projeto (carregadas das fases anteriores)**
- **D-17 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado freezed, `Result`/falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e branco, código e comentários em português; `Navigator.push` + `MaterialPageRoute`, sem go_router (F4/D-18, F7/D-07).
- **D-18 [informational]:** `flutter analyze` limpo e `flutter test` verde **rodados à mão a cada onda**: o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter. `python manage.py test` verde no repo web. Arquivos gerados que o `build_runner` reescreve só com CRLF são restaurados com `git checkout --`. `workflow.use_worktrees=false`.

### Claude's Discretion
- **Sessão e Sair** (área não escolhida para discussão; seguir estas recomendações, a menos que a pesquisa ache problema):
  - Na abertura, o app lê o token do `flutter_secure_storage` só para decidir o rótulo do botão ("Meu acervo" ou "Entrar"); a vitrine não espera rede de sessão para abrir (AC-6).
  - Ao tocar em "Meu acervo", o app chama "quem sou eu" e roteia pelo papel. **Qualquer 401** (nessa chamada ou na lista do acervo) apaga o token local, volta o botão para "Entrar" e abre o login com o aviso "Sua sessão terminou. Entre de novo." Tratamento centralizado na camada de dados (por exemplo, uma falha tipada de sessão expirada).
  - O cabeçalho `Authorization: Token <chave>` vai **só** nas rotas autenticadas; as rotas públicas da vitrine continuam sem token. O token nunca é logado.
  - Sair fica na barra do acervo e na tela de aviso (D-B), com um diálogo simples de confirmação. Chama a revogação no servidor como melhor esforço e **apaga o token do aparelho mesmo se a chamada falhar** (AC-2); depois volta à vitrine com "Entrar".
  - **Atenção (registrar no §14 e no UAT):** o login usa `Token.objects.get_or_create`, então cada usuário tem **um token só, compartilhado entre os aparelhos**. Revogar no Sair (D-A) desconecta os outros aparelhos do mesmo corretor. O site usa sessão e não é afetado. É consequência aceita do D-A, a menos que a pesquisa ache uma alternativa barata sem dependência nova.
- **Rota do acervo:** a pesquisa precisa confirmar quem mais consome `GET /api/imoveis/` (lista). Se só o app usa a lista, adaptar o `ImovelViewSet.list` (filtros, paginação e serializer enxuto só na listagem). Se outro cliente usa, criar uma rota própria do acervo com a mesma permissão `EhCorretor` e o `EmpresaScopedQuerySetMixin`.
- **"Quem sou eu":** nome e caminho no padrão de `contas/api/urls.py` (o card sugere `GET /api/auth/eu/`); devolve pelo menos o papel (`CORRETOR`/`GESTOR`/`ADMINISTRADOR`). Campos a mais (nome para saudação, empresa) só se a tela usar.
- **Limite de tentativas no login:** taxa e escopo (por IP, por e-mail ou os dois) ficam para a pesquisa propor, com `ScopedRateThrottle`/classe em `core/throttles.py` e taxa em `settings.py`, como a vitrine pública fez.
- **Sair no servidor:** forma da rota (`POST /api/auth/sair/` ou nome equivalente no padrão do repo).
- **Textos** de acervo vazio, nenhum resultado para a busca/filtro, título da tela ("Meu acervo"), ícones, e o texto exato da tela de aviso (D-B).
- **Estrutura de pastas** (sugestão: `lib/presentation/acervo/`, `lib/presentation/login/`, `lib/presentation/sessao/`, arquivos novos em `data/` e `domain/`) e quantos Cubits (sessão, login, acervo).
- **UI-SPEC:** como na F4/D-20 e na F7/D-16, as decisões D-01..D-11 podem servir de contrato de UI, com confirmação no human-check de fim de fase; `/gsd-ui-phase 8` é opcional.
- `flutter_secure_storage` exige configuração nativa (por exemplo, `minSdkVersion` do Android): a pesquisa confere o que o projeto precisa mudar.

### Deferred Ideas (OUT OF SCOPE)
- **Detalhe do acervo:** tela só leitura que abre qualquer imóvel do acervo (via `GET /api/imoveis/<id>/`), inclusive os não publicados. O card só pede a lista; fica para uma fase futura.
- **Marca "Não publicado"** no cartão do acervo: fora do card (D-06).
- **Área do gestor/administrador no app:** APP-12 troca a tela de aviso (D-B).
- **Token por aparelho** (Sair que não desconecta os outros aparelhos): exigiria trocar o `Token` único do DRF por outro esquema; só se a desconexão geral virar problema.
</user_constraints>

<phase_requirements>
## Phase Requirements

> O ROADMAP diz `Requirements: TBD` e o `REQUIREMENTS.md` ainda não tem a seção. Por D-16 o planejador cria os IDs; abaixo vai uma **proposta pronta para adoção** (prefixos novos `AUTH` e `ACV`; `API-09`/`API-10` continuam a série `API-xx`, que hoje termina em `API-08`). Registrar é a primeira tarefa da fase.

| ID | Descrição proposta (texto para o REQUIREMENTS.md) | AC / decisão | Research Support |
|----|---------------------------------------------------|--------------|------------------|
| AUTH-01 | O corretor entra no app com e-mail e senha; o token vem de `POST /api/auth/login/`. | AC-1 | Seção "Padrões" (login via Dio público, sem token); `LoginAPIView` lida |
| AUTH-02 | A sessão fica guardada em `flutter_secure_storage`; Sair apaga o token do aparelho (mesmo se a rede falhar) e o revoga no servidor. | AC-2, D-D | Seções `flutter_secure_storage`, Sair, `SairAPIView` |
| AUTH-03 | O erro de login é genérico: texto fixo do app, nenhum texto revela se o e-mail existe; 429 e falha de rede têm mensagens próprias e tipadas. | AC-3, D-03, D-04 | `Retry-After` verificado; falhas tipadas por status |
| AUTH-04 | Sem login o app abre direto na vitrine; o botão do topo mostra "Entrar" ou "Meu acervo" conforme a sessão guardada, sem atrasar a vitrine. | AC-6, D-C | Seção "Abertura e sessão" |
| AUTH-05 | Gestor e administrador entram, o papel vem de `GET /api/auth/eu/` e veem uma tela de aviso com Sair. | D-B, D-02 | Seção "Quem sou eu" |
| AUTH-06 | O servidor limita as tentativas de login por e-mail e por IP (429 com `Retry-After`) sem revelar se o e-mail existe. | D-A, D-04 | Seção "Limite de tentativas" |
| ACV-01 | O corretor vê o acervo (os imóveis dele e os da imobiliária) numa lista paginada com rolagem infinita, em cartão compacto (código, título, preço, situação, marca "Seu"). | AC-4, D-05, D-06, D-10 | Seções "Rota do acervo" e "Lista enxuta" |
| ACV-02 | Busca por código ou título e filtro por situação (Todas/Disponível/Reservado/Vendido/Alugado) resolvidos no servidor com `FiltroImovelForm`; filtro inválido é ignorado. | AC-4, D-08, D-09, D-11 | Seção "Busca + situação" |
| ACV-03 | Imóvel de outra empresa não aparece na lista (nem com `busca`/`situacao`/parâmetros extras) nem pelo id (404); gestor e administrador recebem 403, sem token 401 — testado no Django. | AC-5, D-14 | Seção "Isolamento"; testes propostos |
| ACV-04 | O toque num cartão do acervo só abre a página do imóvel quando o servidor diz que ele está na vitrine (`na_vitrine`); senão o cartão não reage. | D-07 | Seção "Lista enxuta" (`Exists` sobre `na_vitrine()`) |
| API-09 | O contrato §14 de `01-CONTRATO-API.md` congela login, "quem sou eu", Sair, a lista do acervo, 400/401/403/404/429 e o efeito do Sair em outros aparelhos; fixtures e testes antidrift cobrem as rotas autenticadas. | D-15 | Seção "Contrato §14" |
| API-10 | A web entrega (com testes) `GET /api/auth/eu/`, `POST /api/auth/sair/`, o limite de tentativas no login e a lista do acervo paginada, filtrada e enxuta em `GET /api/imoveis/`. | D-A | Seções web |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Fontes lidas: `.claude/CLAUDE.md` do app, `CLAUDE.md` da raiz do repo web (regras de negócio do Django), `.claude/skills/flutter-frontend/skill` (arquivo chama-se `skill`, sem extensão).

- **Arquitetura (não negociável):** `data/` (Models com serialização, Repositories, Data Sources), `domain/` (UseCases puros, interfaces de Repository), `presentation/` (Widgets limpos, Cubits). Widget nunca faz lógica de negócio nem chamada de rede.
- **Estado:** Cubit (flutter_bloc) com estados imutáveis (freezed). **Erros:** `Result`/sealed + `Loading`/`Success<T>`/`Failure(Exception)`; sem `try/catch` genérico na UI.
- **Modelos:** todo JSON em Models imutáveis (`freezed` + `json_serializable`); nunca `dynamic` onde a tipagem forte couber.
- **UI:** Material 3, `ColorScheme.fromSeed`, widgets de `material.dart`, `Theme.of(context).textTheme`; paleta verde e branco; nenhuma cor fora do `ColorScheme`.
- **Skill flutter-md3-expert:** construtores `const` sempre; **não** criar métodos `Widget buildX()` (extrair classes `StatelessWidget`); evitar `!`; usar pattern matching do Dart 3; componentes visuais não fazem HTTP.
- **Regra de negócio:** nada que "valha dinheiro" ou mude estado é decidido no app (aqui: "Seu" e "na vitrine" vêm prontos do Django). **Isolamento multitenant:** toda consulta filtra pela empresa do usuário logado (CLAUDE.md do web).
- **Idioma:** código, models, variáveis e comentários em português. **Branches:** `feat/<card>` (`feat/APP08`, nos dois repos).
- **Segurança (CLAUDE.md do web):** nunca token/senha no código; usar `.env`. Não editar `.gitignore` sem avisar. **Git:** nenhum commit/push sem autorização no repo web (aqui o D-12 já libera commits locais do GSD; push só com autorização explícita).
- **Workflow GSD:** edições de arquivo só dentro de um comando GSD.

## Summary

O app precisa de **uma** dependência nova (`flutter_secure_storage ^11.2.0`, verificada: publicada em 2026-09-16, SDK `>=3.8.0`, resolve limpo no `pubspec.lock` atual por `flutter pub add --dry-run`) e de nenhuma mudança no `minSdk`/`compileSdk` (Flutter 3.47.9 já usa `minSdkVersion = 24` e `compileSdkVersion = 36`, e o pacote 11.x exige minSdk 24). O projeto só tem as plataformas `android/` e `ios/` (não há `macos/` nem `windows/`), então não há entitlement de macOS nem de Windows a tratar. A configuração nativa que de fato falta é **`android:allowBackup="false"`** (o manifest atual não declara, e o padrão do Android faz backup no Google Drive, o que a documentação do pacote aponta como causa de `Failed to unwrap key`) e, no iOS, o arquivo de entitlements do Keychain pedido no README do pacote (só verificável num Mac).

No Django, quase tudo cabe em lugares que já existem. O `ImovelViewSet` (`EhCorretor` + `EmpresaScopedQuerySetMixin`) só é consumido, na árvore inteira e nas branches remotas lidas, por testes e por uma linha de README; portanto a recomendação (regra do CONTEXT) é **adaptar `list`**: paginar, filtrar por `FiltroImovelForm(campos=["busca","situacao"])` e usar um serializer enxuto só na listagem, sem tocar em `retrieve`/`create`/`update`. O isolamento (AC-5) continua garantido pelo mixin, que filtra antes de qualquer filtro do formulário. "Quem sou eu" (`GET /api/auth/eu/`) e Sair (`POST /api/auth/sair/`) são duas `APIView` pequenas em `contas/api`; o limite de tentativas são duas classes em `core/throttles.py` (por e-mail e por IP), com taxas no `settings.py` no padrão `VITRINE_TAXA_ANONIMA`. A consequência do token único compartilhado (Sair desconecta os outros aparelhos) **não tem alternativa barata**: o DRF 3.18.1 não traz `AbstractToken`, então token por aparelho exigiria modelo novo, migração e classe de autenticação nova. Fica como consequência aceita, como o CONTEXT previa.

No app, o desenho que mantém o token fora das rotas públicas **por construção** é um segundo `Dio` nomeado (`@Named('autenticado')`) com um interceptor que anexa `Authorization: Token <chave>` só para a origem da API e converte qualquer 401 em `SessaoExpiradaException` depois de apagar o token (com comparação do token usado, para não apagar um token novo por causa de uma resposta velha). O `Dio` público existente não muda, e o login usa o `Dio` público (um token velho nunca viaja no login). O `SessaoCubit` é um singleton de DI provido acima do `MaterialApp`; o botão "Entrar"/"Meu acervo" entra por um *slot* opcional de `CidadeSelecaoScreen` → `VitrineScreen` (padrão do `aoAbrirImovel`), o que limita o estrago nos testes existentes.

**Primary recommendation:** Faça a web primeiro e congele o contrato §14 (10 campos no item do acervo, incluindo `finalidade`, que o D-13 não listou mas o `linhasDePreco` exige); no app use um segundo `Dio` nomeado com interceptor de sessão, um `SessaoCubit` singleton e `flutter_secure_storage` atrás de uma interface própria com fake em memória, mantendo o `Dio` público e os 774 testes atuais intactos.

### Achados que mudam o plano (não estavam no CONTEXT)

1. **`finalidade` falta no D-13.** `linhasDePreco`/`linhasDePrecoPorFinalidade` decidem quais linhas de preço mostrar pela finalidade (`venda`, `aluguel`, `vendaEAluguel`); sem `finalidade` o cartão não sabe se mostra "Venda R$ …" e "Aluguel R$ …/mês" ou só um. O item do acervo precisa de `finalidade` (10 chaves, não 9). Isso é uma emenda ao D-13 a registrar no §14.
2. **`FiltroImovelForm` invalida tudo se um campo for inválido.** `?busca=abc&situacao=XXX` dá formulário inválido e `filtrar()` devolve o queryset **sem nenhum filtro**, inclusive sem a `busca` válida (experimento rodado nesta sessão, ver "Busca + situação"). É o comportamento do site e o app só envia enums válidos; deve ficar escrito no §14 e coberto por teste.
3. **`LoginAPIView` usa `authentication_classes` padrão.** Um `Authorization: Token <velho>` enviado ao login volta **401** antes da view (DRF autentica antes de qualquer view, mesmo `AllowAny`). Hoje nada no app manda token ao login, mas o endurecimento barato é `authentication_classes = []` na view (a vitrine pública já faz isso).
4. **Mudar `list` quebra um teste existente e uma linha de README.** `ImovelApiTests.test_lista_apenas_da_propria_empresa` itera `response.data` como lista (`for item in response.data`); com paginação vira `response.data["results"]`. A linha `GET/POST /api/imoveis/` do README precisa ser atualizada. É mudança de contrato de uma rota documentada, sem consumidor conhecido além do app desta fase (premissa A2).
5. **O seed da vitrine não serve de UAT sozinho.** `semear_vitrine_dev` cria corretores com `set_unusable_password()` e **uma só empresa**; AC-5 precisa de duas empresas com login. Receita barata, sem código novo, na seção "Dados de UAT".
6. **O app só tem Android e iOS.** `ls` da raiz: `android ios lib test tool ...`; sem `macos/`/`windows/`.
7. **O token vaza se `next` apontar para outra origem.** Hoje a guarda de mesma origem (`_exigirMesmaOrigem`) protege só contra SSRF; nas rotas autenticadas ela passa a proteger a credencial. O interceptor também deve anexar o token só se a origem do pedido for a da base URL.
8. **O `ApiFalsa` de teste não grava cabeçalhos** (`_AdaptadorApiFalsa.fetch` passa só `options.uri`). Os testes "o token só vai nas rotas autenticadas" exigem estender o `ApiFalsa` (Wave 0).
9. **D-04 pode chegar a 60 minutos.** O DRF só aceita períodos `s`, `m`, `h`, `d` (`parse_rate` lê `period[0]`); uma taxa por hora gera `Retry-After` de até 3600 s → "em 60 minutos".

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Autenticar (e-mail+senha → token) | API / Backend (`LoginAPIView`) | — | `authenticate()` do Django; app só envia credencial e guarda a chave |
| Limite de tentativas no login | API / Backend (`core/throttles.py`) | — | Regra de segurança nunca no aparelho; cache do servidor |
| Revogar sessão (Sair) | API / Backend (`SairAPIView`) | App (apaga token local) | Servidor invalida; aparelho apaga sempre, mesmo se a chamada falhar (AC-2) |
| Papel do usuário ("quem sou eu") | API / Backend | App (roteia a tela) | O app nunca infere papel; `perfil` vem do servidor |
| Guardar o token | App (Keychain/Keystore via `flutter_secure_storage`) | — | Único estado local sensível |
| Anexar token / tratar 401 | App `data/` (interceptor do Dio autenticado) | — | Centralizado, sem `try/catch` na UI (CONTEXT) |
| Isolamento por empresa (AC-5) | API / Backend (`EmpresaScopedQuerySetMixin`) | — | Queryset filtrado antes de busca/situação; o app não filtra nada |
| Busca e situação do acervo | API / Backend (`FiltroImovelForm`) | App (envia `busca`/`situacao`) | Mesma regra do painel do site (D-11) |
| "Seu" e "está na vitrine" | API / Backend (serializer + `na_vitrine()`) | App (só exibe) | Regra de negócio do servidor (D-06, D-07) |
| Paginação do acervo | API / Backend (`PageNumberPagination`) | App (segue `next`) | Mesmo envelope da APP-05 |
| Rótulo "Entrar"/"Meu acervo" | App `presentation/` (`SessaoCubit`) | App `data/` (leitura do storage) | Só decide o rótulo; não valida a sessão na abertura |
| Tela de login, acervo, aviso | App `presentation/` | — | UI pura sobre Cubits |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `flutter_secure_storage` | `^11.2.0` (nova; publicada 2026-09-16, dependências Dart `>=3.8.0`/Flutter `>=3.19.0`) | Guardar o token no Keychain (iOS) / Keystore (Android) | Decisão D-D; pacote com publisher verificado `steenbakker.dev`, 4512 likes, ~6,48 M downloads/30 dias, 160/160 pontos no pub.dev. [VERIFIED: pub.dev API `api/packages/flutter_secure_storage` e `/score`] |

Já no projeto (versões do `pubspec.yaml`/`pubspec.lock`, sem mudança): `dio ^5.11.1` (cache local `dio-5.11.1`), `flutter_bloc ^9.1.1`, `freezed ^4.0.1`/`freezed_annotation ^3.1.0`, `injectable ^3.0.0`, `get_it ^9.3.0`, `bloc_test ^10.0.0`, `mocktail ^1.0.5`, `shared_preferences ^2.5.5`. [VERIFIED: pubspec.yaml]

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| (nenhuma nova) | — | Debounce, paginação, DI e testes já têm solução no projeto | — |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `flutter_secure_storage` | `shared_preferences` | Texto puro no aparelho; contradiz D-D |
| Segundo `Dio` nomeado com interceptor | `Options(headers:)` por chamada | Cada data source autenticado teria de lembrar do cabeçalho e do 401; o `Dio` público não ficaria "incapaz" de carregar token |
| Interceptor único no `Dio` público escopado por caminho | — | Um interceptor que decide por caminho quem recebe token é frágil: uma rota nova esquecida na lista vaza ou deixa de autenticar |

**Installation:**
```bash
flutter pub add flutter_secure_storage
dart run build_runner build --delete-conflicting-outputs
```

**Version verification:** `curl https://pub.dev/api/packages/flutter_secure_storage` → `latest.version = 11.2.0`, `published = 2026-09-16T11:48:19Z`, `environment = {sdk: '>=3.8.0 <4.0.0', flutter: '>=3.19.0'}`; projeto com `sdk: ^3.13.4` e Dart 3.13.7. `flutter pub add --dry-run flutter_secure_storage` resolveu (`+ flutter_secure_storage 11.2.0`, `+ flutter_secure_storage_darwin 0.4.3`, `+ flutter_secure_storage_linux 3.0.3`, `+ flutter_secure_storage_platform_interface 2.1.1`, `+ flutter_secure_storage_web 2.1.1`, `+ flutter_secure_storage_windows 4.2.2`; "Would change 6 dependencies") sem mexer no `pubspec.yaml` (`git status` limpo depois).

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `flutter_secure_storage` | pub.dev | v11.2.0 de 2026-09-16 (linha 11.x desde 2026-06; pacote antigo, `10.3.x` em 09/2026) | ~6,48 M / 30 dias | github.com/juliansteenbakker/flutter_secure_storage (publisher verificado `steenbakker.dev`) | OK (manual) | Approved — escolhido pelo usuário (D-D) |

**Nota sobre o gate:** o `gsd-tools query package-legitimacy check` só aceita `npm|pypi|crates` (a mensagem de uso não lista pub.dev). Rodar com `--ecosystem pypi` devolveu `SLOP`, mas isso é só "não existe no PyPI" (ecossistema errado, sem significado). A verificação foi feita direto no registro correto (pub.dev API + página + score + `flutter pub add --dry-run`). Não há scripts de instalação a checar (plugin Flutter, não npm). Pacotes federados puxados (`flutter_secure_storage_darwin`, `_linux`, `_platform_interface`, `_web`, `_windows`) são do mesmo publisher.

**Packages removed due to [SLOP] verdict:** nenhum
**Packages flagged as suspicious [SUS]:** nenhum (nenhum `checkpoint:human-verify` de instalação necessário; a verificação nativa em iOS é outra coisa, ver "Pitfalls")

## Architecture Patterns

### System Architecture Diagram

```
                                   APP (Flutter, Android/iOS)
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ main() ─ configureDependencies() ─ ImoveisAquiApp                           │
 │   BlocProvider.value(SessaoCubit singleton)  ← lê token do storage (async,  │
 │          │                                      NÃO bloqueia a vitrine)     │
 │          ▼                                                                  │
 │  _TelaInicial → CidadeSelecaoScreen → VitrineScreen                         │
 │                    [slot acaoSessao: BotaoSessaoTopo "Entrar"/"Meu acervo"] │
 │         "Entrar" │                          │ "Meu acervo"                  │
 │                  ▼                          ▼                               │
 │            LoginScreen ──ok──►  EntradaAreaScreen (chama GET eu)            │
 │            LoginCubit             │ papel=CORRETOR      │ GESTOR/ADMIN      │
 │                  │ pushReplacement▼                     ▼                   │
 │                  └────────────► AcervoScreen        AvisoAreaScreen         │
 │                                  AcervoCubit (busca 400 ms, chips, scroll)  │
 │   toda tela logada: Sair (diálogo) → SairUseCase → volta à vitrine          │
 │   qualquer 401 → SessaoExpiradaException → SessaoCubit.anonima + LoginScreen│
 └───────────────┬─────────────────────────────────────────────┬───────────────┘
   Dio PÚBLICO   │ (sem interceptor)         Dio 'autenticado' │ InterceptadorSessao
   login, vitrine│                           eu, sair, acervo  │ + Authorization: Token
                 ▼                                             ▼   (só mesma origem)
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ DJANGO + DRF (repo web, branch feat/APP08)                                  │
 │ POST /api/auth/login/  authentication_classes=[]  ThrottleLoginPorEmail/Ip  │
 │                        authenticate() → Token.get_or_create → {"token"}     │
 │ GET  /api/auth/eu/     TokenAuthentication → {"perfil": ...}                │
 │ POST /api/auth/sair/   TokenAuthentication → Token.filter(user).delete() 204│
 │ GET  /api/imoveis/     EhCorretor → EmpresaScopedQuerySetMixin (empresa)    │
 │                        → FiltroImovelForm(busca, situacao) → anotar         │
 │                        (na_vitrine=Exists(na_vitrine())) → paginar (20)     │
 │                        → ImovelAcervoSerializer (10 chaves)                 │
 └─────────────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure

**Web (`Web/`)**
```
core/throttles.py            # + ThrottleLoginPorEmail, ThrottleLoginPorIp
config/settings.py           # + LOGIN_TAXA_POR_EMAIL / LOGIN_TAXA_POR_IP (+ validação) em DEFAULT_THROTTLE_RATES
contas/api/views.py          # LoginAPIView (+auth []/throttles), + EuAPIView, + SairAPIView
contas/api/urls.py           # + auth/eu/ (api-eu), auth/sair/ (api-sair)
imoveis/api/serializers.py   # + ImovelAcervoSerializer
imoveis/api/views.py         # ImovelViewSet: get_serializer_class/get_queryset/pagination_class; + PaginacaoAcervo
contas/tests.py, imoveis/tests.py, README.md   # testes e linhas de rota
```

**App (`lib/`)**
```
data/datasources/  armazenamento_token.dart (interface) + armazenamento_token_seguro.dart
                   autenticacao_datasource.dart + autenticacao_remote_datasource.dart
                   acervo_datasource.dart + acervo_remote_datasource.dart
data/network/      interceptador_sessao.dart            # @injectable, usa ArmazenamentoToken
data/models/       imovel_acervo_model.dart, acervo_envelope_model.dart, eu_model.dart
data/repositories/ autenticacao_repository_impl.dart, acervo_repository_impl.dart
domain/entities/   papel.dart, situacao_imovel.dart, imovel_acervo.dart, pagina_acervo.dart, consulta_acervo.dart
domain/repositories/ autenticacao_repository.dart (+ exceções tipadas), acervo_repository.dart
domain/usecases/   entrar_usecase.dart, obter_papel_usecase.dart, sair_usecase.dart,
                   ler_sessao_usecase.dart, buscar_acervo_usecase.dart
presentation/sessao/  sessao_cubit/state, botao_sessao_topo.dart, entrada_area_screen.dart, aviso_area_screen.dart
presentation/login/   login_cubit/state/screen
presentation/acervo/  acervo_cubit/state/screen, widgets/cartao_imovel_acervo.dart, widgets/chips_situacao.dart
di/modulo_rede.dart   # + Dio @Named('autenticado'), FlutterSecureStorage
test/support/         armazenamento_token_em_memoria.dart; api_falsa.dart estendido (cabeçalhos + rotas)
tool/capturar_fixtures_api.py   # + grupo `acervo` (login com credenciais do SQLite temporário)
```

### Pattern 1: Rota do acervo — adaptar `ImovelViewSet.list` (web)

**What:** `list` passa a ser paginada, filtrada e enxuta; as demais ações do viewset não mudam.
**When to use:** só o app consome a lista (evidência abaixo).

**Evidência (Pergunta 1).** `grep` por `api/imoveis|imovel-list` em `.py/.html/.js/.md/.txt` (excluindo `venv` e `static/admin`) na `main`: ocorrências só em `imoveis/tests.py` e na linha `171` do `README.md` (`GET/POST /api/imoveis/ | Lista e cadastra imóveis da própria empresa | app, corretor`). Em `templates/`, `static/` e `site_publico/` **não há** nenhuma referência a `/api/`. O site e o painel do corretor usam as views Django (`ImovelListView`), não a API. Nas branches remotas `origin/feat/APP06`, `origin/WEB-12`, `origin/feat/corretor-situacao`, `origin/feat/web-08` e `origin/feat/APP05`, `git grep` acha só o README. Usos de `reverse("imovel-list")` em testes: GET em `imoveis/tests.py:360` (gestor → 403), `:366` (lista da empresa), `:1248` (só confere status 200 no teste de que a API autenticada não é limitada); POSTs em `:377` e `:386`. Conclusão: **só o app (esta fase) vai consumir a lista**; regra do CONTEXT → adaptar `list`.

**Mudanças necessárias nos testes/README:** `test_lista_apenas_da_propria_empresa` (`imoveis/tests.py:363`) passa a ler `response.data["results"]`; README linha 171 atualizada; o `:1248` continua válido (200).

```python
# Source: leitura de imoveis/api/views.py (ImovelViewSet, linhas 67-71), imoveis/forms.py (FiltroImovelForm,
# linhas 182-259) e core/mixins.py; padrão de PaginacaoVitrine em imoveis/api/views.py:333-334.
class PaginacaoAcervo(PageNumberPagination):
    page_size = IMOVEIS_POR_PAGINA        # 20, mesma das vitrines; sem page_size_query_param


class ImovelViewSet(EmpresaScopedQuerySetMixin, viewsets.ModelViewSet):
    serializer_class = ImovelSerializer
    permission_classes = [EhCorretor]
    queryset = IMOVEL_COM_DETALHES
    pagination_class = PaginacaoAcervo     # só `list` pagina; as @action não chamam o paginador

    def get_serializer_class(self):
        if self.action == "list":
            return ImovelAcervoSerializer
        return super().get_serializer_class()   # situacao usa MudancaSituacaoSerializer via @action

    def get_queryset(self):
        queryset = super().get_queryset()        # mixin: .filter(empresa=request.user.empresa)  (AC-5)
        if self.action != "list":
            return queryset
        filtro = FiltroImovelForm(
            self.request.query_params or None,
            empresa=self.request.user.empresa,
            campos=["busca", "situacao"],
        )
        queryset = filtro.filtrar(queryset.select_related(None)).annotate(
            na_vitrine=Exists(Imovel.objects.na_vitrine().filter(pk=OuterRef("pk")))
        )
        return queryset.order_by("-criado_em", "-pk")   # desempate estável para paginar
```

### Pattern 2: Lista enxuta — 10 campos (Pergunta 2)

Campos propostos (congelar no §14): `id`, `codigo`, `titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `foto_capa`, `situacao`, `meu_imovel`, `na_vitrine`.

- **Compatibilidade com o cartão público no app** [VERIFIED: lib/data/models/imovel_model.dart]: o `ImovelModel` público declara `id`, `titulo`, `finalidade`, `precoVenda`(`preco_venda`), `precoAluguel`(`preco_aluguel`), `bairro`, `fotoCapa`(`foto_capa`), `natureza`, `quartos`, `suites`, `vagas`, `area`; `paraEntidade()` monta o `Imovel` com `bairro: bairro ?? ''`, `natureza: _mapearNatureza(natureza)` (nulo vira `null`) e `fotoCapa: urlHttpOuNula(fotoCapa)`. Logo os 6 campos compartilhados (`id`, `titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `foto_capa`) bastam para montar um `Imovel` e reutilizar `linhasDePreco(Imovel)` e `abrirDetalheImovel(context, Imovel previa)`. Preços chegam como **string decimal** do DRF (`DecimalField`), igual ao cartão público.
- **Booleanos sem N+1.**
  - `meu_imovel`: `SerializerMethodField` comparando `imovel.corretor_responsavel_id == request.user.pk` (FK já carregada; zero consultas). Mesma lógica de `Imovel.pode_mudar_situacao` (`usuario.pk == self.corretor_responsavel_id`, `imoveis/models.py:212`).
  - `na_vitrine`: `annotate(na_vitrine=Exists(Imovel.objects.na_vitrine().filter(pk=OuterRef("pk"))))`. **Verificado** gerando o SQL no shell: `EXISTS(SELECT 1 ... INNER JOIN "empresas_empresa" U1 ... WHERE (U1."ativa" AND U0."publicado" AND U0."situacao" = DISPONIVEL AND U0."id" = ("imoveis_imovel"."id")) LIMIT 1) AS "na_vitrine"`. Reaproveita a regra única (`ImovelQuerySet.na_vitrine`, `imoveis/models.py:15-19`) em vez de copiar `publicado and situacao==...`; se a regra mudar, o acervo acompanha.
  - `foto_capa`: reutilizar a lógica de `ImovelVitrineSerializer.get_foto_capa` (`imoveis/api/serializers.py:549`: capa marcada, senão a primeira; URL absoluta por `request.build_absolute_uri`). O `IMOVEL_COM_DETALHES` já tem `prefetch_related("fotos")` (ordenado por `["ordem", "id"]`), então são 3 consultas fixas (contagem, página, fotos) mais autenticação, independentes de N. Extrair o método num mixin pequeno compartilhado pelos dois serializers.
- `select_related(None)` na lista descarta os `JOIN`s de natureza/endereço (desnecessários no cartão) sem mexer no `queryset` usado por `retrieve`.
- `situacao` vai como o código do enum; o app mapeia código → rótulo ("Disponível"...) com `switch` exaustivo (valor desconhecido → sem chip, nunca quebra).

```python
class ImovelAcervoSerializer(FotoCapaMixin, serializers.ModelSerializer):
    foto_capa = serializers.SerializerMethodField()
    meu_imovel = serializers.SerializerMethodField()
    na_vitrine = serializers.BooleanField(read_only=True)   # anotação do get_queryset

    class Meta:
        model = Imovel
        fields = [
            "id", "codigo", "titulo", "finalidade", "preco_venda", "preco_aluguel",
            "foto_capa", "situacao", "meu_imovel", "na_vitrine",
        ]

    def get_meu_imovel(self, imovel):
        return imovel.corretor_responsavel_id == self.context["request"].user.pk
```

### Pattern 3: Busca + situação reaproveitando `FiltroImovelForm` (Pergunta 3)

`ImovelListView` usa `FiltroImovelMixin.get_filtro()`: `FiltroImovelForm(self.request.GET or None, empresa=self.request.user.empresa, campos=self.campos_de_filtro)` e `filtrar(queryset)` (`imoveis/views.py:50-72`); a view do painel passa `["busca", "natureza", "finalidade", "situacao", "vitrine"]`, a do acervo passa `["busca", "situacao"]`. Assinatura: `def __init__(self, *args, empresa, campos, **kwargs):` (`imoveis/forms.py:219`).

**Comportamento medido** (shell Django com SQLite em memória, `empresa=None`, `campos=["busca","situacao"]`):

| Entrada | `is_bound` / `is_valid()` | Efeito de `filtrar()` |
|---------|--------------------------|-----------------------|
| `{"busca":"DEV","situacao":"RESERVADO"}` | válido | SQL com `codigo LIKE %DEV% OR titulo LIKE %DEV%` **e** `situacao = RESERVADO` (AND) |
| `{"busca":"DEV","situacao":"XXX"}` | **inválido** (`situacao: Faça uma escolha válida...`) | **nenhum filtro** (devolve o queryset inteiro, inclusive sem a busca) |
| `{}` | bound, válido | nenhum filtro |
| `None` (`query_params` vazio) | não bound, `is_valid()` False | nenhum filtro |

Como `query_params` com só `?page=2` é não vazio e tem campos desconhecidos, o formulário fica bound e válido, sem filtro: correto. `busca` é `icontains` (acento-sensível no Postgres; já é risco aceito no §8 do contrato). `corretor`/`natureza`/`finalidade`/`vitrine` são removidos do formulário pelos `campos`, então `?corretor=<id>` ou `?empresa=<id>` na URL são **ignorados** (útil para o teste de AC-5).

### Pattern 4: "Quem sou eu" e Sair (Perguntas 4 e 6)

- Caminhos no padrão de `contas/api/urls.py:11` (`path("auth/login/", LoginAPIView.as_view(), name="api-login"),`): `path("auth/eu/", EuAPIView.as_view(), name="api-eu")` e `path("auth/sair/", SairAPIView.as_view(), name="api-sair")`.
- **Payload mínimo de `eu`:** `{"perfil": "CORRETOR"}` (valores `ADMINISTRADOR`/`GESTOR`/`CORRETOR`). Nenhuma tela da fase usa nome nem empresa; acrescentar `nome` depois não quebra o app (chaves extras são ignoradas). `UsuarioSerializer` existente traz `empresa`, `email`, `is_active`: **não** reutilizar.
- `authentication_classes = [TokenAuthentication]` nas duas (rotas só do app; sem CSRF/sessão) e `IsAuthenticated` (padrão de `DEFAULT_PERMISSION_CLASSES`). Administrador e gestor passam em `eu` (não exigem `EhCorretor`).
- **Sair:** `Token.objects.filter(user=request.user).delete()` e `204`. Não usar `request.auth.delete()` (com sessão `request.auth` é `None`). Idempotente; token já inválido volta 401 antes da view e o app trata como sucesso.

```python
class EuAPIView(APIView):
    authentication_classes = [TokenAuthentication]
    def get(self, request):
        return Response({"perfil": request.user.perfil})

class SairAPIView(APIView):
    authentication_classes = [TokenAuthentication]
    def post(self, request):
        Token.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

**Token único compartilhado (pergunta 6).** `Token.key` é PK e `user = OneToOneField(... related_name='auth_token' ...)` (DRF 3.18.1, `rest_framework/authtoken/models.py`). Não existe `AbstractToken` (a classe `Token` só vira abstrata se `rest_framework.authtoken` **não** estiver em `INSTALLED_APPS`; aqui está, `config/settings.py:37`). Alternativa "token por aparelho" sem dependência nova: modelo próprio (cópia do `Token` com `ForeignKey`), migração, subclasse de `TokenAuthentication` com `get_model()`, mudar o login para criar um token por aparelho e invalidar todos os tokens atuais. Não é barato; é exatamente a ideia deferida. **Conclusão: manter como consequência aceita** e registrar no §14 e no UAT. Efeito colateral útil: Sair + novo login gera chave nova (`get_or_create` recria), então Sair também rotaciona a credencial.

### Pattern 5: Limite de tentativas no login (Pergunta 5)

**Escopo: dois baldes**, ambos contando toda tentativa (sucesso ou falha, porque o `SimpleRateThrottle` anota cada pedido permitido) e rodando **antes** do `authenticate()` (o DRF checa throttles em `initial()`), então a resposta é idêntica para e-mail existente e inexistente: não revela existência (AC-3).

- `ThrottleLoginPorEmail` (`scope = "login_email"`): chave = SHA-256 do e-mail normalizado (`strip().lower()`); sem e-mail no corpo (`None`) → sem limite (o 400 de validação cuida). Hash evita guardar e-mail em chave de cache.
- `ThrottleLoginPorIp` (`scope = "login_ip"`): `get_ident(request)` (respeita `NUM_PROXIES`, já tratado em `settings.py`; `X-Forwarded-For` forjado é ignorado com `NUM_PROXIES=0`, teste existente `test_x_forwarded_for_forjado_nao_reinicia_a_contagem`).
- **Taxas recomendadas** (decisão de produto, [ASSUMED] A1): `LOGIN_TAXA_POR_EMAIL=10/hour`, `LOGIN_TAXA_POR_IP=30/hour`, em `DEFAULT_THROTTLE_RATES`, com a mesma validação por regex de `VITRINE_TAXA_ANONIMA` (`config/settings.py`, `re.fullmatch(r'[0-9]+/[smhd][a-z]*', ...)`). 30/hora por IP acomoda um escritório atrás de NAT (vários corretores logando de manhã); o balde por e-mail é o que freia força bruta. O DRF só lê o primeiro caractere do período (`parse_rate`), então não há "15 min".
- **429 e `Retry-After`** [VERIFIED: rest_framework/views.py:91-92] `if getattr(exc, 'wait', None): headers['Retry-After'] = '%d' % exc.wait` — segundos inteiros. Com `Retry-After` de vários throttles que falham, o DRF usa o maior. Tentativas durante o bloqueio **não** estendem o histórico (só pedidos permitidos são anotados).
- `LoginAPIView`: `authentication_classes = []` (um token velho no cabeçalho não derruba o login) e `throttle_classes = [ThrottleLoginPorEmail, ThrottleLoginPorIp]`. Padrão de teste existente (`VitrineLimiteDeTaxaTests`, `imoveis/tests.py:1182-1199`): `cache.clear()` no `setUp`, `mock.patch.object(Classe, "rate", "2/min", create=True)`, depois `assertEqual(status, 429)`, `assertIn("Retry-After", response)`, `assertIn("detail", response.data)`; teste de que a taxa vem do settings via `Classe().get_rate()` e de que a view tem as classes (`assertEqual(View.throttle_classes, [...])`).
- Risco aceito (registrar no §14): travar o login de uma vítima por e-mail (negação de serviço dirigida) e IP compartilhado (CGNAT); `LocMemCache` é por processo (item de deploy, já listado no §8 do contrato).

```python
class ThrottleLoginPorEmail(SimpleRateThrottle):
    scope = "login_email"
    def get_cache_key(self, request, view):
        dados = request.data if hasattr(request.data, "get") else {}
        email = str(dados.get("email") or "").strip().lower()
        if not email:
            return None
        return self.cache_format % {"scope": self.scope, "ident": hashlib.sha256(email.encode()).hexdigest()}

class ThrottleLoginPorIp(SimpleRateThrottle):
    scope = "login_ip"
    def get_cache_key(self, request, view):
        return self.cache_format % {"scope": self.scope, "ident": self.get_ident(request)}
```

### Pattern 6: Token e `Dio` no app (Pergunta 7)

**Recomendação: segundo `Dio` nomeado + interceptor.** O `Dio` público de `lib/di/modulo_rede.dart` (`BaseOptions(baseUrl: urlBaseApi, connectTimeout: 10 s, receiveTimeout: 10 s, responseType: ResponseType.json)`, `@lazySingleton`) **não muda**. O módulo ganha:

```dart
// Source: lib/di/modulo_rede.dart (BaseOptions existente); injectable 3.0.0 README (@Named em método de módulo e em parâmetro).
@Named('autenticado')
@lazySingleton
Dio dioAutenticado(InterceptadorSessao interceptador) => Dio(
  BaseOptions(
    baseUrl: urlBaseApi,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    responseType: ResponseType.json,
    followRedirects: false,            // credencial nunca segue redirecionamento
  ),
)..interceptors.add(interceptador);
```

`InterceptadorSessao` (`@injectable`, recebe `ArmazenamentoToken`):

```dart
// Source: dio-5.11.1 lib/src/interceptor.dart (InterceptorsWrapper, RequestInterceptorHandler.next,
// ErrorInterceptorHandler.reject) e DioException.copyWith (dio_exception.dart:242).
Future<void> aoEnviar(RequestOptions opcoes, RequestInterceptorHandler h) async {
  final base = Uri.parse(opcoes.baseUrl);
  final destino = opcoes.uri;
  final mesmaOrigem = destino.scheme == base.scheme && destino.host == base.host && destino.port == base.port;
  final token = mesmaOrigem ? await _armazenamento.ler() : null;
  if (token != null) {
    opcoes.headers['Authorization'] = 'Token $token';
    opcoes.extra['token_usado'] = token;           // compare-and-delete no 401
  }
  h.next(opcoes);
}

Future<void> aoErro(DioException erro, ErrorInterceptorHandler h) async {
  if (erro.response?.statusCode == 401) {
    final usado = erro.requestOptions.extra['token_usado'];
    if (usado != null && usado == await _armazenamento.ler()) await _armazenamento.apagar();
    return h.reject(erro.copyWith(error: const SessaoExpiradaException()));
  }
  h.next(erro);
}
```

- **401 centralizado:** o repositório autenticado traduz `erro.error is SessaoExpiradaException` → `Result.failure(const SessaoExpiradaException())` (mesma cadeia de `PerfilRepositoryImpl._executar`: exceção de domínio primeiro, depois `DioException`, depois `TypeError`→`FormatException`, depois `Exception`). Cubits decidem só pelo tipo.
- **Por que `token_usado`:** uma resposta 401 de um pedido antigo, chegando depois de um novo login, apagaria o token **novo**. A comparação evita isso.
- **Nunca logar o token:** hoje não há `LogInterceptor` nem `print` em `lib/` (`grep` limpo); manter assim e não registrar `LogInterceptor` no Dio autenticado.
- **`next` com credencial:** `AcervoRemoteDataSource.seguir(proximaPagina)` precisa da mesma guarda `_exigirMesmaOrigem` (existe duplicada em `imovel_remote_datasource.dart:53` e `vitrine_anunciante_remote_datasource.dart:50`). Esta é a terceira cópia; recomendo extrair para uma função pura compartilhada (decisão 07.1-01 foi copiar para não mexer em código estável; com a terceira cópia o custo de extrair é menor que o de manter três).
- **Login e Sair usam clientes diferentes:** login no `Dio` público (token velho nunca viaja; teste: pedido do login **sem** `Authorization`); `eu`, `sair`, `acervo` no `Dio` autenticado.

### Pattern 7: Sessão guardada (Pergunta 8)

Interface própria em `data/` (como `CidadePrefsDataSource`), com impl segura e fake de teste:

```dart
abstract class ArmazenamentoToken {
  Future<String?> ler();
  Future<void> salvar(String token);
  Future<void> apagar();
}
// impl: usa FlutterSecureStorage com chave fixa; ler() captura PlatformException e devolve null
// (falha de decifragem = sem sessão, fail-closed), nunca propaga para a UI.
```

- Módulo de DI: `@lazySingleton FlutterSecureStorage get armazenamentoSeguro => const FlutterSecureStorage();` (`const` construtor existe, `lib/flutter_secure_storage.dart:41`; `AndroidOptions()` padrão = RSA-OAEP + AES-GCM). `WidgetsFlutterBinding.ensureInitialized()` já roda em `main()` antes de `configureDependencies()`.
- **Teste:** `FlutterSecureStorage.setMockInitialValues(Map<String,String>)` existe [VERIFIED: pacote 11.2.0 baixado e lido, `lib/flutter_secure_storage.dart:428-433`, `@visibleForTesting static void setMockInitialValues(Map<String, String> values)` que troca `FlutterSecureStoragePlatform.instance` por `TestFlutterSecureStoragePlatform(values)` em memória]. Uso: um teste da impl segura (`ler/salvar/apagar` com o mock); **todos os demais** (cubits, e2e com `ApiFalsa`, `main_launch_routing_test`) usam `ArmazenamentoTokenEmMemoria` (em `test/support/`) registrado no `getIt`, para nunca chegar ao canal de plataforma.
- **Configuração nativa (Pergunta 8):**
  - Android: **nada** em `minSdk`/`compileSdk`. Flutter 3.47.9: `FlutterExtension.kt:26 val minSdkVersion: Int = 24` e `:23 val compileSdkVersion: Int = 36`; o app usa `minSdk = flutter.minSdkVersion` e `compileSdk = 36`; o 11.0.0 subiu minSdk para 24 e compileSdk para 37, e o **11.1.0 voltou a usar `flutter.compileSdkVersion`** [CITED: changelog do pacote] (11.2.0 é posterior). **Mudança necessária:** `android:allowBackup="false"` em `android/app/src/main/AndroidManifest.xml` (`<application ...>` hoje sem o atributo) [CITED: README do pacote 11.2.0, "Disabling Auto Backup": "By default Android backups data on Google Drive. It can cause exception `java.security.InvalidKeyException: Failed to unwrap key`"]. Efeito colateral: a cidade guardada em `SharedPreferences` deixa de ser restaurada por backup (irrelevante).
  - iOS: o projeto não tem `Podfile` (usa Swift Package Manager; o pacote tem a tag `is:swiftpm-plugin`) e `IPHONEOS_DEPLOYMENT_TARGET = 15.0` (≥ 12 exigido desde o 10.0.0). O README do pacote manda adicionar `keychain-access-groups` com `<array/>` em `ios/Runner/DebugProfile.entitlements` e `Release.entitlements` [CITED: README "macOS & iOS"]; `ios/Runner` **não tem** arquivo `.entitlements`. Criar os dois arquivos e apontar `CODE_SIGN_ENTITLEMENTS` no `project.pbxproj` só pode ser validado num Mac: planejar como tarefa com `checkpoint:human-verify` (dev em Mac M1). [ASSUMED] A3: os passos exatos no `pbxproj` e se o simulador exige o entitlement.
  - macOS/Windows/Linux/Web: não aplicável (não há pastas dessas plataformas; os pacotes federados entram no lock mas não compilam).

### Pattern 8: Abertura e sessão (Pergunta 9)

- **`SessaoCubit`** (`@lazySingleton`; estados freezed `verificando`, `anonima`, `autenticada`): no `create` do provider raiz chama `carregar()` que lê o storage; **nada** em `main()`/`_TelaInicial` espera isso, então a vitrine abre no mesmo tempo de hoje (AC-6). Enquanto `verificando` o botão ocupa o espaço (placeholder `SizedBox` de 48 dp) para não piscar "Entrar" para quem tem sessão.
- **Provider:** `BlocProvider.value(value: getIt<SessaoCubit>())` **acima** do `MaterialApp` em `ImoveisAquiApp`, para as rotas empurradas por `Navigator.push` (login, acervo) enxergarem o cubit.
- **Slot do botão (limita o estrago nos testes):** `CidadeSelecaoScreen` e `VitrineScreen` ganham `Widget? acaoSessao` (default `null` = sem botão), do mesmo modo que `VitrineScreen.aoAbrirImovel` existe "para que os testes de widget da vitrine não dependam do DI". `_TelaInicial` (entra direto) e `PrimingScreen._aoTocarUsarLocalizacao` (primeira abertura, que empurra a própria `CidadeSelecaoScreen`) passam `const BotaoSessaoTopo()`. No `VitrineScreen`, `SeletorCidadeTopo` (hoje filho direto da `Column`) vai para `Row(children: [Expanded(child: SeletorCidadeTopo(...)), if (acaoSessao != null) acaoSessao!])`. Testes afetados por essa mudança: `main_launch_routing_test.dart` (usa `ImoveisAquiApp`; precisa registrar um `SessaoCubit` falso no `getIt`) e, se navegarem até a vitrine pelo `PrimingScreen`, `priming_screen_test.dart`/`skeleton_flow_test.dart`; os testes que montam `CidadeSelecaoScreen`/`VitrineScreen` direto não mudam.
- **Navegação** (`Navigator.push` + `MaterialPageRoute`, sem go_router):
  - "Entrar": `Navigator.push(LoginScreen)`; no sucesso o `LoginCubit` emite o destino e a tela chama `Navigator.pushReplacement` para `AcervoScreen` ou `AvisoAreaScreen`, então "voltar" cai na vitrine (D-02).
  - "Meu acervo" (sessão guardada): `Navigator.push(EntradaAreaScreen)` que chama `GET eu` (estados carregando/erro com "Tentar de novo"/papel) e faz `pushReplacement` por papel; 401 → `SessaoCubit` vira `anonima` e `Navigator.pushAndRemoveUntil` para `LoginScreen(aviso: 'Sua sessão terminou. Entre de novo.')` mantendo a vitrine como base da pilha.
  - Sair (confirmação em `AlertDialog`): `SairUseCase` e `Navigator.popUntil((r) => r.isFirst)`; `SessaoCubit` → `anonima`.
- **Login: sequência recomendada.** `Entrar` (Dio público) → salvar token → `eu` (Dio autenticado). Se `eu` falhar por rede/5xx, **apagar o token salvo** (rollback) e mostrar "Não foi possível entrar agora. Tente de novo.", para a mensagem e o botão do topo ficarem coerentes. Se o papel for desconhecido, tratar como `FormatException` (mesma mensagem genérica) e apagar o token.
- **Campos de login:** não aplicar `trim` na senha (o servidor usa `trim_whitespace=False`, `contas/api/serializers.py`); e-mail pode ir sem `trim` (o `EmailField` do DRF já remove espaços). O app só barra vazio (`email.trim().isEmpty` ou `senha.isEmpty`). `AutofillGroup` com `AutofillHints.email`/`AutofillHints.password`, `obscureText`, `enableSuggestions: false`, `autocorrect: false`; chamar `TextInput.finishAutofillContext()` após sucesso [ASSUMED] A4 (API padrão do Flutter, não conferida nesta sessão).

### Pattern 9: Reuso no app (Pergunta 10) — nomes e assinaturas confirmados

| Item | Local e assinatura (lida nesta sessão) | Como usar |
|------|----------------------------------------|-----------|
| `Result<T>` | `lib/core/result.dart:9-13`: `sealed class Result<T>`; `const factory Result.loading() = Loading<T>;` `const factory Result.success(T data) = Success<T>;` `const factory Result.failure(Exception erro) = Failure<T>;` | Retorno dos repositórios; `switch` com `case Success(:final data)`/`Failure()`/`Loading()` como em `VitrineCubit` |
| Falhas tipadas | Padrão `class X implements Exception` em `domain/repositories/*_repository.dart` (`PerfilNaoEncontradoException` em `perfil_repository.dart:9`, `ImovelNaoEncontradoException` em `imovel_detalhe_repository.dart:7`); tradução em `PerfilRepositoryImpl._executar` | Novas: `CredenciaisInvalidasException`, `LimiteTentativasException({Duration? aguardar})`, `FalhaDeRedeException`/falha genérica, `SessaoExpiradaException`, `SemPermissaoException` (403) |
| `RodapePaginacaoLista` | `lib/presentation/perfis/widgets/rodape_paginacao_lista.dart:9`: `RodapePaginacaoLista({super.key, required carregandoMais, required erroAoCarregarMais, required temProximaPagina, required VoidCallback aoTentarDeNovo})` | Usar direto como último item da lista do acervo |
| Rolagem infinita | `vitrine_screen.dart`: listener a `posicao.pixels >= posicao.maxScrollExtent * 0.9` e `_agendarCarregarMaisSeNaoPreencheATela` (pede página extra se a primeira não enche a tela) | Copiar o padrão na `AcervoScreen` |
| `SliverImoveisDoAnunciante` | `sliver_imoveis_anunciante.dart` — acoplado a `VitrineAnuncianteCubit` e `ImovelCard` | **Não** reutilizável direto; só o padrão e o rodapé |
| Busca com atraso | `vitrine_cubit.dart:79` `if (termo.length < 2) return;` e `:81` `_debounce = Timer(const Duration(milliseconds: 400), () {`; campo vazio volta à lista completa na hora; `_versaoConsulta` descarta respostas obsoletas; `close()` cancela o `Timer` | Copiar para o `AcervoCubit` (D-08: "mesmo atraso"). Recomendo mínimo de **1** caractere no acervo (códigos são curtos); decisão do planejador |
| `ImagemRede` | `lib/presentation/comum/imagem_rede.dart`: `ImagemRede({super.key, required String? url, BoxFit fit = BoxFit.cover, Widget? imagemPadrao, Widget Function(String url)? construirImagemDeRede})`; `url == null`/carregando/erro → `ImagemPadraoImovel` | Miniatura quadrada do cartão (D-05); `construirImagemDeRede` é o gancho de teste |
| `linhasDePreco` | `apresentacao_imovel.dart:29` `List<String> linhasDePreco(Imovel imovel)` → `linhasDePrecoPorFinalidade({required FinalidadeImovel finalidade, String? precoVenda, String? precoAluguel})` (`:40`) | Chamar com `finalidade`/preços do item do acervo; "Preço sob consulta" quando vazio |
| `abrirDetalheImovel` | `detalhe_imovel_screen.dart:31`: `Future<void> abrirDetalheImovel(BuildContext context, Imovel previa, {DetalheImovelCubit Function()? criarCubit})`; `typedef AoAbrirImovel = Future<void> Function(BuildContext context, Imovel imovel)` (`:22`) | O `ImovelAcervo` expõe `paraPrevia()` → `Imovel` (bairro `''`, natureza/quartos nulos) |
| Envelope/modelo público | `ImoveisEnvelopeModel({String? next, String? previous, required List<ImovelModel> results})` e `PaginaImoveis{itens, proximaPagina}` são de `Imovel` | O acervo precisa de `AcervoEnvelopeModel`/`PaginaAcervo` próprios (itens `ImovelAcervo`); `urlHttpOuNula` obrigatório em `foto_capa` |
| `SearchBar`/chips | `SearchBar` na `vitrine_screen.dart` (`controller`, `hintText`, `trailing` com "Limpar busca") | Mesmo padrão; chips de escolha única com `ChoiceChip`/`SegmentedButton` (Material 3) |

### Pattern 10: Dados de UAT (Pergunta 11)

`semear_vitrine_dev` (`empresas/management/commands/semear_vitrine_dev.py`) exige `DEBUG=True`, cria a empresa `NOME_EMPRESA_DEMO = "Imobiliária Vitrine Demo (dev)"` com os corretores `corretor.vitrine.demo@example.com` e `corretor.inativo.vitrine.demo@example.com` (`_garantir_corretor` chama `corretor.set_unusable_password()`) e 36 imóveis (`IMOVEIS_POR_CIDADE = {"Campinas": 24, "Valinhos": 4, "Vinhedo": 4, "Indaiatuba": 4}`), todos publicados e `DISPONIVEL`, um deles (`DEV-CAMPINAS-14`, `INDICE_CORRETOR_INATIVO = 13`) do corretor desativado. **Não** cria gestor nem segunda empresa nem senhas conhecidas.

`seed_demo` (`core/management/commands/seed_demo.py`, sem guarda de `DEBUG`) cria a "Imobiliaria Demo" (CNPJ `74286058000180`) com `admin@imoveisaqui.com / TrocarSenha123`, `gestor@demo.com / SenhaForte123`, `corretor@demo.com / SenhaForte123` e **um** imóvel `DEMO-CASA-01` com contrato assinado (fica `VENDIDO` e fora da vitrine).

**Receita mais barata (sem código novo)** — as duas empresas coexistem sem conflito (CNPJs e e-mails distintos):
1. `manage.py migrate` e `manage.py seed_demo` (empresa B: corretor/gestor/admin com senha conhecida; um imóvel VENDIDO).
2. `DEBUG=True manage.py semear_vitrine_dev` (empresa A: 36 imóveis).
3. `manage.py shell -c "from contas.models import Usuario; u=Usuario.objects.get(email='corretor.vitrine.demo@example.com'); u.set_password('<senha de dev>'); u.save()"` (dá senha ao corretor da empresa A; a senha fica fora do repositório).

Cobertura de UAT que isso dá: corretor A vê 36 imóveis, com "Seu" em 35 e sem "Seu" em `DEV-CAMPINAS-14`; `busca=DEV-CAMPINAS-14` → "Apartamento no bairro Barão Geraldo"; corretor B (`corretor@demo.com`) vê só `DEMO-CASA-01` (chip Vendido, sem toque porque `na_vitrine` é falso) e **nunca** os `DEV-*` (AC-5); `gestor@demo.com` e `admin@imoveisaqui.com` caem na tela de aviso. Os chips Reservado/Alugado ficam vazios a menos que o UAT mude a situação: via shell com `imovel.mudar_situacao("RESERVADO", corretor_responsavel, "uat")` (só o responsável ou o gestor muda; imóvel com contrato assinado não muda à mão) ou por `POST /api/imoveis/<id>/situacao/`. Android: `runserver 0.0.0.0:8000` e `10.0.2.2` em `ALLOWED_HOSTS` (o `.env` do web existe; não foi lido, política de segredos).

### Pattern 11: Contrato §14 (Pergunta 12)

Lidos do `01-CONTRATO-API.md`: §4 (Paginação, envelope `{count,next,previous,results}`, `page_size = 20`, `next` URL absoluta, página fora do intervalo 404, app segue `next` só na mesma origem), "Erros 429" (status 429, `Retry-After` em segundos, corpo `{"detail": ...}`, `NUM_PROXIES`), §6 (allowlist exata por chave + deny-list), §7 (isolamento por queryset), §12 (fixtures capturadas da API real, procedimento com SQLite temporário, testes de contrato que travam chaves exatas), §13 (modelo: 13.1 perfis, 13.2 rotas, 13.3 resposta, 13.4 recorte e ordem, 13.5 404/vazio, 13.6 no app, 13.7 PENDENTE WEB, 13.8 sincronização).

**§14 deve conter (sugestão de subseções):**
- **14.1 Rotas e autenticação:** `Authorization: Token <chave>`; login/`eu`/`sair`/acervo; 401 sem token ou token inválido (`WWW-Authenticate: Token`); só as rotas públicas continuam sem token.
- **14.2 Login:** corpo `{email, password}`, 200 `{"token"}`, 400 (credencial inválida **ou** campo inválido, o app ignora o texto), 429 com `Retry-After`; `authentication_classes = []`; taxas e variáveis; não revela existência do e-mail.
- **14.3 Quem sou eu:** 200 `{"perfil"}` com os 3 valores; 401.
- **14.4 Sair:** 204, idempotente, 401 tratado como sucesso; **efeito nos outros aparelhos** (token único compartilhado; o site usa sessão e não é afetado; novo login gera chave nova).
- **14.5 Lista do acervo:** `GET /api/imoveis/` (`EhCorretor`), parâmetros `busca` e `situacao` (valores `DISPONIVEL|RESERVADO|VENDIDO|ALUGADO`), regra do `FiltroImovelForm` incluindo "um campo inválido anula todos os filtros", envelope do §4 com `page_size = 20`, ordem fixa `-criado_em, -pk`, as 10 chaves exatas do item, deny-list (`proprietario`, `corretor_responsavel`, `empresa`, `descricao`, `fotos`, `endereco`, `publicado`, `pode_publicar`, `pendencias_para_publicar`, `criado_em`...). Registrar a emenda ao D-13 (`finalidade`).
- **14.6 Erros:** tabela 400/401/403 (gestor/admin na lista)/404 (página fora do intervalo; imóvel de outra empresa pelo id)/429.
- **14.7 No app:** Dio público vs autenticado, 401 → falha tipada, `next` na mesma origem.
- **14.8 PENDENTE WEB e riscos aceitos:** token sem expiração; negação de serviço por e-mail; CGNAT; `LocMemCache`; acento na busca; mudança do formato de `GET /api/imoveis/` (lista agora paginada).
- **14.9 Sincronização/antidrift:** novo grupo `acervo` em `tool/capturar_fixtures_api.py` (o procedimento do §12 usa SQLite temporário e `semear_vitrine_dev`; para o grupo `acervo` acrescentar: `seed_demo`/definir a senha do corretor no SQLite descartável e passar as credenciais por variável de ambiente, nunca no repositório). Fixtures novas em `test/fixtures/api/`: `acervo_p1.json`, `acervo_p2.json`, `acervo_busca.json`, `acervo_situacao.json`, `eu_corretor.json`, `erro_400_login.json`, `erro_401.json`. O 200 do login traz uma chave de um banco descartável; o teste de contrato só trava o conjunto de chaves `{token}` (decisão do planejador se versiona ou não o arquivo). **Sem fixture de 429** (não é capturável de forma determinística); o `Retry-After` fica travado no Django (`assertIn("Retry-After", response)`) e por teste unitário no app com `Response` sintética. Copiar byte a byte para `contrato/*.example.json` e criar `test/data/contrato_acervo_test.dart` (compara exemplo × fixture e trava chaves exatas do envelope e do item); no Django `AcervoAllowlistExataTests` (igualdade exata de chaves + deny-list), no mesmo molde de `VitrineAllowlistExataTests`.

### Anti-Patterns to Avoid
- **Interceptor no `Dio` público decidindo por caminho:** uma rota nova esquecida vaza ou perde o token. Usar o `Dio` nomeado.
- **`try/catch` genérico em Cubit/Widget para 401/429:** a tradução é do repositório; presentation decide pelo tipo.
- **Decidir "Seu"/"na vitrine" no app** olhando ids, `publicado` ou `situacao` (D-06, D-07).
- **Mostrar a mensagem do servidor no login:** D-03 manda o texto fixo; ignorar o corpo do 400.
- **Guardar e-mail ou senha:** só o token vai para o storage.
- **`Widget buildX()`:** extrair classes (skill do projeto); `!` evitado; `const` sempre que possível.
- **Throttle por e-mail com a chave em texto puro:** usar hash.
- **Mexer em `retrieve`/`create`/`update`:** `get_serializer_class` só troca em `self.action == "list"`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Guardar segredo no aparelho | Criptografia/arquivo próprio | `flutter_secure_storage` (Keychain/Keystore) | D-D; cifra e chaveiro são da plataforma |
| Limite de tentativas | Contador próprio em tabela/memória | `rest_framework.throttling.SimpleRateThrottle` (subclasse) com `get_cache_key` | Janela deslizante, `Retry-After`, testável por `rate` (padrão já usado na vitrine) |
| Revogar token | Lista de revogação própria | `Token.objects.filter(user=...).delete()` | O DRF valida o token no banco a cada pedido; apagar já invalida |
| Filtro de busca/situação | Reimplementar `icontains`/enum | `FiltroImovelForm(campos=["busca","situacao"])` | Regra única com o painel do site (D-11) |
| "Na vitrine" no acervo | Copiar `publicado and situacao...` | `Exists(Imovel.objects.na_vitrine().filter(pk=OuterRef("pk")))` | Regra única `ImovelQuerySet.na_vitrine` |
| Paginação | Cursor/offset manual | `PageNumberPagination` | Mesmo envelope e `next` absoluto da APP-05 |
| Retry-After → minutos | Parser de datas HTTP | `int.tryParse(headers.value('retry-after'))` com fallback para a mensagem sem N | O DRF manda inteiro (`'%d' % exc.wait`) |
| Debounce | `easy_debounce` | `Timer` de 400 ms como `VitrineCubit` | Regra do CLAUDE.md |
| Mock do secure storage nos testes | Mock de `MethodChannel` | `FlutterSecureStorage.setMockInitialValues` / fake em memória atrás da interface | API própria do pacote |

**Key insight:** o servidor já tem tudo que importa (mixin de empresa, formulário de filtro, `na_vitrine()`, throttles com testes); esta fase é montagem + contrato + um cliente que nunca decide regra.

## Runtime State Inventory

> Fase de funcionalidade nova, não é rename/refactor/migração. Omitido (nenhuma string é renomeada). Observação operacional única: o `Token` do DRF é estado de runtime que o **Sair** passa a apagar; tokens já emitidos pelo login atual continuam válidos até alguém sair (sem expiração).

## Common Pitfalls

### Pitfall 1: Token velho derruba o login (401)
**What goes wrong:** `Authorization: Token <revogado>` no `POST /api/auth/login/` volta 401 antes da view.
**Why it happens:** o DRF autentica em `initial()` mesmo com `AllowAny`; `LoginAPIView` hoje usa as `authentication_classes` padrão.
**How to avoid:** `authentication_classes = []` no login; login pelo `Dio` público; teste do app que afirma pedido de login sem `Authorization` e teste do Django com token inválido no cabeçalho dando 200/400, nunca 401.
**Warning signs:** corretor que "não consegue entrar depois de ter saído em outro aparelho".

### Pitfall 2: 401 de resposta antiga apaga o token novo
**What goes wrong:** pedido em voo com o token A responde 401 depois do novo login (token B) e o interceptor apaga B.
**How to avoid:** guardar `token_usado` em `RequestOptions.extra` e só apagar se ainda for o token atual (compare-and-delete); teste com duas respostas fora de ordem.

### Pitfall 3: Credencial vaza por `next`/redirecionamento
**What goes wrong:** `next` com host diferente (ou 3xx) leva o `Authorization` para outra origem.
**How to avoid:** guarda de mesma origem no data source **e** no interceptor; `followRedirects: false` no `Dio` autenticado; teste com `next` de outra origem (nenhum pedido sai).

### Pitfall 4: Filtro inválido anula a busca
**What goes wrong:** `situacao` inválida desliga `busca` também (formulário único).
**How to avoid:** o app só envia os 4 enums; teste no Django do caso `busca` válida + `situacao` inválida (documentar no §14); não "consertar" o formulário compartilhado nesta fase.

### Pitfall 5: Paginação instável
**What goes wrong:** `Imovel.Meta.ordering = ["-criado_em"]` empata em seeds/importações e repete/pula itens entre páginas.
**How to avoid:** `order_by("-criado_em", "-pk")` (mesma ordem fixa do §13.4); o app descarta ids repetidos ao anexar (padrão existente).

### Pitfall 6: N+1 no cartão
**What goes wrong:** `fotos` e `empresa` por item.
**How to avoid:** `prefetch_related("fotos")` (já no `IMOVEL_COM_DETALHES`), `na_vitrine` por `Exists` (uma consulta), `meu_imovel` por `corretor_responsavel_id`; teste com `assertNumQueries` comparando 3 imóveis × 25 imóveis (mesmo número de consultas).

### Pitfall 7: Backup do Android corrompe o Keystore
**What goes wrong:** `Failed to unwrap key` ao restaurar backup; o app não lê o token.
**How to avoid:** `android:allowBackup="false"`; `ler()` captura `PlatformException` → `null` (sessão tratada como ausente). Antes dessa mudança o manifest não declarava o atributo (padrão = backup ligado).

### Pitfall 8: Entitlement do Keychain no iOS
**What goes wrong:** gravação silenciosa que não persiste ou erro de Keychain.
**How to avoid:** criar os `.entitlements` conforme o README do pacote e conferir num Mac (checkpoint humano). Não há como verificar no Windows.

### Pitfall 9: Throttle polui outros testes
**What goes wrong:** `LocMemCache` persiste entre testes do mesmo processo; testes de login em volume batem em 429.
**How to avoid:** `cache.clear()` no `setUp` dos testes de login e taxa alta fixa por padrão nos demais (molde `fixar_taxa_alta` em `imoveis/tests.py:59`).

### Pitfall 10: Gerados com CRLF
**What goes wrong:** `build_runner` reescreve `*.freezed.dart`/`*.g.dart`/`injection.config.dart` só com CRLF e polui o diff.
**How to avoid:** D-18: `git checkout --` nos que mudaram só de quebra de linha.

### Pitfall 11: `SessaoCubit` fora da árvore em testes antigos
**What goes wrong:** `context.watch<SessaoCubit>()` sem provider quebra testes de `CidadeSelecaoScreen`/`VitrineScreen`.
**How to avoid:** slot opcional `acaoSessao` (default `null`), provider raiz só em `ImoveisAquiApp`; registrar fake no `getIt` em `main_launch_routing_test.dart`.

### Pitfall 12: Mensagem de espera de até 60 minutos
**What goes wrong:** com taxa por hora, `Retry-After` chega a 3600 s e o texto diz "60 minutos".
**How to avoid:** é o esperado de D-04 com `10/hour`; tratar singular ("1 minuto") e valores grandes; confirmar a taxa (A1).

## Code Examples

### Retry-After → texto (data parseia, presentation formata)
```dart
// Source: rest_framework/views.py:91-92 (Retry-After = '%d' % exc.wait); dio-5.11.1 Headers.value (headers.dart:54)
Duration? esperaDoLimite(DioException erro) {
  final bruto = erro.response?.headers.value('retry-after');
  final segundos = bruto == null ? null : int.tryParse(bruto.trim());
  return (segundos == null || segundos < 0) ? null : Duration(seconds: segundos);
}

String textoLimiteDeTentativas(Duration? espera) {
  if (espera == null) return 'Tente de novo em alguns minutos.';
  final minutos = (espera.inSeconds / 60).ceil().clamp(1, 1 << 30);
  return 'Muitas tentativas. Tente de novo em $minutos ${minutos == 1 ? 'minuto' : 'minutos'}.';
}
```

### Sair: servidor como melhor esforço, aparelho sempre
```dart
// Source: desenho do CONTEXT (Sessão e Sair); Result de lib/core/result.dart
Future<Result<void>> sair() async {
  try {
    await _remoto.sair();            // 204; 401 também vale (já revogado)
  } on Exception {
    // melhor esforço: rede/5xx/401 não impedem a saída local
  } finally {
    await _armazenamento.apagar();   // sempre (AC-2)
  }
  return const Result.success(null);
}
```
(`on Exception` aqui é a camada de dados, não a UI; limitar o tempo do pedido de Sair, por exemplo `receiveTimeout` de 5 s via `Options`, para o botão não prender por 10 s [ASSUMED] A6.)

### Teste do Django: isolamento (AC-5), molde de `ImovelApiTests`
```python
# Source: padrão de imoveis/tests.py:344-373 (ImovelApiTests: outra_empresa, imovel_de_fora com codigo="FORA")
def test_busca_e_situacao_nao_vazam_imovel_de_outra_empresa(self):
    criar_imovel(self.empresa, self.corretor, self.proprietario, codigo="IM001")
    self.client.force_authenticate(self.corretor)
    for params in ({"busca": "FORA"}, {"situacao": "DISPONIVEL"}, {"empresa": self.outra_empresa.pk}):
        resposta = self.client.get(reverse("imovel-list"), params)
        codigos = [i["codigo"] for i in resposta.data["results"]]
        self.assertNotIn("FORA", codigos)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `flutter_secure_storage` 9.x com `encryptedSharedPreferences` | 10.x/11.x com cifras próprias (RSA-OAEP + AES-GCM), `AndroidOptions()` | 10.0.0 (deprecação), 11.0.0 (remoção) | Projeto novo: usar o padrão; não há dados antigos a migrar |
| minSdk 19/21/23 | minSdk 24 | 11.0.0 | Flutter 3.47.9 já usa 24; sem mudança |
| compileSdk fixo 37 no pacote | `flutter.compileSdkVersion` (36) | 11.1.0 | O `compileSdk = 36` fixado no app serve |
| `SharedPreferences.getInstance()` | `SharedPreferencesAsync` | CLAUDE.md | Cidade já usa; token usa secure storage |

**Deprecated/outdated:** `encryptedSharedPreferences`, `KeyCipherAlgorithm.RSA_ECB_PKCS1Padding`, `StorageCipherAlgorithm.AES_CBC_PKCS7Padding`, `sharedPreferencesName` (removidos no 11.0.0) — não usar. [CITED: pub.dev changelog do pacote]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Taxas de login `10/hour` por e-mail e `30/hour` por IP são adequadas (decisão de produto, DRF só aceita períodos s/m/h/d) | Pattern 5 | Corretor legítimo bloqueado por até 60 min, ou força bruta pouco freada; ajustável por variável de ambiente |
| A2 | Nenhum colega tem consumidor não publicado de `GET /api/imoveis/` (lista), então mudar o formato é seguro | Pattern 1 | Quebra silenciosa do consumidor; mitigação: avisar a frente web no PR/README ou usar `@action acervo` |
| A3 | iOS exige `ios/Runner/*.entitlements` com `keychain-access-groups` vazio (README do pacote) e os passos exatos no `pbxproj` | Pattern 7 | Token não persiste no iOS; só verificável num Mac M1 |
| A4 | `TextInput.finishAutofillContext()` após o sucesso aciona o salvamento de senha do SO | Pattern 8 | Autofill sem oferta de salvar senha; cosmético |
| A5 | Papel desconhecido em `eu` deve virar falha genérica (não tela de aviso) | Pattern 8 | UX diferente para papel novo no futuro |
| A6 | Limitar o Sair a ~5 s de espera é suficiente | Code Examples | Revogação perdida em rede lenta (a saída local ocorre de qualquer jeito) |
| A7 | Mínimo de 1 caractere na busca do acervo (vs 2 da vitrine) é melhor para códigos | Pattern 9 | Mais requisições por tecla; o debounce de 400 ms mitiga |

## Open Questions

1. **Taxa do limite de tentativas (A1).**
   - What we know: DRF limita a períodos `s/m/h/d`; padrão da vitrine é 120/min por IP.
   - What's unclear: tolerância do produto a bloqueio de até 60 min.
   - Recommendation: `10/hour` por e-mail e `30/hour` por IP, configuráveis; confirmar com o Allysson no plano.
2. **Confirmar que a frente web aceita mudar `GET /api/imoveis/` (A2).**
   - What we know: nenhum consumidor encontrado.
   - What's unclear: trabalho em andamento de colegas.
   - Recommendation: seguir a regra do CONTEXT (adaptar `list`), avisar no PR da web; plano B barato é `@action(detail=False, url_path="acervo")` no mesmo viewset.
3. **Emenda ao D-13: incluir `finalidade` no item do acervo.**
   - Recommendation: incluir (10 chaves) e registrar no §14.
4. **Nomes dos booleanos (`meu_imovel`, `na_vitrine`).**
   - Recommendation: congelar estes dois no §14.
5. **iOS Keychain (A3):** exige uma passada num Mac (checkpoint humano no fim da fase).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Python + venv do web | Testes e shell do Django | ✓ | Python 3.11.9; Django 5.2.17; DRF 3.18.1 (`requirements.txt`/venv) | — |
| Flutter/Dart | App, testes, `build_runner` | ✓ | Flutter 3.47.9 / Dart 3.13.7 | — |
| `gsd-tools` (node) | Fluxo GSD | ✓ | node v24.19.0 | — |
| PostgreSQL | Não necessário (testes com `sqlite://:memory:`) | n/a | — | SQLite em memória |
| `adb`/emulador Android | UAT manual | não verificado (`adb` fora do PATH nesta sessão; README cita AVD `Medium_Phone_API_36.0`) | — | UAT no emulador do Android Studio |
| macOS + Xcode (iOS) | Verificar Keychain/entitlements | ✗ (host Windows) | — | Checkpoint humano num Mac M1 |
| Servidor Django local | UAT/captura de fixtures | sob demanda (`runserver 0.0.0.0:8000`) | — | SQLite temporário, como no §12 |

**Missing dependencies with no fallback:** nenhuma que bloqueie a execução.
**Missing dependencies with fallback:** verificação iOS (Mac), emulador Android (conferir fora desta sessão).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Django `manage.py test` (Django 5.2.17 + DRF 3.18.1, `APITestCase`) e `flutter_test` + `bloc_test ^10.0.0` + `mocktail ^1.0.5` |
| Config file | web: nenhum extra (`config/settings.py` troca o hasher só em `test`); app: `analysis_options.yaml` (`flutter_lints`) |
| Quick run command | Web: `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test contas imoveis.tests.ImovelApiTests --noinput` · App: `flutter test test/data test/presentation/<arquivo>_test.dart` |
| Full suite command | Web: `DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` (695 testes, ~18 s) · App: `flutter analyze lib` e `flutter test` (774 testes, ~1 min) — rodar à mão por onda (D-18) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AUTH-01 | Login devolve `{"token"}`; app salva e chama `eu` | unit (Django) + unit (datasource/cubit) | `manage.py test contas.tests.LoginApiTests` · `flutter test test/data/autenticacao_remote_datasource_test.dart` | Django ✅ (estender) / app ❌ Wave 0 |
| AUTH-02 | Sair: 204, token apagado no servidor; app apaga local mesmo com falha | unit (Django) + unit (use case) | `manage.py test contas.tests.SairApiTests` · `flutter test test/domain/sair_usecase_test.dart` | ❌ Wave 0 |
| AUTH-03 | 400 → texto fixo; 429 com `Retry-After` → minutos; rede/5xx → texto genérico; falhas tipadas distintas | unit + widget | `flutter test test/data/autenticacao_repository_impl_test.dart test/presentation/login_cubit_test.dart` | ❌ Wave 0 |
| AUTH-04 | Abertura lê token só para o rótulo; vitrine não espera; "Entrar"/"Meu acervo" | widget (`main_launch_routing_test` estendido) + cubit | `flutter test test/main_launch_routing_test.dart test/presentation/sessao_cubit_test.dart` | ✅ estender / ❌ cubit |
| AUTH-05 | Papel por `eu`: corretor→acervo, gestor/admin→aviso, 401→login com aviso | cubit/widget + unit (Django `EuApiTests`) | `flutter test test/presentation/entrada_area_cubit_test.dart` · `manage.py test contas.tests.EuApiTests` | ❌ Wave 0 |
| AUTH-06 | 429 por e-mail e por IP, `Retry-After`, sem diferença entre e-mail existente e inexistente; `authentication_classes == []` | unit (Django) | `manage.py test contas.tests.LoginLimiteDeTentativasTests` | ❌ Wave 0 |
| ACV-01 | Lista paginada (20), envelope, ordem `-criado_em,-pk`, 10 chaves, `meu_imovel`; app rola e pagina | unit (Django) + cubit + e2e `ApiFalsa` | `manage.py test imoveis.tests.AcervoApiTests` · `flutter test test/presentation/acervo_cubit_test.dart` | ❌ Wave 0 |
| ACV-02 | `busca` (código/título) e `situacao`, combinadas; inválido ignorado; debounce 400 ms | unit (Django) + cubit (`fake_async`) | idem | ❌ Wave 0 |
| ACV-03 | Isolamento: lista, busca, situação, params extras, id→404; gestor/admin 403; sem token 401 | unit (Django) | `manage.py test imoveis.tests.AcervoApiTests` | ❌ Wave 0 (estender `ImovelApiTests`) |
| ACV-04 | `na_vitrine` = `na_vitrine()`; cartão sem `onTap` quando falso | unit (Django) + widget | `flutter test test/presentation/cartao_imovel_acervo_test.dart` | ❌ Wave 0 |
| API-09 | Contrato §14 × fixtures; chaves exatas do item e do `eu` | contrato (Dart) + allowlist (Django) | `flutter test test/data/contrato_acervo_test.dart` · `manage.py test imoveis.tests.AcervoAllowlistExataTests` | ❌ Wave 0 |
| API-10 | Rotas web com testes, README atualizado, `assertNumQueries` constante | unit (Django) | `manage.py test contas imoveis` | ❌ Wave 0 |

Testes de segurança do app que a verificação deve exigir: `Authorization` presente **só** no `Dio` autenticado e **ausente** no login e na vitrine; `next` de outra origem não gera pedido; 401 apaga o token com compare-and-delete; token nunca em log (nenhum `LogInterceptor`/`print` em `lib/`).

### Sampling Rate
- **Per task commit:** o comando rápido do arquivo tocado (web: classe de teste; app: arquivo de teste) + `flutter analyze lib` se tocou `lib/`.
- **Per wave merge:** suíte completa dos dois repos (D-18; o gate do GSD pula Flutter).
- **Phase gate:** `manage.py test` 695+N verde, `flutter analyze lib` limpo, `flutter test` 774+N verde, UAT manual no emulador (receita de dados acima) e checkpoint iOS num Mac.

### Wave 0 Gaps
- [ ] `test/support/armazenamento_token_em_memoria.dart` — fake de `ArmazenamentoToken` (nenhum teste toca o canal de plataforma).
- [ ] `test/support/api_falsa.dart` — gravar cabeçalhos (`options.headers`), rotas `eu`/`acervo`/`login`/`sair` com fixtures novas e resposta 401 sem `Authorization`; `criarDioAutenticado(armazenamento)` com o `InterceptadorSessao` real.
- [ ] `tool/capturar_fixtures_api.py` — grupo `acervo` (credenciais por variável de ambiente, SQLite descartável) e fixtures `acervo_*.json`, `eu_corretor.json`, `erro_400_login.json`, `erro_401.json`.
- [ ] Web: `AcervoApiTests`, `AcervoAllowlistExataTests` (em `imoveis/tests.py`), `EuApiTests`, `SairApiTests`, `LoginLimiteDeTentativasTests` (em `contas/tests.py`); ajustar `test_lista_apenas_da_propria_empresa`.
- [ ] Teste helper para `SessaoCubit` falso (`MockCubit`) usado por `main_launch_routing_test.dart`.
- [ ] Framework install: `flutter pub add flutter_secure_storage` + `build_runner`.

## Security Domain

> `security_enforcement` está ligado (config.json: `security_asvs_level: 1`, `security_block_on: "high"`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | sim | `authenticate()` do Django; erro único; limite por e-mail e IP; `authentication_classes = []` no login |
| V3 Session Management | sim | Token DRF (sem expiração) revogado no Sair (`Token...delete()`); token em Keychain/Keystore; 401 limpa a sessão local |
| V4 Access Control | sim | `EhCorretor` + `EmpresaScopedQuerySetMixin` (isolamento multitenant); `eu`/`sair` só com token; gestor/admin 403 na lista |
| V5 Input Validation | sim | `FiltroImovelForm` (enum `ChoiceField`, `CharField`); DRF `LoginSerializer`; `urlHttpOuNula` em URLs; `next` só na mesma origem |
| V6 Cryptography | sim | Chave do token `secrets.token_hex(20)` (DRF); cifra do storage é do pacote/plataforma — nunca cifra própria |
| V7 Error Handling / Logging | sim | Texto fixo de erro; sem `LogInterceptor`; token nunca em log |
| V8 Data Protection | sim | `android:allowBackup="false"`; só o token é guardado (nunca senha); iOS Keychain |
| V9 Communications | sim | Cleartext só no manifest de debug; produção deve ser HTTPS (o `Authorization` trafega em texto no HTTP de dev) |
| V13 API | sim | Limite de taxa, 429 com `Retry-After`, paginação com `page_size` fixo, sem `page_size_query_param` |

### Known Threat Patterns for DRF Token + Flutter

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Força bruta / credential stuffing no login | Spoofing | Throttle por e-mail (hash) + por IP, 429 com `Retry-After` |
| Enumeração de e-mail (resposta ou tempo diferentes) | Information disclosure | Mensagem única do `LoginSerializer`; throttle antes do `authenticate`; Django equaliza o tempo (`UserModel().set_password(password)` quando o usuário não existe, `django/contrib/auth/backends.py:69`) |
| IDOR entre empresas (`/api/imoveis/<id>/`, `?busca=`, `?empresa=`) | Information disclosure | Queryset filtrado pelo mixin antes do formulário; testes de lista, busca, situação, params extras e id→404 |
| Token roubado do aparelho (backup, root) | Information disclosure | Keystore/Keychain, `allowBackup=false`; revogação no Sair; sem expiração é risco aceito (§14.8) |
| Token enviado a outra origem (`next` adulterado, redirecionamento) | Information disclosure | Guarda de mesma origem + `followRedirects: false` + anexar token só à origem da base URL |
| Token em log/crash report | Information disclosure | Sem `LogInterceptor`/`print`; token só no interceptor |
| Negação de serviço dirigida (bloquear e-mail alheio) | Denial of service | Risco aceito e documentado; taxa configurável |
| Rota de login derrubada por token velho | Denial of service | `authentication_classes = []` |
| CSRF em rotas de token | Tampering | `authentication_classes = [TokenAuthentication]` em `eu`/`sair` (sem sessão); `TokenAuthentication` não exige CSRF |
| Gestor/admin chegando à área do corretor | Elevation of privilege | `EhCorretor` no servidor (403) e roteamento por papel no app só para a UI |

## Sources

### Primary (HIGH confidence)
- Código lido nesta sessão, repo web `main@d9ddd8f`: `contas/api/{views,urls,serializers,urls_publico}.py`, `contas/models.py`, `core/{permissions,mixins,throttles}.py`, `imoveis/{models,forms,views,vitrine}.py`, `imoveis/api/{views,serializers,urls}.py`, `config/{settings,urls}.py`, `imoveis/tests.py` (trechos), `contas/tests.py` (trechos), `core/management/commands/seed_demo.py`, `empresas/management/commands/semear_vitrine_dev.py`, `README.md`, `CLAUDE.md`.
- Código lido, repo app `feat/APP08@7301fea`: `lib/di/{modulo_rede,injection}.dart`, `lib/core/result.dart`, `lib/main.dart`, `lib/presentation/{cidade_selecao,vitrine,perfis,comum,detalhe_imovel,priming}/*`, `lib/data/{models,datasources,repositories}/*`, `lib/domain/*`, `test/support/api_falsa.dart`, `test/main_launch_routing_test.dart`, `pubspec.yaml`/`pubspec.lock`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `.claude/CLAUDE.md`, `.claude/skills/flutter-frontend/skill`, `.planning/**` (CONTEXT, CARD, REQUIREMENTS, STATE, ROADMAP, 01-CONTRATO-API).
- DRF 3.18.1 no venv: `rest_framework/views.py` (Retry-After, `permission_denied`, `get_authenticate_header`), `throttling.py` (`parse_rate`, `allow_request`, `ScopedRateThrottle`, `get_ident`), `authentication.py`, `authtoken/models.py`; Django `contrib/auth/backends.py`.
- Dio 5.11.1 (cache local do pub): `interceptor.dart`, `dio_exception.dart`, `options.dart`, `headers.dart`.
- `flutter_secure_storage-11.2.0` (tarball oficial do pub.dev, lido): `lib/flutter_secure_storage.dart`, `lib/test/test_flutter_secure_storage_platform.dart`, `README.md`.
- pub.dev API/páginas: `https://pub.dev/api/packages/flutter_secure_storage`, `.../score`, `https://pub.dev/packages/flutter_secure_storage` e `/changelog`.
- Flutter SDK local 3.47.9: `packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`.
- injectable 3.0.0 README (cache local): `@Named` em construtor e em método de módulo.
- Experimentos rodados: suíte Django (695 OK), `flutter analyze lib`, `flutter test` (774), shell do Django (SQL do `Exists` e comportamento do `FiltroImovelForm`), `flutter pub add --dry-run`.

### Secondary (MEDIUM confidence)
- Resumos do WebFetch das páginas do pub.dev (conferidos contra o tarball e a API).

### Tertiary (LOW confidence)
- Nada além das entradas `[ASSUMED]` do Assumptions Log.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — versão, SDK e resolução conferidas no registro e por `pub add --dry-run`.
- Architecture: HIGH — padrões e nomes copiados de código lido; interceptor/`@Named` conferidos na fonte do Dio/injectable.
- Pitfalls: HIGH para web e Dio; MEDIUM para iOS/Keychain (A3) e taxas de login (A1).

**Research date:** 2026-11-20
**Valid until:** 2026-12-20 (30 dias; pacote `flutter_secure_storage` publica com frequência, reconferir a versão se o plano atrasar)
