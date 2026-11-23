---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
reviewed: 2026-11-22T00:00:00Z
depth: standard
files_reviewed: 28
files_reviewed_list:
  - lib/data/datasources/gestao_imovel_datasource.dart
  - lib/data/datasources/gestao_imovel_remote_datasource.dart
  - lib/data/models/codigos_imovel_api.dart
  - lib/data/models/imovel_acervo_model.dart
  - lib/data/models/imovel_gestao_model.dart
  - lib/data/models/mudanca_situacao_model.dart
  - lib/data/network/mensagem_de_recusa.dart
  - lib/data/repositories/gestao_imovel_repository_impl.dart
  - lib/domain/entities/imovel_gestao.dart
  - lib/domain/entities/mudanca_situacao.dart
  - lib/domain/repositories/gestao_imovel_repository.dart
  - lib/domain/usecases/mudar_situacao_usecase.dart
  - lib/domain/usecases/obter_historico_situacao_usecase.dart
  - lib/domain/usecases/obter_imovel_gestao_usecase.dart
  - lib/presentation/acervo/acervo_cubit.dart
  - lib/presentation/acervo/acervo_screen.dart
  - lib/presentation/acervo/widgets/cartao_imovel_acervo.dart
  - lib/presentation/gestao_imovel/apresentacao_gestao.dart
  - lib/presentation/gestao_imovel/gestao_imovel_cubit.dart
  - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
  - lib/presentation/gestao_imovel/gestao_imovel_state.dart
  - lib/presentation/gestao_imovel/mudar_situacao_cubit.dart
  - lib/presentation/gestao_imovel/mudar_situacao_state.dart
  - lib/presentation/gestao_imovel/widgets/cabecalho_gestao.dart
  - lib/presentation/gestao_imovel/widgets/historico_situacao.dart
  - lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart
  - lib/presentation/gestao_imovel/widgets/secao_situacao.dart
  - lib/presentation/sessao/sessao_expirada.dart
  - tool/capturar_fixtures_api.py
  - test/support/api_falsa.dart
  - test/support/pilha_real.dart
findings:
  critical: 0
  warning: 3
  info: 6
  total: 9
status: issues_found
---

# Phase 9: Code Review Report

**Reviewed:** 2026-11-22
**Depth:** standard
**Files Reviewed:** 31 (código de produção, script de captura e suporte de teste; os testes de `test/data` e `test/presentation` receberam uma leitura mais leve)
**Status:** issues_found

## Summary

A fase está bem construída: a camada de dados traduz as falhas em tipos de domínio, o token só vai pela origem da API (`InterceptadorSessao`, `followRedirects: false`), o POST não tem nova tentativa automática, a mensagem do servidor só aparece como texto simples e nenhuma decisão de negócio foi para o aparelho. `flutter analyze` está limpo e `flutter test test/data test/presentation` passou inteiro (1359 testes). As decisões D-01..D-19 foram respeitadas e nenhuma foi tratada como defeito.

Não achei nada de nível BLOCKER. Os três WARNING são: uma condição de corrida no `GestaoImovelCubit` que deixa o histórico preso no indicador de carregamento, um buraco de consistência quando o POST dá timeout mas o servidor gravou, e o script de captura, que grava no servidor sem nenhuma trava de destino e roda o grupo `situacao` por padrão.

Nenhum achado depende de decisão travada (D-xx). O lado web (commit de testes `c02a50640`) é só teste de caracterização; não encontrei teste vazio nem asserção errada nele.

## Warnings

### WR-01: `recarregar()` deixa o histórico preso em "carregando" quando o imóvel falha

**File:** `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart:88-95` (com `134-157`)
**Issue:** `tentarNovamenteHistorico()` emite `historico: carregando` e espera a resposta. Se o usuário puxar para atualizar nesse intervalo, `recarregar()` incrementa `_versao`, e a resposta da repetição é descartada na guarda `versaoDaCarga != _versao` (linha 144). Se a releitura do imóvel então falha, `recarregar()` cai no primeiro `return` (`imovelLido is ImovelGestaoErro && tinhaImovel`, linhas 92-95), que só soma `falhasAoAtualizar` e nunca toca em `historico`. Resultado: nenhuma das duas respostas atualiza o histórico, que fica em `HistoricoCarregando` para sempre, sem o botão "Tentar de novo" (esse botão só existe no ramo `HistoricoErro`). A tela só se recupera com outro puxar-para-atualizar bem-sucedido. O caminho é realista: rede instável, o usuário toca em "Tentar de novo" no histórico e logo em seguida puxa a tela. A suíte não cobre essa intercalação (o teste "resposta do histórico de uma carga antiga é descartada" usa `carregar`, não `recarregar`).
**Fix:** no ramo de falha do imóvel, se o histórico na tela está em `HistoricoCarregando`, aplicar o histórico lido (ou `HistoricoErro`):
```dart
if (imovelLido is ImovelGestaoErro && tinhaImovel) {
  emit(
    state.copyWith(
      falhasAoAtualizar: state.falhasAoAtualizar + 1,
      historico: state.historico is HistoricoCarregando
          ? historicoLido
          : state.historico,
    ),
  );
  return;
}
```
Fazer o mesmo no segundo ramo (`historicoLido is HistoricoErro && tinhaHistorico`) não é necessário, porque lá `tinhaHistorico` já é falso quando o estado é `carregando`. Acrescentar um teste de `recarregar` durante `tentarNovamenteHistorico`.

### WR-02: POST que expira (ou dá 5xx) mas gravou deixa tela e acervo defasados, e o reenvio mostra uma recusa enganosa

**File:** `lib/presentation/gestao_imovel/mudar_situacao_cubit.dart:60-62` e `lib/presentation/gestao_imovel/gestao_imovel_screen.dart:144-158`
**Issue:** o comentário do repositório admite que "um POST com tempo esgotado pode ter gravado". Mesmo assim, o desfecho `EnvioFalhou` só mostra o texto fixo na folha: a tela de gestão não relê a API e `GestaoImovelState.mudou` continua falso. Se o servidor de fato gravou, ficam três consequências: (a) a tela mostra a situação antiga com o botão "Mudar situação" ativo; (b) o reenvio para a mesma situação volta como 400 "O imóvel já está reservado." e a folha exibe isso como recusa, o que o corretor lê como erro quando a mudança deu certo; (c) ao voltar, `abrirGestaoImovel` devolve `mudou == false`, então o acervo não recarrega e o chip do cartão (e a vitrine, AC-5) ficam velhos até o usuário refazer a consulta. O AC-4 ("mantém a situação anterior") só vale quando a recusa é do servidor, não quando o resultado é desconhecido.
**Fix:** tratar a falha de rede/5xx do POST como "resultado desconhecido": a tela chama uma releitura silenciosa (`recarregar()`) quando a folha emite `EnvioFalhou`, e o `GestaoImovelCubit` marca `mudou: true` de forma conservadora nesse caso (recarregar o acervo a mais é barato; deixá-lo velho não é). Por exemplo, um `registrarEnvioIncerto()` no `GestaoImovelCubit` que emite `mudou: true` e chama `recarregar()`, acionado por um `BlocListener` em `anterior.envio is! EnvioFalhou && atual.envio is EnvioFalhou`. Cobrir com um teste de fluxo no `gestao_imovel_fluxo_test.dart` (5xx no POST seguido de GET já com a situação nova).

### WR-03: o script de captura escreve no servidor sem trava de destino e roda o grupo `situacao` por padrão

**File:** `tool/capturar_fixtures_api.py:128-150`, `538-675` e `694-722`
**Issue:** `capturar_situacao` faz login com credenciais reais (via ambiente) e dá POST de `RESERVADO` e de `DISPONIVEL`, gravando no banco do servidor. A única proteção é texto de documentação ("só rode contra o SQLite temporário"). Três pontos agravam:
1. O argumento `--grupo` tem `default="todos"`, então `python3 tool/capturar_fixtures_api.py <url>` (a forma mais curta de uso) executa `contato` e agora também `situacao`, ambos com escrita.
2. `url_base` é aceito sem validar o host. Apontar por engano para staging ou produção mandaria o login e os POSTs para lá.
3. `urllib.request.urlopen` segue redirecionamentos e, no CPython, repete o cabeçalho `Authorization` no destino do 3xx (inclusive de outra origem), o que contraria a postura de "token só para a origem da API" que o app adota no `construirDioAutenticado`.
**Fix:** recusar hosts que não sejam de loopback a menos que haja uma opção explícita, e não executar grupos com escrita por padrão:
```python
HOSTS_LOCAIS = {"127.0.0.1", "localhost", "10.0.2.2"}

def _exigir_servidor_local(base):
    host = urllib.parse.urlparse(base).hostname
    if host not in HOSTS_LOCAIS:
        raise ErroCaptura(
            f"{host!r} não é um servidor local; a captura grava no banco "
            "(use --permitir-host-remoto sob sua responsabilidade)."
        )
```
Chamar isso em `main()` antes de qualquer grupo; exigir `--grupo` (sem `default`) ou excluir `contato` e `situacao` do `todos`; e instalar um `HTTPRedirectHandler` que levanta `ErroCaptura` em vez de seguir 3xx.

## Info

### IN-01: o 403 de uma leitura (GET) vira `MudancaSituacaoRecusadaException`

**File:** `lib/data/repositories/gestao_imovel_repository_impl.dart:69-78`
**Issue:** `_executar` é compartilhada pelas três operações, e o ramo `status == 400 || status == 403` vale também para `obterImovel` e `obterHistorico`, apesar do comentário "só a escrita os espera". O contrato de `obterImovel`/`obterHistorico` em `gestao_imovel_repository.dart` não lista essa exceção. Hoje não há efeito visível (o `GestaoImovelCubit` mapeia qualquer `Failure` desconhecida para `erro`), mas um 403 de leitura passa a carregar texto do servidor numa exceção de "mudança recusada", e o 400/403 sem texto vira `FalhaDeConexaoException`.
**Fix:** passar um parâmetro `bool esperaRecusa` para `_executar` (verdadeiro só em `mudarSituacao`), ou mover o tratamento 400/403 para esse método.

### IN-02: `podeConfirmar` não exclui `EnvioConcluido`

**File:** `lib/presentation/gestao_imovel/mudar_situacao_state.dart:27-31` e `lib/presentation/gestao_imovel/mudar_situacao_cubit.dart:48-52`
**Issue:** depois do sucesso, `envio` é `EnvioConcluido`, e `podeConfirmar` continua verdadeiro. Um segundo `confirmar()` entre o `emit` e o fechamento da folha dispararia outro POST (e receberia 400 "já está..."). Hoje a janela é fechada só porque a rota em saída ignora toques (`IgnorePointer` do `ModalRoute`), ou seja, por uma proteção que não é do Cubit. A guarda do toque duplo (T-09-07) fica incompleta.
**Fix:** `envio is! EnvioEnviando && envio is! EnvioConcluido` em `podeConfirmar`, com um teste `confirmar() depois de concluído não chama o use case`.

### IN-03: toque duplo no cartão do acervo empilha duas telas de gestão

**File:** `lib/presentation/acervo/acervo_screen.dart:97-101` e `239`
**Issue:** `_abrirGestao` não tem guarda de reentrada. Dois toques rápidos no mesmo cartão (antes de o primeiro `push` assumir o foco) abrem duas gestões, cada uma com seu `GestaoImovelCubit` e suas duas leituras da API. Ao voltar, a segunda ainda precisa ser fechada pelo usuário.
**Fix:** um `bool _abrindoGestao` no `State` (ou desabilitar o `aoTocar` enquanto `_abrindoGestao` for verdadeiro), liberado em `finally` depois do `await`.

### IN-04: a folha não reage a `EnvioNaoEncontrado`

**File:** `lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart:84` e `lib/presentation/gestao_imovel/gestao_imovel_screen.dart:136-158`
**Issue:** num 404 do POST ("Este imóvel não está mais no seu acervo.") a folha permanece aberta com "Confirmar" ativo, e a tela de baixo continua mostrando o imóvel como se existisse. Cada novo toque repete um 404 certo. O 401 já leva ao login; o 404 deixa o usuário numa folha sem saída útil além de fechar.
**Fix:** num `BlocListener` para `EnvioNaoEncontrado`, fechar a folha e chamar `GestaoImovelCubit.recarregar()` (a releitura devolve 404 e a tela passa a `naoEncontrado`).

### IN-05: `mensagemDeRecusa` junta texto de qualquer chave e corta no meio de um par substituto

**File:** `lib/data/network/mensagem_de_recusa.dart:19-31`
**Issue:** (a) A regra "todo valor de texto, de qualquer chave" é deliberada, mas inclui também campos como `code` ou `error_code` caso o servidor passe a mandá-los junto de `detail`, e eles apareceriam colados à mensagem. (b) `texto.substring(0, limiteMensagemDeRecusa)` conta unidades UTF-16: um emoji ou outro caractere fora do plano básico que caia na posição 299-300 fica com meio caractere antes das reticências (renderiza como caractere inválido).
**Fix:** para (b), cortar por `texto.runes`/`characters` (`texto.characters.take(limite)`), ou recuar um índice quando o último código for um substituto alto. Para (a), manter como está e travar a forma esperada no teste de contrato (`contrato_gestao_situacao_test.dart` já confere as chaves das fixtures), ou restringir às chaves `detail`, `situacao`, `observacao` e `non_field_errors`.

### IN-06: duplicações pequenas e acoplamento entre arquivos de tradução

**File:** `lib/presentation/acervo/acervo_screen.dart:281`, `lib/data/datasources/gestao_imovel_remote_datasource.dart:8` e `65`
**Issue:** (a) O texto `'Tentar de novo'` está repetido como literal em `acervo_screen.dart:281`, enquanto `apresentacao_gestao.dart:25` já tem `rotuloTentarDeNovo`. (b) O envio da situação usa `codigoDaSituacao`, que mora em `parametros_consulta_acervo.dart` (arquivo da consulta do acervo), enquanto o sentido inverso mora em `codigos_imovel_api.dart`. O cabeçalho de `codigos_imovel_api.dart` diz que ele é o "único lugar" da tradução, mas a tradução enum para código está noutro arquivo, e o DataSource de gestão passa a depender de um arquivo cujo nome diz "acervo".
**Fix:** (a) usar a constante (movendo-a para um arquivo comum de apresentação, já que o acervo não deveria importar `apresentacao_gestao`); (b) mover `codigoDaSituacao` para `codigos_imovel_api.dart` e reexportar/ajustar os imports de `parametros_consulta_acervo.dart`.

---

_Reviewed: 2026-11-22_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
