import 'package:intl/intl.dart';

import '../../domain/entities/consulta_contatos.dart';

// Único lugar do app que conhece os nomes dos parâmetros de consulta da caixa
// de contatos (D-19, D-20): traduz [ConsultaContatos] para o que vai na URL e
// nada mais. Não há filtro local — recortar a caixa é trabalho do servidor.

/// Mapeia [ConsultaContatos] para os query params de `GET /api/contatos/`:
/// `imovel` (id) quando há imóvel escolhido, e `de`/`ate` (`AAAA-MM-DD`) quando
/// há período. Sem filtro, nenhuma chave.
///
/// As datas saem do `DateTime` local como estão, SEM converter para UTC:
/// converter deslocaria o dia. O servidor lê `de`/`ate` como dias de São Paulo
/// (§16.7 do contrato) e é ele quem decide em que dia cada contato cai.
Map<String, String> parametrosDaConsultaContatos(ConsultaContatos consulta) {
  final params = <String, String>{};
  final imovel = consulta.imovel;
  if (imovel != null) params['imovel'] = '${imovel.id}';
  final periodo = consulta.periodo;
  if (periodo != null) {
    final formato = DateFormat('yyyy-MM-dd');
    params['de'] = formato.format(periodo.de);
    params['ate'] = formato.format(periodo.ate);
  }
  return params;
}
