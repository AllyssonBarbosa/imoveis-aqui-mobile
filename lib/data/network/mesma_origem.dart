/// Se [destino] está na mesma origem que [base]: scheme, host e porta iguais
/// (a mesma regra que as DataSources remotas aplicam aos links `next` da API).
/// Função pura — quem decide o que fazer com a resposta é o chamador.
bool mesmaOrigem(Uri destino, Uri base) =>
    destino.scheme == base.scheme &&
    destino.host == base.host &&
    destino.port == base.port;
