---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 12
subsystem: presentation/perfis
tags: [flutter, cubit, perfil-empresa, vitrine-anunciante, e2e, fechamento-de-fase]
status: complete
requires:
  - phase: 07-11
    provides: PerfilEmpresaCubit, abrirPerfilEmpresa, PerfilEmpresaScreen (cabecalho), CartaoEmpresa, rotuloTipoEmpresa
  - phase: 07-10
    provides: CorpoPerfilComVitrine, RodapePaginacaoLista, carregarMais
  - phase: 07-08
    provides: VitrineAnuncianteCubit, SliverImoveisDoAnunciante
  - phase: 07-04
    provides: SecaoApresentacao, SecaoContato, linhasDeContato
provides:
  - ChipsCidadesAtuacao (secao "Cidades de atuacao", Chip "Cidade, UF")
  - Pagina da empresa completa - apresentacao, contato, cidades de atuacao e vitrine de imoveis da empresa
  - abrirPerfilEmpresa com MultiBlocProvider (vitrine preguicosa, AnuncianteRef.empresa) e aoAbrirImovel
  - Testes de desfecho (Cubit, telas, cartao presente/ausente, rotulos) e e2e completo da fase
affects: [verify-work da fase 07, Phase 5 (troca da DataSource dos perfis)]
tech-stack:
  added: []
  patterns:
    - Pagina da empresa espelha a do corretor - MultiBlocProvider com vitrine preguicosa, secoes reaproveitadas
    - Vitrine so existe com a empresa carregada (vitrine nula nos demais estados)
key-files:
  created:
    - lib/presentation/perfis/widgets/chips_cidades_atuacao.dart
    - test/presentation/perfil_empresa_cubit_test.dart
  modified:
    - lib/presentation/perfis/perfil_empresa_screen.dart
    - test/presentation/perfil_empresa_screen_test.dart
    - test/presentation/perfil_corretor_screen_test.dart
    - test/presentation/apresentacao_perfil_test.dart
    - test/presentation/detalhe_navegacao_test.dart
key-decisions:
  - "PerfilEmpresaCubit nao precisou de mudanca: os testes de desfecho (404, erro, retry, tres guardas, close) passaram de primeira"
  - "getIt na pagina da empresa chega a 2 usos (PerfilEmpresaCubit e VitrineAnuncianteCubit), ambos dentro de abrirPerfilEmpresa, como o corretor"
requirements-completed: [PERF-01, PERF-02, PERF-03, PERF-04, PERF-05, PERF-06, API-08]
duration: ~45 min
completed: 2026-11-08
plan_head_before: 6fc03aa2c7056ce6a4c397c444314b81b08bbf2f
plan_head_after: 9401fe574509fd112b4bc8925a8f31663d3fd87a
commits: 3
actuals:
  tokens: 28000
  tasks: 3
  commits: 3
coverage:
  - deliverable: "Empresa inativa/inexistente mostra 'Esta pagina nao esta mais disponivel' com Voltar; falha mostra 'Tentar de novo'; empresa inativa de corretor ativo volta ao perfil do corretor (lacuna da WEB 02)"
    verification:
      - {kind: test, ref: "test/presentation/perfil_empresa_cubit_test.dart", status: pass}
      - {kind: test, ref: "test/presentation/perfil_empresa_screen_test.dart", status: pass}
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#empresa indisponivel", status: pass}
    human_judgment: false
  - deliverable: "Cartao 'Ver pagina do anunciante' so com empresa_id, entre Contato e 'Imoveis de', repassando o id 3 ao toque"
    verification:
      - {kind: test, ref: "test/presentation/perfil_corretor_screen_test.dart#cartao Ver pagina do anunciante", status: pass}
    human_judgment: false
  - deliverable: "Pagina da empresa na ordem logomarca/nome/tipo/CRECI, Apresentacao, Contato (texto selecionavel), Cidades de atuacao (chips) e Imoveis de {nome}; omissoes da empresa 4"
    verification:
      - {kind: test, ref: "test/presentation/perfil_empresa_screen_test.dart#pagina completa", status: pass}
    human_judgment: false
  - deliverable: "Vitrine da empresa: cards, toque abre o imovel, vitrine criada so com a empresa carregada e carregada com AnuncianteRef.empresa(id)"
    verification:
      - {kind: test, ref: "test/presentation/perfil_empresa_screen_test.dart#vitrine da empresa", status: pass}
    human_judgment: false
  - deliverable: "Fluxo completo vitrine -> imovel 42 -> Marina -> empresa 3 -> imovel da vitrine da empresa -> volta ate a vitrine intacta na mesma posicao"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo (PERF-01..PERF-06, API-08)", status: pass}
    human_judgment: false
  - deliverable: "Fidelidade Material 3 verde/branco, icones e rotulos ('Ver pagina do anunciante', 'Anunciante', 'Cidades de atuacao', 'Corretor autonomo'), latencia percebida da previa e layout em 360 dp"
    human_judgment: true
    rationale: "Sem UI-SPEC (D-16): so o usuario confirma em aparelho real; ver Human-check de fim de fase"
---

# Phase 7 Plan 12: Fechamento da fase - pagina da empresa completa e fluxo ponta a ponta Summary

**A pagina da empresa agora mostra apresentacao, contato (texto selecionavel), cidades de atuacao em chips e a vitrine paginada dos imoveis da empresa, e o fluxo vitrine -> imovel -> corretor -> empresa -> imovel -> volta esta provado de ponta a ponta sobre a pilha real do mock.**

## Accomplishments

- Task 1 (desfechos): `perfil_empresa_cubit_test.dart` novo no molde do Cubit do corretor (sucesso, 404, erro generico, FormatException, retry, retry duplo, guardas antes de carregar/durante carregando/no 404, close sem emissao). Cartao 'Ver pagina do anunciante' presente com empresa (depois de Contato, antes de 'Imoveis de', semantica e id 3 repassado) e ausente sem `empresaId`. `rotuloTipoEmpresa` testado. E2E 'empresa indisponivel': Marina -> cartao -> aviso -> 'Voltar' devolve o perfil da Marina carregado, sem criar a vitrine da empresa. Nenhuma lacuna da 07-11 encontrada: `perfil_empresa_cubit.dart` ficou intacto.
- Task 2 (empresa completa): `ChipsCidadesAtuacao` (Wrap + Chip 'Cidade, UF', ordem recebida, some quando vazio). `abrirPerfilEmpresa` virou `MultiBlocProvider` com a vitrine preguicosa (`carregar(AnuncianteRef.empresa(id))`), `aoAbrirImovel` e `criarVitrineCubit`. No `PerfilCarregado`: `SecaoApresentacao`, `SecaoContato` e `ChipsCidadesAtuacao` (reaproveitando os componentes do corretor) e `SliverImoveisDoAnunciante` via `CorpoPerfilComVitrine`; nos outros estados `vitrine: null`.
- Task 3 (fim de fase): e2e completo com latencias curtas (300 ms nos perfis/detalhe, zero na vitrine do anunciante), `scrollUntilVisible`, sem `pumpAndSettle`; suite inteira (795 testes), `flutter analyze` e todas as guardas da fase passam.

## Task Commits

1. Task 1: `7da0bad` test(07-12) desfechos da pagina da empresa (404, falha, cartao ausente) e rotulos do tipo
2. Task 2: `35af28b` feat(07-12) pagina da empresa completa com apresentacao, contato, cidades de atuacao e vitrine
3. Task 3: `9401fe5` test(07-12) fluxo completo vitrine -> imovel -> corretor -> empresa -> imovel e volta

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Teste desatualizado] E2E da 07-11 esperava ausencia total de spinner na pagina da empresa**
- **Found during:** Task 2
- **Issue:** com a vitrine da empresa montada, o spinner dela aparece logo apos a empresa carregar (latencia de 300 ms), quebrando `findsNothing` do e2e `... -> pagina da Imobiliaria Jequitiba -> volta ao perfil`.
- **Fix:** o teste agora espera o spinner da vitrine, avanca 300 ms e so entao exige ausencia de spinner.
- **Files modified:** test/presentation/detalhe_navegacao_test.dart
- **Commit:** 35af28b

**2. [Rule 1 - Teste] Ordem dos chips em 400 dp**
- **Found during:** Task 2
- **Issue:** o terceiro chip quebra de linha em 400 dp; comparar so `dx` falhava.
- **Fix:** ordem de leitura (linha de cima primeiro; na mesma linha, esquerda para direita).
- **Files modified:** test/presentation/perfil_empresa_screen_test.dart
- **Commit:** 35af28b

**Total deviations:** 2 auto-fixed (ambas ajustes de teste, sem mudar comportamento de producao). **Impact:** nenhum no escopo. O harness de tela da empresa passou a prover uma vitrine falsa e janela alta (400x3000), porque os slivers sao lazy.

Nota: as guardas de `git diff --exit-code ba77b1e` foram rodadas em dois lotes de caminhos por limitacao do shell do worktree; todas saem com codigo 0. A fixture do detalhe (`imoveis_detalhe_fixture.dart`) soma 15 linhas e remove 1 (limite: 4 remocoes).

## Limitações conhecidas / exceções declaradas

- **Exceção dev-only da vitrine do anunciante (D-03, §12.9):** até o endpoint do §12 existir na web, o recorte por `empresa`/`corretor` e a ordem 'mais recentes' rodam no servidor simulado `VitrineAnuncianteMockDataSource`, em `data/`, dentro do aparelho. O repositório e a apresentação nunca filtram nem reordenam (provado nos testes de 07-06 e 07-08). A exceção é retirada com a Phase 5, quando a DataSource real recebe a página já recortada pelo servidor.
- **Perfis no mock por DI (D-03):** os perfis seguem no mock até a troca de uma anotação junto com a Phase 5, com a DataSource remota pronta e testada.
- **PENDENTE WEB (§12.8):** endpoint da vitrine do anunciante, `cidade` opcional, politica de imoveis de anunciante inativo, checagem de empresa ativa na API do corretor (lacuna reproduzida pelo e2e 'empresa indisponivel'), LGPD do contato - nenhum resolvido no app.
- **Edges `unclassified` do probe (PERF-03, PERF-05, PERF-06)** seguem **unresolved**: cobertos por testes e pelo human-check, sem criterio de borda derivado do probe.

## Human-check de fim de fase (para o /gsd-verify-work)

Nao bloqueante nesta execucao (human_verify_mode = end-of-phase). O usuario deve confirmar num aparelho real (`flutter run` em emulador Android, inclusive largura de 360 dp; `flutter run -d windows` se nao houver emulador). Em Campinas, 'Mais recentes':

1. Abrir o 1o card (42), rolar ate 'Corretor responsavel' e tocar em Marina Lopes.
2. No perfil, pressionar e segurar o telefone.
3. Rolar o perfil ate o fim.
4. Voltar ao topo e tocar 'Ver pagina do anunciante'; rolar a pagina da empresa e tocar num imovel; voltar ate a vitrine.
5. Abrir o 4o card de Campinas (imovel 101, corretora Camila Duarte), o perfil dela e depois 'Ver pagina do anunciante'.
6. Trocar para Vinhedo, rolar ate o fim da lista, abrir o antepenultimo card (imovel 337) e tocar no corretor Paulo Teixeira.

Esperado:

1. A pagina do corretor abre na hora com o nome e a foto da previa (no 42 a foto do detalhe usa host ficticio e mostra o avatar padrao; ~0,5 s depois pode aparecer a foto do perfil) e completa com 'CRECI 12345-F', 'Apresentacao' e 'Contato' (icones de telefone, conversa e e-mail; '(19) 3333-4444', '19999998888' e o e-mail), sem botao de ligar/WhatsApp/e-mail.
2. O texto pode ser selecionado/copiado e nada e discado.
3. Cartao 'Ver pagina do anunciante', depois 'Imoveis de Marina Lopes' com os cards, carregando mais ao rolar ate 'Voce chegou ao fim da lista' (4 paginas), sem card repetido.
4. 'Imobiliaria Jequitiba' com logomarca (ou placeholder verde com predio), 'Imobiliaria', 'CRECI J-1234', 'Apresentacao', 'Contato', chips 'Campinas, SP' / 'Valinhos, SP' / 'Vinhedo, SP' e 'Imoveis de Imobiliaria Jequitiba'; o imovel tocado abre a pagina do imovel e voltar retorna a cada pagina anterior e por fim a vitrine na mesma posicao.
5. Camila sem foto (avatar padrao), sem 'Apresentacao' e sem a linha 'Telefone'; a empresa dela mostra 'Camila Duarte', 'Corretor autonomo', placeholder de logomarca, sem 'Apresentacao', chip 'Vinhedo, SP' e os imoveis dela.
6. O perfil abre com 'Paulo Teixeira' por um instante e troca para 'Este corretor nao esta mais disponivel' com 'Voltar', sem nome nem foto, sem lista de imoveis; 'Voltar' devolve o detalhe 337.

Em tudo: Material 3 verde e branco, sem cor fora do tema, rotulos em portugues natural. Por que humano: sem UI-SPEC (D-16), so o usuario confirma fidelidade visual, icones e rotulos escolhidos por discricao (incl. 'Ver pagina do anunciante' e 'Anunciante'), latencia percebida da previa e layout em 360 dp. Tambem confirmar a suposicao A7 (rotulo neutro do cartao).

## Known Stubs

None.

## Threat Flags

None. Mitigacoes T-07-32 (contato so `SelectableText`, sem pacote/esquema de link), T-07-33 (vitrine da empresa so com a empresa 200; fabrica nunca chamada no 404, testado), T-07-34 e T-07-SC (nenhum drift fora da fase, pubspec intacto) aplicadas e verificadas pelas guardas.

## Self-Check: PASSED

- Criados: `lib/presentation/perfis/widgets/chips_cidades_atuacao.dart`, `test/presentation/perfil_empresa_cubit_test.dart` existem.
- Commits `7da0bad`, `35af28b`, `9401fe5` presentes no historico do worktree.
- `flutter test` (795) e `flutter analyze` limpos; guardas G1-G7 com codigo 0.
