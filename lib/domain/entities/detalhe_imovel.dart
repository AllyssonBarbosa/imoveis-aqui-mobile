import 'package:freezed_annotation/freezed_annotation.dart';

import 'cidade.dart';
import 'dados_natureza.dart';
import 'imovel.dart';

part 'detalhe_imovel.freezed.dart';

/// Parte comum do detalhe de um imóvel (DET-01) — tudo que a página mostra
/// vem pronto da camada de dados, o app nunca monta nem calcula nada aqui.
/// [cidade] e [bairro] vêm do `endereco` da API, que pode ser nulo: sem ele
/// o bairro é vazio e a cidade é `null`.
///
/// Preços e coordenadas continuam strings decimais do servidor, nunca
/// parseadas no domínio (mesma regra de [Imovel], D-03).
@freezed
abstract class DetalheImovel with _$DetalheImovel {
  const factory DetalheImovel({
    required int id,
    required String titulo,
    required FinalidadeImovel finalidade,
    String? precoVenda,
    String? precoAluguel,
    String? precoCondominio,
    String? precoIptu,
    required String descricao,
    required String bairro,
    Cidade? cidade,
    String? latitude,
    String? longitude,

    /// Na ordem recebida — o servidor já manda a capa primeiro; o app nunca
    /// reordena.
    @Default(<FotoImovel>[]) List<FotoImovel> fotos,
    @Default(<String>[]) List<String> caracteristicas,
    CorretorResponsavel? corretor,
    NaturezaImovel? natureza,

    /// Dados próprios da natureza; `null` quando o servidor não manda o bloco
    /// ou a natureza é desconhecida (D-14).
    DadosNatureza? dados,
  }) = _DetalheImovel;
}

/// Uma foto da galeria do imóvel; [capa] marca a foto de capa.
@freezed
abstract class FotoImovel with _$FotoImovel {
  const factory FotoImovel({required String url, required bool capa}) =
      _FotoImovel;
}

/// Corretor responsável pelo imóvel: só o que a API manda (id, nome e foto —
/// D-17). A tela de perfil abre já com este objeto em memória.
@freezed
abstract class CorretorResponsavel with _$CorretorResponsavel {
  const factory CorretorResponsavel({
    required int id,
    required String nome,
    String? foto,
  }) = _CorretorResponsavel;
}
