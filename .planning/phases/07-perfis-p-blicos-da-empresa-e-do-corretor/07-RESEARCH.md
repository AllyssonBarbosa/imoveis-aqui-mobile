# Phase 7: Perfis Públicos da Empresa e do Corretor - Research

**Researched:** 2026-11-08
**Domain:** Flutter (Clean Architecture + Cubit) consumindo dois endpoints públicos DRF já existentes (WEB 02) + uma vitrine por anunciante servida por mock sobre contrato escrito (adendo §12)
**Confidence:** HIGH (wire e código existente lidos nesta sessão); MEDIUM nos pontos que dependem da frente web (§12) e de comportamento do gerador `injectable` ao trocar a implementação por DI

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Critérios de aceite do card (travados — checklist da fase)**
- **AC-1:** Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação.
- **AC-2:** Página do corretor com foto, CRECI, apresentação e contato.
- **AC-3:** As duas mostram a vitrine dos imóveis daquele anunciante.
- **AC-4:** Os dados vêm da API dos perfis públicos.
- **AC-5:** Perfil de corretor desativado mostra aviso, e não tela quebrada.
- **AC-6:** Dá para chegar ao perfil a partir da página do imóvel.

**Dados e contrato**
- **D-01:** Perfis do corretor e da empresa consomem os endpoints da WEB 02 exatamente como estão (formatos no `07-CARD-APP07.md`), sem pedir mudança no Django. Models freezed + json_serializable, entidades de domínio próprias (`PerfilCorretor`, `PerfilEmpresa`), parse defensivo: `""` e `null` viram `null` na camada de dados (os campos opcionais do Django são `blank=True` e chegam como string vazia); URLs de foto/logomarca passam por `urlHttpOuNula` (F4, V12/V13). Corretor: `id, empresa_id, foto, nome, email, creci, telefone, whatsapp, apresentacao`. Empresa: `id, tipo (IMOBILIARIA|AUTONOMO), razao_social_ou_nome, creci, telefone, whatsapp, email, descricao, logomarca, cidades_atuacao[{id,nome,uf}], corretores_ativos[...]` (o app pode ignorar `corretores_ativos` nesta fase).
- **D-02:** Vitrine do anunciante = **adendo §12** em `01-CONTRATO-API.md`: o mesmo `GET /api/publico/imoveis/` da lista (mesmo envelope com cursor `results/next/previous`, mesmos campos do card do §3, mesmo serializer público com allowlist do §6) aceitando `empresa=<id>` ou `corretor=<id>` no lugar de `cidade`; só imóveis publicados; ordenação padrão "mais recentes". Para sign-off da frente web, como §9–§11. — **Reversibility:** costly — contrato compartilhado com a web.
- **D-03:** Mesmo padrão da API-04/F4: DataSource **real (Dio)** para os perfis da WEB 02 e DataSource **mock** sobre JSON de wire, trocáveis por DI. Enquanto detalhe e lista forem mock (até a Phase 5), o DI registra o **mock** dos perfis, com fixtures coerentes com os corretores que o mock do detalhe já devolve (ids batendo), senão o corretor do detalhe mock cairia em 404 na API real. A real fica pronta e testada com Dio mockado; a troca é uma linha de DI, junto com a Phase 5. A vitrine do anunciante é só mock (não há endpoint), parseada pelo mesmo Model da lista (`ImoveisEnvelopeModel`).
- **D-04:** Erros tipados só na camada de dados (F4/D-17, 04-03): 404 → exceção de domínio de "perfil não encontrado"; presentation decide pelo tipo, sem `try/catch` na UI.

**Navegação e entrada**
- **D-05:** Substitui a F4/D-15 (perfil stub com o objeto em memória): tocar no cartão do corretor na página do imóvel abre o perfil **buscando na API pelo `id`** do corretor; a abertura mostra na hora a **prévia** que o detalhe já tem (nome + foto, como F4/D-16) e completa quando a resposta chega.
- **D-06:** Página da empresa aberta a partir do perfil do corretor (usa `empresa_id`), por um cartão "Ver imobiliária" ("Ver página do anunciante" para `tipo == AUTONOMO` — texto é discrição). Sem atalho direto da página do imóvel (o contrato do detalhe não expõe a empresa — §11.5 g).
- **D-07:** `Navigator.push` + `MaterialPageRoute` (F4/D-18), sem go_router. Tocar num imóvel da vitrine do anunciante abre a página do imóvel pelo fluxo existente (`abrirDetalheImovel`).

**Layout (Material 3, `ColorScheme.fromSeed` verde e branco, `Theme.of(context).textTheme`)**
- **D-08:** Corretor, de cima para baixo: foto grande (`AvatarCorretor`) + nome + CRECI → apresentação → contato → cartão da empresa (D-06) → "Imóveis de {nome}".
- **D-09:** Empresa: logomarca + nome + CRECI (+ "Imobiliária"/"Corretor autônomo") → apresentação (`descricao`) → contato → cidades de atuação (chips) → "Imóveis de {nome}".
- **D-10:** Contato = telefone, WhatsApp e e-mail **como texto** selecionável, com ícone. **Sem botões de ligar/WhatsApp/e-mail e sem registrar contato** (APP 06 / CON-01, regra no servidor). Nenhuma dependência nova (sem `url_launcher`).
- **D-11:** Campo vazio/nulo omite a linha; seção vazia some inteira (F4/D-14).
- **D-12:** Vitrine do anunciante reaproveita o `ImovelCard` e o padrão de lista paginada por cursor com rodapés loading/erro/fim (F2/VIT-05). Vazio: "Nenhum imóvel anunciado no momento." Página única rolável (`CustomScrollView`: cabeçalho do perfil + lista em sliver).
- **D-13:** Reaproveitar `AvatarCorretor`, `ImagemRede`, `Card.outlined` (como `CartaoCorretor`) e a formatação de preço da vitrine. Nenhuma cor fora do `ColorScheme`.

**Estados e erros**
- **D-14:** Cubits próprios (`PerfilCorretorCubit`, `PerfilEmpresaCubit`; a vitrine do anunciante pode ter o seu) com estados freezed explícitos Loading/Success/Failure.
- **D-15:** 404 do corretor: "Este corretor não está mais disponível" + "Voltar"; 404 da empresa: "Esta página não está mais disponível" + "Voltar"; demais erros: "Tentar de novo". Mesmo desenho do F4/D-17 (DET-06).
- **D-16:** Sem `/gsd-ui-phase` (mesmo caminho do F4/D-20): D-08..D-13 são o contrato de UI; ícones e rótulos confirmados no human-check de fim de fase.

**Rastreabilidade**
- **D-17:** Novos IDs em `REQUIREMENTS.md` (seção "Perfis públicos (APP07)"), mapeados para a Phase 7 no ROADMAP (`**Requirements**:`) e na tabela de rastreabilidade, como o 04-02 fez: PERF-01 (AC-1), PERF-02 (AC-2), PERF-03 (AC-3), PERF-04 (AC-4), PERF-05 (AC-5), PERF-06 (AC-6) e API-08 (adendo §12 + DataSource trocável da vitrine do anunciante). Ajustar a nota do v2 que diz "cards 10–11" só se for necessário para não contradizer.

### Claude's Discretion
- Ícones e textos exatos (rótulos de contato, título da seção de imóveis, texto do cartão da empresa); formato do CRECI (mostrar como vem).
- Estrutura de pastas (sugestão: `lib/presentation/perfis/`, arquivos novos em `data/` e `domain/`), mexendo o mínimo em arquivos existentes — há trabalho paralelo da Phase 5 em outra branch (merge virá depois).
- Fixtures: pelo menos um corretor completo, um com campos vazios, um id reservado para 404 (desativado); uma empresa IMOBILIARIA e uma AUTONOMO; vitrine do anunciante com e sem imóveis e com mais de uma página.
- Se a vitrine do anunciante usa Cubit próprio ou fica dentro do Cubit do perfil.

### Deferred Ideas (OUT OF SCOPE)
- Botões de contato e registro do contato na API: APP 06 (CON-01).
- Lista "corretores da imobiliária" na página da empresa (`corretores_ativos`): não pedido pelo card.
- Login/área do corretor: APP 08. Área do gestor: APP 12.
- Deep link para perfis e go_router.
</user_constraints>

<phase_requirements>
## Phase Requirements

> Os IDs ainda **não existem** em `REQUIREMENTS.md` (o ROADMAP diz `Requirements: TBD`); a definição vem de CONTEXT D-17. Registrar é a primeira tarefa da fase.

| ID | Descrição (CONTEXT D-17 / AC) | Research Support |
|----|-------------------------------|------------------|
| PERF-01 | Página da empresa: logomarca, CRECI, apresentação, contato, cidades de atuação (AC-1) | `PerfilEmpresaModel` + `PerfilEmpresaScreen`; wire verbatim na seção "Wire real"; chips de `cidades_atuacao` |
| PERF-02 | Página do corretor: foto, CRECI, apresentação, contato (AC-2) | `PerfilCorretorModel` + `PerfilCorretorScreen`; reaproveita `AvatarCorretor` |
| PERF-03 | As duas páginas mostram a vitrine dos imóveis do anunciante (AC-3) | `VitrineAnuncianteCubit` + sliver de `ImovelCard`; mock derivado do detalhe mock; §12 |
| PERF-04 | Dados vêm da API dos perfis públicos (AC-4) | `PerfilRemoteDataSource` (Dio) testada com adaptador falso + teste de contrato; mock ativo por DI até a Phase 5 |
| PERF-05 | Corretor desativado (404) mostra aviso, não tela quebrada (AC-5) | 404 → `PerfilNaoEncontradoException` na camada de dados → estado `naoEncontrado` → aviso + "Voltar" |
| PERF-06 | Chega-se ao perfil pela página do imóvel (AC-6) | `CartaoCorretor.aoTocar` já chama `abrirPerfilCorretor`; só o corpo da função muda (assinatura compatível) |
| API-08 | Adendo §12 do contrato + DataSource trocável da vitrine do anunciante | Texto do §12 pronto na seção "Rascunho do §12"; interface `VitrineAnuncianteDataSource` + mock |
</phase_requirements>

## Summary

A fase é "uma tela sobre os dados": dois GETs públicos já prontos na web (`/api/publico/corretores/{id}/`, `/api/publico/empresas/{id}/`), sem paginação e com URLs de imagem absolutas, e uma vitrine por anunciante que **não existe na API** e por isso é servida por um mock que honra o contrato escrito no §12. Nenhuma dependência nova é necessária (D-10 proíbe `url_launcher`; o resto da stack já está no `pubspec.yaml`). Todo o desenho copia padrões já provados nas fases 2–4: DataSource trocável + mock sobre wire + `Result` + exceção de domínio no 404 + Cubit freezed + `abrirX()` como único ponto que resolve o Cubit no DI.

Achados que mudam o plano e que o CONTEXT não antecipava:
1. **O perfil do corretor não traz o `tipo` da empresa** (só `empresa_id`), então o texto do cartão da empresa (D-06: "Ver imobiliária" × "Ver página do anunciante" por `tipo == AUTONOMO`) **não pode depender do tipo** sem uma segunda requisição. Recomendação: rótulo único neutro "Ver página do anunciante".
2. **Strings vazias vs `null`:** `foto`/`logomarca` chegam `null` (nunca `""`), mas `telefone`, `descricao`, `apresentacao` (e, defensivamente, `creci`/`whatsapp`) podem chegar `""`. Normalizar na camada de dados (`textoOuNulo`) e deixar a UI decidir só por `!= null`.
3. **O 404 do corretor só cobre corretor inativo/inexistente**; empresa inativa **não** derruba o corretor (lacuna da WEB 02). Logo o "Ver página do anunciante" pode abrir um 404 de empresa — o estado `naoEncontrado` da empresa (D-15) é um caminho real, não teórico.
4. **Pontos quentes de merge com a Phase 5 (Georginho):** `lib/di/injection.config.dart` (gerado; resolver **regenerando**, nunca à mão) e a dependência do mock da vitrine do anunciante em `imoveis_fixture.dart`/`imoveis_detalhe_fixture.dart` (que a Phase 5 pode querer apagar como "dev-only").
5. **Testes existentes que quebram por desenho** (stub D-15 da F4): `perfil_corretor_screen_test.dart` inteiro, 1 teste em `detalhe_imovel_screen_test.dart` e o grupo "fluxo completo" de `detalhe_navegacao_test.dart` — todos precisam de DI/cubits falsos.
6. Linha de base verificada: `flutter test` → **587 testes verdes** (~45 s) antes de qualquer mudança.

**Primary recommendation:** Criar tudo em arquivos novos (`domain/`, `data/`, `presentation/perfis/`), manter `abrirPerfilCorretor(context, CorretorResponsavel, {...})` com assinatura compatível (zero edição em `detalhe_imovel_screen.dart`/`cartao_corretor.dart`), reduzir `detalhe_imovel/perfil_corretor_screen.dart` a um re-export, usar o corretor `id 8` do mock do detalhe como o "desativado" reservado (404 provável à mão sem editar a fixture do detalhe), e registrar **mock** de perfis + **mock** da vitrine do anunciante no DI, com a `PerfilRemoteDataSource` (Dio) pronta e testada ao lado.

## Project Constraints (from CLAUDE.md)

Extraídas de `.claude/CLAUDE.md` (mesma autoridade das decisões travadas):
- **Clean Architecture** `data/` (Models com serialização, Repositories, Data Sources) · `domain/` (UseCases puros, interfaces de Repository) · `presentation/` (Widgets limpos, Cubits). **Nenhum Widget faz lógica de negócio ou chamada de rede direta.** Não negociável.
- **Estado:** `Cubit` (flutter_bloc); imutabilidade estrita nos estados de tela. `Provider` está proibido (mistura de modelos mentais).
- **Modelos de API:** todo JSON em Models imutáveis (freezed + json_serializable); nunca `dynamic` onde a tipagem forte couber.
- **Erros de API:** `Result`/sealed; estados explícitos Loading/Success/Failure; **sem `try/catch` genérico na UI**.
- **UI:** Material 3 estrito; `ColorScheme.fromSeed`; widgets de `material.dart` (`Card`, `FilledButton`…); tipografia por `Theme.of(context).textTheme`; paleta Verde e Branco; **nenhuma cor hard-coded**.
- **Regra de negócio:** nada que "valha dinheiro" ou mude estado é decidido no app. (Aqui: o app **não** monta/completa dados do perfil — o servidor já herda da Empresa; o app mostra o que vier.)
- **Idioma:** models, variáveis e comentários em **português**.
- **Stack mandatada:** `dio`, `flutter_bloc`, `freezed`/`json_serializable`, `get_it`+`injectable`, `bloc_test`+`mocktail` (não `mockito`), **não** usar `equatable`, `dartz`, `permission_handler`, `Provider`, `http` puro.
- **Branch:** `feat/APP07` (já criada). Commits locais liberados; **push só com autorização**.
- **GSD:** edições de arquivo só dentro de um workflow GSD (esta pesquisa não edita nada além do RESEARCH.md).
- Skill do projeto `.claude/skills/flutter-frontend/skill`: `const` sempre que possível; **sem funções que retornam Widget** (extrair `StatelessWidget`); evitar `!`; pattern matching do Dart 3; componentes visuais sem HTTP.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Dados do perfil (creci, contato, apresentação, herança do autônomo) | API / Backend (Django) | — | `Usuario.dados_perfil_publico` já resolve a herança; o app só exibe |
| Decidir "corretor desativado" | API / Backend | Client data layer (traduz 404) | Só o servidor sabe; o app traduz 404 → exceção de domínio |
| Filtrar imóveis por `empresa`/`corretor` | API / Backend (§12, PENDENTE WEB) | Client mock (dev-only) | Regra "filtro resolvido no servidor"; o mock imita o servidor, o app nunca filtra |
| Normalizar `""`→`null`, filtrar esquema de URL | Client data layer (Model→entidade) | — | Parse defensivo de dado não confiável (V5/V12/V13) |
| Cursor/paginação da vitrine | API (envelope) | Client Cubit (acumula, nunca interpreta `next`) | `next` é opaco, como na vitrine da cidade |
| Mostrar prévia → completar → 404/erro | Client presentation (Cubit + tela) | — | Estado de tela; sem lógica de negócio |
| Navegação corretor → empresa → imóvel | Client presentation (`Navigator.push`) | — | D-07, sem go_router |
| Contato (telefone/WhatsApp/e-mail) | Client presentation: **só texto** | API (APP 06 faz a ação) | D-10: sem ação e sem registrar contato |

## Standard Stack

### Core (todos já no `pubspec.yaml`; **nenhuma dependência nova**)
| Library | Versão no projeto | Purpose | Why Standard |
|---------|-------------------|---------|--------------|
| `dio` | ^5.11.1 | `PerfilRemoteDataSource` (GET dos perfis) | Padrão do projeto (`CidadeRemoteDataSource`); `Dio` singleton em `modulo_rede.dart` |
| `flutter_bloc` | ^9.1.1 | `PerfilCorretorCubit`, `PerfilEmpresaCubit`, `VitrineAnuncianteCubit` | Decisão do time |
| `freezed_annotation` / `freezed` | ^3.1.0 / ^4.0.1 | Models, entidades, estados selados | Decisão do time |
| `json_annotation` / `json_serializable` | ^4.12.0 / ^6.14.1 | `fromJson` dos Models | Par obrigatório do freezed |
| `get_it` / `injectable` | ^9.3.0 / ^3.0.0 | DI; troca mock↔real | Padrão (`@LazySingleton(as:)`) |
| `cached_network_image` | ^4.0.2 | Logomarca/foto via `ImagemRede` (já existente) | Reuso; hook de teste `construirImagemDeRede` |
| `intl` | ^0.20.3 | `formatarPrecoBrl` (reuso pelo `ImovelCard`) | Reuso |

### Supporting (dev)
| Library | Versão | Purpose |
|---------|--------|---------|
| `bloc_test` / `mocktail` | ^10.0.0 / ^1.0.5 | Testes de Cubit e telas com `MockCubit` |
| `build_runner` / `injectable_generator` | ^2.16.1 / ^3.1.3 | Codegen (`*.freezed.dart`, `*.g.dart`, `injection.config.dart`) — **arquivos gerados são versionados** (`git ls-files` lista todos) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Texto simples selecionável (D-10) | `url_launcher` (ligar/WhatsApp/e-mail) | **Proibido nesta fase** (D-10, APP 06 tem regra no servidor) |
| `Navigator.push` | `go_router` | Fora do escopo (deferido) |
| Estado genérico `PerfilState<T>` compartilhado | Duas uniões separadas | Recomendado o genérico (1 arquivo, 1 teste de forma); separado também é aceitável (D-14 pede cubits próprios, não estados duplicados) |
| Mock da vitrine por arquivo novo | Estender `ImovelMockDataSource` com `empresa`/`corretor` | Estender edita arquivo que a Phase 5 mexe → conflito; arquivo novo evita |

**Installation:** nenhuma. `git diff --exit-code pubspec.yaml pubspec.lock` deve passar ao final da fase.

**Version verification:** versões lidas de `pubspec.yaml` nesta sessão `[VERIFIED: pubspec.yaml]`; `flutter --version` → `Flutter 3.47.9 • channel stable`, `environment: sdk: ^3.13.4` `[VERIFIED: pubspec.yaml, flutter --version]`.

## Package Legitimacy Audit

Nenhum pacote externo novo é instalado nesta fase — gate não aplicável.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| (nenhum) | — | — | — | — | — | — |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Wire real dos perfis (WEB 02) — lido do código, não inferido

Repo da web: `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web`, branch `main` `[VERIFIED: git branch --show-current → main]`. O repo **não** tem rota para imóveis públicos na `main` ainda (`config/urls.py` só inclui `contas.api.urls_publico` e `empresas.api.urls_publico` em `api/publico/`) `[VERIFIED: config/urls.py:14-15]`.

**Rotas** `[VERIFIED: contas/api/urls_publico.py, empresas/api/urls_publico.py]`:
```python
path("corretores/<int:pk>/", CorretorPublicoAPIView.as_view(), name="publico-corretor"),
path("empresas/<int:pk>/", EmpresaPublicaAPIView.as_view(), name="publico-empresa"),
```
→ `GET /api/publico/corretores/{id}/` e `GET /api/publico/empresas/{id}/` (com barra final), `AllowAny`.

**Quando é 404** `[VERIFIED: contas/api/views.py:41, empresas/api/views.py:13]`:
```python
queryset = Usuario.objects.filter(perfil=Usuario.Perfil.CORRETOR, is_active=True)
queryset = Empresa.objects.filter(ativa=True)
```
Corretor: 404 se inexistente, **não é corretor** (gestor/admin) ou `is_active=False`. Empresa: 404 se inexistente ou `ativa=False`. **Nenhuma checagem de empresa ativa na view do corretor** (lacuna WEB 02, já conhecida).

**Forma do corretor** `[VERIFIED: contas/api/serializers.py:32-44]`:
```python
dados = instance.dados_perfil_publico()
foto = dados.pop("foto")
...
foto_url = None
if foto:
    foto_url = request.build_absolute_uri(foto.url) if request else foto.url
return {
    "id": instance.pk,
    "empresa_id": instance.empresa_id,
    "foto": foto_url,
    **dados,
}
```
com `dados_perfil_publico` `[VERIFIED: contas/models.py:99-110]`:
```python
"nome": self.nome,
"email": self.email,
"creci": self.creci or empresa.creci,
"foto": self.foto or empresa.logomarca,
"telefone": self.telefone or empresa.telefone,
"whatsapp": self.whatsapp or empresa.whatsapp,
"apresentacao": self.apresentacao or empresa.descricao,
```
Consequências para o Model: `foto` é `str|null` (nunca `""`: `if foto:` converte vazio em `None`); `telefone`/`apresentacao` podem ser `""` (o `or empresa.X` cai em `empresa.telefone`, `blank=True`, e `empresa.descricao`, `blank=True`) `[VERIFIED: empresas/models.py — telefone/descricao blank=True; creci/whatsapp/email sem blank]`; `creci`/`whatsapp` só seriam vazios se dado bypassou validação — tratar `""` igual mesmo assim.

**Forma da empresa** `[VERIFIED: empresas/api/serializers.py:23-26]`:
```python
fields = [
    "id", "tipo", "razao_social_ou_nome", "creci", "telefone", "whatsapp",
    "email", "descricao", "logomarca", "cidades_atuacao", "corretores_ativos",
]
```
`CidadeSerializer.fields = ["id", "nome", "uf"]` `[VERIFIED: empresas/api/serializers.py:13]`; `tipo` ∈ `"IMOBILIARIA" | "AUTONOMO"` `[VERIFIED: empresas/models.py:15-16]`; `logomarca` é `None` quando não há arquivo (método `get_logomarca`); `cidades_atuacao` é lista possivelmente vazia (M2M `blank=True`).

**URLs de mídia:** absolutas via `request.build_absolute_uri` (precisam de `context={"request": ...}`, que `RetrieveAPIView` fornece). O host sai do `Host` da requisição — pelo emulador será `http://10.0.2.2:8000/media/...`. O manifest de **debug** permite cleartext; o de release não (`android/app/src/debug/AndroidManifest.xml:8` `usesCleartextTraffic="true"`; `android/app/src/main/AndroidManifest.xml:8-10` diz que cleartext segue desligado) `[VERIFIED: leitura dos manifests]`. Mídia só é servida pelo Django com `DEBUG` (`config/urls.py:18-19`) `[VERIFIED]`.

**Corpo do 404:** DRF padrão `{"detail": ...}`; o app **ignora o corpo** e decide só por `statusCode == 404` (mesmo padrão de `ImovelDetalheRepositoryImpl`).

**Teste de existência dos exemplos na web:** os testes da web confirmam 200 sem login, 404 para corretor desativado e empresa inativa `[VERIFIED: contas/tests.py:275-286, 303-314]`.

## Architecture Patterns

### System Architecture Diagram

```
 Página do imóvel (DetalheImovelScreen, F4 — não editada)
        | toque em CartaoCorretor(aoTocar)
        v
 abrirPerfilCorretor(context, previa: CorretorResponsavel, {criarCubit..., aoAbrirImovel})   <-- único ponto que usa getIt
        | Navigator.push(MaterialPageRoute) + MultiBlocProvider
        v
 +--------------------------- PerfilCorretorScreen -----------------------------+
 | CustomScrollView                                                             |
 |  slivers de cabeçalho  <-- BlocBuilder<PerfilCorretorCubit, PerfilState<PerfilCorretor>>
 |     carregando -> AvatarCorretor+nome (PRÉVIA) + spinner                      |
 |     carregado  -> avatar+nome+CRECI | apresentação | contato | CartaoEmpresa  |
 |     naoEncontrado -> "Este corretor não está mais disponível" [Voltar]        |
 |     erro -> "Tentar de novo"                                                  |
 |  SliverImoveisDoAnunciante  <-- BlocBuilder<VitrineAnuncianteCubit, ...>      |
 |     só aparece com o perfil carregado; ImovelCard -> aoAbrirImovel            |
 +-------+------------------------------------------------+---------------------+
         | carregar(id)                                    | carregar(AnuncianteRef.corretor(id)) / proximaPagina(next)
         v                                                 v
 ObterPerfilCorretorUseCase                      BuscarImoveisDoAnuncianteUseCase
         v                                                 v
 PerfilRepositoryImpl  (404->PerfilNaoEncontrado,   VitrineAnuncianteRepositoryImpl (Result<PaginaImoveis>)
   TypeError->FormatException, resto->Failure)               v
         v                                          VitrineAnuncianteDataSource  (interface)
 PerfilDataSource (interface)                                 |  DI: MOCK hoje | real quando §12 existir na web
    |  DI: MOCK hoje (uma linha) | PerfilRemoteDataSource(Dio)
    v                                                         v
 PerfilMockDataSource -> perfis_fixture (wire)    VitrineAnuncianteMockDataSource
 PerfilRemoteDataSource -> GET /api/publico/corretores/{id}/    -> linhasAcervoFixture() filtradas por
                                 /empresas/{id}/                  corretor do detalhe mock (e empresa via perfis_fixture)
                                                                -> ImoveisEnvelopeModel.fromJson (mesmo da lista)
 PerfilEmpresaScreen: idem, entrada = abrirPerfilEmpresa(context, empresaId) a partir do CartaoEmpresa do corretor
```

### Recommended Project Structure (tudo novo, exceto o shim)
```
lib/
├── domain/
│   ├── entities/        perfil_corretor.dart, perfil_empresa.dart (+ enum TipoEmpresa), anunciante_ref.dart
│   ├── repositories/    perfil_repository.dart (+ PerfilNaoEncontradoException), vitrine_anunciante_repository.dart
│   └── usecases/        obter_perfil_corretor_usecase.dart, obter_perfil_empresa_usecase.dart,
│                        buscar_imoveis_do_anunciante_usecase.dart
├── data/
│   ├── models/          perfil_corretor_model.dart, perfil_empresa_model.dart, texto_opcional.dart
│   ├── datasources/     perfil_datasource.dart (interface + caminhos), perfil_remote_datasource.dart,
│   │                    perfil_mock_datasource.dart, vitrine_anunciante_datasource.dart (interface + parâmetros),
│   │                    vitrine_anunciante_mock_datasource.dart
│   ├── mocks/           perfis_fixture.dart
│   └── repositories/    perfil_repository_impl.dart, vitrine_anunciante_repository_impl.dart
└── presentation/
    ├── detalhe_imovel/perfil_corretor_screen.dart   # ÚNICA edição: vira re-export (ver abaixo)
    └── perfis/
        ├── perfil_state.dart                          # PerfilState<T>: carregando|carregado|naoEncontrado|erro
        ├── perfil_corretor_cubit.dart, perfil_empresa_cubit.dart
        ├── vitrine_anunciante_cubit.dart, vitrine_anunciante_state.dart
        ├── perfil_corretor_screen.dart                # abrirPerfilCorretor + PerfilCorretorScreen
        ├── perfil_empresa_screen.dart                 # abrirPerfilEmpresa + PerfilEmpresaScreen
        ├── apresentacao_perfil.dart                   # funções puras (rótulos, linhas de contato)
        └── widgets/ corpo_perfil_com_vitrine.dart (ScrollController+paginação compartilhados),
                     secao_contato.dart, cabecalho_corretor.dart, cabecalho_empresa.dart,
                     cartao_empresa.dart, chips_cidades_atuacao.dart,
                     sliver_imoveis_anunciante.dart, rodape_paginacao_lista.dart, aviso_perfil.dart
```

### Pattern 1: Model de transporte defensivo → entidade (cópia do padrão `DetalheImovelModel`)
**What:** Model freezed com os nomes de wire; `paraEntidade()` aplica `textoOuNulo` e `urlHttpOuNula`. Chaves extras (ex.: `corretores_ativos`) são ignoradas pelo `json_serializable`, então **não declarar** o campo (minimização de dados + menos superfície de parse).
**When to use:** corretor e empresa.
```dart
// Padrão de lib/data/models/detalhe_imovel_model.dart (lido nesta sessão); nomes novos são proposta.
@freezed
abstract class PerfilCorretorModel with _$PerfilCorretorModel {
  const PerfilCorretorModel._();

  const factory PerfilCorretorModel({
    required int id,
    @JsonKey(name: 'empresa_id') int? empresaId, // defensivo: nulo esconde o cartão da empresa
    String? foto,
    required String nome,
    String? email,
    String? creci,
    String? telefone,
    String? whatsapp,
    String? apresentacao,
  }) = _PerfilCorretorModel;

  factory PerfilCorretorModel.fromJson(Map<String, Object?> json) =>
      _$PerfilCorretorModelFromJson(json);

  PerfilCorretor paraEntidade() => PerfilCorretor(
    id: id,
    empresaId: empresaId,
    foto: urlHttpOuNula(foto),
    nome: nome,
    email: textoOuNulo(email),
    creci: textoOuNulo(creci),
    telefone: textoOuNulo(telefone),
    whatsapp: textoOuNulo(whatsapp),
    apresentacao: textoOuNulo(apresentacao),
  );
}
```
```dart
// lib/data/models/texto_opcional.dart — mesmo espírito de url_segura.dart (nunca lança)
String? textoOuNulo(String? valor) {
  final texto = valor?.trim();
  if (texto == null || texto.isEmpty) return null;
  return texto;
}
```
`PerfilEmpresaModel`: `tipo` como `String` → entidade `TipoEmpresa?` (desconhecido → `null`, **não** lança; rótulo neutro), `@JsonKey(name: 'razao_social_ou_nome') nome`, `@Default(<CidadeModel>[]) @JsonKey(name: 'cidades_atuacao') List<CidadeModel>` (reusa `CidadeModel`, descarta `id` via `paraEntidade()` como na F2).

### Pattern 2: Repositório que traduz 404 (cópia de `ImovelDetalheRepositoryImpl`)
```dart
@LazySingleton(as: PerfilRepository)
class PerfilRepositoryImpl implements PerfilRepository {
  PerfilRepositoryImpl(this._dataSource);
  final PerfilDataSource _dataSource;

  @override
  Future<Result<PerfilCorretor>> buscarCorretor(int id) =>
      _executar(() async => (await _dataSource.buscarCorretor(id)).paraEntidade());

  @override
  Future<Result<PerfilEmpresa>> buscarEmpresa(int id) =>
      _executar(() async => (await _dataSource.buscarEmpresa(id)).paraEntidade());

  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on PerfilNaoEncontradoException catch (erro) {
      return Result.failure(erro);
    } on DioException catch (erro) {
      if (erro.response?.statusCode == 404) {
        return Result.failure(const PerfilNaoEncontradoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      // fromJson gerado faz `as` e lança TypeError (Error, não Exception) — Pitfall 1 da F4.
      return Result.failure(FormatException('perfil malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
```
`try/catch` fica em `data/` (permitido); a UI decide só por tipo (`erro is PerfilNaoEncontradoException`).

### Pattern 3: DataSource remota fina (cópia do estilo de `CidadeRemoteDataSource`)
```dart
String caminhoPerfilCorretor(int id) => '/api/publico/corretores/$id/';
String caminhoPerfilEmpresa(int id) => '/api/publico/empresas/$id/';

@lazySingleton // SEM `as:` enquanto o mock estiver ativo — mesmo registro de CidadeRemoteDataSource
class PerfilRemoteDataSource implements PerfilDataSource {
  PerfilRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<PerfilCorretorModel> buscarCorretor(int id) async =>
      PerfilCorretorModel.fromJson(await _obterObjeto(caminhoPerfilCorretor(id)));

  @override
  Future<PerfilEmpresaModel> buscarEmpresa(int id) async =>
      PerfilEmpresaModel.fromJson(await _obterObjeto(caminhoPerfilEmpresa(id)));

  Future<Map<String, Object?>> _obterObjeto(String caminho) async {
    // Dio 5 lança DioException em 404 (validateStatus padrão) — o repositório traduz.
    final resposta = await _dio.get<Object?>(caminho);
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw FormatException('Corpo de GET $caminho não é um objeto JSON.');
    }
    return corpo;
  }
}
```
O `id` é `int` tipado → sem injeção de caminho. Sem interceptors/log (não adicionar `LogInterceptor`: o corpo tem e-mail/telefone).

### Pattern 4: Troca mock↔real "numa linha" (precedente verificado)
`injection.config.dart` hoje registra o mock com `as:` e o remoto de cidades **sem** interface (`gh.lazySingleton<_i326.ImovelDataSource>(() => _i609.ImovelMockDataSource())` e `gh.lazySingleton<_i320.CidadeRemoteDataSource>(...)`) `[VERIFIED: lib/di/injection.config.dart:109-117]`. Para os perfis: `@LazySingleton(as: PerfilDataSource)` **só** em `PerfilMockDataSource`; `PerfilRemoteDataSource` com `@lazySingleton` simples. A troca na Phase 5 = mover a anotação `as: PerfilDataSource` do mock para o remoto + `dart run build_runner build --delete-conflicting-outputs`. Nunca anotar as duas com `as:` (o `getIt` não permite dois registros do mesmo tipo) `[ASSUMED: comportamento do injectable/get_it]`. Um teste "DI real" (`getIt<PerfilDataSource>()` é `PerfilMockDataSource`) é o canário da troca, no molde do grupo 'DI real' de `detalhe_navegacao_test.dart:436-453`.

### Pattern 5: Abertura que resolve o Cubit num só ponto (molde de `abrirDetalheImovel`)
```dart
// lib/presentation/perfis/perfil_corretor_screen.dart (proposta)
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel previa, {
  PerfilCorretorCubit Function()? criarPerfilCubit,       // só para teste
  VitrineAnuncianteCubit Function()? criarVitrineCubit,   // só para teste
  AoAbrirImovel aoAbrirImovel = abrirDetalheImovel,       // default como em VitrineScreen
  Widget Function(String url)? construirImagemDeRede,
}) {
  final criarPerfil = criarPerfilCubit ?? () => getIt<PerfilCorretorCubit>();
  final criarVitrine = criarVitrineCubit ?? () => getIt<VitrineAnuncianteCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PerfilCorretorCubit>(create: (_) => criarPerfil()..carregar(previa.id)),
          BlocProvider<VitrineAnuncianteCubit>(
            create: (_) => criarVitrine()..carregar(AnuncianteRef.corretor(previa.id)),
          ),
        ],
        child: PerfilCorretorScreen(
          previa: previa,
          aoAbrirImovel: aoAbrirImovel,
          construirImagemDeRede: construirImagemDeRede,
        ),
      ),
    ),
  );
}
```
Os dois Cubits sobem em paralelo na abertura (simples e sem armadilha de `BlocProvider` lazy); a UI só **mostra** a vitrine quando o perfil está `carregado`. Custo: uma chamada "à toa" no 404 — aceitável.

### Pattern 6: Tela única rolável com paginação compartilhada
Um `StatefulWidget` (`CorpoPerfilComVitrine`) dono do `ScrollController(keepScrollOffset: false)` que recebe os **slivers do cabeçalho** de cada tela e injeta `SliverImoveisDoAnunciante`. Reproduz de `VitrineScreen`: listener `_aoRolar` a 90% de `maxScrollExtent` → `carregarMais()`, e `_agendarCarregarMaisSeNaoPreencheATela` (pós-frame) para o caso de a primeira página não gerar rolagem. Guarda extra: só chamar `carregarMais` quando o perfil está carregado.
```dart
// Trecho do corpo (sliver, não um BlocProvider no meio dos slivers!)
CustomScrollView(
  controller: _controle,
  slivers: [
    ...cabecalho,                       // List<Widget> de slivers vinda da tela
    if (perfilCarregado) SliverImoveisDoAnunciante(titulo: 'Imóveis de $nome', aoAbrirImovel: ..., aoTentarDeNovo: ...),
    SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24)),
  ],
)
```
`SliverImoveisDoAnunciante` usa `BlocBuilder<VitrineAnuncianteCubit, VitrineAnuncianteState>` retornando um **sliver** (`SliverList.builder`, `SliverToBoxAdapter`, `SliverFillRemaining`). `ImovelCard` e o rodapé (carregando/erro/fim) como itens, igual a `_RodapePaginacao` de `vitrine_screen.dart`, que é **privado** → criar `RodapePaginacaoLista` novo, parametrizado por `aoTentarDeNovo` (não editar `vitrine_screen.dart`).

### Pattern 7: Domínio da vitrine do anunciante (arquivos novos; não toca `ImovelRepository`)
```dart
// domain/entities/anunciante_ref.dart (proposta)
enum TipoAnunciante { corretor, empresa }

class AnuncianteRef {
  const AnuncianteRef.corretor(this.id) : tipo = TipoAnunciante.corretor;
  const AnuncianteRef.empresa(this.id) : tipo = TipoAnunciante.empresa;
  final TipoAnunciante tipo;
  final int id;
  // == / hashCode (sem equatable — CLAUDE.md)
}
```
`VitrineAnuncianteDataSource { Future<ImoveisEnvelopeModel> buscar(AnuncianteRef); Future<ImoveisEnvelopeModel> seguir(String proximaPagina); }`; parâmetros de wire em função pura simétrica (como `parametrosDaConsulta` ↔ `filtrosDosParametros`): `parametrosDoAnunciante(ref) → {'corretor': '7'}` / `{'empresa': '3'}` e o inverso para o mock. **O app envia apenas `corretor` ou `empresa`** (sem `cidade`, sem `ordenacao`, sem `busca`/filtros nesta fase): o padrão do servidor é "mais recentes" (§9 item 2). O `PaginaImoveis`/`ImoveisEnvelopeModel` da lista são reaproveitados sem mudança.

### Anti-Patterns to Avoid
- **`BlocProvider` como filho direto de `CustomScrollView.slivers`** — não é sliver (erro de RenderObject). Prover os Cubits **acima** do `CustomScrollView`.
- **Estender `ImovelMockDataSource`/`ImovelRepository`/`ImovelDataSource`** com `empresa`/`corretor` — edita os arquivos que a Phase 5 reescreve.
- **Duplicar a regra `id % 3` do detalhe mock** na vitrine do anunciante — derivar de `detalhesAcervoFixture()` (fonte única), senão lista e detalhe divergem.
- **Mostrar prévia (nome/foto) no estado 404** — contradiz "desativado"; F4 também escondeu o preço no 404 (decisão 04-03).
- **Formatar telefone/WhatsApp no app** — o wire mistura formatos (`"(19) 3333-4444"` e `"19999998888"`); formatar é regra nova e arriscada. Mostrar como vem (D-10/discrição).
- **Decidir o rótulo do cartão da empresa por `tipo`** no perfil do corretor — o dado não existe ali (ver Summary, achado 1).
- **`LogInterceptor`/logs do corpo** — PII pública, mas não há motivo para registrar.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Paginação por cursor | Novo mecanismo | Padrão `next` opaco + `ImoveisEnvelopeModel` + acumulação do `VitrineCubit` | Já provado; evita cards duplicados |
| Imagem com cache/placeholder | `Image.network` | `ImagemRede` / `AvatarCorretor` | Placeholder, erro e hook de teste prontos |
| Filtro de esquema de URL | Regex própria | `urlHttpOuNula` | Já cobre `javascript:`, `file:`, `data:`, relativa, vazia |
| Mapeamento de erro 404 | `if` na tela | Repositório → exceção de domínio → `switch` no estado | D-04 |
| Texto selecionável | Gesture/clipboard manual | `SelectableText` (nativo) | Sem dependência nova; não autolinka |
| Fake HTTP em teste | Pacote de mock HTTP | `HttpClientAdapter` escrito à mão (já em 3 testes) | Sem pacote novo |
| Equality de estados/entidades | `equatable` | `freezed` | CLAUDE.md |
| Chips de cidades | Container custom | `Wrap` + `Chip` (como `SecaoCaracteristicas`) | Padrão M3 já usado |

**Key insight:** esta fase é composição de peças existentes; o risco real não é técnico, é **coerência de fixtures** (ids de corretor ↔ detalhe mock ↔ empresas ↔ vitrine) e **conflito de merge** com a Phase 5.

## Fixtures coerentes (D-03) — proposta concreta

Fatos verificados do mock do detalhe `[VERIFIED: lib/data/mocks/imoveis_detalhe_fixture.dart:99-116, 160-162]`: corretores `id` **7** (Marina Lopes, foto `'$urlBaseFotosMock/corretor-7/200/200'`), **8** (Rafael Prado) e **9** (Camila Duarte, `'foto': null`), escolhidos por `_corretoresMock[id % _corretoresMock.length]`; `id % 10 == 9` → `corretor: null`; o detalhe 42 curado usa Marina (7) e `42 % 3 == 0` → consistente; 57 e 63 também caem em 7.

Contagens calculadas (script sobre os ids de `linhasAcervoFixture()` menos 339): 119 imóveis publicados no detalhe; **corretor 7 → 38**, **corretor 8 → 36**, **corretor 9 → 36**, 9 sem corretor. Logo `corretor=7` dá 4 páginas de 10 (10/10/10/8); a empresa que reúne 7+8 daria 74 (8 páginas).

| Entidade | Proposta | Cobre |
|----------|----------|-------|
| Corretor **7** Marina Lopes | `empresa_id: 3`, completo: foto, e-mail, creci, telefone formatado, whatsapp só dígitos, apresentação | perfil completo (PERF-02), vitrine com **4 páginas** |
| Corretor **8** Rafael Prado | **reservado = desativado → 404** (constante pública `idCorretorDesativadoMock = 8`) | PERF-05 provável à mão (qualquer imóvel `id%3==1` da vitrine → corretor → aviso), **sem editar** a fixture do detalhe |
| Corretor **9** Camila Duarte | `empresa_id: 4` (AUTONOMO), `foto: null`, `telefone: ""`, `apresentacao: ""` (campos vazios), creci presente | omissão de linhas (D-11), avatar padrão, empresa AUTONOMO |
| Empresa **3** | `tipo: "IMOBILIARIA"`, logomarca, `cidades_atuacao` com 3 cidades, `descricao` longa, `corretores_ativos: [corretor 7 no formato público]` (para provar que o app ignora) | PERF-01 completo + vitrine multi-página |
| Empresa **4** | `tipo: "AUTONOMO"`, `logomarca: null`, `telefone: ""`, 1 cidade | PERF-01 com omissões; AUTONOMO |
| qualquer id ausente | **404 por ausência** (como o detalhe mock faz) | empresa 404 (D-15) em teste; vitrine vazia em `paraTeste` |
| Falha determinística | opcional: `idPerfilFalhaMock` (ex.: corretor 10 lança `FalhaSimuladaDoMock`) | fluxo "Tentar de novo" à mão |

Alternativa (se o planner preferir dois corretores "bons"): corretor dedicado `99` como desativado + **uma** linha em `imoveis_detalhe_fixture.dart` apontando o imóvel 337 para o 99 — editaria um arquivo existente (conflito potencial); por isso a recomendação é usar o 8.

`corretores_ativos` na fixture da empresa deve existir **só para provar o ignore**; o Model não declara o campo.

O mock da vitrine do anunciante: `corretor=<id>` → linhas de `linhasAcervoFixture()` cujo detalhe (`detalhesAcervoFixture()`) tem `corretor.id == id`; `empresa=<id>` → união dos corretores cuja `empresa_id` (de `perfis_fixture`) é `id`. Ordena por `criado_em` desc + `id` desc (mesmo critério de `_compararPorRecenciaDesc`), página de 10, cursor `base64Url('o=<offset>')`, `next` = `Uri.parse('https://mock.imoveisaqui.local/api/publico/imoveis/')` + mesmos params + `cursor` (mesmo formato do mock da lista, para a mesma regra de "next opaco"). Desconhecido → página vazia (não 404). Exceções de parâmetro inválido (`FormatException`) como o mock da lista. Constructor `paraTeste({linhas, detalhes, corretores, latencia, tamanhoPagina})`.

## Rascunho do §12 (para colar em `01-CONTRATO-API.md`)

> Estrutura espelha §11. Marcar **"aguardando sign-off do E2/frente web"** e **Reversibilidade: custosa**.

**12. Adendos da Fase 7 — vitrine do anunciante (aguardando sign-off da frente web)**
- **12.1 Endpoint:** o mesmo `GET /api/publico/imoveis/` da lista (§3–§5), aceitando **`empresa=<id>`** ou **`corretor=<id>`** (inteiros, PK) **no lugar de `cidade`**. Sem `cidade`, a lista **não** é restrita a uma cidade (a vitrine do anunciante é entre cidades). `AllowAny`.
- **12.2 Resposta:** idêntica ao §3/§4: envelope `CursorPagination` `{next, previous, results}`, linhas com a mesma allowlist do §6 — **sem** `corretor`, `empresa`, `proprietario` nas linhas. Queryset obrigatório `Imovel.objects.filter(publicado=True)` + filtro `empresa_id=<id>` (campo `empresa` de `EmpresaOwnedModel`) ou `corretor_responsavel_id=<id>` `[VERIFIED: imoveis/models.py — corretor_responsavel FK; core/models.py — EmpresaOwnedModel.empresa]`.
- **12.3 Ordenação:** padrão `mais_recentes` (`-criado_em`); o app **não** envia `ordenacao`, `busca` nem filtros nesta fase (continuam válidos se enviados — §5/§9/§10).
- **12.4 Id inexistente / inativo:** `200` com `results: []` (não 404) — o 404 é do endpoint de **perfil**; a vitrine de um anunciante inexistente é apenas vazia.
- **12.5 Valor não inteiro em `empresa`/`corretor`:** `400` (como os demais params malformados, §10 item 5/12).
- **12.6 `empresa` e `corretor` juntos:** `AND` entre os dois filtros (o app nunca envia os dois).
- **12.7 PENDENTE WEB (registrar, não resolver aqui):** (a) o endpoint em si (a lista pública `GET /api/publico/imoveis/` nem existe na `main` da web ainda — API-03/Phase 5); (b) `cidade` opcional quando há `empresa`/`corretor`; (c) se imóveis de **empresa inativa** ou de **corretor desativado** continuam públicos na vitrine (regra de negócio da web); (d) a view do corretor (WEB 02) não confere `empresa.ativa` (o site confere `empresa__ativa=True`); (e) o detalhe da WEB 09 expõe `corretor_responsavel` (perfil completo) e o contrato do app §11 expõe `corretor {id,nome,foto,slug}` — conciliação já é da Phase 5.
- **12.8 Sincronização:** vale §8 — copiar para o repo da web e obter sign-off antes de tratar como congelado; até lá vale o mock (`VitrineAnuncianteMockDataSource`), protegido por teste de contrato.

Exemplos de wire dos perfis: salvar `perfil_corretor.example.json` e `perfil_empresa.example.json` em `.planning/phases/01-…/contrato/` (onde já vivem os outros exemplos e de onde `contrato_detalhe_test.dart` lê) `[VERIFIED: test/data/contrato_detalhe_test.dart:16-24]`, com a forma exata das seções "Wire real".

## Runtime State Inventory

Fase aditiva (greenfield dentro do app): **omitida** — sem rename/refactor/migração de dados. Único "estado" tocado: arquivos gerados versionados (`*.freezed.dart`, `*.g.dart`, `lib/di/injection.config.dart`) → regenerar com `dart run build_runner build --delete-conflicting-outputs`.

## Common Pitfalls

### Pitfall 1: Strings vazias do Django tratadas como dado
**What goes wrong:** linha "Telefone" com texto vazio, seção "Apresentação" em branco.
**Why:** campos `blank=True` chegam `""`, não `null`.
**How to avoid:** `textoOuNulo` em `paraEntidade()`; UI testa `!= null`. Teste de Model com `""` e `"   "`.
**Warning signs:** `Text('')` na árvore; ícone de contato sem texto.

### Pitfall 2: `tipo` da empresa inexistente no perfil do corretor
**What goes wrong:** implementar D-06 literalmente exige `tipo`, que só vem em `/empresas/{id}/`.
**How to avoid:** rótulo neutro único "Ver página do anunciante" no `CartaoEmpresa` (travar no plano); o "Imobiliária"/"Corretor autônomo" (D-09) aparece **na página da empresa**, onde `tipo` existe (`TipoEmpresa?` desconhecido → sem rótulo).

### Pitfall 3: Empresa inativa abre 404 a partir de um corretor 200
**What goes wrong:** `CartaoEmpresa` leva a tela de erro.
**How to avoid:** o estado `naoEncontrado` da empresa ("Esta página não está mais disponível" + "Voltar") é caminho real (lacuna WEB 02); testar com id ausente.

### Pitfall 4: `TypeError` do `fromJson` escapa como `Error`
**What goes wrong:** `on Exception` não pega `TypeError`; o Cubit nunca sai de `carregando`.
**How to avoid:** `on TypeError catch` no repositório (como `ImovelDetalheRepositoryImpl`). Teste: corpo sem `nome` → `Failure(FormatException)`.

### Pitfall 5: Cubit emite depois de fechado / duplo toque no "Tentar de novo"
**How to avoid:** `if (isClosed) return;` após cada `await`; `tentarNovamente` ignora se já `carregando` (molde `DetalheImovelCubit`). Para a vitrine do anunciante, `carregarMais` ignora enquanto `carregandoMais || erroAoCarregarMais || proximaPagina == null`; retry é explícito (T-02-03-01).

### Pitfall 6: Vitrine curta não rola → paginação trava
**What goes wrong:** primeira página (≤ 2 cards) mais cabeçalho cabem na tela, `maxScrollExtent <= 0`, nunca dispara `carregarMais`.
**How to avoid:** o `addPostFrameCallback` de `_agendarCarregarMaisSeNaoPreencheATela` (copiar a lógica); testar com `tamanhoPagina: 1` e viewport alto.

### Pitfall 7: Testes de lista em `CustomScrollView` não encontram itens fora da viewport
**What goes wrong:** `SliverList` é preguiçoso; `find` falha em cards abaixo da dobra.
**How to avoid:** `tester.view.physicalSize = Size(400, 2400)` (como `detalhe_imovel_screen_test.dart:64-67`) ou `scrollUntilVisible`. Nunca `pumpAndSettle` com spinner em tela (animação infinita) — usar `pump(Duration)`.

### Pitfall 8: Conflito de merge em `injection.config.dart` (e freezed/g gerados)
**What goes wrong:** Georginho (Phase 5) e esta fase editam o mesmo arquivo gerado.
**How to avoid:** resolver **regenerando** (`build_runner build --delete-conflicting-outputs`) depois do merge, nunca à mão; manter registros novos só em arquivos novos; avisar o colega.

### Pitfall 9: Dependência do mock da vitrine do anunciante em fixtures que a Phase 5 pode apagar
**What goes wrong:** `imoveis_fixture.dart`/`imoveis_detalhe_fixture.dart` são "dev-only: saem junto com o mock na Fase 5"; a vitrine do anunciante continua mock (sem endpoint).
**How to avoid:** combinar com o colega que as fixtures **ficam** (ou migram para `data/mocks/` neutro) até o §12 existir na web; registrar em Open Questions. O novo mock **não** importa `imovel_mock_datasource.dart` (só fixtures e `caminhoImoveisPublico` de `parametros_consulta_imoveis.dart`).

### Pitfall 10: Ciclo de imports `detalhe_imovel_screen` ↔ `perfis`
`detalhe_imovel_screen.dart` importa o shim de `abrirPerfilCorretor`; `perfis/` importa `abrirDetalheImovel`/`AoAbrirImovel` de `detalhe_imovel_screen.dart`. Ciclo de imports **é legal em Dart** (só funções/classes top-level); não há lint por padrão. Mitigação já embutida: o default `aoAbrirImovel = abrirDetalheImovel` é tear-off const, sem estado.

### Pitfall 11: Guarda da F4 sobre `getIt<` em `detalhe_imovel/`
O plano 04-08 impôs "só `detalhe_imovel_screen.dart` usa `getIt<` em `lib/presentation/detalhe_imovel`" (`04-08-PLAN.md:187`). Por isso o **shim** em `detalhe_imovel/perfil_corretor_screen.dart` não pode conter `getIt<` — apenas `export '../perfis/perfil_corretor_screen.dart';`. O `getIt<` fica em `lib/presentation/perfis/` (apenas nos dois `abrir*`).

### Pitfall 12: Testes que passam a exigir DI
`detalhe_imovel_screen_test.dart` ("tocar no cartão abre o perfil com o nome do detalhe", linhas 674-695) e `detalhe_navegacao_test.dart` (grupo "fluxo completo", linhas 203-284) abrem o perfil real → `getIt<PerfilCorretorCubit>` não registrado. Registrar `registerFactory<PerfilCorretorCubit>`/`<VitrineAnuncianteCubit>` nos testes (com a pilha real mock `latencia: Duration.zero`/curta) e `getIt.reset()` no `tearDown` (já existe). `perfil_corretor_screen_test.dart` ("não mostra nenhum dado de contato", T-04-08-01) é **invertido** pela fase e deve ser reescrito.

### Pitfall 13: `find.text` e `SelectableText`
`find.text` casa `EditableText`, então `SelectableText('...')` é encontrável `[VERIFIED: flutter_test/lib/src/finders.dart:1532, _MatchTextFinder.matches → EditableText]`. Mas testes que varrem `find.byType(Text)` (como o do stub) **não** veem `SelectableText` — usar `find.byType(SelectableText)`/`find.text`.

### Pitfall 14: `ImovelCard` sem hook de imagem em teste
`ImovelCard` não expõe `construirImagemDeRede`; os testes da vitrine já passam com `CachedNetworkImage` real (587 verdes). Se aparecer flakiness, usar linhas com `foto_capa: null` nas fixtures de teste — **não** editar `ImovelCard`.

## Code Examples

### Teste da DataSource remota com adaptador falso (molde de `cidade_remote_datasource_test.dart` / `imovel_detalhe_repository_impl_test.dart`)
```dart
// Mesma técnica já em 2 arquivos de teste: HttpClientAdapter escrito à mão.
final adaptador = _HttpClientAdapterFalso(status: 200, corpo: perfilCorretor7Wire);
final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'))..httpClientAdapter = adaptador;
final repo = PerfilRepositoryImpl(PerfilRemoteDataSource(dio));
final resultado = await repo.buscarCorretor(7);
expect(adaptador.uris, ['http://10.0.2.2:8000/api/publico/corretores/7/']);
expect(resultado, isA<Success<PerfilCorretor>>());
// 404 -> Failure(PerfilNaoEncontradoException); 500 -> Failure(DioException); corpo sem 'nome' -> Failure(FormatException)
```

### Cubit de perfil (molde de `DetalheImovelCubit`)
```dart
@injectable
class PerfilCorretorCubit extends Cubit<PerfilState<PerfilCorretor>> {
  PerfilCorretorCubit(this._obter) : super(const PerfilState.carregando());
  final ObterPerfilCorretorUseCase _obter;
  int? _id;

  Future<void> carregar(int id) { _id = id; return _buscar(id); }

  Future<void> tentarNovamente() async {
    final id = _id;
    if (isClosed || id == null || state is PerfilCarregando) return;
    emit(const PerfilState.carregando());
    await _buscar(id);
  }

  Future<void> _buscar(int id) async {
    final resultado = await _obter(id);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data): emit(PerfilState.carregado(data));
      case Failure(:final erro):
        emit(erro is PerfilNaoEncontradoException
            ? const PerfilState.naoEncontrado()
            : const PerfilState.erro());
      case Loading(): break;
    }
  }
}
```
`PerfilState<T>` freezed genérico (`carregando | carregado(T dados) | naoEncontrado | erro`), padrão de `Result<T>` (`lib/core/result.dart`) — um único arquivo + um teste de forma; o `switch` da tela segue exaustivo, sem ramo abrangente.

### Linhas de contato (função pura em `apresentacao_perfil.dart`, testável sem widget)
```dart
// Retorna só o que existe (D-11). Ícones Material: telefone/WhatsApp/e-mail.
List<LinhaContato> linhasDeContato({String? telefone, String? whatsapp, String? email}) => [
  if (telefone != null) LinhaContato(rotulo: 'Telefone', valor: telefone, icone: Icons.phone_outlined),
  if (whatsapp != null) LinhaContato(rotulo: 'WhatsApp', valor: whatsapp, icone: Icons.chat_outlined),
  if (email != null) LinhaContato(rotulo: 'E-mail', valor: email, icone: Icons.email_outlined),
];
```
(`Icons.chat_outlined` porque o Material não tem ícone do WhatsApp; rótulos/ícones são discrição e vão ao human-check — D-16.) A seção inteira some se a lista é vazia; renderizar valor com `SelectableText` e rótulo no `Semantics`.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Stub de perfil com objeto em memória (F4 D-15) | Perfil buscado por `id` + prévia | Esta fase (D-05) | `PerfilCorretorScreen` antigo some; testes mudam |
| `SharedPreferences.getInstance()` | `SharedPreferencesAsync` | n/a aqui | não usado nesta fase |
| `ListView.builder` sozinho | `CustomScrollView` + `SliverList.builder` | Flutter ≥ 3.7 `[ASSUMED]` | Necessário para cabeçalho + lista rolando juntos (D-12) |

**Deprecated/outdated:** nada relevante na stack da fase.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Mover a anotação `as: PerfilDataSource` do mock para o remoto + `build_runner` troca a implementação, e duas anotações `as:` do mesmo tipo quebram o `getIt` | Pattern 4 | A troca exigiria `@Environment`; mitigado por teste "DI real" no plano |
| A2 | `SliverList.builder` disponível no Flutter 3.47 (existe desde 3.7) | State of the Art | Trivial: usar `SliverList(delegate: SliverChildBuilderDelegate(...))` |
| A3 | A frente web aceita `empresa=`/`corretor=` no endpoint de lista, `cidade` opcional e `200` vazio para id desconhecido (§12) | Rascunho do §12 | Retrabalho do mock/DataSource real quando o sign-off vier (reversibilidade custosa — já sinalizado) |
| A4 | Imóveis de empresa inativa/corretor desativado: política indefinida (web) | §12.7 c | O app pode listar imóveis de anunciante "inativo" se a web permitir; a UI só mostra a vitrine quando o perfil é 200 |
| A5 | `Icons.chat_outlined`, `Icons.email_outlined`, `Icons.phone_outlined`, `Icons.apartment_outlined` existem em `material.dart` | Code Examples | Troca de ícone no human-check; `flutter analyze` pega nome inexistente |
| A6 | LGPD: exposição pública de e-mail/telefone/WhatsApp/CRECI do corretor é aceita pelo produto (o card pede "contato"; WEB 02 já expõe; §11.5 g sinalizou LGPD para o detalhe) | Security | Se o produto vetar, remover a linha de e-mail na UI (campo continua no wire) |
| A7 | Rótulo único "Ver página do anunciante" é aceitável no lugar de "Ver imobiliária" | Pitfall 2 | Texto é discrição no CONTEXT; confirmar no human-check |

## Open Questions

1. **Coordenação com a Phase 5 (Georginho) sobre fixtures e DI**
   - Sabe-se: o mock da vitrine do anunciante depende de `imoveis_fixture.dart` e `imoveis_detalhe_fixture.dart`; `injection.config.dart` será editado pelos dois.
   - Incerto: se a Phase 5 apaga as fixtures.
   - Recomendação: avisar antes do merge; fixtures ficam enquanto o §12 não existir; conflito de gerados resolvido por regeneração.

2. **Id reservado do corretor desativado: 8 ou dedicado?**
   - Recomendação: **8** (zero edição na fixture do detalhe). Alternativa documentada acima.

3. **Real `VitrineAnuncianteRemoteDataSource` (Dio) agora ou depois?**
   - Recomendação: **depois** (o endpoint não existe; sem como testar contra a realidade). Se algum dia for feita, repetir a defesa de origem do `next` de `CidadeRemoteDataSource._resolverProximaUrl` (mesmo scheme/host/port) e limite de páginas.

4. **Onde guardar os dois JSONs de exemplo?** Recomendação: dir `contrato/` da Phase 1 (consistente); o planner pode optar por `07-…/contrato/` ajustando a constante de caminho do teste.

5. **Conciliação `corretor` (§11) × `corretor_responsavel` (WEB 09)**: já é da Phase 5; esta fase só depende de `corretor.id`.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | tudo | ✓ | 3.47.9 (stable) `[VERIFIED: flutter --version]` | — |
| Dart SDK | codegen/testes | ✓ | ^3.13.4 (do `pubspec.yaml`) | — |
| `flutter test` | validação | ✓ | 587 testes verdes em ~45 s `[VERIFIED: execução desta sessão]` | — |
| `build_runner` | codegen | ✓ (dev dep) | ^2.16.1 | — |
| API Django local | só human-check com a API real (não necessário com mock) | não sondado | — | Mock ativo por DI (D-03) |
| Emulador/dispositivo | human-check de fim de fase (layout, ícones) | não sondado | — | Checklist manual ao usuário |
| Repo da web (leitura) | conferir wire | ✓ | branch `main` | — |

**Missing dependencies with no fallback:** nenhuma para o trabalho automatizado.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test + bloc_test ^10.0.0 + mocktail ^1.0.5 `[VERIFIED: pubspec.yaml]` |
| Config file | nenhuma — convenção `test/**_test.dart` |
| Quick run command | `flutter test <arquivos tocados>` |
| Full suite command | `flutter test && flutter analyze` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` antes de testes que dependem de `*.freezed.dart`/`*.g.dart`/DI |
| Baseline | 587 testes verdes (antes da fase) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PERF-01 | Empresa: logomarca (hook por URL), nome, CRECI, rótulo Imobiliária/Corretor autônomo, descrição, contato, chips de cidades; seções vazias somem | widget | `flutter test test/presentation/perfil_empresa_screen_test.dart` | ❌ Wave 0 |
| PERF-01 | Model/entidade da empresa: `""`/`null`→`null`, `tipo` desconhecido→`null`, `corretores_ativos` ignorado, logomarca `javascript:`→`null` | unit | `flutter test test/data/perfil_model_test.dart` | ❌ Wave 0 |
| PERF-02 | Corretor: avatar grande, nome, CRECI, apresentação, contato como `SelectableText`, sem botões de ação | widget | `flutter test test/presentation/perfil_corretor_screen_test.dart` | ⚠ reescrever |
| PERF-02 | Linhas de contato/CRECI (funções puras) | unit | `flutter test test/presentation/apresentacao_perfil_test.dart` | ❌ Wave 0 |
| PERF-03 | Mock filtra por `corretor`/`empresa` derivando do detalhe; paginação sem duplicatas; 339 ausente; vazio; ordenação desc; cursor inválido → `FormatException` | unit | `flutter test test/data/vitrine_anunciante_mock_datasource_test.dart` | ❌ Wave 0 |
| PERF-03 | Cubit: carregando→carregada/vazia/erro; `carregarMais` acumula; falha ao carregar mais mantém a lista; retry explícito | bloc_test | `flutter test test/presentation/vitrine_anunciante_cubit_test.dart` | ❌ Wave 0 |
| PERF-03 | Sliver: cards, rodapé (loading/erro/fim), vazio "Nenhum imóvel anunciado no momento.", toque chama `aoAbrirImovel` | widget | `flutter test test/presentation/perfil_corretor_screen_test.dart test/presentation/perfil_empresa_screen_test.dart` | ❌/⚠ |
| PERF-04 | `PerfilRemoteDataSource` chama `/api/publico/corretores/7/` e `/empresas/3/`, parseia o wire real; 404/500/timeout/corpo inválido | unit (Dio adaptador falso) | `flutter test test/data/perfil_remote_datasource_test.dart test/data/perfil_repository_impl_test.dart` | ❌ Wave 0 |
| PERF-04 | Contrato: exemplos do wire ⊆ allowlist (corretor 9 chaves; empresa 11); linhas da vitrine sem `corretor`/`empresa`/`proprietario` | unit | `flutter test test/data/contrato_perfis_test.dart` | ❌ Wave 0 |
| PERF-04 | Mock de perfis coerente com o detalhe: todo `corretor.id` do detalhe mock existe em `perfis_fixture` (exceto o desativado, deliberado) e todo `empresa_id` resolve | unit | `flutter test test/data/perfil_mock_datasource_test.dart` | ❌ Wave 0 |
| PERF-05 | Cubit: 404→`naoEncontrado` (sem retry); outros→`erro`→`tentarNovamente` | bloc_test | `flutter test test/presentation/perfil_corretor_cubit_test.dart test/presentation/perfil_empresa_cubit_test.dart` | ❌ Wave 0 |
| PERF-05 | Tela: "Este corretor não está mais disponível"/"Esta página não está mais disponível" + "Voltar"; **prévia escondida no 404**; erro → "Tentar de novo" chama o Cubit | widget | idem screens | ❌/⚠ |
| PERF-06 | Toque no `CartaoCorretor` abre `PerfilCorretorScreen` (prévia na hora); fluxo ponta a ponta vitrine→detalhe 42→Marina→perfil completo→cartão empresa→empresa→imóvel→detalhe; corretor 8 → aviso | widget e2e (pilha real mock) | `flutter test test/presentation/detalhe_navegacao_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ⚠ estender |
| API-08 | §12 presente no contrato; DI resolve `PerfilDataSource`→mock, `VitrineAnuncianteDataSource`→mock, Cubits; `parametrosDoAnunciante` ↔ inverso simétricos | unit + grep | `flutter test test/data/vitrine_anunciante_mock_datasource_test.dart test/presentation/detalhe_navegacao_test.dart` ; `grep -n "^## 12\." .planning/phases/01-*/01-CONTRATO-API.md` | ❌ Wave 0 |

### Guardas (grep/gates, molde 04-08)
- `! grep -rnE "try *\{" lib/presentation/perfis` (sem `try/catch` na UI)
- `! grep -rlnE "Mock[D]ataSource|perfis[F]ixture|Fixture\(" lib/presentation lib/domain` (apresentação/domínio nunca conhecem o mock)
- `getIt<` em `lib/presentation/perfis` somente nos dois `abrir*`; `! grep -rn "getIt<" lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` (shim limpo, Pitfall 11)
- `! grep -rnE "url_launcher|launchUrl|tel:|mailto:|wa\.me" lib pubspec.yaml` (D-10)
- `git diff --exit-code pubspec.yaml pubspec.lock` (nenhuma dependência nova)
- `! grep -rnE "Color\(0x|Colors\." lib/presentation/perfis` (sem cor fora do `ColorScheme`)
- `! grep -rnE "go_router" pubspec.yaml`
- `flutter analyze` sem issues

### Sampling Rate
- **Per task commit:** `flutter test <arquivos da task>`
- **Per wave merge:** `flutter test && flutter analyze`
- **Phase gate:** suíte completa verde + guardas vazias antes de `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/data/perfil_model_test.dart`, `perfil_remote_datasource_test.dart`, `perfil_repository_impl_test.dart`, `perfil_mock_datasource_test.dart`, `vitrine_anunciante_mock_datasource_test.dart`, `contrato_perfis_test.dart`
- [ ] `test/presentation/perfil_corretor_cubit_test.dart`, `perfil_empresa_cubit_test.dart`, `vitrine_anunciante_cubit_test.dart`, `perfil_empresa_screen_test.dart`, `apresentacao_perfil_test.dart`
- [ ] Reescrever `perfil_corretor_screen_test.dart`; ajustar 1 teste de `detalhe_imovel_screen_test.dart` e o grupo "fluxo completo"/"DI real" de `detalhe_navegacao_test.dart`
- [ ] Os 2 JSONs de exemplo do wire + §12
- Framework install: nenhum.

### Manual-Only (human-check de fim de fase, D-16)
| Behavior | Requirement | Why Manual | Instrução |
|----------|-------------|------------|-----------|
| Aparência da página (cabeçalho, ícones/rótulos de contato, chips) | PERF-01/02 | julgamento visual | Abrir imóvel 42 → Marina; abrir um imóvel `id%3==2` → Camila (campos vazios) |
| Fluxo 404 à mão | PERF-05 | latência/transição reais | Abrir imóvel cujo corretor é o Rafael (id%3==1) → aviso + Voltar |
| Rolagem + paginação da vitrine do anunciante | PERF-03 | gesto e fluidez | Marina: rolar até o fim (4 páginas) e ver o rodapé "fim da lista" |
| Empresa → imóvel → detalhe → voltar | PERF-06 | fluxo | Corretor → "Ver página do anunciante" → tocar num imóvel |

## Security Domain

`security_enforcement: true`, ASVS nível 1, bloqueio em `high` `[VERIFIED: .planning/config.json]`.

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — (app sem login; endpoints `AllowAny`) |
| V3 Session Management | no | — |
| V4 Access Control | no (no app) | Decisão de publicado/ativo é do servidor (404); o app não decide |
| V5 Input Validation | yes | Todo texto do wire é não confiável: renderizado como texto puro (`Text`/`SelectableText`, sem HTML/Markdown, sem autolink); `textoOuNulo`; ids sempre `int` tipado |
| V6 Cryptography | no | — |
| V7 Error Handling/Logging | yes | Mensagens fixas ao usuário (sem `toString` de exceção/stack); sem `LogInterceptor` |
| V8 Data Protection | yes | Minimização: não parsear `corretores_ativos`; sem cache próprio/armazenamento local dos perfis; sem copiar para o clipboard automaticamente |
| V9 Communications | yes | Release exige HTTPS (cleartext só em debug — verificado nos manifests) |
| V12 Files/Resources | yes | `urlHttpOuNula` em `foto`/`logomarca` (descarta `javascript:`, `file:`, `data:`, relativas) |
| V13 API | yes | Parse defensivo; `TypeError`→`FormatException`; 404 por status; corpo não-objeto → `FormatException` |

### Known Threat Patterns
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| URL maliciosa em `foto`/`logomarca` | Tampering / Info Disclosure | `urlHttpOuNula` + fallback para avatar/placeholder; teste de Model |
| Texto com caracteres de controle/enorme em `apresentacao` | DoS (layout) | Texto puro; aceitar baixa severidade (sem truncar para não ocultar dado); wrap normal |
| `next` da vitrine apontando para outra origem (quando o endpoint real existir) | Tampering/SSRF-like | Repetir a validação de origem + limite de páginas de `CidadeRemoteDataSource` |
| Exposição de PII (e-mail/telefone/WhatsApp/CRECI) | Information Disclosure | Já público por desenho da WEB 02/card; app só mostra o necessário (A6 → confirmar com produto); **sem** ações de contato (APP 06) |
| Enumeração de ids de corretor/empresa | Info Disclosure | Resposta 404 uniforme do servidor; o app não adiciona canal |
| Dado de outra empresa vazando via vitrine | Info Disclosure | Allowlist do §6 mantida no §12 (sem `corretor`/`empresa`/`proprietario` nas linhas); queryset `publicado=True` |

## Plano sugerido de fatiamento (para o planner)

1. **07-01 Rastreabilidade + contrato:** PERF-01..06/API-08 em `REQUIREMENTS.md` + ROADMAP; §12; 2 JSONs de exemplo; `contrato_perfis_test.dart` (escrito antes do código).
2. **07-02 Perfis (domain+data):** entidades, Models (+`textoOuNulo`), `PerfilDataSource` (interface), `PerfilRemoteDataSource`, `PerfilMockDataSource` + `perfis_fixture`, repositório, use cases (TDD: model → datasource Dio → repo → mock).
3. **07-03 Vitrine do anunciante (domain+data+cubit):** `AnuncianteRef`, interface, mock derivado do detalhe, repositório, use case, `VitrineAnuncianteCubit` + estado.
4. **07-04 Cubits de perfil + DI:** `PerfilState<T>`, 2 cubits, `build_runner`, teste "DI real".
5. **07-05 UI do corretor + entrada (PERF-02/05/06):** widgets compartilhados, `abrirPerfilCorretor`, shim, reescrever/ajustar testes impactados.
6. **07-06 UI da empresa + e2e + guardas + human-check (PERF-01/03):** `abrirPerfilEmpresa`, tela da empresa, e2e vitrine→…→empresa→imóvel, guardas grep.

### Arquivos **existentes** que a fase precisa tocar (sinalizar ao colega da Phase 5)
| Arquivo | Mudança | Risco de conflito |
|---------|---------|-------------------|
| `lib/di/injection.config.dart` (gerado) | regenerar | **alto** (Phase 5 também) → resolver por `build_runner` |
| `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` | substituir por `export '../perfis/perfil_corretor_screen.dart';` | baixo |
| `.planning/…/01-CONTRATO-API.md`, `REQUIREMENTS.md`, `ROADMAP.md` | §12 e IDs | baixo (docs) |
| `test/presentation/perfil_corretor_screen_test.dart`, `detalhe_imovel_screen_test.dart` (1 teste), `detalhe_navegacao_test.dart` | reescrever/estender | baixo |
| **Não tocar:** `detalhe_imovel_screen.dart`, `cartao_corretor.dart`, `vitrine_*`, `imovel_*_datasource.dart`, `imovel_*_repository*`, `modulo_rede.dart`, `imoveis_*_fixture.dart` | — | — |

## Sources

### Primary (HIGH confidence — lidos nesta sessão)
- Web `main` (`C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web`): `contas/api/views.py`, `contas/api/serializers.py`, `contas/api/urls_publico.py`, `contas/models.py` (campos de perfil, `dados_perfil_publico`), `empresas/api/views.py`, `empresas/api/serializers.py`, `empresas/api/urls_publico.py`, `empresas/models.py` (`Tipo`, campos), `config/urls.py`, `imoveis/models.py` (`corretor_responsavel`, `publicado`), `core/models.py` (`EmpresaOwnedModel.empresa`), `contas/tests.py` (200/404 públicos).
- App: `lib/presentation/detalhe_imovel/{perfil_corretor_screen,detalhe_imovel_screen,detalhe_imovel_cubit,detalhe_imovel_state}.dart`, `widgets/{cartao_corretor,secoes_detalhe}.dart`, `lib/presentation/comum/imagem_rede.dart`, `lib/presentation/vitrine/{vitrine_cubit,vitrine_state,vitrine_screen,apresentacao_imovel}.dart`, `widgets/{imovel_card,foto_capa_imovel}.dart`, `lib/data/datasources/{cidade_remote,imovel,imovel_mock,imovel_detalhe,imovel_detalhe_mock,parametros_consulta_imoveis}*.dart`, `lib/data/repositories/{imovel,imovel_detalhe,cidade}_repository_impl.dart`, `lib/data/models/{imovel,detalhe_imovel,imoveis_envelope,cidade,url_segura}*.dart`, `lib/data/mocks/{imoveis,imoveis_detalhe}_fixture.dart`, `lib/domain/**` (entidades, repositórios, use cases), `lib/di/{injection,modulo_rede,injection.config}.dart`, `lib/core/result.dart`, `pubspec.yaml`, `analysis_options.yaml`, `android/**/AndroidManifest.xml`.
- Testes existentes: `test/presentation/{perfil_corretor_screen,detalhe_navegacao,detalhe_imovel_screen}_test.dart`, `test/data/{cidade_remote_datasource,imovel_detalhe_repository_impl,contrato_detalhe}_test.dart`.
- Planejamento: `07-CONTEXT.md`, `07-CARD-APP07.md`, `REQUIREMENTS.md`, `STATE.md`, `ROADMAP.md`, `01-CONTRATO-API.md` (§3–§11), `04-VALIDATION.md`, `04-08-PLAN.md` (guardas).
- Flutter SDK: `packages/flutter_test/lib/src/finders.dart` (`find.text` casa `EditableText`).
- Execução: `flutter test` (587 verdes), `flutter --version` (3.47.9).

### Secondary (MEDIUM)
- `07-CARD-APP07.md` para afirmações sobre branches da web não lidas por mim (WEB-09 expõe `corretor_responsavel`; WEB 10 monta a vitrine em view HTML) — `[CITED: 07-CARD-APP07.md]`.

### Tertiary (LOW)
- Comportamento do `injectable`/`get_it` com duas implementações (A1) — não executado.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — nenhuma dependência nova; versões lidas do `pubspec.yaml`
- Wire dos perfis: HIGH — serializers/views/models lidos; testes da web confirmam 200/404
- Architecture: HIGH — copia padrões do repo verificados em código; MEDIUM no detalhe do DI de troca (A1)
- §12 / vitrine do anunciante: MEDIUM — depende de sign-off da web
- Pitfalls: HIGH — derivados de código e de testes existentes

**Research date:** 2026-11-08
**Valid until:** ~30 dias, ou até a Phase 5 mergear (muda DI/fixtures) o que vier primeiro
