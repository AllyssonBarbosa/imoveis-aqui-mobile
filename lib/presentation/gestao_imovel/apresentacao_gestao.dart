// Textos fixos e formatação da tela de gestão do imóvel — a tela e os widgets
// só apresentam, nunca decidem nada de negócio (mesmo molde de
// `apresentacao_acervo.dart`).

import 'package:intl/intl.dart';

import '../../domain/entities/mudanca_situacao.dart';
import '../../domain/entities/situacao_imovel.dart';
import '../acervo/apresentacao_acervo.dart';

/// Falha ao ler o imóvel na primeira carga; nunca mostra o corpo do erro do
/// servidor (T-09-05).
const String textoErroGestao = 'Não foi possível carregar o imóvel.';

/// Imóvel que o servidor não encontra mais (404) — texto fixo em português; o
/// `detail` em inglês do Django nunca chega à tela (T-09-05).
const String textoImovelForaDoAcervo =
    'Este imóvel não está mais no seu acervo.';

/// SnackBar quando "puxar para atualizar" falha: o conteúdo anterior fica na
/// tela (D-10, AC-2).
const String textoFalhaAoAtualizar = 'Não foi possível atualizar agora.';

/// Rótulo do botão que repete a leitura.
const String rotuloTentarDeNovo = 'Tentar de novo';

/// Título da seção que mostra a situação atual do imóvel.
const String tituloSecaoSituacao = 'Situação';

/// Atalho para a página pública do imóvel (só com `na_vitrine` do servidor).
const String rotuloVerNaVitrine = 'Ver na vitrine';

/// Rótulo do botão que abre a folha de mudança de situação (D-04: só aparece
/// quando o servidor diz `pode_mudar_situacao`).
const String rotuloBotaoMudarSituacao = 'Mudar situação';

/// Título da folha inferior de mudança de situação (D-09).
const String tituloFolhaMudarSituacao = 'Mudar situação';

/// Rótulo do botão que confirma a mudança na folha.
const String rotuloConfirmar = 'Confirmar';

/// Rótulo do campo de observação da folha (D-06: a observação é opcional).
const String rotuloObservacao = 'Observação (opcional)';

/// Dica do campo de observação — a mesma do `SituacaoForm` do site (D-06).
const String dicaObservacao =
    'Ex.: reservado para o cliente João até a assinatura.';

/// "Data: hoje" na folha: só informa. A data gravada é a do servidor
/// (`alterado_em`) e o app nunca envia data (D-05).
const String textoDataHoje = 'Data: hoje';

/// Limite de caracteres da observação no campo (D-17): decisão do usuário em
/// 2026-11-22, exceção à D-06, como proteção de interface (T-09-09). O servidor
/// não limita o tamanho (§16.6), então o limite vive só na tela.
const int limiteObservacao = 500;

/// Falha de rede, tempo esgotado ou 5xx no pedido de mudança; nunca mostra o
/// corpo do erro do servidor (T-09-05). Só a recusa 400/403 exibe a mensagem do
/// próprio servidor (`EnvioRecusado`).
const String textoFalhaAoMudar =
    'Não foi possível mudar a situação agora. Tente de novo.';

/// SnackBar de sucesso: o mesmo texto do site, com a situação em minúsculas
/// (D-10) — "Situação alterada para reservado.".
String textoSituacaoAlterada(SituacaoImovel situacao) =>
    'Situação alterada para ${rotuloSituacao(situacao).toLowerCase()}.';

/// Data e hora de um instante do servidor, `dd/MM/yyyy HH:mm`, no fuso do
/// aparelho (D-05, A3 da pesquisa). Sem locale de propósito: com locale seria
/// preciso inicializar os dados de data antes (RESEARCH, Pitfall 8).
String formatarDataHora(DateTime momento) =>
    DateFormat('dd/MM/yyyy HH:mm').format(momento.toLocal());

/// "desde dd/MM/yyyy HH:mm" — quando o imóvel entrou na situação atual, sempre
/// a data que o servidor mandou (D-05).
String textoDesde(DateTime momento) => 'desde ${formatarDataHora(momento)}';

/// Título da seção do histórico de situações.
const String tituloHistorico = 'Histórico';

/// Imóvel que nunca mudou de situação — o texto do site (D-11).
const String textoHistoricoVazio =
    'Nenhuma mudança ainda — disponível desde o cadastro.';

/// Falha só do histórico; nunca mostra o corpo do erro do servidor (T-09-05).
const String textoErroHistorico = 'Não foi possível carregar o histórico.';

/// Rótulo de uma situação, ou "—" quando o servidor mandou uma que o app não
/// conhece (T-09-10).
String rotuloSituacaoOuTraco(SituacaoImovel? situacao) =>
    situacao == null ? '—' : rotuloSituacao(situacao);

/// "Disponível → Reservado": de qual situação para qual.
String textoDeParaHistorico(MudancaSituacao mudanca) =>
    '${rotuloSituacaoOuTraco(mudanca.situacaoAnterior)} → '
    '${rotuloSituacaoOuTraco(mudanca.situacaoNova)}';

/// "dd/MM/yyyy HH:mm · Nome de quem mudou"; sem nome, só a data e hora.
String textoQuandoEQuem(MudancaSituacao mudanca) {
  final quando = formatarDataHora(mudanca.alteradoEm);
  final nome = mudanca.alteradoPor;
  if (nome == null || nome.isEmpty) return quando;
  return '$quando · $nome';
}
