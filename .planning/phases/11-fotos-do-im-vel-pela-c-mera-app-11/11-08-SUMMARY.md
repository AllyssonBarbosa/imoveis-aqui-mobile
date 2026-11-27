---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 08
subsystem: app (telas)
tags: [tela, reorderable, popupmenu, popscope, gestao]
requires: ["11-07"]
provides:
  - "abrirFotosImovel (abridor dono do Cubit, devolve FotosAlteradas?) e fotosAlteradasDe"
  - "FotosImovelScreen (botões, fila, ReorderableListView com onReorderItem, menu Capa/Apagar com confirmação, avisos, 401 → login, PopScope com envio pendente)"
  - "Widgets ItemFoto e FilaEnvio"
  - "Botão \"Fotos\" na gestão; GestaoImovelState.fotosMudaram/capaAtualizada/temCapaAtualizada; GestaoImovelCubit.registrarMudancaDeFotos; cabeçalho com a capa atualizada; abrirGestaoImovel devolve mudou || fotosMudaram"
key-files:
  created:
    - "lib/presentation/fotos_imovel/fotos_imovel_screen.dart"
    - "lib/presentation/fotos_imovel/fotos_alteradas.dart"
    - "lib/presentation/fotos_imovel/widgets/item_foto.dart"
    - "lib/presentation/fotos_imovel/widgets/fila_envio.dart"
    - "test/presentation/fotos_imovel/fotos_imovel_screen_test.dart"
    - "test/presentation/gestao_imovel_fotos_test.dart"
  modified:
    - "lib/presentation/fotos_imovel/apresentacao_fotos.dart"
    - "lib/presentation/fotos_imovel/fotos_imovel_cubit.dart (reordenar recebe a posição final)"
    - "lib/domain/entities/foto_imovel.dart (idsNaOrdemPedida com a posição final)"
    - "lib/presentation/gestao_imovel/gestao_imovel_screen.dart"
    - "lib/presentation/gestao_imovel/gestao_imovel_cubit.dart"
    - "lib/presentation/gestao_imovel/gestao_imovel_state.dart (+ .freezed.dart)"
    - "lib/presentation/gestao_imovel/widgets/cabecalho_gestao.dart"
    - "test/domain/fotos_imovel_dominio_test.dart, test/presentation/fotos_imovel/fotos_imovel_cubit_test.dart"
completed: 2026-11-25
---

# 11-08 — Tela de fotos e botão na gestão

## O que foi feito
- **Abridor** `abrirFotosImovel` no padrão da gestão: cria o Cubit, pede a carga, empurra a rota e, na volta, lê
  `fotosAlteradasDe(estado)` e fecha o Cubit.
- **Tela:**
  - `AppBar` com "Fotos" e o código do imóvel.
  - `switch` exaustivo sobre a lista: carregando; erro com "Tentar de novo"; 404 com o texto da gestão; sessão
    expirada; carregada.
  - Com a lista carregada, um `ReorderableListView.builder` com `header`: os botões "Tirar foto" / "Escolher da
    galeria", a `FilaEnvio`, a barra de operação e o vazio "Este imóvel ainda não tem fotos.".
  - `onReorderItem` chama `cubit.reordenar(de, destino)`. A lista exibida é sempre a do estado: soltar não move nada
    até o servidor responder.
  - `MultiBlocListener`: 401 → `voltarAoLoginComSessaoTerminada` (mais a conferência no `initState`), e SnackBars de
    falha de operação (mensagem do servidor ou texto fixo), "Foto apagada." e câmera/galeria que não abriu.
  - `PopScope(canPop: !haEnviosPendentes)`: com envio pendente, o diálogo "Sair e cancelar os envios?" oferece
    "Continuar enviando" / "Sair".
- **ItemFoto:**
  - miniatura do servidor, "Foto N" e o `Chip` "Capa" lido do campo `capa`;
  - `PopupMenuButton` com "Definir como capa" (oculto na capa) e "Apagar", desligado sem `podeAlterarFotos`;
  - alça `ReorderableDragStartListener` só com `podeAlterarFotos`; indicador na foto da operação em andamento.
- **FilaEnvio:**
  - um `Card` por foto, com miniatura local (`Image.file`, `cacheWidth` 160, ícone se ilegível);
  - "Aguardando"; "Preparando…" com barra indeterminada; "Enviando…" com a barra no progresso;
  - falha em `colorScheme.error` (mensagem do servidor ou texto fixo de envio/preparo) com "Tentar de novo" e "Remover".
- **Gestão:**
  - botão "Fotos" (`OutlinedButton.icon`) quando o imóvel carregou;
  - na volta com `FotosAlteradas`, `registrarMudancaDeFotos`;
  - o cabeçalho usa a capa atualizada;
  - `abrirGestaoImovel` devolve `mudou || fotosMudaram` (o acervo relê e o cartão mostra a capa nova).

## Desvios do plano
1. **Capa na volta (D-23 ajustado):** o plano dizia "na volta, a gestão relê o imóvel e o cabeçalho mostra a capa
   nova". Isso não funcionaria: o cabeçalho usa a capa do cartão do acervo, e o Model do `GET /api/imoveis/<id>/` não
   lê fotos. Solução sem pedido novo: a tela de fotos devolve `FotosAlteradas` com a capa que o **servidor** marcou na
   última lista; a gestão guarda essa capa (`capaAtualizada`) e marca `fotosMudaram`, **separado de `mudou`**, porque
   `mudou` esconde "Ver na vitrine" (D-18 da Fase 9), e mexer em foto não tira o imóvel da vitrine. CONTEXT D-23
   atualizado.
2. **`onReorderItem` em vez de `onReorder`:** no Flutter 3.50.1 o `onReorder` é obsoleto. O substituto já entrega a
   posição final, então `idsNaOrdemPedida` passou a receber o destino final, sem a correção `para - 1` (domínio,
   Cubit e testes ajustados).
3. **Câmera e galeria** chamam o Cubit (decidido no 11-07), não o seletor direto.
4. **Testes da ligação com a gestão** num arquivo novo (`gestao_imovel_fotos_test.dart`), sem mexer nos testes da APP 09.

## Verificação
- `flutter test test/presentation/fotos_imovel/fotos_imovel_screen_test.dart`: **26 OK**, entre eles:
  - os desfechos da leitura e o vazio; fotos na ordem com o selo só na capa e alças;
  - botões → Cubit; `onReorderItem(2, 0)` → `reordenar(2, 0)`;
  - menu sem "Definir como capa" na capa e com ele nas outras; apagar com Cancelar/Apagar;
  - sem alça e com menu desligado com envio pendente; barra e indicador durante uma operação;
  - fila com progresso 0.4, falha com a mensagem do servidor e os dois botões, textos fixos de falha;
  - os quatro avisos; 401 por transição e já na abertura;
  - voltar com envio pendente (continuar/sair) e sem pendência; `fotosAlteradasDe` nos 4 casos.
- `flutter test test/presentation/gestao_imovel_fotos_test.dart`: **10 OK**:
  - o botão abre com id e código, e não aparece sem o imóvel;
  - volta com e sem alteração; cabeçalho com a capa atualizada e com a do cartão;
  - "Ver na vitrine" continua com `fotosMudaram`;
  - o Cubit marca e guarda a capa (inclusive nula), com a capa desconhecida, e mantém tudo numa nova carga.
- Os testes antigos da gestão (tela, Cubit, fluxo) continuam verdes.
- `flutter test` inteiro: **2049 OK**. `flutter analyze`: **105 infos**, todos `deprecated_member_use`; os 5 novos são o
  import de `material.dart` nos arquivos novos (anotado em `11-NOTAS-PR.md`). Nenhum `warning` ou `error`.
- Sem commit no app (aguardando aprovação).
