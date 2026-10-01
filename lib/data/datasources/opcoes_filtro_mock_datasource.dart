import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../core/texto_normalizado.dart';
import '../../domain/entities/cidade.dart';
import '../mocks/imoveis_fixture.dart';
import 'opcoes_filtro_datasource.dart';

/// Servidor simulado das opções de bairro/característica (D-20) — deriva
/// tudo das MESMAS linhas do acervo (`linhasAcervoFixture()`), nunca uma
/// lista fixa paralela, mesma disciplina de [ImovelMockDataSource]. O
/// construtor padrão (o único que o `injectable` enxerga) sempre usa o
/// acervo fixo com a latência simulada de rede; testes usam
/// [OpcoesFiltroMockDataSource.paraTeste] para injetar linhas/latência
/// próprias.
@LazySingleton(as: OpcoesFiltroDataSource)
class OpcoesFiltroMockDataSource implements OpcoesFiltroDataSource {
  OpcoesFiltroMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _latencia = const Duration(milliseconds: 300);

  @visibleForTesting
  OpcoesFiltroMockDataSource.paraTeste({
    required List<Map<String, Object?>> linhas,
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _linhas = linhas,
       // ignore: prefer_initializing_formals
       _latencia = latencia;

  final List<Map<String, Object?>> _linhas;
  final Duration _latencia;

  @override
  Future<List<String>> bairros(Cidade cidade) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }
    final chaveCidade = cidade.chaveNatural;
    final bairrosDaCidade = _linhas.where((linha) {
      final cidadeLinha = linha['cidade']! as Map<String, Object?>;
      final cidadeDaLinha = Cidade(
        nome: cidadeLinha['nome']! as String,
        uf: cidadeLinha['uf']! as String,
      );
      return cidadeDaLinha.chaveNatural == chaveCidade;
    }).map((linha) => linha['bairro']! as String);
    return _distinctOrdenadoPorTextoNormalizado(bairrosDaCidade);
  }

  @override
  Future<List<String>> caracteristicas() async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }
    final todas = _linhas.expand(
      (linha) => (linha['caracteristicas']! as List).cast<String>(),
    );
    return _distinctOrdenadoPorTextoNormalizado(todas);
  }

  /// Dedupe por [normalizarTexto] (mantendo a PRIMEIRA grafia encontrada) e
  /// ordena por [normalizarTexto] — é o servidor (simulado) quem decide a
  /// ordem, o app nunca re-ordena (contrato §10 item 8).
  static List<String> _distinctOrdenadoPorTextoNormalizado(
    Iterable<String> valores,
  ) {
    final grafiaPorChave = <String, String>{};
    for (final valor in valores) {
      grafiaPorChave.putIfAbsent(normalizarTexto(valor), () => valor);
    }
    final chavesOrdenadas = grafiaPorChave.keys.toList()..sort();
    return [
      for (final chave in chavesOrdenadas) grafiaPorChave[chave]!,
    ];
  }
}
