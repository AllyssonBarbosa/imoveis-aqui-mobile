import '../../domain/entities/retorno_contato.dart';

/// Nomes de [RetornoContato] no wire da API — o único lugar onde eles vivem
/// (D-10); o domínio e a apresentação só enxergam o enum.
extension RetornoContatoNaApi on RetornoContato {
  String get valorApi => switch (this) {
    RetornoContato.pendente => 'PENDENTE',
    RetornoContato.falei => 'FALEI',
    RetornoContato.visitaAgendada => 'VISITA_AGENDADA',
    RetornoContato.semResposta => 'SEM_RESPOSTA',
    RetornoContato.descartado => 'DESCARTADO',
  };
}

/// Lê o retorno do wire (inverso de [RetornoContatoNaApi.valorApi]). Um valor
/// fora do conjunto conhecido lança [FormatException]: o Model da caixa (10-05)
/// usa esta função e o repositório converte a exceção em falha.
RetornoContato retornoContatoDaApi(String valor) {
  return switch (valor) {
    'PENDENTE' => RetornoContato.pendente,
    'FALEI' => RetornoContato.falei,
    'VISITA_AGENDADA' => RetornoContato.visitaAgendada,
    'SEM_RESPOSTA' => RetornoContato.semResposta,
    'DESCARTADO' => RetornoContato.descartado,
    _ => throw FormatException('retorno desconhecido: $valor'),
  };
}
