/// Situação comercial de um imóvel no acervo do corretor — espelha
/// `Imovel.Situacao` do Django (`DISPONIVEL` | `RESERVADO` | `VENDIDO` |
/// `ALUGADO`, §14.5). Os rótulos de tela ficam na apresentação; o domínio só
/// conhece o valor.
enum SituacaoImovel { disponivel, reservado, vendido, alugado }
