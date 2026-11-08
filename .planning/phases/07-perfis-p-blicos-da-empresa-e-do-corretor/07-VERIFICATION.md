---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
verified: 2026-11-08T12:00:00Z
status: human_needed
score: 7/7 must-haves verified
covered_files:
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-01-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-01-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-02-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-02-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-03-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-03-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-04-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-04-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-05-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-05-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-06-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-06-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-07-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-07-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-08-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-08-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-09-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-09-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-10-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-10-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-11-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-11-SUMMARY.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-12-PLAN.md"
  - ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-12-SUMMARY.md"
  - "lib/data/datasources/perfil_mock_datasource.dart"
  - "lib/data/datasources/perfil_remote_datasource.dart"
  - "lib/data/datasources/vitrine_anunciante_mock_datasource.dart"
  - "lib/data/repositories/perfil_repository_impl.dart"
  - "lib/data/repositories/vitrine_anunciante_repository_impl.dart"
  - "lib/di/injection.config.dart"
  - "lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart"
  - "lib/presentation/perfis/perfil_corretor_cubit.dart"
  - "lib/presentation/perfis/perfil_corretor_screen.dart"
  - "lib/presentation/perfis/perfil_empresa_cubit.dart"
  - "lib/presentation/perfis/perfil_empresa_screen.dart"
  - "lib/presentation/perfis/vitrine_anunciante_cubit.dart"
covered_digest: "v4:sha256:ef875507f8c60c0fa5e88d8ca9abd83e85ba03979ed6053f9869f32bfd658f02"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Em Campinas, 'Mais recentes': abrir o card 42, rolar até 'Corretor responsável' e tocar em Marina Lopes."
    expected: "A página do corretor abre na hora com nome e foto da prévia (foto do 42 usa host fictício e mostra o avatar padrão) e completa em ~0,5 s com 'CRECI 12345-F', 'Apresentação' e 'Contato' (ícones de telefone, conversa e e-mail), sem botão de ligar/WhatsApp/e-mail."
    why_human: "Fidelidade visual Material 3 verde e branco, escolha de ícones e latência percebida da prévia não são verificáveis por grep/teste (sem UI-SPEC, D-16)."
  - test: "No perfil de Marina, pressionar e segurar o telefone; rolar até o fim; voltar ao topo e tocar 'Ver página do anunciante'; rolar a página da empresa e tocar num imóvel; voltar até a vitrine."
    expected: "O texto do contato é selecionável/copiável e nada é discado; vitrine 'Imóveis de Marina Lopes' carrega mais ao rolar até 'Você chegou ao fim da lista' (4 páginas) sem card repetido; 'Imobiliária Jequitibá' mostra logomarca (ou placeholder verde com prédio), 'Imobiliária', 'CRECI J-1234', Apresentação, Contato, chips 'Campinas, SP' / 'Valinhos, SP' / 'Vinhedo, SP' e 'Imóveis de Imobiliária Jequitibá'; voltar retorna página a página até a vitrine na mesma posição."
    why_human: "Comportamento de seleção de texto, rolagem real e posição preservada em aparelho real; rótulos escolhidos por discrição ('Ver página do anunciante', 'Anunciante') precisam do aceite do dono."
  - test: "Abrir o 4º card de Campinas (imóvel 101, Camila Duarte), o perfil dela e depois 'Ver página do anunciante'."
    expected: "Camila sem foto (avatar padrão), sem 'Apresentação' e sem a linha 'Telefone'; a empresa dela mostra 'Corretor autônomo', placeholder de logomarca, sem 'Apresentação', chip 'Vinhedo, SP' e os imóveis dela."
    why_human: "Aparência dos estados de campos vazios (omissão de linha/seção sem 'buraco' visual) só se confirma visualmente."
  - test: "Trocar para Vinhedo, rolar até o fim, abrir o antepenúltimo card (imóvel 337) e tocar no corretor Paulo Teixeira."
    expected: "O perfil abre com 'Paulo Teixeira' por um instante e troca para 'Este corretor não está mais disponível' com 'Voltar', sem nome nem foto, sem lista de imóveis; 'Voltar' devolve o detalhe 337."
    why_human: "Transição prévia -> aviso 404 e ausência de tela quebrada, percebidas visualmente."
  - test: "Repetir os fluxos acima numa largura de 360 dp (emulador Android ou dispositivo real; ou flutter run -d windows)."
    expected: "Sem overflow, sem cor fora do tema, rótulos em português natural; confirmar também a suposição A7 (rótulo neutro 'Ver página do anunciante' no cartão da empresa)."
    why_human: "Layout em 360 dp e fidelidade visual em aparelho real."
---

# Fase 7: Perfis Públicos da Empresa e do Corretor — Relatório de Verificação

**Objetivo da fase:** O visitante vê quem está anunciando para saber com quem vai negociar: a página da empresa traz logomarca, CRECI, apresentação, contato e cidades de atuação; a do corretor traz foto, CRECI, apresentação e contato; as duas mostram a vitrine dos imóveis daquele anunciante. Card APP 07 (tarefa A07).
**Verificado em:** 2026-11-08
**Status:** human_needed
**Re-verificação:** Não — verificação inicial

## Resultado do objetivo

### Verdades observáveis (Success Criteria do ROADMAP + must_haves dos PLANs)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação (PERF-01) | VERIFICADO | `perfil_empresa_screen.dart`: `_CabecalhoEmpresa` (logomarca 96 dp via `ImagemRede`, nome, `rotuloTipoEmpresa`, `CRECI ...`), `SecaoApresentacao(dados.descricao)`, `SecaoContato(linhasDeContato(...))` (texto `SelectableText`), `ChipsCidadesAtuacao(cidades)` (um `Chip` "Cidade, UF" por cidade). Campo nulo omite linha; seção vazia some. Testes de tela da empresa (ordem, autônomo, sem cidades, contato só texto) passam. |
| 2 | Página do corretor com foto, CRECI, apresentação e contato (PERF-02) | VERIFICADO | `perfil_corretor_screen.dart`: `AvatarCorretor` (raio 56) + nome + `CRECI`, `SecaoApresentacao`, `SecaoContato`; prévia (nome+foto do detalhe) enquanto carrega (D-05). `PerfilCorretorModel.paraEntidade` normaliza `""`/`null` e filtra URL não http(s). |
| 3 | As duas páginas mostram a vitrine dos imóveis daquele anunciante (PERF-03) | VERIFICADO | `SliverImoveisDoAnunciante` usado nas duas telas via `CorpoPerfilComVitrine`, só com perfil carregado; `VitrineAnuncianteCubit` com paginação por cursor, rodapés carregando/erro/fim, vazio "Nenhum imóvel anunciado no momento."; reaproveita `ImovelCard`; toque abre `abrirDetalheImovel`. Repositório só repassa a página (não filtra nem reordena). |
| 4 | Dados vêm da API de perfis públicos por DataSource trocável (PERF-04) | VERIFICADO (com a ressalva do mock declarado) | `PerfilDataSource` (interface) com `PerfilMockDataSource` (registrado em `injection.config.dart` como `PerfilDataSource`) e `PerfilRemoteDataSource` (Dio, `/api/publico/corretores/{id}/` e `/empresas/{id}/`, pronto e testado com Dio mockado, não ativo). Repositório injeta a interface. Troca = mover `as:` + build_runner, sem tocar domain/presentation. Conforme D-03/§12 do contrato. |
| 5 | Corretor desativado (404) mostra aviso, não tela quebrada (PERF-05) | VERIFICADO | `PerfilRepositoryImpl._executar` traduz `PerfilNaoEncontradoException`/`DioException 404` em `Result.failure` tipado; `PerfilCorretorCubit` decide só pelo tipo -> `PerfilNaoEncontrado` -> `AvisoPerfil` "Este corretor não está mais disponível" + "Voltar"; fixture reservada `idCorretorDesativadoMock = 99` (detalhe 337). Empresa 404: "Esta página não está mais disponível" (caminho coberto em `detalhe_navegacao_test.dart` l.506–597). Erros genéricos: "Tentar de novo". Sem `try/catch` em `presentation/perfis`. |
| 6 | Chega-se ao perfil do corretor pela página do imóvel e à empresa pelo perfil do corretor (PERF-06) | VERIFICADO | `detalhe_imovel_screen.dart:169` `CartaoCorretor(aoTocar: abrirPerfilCorretor(...))`; `PerfilCorretorScreen` -> `CartaoEmpresa(aoTocar: aoAbrirEmpresa(context, empresaId))` só se `empresaId != null`; `abrirPerfilEmpresa` monta `MultiBlocProvider`. E2E em `detalhe_navegacao_test.dart` (vitrine -> imóvel 42 -> Marina -> empresa -> imóvel -> volta). |
| 7 | Vitrine do anunciante escrita como adendo §12 do contrato e consumida por DataSource trocável (API-08) | VERIFICADO | `01-CONTRATO-API.md` §12.1–§12.9 existe (endpoint `GET /api/publico/imoveis/` com `empresa=`/`corretor=` no lugar de `cidade`, resposta, ordenação, 404 vs. vazio, 400, PENDENTE WEB). `VitrineAnuncianteDataSource` (interface) + `VitrineAnuncianteMockDataSource` (parseia pelo mesmo `ImoveisEnvelopeModel`, remove `corretor/empresa/proprietario`, exceção dev-only de recorte declarada no §12.9) + `parametrosDoAnunciante`/`anuncianteDosParametros`; exemplos `perfil_corretor/empresa.example.json` guardados por `test/data/contrato_perfis_test.dart`. |

**Pontuação:** 7/7 verdades verificadas (6 Success Criteria do ROADMAP + API-08); 0 presentes-sem-comportamento.

### Itens adiados (Passo 9b)

Nenhum. As pendências de web (endpoint real da vitrine, `cidade` opcional, LGPD do contato, empresa inativa de corretor ativo) estão registradas em §12.8 como PENDENTE WEB por decisão do usuário (CONTEXT D-02/D-03) e não são gaps da fase.

### Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `lib/domain/entities/perfil_corretor.dart`, `perfil_empresa.dart`, `anunciante_ref.dart` | Entidades freezed | VERIFICADO | Existem; usadas por models/telas. |
| `lib/data/models/perfil_corretor_model.dart`, `perfil_empresa_model.dart` | Models defensivos freezed+json | VERIFICADO | Nove/dez chaves públicas, `corretores_ativos` não declarado (minimização), `textoOuNulo`/`urlHttpOuNula`. |
| `lib/data/datasources/perfil_datasource.dart`, `perfil_mock_datasource.dart`, `perfil_remote_datasource.dart` | Interface + mock + real | VERIFICADO | Wired no DI (`injection.config.dart` l.126, 153). |
| `lib/data/datasources/vitrine_anunciante_datasource.dart`, `..._mock_datasource.dart` | Interface + mock §12 | VERIFICADO | DI l.141. |
| `lib/data/repositories/perfil_repository_impl.dart`, `vitrine_anunciante_repository_impl.dart` | Repositórios com erros tipados | VERIFICADO | Dependem da interface, não do mock. |
| `lib/domain/usecases/obter_perfil_corretor/empresa_usecase.dart`, `buscar_imoveis_do_anunciante_usecase.dart` | UseCases | VERIFICADO | Registrados como factory. |
| `lib/presentation/perfis/*` (3 cubits, 2 telas, estados freezed, 7 widgets) | UI + estado | VERIFICADO | Nenhum stub, TODO/FIXME/TBD, cor literal, `url_launcher` ou `try/catch`. |
| `.planning/.../01-CONTRATO-API.md` §12 + 2 exemplos JSON | Contrato | VERIFICADO | Presente. |
| Testes (cubits, telas, datasources, contrato, DI, e2e) | Cobertura | VERIFICADO | 17 arquivos de teste ligados à fase. |

### Verificação de ligações-chave

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|----------|
| `detalhe_imovel_screen.dart` | `abrirPerfilCorretor` | `CartaoCorretor.aoTocar` | LIGADO | l.169. `perfil_corretor_screen.dart` em `detalhe_imovel/` reexporta o novo. |
| `PerfilCorretorScreen` | `abrirPerfilEmpresa` | `CartaoEmpresa` + `empresaId` | LIGADO | Cartão só com `empresaId`. |
| Telas | `VitrineAnuncianteCubit` | `MultiBlocProvider` preguiçoso + `SliverImoveisDoAnunciante` só em `PerfilCarregado` | LIGADO | 404/erro/carregando nunca consultam a vitrine (testes dedicados). |
| Repositórios | DataSources | Interface injetada via DI | LIGADO | `injection.config.dart` l.126–162. |
| Vitrine mock | Lista/detalhe fixtures | Vínculo imóvel-corretor via `corretor.id` do detalhe; empresa via `empresa_id` dos perfis | LIGADO | Coerência guardada por `contrato_perfis_test.dart`. |

### Rastreio de fluxo de dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `PerfilCorretorScreen` | `dados` | `PerfilCorretorCubit` -> UseCase -> Repo -> `PerfilDataSource` (mock com JSON de wire via `fromJson`) | Sim (mock honra o contrato) | FLUINDO (mock por decisão D-03) |
| `PerfilEmpresaScreen` | `dados` | idem, `buscarEmpresa` | Sim | FLUINDO |
| `SliverImoveisDoAnunciante` | `itens` | `VitrineAnuncianteCubit` -> UseCase -> Repo -> mock §12 -> `ImoveisEnvelopeModel` | Sim | FLUINDO (mock) |

### Verificações comportamentais por amostragem

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Telas e Cubits de corretor/empresa/vitrine, e2e, contrato, remote DS, mock da vitrine, DI | `flutter test` em 10 arquivos da fase (inclui `vitrine_fluxo_test.dart`) | `All tests passed!` | PASSOU |
| Suíte completa e analyzer (rodados pelo orquestrador após o merge final) | `flutter test` / `flutter analyze` | 795 testes OK / sem issues | PASSOU (reportado pelo orquestrador) |
| Nenhuma dependência nova | `git diff main -- pubspec.yaml` | vazio | PASSOU |

### Execução de probes

Não aplicável (a fase não declara probes `scripts/*/tests/probe-*.sh`).

### Cobertura de requisitos

| Requisito | Plano(s) de origem | Descrição | Status | Evidência |
|-----------|--------------------|-----------|--------|-----------|
| PERF-01 | 07-05, 07-09, 07-11, 07-12 | Página da empresa: logomarca, CRECI, apresentação, contato, cidades | SATISFEITO | `perfil_empresa_screen.dart` + `chips_cidades_atuacao.dart` |
| PERF-02 | 07-01, 07-02, 07-04, 07-12 | Página do corretor: foto, CRECI, apresentação, contato | SATISFEITO | `perfil_corretor_screen.dart` |
| PERF-03 | 07-06, 07-08, 07-10, 07-12 | Vitrine do anunciante paginada por cursor, filtrada no servidor | SATISFEITO (servidor simulado declarado) | `vitrine_anunciante_cubit.dart`, `sliver_imoveis_anunciante.dart` |
| PERF-04 | 07-01, 07-02, 07-03, 07-05, 07-09, 07-11, 07-12 | Perfis via API de perfis públicos por DataSource trocável | SATISFEITO | `PerfilRemoteDataSource` pronta + mock ativo (D-03) |
| PERF-05 | 07-04, 07-05, 07-07, 07-12 | Corretor desativado (404) mostra aviso | SATISFEITO | `AvisoPerfil` + fixture 99 |
| PERF-06 | 07-02, 07-11, 07-12 | Navegação imóvel -> corretor -> empresa | SATISFEITO | e2e em `detalhe_navegacao_test.dart` |
| API-08 | 07-03, 07-06, 07-08, 07-10, 07-12 | Adendo §12 + DataSource trocável da vitrine do anunciante | SATISFEITO | `01-CONTRATO-API.md` §12; `VitrineAnuncianteDataSource` |

Todos os 7 IDs do ROADMAP/PLAN frontmatter existem em `REQUIREMENTS.md` e foram reivindicados por pelo menos um plano. Nenhum requisito órfão.

### Anti-padrões encontrados

| Arquivo | Linha | Padrão | Severidade | Impacto |
|---------|-------|--------|------------|---------|
| — | — | Sem TBD/FIXME/XXX/TODO/HACK; sem `try/catch`, cor literal ou `url_launcher` em `presentation/perfis` | — | Nenhum |

### Observações (não bloqueantes)

- `.planning/REQUIREMENTS.md` ainda mostra PERF-01..06 e API-08 como `[ ]` / "Pending" (linhas 48–63 e 123–129). Atualização de rastreabilidade a cargo do orquestrador ao fechar a fase.
- A decisão D-06 sugeria "Ver imobiliária" para corretor com empresa e "Ver página do anunciante" para autônomo; a implementação usa um único rótulo neutro "Ver página do anunciante" (o perfil do corretor só conhece `empresa_id`, não o tipo). D-06 declara o texto como discrição; fica listado no human-check (suposição A7).
- O recorte por `empresa`/`corretor` roda no servidor simulado (`data/`), exceção dev-only registrada no §12.9; o app/presentation nunca filtra nem reordena. Deixa de existir quando a web entregar o endpoint (PENDENTE WEB §12.8 a).

### Verificação humana necessária

Ver `human_verification` no frontmatter (origem: "Human-check de fim de fase" do `07-12-SUMMARY.md`): fidelidade visual Material 3 verde e branco, ícones e rótulos ("Ver página do anunciante", "Anunciante"), latência percebida da prévia do perfil, seleção de texto de contato e layout em 360 dp em aparelho real.

### Resumo das lacunas

Nenhuma lacuna de implementação. Todas as verdades observáveis, artefatos e ligações-chave foram confirmados no código, e os testes direcionados da fase passam. O status é `human_needed` apenas porque a fase deixou um human-check de fim de fase (D-16, sem UI-SPEC) que não pode ser verificado programaticamente.

---

_Verificado: 2026-11-08_
_Verificador: Claude (gsd-verifier)_
