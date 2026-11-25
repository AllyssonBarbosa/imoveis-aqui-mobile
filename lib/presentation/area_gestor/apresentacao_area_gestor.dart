import 'package:intl/intl.dart';

import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../acervo/apresentacao_acervo.dart';
import '../gestao_imovel/apresentacao_gestao.dart';
import 'area_gestor_state.dart';

/// Funções puras e textos fixos da Área do gestor — a tela e os widgets só
/// apresentam, nunca decidem nada de negócio. Enums, números e nomes
/// atravessam do servidor; mensagens não (D-23).

/// Título da `AppBar` da tela.
const String tituloAreaGestor = 'Área do gestor';

/// Título da seção dos totais da empresa (D-10).
const String tituloSecaoTotais = 'Totais da empresa por situação';

/// Título da seção do acervo por corretor (D-14).
const String tituloSecaoAcervo = 'Acervo por corretor';

/// Título da seção dos contatos por corretor (D-17).
const String tituloSecaoContatos = 'Contatos por corretor';

/// Nenhum corretor veio do servidor (texto do site).
const String textoNenhumCorretor = 'Nenhum corretor cadastrado.';

/// Linha dos contatos que não são de nenhum corretor (D-17).
const String textoLinhaDaEmpresa = 'Empresa (corretor desativado no clique)';

/// Botão de repetir só o pedido da seção que falhou (D-07).
const String rotuloTentarDeNovoSecao = 'Tentar de novo';

/// Título da seção de mudanças recentes; o número de dias é o que o servidor
/// mandou (D-19). Sem o número (ainda carregando ou falhou), só o título.
String tituloSecaoMudancas(int? dias) {
  const base = 'Mudanças de situação';
  if (dias == null) return base;
  if (dias == 1) return '$base — último dia';
  return '$base — últimos $dias dias';
}

/// Texto fixo de cada falha de seção; nunca o corpo do erro do servidor
/// (D-23, T-12-19).
String textoDaFalha(FalhaDaSecao falha) => switch (falha) {
  FalhaDaSecao.semPermissao =>
    'Só o gestor da imobiliária pode ver estes números.',
  FalhaDaSecao.indisponivel => 'Não foi possível carregar.',
};

/// "Total: N imóveis" (D-10); o N é o `total` do servidor.
String textoTotalImoveis(int total) =>
    total == 1 ? 'Total: 1 imóvel' : 'Total: $total imóveis';

/// Quantidade de imóveis de um corretor (D-14).
String textoImoveisDoCorretor(int total) {
  if (total == 0) return 'Nenhum imóvel';
  if (total == 1) return '1 imóvel';
  return '$total imóveis';
}

/// Nome do corretor, marcado quando está desativado (D-14). `ativo` nulo (a
/// linha da empresa não tem corretor) não marca nada.
String nomeDoCorretor(String nome, {required bool? ativo}) =>
    ativo == false ? '$nome (desativado)' : nome;

/// "N contatos · M aguardando retorno" de um corretor (D-17).
String textoContatosDoCorretor(int total, int pendentes) =>
    '${_contatos(total)} · $pendentes aguardando retorno';

/// "Total: N contatos · M aguardando retorno" da empresa (D-17).
String textoTotalContatos(int total, int pendentes) =>
    'Total: ${_contatos(total)} · $pendentes aguardando retorno';

String _contatos(int total) => total == 1 ? '1 contato' : '$total contatos';

/// Texto do período aplicado à seção de contatos (D-16). O `DateFormat` não
/// leva locale, como em `rotuloChipPeriodo`; o período é de dias, sem hora.
String textoDoPeriodo(PeriodoContatos? periodo) {
  if (periodo == null) return 'Todo o período.';
  final formato = DateFormat('dd/MM/yyyy');
  return 'Período: ${formato.format(periodo.de)} a ${formato.format(periodo.ate)}.';
}

/// Nenhuma mudança de situação na janela que o servidor definiu (D-19).
String textoNenhumaMudanca(int dias) => dias == 1
    ? 'Nenhuma mudança de situação no último dia.'
    : 'Nenhuma mudança de situação nos últimos $dias dias.';

/// "código — título" do imóvel da mudança (D-21).
String rotuloImovelDaMudanca(MudancaRecente mudanca) =>
    '${mudanca.imovelCodigo} — ${mudanca.imovelTitulo}';

/// "Disponível → Reservado": de qual situação para qual (D-21).
String textoDeParaMudanca(MudancaRecente mudanca) =>
    '${rotuloSituacao(mudanca.situacaoAnterior)} → '
    '${rotuloSituacao(mudanca.situacaoNova)}';

/// "dd/MM/yyyy HH:mm · Nome de quem mudou"; sem nome, só a data e hora (D-21).
String textoQuandoEQuemMudanca(MudancaRecente mudanca) {
  final quando = formatarDataHora(mudanca.alteradoEm);
  final nome = mudanca.alteradoPor;
  if (nome.isEmpty) return quando;
  return '$quando · $nome';
}
