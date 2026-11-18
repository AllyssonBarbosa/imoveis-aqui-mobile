---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 10
subsystem: fechamento-da-fase
tags: [readme, gates, device-check, human-verify, contato]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "App completo do contato (06-04..06-09) e API na feat/APP06 com throttle e %20 (06-01, 06-02)"
provides:
  - "Duas suítes verdes no fim da fase e nenhum push em nenhum dos repositórios"
  - "README com a API na feat/APP06 (contatos.0001) e o passo 'Contato (APP 06)' do roteiro"
  - "Veredito do device check: aprovado em emulador Android (emulator-5554, API 36)"
affects: []

plan_head_before: f04ca076f9643583c284e386c05e530b212a6c31
actuals:
  tokens: 340   # chars/4 sobre as linhas adicionadas do README (git diff f04ca07..HEAD)
  tasks: 3
  commits: 1    # MEDIDO: git rev-list --count f04ca076..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns: []

key-files:
  created: []
  modified:
    - README.md

key-decisions:
  - "Ícone Icons.chat + 'WhatsApp' (Open Question 4) aceito sob a aprovação geral do usuário, sem troca"
  - "Recados para Palloma e Allysson não enviados: o usuário vai conversar pessoalmente para combinar o merge"

requirements-completed: [APP06-C1, APP06-C2, APP06-C3, APP06-C4, APP06-C5, APP06-C6, APP06-API-1, APP06-API-2]

coverage:
  - id: E1
    description: "Link wa.me do servidor codifica espaço como %20 e nunca '+' (teste Django rodado por nome antes do aparelho) e confirmado no WhatsApp real"
    requirement: APP06-C2
    verification:
      - kind: unit
        ref: "contatos.tests.MensagemDoWhatsAppComEspacosTests (3 testes, OK)"
        status: pass
      - kind: manual
        ref: "device check Android emulator-5554, aprovado pelo usuário"
        status: pass
    human_judgment: true
  - id: E2
    description: "WhatsApp abre o app com a mensagem pronta, Ligar abre o discador, Enviar e-mail abre o e-mail, perfil aberto do imóvel contata, falhas e registros no servidor"
    requirement: APP06-C3
    verification:
      - kind: manual
        ref: "06-10 Task 2 (passos 1-10), aprovação geral do usuário"
        status: pass
    human_judgment: true
---

# Phase 6 Plan 10: Fechamento da fase e verificação no aparelho Summary

**Duas suítes completas verdes (app 716 testes, API 437), nada enviado por push, README com o roteiro do contato e API na `feat/APP06`, e o contato aprovado pelo usuário num emulador Android com WhatsApp contra um servidor semeado temporário (já desligado e apagado).**

## Performance

- **Completed:** 2026-11-18
- **Tasks:** 3 (2 auto, 1 checkpoint:human-verify)
- **Files modified:** 1 (README.md)

## Accomplishments

- Portões finais: `flutter test` (716 passaram) e `flutter analyze` (sem issues) no app; `manage.py test` completo (437 testes, OK) e `makemigrations --check --dry-run` ("No changes detected") na API.
- `contatos.tests.MensagemDoWhatsAppComEspacosTests` rodado por nome antes do aparelho (3 testes OK, incluindo `test_api_usa_por_cento_20_e_nunca_mais`): o link do servidor usa `%20`.
- README: "Subir o Django" passa a usar `feat/APP06` e avisa que o `migrate` também cria `contatos.0001`; o roteiro ganhou o passo "Contato (APP 06)" e a frase do perfil (nome, foto e barra "Sobre: <título>") foi reescrita.
- Servidor temporário semeado (SQLite sob `$TMPDIR`, nunca o banco do `Web/.env`) para o device check; desligado e apagado no Task 3.

## Task Commits

1. **Task 1: portões finais, README e servidor temporário** - `6ba5828` (docs)
2. **Task 2: verificação no aparelho** - checkpoint humano, sem commit
3. **Task 3: desligar o servidor e registrar o resultado** - sem commit de código (README não precisou de correção); o registro está neste SUMMARY

Repo da API: nenhum commit novo (opcao-a, HEAD = `7d4f5cd8b5c2d91452f2db5431c4c09993aae043`). Nada de push.

## Heads (conferência de push)

| Repo | HEAD | `git branch -r --contains HEAD` |
|------|------|--------------------------------|
| App (`feat/APP06`) | `6ba58288a5fbdaeb9ccef27b547e7c600a452ad8` (antes do commit do SUMMARY; antes do plano: `f04ca076f9643583c284e386c05e530b212a6c31`) | vazio |
| API (`feat/APP06`) | `7d4f5cd8b5c2d91452f2db5431c4c09993aae043` | vazio |

## Veredito do device check (Task 2)

- **Aparelho:** emulador Android `emulator-5554` (sdk gphone64 arm64, API 36), base URL `http://10.0.2.2:8000`, contra o servidor temporário semeado.
- **Veredito:** **aprovado**. Resposta do usuário: "aprovado, vou conversar com palloma e allyson para fazerem o merge".
- **Por passo (1-10):** o usuário deu uma aprovação geral e não detalhou cada passo; nenhum passo foi reportado como falho. Não registro veredito individual inventado por passo.
- **Pitfall 7 (espaços no WhatsApp):** o usuário não reportou `pitfall-7`; a correção `%20` do 06-02 fica confirmada pela aprovação, além do teste Django verde antes do aparelho. Nenhuma regressão a registrar.
- **Open Question 4 (ícone `Icons.chat` + "WhatsApp"):** o usuário não comentou o ícone separadamente; registrado como aceito sob a aprovação geral, sem troca. Open Question 4 fechada sem mudança.
- **Passos 9 e 10:** o usuário não detalhou o conferido no passo 9 (registros de Contato no servidor); vale na aprovação geral. O passo 10 (recados) está abaixo.

## Recados para enviar (o usuário envia)

Texto copiado verbatim dos SUMMARYs de origem. O agente nunca enviou nada. Pela resposta do usuário, nenhum foi enviado.

### Recado para a Palloma (06-01-SUMMARY)

> Palloma, a WEB-11 (contatos da W11) foi mesclada localmente na minha branch `feat/APP06` do repo da API, em cima da main (71ffeed), para o app de contato poder usar o POST público. Nada foi enviado por push e a `origin/WEB-11` não foi alterada. Quando puder, vale mergear a WEB-11 na main. O conflito de merge foi só aditivo (README, painel.css e painel_home.html: mantive os dois lados).

Status: não enviado — o usuário vai conversar pessoalmente com a Palloma e o Allysson para combinarem o merge

### Recado para a Palloma (06-02-SUMMARY)

> Palloma, na minha branch local `feat/APP06` do repo da API mexi em duas coisas da W11, sem commit e sem push. (1) `ContatoPublicoAPIView` ganhou `throttle_classes = [ThrottleContatoPublico]`: balde próprio por IP, configurado em `CONTATO_TAXA_ANONIMA` (padrão 10/min); acima disso responde 429 com `Retry-After` e não grava o contato. O POST do site `/imovel/<id>/contato/` continua sem limite, e a frase do README da W11 sobre "ainda não há limite de requisições" foi reescrita. (2) `link_whatsapp` em `contatos/servicos.py` agora usa `urlencode(..., quote_via=quote)`, como o `link_email`: espaço sai como `%20` (nunca `+`) e um `+` literal sai como `%2B`. Como é a mesma função, isso também muda os botões de WhatsApp das páginas de empresa/corretor do site. Travado por `MensagemDoWhatsAppComEspacosTests`. Nenhum teste da W11 ou do site foi alterado, com uma exceção: `site_publico.tests.WhatsAppTests` esperava `Casa+com+quintal` e passou a esperar `Casa%20com%20quintal`.

Status: não enviado — o usuário vai conversar pessoalmente com a Palloma e o Allysson para combinarem o merge

### Recado para o Allysson (06-09-SUMMARY)

> Allysson, o componente de contato do APP 06 esta em `lib/presentation/contato/` (`BarraContato`, `ContatoCubit`, `mostrarContatoBottomSheet`). O perfil do corretor da branch `feat/APP06` ainda e a tela stub do APP 04. Quem fizer o merge por ultimo precisa plugar `BarraContato` na tela de perfil reescrita da `origin/feat/APP07`: a barra entra em `bottomNavigationBar` com `legenda: Text('Sobre: <titulo do imovel>')` e `abrirPerfilCorretor` recebe `contato: ContatoDoImovel(imovelId, titulo, canais)` e `criarContatoCubit` (o perfil e uma rota nova e nao herda o `ContatoCubit` da pagina, entao o `BlocProvider<ContatoCubit>` e criado na funcao de abertura). Sem imovel de origem (ex.: pagina da empresa) o perfil nao mostra barra nem botoes. Os testes `test/presentation/perfil_corretor_screen_test.dart` e `detalhe_navegacao_test.dart` ('perfil aberto a partir do imovel...') quebram se a barra for perdida no merge.

Status: não enviado — o usuário vai conversar pessoalmente com a Palloma e o Allysson para combinarem o merge

## Limpeza do servidor temporário (Task 3)

- Servidor (PID 50580, runserver 0.0.0.0:8000) parado só por esse PID; o processo saiu.
- SQLite `imoveis_device_06.sqlite3` em `$TMPDIR` e o log do runserver apagados.
- Verificado: porta 8000 livre (`curl` sem resposta, `lsof` sem listener) e arquivo inexistente.
- O banco do `Web/.env` nunca foi tocado.

## Itens em aberto

- Combinar com Palloma (merge da WEB-11 na main; throttle e `%20` do 06-02) e com Allysson (onde plugar `BarraContato` e `abrirPerfilCorretor(contato:, criarContatoCubit:)` na tela do APP 07): feito pelo usuário pessoalmente; nenhum recado foi enviado por escrito. Nenhum artefato da fase diz que alguém foi avisado.
- Nenhum defeito do aparelho reportado; nenhuma troca de ícone pedida.

## Deviations from Plan

**1. [Process] SUMMARY criado só depois do checkpoint.** O orquestrador pediu para não escrever o SUMMARY antes da resposta do usuário; os recados prontos foram devolvidos na mensagem do checkpoint e entram aqui. O verify do Task 1 que esperava a seção "Recados para enviar" no SUMMARY foi satisfeito neste arquivo, após o checkpoint. Fora isso, plano executado como escrito. O README não precisou de correção no Task 3.

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova; T-06-10-01 (nenhum push, conferido nos dois repos) e T-06-10-02 (servidor e SQLite temporários removidos, verificado) mitigadas; T-06-10-03: o agente não tocou o banco do `Web/.env`.

## Self-Check: PASSED

- README.md contém `feat/APP06` e `Contato (APP 06)`; commit `6ba5828` existe em feat/APP06.
- Porta 8000 livre e SQLite temporário apagado.
