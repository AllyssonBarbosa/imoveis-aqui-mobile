import '../../domain/entities/canal_contato.dart';

/// Nomes de [CanalContato] no wire da API — o único lugar onde eles vivem;
/// o domínio só enxerga o enum.
extension CanalContatoNaApi on CanalContato {
  String get valorApi => switch (this) {
    CanalContato.whatsapp => 'WHATSAPP',
    CanalContato.telefone => 'TELEFONE',
    CanalContato.email => 'EMAIL',
  };
}

/// Lê o canal do wire (inverso de [CanalContatoNaApi.valorApi]). Um valor fora
/// do conjunto conhecido lança [FormatException]: o Model da caixa (10-05) deixa
/// a exceção subir e o repositório a converte em falha (D-10).
CanalContato canalContatoDaApi(String valor) {
  return switch (valor) {
    'WHATSAPP' => CanalContato.whatsapp,
    'TELEFONE' => CanalContato.telefone,
    'EMAIL' => CanalContato.email,
    _ => throw FormatException('canal desconhecido: $valor'),
  };
}
