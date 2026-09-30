import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../core/texto_normalizado.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../../domain/entities/filtros_vitrine.dart';
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
    return _paginarPelosParametros(
      parametrosDaConsulta(consulta),
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
    final cursorParam = params['cursor'];
    if (cursorParam == null) {
      throw const FormatException(
        'parâmetros ausentes no cursor de paginação',
      );
    }

    final offset = _decodificarCursor(cursorParam);
    return _paginarPelosParametros(params, offset: offset);
  }

  /// Pipeline única usada por [buscar] e [seguir]: interpreta `cidade` e
  /// `ordenacao` do mapa de params — obrigatórios, [FormatException] se
  /// ausentes ou desconhecidos (mesma disciplina de [cidadeDoParametro]/
  /// [ordenacaoDoParametro]) — SINCRONAMENTE, antes de qualquer `await`
  /// (este método NÃO é `async`), para que um param inválido lance direto na
  /// chamada de [buscar]/[seguir], nunca escondido dentro de uma `Future`
  /// resolvida depois. O resto do trabalho fica em [_montarPagina].
  Future<ImoveisEnvelopeModel> _paginarPelosParametros(
    Map<String, String> params, {
    required int offset,
  }) {
    final cidadeParam = params['cidade'];
    final ordenacaoParam = params['ordenacao'];
    if (cidadeParam == null || ordenacaoParam == null) {
      throw const FormatException(
        'parâmetros obrigatórios ausentes (cidade/ordenacao)',
      );
    }
    final cidade = cidadeDoParametro(cidadeParam);
    final ordenacao = ordenacaoDoParametro(ordenacaoParam);
    return _montarPagina(
      cidade: cidade,
      ordenacao: ordenacao,
      params: params,
      offset: offset,
    );
  }

  /// Filtra por cidade -> gatilho de falha simulada (D-15) -> busca em
  /// título+bairro (D-05/D-06) -> aplica os filtros de query params sobre as
  /// linhas de wire (D-01..D-05, antes de ordenar/paginar) -> ordena
  /// conforme [ordenacao] (D-11/D-12) -> corta a fatia
  /// `[offset, offset+tamanhoPagina)`. `next`/`previous` carregam o MESMO
  /// mapa de [params] recebido (menos `cursor`, substituído pelo cursor da
  /// nova página) — todo filtro sobrevive à paginação automaticamente.
  /// Deriva tudo dos argumentos recebidos — nenhum estado mutável entre
  /// chamadas (API-04, concorrência entre cidades).
  Future<ImoveisEnvelopeModel> _montarPagina({
    required Cidade cidade,
    required OrdenacaoVitrine ordenacao,
    required Map<String, String> params,
    required int offset,
  }) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }

    final busca = params['busca'];
    final termoBusca = busca?.trim();
    if (termoBusca != null && normalizarTexto(termoBusca) == 'erro') {
      throw const FalhaSimuladaDoMock();
    }

    final filtros = filtrosDosParametros(params);

    final chaveCidade = cidade.chaveNatural;
    final linhasFiltradas =
        _linhas.where((linha) {
          final cidadeLinha = linha['cidade']! as Map<String, Object?>;
          final cidadeDaLinha = Cidade(
            nome: cidadeLinha['nome']! as String,
            uf: cidadeLinha['uf']! as String,
          );
          if (cidadeDaLinha.chaveNatural != chaveCidade) return false;
          if (!_linhaCasaComBusca(linha, termoBusca)) return false;
          return _linhaCasaComFiltros(linha, filtros);
        }).toList()
        ..sort(_comparadorDe(ordenacao));

    final fim = (offset + _tamanhoPagina).clamp(0, linhasFiltradas.length);
    final pagina = (offset >= 0 && offset < linhasFiltradas.length)
        ? linhasFiltradas.sublist(offset, fim)
        : <Map<String, Object?>>[];

    final paramsBase = Map<String, String>.from(params)..remove('cursor');

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

  /// Aplica os filtros da Fase 3 (D-01..D-05) sobre a linha de wire, ANTES
  /// de ordenar/paginar — nunca depois do parse (mesma doutrina de
  /// [_linhaCasaComBusca]). `finalidade` é inclusiva (D-02:
  /// `finalidade=VENDA` aceita linhas `VENDA` e `VENDA_E_ALUGUEL`;
  /// `finalidade=ALUGUEL` aceita `ALUGUEL` e `VENDA_E_ALUGUEL`); `natureza`
  /// e `bairro` combinam por OU entre valores (D-05); `características`
  /// exige TODAS as marcadas (E, D-04); quartos/suítes/vagas são limiares
  /// "N ou mais" (D-01, `>=`, nunca `==`). Dimensões diferentes combinam
  /// entre si por E. As dimensões de preço/área ainda não têm predicado
  /// (planos 03-03..03-05 as adicionam, cada um estendendo este método).
  static bool _linhaCasaComFiltros(
    Map<String, Object?> linha,
    FiltrosVitrine filtros,
  ) {
    final finalidade = filtros.finalidade;
    if (finalidade != null) {
      final finalidadeLinha = linha['finalidade']! as String;
      final aceitaFinalidade = switch (finalidade) {
        FinalidadeFiltro.venda =>
          finalidadeLinha == 'VENDA' || finalidadeLinha == 'VENDA_E_ALUGUEL',
        FinalidadeFiltro.aluguel =>
          finalidadeLinha == 'ALUGUEL' ||
              finalidadeLinha == 'VENDA_E_ALUGUEL',
      };
      if (!aceitaFinalidade) return false;
    }

    final naturezas = filtros.naturezas;
    if (naturezas.isNotEmpty) {
      final naturezaLinha = linha['natureza']! as String;
      final wireDasNaturezas = naturezas.map(valorWireDaNatureza);
      if (!wireDasNaturezas.contains(naturezaLinha)) return false;
    }

    final quartosMin = filtros.quartosMin;
    if (quartosMin != null && (linha['quartos']! as int) < quartosMin) {
      return false;
    }

    final suitesMin = filtros.suitesMin;
    if (suitesMin != null && (linha['suites']! as int) < suitesMin) {
      return false;
    }

    final vagasMin = filtros.vagasMin;
    if (vagasMin != null && (linha['vagas']! as int) < vagasMin) {
      return false;
    }

    final bairros = filtros.bairros;
    if (bairros.isNotEmpty) {
      final bairroLinha = normalizarTexto(linha['bairro']! as String);
      final bairrosNormalizados = bairros.map(normalizarTexto);
      if (!bairrosNormalizados.contains(bairroLinha)) return false;
    }

    final caracteristicas = filtros.caracteristicas;
    if (caracteristicas.isNotEmpty) {
      final caracteristicasLinha = (linha['caracteristicas']! as List)
          .map((c) => normalizarTexto(c as String))
          .toSet();
      final temTodas = caracteristicas.every(
        (c) => caracteristicasLinha.contains(normalizarTexto(c)),
      );
      if (!temTodas) return false;
    }

    return true;
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
