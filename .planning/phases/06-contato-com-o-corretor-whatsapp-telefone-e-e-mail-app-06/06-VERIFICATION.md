---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
verified: 2026-11-22T14:00:00Z
status: passed
re_verified: 2026-11-23T22:00:00Z
score: 6/6 must-haves verified
covered_files: [".planning/REQUIREMENTS.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-01-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-01-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-02-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-02-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-03-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-03-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-04-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-04-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-05-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-05-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-06-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-06-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-07-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-07-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-08-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-08-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-09-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-09-SUMMARY.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-10-PLAN.md", ".planning/phases/06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06/06-10-SUMMARY.md", "lib/data/datasources/contato_remote_datasource.dart", "lib/data/gateways/url_launcher_gateway_impl.dart", "lib/data/repositories/contato_repository_impl.dart", "lib/domain/usecases/contatar_corretor_usecase.dart", "lib/presentation/contato/contato_cubit.dart", "lib/presentation/contato/widgets/barra_contato.dart", "lib/presentation/contato/widgets/contato_bottom_sheet.dart", "lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart", "lib/presentation/detalhe_imovel/perfil_corretor_screen.dart"]
covered_digest: "v1:sha256:e7882c69d7fc29fdfc8a281d64c3352b0164ea69def20d97bcbf02d0ed4dbac9"
behavior_unverified: 0
overrides_applied: 0
---

# Fase 6: Contato com o Corretor (APP 06) — Relatório de Verificação

**Objetivo da fase:** O visitante fala com o corretor com um toque, sem login e sem formulário: na página do imóvel e no perfil do corretor, o botão de WhatsApp (e as alternativas telefone e e-mail) dispara `POST /api/publico/imoveis/{id}/contato/` (WEB 11), que registra o contato (imóvel, corretor, canal) e devolve o link pronto — com a mensagem padrão montada pelo servidor — que o app apenas abre.
**Verificado em:** 2026-11-22
**Status:** passed
**Re-verificação:** Não — verificação inicial

## Alcance do Objetivo

### Verdades Observáveis (Critérios de Sucesso do ROADMAP)

| #   | Verdade | Status | Evidência |
| --- | ------- | ------ | --------- |
| 1 | Botão de contato na página do imóvel e no perfil do corretor | ✓ VERIFIED | `detalhe_imovel_screen.dart:84-98` monta `BarraContato` em `bottomNavigationBar` só com `DetalheCarregado` e `canaisContato.isNotEmpty`. `perfil_corretor_screen.dart:81-86` monta a mesma `BarraContato` com legenda "Sobre: <título>", com `BlocProvider<ContatoCubit>` próprio (linhas 40-41). Testes de widget em `detalhe_imovel_screen_test.dart` e `perfil_corretor_screen_test.dart` passam. UAT #1, #2, #7. |
| 2 | O botão abre o WhatsApp com a mensagem padrão já preenchida | ✓ VERIFIED | O app não monta mensagem: `ContatoRemoteDataSource.registrar` envia só `{'canal': ...}`; `ContatarCorretorUseCase` abre o `Uri` devolvido pelo servidor via `UrlLauncherGatewayImpl` (`LaunchMode.externalApplication`). `ContatoRepositoryImpl._linkSeguro` exige `https://wa.me`. No servidor, `contatos/servicos.py:48` monta `https://wa.me/<dígitos>?text=...` com `quote_via=quote` (espaço vira `%20`, nunca `+`) a partir de `MENSAGEM_PADRAO`. UAT #1 (WhatsApp real no emulador, mensagem preenchida com espaços), #24, #25. |
| 3 | Telefone e e-mail como alternativas de contato | ✓ VERIFIED | `BarraContato` mostra o primeiro canal da ordem fixa WhatsApp, Telefone, E-mail como botão principal e os demais no `⋮` (`contato_bottom_sheet.dart`: "Outras formas de contato"). O repositório aceita `tel:` e `mailto:` por canal. UAT #3 ("Ligar" abre o discador) e #4 ("Enviar e-mail" abre o app de e-mail). |
| 4 | O contato é registrado na API no momento em que o visitante o dispara | ✓ VERIFIED | `ContatoCubit.contatar` -> `ContatarCorretorUseCase.call` -> `ContatoRepositoryImpl.registrarContato` -> `ContatoRemoteDataSource.registrar` (`_dio.post` em `caminhoContatoImovelPublico(id)`). A ordem é registro primeiro, abertura depois; falha no registro não abre nada (teste do caso de uso e UAT #26). No servidor, `ContatoPublicoAPIView.post` chama `registrar_contato` a cada POST. UAT #9 (registros vistos em `/painel/contatos/`), #11. |
| 5 | O registro guarda o imóvel, o corretor e o canal usado | ✓ VERIFIED | `contatos/servicos.py::registrar_contato` faz `Contato.objects.create(empresa_id=..., imovel=imovel, corretor=corretor, canal=canal)`. O corretor é `None` quando está desativado e a empresa atende (UAT #8). UAT #9 confirmou imóvel, corretor e canal corretos no painel do servidor. |
| 6 | Tudo funciona sem login | ✓ VERIFIED | App: `lib/di/modulo_rede.dart` declara Dio sem interceptors e sem autenticação; o datasource não passa `Options` nem cabeçalhos; teste de contrato (UAT #21) trava que o POST sai sem `Authorization`/`Cookie`. Servidor: `ContatoPublicoAPIView` com `permission_classes=[AllowAny]` e `authentication_classes=[]`. |

**Pontuação:** 6/6 verdades verificadas (0 presentes mas sem verificação comportamental)

### Verdades adicionais dos PLANs (APP06-API-1, APP06-API-2)

| Verdade | Status | Evidência |
| ------- | ------ | --------- |
| `GET /api/publico/imoveis/{id}/` expõe `canais_contato` só com nomes dos canais (nunca número, e-mail ou link) | ✓ VERIFIED | `imoveis/api/serializers.py:565-604` (`get_canais_contato` devolve `[str(canal) ...]` de `canais_disponiveis`, na ordem fixa WHATSAPP/TELEFONE/EMAIL). `imoveis/tests.py:2215` inclui `canais_contato` na allowlist exata do detalhe público; testes das linhas 2337-2359 cobrem ordem, subconjunto e vazio. UAT #12, #16. |
| POST de contato tem throttle próprio (`ThrottleContatoPublico`, escopo `contato_publico`, 10/min por IP), isolado do balde da vitrine, 429 ao exceder | ✓ VERIFIED | `core/throttles.py:16-25`, `config/settings.py:148,175` (`CONTATO_TAXA_ANONIMA` padrão `10/min`, validada por regex), `ContatoPublicoAPIView.throttle_classes = [ThrottleContatoPublico]`. Testes em `contatos/tests.py:430-478`. UAT #13, #14. |
| Verdades comportamentais: ordem registro-antes-da-abertura, guarda de toque duplo, falha tipada sem abrir link | ✓ VERIFIED | Cobertas por testes que exercitam o comportamento (não só presença): `contatar_corretor_usecase_test.dart`, `contato_cubit_test.dart` (bloc_test), `barra_contato_test.dart`; rodei estes testes (149 passam) e ainda UAT #5, #6, #26, #27 no dispositivo. |

### Artefatos Obrigatórios

| Artefato | Esperado | Status | Detalhes |
| -------- | -------- | ------ | -------- |
| `lib/data/datasources/contato_remote_datasource.dart` | POST anônimo com `{canal}` | ✓ VERIFIED | Substantivo, ligado por DI (`injection.config.dart:114`) |
| `lib/data/repositories/contato_repository_impl.dart` | Falhas tipadas (400/404/429) + validação do link por canal | ✓ VERIFIED | `injection.config.dart:145` |
| `lib/domain/usecases/contatar_corretor_usecase.dart` | Registro, depois abertura | ✓ VERIFIED | Injetado no `ContatoCubit` |
| `lib/data/gateways/url_launcher_gateway_impl.dart` | `launchUrl` externo, falha vira `false` | ✓ VERIFIED | `LinkLauncherGateway` no domínio, `url_launcher` no `pubspec.yaml` |
| `lib/presentation/contato/contato_cubit.dart` + `contato_state.dart` | Estados ocioso/enviando/falhou, trava de toque duplo | ✓ VERIFIED | `injection.config.dart:204` |
| `lib/presentation/contato/widgets/barra_contato.dart` | Barra com canal principal, spinner e SnackBar | ✓ VERIFIED | Usada nas duas telas |
| `lib/presentation/contato/widgets/contato_bottom_sheet.dart` | Sheet com canais restantes | ✓ VERIFIED | Usado por `BarraContato` |
| `lib/domain/entities/canal_contato.dart`, `data/models/canal_contato_api.dart`, `contato_registrado_model.dart` | Enum de canais, parse tolerante, modelo do POST | ✓ VERIFIED | `detalhe_imovel_model.dart:93` filtra nomes desconhecidos |
| API: `contatos/api/views.py`, `contatos/servicos.py`, `core/throttles.py`, `imoveis/api/serializers.py` (branch `feat/APP06`) | POST público, links, throttle, `canais_contato` | ✓ VERIFIED | Branch atual `feat/APP06`; `main` + merge WEB-11 + commit `420bcaf` |

### Verificação de Ligações-Chave

| De | Para | Via | Status | Detalhes |
| -- | ---- | --- | ------ | -------- |
| `DetalheImovelScreen` | `BarraContato` | `BlocProvider<ContatoCubit>` + `bottomNavigationBar` | ✓ WIRED | Só com detalhe carregado e canais |
| `PerfilCorretorScreen` | `BarraContato` | `BlocProvider<ContatoCubit>` próprio | ✓ WIRED | Contato passado pelo cartão do corretor |
| `BarraContato` / sheet | `ContatoCubit.contatar` | `context.read` capturado antes do modal | ✓ WIRED | |
| `ContatoCubit` | `ContatarCorretorUseCase` | injeção | ✓ WIRED | |
| `ContatarCorretorUseCase` | `ContatoRepository` + `LinkLauncherGateway` | injeção | ✓ WIRED | |
| `ContatoRemoteDataSource` | `POST /api/publico/imoveis/{id}/contato/` | `Dio.post` | ✓ WIRED | Rota em `config/urls.py:20` (`api/publico/`) |
| `ContatoPublicoAPIView` | `Contato` (imóvel, corretor, canal) | `registrar_contato` | ✓ WIRED | |

### Rastreio de Fluxo de Dados (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
| -------- | -------- | ----- | ----------- | ------ |
| `BarraContato` | `canais` | `detalhe.canaisContato` <- `canais_contato` do GET real (`canais_disponiveis`) | Sim | ✓ FLOWING |
| `UrlLauncherGatewayImpl` | `link` | `link` do POST real, validado por canal | Sim (fixtures recapturadas da API real, UAT #15, #17) | ✓ FLOWING |

### Verificações Comportamentais

| Comportamento | Comando | Resultado | Status |
| ------------- | ------- | --------- | ------ |
| Testes de contato do app (datasource, repositório, contrato, caso de uso, cubit, barra, telas, gateway) | `flutter test` nos 9 arquivos de contato | 149 passam, nenhum falha | ✓ PASS |
| Suíte completa do app | `flutter test` (evidência do orquestrador) | 716 passam | ✓ PASS |
| Análise estática | `flutter analyze` (evidência do orquestrador) | Sem problemas | ✓ PASS |
| Link do WhatsApp com `%20` | `MensagemDoWhatsAppComEspacosTests` (evidência do orquestrador) | 3 testes OK | ✓ PASS |
| Testes Django locais | `python manage.py test contatos` | Não executado por mim: o ambiente do verificador não tem Django instalado. Coberto pela evidência do orquestrador e pela leitura do código do servidor | ? SKIP (coberto) |

### Execução de Probes

Nenhum probe declarado nos PLANs desta fase (`scripts/*/tests/probe-*.sh` inexistente). Passo ignorado.

### Cobertura de Requisitos

Todos os 8 IDs aparecem no frontmatter `requirements` dos PLANs e em `REQUIREMENTS.md`; nenhum requisito órfão (a seção "Planos da Phase 6" de REQUIREMENTS.md bate com os PLANs).

| Requisito | Planos | Descrição | Status | Evidência |
| --------- | ------ | --------- | ------ | --------- |
| APP06-C1 | 06-07, 06-09, 06-10 | Botão de contato no imóvel e no perfil do corretor | ✓ SATISFIED | Verdade 1 |
| APP06-C2 | 06-02..06-07, 06-10 | WhatsApp com mensagem padrão preenchida | ✓ SATISFIED | Verdade 2 |
| APP06-C3 | 06-03..06-06, 06-08..06-10 | Telefone e e-mail como alternativas | ✓ SATISFIED | Verdade 3 |
| APP06-C4 | 06-01, 06-03, 06-05..06-08, 06-10 | Contato registrado na API ao disparar | ✓ SATISFIED | Verdade 4 |
| APP06-C5 | 06-01, 06-09, 06-10 | Registro guarda imóvel, corretor e canal | ✓ SATISFIED | Verdade 5 |
| APP06-C6 | 06-01, 06-02, 06-05, 06-07, 06-09, 06-10 | Sem login | ✓ SATISFIED | Verdade 6 |
| APP06-API-1 | 06-01, 06-03, 06-04, 06-10 | `canais_contato` no detalhe público, só nomes, na allowlist | ✓ SATISFIED | Verdade adicional 1 |
| APP06-API-2 | 06-02, 06-10 | Throttle próprio `contato_publico` 10/min, 429 | ✓ SATISFIED | Verdade adicional 2 |

### Anti-padrões Encontrados

Varredura de `TBD|FIXME|XXX|TODO|HACK` nos arquivos de implementação da fase: nenhuma ocorrência. Nenhum `print`/`log` de link, número ou e-mail nos arquivos de contato. `UrlLauncherGatewayImpl` captura `Error` (IN-02 do review), decisão consciente e documentada no comentário da classe.

| Arquivo | Linha | Padrão | Severidade | Impacto |
| ------- | ----- | ------ | ---------- | ------- |
| (nenhum bloqueador) | — | — | — | — |

### Observações Consultivas (06-REVIEW.md: 0 críticos, 5 avisos, 7 informativos)

Não bloqueiam o objetivo; ficam como acompanhamento:

- WR-01: o throttle do POST pode ser contornado pelo endpoint de formulário do site, que não tem limite. Não afeta nenhum critério da fase.
- WR-03: a trava de toque duplo é por tela; página do imóvel e perfil podem registrar o mesmo contato duas vezes se o visitante navegar entre elas. Registro duplicado, mas ambos são contatos reais disparados pelo visitante.
- WR-04 e WR-05: robustez de layout com texto grande e limite de 10/min atrás de NAT de operadora. Risco de UX/operação, não de objetivo.

### Verificação Humana

Nenhum item pendente. A verificação humana de dispositivo já foi concluída em `06-UAT.md` (status `complete`, 27/27 aprovados, 0 problemas), cobrindo: WhatsApp pré-preenchido com espaços, aparência da barra, `⋮` com Ligar e Enviar e-mail abrindo discador e app de e-mail, spinner/desabilitado durante o POST, SnackBar de falha sem expor dados de contato, contato pelo perfil do corretor, imóvel com corretor desativado usando canais da empresa e registros corretos em `/painel/contatos/`.

### Resumo de Lacunas

Nenhuma lacuna. Os seis critérios do ROADMAP e os oito IDs de requisito têm evidência no código (cadeia completa Cubit -> caso de uso -> repositório -> datasource -> POST público -> `Contato.objects.create` -> link -> `launchUrl`), em testes automatizados que exercitam o comportamento e no UAT de dispositivo. Limitação registrada: não reexecutei os testes Django (ambiente sem Django); confiei na evidência do orquestrador e na leitura direta do código do servidor.

---

_Verificado: 2026-11-22_
_Verificador: Claude (gsd-verifier)_
