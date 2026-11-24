---
phase: "10"
slug: "contatos-recebidos-e-retorno-anotado"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-11-24"
---

# Phase 10 — Security

> Contrato de segurança da fase: fronteiras de confiança, registro de ameaças (montado no planejamento, nos `<threat_model>` dos 10 planos), riscos aceitos e trilha de auditoria.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| app autenticado → API Django | o token prova quem é o usuário; query string (`imovel`, `de`, `ate`, `page`, `page_size`), o id na URL e o corpo do PATCH são entrada não confiável | token DRF, filtros, retorno anotado |
| banco multitenant → respostas da caixa | só contatos (e imóveis/contagem derivados deles) da empresa e do perfil do usuário podem sair | contatos de clientes interessados (dado de negócio por empresa) |
| app → API autenticada | o token sai do aparelho e só pode ir para a origem da base URL | token de sessão (credencial) |
| resposta da API → Models / repositório | JSON, status e corpo são não confiáveis até virarem entidade tipada; nunca sobem como exceção crua para a UI | JSON da caixa |
| dados do servidor → texto na tela | só enums e datas atravessam; todo texto mostrado é do app | canal, retorno, datas |
| toque do usuário → PATCH | uma escolha vira mudança de estado no servidor; o app não decide o resultado | retorno anotado |
| sessão do app → telas autenticadas | um 401 tem de tirar o usuário da área autenticada | estado de sessão |
| Django temporário → fixtures → contrato | o wire capturado vira a verdade dos testes e do contrato; credenciais e tokens não podem atravessar para o repositório | fixtures JSON versionadas |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-10-01 | Information Disclosure | `ContatoViewSet.resumo`/`imoveis` e lista com `?imovel=` de outra empresa | high | mitigate | ações partem de `contatos_visiveis_para(request.user)`; lista com `restringir_ao_perfil` (views.py:84, 95, 101); `IsolamentoTests`, `ResumoSemRetornoTests`, `OpcoesDeImovelDaCaixaTests` | closed |
| T-10-02 | Tampering | `PATCH /api/contatos/<id>/` de outro corretor/empresa (IDOR) | high | mitigate | `get_queryset` filtrado → 404 sem revelar existência; `test_trocar_o_id_na_url_cai_em_404` verde | closed |
| T-10-03 | Information Disclosure | `PATCH {}` → `KeyError`/traceback | medium | mitigate | `ContatoSerializer.validate` → 400 `{"retorno": [...]}`; teste em `AnotarRetornoTests` | closed |
| T-10-04 | Elevation of Privilege | administrador nas rotas novas | medium | mitigate | `permission_classes = [PertenceAUmaEmpresa]` vale para as `@action`; testes 403 (admin) e 401 (anônimo) | closed |
| T-10-05 | Denial of Service | lista inteira / tamanho escolhido pelo cliente | medium | mitigate | `PaginacaoContatos` com `page_size` fixo 20, sem `page_size_query_param`; teste de `?page_size=50` ignorado | closed |
| T-10-06 | Denial of Service | `imoveis/` sem paginação para gestor com acervo grande | low | accept | ver Accepted Risks Log (AR-10-01) | closed |
| T-10-07 | Information Disclosure | senhas/token nas fixtures ou na ferramenta de captura | high | mitigate | credenciais só por variável de ambiente (`os.environ`, 7 usos), nenhum e-mail/senha literal em `tool/capturar_fixtures_api.py` (grep 0); token só em memória | closed |
| T-10-08 | Tampering | drift entre Django e app | medium | mitigate | `contrato_contatos_test.dart` trava chaves exatas, exemplo = fixture byte a byte e caixa da outra empresa não vazia e disjunta | closed |
| T-10-09 | Information Disclosure | captura contra o banco real do `Web/.env` | medium | mitigate | SQLite temporário com `DATABASE_URL` explícito, apagado no fim; repo web conferido limpo (10-02) | closed |
| T-10-10 | Information Disclosure | contato de outra empresa no wire | high | mitigate | captura exige `count == 1` na caixa da empresa B e falha se o contato da B aparecer na A (`ErroCaptura`, capturar_fixtures_api.py:637-644) | closed |
| T-10-11 | Tampering | `canal`/`retorno` fora do conjunto conhecido | low | mitigate | `canalContatoDaApi`/`retornoContatoDaApi` lançam `FormatException`; teste com valor desconhecido | closed |
| T-10-12 | Information Disclosure | dados de exibição vindos do servidor | low | mitigate | Model não lê `*_exibicao` nem `corretor_nome`; gate de grep em `lib` vazio | closed |
| T-10-13 | Information Disclosure | token enviado a outra origem via `next` | high | mitigate | `mesmaOrigem` no `seguir` antes de qualquer requisição (caixa_contatos_remote_datasource.dart:40); teste sem requisição gravada | closed |
| T-10-14 | Information Disclosure | rota da caixa no `Dio` público ou token em log | high | mitigate | DataSource só com `@Named('autenticado')`; nenhum `LogInterceptor` em `lib` (grep vazio); teste confere `Authorization` | closed |
| T-10-15 | Tampering | PATCH sem barra final seguindo redirecionamento | low | mitigate | caminho `/api/contatos/$id/` fixo + `followRedirects: false`; teste do caminho exato | closed |
| T-10-16 | Spoofing | 401 ignorado deixando estado autenticado falso | medium | mitigate | `SessaoExpiradaException` tipada em todos os métodos do repositório (teste por método) | closed |
| T-10-17 | Denial of Service | exceção não tratada derrubando a tela | low | mitigate | `_executar` converte toda exceção em `Failure`, inclusive `TypeError` | closed |
| T-10-18 | Spoofing | 401 na lista, na página seguinte ou na contagem | medium | mitigate | `CaixaSessaoExpirada` terminal + `BlocListener` → `encerrarPorExpiracao()` e login com aviso; Cubit, tela e fluxo ponta a ponta | closed |
| T-10-19 | Information Disclosure | mensagens/rótulos vindos do servidor | low | mitigate | textos fixos em `apresentacao_contatos.dart`, `switch` exaustivo | closed |
| T-10-20 | Tampering | número de sem retorno calculado no aparelho | medium | mitigate | `semRetorno` só recebe o inteiro do servidor; sem aritmética no Cubit; teste de versão do resumo | closed |
| T-10-21 | Elevation of Privilege | gestor alcançando a caixa pelo app | low | accept | ver Accepted Risks Log (AR-10-02); confirmado no UAT (gestor vê só a tela de aviso) | closed |
| T-10-22 | Tampering | parâmetros `imovel`/`de`/`ate` | low | mitigate | id só das opções do servidor; datas formatadas em `data/`; servidor valida e recorta | closed |
| T-10-23 | Information Disclosure | imóvel de outra empresa nas opções | low | mitigate | opções vêm de `GET /api/contatos/imoveis/` com `contatos_visiveis_para`; o app não monta a lista | closed |
| T-10-24 | Spoofing | 401 ao abrir as opções | medium | mitigate | `carregarOpcoesDeImovel` → `CaixaSessaoExpirada` terminal; `pushAndRemoveUntil` remove a folha | closed |
| T-10-25 | Tampering | retorno decidido no aparelho (otimismo) / número decrementado localmente | medium | mitigate | item trocado só no 200 pelo item do servidor; resumo pedido de novo após sucesso e 404; testes sem emissão otimista | closed |
| T-10-26 | Denial of Service | toques repetidos gerando PATCHs em série | low | mitigate | `anotando` por id ignora novo toque; item com toque desligado em voo; teste de duplo toque | closed |
| T-10-27 | Information Disclosure | texto do servidor na SnackBar | low | mitigate | `textoDoAviso` com `switch` exaustivo e textos fixos (D-17) | closed |
| T-10-28 | Spoofing | 401 no PATCH | medium | mitigate | `SessaoExpiradaException` → `CaixaSessaoExpirada` terminal → login com aviso | closed |
| T-10-SC | Tampering | dependências (supply chain) | low | mitigate | nenhum pacote instalado na web (`Web/requirements.txt` inalterado); no app só `flutter_localizations` (SDK), lock com 1 linha | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-10-01 | T-10-06 | `GET /api/contatos/imoveis/` não é paginado; o volume fica limitado aos imóveis com contato visível ao usuário, e o app só oferece a caixa ao corretor (D-03). Risco registrado no §16 do contrato para a APP-12 (área do gestor). | Planejamento da Phase 10 (plano aceito pelo Allysson) | 2026-11-24 |
| AR-10-02 | T-10-21 | O gestor não alcança a caixa pelo app: a entrada só existe no `AcervoScreen`, que só o corretor vê; a API já atende o gestor com o escopo da empresa (D-03). Confirmado no UAT de 24/11/2026. | Planejamento da Phase 10 (plano aceito pelo Allysson) | 2026-11-24 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-24 | 29 | 29 | 0 | orquestrador /gsd-secure-phase (L1, grep nas mitigações de severidade alta + Threat Flags dos 10 SUMMARYs; auditor dispensado: registro do planejamento, ASVS 1, 0 abertas) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-11-24
