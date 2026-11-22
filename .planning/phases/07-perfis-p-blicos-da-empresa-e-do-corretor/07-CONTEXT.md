# Phase 7: Perfis Públicos da Empresa e do Corretor - Context

**Gathered:** 2026-11-08
**Status:** Ready for planning
**Source:** PRD Express Path (.planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-CARD-APP07.md)

<domain>
## Phase Boundary

Card APP 07 (tarefa A07). O visitante vê quem está anunciando para saber com quem vai negociar:
a página do corretor (foto, CRECI, apresentação, contato) e a página da empresa (logomarca,
CRECI, apresentação, contato, cidades de atuação), as duas com a vitrine dos imóveis daquele
anunciante. Chega-se ao perfil do corretor pela página do imóvel (cartão do corretor, DET-05),
e à página da empresa pelo perfil do corretor. Corretor desativado mostra aviso, nunca tela
quebrada.

Os perfis já existem na API (WEB 02, `main` do repo da web): `GET /api/publico/corretores/{id}/`
e `GET /api/publico/empresas/{id}/`. A vitrine do anunciante **não tem endpoint na web**: esta
fase escreve o adendo de contrato (§12) e constrói sobre mock que segue esse contrato, como as
fases 2–4 fizeram.

Fora do escopo: botões de WhatsApp/telefone/e-mail e registro do contato (APP 06 / CON-01),
login e área do corretor (APP 08), área do gestor (APP 12), favoritos, mapa e qualquer mudança
no Django.

</domain>

<decisions>
## Implementation Decisions

### Critérios de aceite do card (travados — checklist da fase)
- **AC-1:** Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação.
- **AC-2:** Página do corretor com foto, CRECI, apresentação e contato.
- **AC-3:** As duas mostram a vitrine dos imóveis daquele anunciante.
- **AC-4:** Os dados vêm da API dos perfis públicos.
- **AC-5:** Perfil de corretor desativado mostra aviso, e não tela quebrada.
- **AC-6:** Dá para chegar ao perfil a partir da página do imóvel.

### Dados e contrato
- **D-01:** Perfis do corretor e da empresa consomem os endpoints da WEB 02 exatamente como
  estão (formatos no `07-CARD-APP07.md`), sem pedir mudança no Django. Models freezed +
  json_serializable, entidades de domínio próprias (`PerfilCorretor`, `PerfilEmpresa`), parse
  defensivo: `""` e `null` viram `null` na camada de dados (os campos opcionais do Django são
  `blank=True` e chegam como string vazia); URLs de foto/logomarca passam por `urlHttpOuNula`
  (F4, V12/V13). Corretor: `id, empresa_id, foto, nome, email, creci, telefone, whatsapp,
  apresentacao`. Empresa: `id, tipo (IMOBILIARIA|AUTONOMO), razao_social_ou_nome, creci,
  telefone, whatsapp, email, descricao, logomarca, cidades_atuacao[{id,nome,uf}],
  corretores_ativos[...]` (o app pode ignorar `corretores_ativos` nesta fase).
- **D-02:** Vitrine do anunciante = **adendo §12** em `01-CONTRATO-API.md`: o mesmo
  `GET /api/publico/imoveis/` da lista (mesmo envelope com cursor `results/next/previous`,
  mesmos campos do card do §3, mesmo serializer público com allowlist do §6) aceitando
  `empresa=<id>` ou `corretor=<id>` no lugar de `cidade`; só imóveis publicados; ordenação
  padrão "mais recentes". Para sign-off da frente web, como §9–§11.
  — **Reversibility:** costly — contrato compartilhado com a web.
- **D-03:** Mesmo padrão da API-04/F4: DataSource **real (Dio)** para os perfis da WEB 02 e
  DataSource **mock** sobre JSON de wire, trocáveis por DI. Enquanto detalhe e lista forem
  mock (até a Phase 5), o DI registra o **mock** dos perfis, com fixtures coerentes com os
  corretores que o mock do detalhe já devolve (ids batendo), senão o corretor do detalhe mock
  cairia em 404 na API real. A real fica pronta e testada com Dio mockado; a troca é uma linha
  de DI, junto com a Phase 5. A vitrine do anunciante é só mock (não há endpoint), parseada pelo
  mesmo Model da lista (`ImoveisEnvelopeModel`).
- **D-04:** Erros tipados só na camada de dados (F4/D-17, 04-03): 404 → exceção de domínio de
  "perfil não encontrado"; presentation decide pelo tipo, sem `try/catch` na UI.

### Navegação e entrada
- **D-05:** Substitui a F4/D-15 (perfil stub com o objeto em memória): tocar no cartão do
  corretor na página do imóvel abre o perfil **buscando na API pelo `id`** do corretor; a
  abertura mostra na hora a **prévia** que o detalhe já tem (nome + foto, como F4/D-16) e
  completa quando a resposta chega.
- **D-06:** Página da empresa aberta a partir do perfil do corretor (usa `empresa_id`), por um
  cartão "Ver imobiliária" ("Ver página do anunciante" para `tipo == AUTONOMO` — texto é
  discrição). Sem atalho direto da página do imóvel (o contrato do detalhe não expõe a empresa —
  §11.5 g).
- **D-07:** `Navigator.push` + `MaterialPageRoute` (F4/D-18), sem go_router. Tocar num imóvel
  da vitrine do anunciante abre a página do imóvel pelo fluxo existente (`abrirDetalheImovel`).

### Layout (Material 3, `ColorScheme.fromSeed` verde e branco, `Theme.of(context).textTheme`)
- **D-08:** Corretor, de cima para baixo: foto grande (`AvatarCorretor`) + nome + CRECI →
  apresentação → contato → cartão da empresa (D-06) → "Imóveis de {nome}".
- **D-09:** Empresa: logomarca + nome + CRECI (+ "Imobiliária"/"Corretor autônomo") →
  apresentação (`descricao`) → contato → cidades de atuação (chips) → "Imóveis de {nome}".
- **D-10:** Contato = telefone, WhatsApp e e-mail **como texto** selecionável, com ícone.
  **Sem botões de ligar/WhatsApp/e-mail e sem registrar contato** (APP 06 / CON-01, regra no
  servidor). Nenhuma dependência nova (sem `url_launcher`).
- **D-11:** Campo vazio/nulo omite a linha; seção vazia some inteira (F4/D-14).
- **D-12:** Vitrine do anunciante reaproveita o `ImovelCard` e o padrão de lista paginada por
  cursor com rodapés loading/erro/fim (F2/VIT-05). Vazio: "Nenhum imóvel anunciado no
  momento." Página única rolável (`CustomScrollView`: cabeçalho do perfil + lista em sliver).
- **D-13:** Reaproveitar `AvatarCorretor`, `ImagemRede`, `Card.outlined` (como
  `CartaoCorretor`) e a formatação de preço da vitrine. Nenhuma cor fora do `ColorScheme`.

### Estados e erros
- **D-14:** Cubits próprios (`PerfilCorretorCubit`, `PerfilEmpresaCubit`; a vitrine do
  anunciante pode ter o seu) com estados freezed explícitos Loading/Success/Failure.
- **D-15:** 404 do corretor: "Este corretor não está mais disponível" + "Voltar"; 404 da
  empresa: "Esta página não está mais disponível" + "Voltar"; demais erros: "Tentar de novo".
  Mesmo desenho do F4/D-17 (DET-06).
- **D-16:** Sem `/gsd-ui-phase` (mesmo caminho do F4/D-20): D-08..D-13 são o contrato de UI;
  ícones e rótulos confirmados no human-check de fim de fase.

### Rastreabilidade
- **D-17:** Novos IDs em `REQUIREMENTS.md` (seção "Perfis públicos (APP07)"), mapeados para a
  Phase 7 no ROADMAP (`**Requirements**:`) e na tabela de rastreabilidade, como o 04-02 fez:
  PERF-01 (AC-1), PERF-02 (AC-2), PERF-03 (AC-3), PERF-04 (AC-4), PERF-05 (AC-5),
  PERF-06 (AC-6) e API-08 (adendo §12 + DataSource trocável da vitrine do anunciante).
  Ajustar a nota do v2 que diz "cards 10–11" só se for necessário para não contradizer.

### Claude's Discretion
- Ícones e textos exatos (rótulos de contato, título da seção de imóveis, texto do cartão da
  empresa); formato do CRECI (mostrar como vem).
- Estrutura de pastas (sugestão: `lib/presentation/perfis/`, arquivos novos em `data/` e
  `domain/`), mexendo o mínimo em arquivos existentes — há trabalho paralelo da Phase 5 em outra
  branch (merge virá depois).
- Fixtures: pelo menos um corretor completo, um com campos vazios, um id reservado para 404
  (desativado); uma empresa IMOBILIARIA e uma AUTONOMO; vitrine do anunciante com e sem imóveis
  e com mais de uma página.
- Se a vitrine do anunciante usa Cubit próprio ou fica dentro do Cubit do perfil.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Fonte da fase
- `.planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-CARD-APP07.md` — texto oficial do card, formatos de wire da WEB 02, lacunas da web e decisões

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — §3 campos da lista, §6 allowlist pública, §9–§10 adendos, §11 detalhe (inclui §11.5 a e g: slug e exposição do corretor); recebe o novo §12
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json` — wire da lista (base da vitrine do anunciante)
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json` — wire do detalhe (de onde vem o `corretor.id`)

### API real da web (repo irmão, branch `main`; NÃO está em `../imoveis-aqui/Web`)
- `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web\contas\api\views.py` — `CorretorPublicoAPIView`
- `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web\contas\api\serializers.py` — `CorretorPublicoSerializer`
- `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web\contas\models.py` — `Usuario.dados_perfil_publico`
- `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web\empresas\api\views.py` e `serializers.py` — `EmpresaPublicaAPIView`, `EmpresaPublicaSerializer`

### Decisões anteriores
- `.planning/phases/04-pagina-do-imovel-galeria-e-dados-da-natureza/04-CONTEXT.md` — D-14 (nulo omite linha), D-15 (stub de perfil, agora substituído), D-16 (prévia), D-17 (404 x tentar de novo), D-18 (navegação), D-20 (sem ui-phase)
- `.planning/phases/04-pagina-do-imovel-galeria-e-dados-da-natureza/04-PATTERNS.md` — padrões de arquivo da página do imóvel
- `.planning/phases/02-vitrine-lista-busca-e-ordena-o/02-CONTEXT.md` — lista paginada por cursor, mock sobre wire, Dio com `API_BASE_URL`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart` — `AvatarCorretor` e `CartaoCorretor` (entrada do perfil)
- `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` — `abrirPerfilCorretor` + tela stub (D-15 da F4) a ser substituída/evoluída
- `lib/presentation/comum/imagem_rede.dart` — imagem com cache e gancho de teste `construirImagemDeRede`
- `lib/presentation/vitrine/widgets/imovel_card.dart` e `apresentacao_imovel.dart` — card e formatação de preço
- `lib/data/models/url_segura.dart` — `urlHttpOuNula`
- `lib/data/datasources/cidade_remote_datasource.dart` + `lib/di/modulo_rede.dart` — padrão de DataSource real com Dio
- `lib/data/datasources/imovel_mock_datasource.dart`, `lib/data/mocks/imoveis_fixture.dart`, `lib/data/mocks/imoveis_detalhe_fixture.dart` — padrão de mock sobre wire; o detalhe gera corretores por `id % 3`

### Established Patterns
- Clean Architecture data/domain/presentation; Model freezed + json_serializable; DI com injectable (`@LazySingleton(as: ...)`), `lib/di/injection.config.dart` gerado por build_runner
- Mock serve mapas de wire e parseia pelo mesmo Model que o remoto vai usar
- Cubit com estado freezed imutável; erros tipados na camada de dados
- Widgets com gancho `@visibleForTesting construirImagemDeRede` nas telas
- Abertura de tela que resolve o Cubit no DI num único ponto (`abrirDetalheImovel`)

### Integration Points
- `CartaoCorretor.aoTocar` na página do imóvel → novo fluxo de abertura do perfil por id
- `ImovelCard` / `abrirDetalheImovel` → imóveis da vitrine do anunciante abrem a página do imóvel
- `lib/di/` → registrar DataSources (mock ativo) e Cubits novos

</code_context>

<specifics>
## Specific Ideas

- Os 6 critérios do card são o checklist de aceite (AC-1..AC-6, ROADMAP Phase 7).
- AC-4 fica atendido de fato pela DataSource real (Dio) testada contra os formatos da WEB 02,
  e ativo no app por DI junto com a Phase 5 (D-03).
- Pendências para a frente web (registrar no §12 / como PENDENTE WEB): endpoint da vitrine do
  anunciante; checagem de empresa ativa na API do corretor (WEB 02).

</specifics>

<deferred>
## Deferred Ideas

- Botões de contato e registro do contato na API: APP 06 (CON-01).
- Lista "corretores da imobiliária" na página da empresa (`corretores_ativos`): não pedido pelo card.
- Login/área do corretor: APP 08. Área do gestor: APP 12.
- Deep link para perfis e go_router.

</deferred>

---

*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Context gathered: 2026-11-08 via PRD Express Path*
