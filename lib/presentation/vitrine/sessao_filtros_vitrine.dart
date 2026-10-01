import 'package:injectable/injectable.dart';

import '../../domain/entities/cidade.dart';
import '../../domain/entities/filtros_vitrine.dart';

/// Memória EM SESSÃO (D-14, D-23) dos últimos filtros aplicados na vitrine
/// — campos privados só em memória do processo, nunca gravados no aparelho
/// (só a cidade escolhida é persistida, F1/D-15): fechar e reabrir o app
/// sempre volta sem filtros (nova instância do processo = nova instância
/// deste Cubit via `@lazySingleton`, campos no estado inicial).
///
/// `@lazySingleton` (não `@injectable`) — precisa sobreviver à troca de
/// cidade mesmo que `VitrineCubit` seja recriado do zero a cada cidade
/// (`CidadeSelecaoScreen._CorpoVitrine`, chaveado por `cidade.chaveNatural`).
@lazySingleton
class SessaoFiltrosVitrine {
  Cidade? _cidade;
  FiltrosVitrine _filtros = const FiltrosVitrine();

  /// Registra os filtros aplicados na última consulta de [cidade] — chamado
  /// a cada reinício da vitrine (`VitrineCubit._aplicarConsulta`), nunca só
  /// no "Ver imóveis" do sheet. Uma chamada posterior sempre sobrescreve a
  /// anterior.
  void lembrar(Cidade cidade, FiltrosVitrine filtros) {
    _cidade = cidade;
    _filtros = filtros;
  }

  /// Filtros a usar na primeira consulta de [cidade] (D-14):
  /// - nada lembrado ainda (sessão nova) -> filtro vazio (D-23);
  /// - mesma cidade do último `lembrar` (`chaveNatural` igual) -> os
  ///   filtros tal como foram lembrados;
  /// - outra cidade -> os mesmos filtros gerais, mas com `bairros` limpos —
  ///   bairros pertencem à cidade anterior, nunca vazam para a consulta da
  ///   nova (D-14).
  FiltrosVitrine filtrosPara(Cidade cidade) {
    final cidadeLembrada = _cidade;
    if (cidadeLembrada == null) return const FiltrosVitrine();
    if (cidadeLembrada.chaveNatural == cidade.chaveNatural) return _filtros;
    return _filtros.copyWith(bairros: const {});
  }
}
