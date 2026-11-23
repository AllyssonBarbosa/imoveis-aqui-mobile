import 'package:intl/intl.dart';

import '../../domain/entities/canal_contato.dart';
import '../../domain/entities/contato_recebido.dart';
import '../../domain/entities/retorno_contato.dart';

/// Funções puras e textos da caixa "Meus contatos" — a tela e os widgets só
/// apresentam, nunca decidem nada de negócio. Todo texto mostrado é fixo do
/// app (T-10-19): enums e datas atravessam do servidor, mensagens e rótulos
/// não.

/// Título da `AppBar` da tela.
const String tituloCaixaContatos = 'Meus contatos';

/// Caixa sem nenhum contato e sem filtro ativo (D-21).
const String textoCaixaVazia = 'Você ainda não recebeu contatos.';

/// Filtros ativos que não devolvem nada (D-21).
const String textoCaixaSemResultado = 'Nenhum contato encontrado.';

/// Falha ao carregar a primeira página da caixa (D-21).
const String textoErroCaixa = 'Não foi possível carregar os contatos.';

/// Falha ao carregar uma página seguinte; vai no rodapé da lista (D-12).
const String textoErroAoCarregarMaisContatos =
    'Não foi possível carregar mais contatos';

/// Linha do número de contatos sem retorno (D-07).
String textoSemRetorno(int quantidade) {
  if (quantidade == 0) return 'Nenhum contato sem retorno';
  if (quantidade == 1) return '1 contato sem retorno';
  return '$quantidade contatos sem retorno';
}

/// Data e hora no formato do site (`dd/MM/yyyy HH:mm`).
///
/// Função pura sobre uma data que já é local; sem `toLocal` aqui. O
/// `DateFormat` não leva locale de propósito: o padrão só tem dígitos e `/`,
/// e um locale explícito exigiria os dados de formatação inicializados em
/// qualquer teste que use a função.
String formatarDataHoraContato(DateTime local) =>
    DateFormat('dd/MM/yyyy HH:mm').format(local);

/// "anotado em dd/MM/yyyy HH:mm" — só mostrado quando há `retornoEm`.
String textoAnotadoEm(DateTime local) =>
    'anotado em ${formatarDataHoraContato(local)}';

/// "código — título" do imóvel do contato (travessão com espaços).
String rotuloImovelDoContato(ContatoRecebido contato) =>
    '${contato.imovelCodigo} — ${contato.imovelTitulo}';

/// Nome do canal como o site mostra (D-09). O rótulo de AÇÃO da tela do
/// anúncio ("Ligar", "Enviar e-mail") não serve aqui.
extension NomeCanalContato on CanalContato {
  String get nomeExibicao => switch (this) {
    CanalContato.whatsapp => 'WhatsApp',
    CanalContato.telefone => 'Telefone',
    CanalContato.email => 'E-mail',
  };
}

/// Rótulo fixo de cada retorno, igual ao do site (D-10).
extension ApresentacaoRetornoContato on RetornoContato {
  String get rotulo => switch (this) {
    RetornoContato.pendente => 'Aguardando retorno',
    RetornoContato.falei => 'Falei',
    RetornoContato.visitaAgendada => 'Visita agendada',
    RetornoContato.semResposta => 'Sem resposta',
    RetornoContato.descartado => 'Descartado',
  };
}
