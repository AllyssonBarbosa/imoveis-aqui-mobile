# API Coverage — relatórios do gestor da API Django (`relatorios/api/`, `/api/relatorios/...`)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.
>
> A API é a do próprio projeto (repo web): as rotas `acervo` e `contatos` já estão na `main` (W12); `acervo-por-corretor`
> e `mudancas-situacao` são criadas nesta fase pelo 12-01 na `feat/APP12`, capturadas pelo 12-02 e congeladas no §18 do
> contrato pelo 12-03. Todas são `GET` atrás de `EhGestor`, sempre com a empresa do usuário.
>
> Capacidades: `totais-por-situacao` = `GET /api/relatorios/acervo/` (`totais`, `total`); `acervo-natureza-situacao` = a
> mesma rota (`linhas`, `situacoes`); `acervo-por-corretor` = `GET /api/relatorios/acervo-por-corretor/`;
> `contatos-por-corretor` = `GET /api/relatorios/contatos/`; `contatos-periodo` = `?de=&ate=`; `contatos-imovel` =
> `?imovel=`; `mudancas-situacao` = `GET /api/relatorios/mudancas-situacao/` (janela padrão do servidor);
> `mudancas-dias` = `?dias=1..365`; `parcelas` = `GET /api/relatorios/parcelas/`; `gestao-imoveis` = `/api/gestao/imoveis/...`.

| capability | decision | reason |
|---|---|---|
| totais-por-situacao | INTEGRATE | |
| acervo-natureza-situacao | OPT-OUT | explicitly out of scope — o critério 4 pede só o total por situação (D-09) |
| acervo-por-corretor | INTEGRATE | |
| contatos-por-corretor | INTEGRATE | |
| contatos-periodo | INTEGRATE | |
| contatos-imovel | OPT-OUT | explicitly out of scope — o card não pede filtro por imóvel (D-15, Deferred) |
| mudancas-situacao | INTEGRATE | |
| mudancas-dias | OPT-OUT | not needed — a janela é decidida no servidor (7 dias); escolher no app está em Deferred (D-19) |
| parcelas | OPT-OUT | explicitly out of scope — relatório de parcelas fora do card (Deferred) |
| gestao-imoveis | OPT-OUT | explicitly out of scope — tocar na linha e mudar situação pelo gestor estão em Deferred (D-08) |
