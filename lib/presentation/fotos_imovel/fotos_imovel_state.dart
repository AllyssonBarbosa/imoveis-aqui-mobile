import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/foto_imovel.dart';

part 'fotos_imovel_state.freezed.dart';

/// Estado da tela de fotos do imóvel (APP 11).
///
/// - [lista]: as fotos como o servidor as devolveu, na ordem dele. O app nunca
///   a altera por conta própria: reordenar, trocar a capa e apagar só mudam
///   [lista] com a lista devolvida pelo servidor (D-20 a D-22).
/// - [fila]: fotos escolhidas no aparelho que ainda não viraram foto do
///   servidor — enviadas uma por vez, na ordem da escolha (D-18). Só memória.
/// - [operacao]: a escrita de ordem, capa ou exclusão em andamento (uma por
///   vez); enquanto houver, a tela trava o arrastar e o menu.
/// - Contadores ([falhasDeOperacao], [fotosApagadas], [falhasAoEscolher]): a
///   tela mostra um SnackBar a cada aumento, sem estado de "mensagem lida".
/// - [mudou]: alguma foto mudou no servidor durante a visita; a gestão relê o
///   imóvel na volta (D-23).
@freezed
abstract class FotosImovelState with _$FotosImovelState {
  const FotosImovelState._();

  const factory FotosImovelState({
    @Default(ListaFotos.carregando()) ListaFotos lista,
    @Default(<EnvioDeFoto>[]) List<EnvioDeFoto> fila,
    @Default(OperacaoFotos.nenhuma()) OperacaoFotos operacao,
    @Default(0) int falhasDeOperacao,

    /// Mensagem do servidor da última falha de operação (400/403), para o
    /// SnackBar; `null` usa o texto fixo.
    String? mensagemDaUltimaFalha,
    @Default(0) int fotosApagadas,
    @Default(0) int falhasAoEscolher,
    @Default(false) bool mudou,
  }) = _FotosImovelState;

  /// Há foto esperando, sendo preparada ou sendo enviada (as que falharam não
  /// contam: ficam paradas até "Tentar de novo" ou "Remover").
  bool get haEnviosPendentes =>
      fila.any((envio) => envio.estado is! EnvioFalhou);

  /// Reordenar, definir capa e apagar só valem com a lista carregada, sem
  /// outra operação e sem envio em andamento (D-20).
  bool get podeAlterarFotos =>
      lista is ListaFotosCarregada &&
      operacao is OperacaoNenhuma &&
      !haEnviosPendentes;
}

/// Desfechos da leitura da lista — `switch` exaustivo na tela.
@freezed
sealed class ListaFotos with _$ListaFotos {
  const factory ListaFotos.carregando() = ListaFotosCarregando;

  /// As fotos na ordem do servidor (lista vazia: imóvel sem foto).
  const factory ListaFotos.carregada(List<FotoImovel> fotos) =
      ListaFotosCarregada;

  /// Falha na primeira leitura — "Tentar de novo".
  const factory ListaFotos.erro() = ListaFotosErro;

  /// 404: o imóvel não está (mais) no acervo da empresa do corretor.
  const factory ListaFotos.naoEncontrado() = ListaFotosNaoEncontrado;

  /// 401 em qualquer chamada: a tela volta ao login e a fila para.
  const factory ListaFotos.sessaoExpirada() = ListaFotosSessaoExpirada;
}

/// Uma foto escolhida no aparelho, na fila de envio.
@freezed
abstract class EnvioDeFoto with _$EnvioDeFoto {
  const factory EnvioDeFoto({
    /// Identificador local (não é o id do servidor).
    required int id,

    /// O arquivo como a câmera ou a galeria entregou (miniatura da fila).
    required FotoEscolhida original,

    /// O JPEG reduzido, depois de preparado; reaproveitado no "Tentar de novo".
    FotoEscolhida? preparada,
    @Default(EstadoEnvio.aguardando()) EstadoEnvio estado,
  }) = _EnvioDeFoto;
}

/// Estado de um item da fila.
@freezed
sealed class EstadoEnvio with _$EstadoEnvio {
  const factory EstadoEnvio.aguardando() = EnvioAguardando;

  const factory EstadoEnvio.preparando() = EnvioPreparando;

  /// [progresso] de 0 a 1, ou `null` quando o total não é conhecido.
  const factory EstadoEnvio.enviando({double? progresso}) = EnvioEnviando;

  /// [mensagemDoServidor]: texto de uma recusa 400/403 (tipo, tamanho, teto),
  /// só para exibir; `null` usa o texto fixo ([noPreparo] diz qual).
  const factory EstadoEnvio.falhou({
    String? mensagemDoServidor,
    @Default(false) bool noPreparo,
  }) = EnvioFalhou;
}

/// Escrita em andamento sobre as fotos do servidor.
@freezed
sealed class OperacaoFotos with _$OperacaoFotos {
  const factory OperacaoFotos.nenhuma() = OperacaoNenhuma;
  const factory OperacaoFotos.reordenando() = OperacaoReordenando;
  const factory OperacaoFotos.definindoCapa(int fotoId) = OperacaoDefinindoCapa;
  const factory OperacaoFotos.apagando(int fotoId) = OperacaoApagando;
}
