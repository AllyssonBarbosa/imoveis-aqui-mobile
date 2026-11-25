import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/di/modulo_rede.dart';

/// Base URL do servidor de captura das fixtures (os `next`/`previous` das
/// fixtures de lista são absolutos nesta origem — 05-06).
const String urlBaseApiFalsa = 'http://127.0.0.1:8000';

/// Lê e decodifica `test/fixtures/api/<nomeArquivo>` (JSON capturado da API
/// real — nunca escrito à mão).
Object? lerFixtureApi(String nomeArquivo) {
  final arquivo = File('test/fixtures/api/$nomeArquivo');
  return jsonDecode(arquivo.readAsStringSync());
}

/// Uma requisição como a [ApiFalsa] a recebeu: URL, método e cabeçalhos (cópia
/// do que o Dio mandou, depois de passar pelos interceptors).
class RequisicaoGravada {
  RequisicaoGravada({
    required this.uri,
    required this.metodo,
    required Map<String, Object?> cabecalhos,
    this.corpo,
  }) : cabecalhos = Map.unmodifiable(cabecalhos);

  final Uri uri;
  final String metodo;
  final Map<String, Object?> cabecalhos;

  /// Corpo enviado (`RequestOptions.data`), ou nulo se o pedido não tem corpo.
  final Object? corpo;

  /// Valor do cabeçalho [nome] (sem diferenciar maiúsculas), ou nulo.
  String? cabecalho(String nome) {
    for (final entrada in cabecalhos.entries) {
      if (entrada.key.toLowerCase() == nome.toLowerCase()) {
        return entrada.value?.toString();
      }
    }
    return null;
  }
}

class _Sobrescrita {
  const _Sobrescrita(
    this.quando,
    this.status,
    this.fixture,
    this.corpo,
    this.cabecalhos,
  );

  final bool Function(Uri uri) quando;
  final int status;
  final String? fixture;
  final Object? corpo;
  final Map<String, List<String>>? cabecalhos;
}

/// Uma chamada HTTP recebida pela [ApiFalsa]: método, URI, corpo enviado e
/// cabeçalhos da requisição (para provar que o contato anônimo não leva
/// credencial, C6).
class ChamadaApiFalsa {
  const ChamadaApiFalsa({
    required this.metodo,
    required this.uri,
    required this.corpo,
    required this.cabecalhos,
  });

  /// Método HTTP em maiúsculas (`GET`, `POST`).
  final String metodo;

  final Uri uri;

  /// Corpo enviado já decodificado (o `Map` passado ao dio ou o JSON de uma
  /// string); nulo em requisições sem corpo.
  final Object? corpo;

  /// Cabeçalhos da requisição como o dio os montou.
  final Map<String, Object?> cabecalhos;
}

class _Falha {
  _Falha(this.caminho, this.status, this.restantes);

  final String caminho;
  final int status;
  int restantes;
}

/// API pública falsa: um [Dio] sobre um `HttpClientAdapter` de teste que serve
/// as fixtures de `test/fixtures/api/` por rota e grava as requisições. Sem
/// pacote novo. Rotas: cidades e `/api/publico/cidades/<id>/imoveis/` (página
/// 2 com `page=2`; só Campinas tem imóveis capturados, as outras cidades
/// recebem a lista vazia), bairros da cidade (`/bairros/`, só Campinas tem
/// bairros capturados, as outras cidades recebem `[]`) e o catálogo de
/// características. O detalhe (`/api/publico/imoveis/<id>/`) serve o
/// `detalhe_*.json` capturado cujo `id` bate, senão 404 com
/// `erro_404_detalhe.json`. Os perfis (`/api/publico/corretores/<id>/` e
/// `/api/publico/empresas/<id>/`) servem `perfil_corretor.json` e
/// `perfil_empresa.json` quando o id é o capturado; a vitrine do anunciante
/// (`/api/publico/<corretores|empresas>/<id>/imoveis/`) serve
/// `vitrine_<corretor|empresa>_p1.json` (p2 com `page=2`) para o id do perfil
/// capturado. Id sem fixture nessas rotas responde 404 com
/// `erro_404_perfil.json`, o mesmo `{detail}` que o Django devolve (o app nunca
/// lê o texto). As rotas de autenticação: `POST /api/auth/login/` serve
/// `login_200.json`; `GET /api/auth/eu/` serve `eu_corretor.json` e
/// `POST /api/auth/sair/` responde 204, ambos só com `Authorization: Token ...`
/// (senão 401 com `erro_401.json`). O acervo do corretor (`GET /api/imoveis/`)
/// também exige o token (senão 401) e serve `acervo_p1.json` (`acervo_p2.json`
/// com `page=2`, `acervo_busca.json` com `busca` não vazia e
/// `acervo_situacao_vazia.json` com `situacao=VENDIDO`). O imóvel de gestão
/// (`GET /api/imoveis/<id>/`) também exige o token (senão 401) e serve o
/// primeiro `imovel_gestao_*.json` (ordem alfabética) cujo `id` bate, senão 404
/// com `erro_404_imovel.json`. O histórico de situações
/// (`GET /api/imoveis/<id>/historico/`) também exige o token (senão 401) e serve
/// `historico_vazio.json` (os testes trocam por `responder`). A mudança de
/// situação (`POST /api/imoveis/<id>/situacao/`) responde 405 fora do POST, 401
/// sem token e 200 `situacao_200.json` com token. A caixa de contatos do
/// corretor também exige o token (senão 401): `GET /api/contatos/` serve
/// `contatos_p1.json` (`contatos_p2.json` com `page=2`, `contatos_imovel.json`
/// com `imovel` não vazio e `contatos_periodo_vazio.json` com `de` ou `ate`),
/// `GET /api/contatos/resumo/` serve `contatos_resumo.json` (e
/// `contatos_resumo_apos.json` depois de um PATCH aceito, o número cai pelo
/// servidor), `GET /api/contatos/imoveis/` serve `contatos_imoveis.json` e
/// `PATCH /api/contatos/<id>/` responde 200 com `contato_patch_200.json` para o
/// id dessa fixture, 400 com `erro_400_retorno.json` para retorno fora do
/// conjunto anotável e 404 com `erro_404_contato.json` para outro id. Atenção:
/// [falharProximas] casa por PREFIXO do caminho, então `'/api/contatos/'`
/// também falha `/api/contatos/resumo/`; para falhar só a lista use
/// `responder((uri) => uri.path == '/api/contatos/', ...)`.
/// O contato (`POST /api/publico/imoveis/<id>/contato/`)
/// responde 201 com `contato_201_<canal>.json` quando o `canal` do corpo está em
/// `canais_contato` do detalhe do id, 400 com `erro_400_canal_contato.json`
/// quando não está, 404 para id fora das fixtures e 405 para outro método.
/// Os relatórios do gestor (`GET /api/relatorios/acervo/`,
/// `.../acervo-por-corretor/`, `.../contatos/` e `.../mudancas-situacao/`)
/// também exigem o token (senão 401 com `erro_401.json`) e servem
/// `relatorio_acervo.json`, `relatorio_acervo_por_corretor.json`,
/// `relatorio_contatos.json` (`relatorio_contatos_periodo.json` com `de` ou
/// `ate` não vazios) e `relatorio_mudancas.json`. A `ApiFalsa` não decide o
/// papel: o 403 de quem não é gestor se simula com `responder(..., status:
/// 403, fixture: 'erro_403_relatorio.json')`; [requisicoesDosRelatorios] lista
/// só esses pedidos.
/// Rota ainda não servida responde 404 com um objeto JSON vazio.
/// Cada requisição é gravada com método e cabeçalhos ([requisicoesGravadas]) e,
/// com o corpo já decodificado, em [chamadas];
/// e [criarDioAutenticado] monta o mesmo `Dio` autenticado da produção sobre a
/// rede falsa, para provar o que o app envia (ex.: `Authorization`).
class ApiFalsa {
  ApiFalsa({this.latencia = Duration.zero});

  /// Atraso aplicado antes de cada resposta (para testar estados de loading).
  final Duration latencia;

  final List<Uri> _requisicoes = [];
  final List<ChamadaApiFalsa> _chamadas = [];
  final List<RequisicaoGravada> _gravadas = [];
  final List<_Sobrescrita> _sobrescritas = [];
  final List<_Falha> _falhas = [];

  /// Verdadeiro depois que um `PATCH /api/contatos/<id>/` foi aceito: o resumo
  /// passa a servir `contatos_resumo_apos.json` (o número cai pelo servidor).
  bool _retornoAnotado = false;

  /// Todas as URIs requisitadas, na ordem.
  List<Uri> get requisicoes => List.unmodifiable(_requisicoes);

  /// Todas as chamadas (método, URI, corpo e cabeçalhos), na ordem.
  List<ChamadaApiFalsa> get chamadas => List.unmodifiable(_chamadas);

  /// Todas as requisições com método e cabeçalhos, na ordem.
  List<RequisicaoGravada> get requisicoesGravadas =>
      List.unmodifiable(_gravadas);

  /// Última requisição à lista de imóveis de uma cidade
  /// (`/api/publico/cidades/<id>/imoveis/`), ou nulo se ainda não houve.
  Uri? get ultimaRequisicaoDaLista {
    for (final uri in _requisicoes.reversed) {
      if (_idDaListaDeImoveis(uri.path) != null) return uri;
    }
    return null;
  }

  /// Última requisição a uma rota da caixa de contatos (caminho que começa com
  /// `/api/contatos/`), ou nulo se ainda não houve.
  Uri? get ultimaRequisicaoDaCaixa {
    for (final uri in _requisicoes.reversed) {
      if (uri.path.startsWith('/api/contatos/')) return uri;
    }
    return null;
  }

  /// Requisições às rotas dos relatórios do gestor (caminho que começa com
  /// `/api/relatorios/`), na ordem.
  List<Uri> get requisicoesDosRelatorios => List.unmodifiable(
    _requisicoes.where((uri) => uri.path.startsWith('/api/relatorios/')),
  );

  /// Registra uma resposta que vale para as URIs em que [quando] é verdadeiro.
  /// Vale a última registrada. [fixture] é o nome do arquivo em
  /// `test/fixtures/api/`; [corpo] serve um valor JSON derivado de uma
  /// fixture (ex.: uma cópia com uma chave alterada para simular wire
  /// malformado). Sem nenhum dos dois o corpo é um objeto JSON vazio.
  /// [cabecalhos] são somados aos cabeçalhos da resposta (ex.: `Retry-After`
  /// de um 429).
  void responder(
    bool Function(Uri uri) quando, {
    required int status,
    String? fixture,
    Object? corpo,
    Map<String, List<String>>? cabecalhos,
  }) {
    _sobrescritas.add(_Sobrescrita(quando, status, fixture, corpo, cabecalhos));
  }

  /// As próximas [vezes] requisições cujo caminho começa com [caminho]
  /// respondem [status] com um objeto JSON vazio no corpo; depois disso a rota
  /// volta a responder normalmente.
  void falharProximas(String caminho, {int status = 500, int vezes = 1}) {
    _falhas.add(_Falha(caminho, status, vezes));
  }

  Dio criarDio() {
    final dio = Dio(BaseOptions(baseUrl: urlBaseApiFalsa));
    dio.httpClientAdapter = _AdaptadorApiFalsa(this);
    return dio;
  }

  /// O `Dio` autenticado de produção ([construirDioAutenticado]) com o
  /// [interceptador] dado, trocando só o adaptador pela rede falsa.
  Dio criarDioAutenticado(InterceptadorSessao interceptador) {
    final dio = construirDioAutenticado(
      urlBase: urlBaseApiFalsa,
      interceptador: interceptador,
    );
    dio.httpClientAdapter = _AdaptadorApiFalsa(this);
    return dio;
  }

  Future<ResponseBody> _atender(RequestOptions opcoes) async {
    final uri = opcoes.uri;
    _requisicoes.add(uri);
    final corpoEnviado = opcoes.data;
    _chamadas.add(
      ChamadaApiFalsa(
        metodo: opcoes.method.toUpperCase(),
        uri: uri,
        corpo: corpoEnviado is String ? jsonDecode(corpoEnviado) : corpoEnviado,
        cabecalhos: Map<String, Object?>.of(opcoes.headers),
      ),
    );
    _gravadas.add(
      RequisicaoGravada(
        uri: uri,
        metodo: opcoes.method,
        cabecalhos: Map<String, Object?>.of(opcoes.headers),
        corpo: opcoes.data,
      ),
    );
    if (latencia > Duration.zero) await Future<void>.delayed(latencia);

    for (final falha in _falhas) {
      if (falha.restantes > 0 && uri.path.startsWith(falha.caminho)) {
        falha.restantes--;
        return _corpoJson(const <String, Object?>{}, falha.status);
      }
    }

    for (final sobrescrita in _sobrescritas.reversed) {
      if (sobrescrita.quando(uri)) {
        return _corpoJson(
          sobrescrita.fixture != null
              ? lerFixtureApi(sobrescrita.fixture!)
              : sobrescrita.corpo ?? const <String, Object?>{},
          sobrescrita.status,
          cabecalhos: sobrescrita.cabecalhos,
        );
      }
    }

    if (uri.path == '/api/publico/cidades/') {
      return _corpoJson(lerFixtureApi('cidades.json'), 200);
    }
    if (uri.path == '/api/publico/caracteristicas/') {
      return _corpoJson(lerFixtureApi('caracteristicas.json'), 200);
    }
    final idDoContato = _idDoContatoDeImovel(uri.path);
    if (idDoContato != null) {
      return _atenderContato(idDoContato, opcoes);
    }
    if (uri.path == '/api/auth/login/' && opcoes.method == 'POST') {
      return _corpoJson(lerFixtureApi('login_200.json'), 200);
    }
    if (uri.path == '/api/auth/eu/' && opcoes.method == 'GET') {
      return _temToken(opcoes)
          ? _corpoJson(lerFixtureApi('eu_corretor.json'), 200)
          : _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    if (uri.path == '/api/auth/sair/' && opcoes.method == 'POST') {
      return _temToken(opcoes)
          ? _semCorpo(204)
          : _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    final rotaDaCaixa = _atenderCaixa(uri, opcoes);
    if (rotaDaCaixa != null) return rotaDaCaixa;
    final rotaDosRelatorios = _atenderRelatorios(uri, opcoes);
    if (rotaDosRelatorios != null) return rotaDosRelatorios;
    if (uri.path == '/api/imoveis/' && opcoes.method == 'GET') {
      if (!_temToken(opcoes)) {
        return _corpoJson(lerFixtureApi('erro_401.json'), 401);
      }
      final String fixture;
      if (uri.queryParameters['page'] == '2') {
        fixture = 'acervo_p2.json';
      } else if ((uri.queryParameters['busca'] ?? '').isNotEmpty) {
        fixture = 'acervo_busca.json';
      } else if (uri.queryParameters['situacao'] == 'VENDIDO') {
        fixture = 'acervo_situacao_vazia.json';
      } else {
        fixture = 'acervo_p1.json';
      }
      return _corpoJson(lerFixtureApi(fixture), 200);
    }
    final idDoHistorico = _idDoHistoricoDeImovel(uri.path);
    if (idDoHistorico != null && opcoes.method == 'GET') {
      return _temToken(opcoes)
          ? _corpoJson(lerFixtureApi('historico_vazio.json'), 200)
          : _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    final idDaSituacao = _idDaSituacaoDeImovel(uri.path);
    if (idDaSituacao != null) {
      if (opcoes.method != 'POST') {
        return _corpoJson(const <String, Object?>{}, 405);
      }
      return _temToken(opcoes)
          ? _corpoJson(lerFixtureApi('situacao_200.json'), 200)
          : _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    final idDaGestao = _idDoImovelDeGestao(uri.path);
    if (idDaGestao != null && opcoes.method == 'GET') {
      if (!_temToken(opcoes)) {
        return _corpoJson(lerFixtureApi('erro_401.json'), 401);
      }
      final fixture = _fixtureDaGestao(idDaGestao);
      return fixture == null
          ? _corpoJson(lerFixtureApi('erro_404_imovel.json'), 404)
          : _corpoJson(lerFixtureApi(fixture), 200);
    }
    final idDoDetalhe = _idDoDetalheDeImovel(uri.path);
    if (idDoDetalhe != null) {
      final fixture = _fixtureDoDetalhe(idDoDetalhe);
      return fixture == null
          ? _corpoJson(lerFixtureApi('erro_404_detalhe.json'), 404)
          : _corpoJson(lerFixtureApi(fixture), 200);
    }
    final perfil = _rotaDePerfil(uri.path);
    if (perfil != null) {
      final (:recurso, :id) = perfil;
      return id == _idDaFixture('perfil_$recurso.json')
          ? _corpoJson(lerFixtureApi('perfil_$recurso.json'), 200)
          : _corpoJson(lerFixtureApi('erro_404_perfil.json'), 404);
    }
    final vitrine = _rotaDaVitrineDoAnunciante(uri.path);
    if (vitrine != null) {
      final (:recurso, :id) = vitrine;
      if (id != _idDaFixture('perfil_$recurso.json')) {
        return _corpoJson(lerFixtureApi('erro_404_perfil.json'), 404);
      }
      final pagina = uri.queryParameters['page'] == '2' ? 'p2' : 'p1';
      return _corpoJson(lerFixtureApi('vitrine_${recurso}_$pagina.json'), 200);
    }
    final cidadeDosBairros = _idDosBairros(uri.path);
    if (cidadeDosBairros != null) {
      return _corpoJson(
        cidadeDosBairros == _idDeCampinas()
            ? lerFixtureApi('bairros_campinas.json')
            : const <String>[],
        200,
      );
    }
    final cidadeDaLista = _idDaListaDeImoveis(uri.path);
    if (cidadeDaLista != null) {
      final String fixture;
      if (cidadeDaLista != _idDeCampinas()) {
        fixture = 'lista_campinas_vazia.json';
      } else if (uri.queryParameters['page'] == '2') {
        fixture = 'lista_campinas_p2.json';
      } else {
        fixture = 'lista_campinas_p1.json';
      }
      return _corpoJson(lerFixtureApi(fixture), 200);
    }
    return _corpoJson(const <String, Object?>{}, 404);
  }

  /// Atende as rotas da caixa de contatos (`/api/contatos/...`), todas com
  /// token (senão 401); nulo se [uri] não é uma delas.
  ResponseBody? _atenderCaixa(Uri uri, RequestOptions opcoes) {
    final metodo = opcoes.method.toUpperCase();
    final idDoContato = _idDoContatoDaCaixa(uri.path);
    final ehRotaDaCaixa =
        (metodo == 'GET' &&
            (uri.path == '/api/contatos/' ||
                uri.path == '/api/contatos/resumo/' ||
                uri.path == '/api/contatos/imoveis/')) ||
        (metodo == 'PATCH' && idDoContato != null);
    if (!ehRotaDaCaixa) return null;
    if (!_temToken(opcoes)) {
      return _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    if (idDoContato != null) return _anotarRetorno(idDoContato, opcoes);
    if (uri.path == '/api/contatos/resumo/') {
      return _corpoJson(
        lerFixtureApi(
          _retornoAnotado
              ? 'contatos_resumo_apos.json'
              : 'contatos_resumo.json',
        ),
        200,
      );
    }
    if (uri.path == '/api/contatos/imoveis/') {
      return _corpoJson(lerFixtureApi('contatos_imoveis.json'), 200);
    }
    final String fixture;
    if (uri.queryParameters['page'] == '2') {
      fixture = 'contatos_p2.json';
    } else if ((uri.queryParameters['imovel'] ?? '').isNotEmpty) {
      fixture = 'contatos_imovel.json';
    } else if ((uri.queryParameters['de'] ?? '').isNotEmpty ||
        (uri.queryParameters['ate'] ?? '').isNotEmpty) {
      fixture = 'contatos_periodo_vazio.json';
    } else {
      fixture = 'contatos_p1.json';
    }
    return _corpoJson(lerFixtureApi(fixture), 200);
  }

  /// Atende as rotas dos relatórios do gestor (`/api/relatorios/...`), todas
  /// `GET` e com token (senão 401); nulo se [uri] não é uma delas. Não decide
  /// papel: o 403 de quem não é gestor é simulado pelos testes com `responder`.
  ResponseBody? _atenderRelatorios(Uri uri, RequestOptions opcoes) {
    if (opcoes.method.toUpperCase() != 'GET') return null;
    const rotas = {
      '/api/relatorios/acervo/',
      '/api/relatorios/acervo-por-corretor/',
      '/api/relatorios/contatos/',
      '/api/relatorios/mudancas-situacao/',
    };
    if (!rotas.contains(uri.path)) return null;
    if (!_temToken(opcoes)) {
      return _corpoJson(lerFixtureApi('erro_401.json'), 401);
    }
    final String fixture;
    switch (uri.path) {
      case '/api/relatorios/acervo/':
        fixture = 'relatorio_acervo.json';
      case '/api/relatorios/acervo-por-corretor/':
        fixture = 'relatorio_acervo_por_corretor.json';
      case '/api/relatorios/mudancas-situacao/':
        fixture = 'relatorio_mudancas.json';
      default:
        fixture =
            (uri.queryParameters['de'] ?? '').isNotEmpty ||
                (uri.queryParameters['ate'] ?? '').isNotEmpty
            ? 'relatorio_contatos_periodo.json'
            : 'relatorio_contatos.json';
    }
    return _corpoJson(lerFixtureApi(fixture), 200);
  }

  /// `PATCH /api/contatos/<id>/`: 400 se o `retorno` do corpo não é um valor
  /// anotável, 200 com `contato_patch_200.json` (e o resumo passa a cair) se o
  /// id é o dessa fixture, 404 nos demais.
  ResponseBody _anotarRetorno(int id, RequestOptions opcoes) {
    const anotaveis = {
      'FALEI',
      'VISITA_AGENDADA',
      'SEM_RESPOSTA',
      'DESCARTADO',
    };
    final dados = opcoes.data;
    final corpo = dados is String ? jsonDecode(dados) : dados;
    final retorno = corpo is Map<Object?, Object?> ? corpo['retorno'] : null;
    if (retorno is! String || !anotaveis.contains(retorno)) {
      return _corpoJson(lerFixtureApi('erro_400_retorno.json'), 400);
    }
    if (id == _idDaFixture('contato_patch_200.json')) {
      _retornoAnotado = true;
      return _corpoJson(lerFixtureApi('contato_patch_200.json'), 200);
    }
    return _corpoJson(lerFixtureApi('erro_404_contato.json'), 404);
  }

  /// Id do contato de `/api/contatos/<id>/`, ou nulo se [caminho] não é essa
  /// rota.
  int? _idDoContatoDaCaixa(String caminho) {
    final casamento = RegExp(r'^/api/contatos/(\d+)/$').firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Atende `POST /api/publico/imoveis/<id>/contato/` com as respostas
  /// capturadas: 405 fora do POST, 404 sem detalhe capturado, 201 quando o
  /// canal está em `canais_contato` do detalhe e 400 nos demais casos.
  ResponseBody _atenderContato(int id, RequestOptions options) {
    if (options.method.toUpperCase() != 'POST') {
      return _corpoJson(const <String, Object?>{}, 405);
    }
    final fixture = _fixtureDoDetalhe(id);
    if (fixture == null) {
      return _corpoJson(lerFixtureApi('erro_404_detalhe.json'), 404);
    }
    final detalhe = lerFixtureApi(fixture)! as Map<String, Object?>;
    final canais = (detalhe['canais_contato'] as List<Object?>? ?? const [])
        .cast<String>();
    final dados = options.data;
    final corpo = dados is String ? jsonDecode(dados) : dados;
    final canal = corpo is Map<Object?, Object?> ? corpo['canal'] : null;
    if (canal is String && canais.contains(canal)) {
      return _corpoJson(
        lerFixtureApi('contato_201_${canal.toLowerCase()}.json'),
        201,
      );
    }
    return _corpoJson(lerFixtureApi('erro_400_canal_contato.json'), 400);
  }

  /// Id do imóvel de `/api/publico/imoveis/<id>/contato/`, ou nulo se
  /// [caminho] não é essa rota.
  int? _idDoContatoDeImovel(String caminho) {
    final casamento = RegExp(r'^/api/publico/imoveis/(\d+)/contato/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id da cidade de `/api/publico/cidades/<id>/imoveis/`, ou nulo se [caminho]
  /// não é essa rota.
  int? _idDaListaDeImoveis(String caminho) {
    final casamento = RegExp(r'^/api/publico/cidades/(\d+)/imoveis/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id do imóvel de `/api/imoveis/<id>/` (rota autenticada da gestão), ou nulo
  /// se [caminho] não é essa rota.
  int? _idDoImovelDeGestao(String caminho) {
    final casamento = RegExp(r'^/api/imoveis/(\d+)/$').firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id do imóvel de `/api/imoveis/<id>/historico/` (rota autenticada do
  /// histórico de situações), ou nulo se [caminho] não é essa rota.
  int? _idDoHistoricoDeImovel(String caminho) {
    final casamento = RegExp(r'^/api/imoveis/(\d+)/historico/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id do imóvel de `/api/imoveis/<id>/situacao/` (rota autenticada da
  /// mudança de situação), ou nulo se [caminho] não é essa rota.
  int? _idDaSituacaoDeImovel(String caminho) {
    final casamento = RegExp(r'^/api/imoveis/(\d+)/situacao/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Nome do `test/fixtures/api/imovel_gestao_*.json` capturado cujo `id` é
  /// [id] (o primeiro na ordem alfabética), ou nulo se nenhum bate.
  String? _fixtureDaGestao(int id) {
    final arquivos =
        Directory('test/fixtures/api')
            .listSync()
            .whereType<File>()
            .map((arquivo) => arquivo.uri.pathSegments.last)
            .where(
              (nome) =>
                  nome.startsWith('imovel_gestao_') && nome.endsWith('.json'),
            )
            .toList()
          ..sort();
    for (final nome in arquivos) {
      final corpo = lerFixtureApi(nome);
      if (corpo is Map<String, Object?> && corpo['id'] == id) return nome;
    }
    return null;
  }

  /// Id do imóvel de `/api/publico/imoveis/<id>/`, ou nulo se [caminho] não é
  /// essa rota.
  int? _idDoDetalheDeImovel(String caminho) {
    final casamento = RegExp(r'^/api/publico/imoveis/(\d+)/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Nome do `test/fixtures/api/detalhe_*.json` capturado cujo `id` é [id],
  /// ou nulo se nenhum bate.
  String? _fixtureDoDetalhe(int id) {
    final arquivos =
        Directory('test/fixtures/api')
            .listSync()
            .whereType<File>()
            .map((arquivo) => arquivo.uri.pathSegments.last)
            .where(
              (nome) => nome.startsWith('detalhe_') && nome.endsWith('.json'),
            )
            .toList()
          ..sort();
    for (final nome in arquivos) {
      final corpo = lerFixtureApi(nome);
      if (corpo is Map<String, Object?> && corpo['id'] == id) return nome;
    }
    return null;
  }

  /// Recurso (`corretor` ou `empresa`) e id de
  /// `/api/publico/corretores/<id>/` ou `/api/publico/empresas/<id>/`, ou nulo
  /// se [caminho] não é essa rota.
  ({String recurso, int id})? _rotaDePerfil(String caminho) {
    final casamento = RegExp(r'^/api/publico/(corretores|empresas)/(\d+)/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return (
      recurso: _recursoNoSingular(casamento.group(1)!),
      id: int.parse(casamento.group(2)!),
    );
  }

  /// Recurso e id de `/api/publico/<corretores|empresas>/<id>/imoveis/`, ou
  /// nulo se [caminho] não é essa rota.
  ({String recurso, int id})? _rotaDaVitrineDoAnunciante(String caminho) {
    final casamento = RegExp(
      r'^/api/publico/(corretores|empresas)/(\d+)/imoveis/$',
    ).firstMatch(caminho);
    if (casamento == null) return null;
    return (
      recurso: _recursoNoSingular(casamento.group(1)!),
      id: int.parse(casamento.group(2)!),
    );
  }

  String _recursoNoSingular(String plural) =>
      plural == 'corretores' ? 'corretor' : 'empresa';

  /// `id` da fixture de perfil capturada [fixture] (os ids nunca ficam fixos no
  /// código: vêm do que o Django devolveu).
  int _idDaFixture(String fixture) =>
      (lerFixtureApi(fixture)! as Map<String, Object?>)['id']! as int;

  /// Id da cidade de `/api/publico/cidades/<id>/bairros/`, ou nulo se
  /// [caminho] não é essa rota.
  int? _idDosBairros(String caminho) {
    final casamento = RegExp(r'^/api/publico/cidades/(\d+)/bairros/$')
        .firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id de Campinas lido de `cidades.json` (as listas capturadas são dela).
  int _idDeCampinas() {
    final cidades = lerFixtureApi('cidades.json')! as List<Object?>;
    final campinas = cidades.cast<Map<String, Object?>>().firstWhere(
      (cidade) => cidade['nome'] == 'Campinas',
    );
    return campinas['id']! as int;
  }

  /// Verdadeiro se o pedido leva `Authorization: Token ...`.
  bool _temToken(RequestOptions opcoes) {
    for (final entrada in opcoes.headers.entries) {
      if (entrada.key.toLowerCase() == 'authorization') {
        return entrada.value.toString().startsWith('Token ');
      }
    }
    return false;
  }

  ResponseBody _semCorpo(int status) => ResponseBody.fromString('', status);

  ResponseBody _corpoJson(
    Object? corpo,
    int status, {
    Map<String, List<String>>? cabecalhos,
  }) {
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...?cabecalhos,
      },
    );
  }
}

class _AdaptadorApiFalsa implements HttpClientAdapter {
  _AdaptadorApiFalsa(this._api);

  final ApiFalsa _api;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _api._atender(options);
  }

  @override
  void close({bool force = false}) {}
}
