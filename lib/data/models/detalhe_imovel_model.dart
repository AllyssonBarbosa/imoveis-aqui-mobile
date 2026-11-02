import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dados_natureza.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/entities/imovel.dart';
import 'caracteristica_model.dart';
import 'cidade_model.dart';
import 'dados_natureza_model.dart';
import 'url_segura.dart';

part 'detalhe_imovel_model.freezed.dart';
part 'detalhe_imovel_model.g.dart';

/// Modelo de transporte do detalhe de um imóvel
/// (`GET /api/publico/imoveis/{id}/`), servido por
/// `ImovelDetalheRemoteDataSource` (API-07). Segue o wire real da W09 (D-15):
/// o endereço vem aninhado em `endereco` e o corretor em
/// `corretor_responsavel`. Declara só o que o app usa (D-06, D-16): qualquer
/// chave extra do JSON é ignorada pelo `json_serializable`, então os dados de
/// contato do corretor nunca são guardados.
@freezed
abstract class DetalheImovelModel with _$DetalheImovelModel {
  const DetalheImovelModel._();

  const factory DetalheImovelModel({
    required int id,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    @JsonKey(name: 'preco_condominio') String? precoCondominio,
    @JsonKey(name: 'preco_iptu') String? precoIptu,
    required String descricao,

    /// Pode vir `null` (imóvel sem endereço cadastrado): tolerado.
    EnderecoPublicoModel? endereco,
    @Default(<FotoImovelModel>[]) List<FotoImovelModel> fotos,
    @Default(<CaracteristicaModel>[])
    List<CaracteristicaModel> caracteristicas,
    @JsonKey(name: 'corretor_responsavel') CorretorModel? corretor,
    String? natureza,

    /// Um bloco por natureza; só o que bate com `natureza` é usado
    /// (RESEARCH Pattern 2: o discriminador é irmão do bloco).
    CasaModel? casa,
    ApartamentoModel? apartamento,
    TerrenoModel? terreno,
    LoteModel? lote,
  }) = _DetalheImovelModel;

  factory DetalheImovelModel.fromJson(Map<String, Object?> json) =>
      _$DetalheImovelModelFromJson(json);

  /// Mapeia para a entidade de domínio. As características viram a lista de
  /// nomes. `finalidade` desconhecida lança
  /// [FormatException] (o repositório converte em `Result.failure`);
  /// `natureza` desconhecida ou ausente vira `null`. As fotos mantêm a ordem
  /// recebida — o app nunca reordena — e só as de URL http(s) sobrevivem
  /// (V12/V13); a foto do corretor fora de http(s) vira `null`.
  DetalheImovel paraEntidade() {
    return DetalheImovel(
      id: id,
      titulo: titulo,
      finalidade: _mapearFinalidade(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      precoCondominio: precoCondominio,
      precoIptu: precoIptu,
      descricao: descricao,
      bairro: endereco?.bairro ?? '',
      cidade: endereco?.cidade?.paraEntidade(),
      latitude: endereco?.latitude,
      longitude: endereco?.longitude,
      fotos: [
        for (final foto in fotos)
          if (urlHttpOuNula(foto.url) case final url?)
            FotoImovel(url: url, capa: foto.capa),
      ],
      caracteristicas: [for (final item in caracteristicas) item.nome],
      corretor: corretor?.paraEntidade(),
      natureza: _mapearNatureza(natureza),
      dados: _mapearDados(),
    );
  }

  /// Escolhe o bloco pela `natureza`. Natureza desconhecida, bloco ausente ou
  /// nulo, ou bloco que não bate com a natureza resultam em `null` — nunca
  /// derrubam o parse (D-14, T-04-05-01), então uma natureza nova do servidor
  /// só omite a seção.
  DadosNatureza? _mapearDados() {
    return switch (natureza) {
      'CASA' => casa?.paraEntidade(),
      'APARTAMENTO' => apartamento?.paraEntidade(),
      'TERRENO' => terreno?.paraEntidade(),
      'LOTE' => lote?.paraEntidade(),
      _ => null,
    };
  }

  static FinalidadeImovel _mapearFinalidade(String valor) {
    switch (valor) {
      case 'VENDA':
        return FinalidadeImovel.venda;
      case 'ALUGUEL':
        return FinalidadeImovel.aluguel;
      case 'VENDA_E_ALUGUEL':
        return FinalidadeImovel.vendaEAluguel;
      default:
        throw FormatException('finalidade desconhecida: $valor');
    }
  }

  static NaturezaImovel? _mapearNatureza(String? valor) {
    switch (valor) {
      case 'CASA':
        return NaturezaImovel.casa;
      case 'APARTAMENTO':
        return NaturezaImovel.apartamento;
      case 'TERRENO':
        return NaturezaImovel.terreno;
      case 'LOTE':
        return NaturezaImovel.lote;
      default:
        return null;
    }
  }
}

/// Endereço público do detalhe (`endereco`). Todos os campos são anuláveis:
/// o app lê logradouro, número e CEP (D-15), mas a página só mostra
/// "bairro · cidade, UF" — endereço exato e mapa são do APP 05 (D-01).
@freezed
abstract class EnderecoPublicoModel with _$EnderecoPublicoModel {
  const factory EnderecoPublicoModel({
    String? logradouro,
    String? numero,
    String? bairro,
    String? cep,
    CidadeModel? cidade,
    String? latitude,
    String? longitude,
  }) = _EnderecoPublicoModel;

  factory EnderecoPublicoModel.fromJson(Map<String, Object?> json) =>
      _$EnderecoPublicoModelFromJson(json);
}

/// Foto da galeria no formato de transporte; `ordem` vem do servidor e a
/// URL chega em `imagem`.
@freezed
abstract class FotoImovelModel with _$FotoImovelModel {
  const FotoImovelModel._();

  const factory FotoImovelModel({
    @JsonKey(name: 'imagem') required String url,
    required int ordem,
    required bool capa,
  }) = _FotoImovelModel;

  factory FotoImovelModel.fromJson(Map<String, Object?> json) =>
      _$FotoImovelModelFromJson(json);

  FotoImovel paraEntidade() => FotoImovel(url: url, capa: capa);
}

/// Corretor responsável no formato de transporte: só id, nome e foto (D-16).
/// E-mail, telefone, WhatsApp, CRECI, apresentação e `empresa_id` que a API
/// manda são ignorados pelo parser.
@freezed
abstract class CorretorModel with _$CorretorModel {
  const CorretorModel._();

  const factory CorretorModel({
    required int id,
    required String nome,
    String? foto,
  }) = _CorretorModel;

  factory CorretorModel.fromJson(Map<String, Object?> json) =>
      _$CorretorModelFromJson(json);

  CorretorResponsavel paraEntidade() => CorretorResponsavel(
    id: id,
    nome: nome,
    foto: urlHttpOuNula(foto),
  );
}
