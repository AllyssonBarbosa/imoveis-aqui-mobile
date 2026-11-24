# Imóveis Aqui — App (Vitrine)

## What This Is

O aplicativo Flutter do projeto "Imóveis Aqui", um marketplace de imóveis por cidade.
O app abre direto na vitrine da cidade do visitante — **sem login** — para que qualquer
pessoa navegue os imóveis à venda e para alugar. Esta é a fatia sob minha responsabilidade
na equipe: as tarefas **APP01, APP02 e APP03** (abertura/localização/escolha da cidade,
vitrine com lista/busca/ordenação, e filtros da vitrine). O app é "uma tela sobre os dados":
nenhuma regra de negócio é decidida no celular — tudo vem calculado e filtrado da API Django.

Este projeto entrega, além do app, **os endpoints públicos da API que o app consome**
(`GET /cidades`, `GET /imoveis?cidade=...&filtros`), criados no repositório da API
(`../imoveis-aqui/Web`, Django + DRF), coordenando com os colegas que evoluem o model de
Imóvel na frente web (a base do model já existe; falta a tipologia — ver Context).

## Core Value

A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com a
**busca e o filtro resolvidos no servidor** — o mesmo dado e a mesma regra do site, nunca
recalculados dentro do aparelho.

## Requirements

### Validated

- ✓ **APP10** — Caixa de contatos do corretor ("Meus contatos", pelo ícone no "Meu acervo"): lista paginada dos contatos recebidos (mais recentes primeiro, com imóvel, canal e data), número de sem retorno calculado no Django, filtros por imóvel e por período (seletor em pt-BR) resolvidos no servidor e retorno anotado com um toque (falei, visita agendada, sem resposta, descartado), gravado pela API; isolamento por empresa e corretor — Phase 10 (UAT 6/6 contra o Django real; CXA-01..06, API-13, API-14)
- ✓ **APP08** — Login do corretor no mesmo app (token da API em `flutter_secure_storage`), "Meu acervo" com os imóveis dele e da imobiliária, busca e filtro por situação resolvidos no servidor, isolamento por empresa, Sair que revoga o token; gestor e administrador veem um aviso — Phase 8
- ✓ **PERF-03** — Vitrine do anunciante (corretor e empresa) paginada e recortada no servidor, via `GET /api/publico/corretores/<id>/imoveis/` e `/api/publico/empresas/<id>/imoveis/` — Phase 07.1
- ✓ **PERF-04** — Perfis do corretor e da empresa vindos da API real (WEB 02) por DataSource trocável, sem mock em `lib/` — Phase 07.1
- ✓ **API-08** — Vitrine do anunciante escrita no §13 do contrato e entregue pelo Django, com allowlist e limite de taxa da API pública — Phase 07.1
- ✓ **PERF-01** — Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação — Phase 7 (UAT 5/5 na API real)
- ✓ **PERF-02** — Página do corretor com foto, CRECI, apresentação e contato — Phase 7
- ✓ **PERF-05** — Corretor desativado (404) mostra "Este corretor não está mais disponível", não uma tela quebrada — Phase 7
- ✓ **PERF-06** — Perfil do corretor a partir da página do imóvel e página da empresa a partir do perfil do corretor — Phase 7

### Active

<!-- Hipóteses até enviadas e validadas. As três tarefas atribuídas + os endpoints que as habilitam. -->

- [ ] **APP01** — Abertura do app com pedido de permissão de localização; autorizada, descobre e entra na cidade; recusada (caminho normal, não um beco), mostra lista de cidades atendidas para escolher; escolha guardada no aparelho e reusada; trocar de cidade num toque no topo. Lista de cidades pode começar fixa no app.
- [ ] **APP02** — Vitrine da cidade escolhida: lista de imóveis com foto de capa, título, preço, natureza, bairro e quartos; busca por texto; ordenação por preço, área ou mais recentes; carregamento paginado (scroll infinito). A lista de cidades passa a vir da API (substitui a fixa de APP01).
- [ ] **APP03** — Filtros da vitrine (finalidade venda/aluguel, natureza casa/apartamento/terreno/lote, faixa de preço, quartos, suítes, vagas, bairro, faixa de área, características), **aplicados no servidor** — a lista vem pronta da API.
- [ ] **API-CIDADES** — Endpoint público `GET /cidades` (sem token) na API, expondo as cidades atendidas para a vitrine (app e site).
- [ ] **API-IMOVEIS** — Endpoint público `GET /imoveis?cidade=...` com busca, ordenação e filtros server-side, retornando só imóveis publicados; sem dado interno (proprietário/documento). Depende do model de Imóvel (frente web, E2).
- [ ] **API-AUDIT** — Auditar o estado atual da API e documentar a lacuna entre o que existe e o que o app precisa (contrato dos endpoints, campos, paginação, filtros).

### Out of Scope

<!-- Fronteiras explícitas, com o porquê para não re-adicionar. -->

- Site público / painel web — outra frente, feita por outros colegas da equipe.
- Página de detalhe do imóvel (card 8), contato por WhatsApp (card 9), favoritos — entregas seguintes do app, não nas 3 tarefas atribuídas agora.
- Área logada do gestor/administrador, contratos e parcelas — milestones futuros (a área do corretor entrou na Phase 8).
- Caixa de contatos do gestor no app — fica para a APP-12 (área do gestor); na Phase 10 o app só oferece a caixa ao corretor, embora a API já atenda o gestor com o escopo da empresa.
- Model de Imóvel / endereço / fotos / quatro naturezas / loteamento / publicação — **dependência** minha, mas construídos na frente web pelos colegas (E2); eu apenas exponho o que for publicado via API pública.
- Infra de backend: PostgreSQL, Dockerização da API e volume de imagens — pertencem ao repositório e às decisões da API (colega), não ao app Flutter. O app persiste só a cidade escolhida localmente no aparelho.

## Context

- **Duas frentes, um banco só.** Web (Django + DRF + PostgreSQL) é dona da regra e do dado, e publica a API. O app é a tela. Repositórios irmãos: `imoveis-aqui/` (API, do colega) e `imovies-aqui-mobile/` (este, o app).
- **Estado atual da API** (repo `../imoveis-aqui/Web`, Django 5.2 + DRF): apps `localizacao` (model `Cidade` já existe), `core` (Endereco com bairro/cidade/lat/long, base multitenant `EmpresaOwnedModel` + `EmpresaScopedQuerySetMixin`), `empresas` (`Empresa`), `contas` (`Usuario` por e-mail, perfis admin/gestor/corretor, auth por Token), e `imoveis` — o model **`Imovel` JÁ existe** (codigo, titulo, `finalidade` VENDA/ALUGUEL/VENDA_E_ALUGUEL, preços venda/aluguel/condomínio/iptu, descricao, `caracteristicas` M2M, `endereco`, `publicado`, criado_em), com `Caracteristica`, `FotoImovel` (capa/ordem) e um `ImovelViewSet` autenticado empresa-scoped em `/api/imoveis/`. Rotas públicas prontas: `POST /api/auth/login/`, `GET /api/usuarios/`, `GET /api/publico/corretores/<id>/`, `GET /api/publico/empresas/<id>/`. **Ainda faltam:** os endpoints públicos `GET /api/publico/cidades/` e `GET /api/publico/imoveis/`, e a **tipologia** do imóvel (natureza casa/apto/terreno/lote, quartos, suítes, vagas, área) — dependência da frente web (E2). Auditoria detalhada em `phases/01-.../01-CONTEXT.md`.
- **Isolamento multitenant** é o critério de maior peso da avaliação: todo dado de acervo filtra pela empresa; trocar o ID na URL cai em 404. A API pública da vitrine não pede token e não devolve dado interno.
- **Perfil do desenvolvedor:** backend forte em Java (Spring Boot) e Python (FastAPI); mindset de tipagem forte, OO, inversão de controle e tratamento explícito de erro. Explicações podem usar analogias com Java/Python.

## Constraints

- **Tech stack (app):** Flutter (versão estável mais recente) + Dart. Multiplataforma (Windows e macOS M1). — Definido em `instruções.md`.
- **Arquitetura:** Clean Architecture adaptada ao Flutter, em camadas `data/` (Models com serialização, Repositories, Data Sources), `domain/` (UseCases puros, interfaces de Repository) e `presentation/` (Widgets limpos, Controllers/Cubits). Nenhum Widget faz lógica de negócio ou chamada de rede direta. — Não negociável.
- **Estado:** `Cubit` (flutter_bloc) ou `Provider`; imutabilidade estrita nos estados de tela.
- **Modelos de API:** todo JSON mapeado para Models imutáveis (`freezed` ou classes tipadas com `fromJson`/`toJson`); nunca `dynamic` onde a tipagem forte couber.
- **Erros de API:** padrão `Result`/`Either` ou `sealed classes`; estados explícitos `Loading` / `Success<T>` / `Failure(Exception)`. Sem `try/catch` genérico na UI.
- **UI:** Material 3 estritamente; `ColorScheme.fromSeed`; widgets nativos de `material.dart` (`Card`, `FilledButton`, `NavigationRail` em telas maiores); tipografia oficial (`Theme.of(context).textTheme`).
- **Paleta:** Verde e Branco.
- **Regra de negócio:** nada que "valha dinheiro" ou mude estado (preço/parcela/situação/filtro) é decidido no app — só no Django.
- **Idioma do código:** models, variáveis e comentários em português, seguindo o padrão do projeto.
- **Branches:** `feat/<número do card>` — ex.: `feat/APP01`.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Escopo = app (APP01–03) + os endpoints públicos que ele consome | O app não funciona de verdade sem `/cidades` e `/imoveis`; melhor entregar a fatia ponta a ponta | — Pending |
| Este projeto cria os endpoints na API (não só mocka) | Usuário optou por criar os endpoints reais, coordenando com a frente web | — Pending |
| `.planning/` mora no repo do app (`imovies-aqui-mobile`) | O trabalho principal é o app; API é repo irmão referenciado | — Pending |
| Cidade escolhida guardada localmente no aparelho | Vitrine sem login; sem conta e sem senha (card APP01) | — Pending |
| Filtro e busca server-side | Filtrar no celular exigiria baixar o acervo inteiro — não escala e gasta o dado do visitante (card APP03) | — Pending |
| Paleta Verde e Branco via `ColorScheme.fromSeed` | Decisão da equipe + diretriz Material 3 | — Pending |
| Vitrine do anunciante como endpoint próprio no Django (rotas aninhadas `corretores\|empresas/<id>/imoveis/`), no padrão da API pública da APP-05 | O app não recorta a vitrine; o servidor decide o que é do anunciante, com a mesma allowlist, paginação e limite de taxa | ✓ Good — Phase 07.1 (17 testes direcionados no web, UAT real no emulador) |
| Anunciante inexistente ou inativo responde 404 uniforme; ativo sem imóveis responde 200 vazio | Não vaza se o anunciante existe; o app mostra o aviso de indisponível | ✓ Good — Phase 07.1 (§13 do contrato) |
| `feat/APP07` recebeu a `main` por merge, não rebase | Preservar o histórico já enviado e resolver os 10 conflitos uma vez | ✓ Good — Phase 07.1 (merge 9c2252a) |
| Contato do anunciante só como texto selecionável, sem botão de ligar/WhatsApp/e-mail | Ações de contato e o registro do contato são da APP 06 / CON-01, com regra no servidor | ✓ Good — Phase 7 (UAT 2) |
| Rótulo neutro "Ver página do anunciante" no cartão da empresa | Vale para imobiliária e construtora sem o app decidir o tipo no texto | ✓ Good — Phase 7 (suposição A7 aprovada no UAT 5) |
| Token da API guardado em `flutter_secure_storage` (Keychain/Keystore), só nas rotas autenticadas | Login do corretor exige credencial no aparelho; a vitrine pública e o login nunca levam `Authorization` | ✓ Good — Phase 8 (UAT 7/7) |
| `GET /api/imoveis/` virou envelope paginado (`count`/`next`/`results`) filtrado no servidor | O acervo do corretor rola e filtra sem baixar tudo; o time da web precisa saber da mudança de formato | ✓ Good — Phase 8 |
| Limite de login 10/hour por e-mail e 30/hour por IP | Freia tentativa de senha sem travar o uso normal; taxas ajustáveis pelo `.env` | ✓ Good — Phase 8 (aceito no UAT 4) |
| Número de contatos sem retorno vem do Django por rota própria (`GET /api/contatos/resumo/`), pedido de novo após cada anotação; o app nunca soma nem subtrai | Regra que muda estado não é decidida no aparelho; o número ignora os filtros da lista | ✓ Good — Phase 10 (UAT 4: 25 → 24 vindo do servidor) |
| `ContatoViewSet` paginado (20 por página, `PageNumberPagination`) e `GET /api/contatos/imoveis/` para as opções do filtro, com a mesma regra de visibilidade do site | A caixa rola e filtra sem baixar tudo; o app não monta a lista de imóveis | ✓ Good — Phase 10 (§17 do contrato, 766 testes no web) |
| Anotação sem otimismo: o item só muda com o 200 do servidor; 404 recarrega lista e número; falha mostra texto fixo | O retorno é estado do servidor; o app não finge sucesso | ✓ Good — Phase 10 (UAT com Django parado e com contato apagado) |
| pt-BR do Material ligado no app inteiro (`flutter_localizations`, do SDK) | O seletor de período precisava estar em português; nenhum pacote de terceiros | ✓ Good — Phase 10 (UAT 3) |
| Colisão de numeração entre fases paralelas resolvida pela ordem de entrada na `main`: a APP-09 ficou com o §16 do contrato e com API-11/API-12; a APP-10 virou §17 e API-13/API-14 | Merge da `main` na `feat/APP10` (b9d36e9) sem reescrever o que já estava na `main`; os documentos da Fase 10 foram renumerados (51afe35) | ✓ Good — Phase 10 (re-verificação passed, 1743 testes no app e 776 no web) |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-24 after Phase 10*
