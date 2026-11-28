---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
verified: 2026-11-20T18:00:00Z
status: passed
re_verified: 2026-11-23T22:00:00Z
score: 7/7 must-haves verified
covered_files: [".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-01-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-01-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-02-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-02-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-03-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-03-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-04-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-04-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-05-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-05-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-06-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-06-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-07-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-07-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-08-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-08-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-09-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-09-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-10-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-10-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-11-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-11-SUMMARY.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-12-PLAN.md", ".planning/phases/07-perfis-p-blicos-da-empresa-e-do-corretor/07-12-SUMMARY.md", "lib/data/datasources/perfil_datasource.dart", "lib/data/datasources/perfil_remote_datasource.dart", "lib/data/datasources/vitrine_anunciante_datasource.dart", "lib/data/datasources/vitrine_anunciante_remote_datasource.dart", "lib/data/repositories/perfil_repository_impl.dart", "lib/data/repositories/vitrine_anunciante_repository_impl.dart", "lib/di/injection.config.dart", "lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart", "lib/presentation/perfis/perfil_corretor_cubit.dart", "lib/presentation/perfis/perfil_corretor_screen.dart", "lib/presentation/perfis/perfil_empresa_cubit.dart", "lib/presentation/perfis/perfil_empresa_screen.dart", "lib/presentation/perfis/vitrine_anunciante_cubit.dart"]
covered_digest: "v1:sha256:724c8908509fb163af3ccb02f5c8c680bbdab4355c1f7140b545f7e4f094e584"
behavior_unverified: 0
overrides_applied: 0
---

# Fase 7: Perfis Públicos da Empresa e do Corretor — Relatório de Verificação

**Objetivo da fase:** O visitante vê quem está anunciando para saber com quem vai negociar: a página da empresa traz logomarca, CRECI, apresentação, contato e cidades de atuação; a do corretor traz foto, CRECI, apresentação e contato; as duas mostram a vitrine dos imóveis daquele anunciante. Card APP 07 (tarefa A07).
**Verificado em:** 2026-11-20
**Status:** passed
**Re-verificação:** Sim — o relatório anterior (2026-11-08, `human_needed`, 7/7) ficou obsoleto porque a Fase 07.1 removeu os servidores simulados (`perfil_mock_datasource.dart`, `vitrine_anunciante_mock_datasource.dart`) e ativou as DataSources reais no DI. Esta versão foi refeita contra o código atual. O relatório anterior não tinha `gaps:`, então a verificação foi completa (modo inicial) sobre o código de hoje.

## Resultado do objetivo

### O que mudou desde o relatório anterior

- **Os mocks não existem mais.** `grep` por `PerfilMockDataSource`, `VitrineAnuncianteMockDataSource`, `perfil_mock` e `vitrine_anunciante_mock` em `lib/` e `test/` não encontra nada. No DI (`lib/di/injection.config.dart` l.127–128 e l.142–143), `VitrineAnuncianteDataSource` resolve para `VitrineAnuncianteRemoteDataSource(Dio)` e `PerfilDataSource` para `PerfilRemoteDataSource(Dio)`.
- **O contrato virou §13.** O adendo §12 da APP-07 (que propunha `GET /api/publico/imoveis/?corretor=|empresa=`) foi substituído pelo §13 de `01-CONTRATO-API.md`, escrito a partir do que o Django entrega: rotas aninhadas `GET /api/publico/corretores/<id>/imoveis/` e `/empresas/<id>/imoveis/`, 20 por página, 404 para anunciante inexistente ou inativo, 200 vazio para anunciante ativo sem imóveis. `REQUIREMENTS.md` já cita §13 (API-08).
- **As verdades que citavam o mock estão superadas, não quebradas.** Os `must_haves` dos PLANs 07-01..07-12 falam em "servidor simulado", Marina Lopes, Imobiliária Jequitibá e corretor reservado 99. Esses dados nunca chegam ao visitante hoje. O resultado voltado ao visitante que eles descreviam foi reverificado no código atual e no UAT contra a API real (ver abaixo). Os testes foram migrados para fixtures capturadas da API (`test/fixtures/api/`, `test/support/api_falsa.dart`).

### Verdades observáveis (Success Criteria do ROADMAP + must_haves dos PLANs)

| # | Verdade | Status | Evidência |
|---|---------|--------|-----------|
| 1 | Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação (PERF-01) | VERIFICADO | `perfil_empresa_screen.dart`: `_CabecalhoEmpresa` (logomarca 96 dp com placeholder de prédio, nome, `rotuloTipoEmpresa(tipo)`, `CRECI $creci`), `SecaoApresentacao(dados.descricao)`, `SecaoContato(linhasDeContato(...))`, `ChipsCidadesAtuacao(dados.cidadesAtuacao)`. Tipo e CRECI só aparecem se a API os mandou (nada é deduzido no aparelho). UAT 2 e 3 (API real): "Imobiliária", "CRECI 00000-D", 4 chips de cidade, placeholder de logomarca, sem "Apresentação" nem "Telefone" quando o dado é vazio. |
| 2 | Página do corretor com foto, CRECI, apresentação e contato (PERF-02) | VERIFICADO | `perfil_corretor_screen.dart`: `_CabecalhoCorretor` (avatar + nome + `CRECI`), `SecaoApresentacao`, `SecaoContato`; a prévia (foto + nome do detalhe) aparece enquanto carrega (D-05). `PerfilCorretorModel`/`PerfilEmpresaModel` existem e normalizam `""`/`null` e URL não http(s). UAT 1: "CRECI 12345-F", Apresentação com o texto do seed, Contato como texto, sem botão de ligar/WhatsApp/e-mail. |
| 3 | As duas páginas mostram a vitrine dos imóveis daquele anunciante (PERF-03) | VERIFICADO | As duas telas usam `CorpoPerfilComVitrine` + `SliverImoveisDoAnunciante` só no estado `PerfilCarregado`. `VitrineAnuncianteRemoteDataSource` chama `caminhoVitrineDoAnunciante` (`/corretores/<id>/imoveis/` ou `/empresas/<id>/imoveis/`), sem query string, e segue o `next` só se for da mesma origem da base URL. O repositório só repassa a página na ordem recebida. Reaproveita `ImovelCard`; toque abre `abrirDetalheImovel`. UAT 2: corretor com 35 imóveis e empresa com 36 imóveis, 2 páginas cada, "Você chegou ao fim da lista", sem card repetido. |
| 4 | Dados vêm da API de perfis públicos por DataSource trocável, sem nada montado no app (PERF-04) | VERIFICADO | `PerfilRemoteDataSource` (Dio) lê `/api/publico/corretores/{id}/` e `/empresas/{id}/`, exige corpo objeto JSON (senão `FormatException`) e **não tem interceptador de log** (o corpo traz e-mail e telefone). `PerfilRepositoryImpl` injeta a interface `PerfilDataSource`. Ativa no DI de produção; `test/di/injection_perfis_test.dart` trava a resolução. A ressalva do relatório anterior ("mock declarado") deixou de existir. |
| 5 | Corretor desativado (404) mostra aviso, não tela quebrada (PERF-05) | VERIFICADO | `PerfilRepositoryImpl._executar` traduz `DioException` 404 em `PerfilNaoEncontradoException`; `PerfilCorretorCubit` decide só pelo tipo e emite `naoEncontrado`; a tela mostra `AvisoPerfil` "Este corretor não está mais disponível" e a vitrine nem é montada (`vitrine = null`). Empresa 404: "Esta página não está mais disponível". Outros erros: "Tentar de novo". Sem `try/catch` em `presentation/perfis`. UAT 4: com o corretor desativado por corrida pelo shell do Django, a prévia troca para o aviso com "Voltar"; "Voltar" devolve o detalhe; o imóvel de corretor desativado abre sem a seção "Corretor responsável". |
| 6 | Chega-se ao perfil do corretor pela página do imóvel e à empresa pelo perfil do corretor (PERF-06) | VERIFICADO | `detalhe_imovel_screen.dart` l.164–166: `CartaoCorretor(aoTocar: () => abrirPerfilCorretor(...))`. `PerfilCorretorScreen` mostra `CartaoEmpresa(aoTocar: aoAbrirEmpresa(context, empresaId))` só se `dados.empresaId != null`; `abrirPerfilEmpresa` monta `MultiBlocProvider`. E2E em `detalhe_navegacao_test.dart` (perfil do corretor -> "Ver página do anunciante" -> página da empresa -> imóvel da vitrine -> volta). UAT 2 percorre o mesmo caminho na API real. |
| 7 | Vitrine do anunciante documentada no contrato e consumida por DataSource real e trocável (API-08) | VERIFICADO | `01-CONTRATO-API.md` §13.1–§13.8 existe (perfis, rotas, resposta paginada, recorte/ordem do servidor, 404 vs. vazio, "No app", PENDENTE WEB, sincronização). `VitrineAnuncianteDataSource` (interface) + `VitrineAnuncianteRemoteDataSource` (Dio) ativa no DI. Travas: `test/data/contrato_perfis_test.dart` e `test/data/vitrine_anunciante_remote_datasource_test.dart`. |

**Pontuação:** 7/7 verdades verificadas; 0 presentes-sem-comportamento.

### Itens humanos do relatório anterior: agora satisfeitos pelo UAT

O relatório de 2026-11-08 listava cinco verificações humanas e estava `human_needed`. Elas foram executadas em `07-UAT.md` (status `complete`, 5/5 passados, 0 problemas, 0 pendentes, 0 bloqueados), contra a API Django real (seed `semear_vitrine_dev`) no emulador Pixel_7:

| Item humano anterior | Resolvido por |
|----------------------|---------------|
| Perfil do corretor a partir do imóvel, prévia e conteúdo completo | UAT 1 (pass) |
| Texto de contato selecionável, rolagem infinita das duas vitrines, página da empresa, volta à mesma posição | UAT 2 (pass) |
| Estado de campos vazios sem "buraco" visual | UAT 3 (pass, com a ressalva abaixo) |
| Corretor desativado: prévia -> aviso 404 -> "Voltar" | UAT 4 (pass) |
| Layout em 360 dp, fidelidade visual, rótulo "Ver página do anunciante" (suposição A7) | UAT 5 (pass); A7 aprovada pelo Allysson |

Não restam itens de verificação humana pendentes, então o status é `passed`.

Ressalva registrada, não é lacuna: o seed `semear_vitrine_dev` não tem corretor autônomo nem corretor ativo sem imóveis (PENDENTE WEB §13.7 h, D-20). O UAT 3 cobre "campos vazios" só pela empresa demo. Os casos de autônomo e vitrine vazia são cobertos por testes de tela (`perfil_empresa_screen_test.dart` l.202–211 "autônomo sem logomarca"; `perfil_corretor_screen_test.dart` l.462 "vazia mostra 'Nenhum imóvel anunciado no momento.'").

### Itens adiados (Passo 9b)

Nenhum. As pendências de web que continuam abertas (§13.7 f LGPD do contato, g limite de taxa das views de perfil, h extensão do seed) são decisões de produto/web registradas, fora do escopo dos critérios da fase.

### Artefatos obrigatórios

| Artefato | Esperado | Status | Detalhes |
|----------|----------|--------|----------|
| `lib/domain/entities/perfil_corretor.dart`, `perfil_empresa.dart`, `anunciante_ref.dart` | Entidades freezed | VERIFICADO | Existem, com `.freezed.dart`; usadas por models, cubits e telas. |
| `lib/data/models/perfil_corretor_model.dart`, `perfil_empresa_model.dart` | Models imutáveis com `fromJson` | VERIFICADO | Existem com `.freezed.dart` e `.g.dart`. |
| `lib/data/datasources/perfil_datasource.dart` + `perfil_remote_datasource.dart` | Interface + Dio | VERIFICADO | Wired no DI (l.142–143). |
| `lib/data/datasources/vitrine_anunciante_datasource.dart` + `..._remote_datasource.dart` | Interface + Dio | VERIFICADO | Wired no DI (l.127–128). |
| `lib/data/repositories/perfil_repository_impl.dart`, `vitrine_anunciante_repository_impl.dart` | Erros tipados | VERIFICADO | Dependem da interface; DI l.151–157. |
| `lib/domain/usecases/obter_perfil_corretor/empresa_usecase.dart`, `buscar_imoveis_do_anunciante_usecase.dart` | UseCases | VERIFICADO | Registrados como `factory` no DI. |
| `lib/presentation/perfis/*` (3 cubits, 2 telas, estados freezed, 7 widgets) | UI + estado | VERIFICADO | Nenhum stub, debt marker, `try/catch` nem `url_launcher`. |
| `01-CONTRATO-API.md` §13 + exemplos JSON | Contrato | VERIFICADO | Presente. |
| Testes da fase | Cobertura | VERIFICADO | 17 arquivos ligados à fase, todos na lista acima. |

### Verificação de ligações-chave

| De | Para | Via | Status | Detalhes |
|----|------|-----|--------|----------|
| `detalhe_imovel_screen.dart` | `abrirPerfilCorretor` | `CartaoCorretor.aoTocar` | LIGADO | l.164–166. |
| `PerfilCorretorScreen` | `abrirPerfilEmpresa` | `CartaoEmpresa` + `empresaId` | LIGADO | Cartão só existe com `empresaId`. |
| Telas | `VitrineAnuncianteCubit` | `MultiBlocProvider` preguiçoso + `SliverImoveisDoAnunciante` só em `PerfilCarregado` | LIGADO | 404/erro/carregando nunca consultam a vitrine. |
| Repositórios | DataSources reais | Interface injetada via `injection.config.dart` | LIGADO | l.127–157. |
| `VitrineAnuncianteCubit` | Repositório -> DataSource Dio | `buscarPrimeiraPagina` / `buscarProximaPagina(next)` | LIGADO | `next` seguido tal e qual, só na mesma origem. |

### Rastreio de fluxo de dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `PerfilCorretorScreen` | `dados` | `PerfilCorretorCubit` -> UseCase -> `PerfilRepositoryImpl` -> `PerfilRemoteDataSource` -> `GET /api/publico/corretores/{id}/` | Sim (UAT 1 contra o Django) | FLUINDO |
| `PerfilEmpresaScreen` | `dados` | idem, `GET /api/publico/empresas/{id}/` | Sim (UAT 2 e 3) | FLUINDO |
| `SliverImoveisDoAnunciante` | `itens` | `VitrineAnuncianteCubit` -> UseCase -> Repo -> `VitrineAnuncianteRemoteDataSource` -> `ImoveisEnvelopeModel` | Sim (UAT 2: 35 e 36 imóveis, 2 páginas) | FLUINDO |

### Verificações comportamentais por amostragem

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Perfis, vitrine do anunciante, DI, contrato, navegação e2e (13 arquivos da fase) | `flutter test test/data/contrato_perfis_test.dart test/data/perfil_model_test.dart test/data/perfil_remote_datasource_test.dart test/data/perfil_repository_impl_test.dart test/data/vitrine_anunciante_remote_datasource_test.dart test/di/injection_perfis_test.dart test/presentation/perfil_corretor_cubit_test.dart test/presentation/perfil_corretor_screen_test.dart test/presentation/perfil_empresa_cubit_test.dart test/presentation/perfil_empresa_screen_test.dart test/presentation/vitrine_anunciante_cubit_test.dart test/presentation/corpo_perfil_com_vitrine_test.dart test/presentation/detalhe_navegacao_test.dart` | 199 testes, `All tests passed!` | PASSOU |
| Suíte completa (rodada pelo orquestrador nesta sessão) | `flutter test` | 774 testes, `All tests passed!`, exit 0 | PASSOU (reportado pelo orquestrador) |
| Segurança | `07-SECURITY.md` | `status: verified`, `threats_open: 0` | PASSOU (lido pelo orquestrador) |
| Cobertura de API | `COVERAGE.md` (gate api-coverage) | 11 capacidades, 4 OPT-OUT com motivo; 7 INTEGRATE conferidos | PASSOU |

### Execução de probes

Não aplicável (a fase não declara probes `scripts/*/tests/probe-*.sh`).

### Cobertura de requisitos

| Requisito | Planos de origem | Descrição | Status | Evidência |
|-----------|------------------|-----------|--------|-----------|
| PERF-01 | 07-05, 07-09, 07-11, 07-12 | Página da empresa: logomarca, CRECI, apresentação, contato, cidades | SATISFEITO | `perfil_empresa_screen.dart`, `chips_cidades_atuacao.dart`; UAT 2/3 |
| PERF-02 | 07-01, 07-02, 07-04, 07-12 | Página do corretor: foto, CRECI, apresentação, contato | SATISFEITO | `perfil_corretor_screen.dart`; UAT 1 |
| PERF-03 | 07-06, 07-08, 07-10, 07-12 | Vitrine do anunciante paginada, recortada e ordenada no servidor | SATISFEITO | `VitrineAnuncianteRemoteDataSource`, `sliver_imoveis_anunciante.dart`; UAT 2 |
| PERF-04 | 07-01, 07-02, 07-03, 07-05, 07-09, 07-11, 07-12 | Perfis pela API pública por DataSource trocável | SATISFEITO | `PerfilRemoteDataSource` ativa no DI |
| PERF-05 | 07-04, 07-05, 07-07, 07-12 | Corretor desativado (404) mostra aviso | SATISFEITO | `AvisoPerfil`; UAT 4 |
| PERF-06 | 07-02, 07-11, 07-12 | Navegação imóvel -> corretor -> empresa | SATISFEITO | e2e em `detalhe_navegacao_test.dart`; UAT 2 |
| API-08 | 07-03, 07-06, 07-08, 07-10, 07-12 | Vitrine do anunciante no contrato (§13) e DataSource real | SATISFEITO | `01-CONTRATO-API.md` §13; `VitrineAnuncianteRemoteDataSource` |

Os 7 IDs do frontmatter dos PLANs existem em `REQUIREMENTS.md` e foram reivindicados por pelo menos um plano. Nenhum requisito órfão: `REQUIREMENTS.md` mapeia exatamente PERF-01..06 e API-08 à Fase 7.

### Anti-padrões encontrados

| Arquivo | Linha | Padrão | Severidade | Impacto |
|---------|-------|--------|------------|---------|
| — | — | Sem `TBD`/`FIXME`/`XXX`/`TODO`/`HACK` em `lib/presentation/perfis`, DataSources, repositórios, models e `domain/` da fase; sem `try/catch` em `presentation/perfis`; `url_launcher` ausente | — | Nenhum |

### Observações (não bloqueantes)

- **Rastreabilidade desatualizada em `.planning/REQUIREMENTS.md`:** PERF-01, PERF-02, PERF-05 e PERF-06 ainda estão `[ ]` (linhas 48, 49, 52, 53) e "Pending" na tabela (linhas 123, 124, 127, 128), enquanto PERF-03, PERF-04 e API-08 já estão `[x]`/"Complete". O código e o UAT mostram os quatro satisfeitos; é só atualização documental a cargo do fechamento de fase, não lacuna de implementação.
- **Rótulo único "Ver página do anunciante"** (refina D-06, suposição A7): confirmado pelo Allysson no UAT 5.
- **Pendências de web que seguem abertas** (§13.7 f, g, h): LGPD do contato, limite de taxa das views de perfil e extensão do seed. São decisões de produto/web registradas, sem efeito nos critérios desta fase.

### Resumo das lacunas

Nenhuma. Todas as verdades observáveis, artefatos e ligações-chave foram confirmados no código atual (DataSources reais ativas no DI, mocks removidos), os testes direcionados e a suíte completa passam, e as verificações humanas do relatório anterior foram cumpridas pelo UAT de 5 testes contra a API real.

---

_Verificado: 2026-11-20_
_Verificador: Claude (gsd-verifier)_
