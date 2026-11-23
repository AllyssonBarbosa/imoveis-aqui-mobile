import 'canal_contato.dart';
import 'retorno_contato.dart';

/// Um contato recebido na caixa do corretor (CXA-01): o item da lista com o
/// imóvel ("código — título"), o canal, quando chegou e o retorno anotado
/// (D-09).
///
/// As datas já estão na hora local do aparelho; o servidor decide o dia em
/// São Paulo. Nenhum dado do visitante existe aqui: a caixa só registra que o
/// contato aconteceu, por qual canal e sobre qual imóvel. [retornoEm] é nulo
/// enquanto o retorno for [RetornoContato.pendente].
class ContatoRecebido {
  const ContatoRecebido({
    required this.id,
    required this.imovelCodigo,
    required this.imovelTitulo,
    required this.canal,
    required this.criadoEm,
    required this.retorno,
    this.retornoEm,
  });

  final int id;
  final String imovelCodigo;
  final String imovelTitulo;
  final CanalContato canal;
  final DateTime criadoEm;
  final RetornoContato retorno;
  final DateTime? retornoEm;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContatoRecebido &&
          other.id == id &&
          other.imovelCodigo == imovelCodigo &&
          other.imovelTitulo == imovelTitulo &&
          other.canal == canal &&
          other.criadoEm == criadoEm &&
          other.retorno == retorno &&
          other.retornoEm == retornoEm);

  @override
  int get hashCode => Object.hash(
    id,
    imovelCodigo,
    imovelTitulo,
    canal,
    criadoEm,
    retorno,
    retornoEm,
  );

  @override
  String toString() =>
      'ContatoRecebido(id: $id, imovel: $imovelCodigo, canal: $canal, '
      'retorno: $retorno)';
}
