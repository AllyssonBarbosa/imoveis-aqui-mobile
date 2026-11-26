import 'package:freezed_annotation/freezed_annotation.dart';

part 'foto_imovel.freezed.dart';

/// Entidade de domínio: uma foto do imóvel como o servidor a devolve
/// (`GET /api/imoveis/{id}/fotos/`, §19.2 do contrato).
///
/// Imutável e sem serialização (isso é papel de `FotoImovelModel` em `data/`).
/// [ordem] e [capa] são só lidos: quem decide a ordem e a capa é o Django
/// (D-02, D-04); o app pede a mudança e mostra a lista que voltar.
@freezed
abstract class FotoImovel with _$FotoImovel {
  const factory FotoImovel({
    required int id,

    /// URL absoluta da imagem no servidor.
    required String url,

    /// Posição definida pelo corretor (`0..n-1` nas listas do servidor).
    required int ordem,

    /// Se é a capa do imóvel — exatamente uma por imóvel com foto.
    required bool capa,
  }) = _FotoImovel;
}

/// Um arquivo de imagem no aparelho: o que o seletor devolve (foto da câmera ou
/// da galeria) e o que o preparador produz (JPEG reduzido, pronto para enviar).
@freezed
abstract class FotoEscolhida with _$FotoEscolhida {
  const factory FotoEscolhida({
    /// Caminho do arquivo local (cache do app).
    required String caminho,
  }) = _FotoEscolhida;
}

/// Ids de [atual] na ordem que o corretor pediu ao arrastar a foto da posição
/// [de] para a posição [para] num `ReorderableListView` — ou `null` quando a
/// ordem não muda (nada a pedir ao servidor).
///
/// O `ReorderableListView` entrega [para] contando o item que ainda está na
/// lista: quando a foto desce, a posição final é `para - 1`. A lista [atual] é
/// a do servidor e não é alterada; o resultado é só o pedido (D-20).
List<int>? idsNaOrdemPedida(List<FotoImovel> atual, int de, int para) {
  if (de < 0 || de >= atual.length || para < 0 || para > atual.length) {
    return null;
  }
  final destino = para > de ? para - 1 : para;
  if (destino == de) return null;
  final ids = [for (final foto in atual) foto.id];
  final movido = ids.removeAt(de);
  ids.insert(destino, movido);
  return List.unmodifiable(ids);
}
