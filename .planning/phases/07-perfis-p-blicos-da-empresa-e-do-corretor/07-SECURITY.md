---
phase: "07"
slug: "perfis-p-blicos-da-empresa-e-do-corretor"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
block_on: high
created: "2026-11-20"
---

# Phase 07 — Security

> Contrato de segurança da fase: registro de ameaças, riscos aceitos e trilha de auditoria.
> Auditado sobre o código atual (main 48eb08b, já com a fase 07.1). A 07.1 trocou os mocks
> (`lib/data/mocks/`, apagados pela APP-05 em 7d2d447) pela API real; nas ameaças cuja mitigação
> original vivia no mock, a evidência abaixo é a mitigação que vale hoje (ver `07.1-SECURITY.md`).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| servidor -> app | perfis do corretor/empresa, linhas da vitrine do anunciante e cursor `next` | JSON não confiável |
| data -> domain / presentation | só entidades (`PerfilCorretor`, `PerfilEmpresa`, `PaginaImoveis`) e `Result` cruzam; widgets nunca veem mapas de wire | entidades tipadas |
| detalhe -> perfil do corretor | só o `CorretorResponsavel` já público no detalhe (id, nome, foto) | dado público |
| perfil do corretor -> página da empresa | só o `empresa_id` (int) | id tipado |
| perfil -> vitrine | a vitrine do anunciante só existe com o perfil 200 | — |
| contrato app <-> web | o contrato da API é a forma de wire das duas frentes | allowlist de chaves |
| app -> usuário | o que a tela mostra de anunciante desativado e como o contato aparece | e-mail, telefone, WhatsApp, CRECI (públicos) |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-07-01 | Tampering | `PerfilCorretorModel.paraEntidade` (foto) | medium | mitigate | `foto: urlHttpOuNula(foto)` (`lib/data/models/perfil_corretor_model.dart:41`); `url_segura.dart:8` | closed |
| T-07-02 | Denial of Service | JSON de perfil malformado | low | mitigate | repositório devolve `Result.failure` (`perfil_repository_impl.dart:44-53`) | closed |
| T-07-03 | Elevation of Privilege | localizador de serviços em widgets | low | mitigate | `getIt` em `perfis/` só dentro de `abrirPerfilCorretor` (`perfil_corretor_screen.dart:31-42`) | closed |
| T-07-04 | Information Disclosure | prévia do corretor | low | accept | AR-07-01 | closed |
| T-07-05 | Tampering | drift do contrato dos perfis | medium | mitigate | `test/data/contrato_perfis_test.dart` (19 testes: allowlists e igualdade exemplo x fixture, com o caso "sujo") | closed |
| T-07-06 | Information Disclosure | enumeração de ids de corretor/empresa | low | accept | AR-07-02 | closed |
| T-07-07 | Information Disclosure | `PerfilCorretorScreen` no 404 | low | mitigate | ramo `PerfilNaoEncontrado` sem prévia (`perfil_corretor_screen.dart:165,180`); teste `corretor desativado` (`test/presentation/detalhe_navegacao_test.dart:1134`) | closed |
| T-07-08 | Tampering | contato renderizado | medium | mitigate | `SecaoContato` só com `SelectableText` (`lib/presentation/perfis/widgets/secoes_perfil.dart:27,71`); zero `url_launcher`/`tel:`/`mailto:`/`wa.me` em `lib/` e no pubspec | closed |
| T-07-09 | Information Disclosure | exposição pública de e-mail/telefone/WhatsApp/CRECI (LGPD) | medium | transfer | transferido à web/produto: já público pela WEB 02; registrado como PENDENTE WEB (f) no contrato (mesmo risco de AR-07.1-01) | closed |
| T-07-10 | Denial of Service | apresentação muito longa/caracteres de controle | low | accept | AR-07-03 | closed |
| T-07-11 | Spoofing | decisão de 404 na UI | low | mitigate | Cubit decide por `erro is PerfilNaoEncontradoException` (`perfil_corretor_cubit.dart:54`, `perfil_empresa_cubit.dart:54`); zero `try`/`catch` em `lib/presentation/` | closed |
| T-07-12 | Denial of Service | JSON malformado / corpo não-objeto | medium | mitigate | `on TypeError` -> `FormatException` (`perfil_repository_impl.dart:50-53`); corpo `is! Map` -> `FormatException` (`perfil_remote_datasource.dart:42-43`) | closed |
| T-07-13 | Information Disclosure | log do corpo (e-mail/telefone) | low | mitigate | zero `LogInterceptor` em `lib/`; `lib/di/modulo_rede.dart:16` sem interceptors | closed |
| T-07-14 | Spoofing | interpretação do 404 | low | mitigate | `DioException` lida só em `data/` (`perfil_repository_impl.dart:44-45`); nenhum `statusCode`/`DioException` em `presentation/` ou `domain/` | closed |
| T-07-15 | Information Disclosure | tráfego em texto claro | low | accept | AR-07-04 | closed |
| T-07-16 | Tampering | `logomarca` | medium | mitigate | `logomarca: urlHttpOuNula(logomarca)` (`perfil_empresa_model.dart:55`); testes com `javascript:` | closed |
| T-07-17 | Information Disclosure | lista de corretores da empresa | low | mitigate | `corretores_ativos` não declarado no Model (`perfil_empresa_model.dart:12-13`) | closed |
| T-07-18 | Denial of Service | `tipo` desconhecido | low | mitigate | `switch (tipo) { ... _ => null }` (`perfil_empresa_model.dart:44-47`) | closed |
| T-07-19 | Information Disclosure | linhas da vitrine do anunciante | medium | mitigate | hoje o servidor serve só `ImovelVitrineSerializer` (T-07.1-05) e `ImovelModel` só declara campos do cartão, sem `corretor`/`empresa`/`proprietario` | closed |
| T-07-20 | Tampering | `next` de outra origem | medium | transfer | transferido à DataSource real, entregue na 07.1: `_exigirMesmaOrigem` (`vitrine_anunciante_remote_datasource.dart:34,50`) + teste de host/porta estranhos (T-07.1-01/23) | closed |
| T-07-21 | Denial of Service | cursor/params malformados | low | mitigate | a DataSource real lança `FormatException` (`vitrine_anunciante_remote_datasource.dart:41,58`) -> `Result.failure` -> estado de erro com retry | closed |
| T-07-22 | Information Disclosure | dados do corretor desativado | low | mitigate | mock do id 99 substituído pelo 404 do servidor (T-07.1-07/08); a tela do 404 não mostra a prévia nem pede a vitrine (teste `corretor desativado`) | closed |
| T-07-23 | Tampering | edição da fixture do detalhe compartilhada com a Phase 5 | low | mitigate | guarda aplicada na execução (07-07); o arquivo `imoveis_detalhe_fixture.dart` foi removido pela APP-05 (7d2d447), então não há mais superfície | closed |
| T-07-24 | Elevation of Privilege | localizador de serviços | low | mitigate | `getIt` só em `abrirPerfilCorretor` (`perfil_corretor_screen.dart:40,42`) | closed |
| T-07-25 | Information Disclosure | consulta de imóveis de corretor desativado | low | mitigate | `BlocProvider` preguiçoso; `SliverImoveisDoAnunciante` só no ramo `PerfilCarregado` (`perfil_corretor_screen.dart:176`); teste sem requisição a `/corretores/<id>/imoveis/` após 404 | closed |
| T-07-26 | Tampering | caminho da busca da empresa | low | accept | AR-07-05 | closed |
| T-07-27 | Tampering | drift do contrato da empresa | medium | mitigate | `contrato_perfis_test.dart` (chaves da empresa e coerência corretores x empresas) | closed |
| T-07-28 | Denial of Service | paginação em laço | low | mitigate | guardas em `VitrineAnuncianteCubit.carregarMais` (`carregandoMais`, `erroAoCarregarMais`, `proximaPagina == null`); retry só pelo botão | closed |
| T-07-29 | Tampering | cursor da vitrine | low | mitigate | nenhum `Uri.parse`/leitura de `next` em `lib/presentation/`; o Cubit só repassa `proximaPagina` à camada de dados | closed |
| T-07-30 | Elevation of Privilege | localizador de serviços | low | mitigate | `getIt` em `perfis/` só nos dois `abrir*` (`perfil_corretor_screen.dart:31`, `perfil_empresa_screen.dart:35`) | closed |
| T-07-31 | Spoofing | tipo do anunciante deduzido no aparelho | low | mitigate | `rotuloTipoEmpresa` usado só em `perfil_empresa_screen.dart:194`; o tipo vem da API da empresa | closed |
| T-07-32 | Tampering | contato da empresa | medium | mitigate | mesma `SecaoContato` (só `SelectableText`); guarda de pacote/esquema de link vazia | closed |
| T-07-33 | Information Disclosure | vitrine de empresa inativa | low | mitigate | `SliverImoveisDoAnunciante` só no ramo `PerfilCarregado` (`perfil_empresa_screen.dart:150`); o servidor dá 404 para empresa inativa (T-07.1-07) | closed |
| T-07-34 | Tampering | drift de arquivos fora da fase | low | mitigate | guarda `git diff --exit-code` contra `ba77b1e` aplicada na execução (07-12); depois disso, as mudanças vieram do merge da APP-05 na 07.1, de propósito | closed |
| T-07-SC | Tampering | instalação de pacotes | low | accept | AR-07-06; `git diff ba77b1e HEAD -- pubspec.*` vazio | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-07-01 | T-07-04 | Nome e foto da prévia já são públicos no detalhe do imóvel; nenhum dado novo aparece antes da resposta do perfil. | Allysson (plano 07-02) | 2026-11-08 |
| AR-07-02 | T-07-06 | O servidor responde com o mesmo 404 para id inexistente e desativado (T-07.1-07 fecha isso no Django); o app não cria canal novo de enumeração. | Allysson (plano 07-03) | 2026-11-08 |
| AR-07-03 | T-07-10 | Apresentação em texto puro com quebra normal; não truncar para não esconder dado do anunciante. | Allysson (plano 07-04) | 2026-11-08 |
| AR-07-04 | T-07-15 | `usesCleartextTraffic` só no manifest de debug (`android/app/src/debug/AndroidManifest.xml:8`); o build de release exige HTTPS. | Allysson (plano 07-05) | 2026-11-08 |
| AR-07-05 | T-07-26 | Só um `int` tipado entra no caminho da busca da empresa, sem texto do usuário. | Allysson (plano 07-09) | 2026-11-08 |
| AR-07-06 | T-07-SC | Nenhum pacote novo na fase (RESEARCH, Package Legitimacy Audit); `pubspec.yaml`/`pubspec.lock` intactos. | Allysson (planos 07-01..07-12) | 2026-11-08 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-20 | 35 | 35 | 0 | /gsd-secure-phase (orquestrador, verificação L1 por grep no código atual) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-11-20
