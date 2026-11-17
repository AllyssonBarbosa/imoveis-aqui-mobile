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
