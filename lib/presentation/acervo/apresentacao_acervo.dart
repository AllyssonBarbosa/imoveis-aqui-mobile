import '../../domain/entities/situacao_imovel.dart';

/// Funções puras e textos da tela "Meu acervo" — a tela e os widgets só
/// apresentam, nunca decidem nada de negócio.

/// Título da `AppBar` da tela.
const String tituloAcervo = 'Meu acervo';

/// Dica da `SearchBar` (D-08): o servidor busca por código ou título.
const String dicaBuscaAcervo = 'Buscar por código ou título';

/// Acervo sem nenhum imóvel (sem busca e sem situação).
const String textoAcervoVazio = 'Nenhum imóvel no acervo ainda.';

/// Busca e/ou situação sem nenhum imóvel.
const String textoAcervoSemResultado =
    'Nenhum imóvel encontrado para esta busca ou situação.';

/// Falha ao carregar a primeira página.
const String textoErroAcervo = 'Não foi possível carregar o acervo.';

/// Sessão terminada (401) — a navegação de volta ao login é do 08-10.
const String textoSessaoExpiradaAcervo = 'Sua sessão terminou. Entre de novo.';

/// Marca do cartão para o imóvel do próprio corretor (D-06).
const String rotuloMarcaSeu = 'Seu';

/// Rótulo do chip de situação do cartão e dos chips de filtro.
String rotuloSituacao(SituacaoImovel situacao) => switch (situacao) {
  SituacaoImovel.disponivel => 'Disponível',
  SituacaoImovel.reservado => 'Reservado',
  SituacaoImovel.vendido => 'Vendido',
  SituacaoImovel.alugado => 'Alugado',
};

/// Opções da linha de chips, na ordem da tela (D-09): `null` é "Todas".
const List<SituacaoImovel?> opcoesDeSituacao = [
  null,
  SituacaoImovel.disponivel,
  SituacaoImovel.reservado,
  SituacaoImovel.vendido,
  SituacaoImovel.alugado,
];

/// Rótulo de uma opção da linha de chips — "Todas" para `null`.
String rotuloOpcaoDeSituacao(SituacaoImovel? situacao) =>
    situacao == null ? 'Todas' : rotuloSituacao(situacao);
