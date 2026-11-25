# Requirements: Imóveis Aqui — App (Vitrine)

**Defined:** 2026-09-21
**Core Value:** A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com busca e filtro resolvidos no servidor — o mesmo dado e a mesma regra do site, nunca recalculados no aparelho.

## v1 Requirements

Requisitos da primeira entrega (tarefas APP01, APP02, APP03, APP04, APP07, APP08, APP09 + os endpoints da API que as habilitam). Cada um mapeia para uma fase do roadmap.

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

- [x] **AUTH-01**: O corretor entra no app com e-mail e senha, no mesmo aplicativo (sem app separado); o token vem de `POST /api/auth/login/`.
- [x] **AUTH-02**: A sessão fica guardada no aparelho em `flutter_secure_storage`; Sair apaga o token do aparelho mesmo se a rede falhar e o revoga no servidor (`POST /api/auth/sair/`).
- [x] **AUTH-03**: O erro de login é genérico: o app mostra o texto fixo "E-mail ou senha inválidos." e nenhum texto revela se o e-mail existe; limite de tentativas (429) e falha de rede têm mensagens próprias, vindas de falhas tipadas na camada de dados.
- [x] **AUTH-04**: Sem login o app continua abrindo direto na vitrine; o botão do topo mostra "Entrar" ou "Meu acervo" conforme a sessão guardada, sem atrasar a abertura.
- [x] **AUTH-05**: Quem entra vê a área do seu papel, lido de `GET /api/auth/eu/`: o corretor vai ao acervo; gestor e administrador veem uma tela de aviso com Sair; sessão expirada (401) volta ao login com aviso.
- [x] **AUTH-06**: O servidor limita as tentativas de login por e-mail e por IP (429 com `Retry-After`), sem revelar se o e-mail existe.
- [x] **ACV-01**: O corretor vê o acervo — os imóveis dele e os da imobiliária — numa lista paginada com rolagem infinita, em cartão compacto (código, título, preço, situação e a marca "Seu" calculada no servidor).
- [x] **ACV-02**: Busca por código ou título e filtro por situação (Todas, Disponível, Reservado, Vendido, Alugado) resolvidos no servidor com a regra do painel do site (`FiltroImovelForm`); busca e situação se combinam.
- [x] **ACV-03**: Imóvel de outra empresa não aparece no acervo nem forçando a consulta (busca, situação, parâmetros extras ou id), garantido e testado no Django; gestor e administrador não acessam a lista e sem token a resposta é 401.
- [x] **ACV-04**: O toque num cartão do acervo só abre a página do imóvel quando o servidor diz que ele está na vitrine (`na_vitrine`); senão o cartão não reage. Superado na Phase 9 pelo SIT-07: todo cartão abre a tela de gestão e "Ver na vitrine" só aparece com `na_vitrine`.
- [x] **API-09**: O §14 de `01-CONTRATO-API.md` congela login, "quem sou eu", Sair e a lista do acervo (parâmetros, envelope, as 10 chaves do item, 400/401/403/404/429 e o efeito do Sair nos outros aparelhos), com fixtures capturadas do Django e testes de contrato nos dois repositórios.
- [x] **API-10**: A web entrega, com testes, `GET /api/auth/eu/`, `POST /api/auth/sair/`, o limite de tentativas no login e a lista do acervo paginada, filtrada e enxuta em `GET /api/imoveis/`.

### Situação do imóvel (APP09)

Card APP 09 (tarefa A09). SIT-01..SIT-06 cobrem os critérios AC-1..AC-6 do card; SIT-07 é a tela de gestão que os habilita.

- [x] **SIT-01**: O corretor troca a situação do imóvel (Disponível, Reservado, Vendido, Alugado) numa folha com chips de escolha única (a situação atual desabilitada) e observação opcional; a data é a do servidor (`alterado_em`), mostrada como "Data: hoje" na folha e com data e hora no histórico (AC-1).
- [x] **SIT-02**: A troca é pedida à API (`POST /api/imoveis/{id}/situacao/`) e o app não altera nada localmente: depois do 200 a folha fecha, aparece "Situação alterada para <situação>." e a tela relê o imóvel e o histórico da API (AC-2).
- [x] **SIT-03**: A tela de gestão do imóvel mostra o histórico das mudanças na ordem do servidor (mais recente primeiro): de → para, data e hora, quem mudou e a observação; sem mudanças mostra "Nenhuma mudança ainda — disponível desde o cadastro." (AC-3).
- [x] **SIT-04**: Recusa do servidor (400/403) mostra a mensagem do servidor na folha, que continua aberta com a observação, e a situação exibida não muda; rede, tempo esgotado e 5xx mostram "Não foi possível mudar a situação agora. Tente de novo."; 404 mostra um texto fixo; 401 volta ao login com "Sua sessão terminou. Entre de novo." (AC-4).
- [x] **SIT-05**: A vitrine pública reflete a mudança na consulta seguinte (regra única `na_vitrine` no servidor, provada no UAT) e o Meu acervo recarrega da API ao voltar da tela de gestão quando houve mudança, mantendo a busca e a situação escolhidas (AC-5).
- [x] **SIT-06**: Só o corretor responsável muda a situação pelo app (o gestor muda pela web; a área dele no app é da APP-12): o botão "Mudar situação" só aparece com `pode_mudar_situacao` calculado pelo Django, e quem forçar recebe a recusa do servidor (403), testada no Django (AC-6).
- [x] **SIT-07**: Todo cartão do Meu acervo abre a tela de gestão do imóvel (cabeçalho, situação atual com "desde" e histórico); "Ver na vitrine" só aparece quando o servidor diz `na_vitrine` e some depois de uma mudança até a tela ser reaberta. Supera o ACV-04 da Phase 8.
- [x] **API-11**: O §16 de `01-CONTRATO-API.md` congela `GET /api/imoveis/{id}/` (as 9 chaves que o app lê), `POST /api/imoveis/{id}/situacao/` (corpo, 200, 400, 401, 403, 404) e `GET /api/imoveis/{id}/historico/`, com fixtures capturadas da API real (código da `origin/main` da web) e teste de contrato no app.
- [x] **API-12**: (D-08 e D-19 da Phase 9) A web ganha, na branch `feat/APP09` criada da `origin/main` num worktree separado (`../imoveis-aqui-APP09`; o clone `../imoveis-aqui` não troca de branch), os testes que faltam para as rotas do corretor — 400 de mesma situação, situação inválida e contrato assinado, 401 sem token, 404 de histórico/detalhe de outra empresa, ordem do histórico e 403 antes de 400 —, sem mudança de código de produção nem push.

### Caixa de contatos (APP10)

Na Fase 10, API-13 e API-14 foram registrados como API-11 e API-12 (os planos, SUMMARYs e a VERIFICATION da fase usavam esses nomes); viraram API-13/API-14 ao juntar a `main` com a Fase 9, que ficou com API-11/API-12.

- [x] **CXA-01**: O corretor vê "Meus contatos": a lista dos contatos que recebeu, mais recentes primeiro, vinda de `GET /api/contatos/` (paginada, rolagem infinita); cada item traz imóvel ("código — título"), canal, data e retorno atual.
- [x] **CXA-02**: Filtro por imóvel (opções vindas de `GET /api/contatos/imoveis/`) e por período (`de`/`ate`, `showDateRangePicker` em pt-BR); os dois se combinam e o servidor resolve.
- [x] **CXA-03**: O corretor anota o retorno (Falei, Visita agendada, Sem resposta, Descartado) com um toque; a anotação é gravada por `PATCH /api/contatos/<id>/` e o app espera o servidor; falhas viram SnackBar com texto fixo.
- [x] **CXA-04**: Contato de outra empresa ou de outro corretor nunca aparece na lista, na contagem nem nas opções do filtro, e o PATCH pelo id dá 404 — garantido e testado no Django.
- [x] **CXA-05**: A tela mostra quantos contatos estão sem retorno anotado (`GET /api/contatos/resumo/` → `{"sem_retorno": N}`), calculado no Django, sem filtros, atualizado ao abrir e depois de cada anotação.
- [x] **CXA-06**: A caixa abre por um ícone na `AppBar` do "Meu acervo" (só o corretor); qualquer 401 encerra a sessão e abre o login com o aviso "Sua sessão terminou. Entre de novo."; os textos de estado são fixos do app.
- [x] **API-13**: O §17 de `01-CONTRATO-API.md` congela a lista paginada, os parâmetros, os 12 campos do item, o PATCH (valores, resposta, 400/401/403/404/405), a contagem, as opções do imóvel, o fuso e o isolamento, com fixtures capturadas do Django e testes de contrato nos dois repositórios.
- [x] **API-14**: A web entrega, com testes, a paginação de `GET /api/contatos/`, `GET /api/contatos/resumo/`, `GET /api/contatos/imoveis/` e o PATCH sem `retorno` respondendo 400, todas atrás de `PertenceAUmaEmpresa` e do escopo de empresa e perfil.

### Área do gestor (APP12)

Card APP 12 (tarefa A12). GES-01..GES-06 cobrem os critérios 1–6 do card; API-15/API-16 são as rotas novas da web e o §18 do contrato.

- [x] **GES-01**: Acervo por corretor (critério 1): a Área do gestor mostra quantos imóveis cada corretor tem — todos os imóveis da empresa, em qualquer situação —, com todo corretor ativo (mesmo com zero) e o desativado que ainda é responsável por imóvel marcado "(desativado)", mais o total, tudo de `GET /api/relatorios/acervo-por-corretor/`.
- [x] **GES-02**: Contatos por corretor e por período (critério 2): por corretor, quantos contatos recebeu e quantos aguardam retorno, de `GET /api/relatorios/contatos/?de=&ate=`; o padrão é todo o período e o chip "Período" (seletor pt-BR da APP-10) recarrega só esta seção; a linha da empresa usa texto fixo do app.
- [x] **GES-03**: Mudanças de situação recentes (critério 3): lista das mudanças de situação dos últimos dias da empresa (janela de 7 dias decidida no servidor), com imóvel, de → para, data e hora, quem mudou e a observação, de `GET /api/relatorios/mudancas-situacao/`.
- [x] **GES-04**: Totais da empresa por situação (critério 4): Disponível, Reservado, Vendido e Alugado, mais o total, lidos de `totais` e `total` de `GET /api/relatorios/acervo/`.
- [x] **GES-05**: Números do servidor (critério 5): o app não conta, não soma e não filtra nada; cada seção carrega sozinha, com o próprio carregando e o próprio erro ("Não foi possível carregar." com "Tentar de novo"), e uma falha não derruba as outras.
- [x] **GES-06**: Só o gestor (critério 6): o gestor cai na "Área do gestor" depois do login e pelo botão do topo; o administrador continua no aviso ("Área do administrador"); o corretor nunca vê a área; o servidor recusa as 4 rotas a quem não é gestor (403/401), testado no Django; 401 encerra a sessão e 403 mostra texto fixo.
- [x] **API-15**: A web entrega, com testes, na branch `feat/APP12`, `GET /api/relatorios/acervo-por-corretor/` e `GET /api/relatorios/mudancas-situacao/?dias=` (padrão 7, de 1 a 365), atrás de `EhGestor` e sempre com a empresa do usuário, sem migração.
- [x] **API-16**: O §18 de `01-CONTRATO-API.md` congela as 4 rotas da Área do gestor (campos lidos, parâmetros, 400/401/403, isolamento, fuso e janela), com fixtures capturadas do Django e testes de contrato nos dois repositórios.

### API pública (endpoints que o app consome)

- [x] **API-01**: Auditar a API atual e congelar por escrito o contrato de `/cidades` e `/imoveis` (nomes de campos, enums, nomes dos params de filtro, envelope de paginação) antes de codar APP02/APP03 ou o endpoint real.
- [x] **API-02**: `GET /api/publico/cidades/` — endpoint público sem token, expõe as cidades atendidas para a vitrine (app e site).
- [x] **API-03**: `GET /api/publico/cidades/<id>/imoveis/?filtros` — endpoint público sem token com busca, ordenação, filtros e paginação server-side; retorna só imóveis publicados; usa serializer público com allowlist (sem proprietário/documento/dado interno) e não quebra o isolamento multitenant.
- [x] **API-04**: A camada de dados do app é trocável (DataSource mock/fixture honrando o contrato → DataSource real por DI), permitindo desenvolver APP02/APP03 antes de o endpoint real de imóveis existir.
- [x] **API-06**: O contrato de `GET /api/publico/imoveis/{id}/` fica congelado por escrito no §11 do contrato da API + `imovel_detalhe.example.json`, e o app o consome por DataSource trocável (mock honrando o contrato).
- [x] **API-07**: Endpoint real `GET /api/publico/imoveis/{id}/` público, só imóveis publicados, 404 igual para inexistente e não publicado, serializer com a allowlist do §11, e troca da DataSource do detalhe por DI.
- [x] **API-08**: A vitrine do anunciante fica escrita como §13 do contrato (rotas `GET /api/publico/corretores/<id>/imoveis/` e `/api/publico/empresas/<id>/imoveis/`, `PageNumberPagination`, allowlist e limite de taxa da API pública) e o app a consome pela DataSource real (Dio), entregue pelo Django.

### Contato com o corretor (APP06)

Card APP 06 (tarefa A06), promovido do v2 `CON-01` para a Phase 6. C1–C6 são os critérios de aceite do card (todos obrigatórios); API-1/API-2 são as mudanças no repo da API (`../imoveis-aqui`, branch local `feat/APP06`).

- [x] **APP06-C1**: Botão de contato na página do imóvel e no perfil do corretor.
- [x] **APP06-C2**: O botão abre o WhatsApp com a mensagem padrão já preenchida.
- [x] **APP06-C3**: Telefone e e-mail como alternativas de contato.
- [x] **APP06-C4**: O contato é registrado na API no momento em que o visitante o dispara.
- [x] **APP06-C5**: O registro guarda o imóvel, o corretor e o canal usado.
- [x] **APP06-C6**: Tudo funciona sem login.
- [x] **APP06-API-1**: O detalhe público `GET /api/publico/imoveis/{id}/` expõe `canais_contato` (subconjunto de `WHATSAPP`/`TELEFONE`/`EMAIL` na ordem fixa, calculado no servidor por `canais_disponiveis`), só com os nomes dos canais — nunca número, e-mail ou link — e coberto pelo teste de allowlist do público.
- [x] **APP06-API-2**: O `POST /api/publico/imoveis/{id}/contato/` (sem login) tem throttle próprio (`ThrottleContatoPublico`, escopo `contato_publico`, `CONTATO_TAXA_ANONIMA` padrão 10/min por IP), separado do balde da vitrine, e responde 429 ao exceder.

## v2 Requirements

Reconhecidos, mas fora desta entrega (outras tarefas do app, feitas depois / por outros colegas).

### App — próximas tarefas

- **CON-01**: Contato com o corretor por WhatsApp com mensagem montada pelo servidor e gravação do contato (card 9). → Promovido para a Phase 6 como APP06-C1..C6 e APP06-API-1/2 (seção "Contato com o corretor (APP06)").
- **FAV-01**: Favoritos guardados no aparelho.
- **LOG-01**: Áreas logadas do app — área do corretor e área do gestor (cards 10–11). → Área do corretor entregue nas Phases 8–10; área do gestor promovida para a Phase 12 como GES-01..GES-06, API-15 e API-16 (seção "Área do gestor (APP12)").
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
| APP06-C1 | Phase 6 | Complete |
| APP06-C2 | Phase 6 | Complete |
| APP06-C3 | Phase 6 | Complete |
| APP06-C4 | Phase 6 | Complete |
| APP06-C5 | Phase 6 | Complete |
| APP06-C6 | Phase 6 | Complete |
| APP06-API-1 | Phase 6 | Complete |
| APP06-API-2 | Phase 6 | Complete |
| PERF-01 | Phase 7 | Complete |
| PERF-02 | Phase 7 | Complete |
| PERF-03 | Phase 7, Phase 07.1 | Complete |
| PERF-04 | Phase 7, Phase 07.1 | Complete |
| PERF-05 | Phase 7 | Complete |
| PERF-06 | Phase 7 | Complete |
| API-08 | Phase 7, Phase 07.1 | Complete |
| AUTH-01 | Phase 8 | Complete |
| AUTH-02 | Phase 8 | Complete |
| AUTH-03 | Phase 8 | Complete |
| AUTH-04 | Phase 8 | Complete |
| AUTH-05 | Phase 8 | Complete |
| AUTH-06 | Phase 8 | Complete |
| ACV-01 | Phase 8 | Complete |
| ACV-02 | Phase 8 | Complete |
| ACV-03 | Phase 8 | Complete |
| ACV-04 | Phase 8 | Complete |
| API-09 | Phase 8 | Complete |
| API-10 | Phase 8 | Complete |
| SIT-01 | Phase 9 | Complete |
| SIT-02 | Phase 9 | Complete |
| SIT-03 | Phase 9 | Complete |
| SIT-04 | Phase 9 | Complete |
| SIT-05 | Phase 9 | Complete |
| SIT-06 | Phase 9 | Complete |
| SIT-07 | Phase 9 | Complete |
| API-11 | Phase 9 | Complete |
| API-12 | Phase 9 | Complete |
| CXA-01 | Phase 10 | Complete |
| CXA-02 | Phase 10 | Complete |
| CXA-03 | Phase 10 | Complete |
| CXA-04 | Phase 10 | Complete |
| CXA-05 | Phase 10 | Complete |
| CXA-06 | Phase 10 | Complete |
| API-13 | Phase 10 | Complete |
| API-14 | Phase 10 | Complete |
| GES-01 | Phase 12 | Complete |
| GES-02 | Phase 12 | Complete |
| GES-03 | Phase 12 | Complete |
| GES-04 | Phase 12 | Complete |
| GES-05 | Phase 12 | Complete |
| GES-06 | Phase 12 | Complete |
| API-15 | Phase 12 | Complete |
| API-16 | Phase 12 | Complete |

Planos da Phase 6 que cobrem cada ID (frontmatter `requirements` dos `06-NN-PLAN.md`): APP06-C1 → 06-07, 06-09, 06-10; APP06-C2 → 06-02, 06-03, 06-04, 06-05, 06-06, 06-07, 06-10; APP06-C3 → 06-03, 06-04, 06-05, 06-06, 06-08, 06-09, 06-10; APP06-C4 → 06-01, 06-03, 06-05, 06-06, 06-07, 06-08, 06-10; APP06-C5 → 06-01, 06-09, 06-10; APP06-C6 → 06-01, 06-02, 06-05, 06-07, 06-09, 06-10; APP06-API-1 → 06-01, 06-03, 06-04, 06-10; APP06-API-2 → 06-02, 06-10.

**Coverage:**

- v1 requirements: 82 total
- Mapped to phases: 82 (roadmap complete)
- Unmapped: 0

Planos da Phase 9 que cobrem cada ID (frontmatter `requirements` dos `09-NN-PLAN.md`): SIT-01 → 09-07, 09-09, 09-10, 09-11, 09-13; SIT-02 → 09-08, 09-09, 09-10, 09-11, 09-13; SIT-03 → 09-03, 09-06, 09-07, 09-13; SIT-04 → 09-08, 09-09, 09-11, 09-12, 09-13; SIT-05 → 09-13; SIT-06 → 09-02, 09-10, 09-12, 09-13; SIT-07 → 09-03, 09-04, 09-05, 09-07, 09-10, 09-13; API-11 → 09-01, 09-13; API-12 → 09-02, 09-13.

---
*Requirements defined: 2026-09-21*
*Last updated: 2026-11-25 after Phase 12 execution (GES-01..06, API-15, API-16)*
