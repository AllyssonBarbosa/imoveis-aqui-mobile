/// O que a tela de fotos devolve à gestão quando alguma foto mudou no servidor
/// durante a visita (D-23). `null` (no lugar desta classe) quando nada mudou.
///
/// [urlDaCapa] é a capa que o SERVIDOR marcou na última lista que a tela
/// recebeu (o campo `capa`, nunca escolhida no app), ou `null` se o imóvel
/// ficou sem fotos. Só vale com [capaConhecida]: se a última leitura falhou, a
/// gestão mantém a imagem que já mostrava (e o acervo relê a API na volta).
class FotosAlteradas {
  const FotosAlteradas({required this.urlDaCapa, required this.capaConhecida});

  final String? urlDaCapa;
  final bool capaConhecida;

  @override
  bool operator ==(Object other) =>
      other is FotosAlteradas &&
      other.urlDaCapa == urlDaCapa &&
      other.capaConhecida == capaConhecida;

  @override
  int get hashCode => Object.hash(urlDaCapa, capaConhecida);
}
