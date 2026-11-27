---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 07
subsystem: app (apresentação: estado e Cubit)
tags: [cubit, fila, upload, freezed]
requires: ["11-06"]
provides:
  - "apresentacao_fotos.dart (textos fixos)"
  - "FotosImovelState (lista, fila, operação, contadores, mudou; haEnviosPendentes, podeAlterarFotos) e as uniões ListaFotos, EnvioDeFoto/EstadoEnvio, OperacaoFotos"
  - "FotosImovelCubit (carregar, tirarFoto, escolherDaGaleria, adicionar, tentarDeNovoEnvio, remover, reordenar, definirCapa, apagar, close que descarta os JPEGs)"
  - "TirarFotoUseCase e EscolherFotosDaGaleriaUseCase"
key-files:
  created:
    - "lib/presentation/fotos_imovel/apresentacao_fotos.dart"
    - "lib/presentation/fotos_imovel/fotos_imovel_state.dart (+ .freezed.dart)"
    - "lib/presentation/fotos_imovel/fotos_imovel_cubit.dart"
    - "lib/domain/usecases/tirar_foto_usecase.dart"
    - "lib/domain/usecases/escolher_fotos_da_galeria_usecase.dart"
    - "test/presentation/fotos_imovel/fotos_imovel_cubit_test.dart"
  modified: ["lib/di/injection.config.dart"]
completed: 2026-11-25
---

# 11-07 — Estado e Cubit da tela de fotos

## O que foi feito
- **Estado** (freezed, imutável):
  - `lista` (carregando | carregada | erro | naoEncontrado | sessaoExpirada);
  - `fila` de `EnvioDeFoto` (id local, original, preparada, estado aguardando | preparando | enviando(progresso) |
    falhou(mensagemDoServidor, noPreparo));
  - `operacao` (nenhuma | reordenando | definindoCapa | apagando);
  - contadores para os SnackBars (`falhasDeOperacao` + `mensagemDaUltimaFalha`, `fotosApagadas`, `falhasAoEscolher`)
    e `mudou`;
  - getters `haEnviosPendentes` (as que falharam não contam) e `podeAlterarFotos` (lista carregada, sem operação e
    sem envio).
- **Cubit:**
  - **Leitura:** desfecho decidido só pelo tipo da falha. A releitura depois de um envio mantém a lista anterior
    numa falha genérica.
  - **Fila:** um laço único (`_processandoFila`) pega a próxima "aguardando", na ordem. Para cada foto: prepara (só
    se ainda não tem JPEG), envia com progresso e, se aceita, ela sai da fila e a lista é relida.
    - Recusa 400/403: a falha guarda a mensagem do servidor.
    - Falha genérica: marca a foto e relê a lista (o POST pode ter gravado).
    - 401 ou 404: a lista muda de estado e a fila para.
  - **"Tentar de novo":** reenvia o mesmo JPEG; se a falha foi no preparo, prepara de novo.
  - **"Remover":** só para foto que falhou, e apaga o JPEG.
  - **Ordem, capa e exclusão** passam por um `_operar` único:
    - marca a operação e **não muda a lista** até a resposta;
    - sucesso: lista devolvida e `mudou`;
    - 401 ou 404: estado próprio;
    - outra falha: soma 1 na falha (com a mensagem do servidor, se houver) e relê a lista.

    São ignoradas com envio ou outra operação em andamento. `reordenar` usa `idsNaOrdemPedida`, e soltar no mesmo
    lugar não chama o servidor.
  - **Câmera e galeria:** cancelar não faz nada; falha da plataforma soma `falhasAoEscolher`.
  - **`close()`** apaga os JPEGs preparados que ficaram na fila.
- **Textos fixos:** em `apresentacao_fotos.dart`. "Tentar de novo" e o texto do 404 vêm da gestão, para não
  duplicar a constante.

## Desvios do plano
- **Câmera e galeria pelo Cubit**, com `TirarFotoUseCase` e `EscolherFotosDaGaleriaUseCase`. O plano do 11-08 dizia
  que a tela chamaria o seletor; assim a tela não toca em gateway nem trata `Result`.
- **Nome:** `tentarDeNovoEnvio` (não `tentarDeNovo`), para não confundir com `tentarNovamente` (a leitura da lista).
- `mensagemDaUltimaFalha` no estado, para o SnackBar da operação recusada mostrar o texto do servidor (ex.: lista de
  ordem inválida) em vez do fixo.
- **404 no envio para a fila** e marca o imóvel como fora do acervo, assim como na leitura.

## Verificação
- `flutter test test/presentation/fotos_imovel`: **30 OK**, entre eles:
  - os 4 desfechos da carga;
  - três fotos enviadas uma por vez, na ordem (só a primeira no ar até ser concluída, conferido com `Completer`);
  - o progresso no item (fração e indeterminado);
  - uma recusa 400 no meio com a terceira enviada mesmo assim;
  - "Tentar de novo" sem novo preparo; falha no preparo com novo preparo;
  - remover (e não remover a que está enviando);
  - 401 e 404 parando a fila; `close` apagando os JPEGs;
  - câmera cancelada, foto da câmera, falhas do seletor, galeria em ordem;
  - reordenar sem mudança local antes da resposta; soltar no mesmo lugar;
  - operações ignoradas com envio ou outra operação;
  - capa e apagar com a lista devolvida; recusa com mensagem e releitura; falha de rede; 401 e 404 numa operação.
- **Mutação:** com o envio sem esperar o anterior (`unawaited`), 3 testes falham. O Cubit foi restaurado.
- `flutter test` inteiro: **2013 OK**. `flutter analyze`: os mesmos 100 infos antigos. Os arquivos novos não importam
  `material.dart`.
- Sem commit no app (aguardando aprovação).
