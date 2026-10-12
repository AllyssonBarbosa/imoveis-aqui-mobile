import 'package:flutter/material.dart';

import '../../../domain/entities/detalhe_imovel.dart';
import '../../comum/imagem_rede.dart';

/// Avatar redondo do corretor: a foto recortada em círculo ou, quando não há
/// foto (ou ela falha ao carregar), um ícone de pessoa sobre o verde claro
/// do tema.
class AvatarCorretor extends StatelessWidget {
  const AvatarCorretor({
    super.key,
    required this.foto,
    this.raio = 24,
    this.construirImagemDeRede,
  });

  final String? foto;
  final double raio;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`. Sem
  /// `@visibleForTesting` porque os widgets de cima repassam o gancho; só as
  /// pontas (telas) carregam a anotação.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: raio,
      backgroundColor: colorScheme.primaryContainer,
      child: ClipOval(
        child: SizedBox.square(
          dimension: raio * 2,
          child: ImagemRede(
            url: foto,
            fit: BoxFit.cover,
            imagemPadrao: Center(
              child: Icon(
                Icons.person_outline,
                size: raio,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            construirImagemDeRede: construirImagemDeRede,
          ),
        ),
      ),
    );
  }
}

/// Cartão tocável do corretor responsável (DET-05): foto, nome e um convite
/// para ver o perfil. Só apresenta o [CorretorResponsavel] que já veio no
/// detalhe — nada de contato aqui (APP 06).
class CartaoCorretor extends StatelessWidget {
  const CartaoCorretor({
    super.key,
    required this.corretor,
    required this.aoTocar,
    this.construirImagemDeRede,
  });

  final CorretorResponsavel corretor;
  final VoidCallback aoTocar;

  /// Ponto de extensão só para teste — ver [AvatarCorretor].
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver perfil de ${corretor.nome}',
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: ListTile(
            leading: AvatarCorretor(
              foto: corretor.foto,
              construirImagemDeRede: construirImagemDeRede,
            ),
            title: Text(corretor.nome),
            subtitle: const Text('Ver perfil do corretor'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
