import 'package:flutter/widgets.dart';

/// Nome da rota da vitrine (a [CidadeSelecaoScreen] que hospeda a vitrine).
///
/// No primeiro uso, sem cidade salva, a primeira rota é a tela de priming e a
/// vitrine é empurrada por cima dela. Por isso "voltar à vitrine" não pode
/// significar "voltar à primeira rota": o usuário já escolheu a cidade, e cair
/// de novo no priming seria um passo regredido.
const String nomeRotaVitrine = 'vitrine';

/// Configuração da rota da vitrine, para `MaterialPageRoute(settings: ...)`.
const RouteSettings configuracaoRotaVitrine = RouteSettings(
  name: nomeRotaVitrine,
);

/// Predicado de `popUntil`/`pushAndRemoveUntil` que para na vitrine: a rota
/// nomeada [nomeRotaVitrine] ou, quando já existe cidade salva e a vitrine é
/// a própria `home`, a primeira rota.
bool eRotaDaVitrine(Route<dynamic> rota) =>
    rota.settings.name == nomeRotaVitrine || rota.isFirst;
