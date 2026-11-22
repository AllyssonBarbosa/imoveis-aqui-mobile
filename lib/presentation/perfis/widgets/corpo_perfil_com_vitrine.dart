import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../vitrine_anunciante_cubit.dart';
import '../vitrine_anunciante_state.dart';

/// Corpo rolável das páginas de perfil (corretor e empresa): UM
/// `CustomScrollView` com o [cabecalho] (slivers do estado atual do perfil) e,
/// quando o perfil está carregado, a [vitrine] de imóveis do anunciante. É
/// dono do `ScrollController` que dispara a paginação (PERF-03, D-12):
///
/// - a 90% do fim da rolagem pede a próxima página;
/// - se o cabeçalho e a primeira página não enchem a tela (nada para rolar),
///   pede a próxima sozinho, depois do frame (Pitfall 6);
/// - com [vitrine] nula (perfil carregando, 404 ou erro) nunca toca no
///   [VitrineAnuncianteCubit] — o provider da vitrine é preguiçoso e só pode
///   nascer com o perfil existente.
///
/// O Cubit só é lido de dentro do `State`, nunca dentro de `slivers`.
class CorpoPerfilComVitrine extends StatefulWidget {
  const CorpoPerfilComVitrine({
    super.key,
    required this.cabecalho,
    this.vitrine,
  });

  /// Slivers do estado do perfil (cabeçalho, seções, aviso de erro etc.).
  final List<Widget> cabecalho;

  /// Sliver da vitrine do anunciante; `null` enquanto ela não deve existir.
  final Widget? vitrine;

  @override
  State<CorpoPerfilComVitrine> createState() => _CorpoPerfilComVitrineState();
}

class _CorpoPerfilComVitrineState extends State<CorpoPerfilComVitrine> {
  // `keepScrollOffset: false`: o controlador nasce sempre no topo, sem herdar a
  // posição de rolagem de outra instância (mesmo cuidado da vitrine da cidade).
  final ScrollController _controleDeRolagem = ScrollController(
    keepScrollOffset: false,
  );

  // Ouve os estados da vitrine só enquanto ela existe; mantê-la fora da árvore
  // de widgets evita recriar o `CustomScrollView` quando o perfil termina de
  // carregar.
  StreamSubscription<VitrineAnuncianteState>? _inscricaoVitrine;

  @override
  void initState() {
    super.initState();
    _controleDeRolagem.addListener(_aoRolar);
    _sincronizarVitrine();
  }

  @override
  void didUpdateWidget(CorpoPerfilComVitrine antigo) {
    super.didUpdateWidget(antigo);
    _sincronizarVitrine();
  }

  @override
  void dispose() {
    unawaited(_inscricaoVitrine?.cancel());
    _controleDeRolagem
      ..removeListener(_aoRolar)
      ..dispose();
    super.dispose();
  }

  /// Liga a escuta quando a vitrine passa a existir e a desliga quando some.
  /// Na ligação, agenda a checagem de página curta uma vez, lendo o estado
  /// atual do Cubit.
  void _sincronizarVitrine() {
    final temVitrine = widget.vitrine != null;
    if (temVitrine && _inscricaoVitrine == null) {
      final cubit = context.read<VitrineAnuncianteCubit>();
      _inscricaoVitrine = cubit.stream.listen(
        (_) => _agendarChecagemDePaginaCurta(),
      );
      _agendarChecagemDePaginaCurta();
    } else if (!temVitrine && _inscricaoVitrine != null) {
      unawaited(_inscricaoVitrine!.cancel());
      _inscricaoVitrine = null;
    }
  }

  void _aoRolar() {
    if (widget.vitrine == null || !_controleDeRolagem.hasClients) return;
    final posicao = _controleDeRolagem.position;
    if (posicao.pixels >= posicao.maxScrollExtent * 0.9) {
      _pedirProximaPaginaSePossivel();
    }
  }

  /// Pede a próxima página só quando há o que pedir: lista carregada, sem
  /// página em voo, sem falha pendente (o retry é só pelo botão) e com
  /// próxima página. O Cubit repete essas guardas; checar aqui evita chamadas
  /// inúteis a cada notificação de rolagem.
  void _pedirProximaPaginaSePossivel() {
    final cubit = context.read<VitrineAnuncianteCubit>();
    final estado = cubit.state;
    if (estado is! VitrineAnuncianteCarregada) return;
    if (estado.carregandoMais || estado.erroAoCarregarMais) return;
    if (estado.proximaPagina == null) return;
    unawaited(cubit.carregarMais());
  }

  /// Se o cabeçalho e a primeira página não preencherem a tela (nada para
  /// rolar) e ainda houver próxima página, pede a próxima automaticamente
  /// depois do frame — sem isso a paginação travaria em telas altas, já que
  /// o gatilho de rolagem nunca dispararia.
  void _agendarChecagemDePaginaCurta() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.vitrine == null) return;
      if (!_controleDeRolagem.hasClients) return;
      final posicao = _controleDeRolagem.position;
      if (!posicao.hasContentDimensions || posicao.maxScrollExtent > 0) return;
      _pedirProximaPaginaSePossivel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vitrine = widget.vitrine;
    return CustomScrollView(
      controller: _controleDeRolagem,
      slivers: [
        ...widget.cabecalho,
        ?vitrine,
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
        ),
      ],
    );
  }
}
