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
(`../imoveis-aqui/Web`, Django + DRF), coordenando com os colegas que constroem o model de
Imóvel na frente web.

## Core Value

A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com a
**busca e o filtro resolvidos no servidor** — o mesmo dado e a mesma regra do site, nunca
recalculados dentro do aparelho.

## Requirements

### Validated

(None yet — ship to validate)

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
- Áreas logadas do app (corretor / gestor), contratos e parcelas — milestones futuros, atrás de login.
- Model de Imóvel / endereço / fotos / quatro naturezas / loteamento / publicação — **dependência** minha, mas construídos na frente web pelos colegas (E2); eu apenas exponho o que for publicado via API pública.
- Infra de backend: PostgreSQL, Dockerização da API e volume de imagens — pertencem ao repositório e às decisões da API (colega), não ao app Flutter. O app persiste só a cidade escolhida localmente no aparelho.

## Context

- **Duas frentes, um banco só.** Web (Django + DRF + PostgreSQL) é dona da regra e do dado, e publica a API. O app é a tela. Repositórios irmãos: `imoveis-aqui/` (API, do colega) e `imovies-aqui-mobile/` (este, o app).
- **Estado atual da API** (repo `../imoveis-aqui/Web`, Django 5.2 + DRF): apps `localizacao` (model `Cidade` já existe), `core` (Endereco, base multitenant `EmpresaOwnedModel` + `EmpresaScopedQuerySetMixin`), `empresas` (`Empresa`), `contas` (`Usuario` por e-mail, perfis admin/gestor/corretor, auth por Token). Rotas prontas: `POST /api/auth/login/`, `GET /api/usuarios/`, `GET /api/publico/corretores/<id>/`, `GET /api/publico/empresas/<id>/`. **Ainda não existem:** `GET /cidades`, `GET /imoveis`, nem o model de Imóvel.
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
*Last updated: 2026-09-21 after initialization*
