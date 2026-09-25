import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../core/texto_normalizado.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/ordenacao_vitrine.dart';
import '../mocks/imoveis_fixture.dart';
import '../models/imoveis_envelope_model.dart';
import 'imovel_datasource.dart';
import 'parametros_consulta_imoveis.dart';

/// Gatilho determinístico de falha do servidor simulado (D-15) — disparado
/// quando o termo de busca (normalizado) é exatamente "erro". Vive só aqui:
/// sai inteira na Fase 4 junto com o resto do mock, nunca em `domain/` ou
/// `presentation/`.
class FalhaSimuladaDoMock implements Exception {
  const FalhaSimuladaDoMock();

  @override
  String toString() =>
      'FalhaSimuladaDoMock: falha determinística provocada pelo termo de '
      'busca "erro" (D-15)';
}

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
  /// gatilho de falha simulada (D-15) -> busca em título+bairro (D-05/D-06)
  /// -> ordena conforme [ordenacao] (D-11/D-12) -> corta a fatia
  /// `[offset, offset+tamanhoPagina)`. Deriva tudo dos argumentos recebidos —
  /// nenhum estado mutável entre chamadas (API-04, concorrência entre
  /// cidades).
  Future<ImoveisEnvelopeModel> _paginar({
    required Cidade cidade,
    required OrdenacaoVitrine ordenacao,
    required String? busca,
    required int offset,
  }) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }

    final termoBusca = busca?.trim();
    if (termoBusca != null && normalizarTexto(termoBusca) == 'erro') {
      throw const FalhaSimuladaDoMock();
    }

    final chaveCidade = cidade.chaveNatural;
    final linhasFiltradas =
        _linhas.where((linha) {
          final cidadeLinha = linha['cidade']! as Map<String, Object?>;
          final cidadeDaLinha = Cidade(
            nome: cidadeLinha['nome']! as String,
            uf: cidadeLinha['uf']! as String,
          );
          if (cidadeDaLinha.chaveNatural != chaveCidade) return false;
          return _linhaCasaComBusca(linha, termoBusca);
        }).toList()
        ..sort(_comparadorDe(ordenacao));

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

  /// Semântica do `SearchFilter` do DRF (D-05/D-06) que a Fase 4 replicará no
  /// servidor real: sem termo, casa tudo; com termo, TODA palavra (separada
  /// por espaço, normalizada) precisa aparecer em `titulo` OU `bairro`
  /// (normalizados) — `descricao` nunca é buscada.
  static bool _linhaCasaComBusca(Map<String, Object?> linha, String? termo) {
    if (termo == null || termo.isEmpty) return true;
    final palavras = normalizarTexto(
      termo,
    ).split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (palavras.isEmpty) return true;
    final tituloNormalizado = normalizarTexto(linha['titulo']! as String);
    final bairroNormalizado = normalizarTexto(linha['bairro']! as String);
    return palavras.every(
      (palavra) =>
          tituloNormalizado.contains(palavra) ||
          bairroNormalizado.contains(palavra),
    );
  }

  /// Escolhe o comparador de acordo com [ordenacao] (D-11). `precoAsc`/
  /// `precoDesc` usam `preco_venda`, `areaAsc`/`areaDesc` usam `area` — em
  /// ambos os casos, valores nulos vão para o FIM independente do sentido
  /// (D-12), nunca uma regra do app: é o servidor simulado que decide. `id`
  /// crescente desempata dentro do grupo de nulos e em empates numéricos,
  /// garantindo uma ordem determinística e estável.
  static int Function(Map<String, Object?>, Map<String, Object?>)
  _comparadorDe(OrdenacaoVitrine ordenacao) {
    switch (ordenacao) {
      case OrdenacaoVitrine.maisRecentes:
        return _compararPorRecenciaDesc;
      case OrdenacaoVitrine.precoAsc:
        return _compararPorCampoNumericoNullsLast(
          'preco_venda',
          ascendente: true,
        );
      case OrdenacaoVitrine.precoDesc:
        return _compararPorCampoNumericoNullsLast(
          'preco_venda',
          ascendente: false,
        );
      case OrdenacaoVitrine.areaAsc:
        return _compararPorCampoNumericoNullsLast('area', ascendente: true);
      case OrdenacaoVitrine.areaDesc:
        return _compararPorCampoNumericoNullsLast('area', ascendente: false);
    }
  }

  static int Function(Map<String, Object?>, Map<String, Object?>)
  _compararPorCampoNumericoNullsLast(String campo, {required bool ascendente}) {
    return (a, b) {
      final valorA = a[campo] as String?;
      final valorB = b[campo] as String?;
      if (valorA == null && valorB == null) {
        return (a['id']! as int).compareTo(b['id']! as int);
      }
      if (valorA == null) return 1; // nulls last, qualquer sentido (D-12)
      if (valorB == null) return -1;
      final numeroA = double.parse(valorA);
      final numeroB = double.parse(valorB);
      final comparacao = ascendente
          ? numeroA.compareTo(numeroB)
          : numeroB.compareTo(numeroA);
      if (comparacao != 0) return comparacao;
      return (a['id']! as int).compareTo(b['id']! as int);
    };
  }
}
