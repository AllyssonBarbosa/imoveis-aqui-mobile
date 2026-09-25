import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../domain/entities/cidade.dart';
import '../../domain/entities/consulta_imoveis.dart';
import '../mocks/imoveis_fixture.dart';
import '../models/imoveis_envelope_model.dart';
import 'imovel_datasource.dart';

/// Servidor simulado do acervo de imóveis (D-14) — fixture em memória,
/// filtrando por cidade via chave natural (contrato §7.2) sobre as linhas em
/// forma de wire (snake_case), e devolvendo um envelope parseado pela mesma
/// forma real (`ImoveisEnvelopeModel.fromJson`), garantindo que o parsing
/// exercitado aqui é idêntico ao da Fase 4. Nada de valor não-determinístico
/// entra na simulação (D-15).
///
/// O construtor padrão (o único que o `injectable` enxerga) sempre usa o
/// acervo fixo com a latência simulada de rede; testes usam
/// [ImovelMockDataSource.paraTeste] para injetar linhas e latência próprias.
@LazySingleton(as: ImovelDataSource)
class ImovelMockDataSource implements ImovelDataSource {
  ImovelMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _latencia = const Duration(milliseconds: 500);

  @visibleForTesting
  ImovelMockDataSource.paraTeste({
    required List<Map<String, Object?>> linhas,
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _linhas = linhas,
       // ignore: prefer_initializing_formals
       _latencia = latencia;

  final List<Map<String, Object?>> _linhas;
  final Duration _latencia;

  @override
  Future<ImoveisEnvelopeModel> buscar(ConsultaImoveis consulta) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }

    final chaveCidade = consulta.cidade.chaveNatural;
    final linhasFiltradas = _linhas.where((linha) {
      final cidadeLinha = linha['cidade']! as Map<String, Object?>;
      final cidadeDaLinha = Cidade(
        nome: cidadeLinha['nome']! as String,
        uf: cidadeLinha['uf']! as String,
      );
      return cidadeDaLinha.chaveNatural == chaveCidade;
    }).toList()..sort(_compararPorRecenciaDesc);

    return ImoveisEnvelopeModel.fromJson({
      'next': null,
      'previous': null,
      'results': linhasFiltradas,
    });
  }

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) {
    throw const FormatException(
      'Paginação da vitrine chega numa fase seguinte do roteiro.',
    );
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
