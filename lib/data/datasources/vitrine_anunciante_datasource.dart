import '../../domain/entities/anunciante_ref.dart';
import '../models/imoveis_envelope_model.dart';

/// Mapeia [AnuncianteRef] para os query params da vitrine do anunciante
/// (contrato §12.2): `corretor=<id>` ou `empresa=<id>` — exatamente um deles,
/// e nunca cidade, ordenação, busca nem filtros: o recorte e a ordem são do
/// servidor. Simétrica a [anuncianteDosParametros] (o inverso exato).
Map<String, String> parametrosDoAnunciante(AnuncianteRef anunciante) =>
    switch (anunciante) {
      AnuncianteCorretor(:final id) => {'corretor': '$id'},
      AnuncianteEmpresa(:final id) => {'empresa': '$id'},
    };

/// Inverso de [parametrosDoAnunciante]: exige exatamente uma das chaves
/// `corretor` ou `empresa`, com valor inteiro. Qualquer outra forma lança
/// [FormatException] — o equivalente do 400 do contrato (§12.6).
AnuncianteRef anuncianteDosParametros(Map<String, String> parametros) {
  final corretor = parametros['corretor'];
  final empresa = parametros['empresa'];
  if ((corretor == null) == (empresa == null)) {
    throw const FormatException(
      'a vitrine do anunciante exige exatamente um de corretor/empresa',
    );
  }
  if (corretor != null) {
    final id = int.tryParse(corretor);
    if (id == null) {
      throw FormatException('corretor inválido: "$corretor"');
    }
    return AnuncianteRef.corretor(id);
  }
  final id = int.tryParse(empresa!);
  if (id == null) {
    throw FormatException('empresa inválida: "$empresa"');
  }
  return AnuncianteRef.empresa(id);
}

/// Fronteira trocável mock->real da vitrine do anunciante (§12, API-08).
/// Hoje quem a implementa é um servidor simulado (dev-only); quando a web
/// tiver o endpoint (PENDENTE WEB, §12.8 a), uma DataSource `dio` a substitui
/// sem tocar `domain/`/`presentation/` — só a anotação de DI muda.
abstract class VitrineAnuncianteDataSource {
  /// Primeira página da vitrine do [anunciante].
  Future<ImoveisEnvelopeModel> buscar(AnuncianteRef anunciante);

  /// Próxima página, a partir do cursor opaco [proximaPagina].
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina);
}
