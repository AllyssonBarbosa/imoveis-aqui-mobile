import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/foto_imovel.dart';
import '../gestao_imovel/apresentacao_gestao.dart';
import '../login/apresentacao_login.dart';
import '../sessao/sessao_expirada.dart';
import 'apresentacao_fotos.dart';
import 'fotos_alteradas.dart';
import 'fotos_imovel_cubit.dart';
import 'fotos_imovel_state.dart';
import 'widgets/fila_envio.dart';
import 'widgets/item_foto.dart';

/// Assinatura de quem abre a tela de fotos a partir da gestão — a
/// `GestaoImovelScreen` recebe uma por parâmetro (padrão [abrirFotosImovel])
/// para os testes de widget da gestão não dependerem do DI.
typedef AoAbrirFotos = Future<FotosAlteradas?> Function(
  BuildContext context, {
  required int imovelId,
  required String codigo,
});

/// Abre a tela de fotos por `Navigator.push` + `MaterialPageRoute` (D-08). O
/// abridor é o DONO do Cubit: cria, pede a leitura, empurra a rota e fecha o
/// Cubit na volta (padrão `abrirGestaoImovel`). O localizador de serviços só é
/// tocado aqui, no toque; [criarCubit] existe para teste.
///
/// Devolve [FotosAlteradas] quando alguma foto mudou no servidor (a capa vem do
/// campo `capa` da última lista recebida), senão `null`.
Future<FotosAlteradas?> abrirFotosImovel(
  BuildContext context, {
  required int imovelId,
  required String codigo,
  FotosImovelCubit Function()? criarCubit,
}) async {
  final cubit = (criarCubit ?? () => getIt<FotosImovelCubit>())()
    ..carregar(imovelId);
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<FotosImovelCubit>.value(
        value: cubit,
        child: FotosImovelScreen(codigo: codigo),
      ),
    ),
  );
  final resultado = fotosAlteradasDe(cubit.state);
  await cubit.close();
  return resultado;
}

/// Resultado da visita à tela, lido do estado na volta.
FotosAlteradas? fotosAlteradasDe(FotosImovelState estado) {
  if (!estado.mudou) return null;
  return switch (estado.lista) {
    ListaFotosCarregada(:final fotos) => FotosAlteradas(
      urlDaCapa: fotos.where((foto) => foto.capa).firstOrNull?.url,
      capaConhecida: true,
    ),
    _ => const FotosAlteradas(urlDaCapa: null, capaConhecida: false),
  };
}

/// Tela de fotos do imóvel (APP 11): botões de câmera e galeria, a fila de
/// envio com progresso e a lista das fotos do servidor, que se reordena
/// arrastando e tem "Definir como capa" e "Apagar" por foto. Nenhuma regra,
/// rede ou `try/catch` aqui: só apresenta o que o [FotosImovelCubit] entrega.
/// A lista exibida é sempre a do servidor — soltar uma foto em outra posição
/// pede a ordem nova e a lista só muda quando a resposta chega (D-20).
class FotosImovelScreen extends StatefulWidget {
  const FotosImovelScreen({
    super.key,
    required this.codigo,
    @visibleForTesting this.construirImagemDeRede,
    @visibleForTesting this.construirMiniaturaLocal,
  });

  /// Código do imóvel, mostrado no título.
  final String codigo;

  /// Ponto de extensão só para teste (ver `ImagemRede`); em produção `null`.
  final Widget Function(String url)? construirImagemDeRede;

  /// Ponto de extensão só para teste das miniaturas da fila (arquivos locais);
  /// em produção `null` (usa `Image.file`).
  final Widget Function(String caminho)? construirMiniaturaLocal;

  @override
  State<FotosImovelScreen> createState() => _FotosImovelScreenState();
}

/// `StatefulWidget` só para conferir o estado já presente quando a tela abre:
/// o abridor pede a leitura antes de empurrar a rota, então um 401 pode ter
/// chegado antes de o `BlocListener` existir (ele só enxerga transições).
class _FotosImovelScreenState extends State<FotosImovelScreen> {
  @override
  void initState() {
    super.initState();
    final jaExpirada =
        context.read<FotosImovelCubit>().state.lista
            is ListaFotosSessaoExpirada;
    if (!jaExpirada) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(voltarAoLoginComSessaoTerminada(context));
    });
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text(tituloSairComEnvios),
        content: const Text(textoSairComEnvios),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text(rotuloContinuarEnviando),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text(rotuloSair),
          ),
        ],
      ),
    );
    if (sair == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmarApagar(int fotoId) async {
    final apagar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text(tituloConfirmarApagar),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text(rotuloCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text(rotuloApagar),
          ),
        ],
      ),
    );
    if (apagar == true && mounted) {
      unawaited(context.read<FotosImovelCubit>().apagar(fotoId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiBlocListener(
      listeners: [
        // 401 em qualquer chamada: volta ao login pelo helper único (D-23).
        BlocListener<FotosImovelCubit, FotosImovelState>(
          listenWhen: (antes, agora) =>
              antes.lista is! ListaFotosSessaoExpirada &&
              agora.lista is ListaFotosSessaoExpirada,
          listener: (context, _) =>
              unawaited(voltarAoLoginComSessaoTerminada(context)),
        ),
        BlocListener<FotosImovelCubit, FotosImovelState>(
          listenWhen: (antes, agora) =>
              agora.falhasDeOperacao > antes.falhasDeOperacao,
          listener: (context, estado) =>
              _avisar(estado.mensagemDaUltimaFalha ?? textoFalhaOperacao),
        ),
        BlocListener<FotosImovelCubit, FotosImovelState>(
          listenWhen: (antes, agora) =>
              agora.fotosApagadas > antes.fotosApagadas,
          listener: (context, _) => _avisar(textoFotoApagada),
        ),
        BlocListener<FotosImovelCubit, FotosImovelState>(
          listenWhen: (antes, agora) =>
              agora.falhasAoEscolher > antes.falhasAoEscolher,
          listener: (context, _) => _avisar(textoFalhaAoEscolher),
        ),
      ],
      child: BlocBuilder<FotosImovelCubit, FotosImovelState>(
        builder: (context, estado) {
          final cubit = context.read<FotosImovelCubit>();
          return PopScope(
            // Com envio em andamento, sair pede confirmação (a fila é só de
            // memória, D-18). Sem envio, o voltar (e o gesto do iOS) é livre.
            canPop: !estado.haEnviosPendentes,
            onPopInvokedWithResult: (saiu, _) {
              if (!saiu) unawaited(_confirmarSaida());
            },
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(tituloFotos),
                    Text(widget.codigo, style: textTheme.bodySmall),
                  ],
                ),
              ),
              body: switch (estado.lista) {
                ListaFotosCarregando() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ListaFotosErro() => _Mensagem(
                  texto: textoErroFotos,
                  aoTentarDeNovo: cubit.tentarNovamente,
                ),
                ListaFotosNaoEncontrado() => const _Mensagem(
                  texto: textoImovelForaDoAcervo,
                ),
                // Enquanto a navegação para o login acontece.
                ListaFotosSessaoExpirada() => const _Mensagem(
                  texto: avisoSessaoTerminou,
                ),
                ListaFotosCarregada(:final fotos) => _ListaDeFotos(
                  estado: estado,
                  fotos: fotos,
                  construirImagemDeRede: widget.construirImagemDeRede,
                  construirMiniaturaLocal: widget.construirMiniaturaLocal,
                  aoApagar: (fotoId) => unawaited(_confirmarApagar(fotoId)),
                ),
              },
            ),
          );
        },
      ),
    );
  }
}

/// Corpo com a lista carregada: o cabeçalho (botões, fila, aviso de operação,
/// vazio) vai no `header` do `ReorderableListView`, então tudo rola junto.
class _ListaDeFotos extends StatelessWidget {
  const _ListaDeFotos({
    required this.estado,
    required this.fotos,
    required this.aoApagar,
    this.construirImagemDeRede,
    this.construirMiniaturaLocal,
  });

  final FotosImovelState estado;
  final List<FotoImovel> fotos;
  final void Function(int fotoId) aoApagar;
  final Widget Function(String url)? construirImagemDeRede;
  final Widget Function(String caminho)? construirMiniaturaLocal;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FotosImovelCubit>();
    final textTheme = Theme.of(context).textTheme;
    final listaDoServidor = fotos;
    final podeAlterar = estado.podeAlterarFotos;
    final operacao = estado.operacao;

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      buildDefaultDragHandles: false,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => unawaited(cubit.tirarFoto()),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text(rotuloTirarFoto),
                ),
                OutlinedButton.icon(
                  onPressed: () => unawaited(cubit.escolherDaGaleria()),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text(rotuloEscolherDaGaleria),
                ),
              ],
            ),
            if (estado.fila.isNotEmpty) ...[
              const SizedBox(height: 16),
              FilaEnvio(
                fila: estado.fila,
                construirMiniaturaLocal: construirMiniaturaLocal,
                aoTentarDeNovo: cubit.tentarDeNovoEnvio,
                aoRemover: (idLocal) => unawaited(cubit.remover(idLocal)),
              ),
            ],
            const SizedBox(height: 16),
            // Ordem, capa ou exclusão em andamento: a lista fica travada e
            // ainda mostra a ordem do servidor.
            SizedBox(
              height: 4,
              child: operacao is OperacaoNenhuma
                  ? null
                  : const LinearProgressIndicator(),
            ),
            if (listaDoServidor.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  textoSemFotos,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      itemCount: listaDoServidor.length,
      // A lista não é mexida aqui: o Cubit pede a ordem ao servidor.
      // `onReorderItem` já entrega a posição final (desconta o item que saiu).
      onReorderItem: (de, destino) => unawaited(cubit.reordenar(de, destino)),
      itemBuilder: (context, indice) {
        final foto = listaDoServidor[indice];
        return ItemFoto(
          key: ValueKey(foto.id),
          foto: foto,
          posicao: indice + 1,
          indice: indice,
          podeAlterar: podeAlterar,
          emOperacao: switch (operacao) {
            OperacaoDefinindoCapa(:final fotoId) ||
            OperacaoApagando(:final fotoId) => fotoId == foto.id,
            OperacaoNenhuma() || OperacaoReordenando() => false,
          },
          construirImagemDeRede: construirImagemDeRede,
          aoDefinirCapa: () => unawaited(cubit.definirCapa(foto.id)),
          aoApagar: () => aoApagar(foto.id),
        );
      },
    );
  }
}

/// Mensagem de um desfecho sem lista, com "Tentar de novo" opcional.
class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.texto, this.aoTentarDeNovo});

  final String texto;
  final Future<void> Function()? aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final tentar = aoTentarDeNovo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texto,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (tentar != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => unawaited(tentar()),
                child: const Text(rotuloTentarDeNovo),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
