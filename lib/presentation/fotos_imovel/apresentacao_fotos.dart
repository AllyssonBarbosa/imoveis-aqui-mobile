// Textos fixos da tela de fotos do imóvel (APP 11) — a tela e os widgets só
// apresentam, nunca decidem nada de negócio (molde de `apresentacao_gestao.dart`).
// O único texto do servidor que aparece é a mensagem de recusa de um envio ou
// de uma reordenação (400/403), achatada, na foto ou no aviso.

/// Título da tela.
const String tituloFotos = 'Fotos';

/// Rótulo do botão que abre a câmera (uma foto por vez).
const String rotuloTirarFoto = 'Tirar foto';

/// Rótulo do botão que abre a galeria (várias fotos).
const String rotuloEscolherDaGaleria = 'Escolher da galeria';

/// Botão da gestão do imóvel que abre esta tela (D-08).
const String rotuloBotaoFotos = 'Fotos';

/// Imóvel sem nenhuma foto no servidor.
const String textoSemFotos = 'Este imóvel ainda não tem fotos.';

/// Falha na primeira leitura da lista.
const String textoErroFotos = 'Não foi possível carregar as fotos.';

// "Tentar de novo" e o texto do 404 vêm de `apresentacao_gestao.dart`
// (`rotuloTentarDeNovo`, `textoImovelForaDoAcervo`): os mesmos da gestão.

/// Envio que falhou sem mensagem do servidor (rede, tempo esgotado, 5xx).
const String textoFalhaEnvio = 'Não foi possível enviar.';

/// Foto que não pôde ser reduzida no aparelho.
const String textoFalhaPreparo = 'Não foi possível preparar a foto.';

/// Tira da fila uma foto que falhou, sem reenviar.
const String rotuloRemover = 'Remover';

/// Estados de um item da fila.
const String textoAguardando = 'Aguardando';
const String textoPreparando = 'Preparando…';
const String textoEnviando = 'Enviando…';

/// Selo da foto de capa (lido do campo `capa` do servidor).
const String rotuloCapa = 'Capa';

/// Ações do menu de cada foto.
const String rotuloDefinirComoCapa = 'Definir como capa';
const String rotuloApagar = 'Apagar';

/// Diálogo de confirmação de exclusão (D-22).
const String tituloConfirmarApagar = 'Apagar esta foto?';
const String rotuloCancelar = 'Cancelar';

/// SnackBar depois de o servidor apagar a foto.
const String textoFotoApagada = 'Foto apagada.';

/// SnackBar quando ordem, capa ou exclusão falham sem texto do servidor; a
/// lista é relida.
const String textoFalhaOperacao = 'Não foi possível salvar a mudança.';

/// SnackBar quando a câmera ou a galeria não abrem.
const String textoFalhaAoEscolher =
    'Não foi possível abrir a câmera ou a galeria.';

/// Diálogo ao sair com envio em andamento (D-18).
const String tituloSairComEnvios = 'Sair e cancelar os envios?';
const String textoSairComEnvios =
    'As fotos que ainda não foram enviadas serão descartadas.';
const String rotuloSair = 'Sair';
const String rotuloContinuarEnviando = 'Continuar enviando';

/// Rótulo de posição de cada foto na lista ("Foto 1", "Foto 2"…).
String rotuloPosicaoDaFoto(int posicao) => 'Foto $posicao';

/// Dica (tooltip) do menu de ações de cada foto.
String rotuloAcoesDaFoto(int posicao) => 'Ações da foto $posicao';
