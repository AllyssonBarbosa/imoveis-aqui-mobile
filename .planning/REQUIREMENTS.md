# Requirements: Imóveis Aqui — App (Vitrine)

**Defined:** 2026-09-21
**Core Value:** A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com busca e filtro resolvidos no servidor — o mesmo dado e a mesma regra do site, nunca recalculados no aparelho.

## v1 Requirements

Requisitos da primeira entrega (tarefas APP01, APP02, APP03, APP04, APP07, APP08 + os endpoints da API que as habilitam). Cada um mapeia para uma fase do roadmap.

### Localização e escolha da cidade (APP01)

- [x] **LOC-01**: Na primeira abertura, o app pede a permissão de localização.
- [x] **LOC-02**: Autorizada, o app descobre a cidade (reverse geocoding) e já entra nela; se a cidade descoberta não estiver entre as atendidas, cai no fallback de escolha em vez de travar.
- [x] **LOC-03**: Recusada ou bloqueada — caminho normal, não um beco — o app mostra a lista de cidades atendidas para o visitante escolher.
- [x] **LOC-04**: A cidade escolhida é guardada no aparelho (sem conta e sem senha) e reusada nas próximas aberturas.
- [x] **LOC-05**: O visitante troca de cidade num toque no topo da tela; a nova escolha passa a ser a guardada.
- [x] **LOC-06**: Os desfechos de localização são tratados como estados explícitos (autorizado / recusado / bloqueado-para-sempre / serviço-desligado / cidade-não-atendida), cada um com UI própria — nunca como exceção genérica.

### Vitrine da cidade (APP02)

- [x] **VIT-01**: A vitrine mostra a lista de imóveis da cidade escolhida.
- [x] **VIT-02**: Cada card mostra foto de capa, título, preço, natureza, bairro e quartos, em formato consistente entre os cards.
- [x] **VIT-03**: O visitante busca imóveis por texto, com debounce e estado de "nenhum resultado".
- [x] **VIT-04**: O visitante ordena por preço, área ou mais recentes.
- [x] **VIT-05**: A lista carrega paginada (scroll infinito), com estados de loading, vazio, erro/retry e fim-da-lista.
- [x] **VIT-06**: A lista de cidades passa a vir da API (`GET /cidades`), substituindo a lista fixa de APP01.

### Filtros da vitrine (APP03)

- [x] **FIL-01**: Filtro por finalidade (venda / aluguel).
- [x] **FIL-02**: Filtro por natureza (casa, apartamento, terreno, lote).
- [x] **FIL-03**: Filtros por faixa de preço, quartos, suítes e vagas.
- [x] **FIL-04**: Filtros por bairro, faixa de área e características.
- [x] **FIL-05**: Os filtros são aplicados no servidor — a lista vem pronta da API; o app nunca filtra o acervo localmente.
- [x] **FIL-06**: Filtros ativos aparecem como chips acima da lista, com aplicar e limpar; mudar filtro ou ordenação reseta a paginação (sem cards duplicados ou embaralhados).

### Página do imóvel (APP04)

- [x] **DET-01**: Tocar num card da vitrine abre a página do imóvel; a abertura mostra de imediato a prévia que a vitrine já tem (capa, título, preço) e carrega o detalhe.
- [x] **DET-02**: A galeria mostra todas as fotos do imóvel começando pela capa, com contador "N/M"; o toque abre um visualizador em tela cheia com swipe e pinch-zoom; sem fotos mostra o placeholder, sem contador.
- [x] **DET-03**: A página mostra os preços de venda e/ou aluguel, condomínio e IPTU exatamente como vieram da API (valores formatados, nunca calculados no app).
- [x] **DET-04**: A página mostra os dados da natureza — casa (terreno, área construída, área livre), terreno (frente, fundo, topografia), apartamento (dados do prédio) e lote (quadra e loteamento); campo nulo omite a linha e seção vazia some.
- [x] **DET-05**: A página mostra descrição, características e o corretor responsável com foto; tocar no corretor abre a tela de perfil do corretor, cujo conteúdo completo é do APP 07.
- [x] **DET-06**: Imóvel não encontrado (404) mostra "Este imóvel não está mais disponível" com volta à vitrine; os demais erros mostram "Tentar de novo".

### Perfis públicos (APP07)

- [x] **PERF-01**: A página da empresa mostra logomarca, CRECI, apresentação, contato e cidades de atuação.
- [x] **PERF-02**: A página do corretor mostra foto, CRECI, apresentação e contato.
- [x] **PERF-03**: As páginas da empresa e do corretor mostram a vitrine dos imóveis daquele anunciante (lista paginada por página — `GET /api/publico/corretores/<id>/imoveis/` e `/api/publico/empresas/<id>/imoveis/` —, recortada e ordenada no servidor).
- [x] **PERF-04**: Os dados dos perfis vêm da API dos perfis públicos (`GET /api/publico/corretores/{id}/` e `GET /api/publico/empresas/{id}/`, WEB 02) por DataSource trocável, sem nada montado ou decidido no app.
- [x] **PERF-05**: Perfil de corretor desativado (404) mostra o aviso "Este corretor não está mais disponível", e não uma tela quebrada.
- [x] **PERF-06**: Dá para chegar ao perfil do corretor a partir da página do imóvel e à página da empresa a partir do perfil do corretor.

### Login e acervo (APP08)

- [ ] **AUTH-01**: O corretor entra no app com e-mail e senha, no mesmo aplicativo (sem app separado); o token vem de `POST /api/auth/login/`.
- [ ] **AUTH-02**: A sessão fica guardada no aparelho em `flutter_secure_storage`; Sair apaga o token do aparelho mesmo se a rede falhar e o revoga no servidor (`POST /api/auth/sair/`).
- [ ] **AUTH-03**: O erro de login é genérico: o app mostra o texto fixo "E-mail ou senha inválidos." e nenhum texto revela se o e-mail existe; limite de tentativas (429) e falha de rede têm mensagens próprias, vindas de falhas tipadas na camada de dados.
- [ ] **AUTH-04**: Sem login o app continua abrindo direto na vitrine; o botão do topo mostra "Entrar" ou "Meu acervo" conforme a sessão guardada, sem atrasar a abertura.
- [ ] **AUTH-05**: Quem entra vê a área do seu papel, lido de `GET /api/auth/eu/`: o corretor vai ao acervo; gestor e administrador veem uma tela de aviso com Sair; sessão expirada (401) volta ao login com aviso.
- [ ] **AUTH-06**: O servidor limita as tentativas de login por e-mail e por IP (429 com `Retry-After`), sem revelar se o e-mail existe.
- [ ] **ACV-01**: O corretor vê o acervo — os imóveis dele e os da imobiliária — numa lista paginada com rolagem infinita, em cartão compacto (código, título, preço, situação e a marca "Seu" calculada no servidor).
- [ ] **ACV-02**: Busca por código ou título e filtro por situação (Todas, Disponível, Reservado, Vendido, Alugado) resolvidos no servidor com a regra do painel do site (`FiltroImovelForm`); busca e situação se combinam.
- [ ] **ACV-03**: Imóvel de outra empresa não aparece no acervo nem forçando a consulta (busca, situação, parâmetros extras ou id), garantido e testado no Django; gestor e administrador não acessam a lista e sem token a resposta é 401.
- [ ] **ACV-04**: O toque num cartão do acervo só abre a página do imóvel quando o servidor diz que ele está na vitrine (`na_vitrine`); senão o cartão não reage.
- [ ] **API-09**: O §14 de `01-CONTRATO-API.md` congela login, "quem sou eu", Sair e a lista do acervo (parâmetros, envelope, as 10 chaves do item, 400/401/403/404/429 e o efeito do Sair nos outros aparelhos), com fixtures capturadas do Django e testes de contrato nos dois repositórios.
- [ ] **API-10**: A web entrega, com testes, `GET /api/auth/eu/`, `POST /api/auth/sair/`, o limite de tentativas no login e a lista do acervo paginada, filtrada e enxuta em `GET /api/imoveis/`.

### API pública (endpoints que o app consome)

- [x] **API-01**: Auditar a API atual e congelar por escrito o contrato de `/cidades` e `/imoveis` (nomes de campos, enums, nomes dos params de filtro, envelope de paginação) antes de codar APP02/APP03 ou o endpoint real.
- [x] **API-02**: `GET /api/publico/cidades/` — endpoint público sem token, expõe as cidades atendidas para a vitrine (app e site).
- [x] **API-03**: `GET /api/publico/cidades/<id>/imoveis/?filtros` — endpoint público sem token com busca, ordenação, filtros e paginação server-side; retorna só imóveis publicados; usa serializer público com allowlist (sem proprietário/documento/dado interno) e não quebra o isolamento multitenant.
- [x] **API-04**: A camada de dados do app é trocável (DataSource mock/fixture honrando o contrato → DataSource real por DI), permitindo desenvolver APP02/APP03 antes de o endpoint real de imóveis existir.
- [x] **API-06**: O contrato de `GET /api/publico/imoveis/{id}/` fica congelado por escrito no §11 do contrato da API + `imovel_detalhe.example.json`, e o app o consome por DataSource trocável (mock honrando o contrato).
- [x] **API-07**: Endpoint real `GET /api/publico/imoveis/{id}/` público, só imóveis publicados, 404 igual para inexistente e não publicado, serializer com a allowlist do §11, e troca da DataSource do detalhe por DI.
- [x] **API-08**: A vitrine do anunciante fica escrita como §13 do contrato (rotas `GET /api/publico/corretores/<id>/imoveis/` e `/api/publico/empresas/<id>/imoveis/`, `PageNumberPagination`, allowlist e limite de taxa da API pública) e o app a consome pela DataSource real (Dio), entregue pelo Django.

## v2 Requirements

Reconhecidos, mas fora desta entrega (outras tarefas do app, feitas depois / por outros colegas).

### App — próximas tarefas

- **CON-01**: Contato com o corretor por WhatsApp com mensagem montada pelo servidor e gravação do contato (card 9).
- **FAV-01**: Favoritos guardados no aparelho.
- **LOG-01**: Áreas logadas do app — área do corretor e área do gestor (cards 10–11).
- **API-05**: Endpoint de result-count para prévia "Ver N imóveis" no botão aplicar (diferencial, depende de custo de contagem barato).

## Out of Scope

Excluídos de propósito. Documentados para evitar scope creep.

| Feature | Reason |
|---------|--------|
| Site público / painel de gestão web | Outra frente da equipe (outros colegas) |
| Model de Imóvel / endereço / fotos / naturezas / loteamento / publicação | Construídos na frente web (E2) por colegas; é dependência minha, não entrega minha — eu só exponho o publicado via API pública |
| Contratos, parcelas, baixa (card 12) | Entrega E3, atrás de login, fora do app da vitrine |
| Filtragem no cliente | Não escala e gasta o dado do visitante; regra do projeto é filtrar no servidor |
| PostgreSQL, Dockerização, volume de imagens | Infra do backend (repo da API); o app só guarda a cidade escolhida localmente |
| Mapa na busca / push / chat no app | Diferenciais do infográfico, explicitamente "não requisitos" |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| LOC-01 | Phase 1 | Complete |
| LOC-02 | Phase 1 | Complete |
| LOC-03 | Phase 1 | Complete |
| LOC-04 | Phase 1 | Complete |
| LOC-05 | Phase 1 | Complete |
| LOC-06 | Phase 1 | Complete |
| API-01 | Phase 1 | Complete |
| VIT-01 | Phase 2 | Complete |
| VIT-02 | Phase 2 | Complete |
| VIT-03 | Phase 2 | Complete |
| VIT-04 | Phase 2 | Complete |
| VIT-05 | Phase 2 | Complete |
| VIT-06 | Phase 2 | Complete |
| API-02 | Phase 2 | Complete |
| API-04 | Phase 2 | Complete |
| FIL-01 | Phase 3 | Complete |
| FIL-02 | Phase 3 | Complete |
| FIL-03 | Phase 3 | Complete |
| FIL-04 | Phase 3 | Complete |
| FIL-05 | Phase 3 | Complete |
| FIL-06 | Phase 3 | Complete |
| DET-01 | Phase 4 | Complete |
| DET-02 | Phase 4 | Complete |
| DET-03 | Phase 4 | Complete |
| DET-04 | Phase 4 | Complete |
| DET-05 | Phase 4 | Complete |
| DET-06 | Phase 4 | Complete |
| API-06 | Phase 4 | Complete |
| API-03 | Phase 5 | Complete |
| API-07 | Phase 5 | Complete |
| PERF-01 | Phase 7 | Complete |
| PERF-02 | Phase 7 | Complete |
| PERF-03 | Phase 7, Phase 07.1 | Complete |
| PERF-04 | Phase 7, Phase 07.1 | Complete |
| PERF-05 | Phase 7 | Complete |
| PERF-06 | Phase 7 | Complete |
| API-08 | Phase 7, Phase 07.1 | Complete |
| AUTH-01 | Phase 8 | Pending |
| AUTH-02 | Phase 8 | Pending |
| AUTH-03 | Phase 8 | Pending |
| AUTH-04 | Phase 8 | Pending |
| AUTH-05 | Phase 8 | Pending |
| AUTH-06 | Phase 8 | Pending |
| ACV-01 | Phase 8 | Pending |
| ACV-02 | Phase 8 | Pending |
| ACV-03 | Phase 8 | Pending |
| ACV-04 | Phase 8 | Pending |
| API-09 | Phase 8 | Pending |
| API-10 | Phase 8 | Pending |

**Coverage:**

- v1 requirements: 49 total
- Mapped to phases: 49 (roadmap complete)
- Unmapped: 0

---
*Requirements defined: 2026-09-21*
*Last updated: 2026-11-20 after Phase 8 planning (AUTH-01..06, ACV-01..04, API-09 and API-10 registered for card APP 08, D-16)*
