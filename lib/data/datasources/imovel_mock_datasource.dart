import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/ordenacao_vitrine.dart';
import '../mocks/imoveis_fixture.dart';
import '../models/imoveis_envelope_model.dart';
import 'imovel_datasource.dart';
import 'parametros_consulta_imoveis.dart';

/// Servidor simulado do acervo de imóveis (D-14) — fixture em memória,
/// filtrando por cidade via chave natural (contrato §7.2) sobre as linhas em
/// forma de wire (snake_case), e devolvendo um envelope parseado pela mesma
/// forma real (`ImoveisEnvelopeModel.fromJson`), garantindo que o parsing
/// exercitado aqui é idêntico ao da Fase 4. Nada de valor não-determinístico
/// entra na simulação (D-15).
///
/// Paginação cursor real (D-01/API-04): `next`/`previous` são URLs absolutas
/// no formato `/api/publico/imoveis/?cidade=...&ordenacao=...&cursor=...`
/// (mesmo shape do futuro endpoint Django), com o cursor sendo um
/// `base64Url` opaco de `"o=<offset>"` — nunca interpretado fora desta
/// classe (Cubit/UI só repassam o valor de `next` adiante). Sem estado
/// mutável entre chamadas: cada busca é derivada só dos argumentos
/// recebidos, então consultas concorrentes para cidades diferentes nunca se
/// misturam (API-04).
///
/// O construtor padrão (o único que o `injectable` enxerga) sempre usa o
/// acervo fixo com a latência simulada de rede; testes usam
/// [ImovelMockDataSource.paraTeste] para injetar linhas, latência e tamanho
/// de página próprios.
@LazySingleton(as: ImovelDataSource)
class ImovelMockDataSource implements ImovelDataSource {
  ImovelMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _latencia = const Duration(milliseconds: 500),
      _tamanhoPagina = 10;

  @visibleForTesting
  ImovelMockDataSource.paraTeste({
    required List<Map<String, Object?>> linhas,
    Duration latencia = Duration.zero,
    int tamanhoPagina = 10,
    // ignore: prefer_initializing_formals
  }) : _linhas = linhas,
       // ignore: prefer_initializing_formals
       _latencia = latencia,
       // ignore: prefer_initializing_formals
       _tamanhoPagina = tamanhoPagina;

  final List<Map<String, Object?>> _linhas;
  final Duration _latencia;
  final int _tamanhoPagina;

  /// Base fixa do host simulado — nunca aponta para uma URL real (D-14).
  static const String urlBaseMock =
      'https://mock.imoveisaqui.local$caminhoImoveisPublico';

  @override
  Future<ImoveisEnvelopeModel> buscar(ConsultaImoveis consulta) {
    return _paginar(
      cidade: consulta.cidade,
      ordenacao: consulta.ordenacao,
      busca: consulta.busca,
      offset: 0,
    );
  }

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) {
    final Uri uri;
    try {
      uri = Uri.parse(proximaPagina);
    } on FormatException {
      rethrow;
    }
    final params = uri.queryParameters;
    final cidadeParam = params['cidade'];
    final ordenacaoParam = params['ordenacao'];
    final cursorParam = params['cursor'];
    if (cidadeParam == null || ordenacaoParam == null || cursorParam == null) {
      throw const FormatException(
        'parâmetros ausentes no cursor de paginação',
      );
    }

    final cidade = cidadeDoParametro(cidadeParam);
    final ordenacao = ordenacaoDoParametro(ordenacaoParam);
    final offset = _decodificarCursor(cursorParam);

    return _paginar(
      cidade: cidade,
      ordenacao: ordenacao,
      busca: params['busca'],
      offset: offset,
    );
  }

  /// Pipeline única usada por [buscar] e [seguir]: filtra por cidade ->
  /// [busca]/[ordenacao] são hooks pass-through até o plano 02-05 -> ordena
  /// por recência -> corta a fatia `[offset, offset+tamanhoPagina)`. Deriva
  /// tudo dos argumentos recebidos — nenhum estado mutável entre chamadas
  /// (API-04, concorrência entre cidades).
  Future<ImoveisEnvelopeModel> _paginar({
    required Cidade cidade,
    required OrdenacaoVitrine ordenacao,
    required String? busca,
    required int offset,
  }) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }

    final chaveCidade = cidade.chaveNatural;
    final linhasFiltradas =
        _linhas.where((linha) {
          final cidadeLinha = linha['cidade']! as Map<String, Object?>;
          final cidadeDaLinha = Cidade(
            nome: cidadeLinha['nome']! as String,
            uf: cidadeLinha['uf']! as String,
          );
          return cidadeDaLinha.chaveNatural == chaveCidade;
        }).toList()
        ..sort(_compararPorRecenciaDesc);

    final fim = (offset + _tamanhoPagina).clamp(0, linhasFiltradas.length);
    final pagina = (offset >= 0 && offset < linhasFiltradas.length)
        ? linhasFiltradas.sublist(offset, fim)
        : <Map<String, Object?>>[];

    final paramsBase = parametrosDaConsulta(
      ConsultaImoveis(cidade: cidade, busca: busca, ordenacao: ordenacao),
    );

    String? montarUrl(int novoOffset) {
      if (novoOffset < 0 || novoOffset >= linhasFiltradas.length) return null;
      final query = {...paramsBase, 'cursor': _codificarCursor(novoOffset)};
      return Uri.parse(
        urlBaseMock,
      ).replace(queryParameters: query).toString();
    }

    return ImoveisEnvelopeModel.fromJson({
      'next': montarUrl(offset + _tamanhoPagina),
      'previous': offset > 0
          ? montarUrl((offset - _tamanhoPagina).clamp(0, offset - 1))
          : null,
      'results': pagina,
    });
  }

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

  /// Ordena por data de criação decrescente, com `id` decrescente como
  /// desempate estável (D-11 `maisRecentes`).
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
