import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Imagem padrão do imóvel (D-10): fundo verde claro com ícone de casa. É o
/// que a vitrine e a página do imóvel mostram quando não há foto, enquanto a
/// foto carrega ou quando o carregamento falha.
class ImagemPadraoImovel extends StatelessWidget {
  const ImagemPadraoImovel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: 48,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Foto vinda da rede, compartilhada pela vitrine e pela página do imóvel.
/// Não impõe proporção (sem `AspectRatio`): quem usa decide o tamanho do slot
/// — o card da vitrine envolve em 16:9, a galeria preenche o espaço que tem
/// (RESEARCH Pitfall 4). `url` nula, carregamento e erro caem em
/// [imagemPadrao] (ou na [ImagemPadraoImovel]).
class ImagemRede extends StatelessWidget {
  const ImagemRede({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.imagemPadrao,
    this.construirImagemDeRede,
  });

  final String? url;
  final BoxFit fit;

  /// Substitui a imagem padrão verde (ex.: fundo escuro no visualizador).
  final Widget? imagemPadrao;

  /// Ponto de extensão só para teste — permite substituir
  /// `CachedNetworkImage` (que depende de plugins nativos indisponíveis em
  /// `flutter test`) por um builder determinístico. Em produção fica sempre
  /// `null`, e a foto real usa `CachedNetworkImage`. Sem `@visibleForTesting`
  /// aqui porque os widgets de cima repassam o gancho até este ponto; só as
  /// pontas (tela, capa do card) carregam a anotação.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final padrao = imagemPadrao ?? const ImagemPadraoImovel();
    return switch (url) {
      final String endereco =>
        construirImagemDeRede?.call(endereco) ??
            CachedNetworkImage(
              imageUrl: endereco,
              fit: fit,
              placeholder: (context, _) => padrao,
              errorWidget: (context, _, _) => padrao,
            ),
      null => padrao,
    };
  }
}
