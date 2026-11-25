---
phase: "12"
slug: "area-do-gestor-acompanhamento-dos-corretores"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-11-25"
---

# Phase 12 — Security

> Contrato de segurança da fase: fronteiras de confiança, registro de ameaças (montado no planejamento, nos `<threat_model>` dos 9 planos), riscos aceitos e trilha de auditoria.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| app autenticado → API Django | o token prova quem é o usuário; `?dias=`, `?de=`, `?ate=` e o papel do usuário são entrada não confiável | token DRF, filtros de período |
| banco multitenant → respostas dos relatórios | só imóveis, corretores e mudanças da empresa do gestor podem sair | números do acervo, contatos por corretor, mudanças de situação (dado de negócio por empresa) |
| máquina do desenvolvedor → repositório do app | fixtures e ferramenta de captura são versionadas; credenciais e tokens não podem atravessar | fixtures JSON versionadas |
| Django temporário → fixtures → contrato | o wire capturado vira a verdade dos testes e do contrato (§18) | fixtures JSON |
| servidor do desenvolvedor (porta 8000, Postgres) | não pode ser tocado nem receber escrita da captura | — |
| app → API autenticada | o token só pode ir para a origem da API, e só pelo `Dio` autenticado | token de sessão (credencial) |
| resposta da API → Models / repositório | JSON, status e corpo são não confiáveis até virarem entidade tipada; nenhuma exceção crua sobe | JSON dos relatórios |
| repositório → Cubit → widgets | só entidades e tipos de falha atravessam; todo texto mostrado é do app | totais, linhas por corretor, mudanças |
| toque do usuário → navegação / pedidos | só o chip de período, o "Tentar de novo" e o Sair reagem | período escolhido |
| papel vindo do servidor → escolha da tela | o app escolhe a área pelo papel de `GET /api/auth/eu/` a cada entrada; quem garante o acesso é o Django | papel do usuário |
| sessão → pilha de navegação | Sair e 401 não podem deixar uma tela logada acessível pelo "voltar" | estado de sessão |
| roteiro humano → Postgres do desenvolvedor | o preparo do UAT escreve no banco real só no checkpoint `blocking-human` da Task 4 do 12-09, pelo Allysson | gestor de teste + `seed_demo` |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-12-01 | Information Disclosure | `acervo_por_corretor` / `mudancas_de_situacao` devolvendo dado de outra empresa | high | mitigate | a empresa é sempre `request.user.empresa_id` (Web/relatorios/api/views.py:36, 74); filtros `empresa_id=` e `imovel__empresa_id=` (servicos.py:111, 118, 140); `AcervoPorCorretorTests`, `MudancasDeSituacaoTests` e `AreaDoGestorApiTests` com a empresa B (tests.py:270, 344, 432) | closed |
| T-12-02 | Elevation of Privilege | corretor ou administrador chamando as rotas novas | high | mitigate | as views herdam `RelatorioApiView` com `permission_classes = [EhGestor]` (views.py:21-22, 32, 66); teste com corretor 403, administrador 403, anônimo 401 e gestor 200 nas 4 rotas do app (`AreaDoGestorApiTests`) | closed |
| T-12-03 | Denial of Service | `?dias=` enorme ou lista de mudanças sem paginação | medium | mitigate | `ler_dias` limita de 1 a 365 (servicos.py:148-154), padrão 7 nas mudanças (views.py:71); lista sem paginação aceita por D-20 (a janela limita o tamanho), registrada no §18.9 do contrato | closed |
| T-12-04 | Information Disclosure | campos internos (proprietário, preço, documentos) no item de mudança | medium | mitigate | `_mudanca` monta só os 9 campos de D-20 (views.py:49-63); testes de chaves exatas com `set(...) == {...}` (tests.py:446-472) | closed |
| T-12-05 | Tampering | `?dias=` malformado derrubando a view | low | mitigate | `ler_dias` levanta `FiltroInvalido` → 400 `{"dias": ...}`; testes de `0`, `366`, `abc`, `-1` (tests.py:375, 512) | closed |
| T-12-06 | Information Disclosure | nome de usuário de outra empresa responsável por imóvel da empresa | low | accept | ver AR-12-01 | closed |
| T-12-07 | Information Disclosure | senhas e tokens nas fixtures ou na ferramenta | high | mitigate | credenciais só por variável de ambiente (`_credencial`, tool/capturar_fixtures_api.py:465); nenhuma fixture dos relatórios com e-mail, senha ou token de 40 hex (grep); nenhuma senha na ferramenta | closed |
| T-12-08 | Tampering | captura escrevendo no Postgres do `Web/.env` ou batendo no `runserver` do desenvolvedor | high | mitigate | captura do grupo gestor no SQLite temporário, servidor na porta 8012, nunca 8000; repo web terminou limpo em `5763b90` (12-02-SUMMARY, linhas 32, 52, 71, 91) | closed |
| T-12-09 | Information Disclosure | relatório de uma empresa trazendo dado de outra, ou corretor vendo os números | high | mitigate | a captura exige 403 do corretor, 401 do anônimo e a empresa B disjunta nas 4 rotas; fixtures `*_outra_empresa.json`; o teste de contrato repete a checagem | closed |
| T-12-10 | Tampering | drift entre o Django e o app | medium | mitigate | `test/data/contrato_area_gestor_test.dart` trava chaves, exemplo = fixture, soma = total e outra empresa disjunta; o Django trava as chaves exatas em `AreaDoGestorApiTests` | closed |
| T-12-11 | Information Disclosure | `toString` de `MudancaRecente` em log ou mensagem de erro | low | mitigate | `toString` só com id, código e de → para, sem nome nem observação (lib/domain/entities/mudancas_recentes.dart:64-67); teste | closed |
| T-12-12 | Tampering | wire malformado ou situação nova virando valor inventado | medium | mitigate | situação desconhecida → `FormatException` na camada de dados (lib/data/models/mudancas_recentes_model.dart:53); campos tipados, sem `dynamic` | closed |
| T-12-13 | Information Disclosure | texto do servidor na linha da empresa | low | mitigate | o Model descarta `corretor` quando o id é nulo (lib/data/models/contatos_por_corretor_model.dart:31); a entidade não carrega o texto (D-17) | closed |
| T-12-14 | Spoofing | token enviado a outra origem ou rota pública | medium | mitigate | só o `Dio` `@Named('autenticado')` (lib/data/datasources/area_gestor_remote_datasource.dart:22); teste confere `Authorization` em todo pedido | closed |
| T-12-15 | Information Disclosure | texto do servidor (detail do 403, 400) chegando à tela | low | mitigate | o repositório devolve só tipos (`SemPermissaoException`, `Failure` genérica); a apresentação escolhe textos fixos | closed |
| T-12-16 | Denial of Service | wire malformado derrubando a tela | medium | mitigate | `_executar` converte `DioException`, `TypeError` e `Exception` em `Failure` (lib/data/repositories/area_gestor_repository_impl.dart:60-82); teste de "nenhum método lança" | closed |
| T-12-17 | Spoofing | 401 ignorado, tela aberta com sessão morta | medium | mitigate | `SessaoExpiradaException` → `sessaoExpirada` terminal (area_gestor_cubit.dart:23, 48, 93); testes de 401 e de respostas atrasadas depois dele | closed |
| T-12-18 | Tampering | resposta de período antigo cobrindo a do período novo | medium | mitigate | versão por seção (`_versaoTotais`…`_versaoMudancas`, area_gestor_cubit.dart:41-44, 85-90); testes com `Completer` fora de ordem | closed |
| T-12-19 | Information Disclosure | texto do servidor mostrado ao usuário | low | mitigate | o Cubit guarda só `FalhaDaSecao`; `textoDaFalha` com `switch` exaustivo e textos fixos (apresentacao_area_gestor.dart:45-49) | closed |
| T-12-20 | Information Disclosure | texto do servidor na tela (linha da empresa, 403) | low | mitigate | `textoLinhaDaEmpresa` e `textoDaFalha` fixos (apresentacao_area_gestor.dart:29, 45); testes de widget | closed |
| T-12-21 | Elevation of Privilege | toque numa linha abrindo tela de gestão fora do card | low | mitigate | nenhum `onTap`/`InkWell`/`GestureDetector`/`ListTile` nas seções (grep vazio em lib/presentation/area_gestor/widgets/); teste com `NavigatorObserver` (test/presentation/secoes_area_gestor_test.dart) | closed |
| T-12-22 | Spoofing | tela logada aberta depois do 401, ou "voltar" reabrindo a área | medium | mitigate | `voltarAoLoginComSessaoTerminada` (lib/presentation/sessao/sessao_expirada.dart:18) chamado pela tela (area_gestor_screen.dart:88); teste do 401 com a rota "Vitrine" embaixo (area_gestor_screen_test.dart:288-351) | closed |
| T-12-23 | Elevation of Privilege | corretor chegando à Área do gestor | high | mitigate | papel vem de `eu` a cada entrada e não é guardado (login_screen.dart:81-82); as 4 rotas dão 403 a quem não é gestor (T-12-02); nenhuma chamada a `/api/relatorios/` fora da área do gestor; UAT teste 1 | closed |
| T-12-24 | Elevation of Privilege | administrador vendo números de alguma empresa | medium | mitigate | `Papel.administrador => AvisoAreaScreen` (login_screen.dart:82); rotas exigem `EhGestor` com empresa (403 testado); UAT teste 6 | closed |
| T-12-25 | Spoofing | 401 ou Sair deixando a Área do gestor na pilha | medium | mitigate | `voltarAoLoginComSessaoTerminada`/`confirmarESair` param em `eRotaDaVitrine` (lib/presentation/sessao/); fluxo ponta a ponta do 401 confere token nulo (area_gestor_fluxo_test.dart:349-367) | closed |
| T-12-26 | Tampering | script do UAT escrevendo no Postgres sem controle | low | mitigate | `criar_gestor_vitrine.py` fora dos repositórios (na Área de Trabalho, nem no histórico do git) e rodado só pelo Allysson no checkpoint `blocking-human`; conferido no UAT teste 8 | closed |
| T-12-SC | Tampering | dependências (supply chain) | low | mitigate | nenhum pacote novo: `Web/requirements.txt` igual a `e2d1fa0`; `pubspec.yaml`/`pubspec.lock` sem diferença para `feat/APP10` | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-12-01 | T-12-06 | O nome de um usuário de outra empresa só apareceria no acervo por corretor se ele fosse `corretor_responsavel` de um imóvel desta empresa, o que já é dado da própria empresa; o cadastro do site não cria esse caso. | Planejamento da Phase 12 (plano aceito pelo Allysson) | 2026-11-25 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-25 | 27 | 27 | 0 | orquestrador /gsd-secure-phase (L1, grep nas mitigações dos 2 repositórios + Threat Flags dos 9 SUMMARYs; auditor dispensado: registro do planejamento, ASVS 1, 0 abertas) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-11-25
