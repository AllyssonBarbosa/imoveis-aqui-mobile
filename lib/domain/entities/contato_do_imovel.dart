import 'package:freezed_annotation/freezed_annotation.dart';

import 'canal_contato.dart';

part 'contato_do_imovel.freezed.dart';

/// Contexto do imóvel levado ao perfil do corretor (D-09): o id, o título e os
/// nomes dos canais que a página do imóvel já carregou. É o que permite ao
/// perfil mostrar a mesma barra de contato (`Sobre: <título>`) e registrar o
/// contato no mesmo imóvel, sem mudar o model de contato do servidor.
///
/// Nunca carrega número, e-mail nem link (D-02): só nomes de canal — quem
/// entrega o link é o `POST` de contato, no toque.
@freezed
abstract class ContatoDoImovel with _$ContatoDoImovel {
  const factory ContatoDoImovel({
    required int imovelId,
    required String titulo,
    required List<CanalContato> canais,
  }) = _ContatoDoImovel;
}
