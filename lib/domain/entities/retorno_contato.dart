/// Retorno anotado pelo corretor para um contato recebido (CXA-03).
///
/// [pendente] é só o estado inicial de todo contato novo: a API recusa anotá-lo
/// (D-14), por isso [anotaveis] não o inclui. Os nomes do wire moram só em
/// `data/` (`RetornoContatoNaApi`); o rótulo mostrado ao corretor é da
/// apresentação (D-10).
enum RetornoContato {
  pendente,
  falei,
  visitaAgendada,
  semResposta,
  descartado;

  /// Valores que o corretor pode anotar, na ordem em que a tela os oferece.
  /// PENDENTE é só o estado inicial; a API recusa anotá-lo — D-14.
  static const List<RetornoContato> anotaveis = [
    falei,
    visitaAgendada,
    semResposta,
    descartado,
  ];
}
