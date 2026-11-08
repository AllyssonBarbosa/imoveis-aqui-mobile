import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../domain/entities/anunciante_ref.dart';
import '../mocks/imoveis_detalhe_fixture.dart';
import '../mocks/imoveis_fixture.dart';
import '../mocks/perfis_fixture.dart';
import '../models/imoveis_envelope_model.dart';
import 'parametros_consulta_imoveis.dart' show caminhoImoveisPublico;
import 'vitrine_anunciante_datasource.dart';

/// Servidor simulado da vitrine do anunciante (contrato §12) — DEV-ONLY.
///
/// Enquanto o endpoint do §12 não existe na web (PENDENTE WEB §12.8 a), o
/// recorte por `corretor=<id>` / `empresa=<id>` e a ordem "mais recentes"
/// (§12.3, §12.4) rodam AQUI, dentro do aparelho — exceção declarada no
/// §12.9, o mesmo padrão da vitrine da cidade (D-03). O repositório e a
/// apresentação nunca filtram nem reordenam; quando o endpoint real existir,
/// uma DataSource `dio` o substitui e esta classe sai.
///
/// Fonte única do vínculo imóvel-corretor: o DETALHE (`corretor.id`), nunca
/// uma regra duplicada de `id % 3`. Uma linha da lista sem detalhe (o 339,
/// despublicado) não é publicada e fica fora. Para empresa, entram os
/// imóveis dos corretores cuja `empresa_id` (perfis) é o id pedido. Id
/// desconhecido ou anunciante sem imóveis resulta em página vazia, nunca em
/// erro (§12.5); parâmetros ou cursor inválidos lançam [FormatException]
/// (§12.6).
///
/// As linhas devolvidas são as MESMAS da lista pública da cidade (allowlist
/// do §6/§12.3), parseadas pelo mesmo [ImoveisEnvelopeModel.fromJson]; por
/// segurança, as chaves `corretor`, `empresa` e `proprietario` são removidas
/// caso alguma fixture as carregue. Sem estado mutável entre chamadas.
@LazySingleton(as: VitrineAnuncianteDataSource)
class VitrineAnuncianteMockDataSource implements VitrineAnuncianteDataSource {
  VitrineAnuncianteMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _detalhes = detalhesAcervoFixture(),
      _corretores = corretoresPerfisFixture(),
      _latencia = const Duration(milliseconds: 500),
      _tamanhoPagina = 10;

  @visibleForTesting
  VitrineAnuncianteMockDataSource.paraTeste({
    required List<Map<String, Object?>> linhas,
    required Map<int, Map<String, Object?>> detalhes,
    required Map<int, Map<String, Object?>> corretores,
    Duration latencia = Duration.zero,
    int tamanhoPagina = 10,
    // ignore: prefer_initializing_formals
  }) : _linhas = linhas,
       // ignore: prefer_initializing_formals
       _detalhes = detalhes,
       // ignore: prefer_initializing_formals
       _corretores = corretores,
       // ignore: prefer_initializing_formals
       _latencia = latencia,
       // ignore: prefer_initializing_formals
       _tamanhoPagina = tamanhoPagina;

  final List<Map<String, Object?>> _linhas;
  final Map<int, Map<String, Object?>> _detalhes;
  final Map<int, Map<String, Object?>> _corretores;
  final Duration _latencia;
  final int _tamanhoPagina;

  /// Base fixa do host simulado — nunca aponta para uma URL real.
  static const String _urlBaseMock =
      'https://mock.imoveisaqui.local$caminhoImoveisPublico';

  /// Chaves que nenhuma linha da lista pública pode expor (§6/§12.3).
  static const Set<String> _chavesProibidas = {
    'corretor',
    'empresa',
    'proprietario',
  };

  @override
  Future<ImoveisEnvelopeModel> buscar(AnuncianteRef anunciante) =>
      _paginarPelosParametros(parametrosDoAnunciante(anunciante), offset: 0);

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) {
    final params = Uri.parse(proximaPagina).queryParameters;
    final cursorParam = params['cursor'];
    if (cursorParam == null) {
      throw const FormatException(
        'parâmetros ausentes no cursor de paginação',
      );
    }
    final offset = _decodificarCursor(cursorParam);
    return _paginarPelosParametros(params, offset: offset);
  }

  /// Valida os parâmetros SINCRONAMENTE, antes de qualquer `await` (este
  /// método NÃO é `async`), para que um parâmetro inválido lance direto na
  /// chamada de [buscar]/[seguir], nunca escondido numa `Future`.
  Future<ImoveisEnvelopeModel> _paginarPelosParametros(
    Map<String, String> params, {
    required int offset,
  }) {
    final anunciante = anuncianteDosParametros(params);
    return _montarPagina(anunciante, offset: offset);
  }

  Future<ImoveisEnvelopeModel> _montarPagina(
    AnuncianteRef anunciante, {
    required int offset,
  }) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }

    final idsDeCorretor = switch (anunciante) {
      AnuncianteCorretor(:final id) => <int>{id},
      AnuncianteEmpresa(:final id) =>
        _corretores.entries
            .where((entrada) => entrada.value['empresa_id'] == id)
            .map((entrada) => entrada.key)
            .toSet(),
    };

    final linhasDoAnunciante = _linhas.where((linha) {
      final detalhe = _detalhes[linha['id']! as int];
      if (detalhe == null) return false; // sem detalhe = não publicado
      final corretor = detalhe['corretor'] as Map<String, Object?>?;
      final idCorretor = corretor?['id'];
      return idCorretor is int && idsDeCorretor.contains(idCorretor);
    }).toList()..sort(_compararPorRecenciaDesc);

    final fim = (offset + _tamanhoPagina).clamp(0, linhasDoAnunciante.length);
    final pagina = (offset >= 0 && offset < linhasDoAnunciante.length)
        ? linhasDoAnunciante.sublist(offset, fim)
        : <Map<String, Object?>>[];

    final paramsBase = parametrosDoAnunciante(anunciante);

    String? montarUrl(int novoOffset) {
      if (novoOffset < 0 || novoOffset >= linhasDoAnunciante.length) {
        return null;
      }
      final query = {...paramsBase, 'cursor': _codificarCursor(novoOffset)};
      return Uri.parse(
        _urlBaseMock,
      ).replace(queryParameters: query).toString();
    }

    return ImoveisEnvelopeModel.fromJson({
      'next': montarUrl(offset + _tamanhoPagina),
      'previous': offset > 0
          ? montarUrl((offset - _tamanhoPagina).clamp(0, offset - 1))
          : null,
      'results': [for (final linha in pagina) _semChavesProibidas(linha)],
    });
  }

  static Map<String, Object?> _semChavesProibidas(Map<String, Object?> linha) =>
      {
        for (final entrada in linha.entries)
          if (!_chavesProibidas.contains(entrada.key))
            entrada.key: entrada.value,
      };

  static String _codificarCursor(int offset) =>
      base64Url.encode(utf8.encode('o=$offset'));

  static int _decodificarCursor(String cursor) {
    try {
      final decodificado = utf8.decode(base64Url.decode(cursor));
      if (!decodificado.startsWith('o=')) {
        throw const FormatException('cursor de paginação inválido');
      }
      return int.parse(decodificado.substring(2));
    } on FormatException {
      rethrow;
    } on Exception {
      throw const FormatException('cursor de paginação inválido');
    }
  }

  /// `criado_em` decrescente, com `id` decrescente como desempate estável
  /// (§12.4 `mais_recentes`).
  static int _compararPorRecenciaDesc(
    Map<String, Object?> a,
    Map<String, Object?> b,
  ) {
    final criadoEmA = a['criado_em']! as String;
    final criadoEmB = b['criado_em']! as String;
    final comparacaoData = criadoEmB.compareTo(criadoEmA);
    if (comparacaoData != 0) return comparacaoData;
    return (b['id']! as int).compareTo(a['id']! as int);
  }
}
