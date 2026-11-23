# API Coverage — caixa de contatos da API Django (`ContatoViewSet`, `/api/contatos/`)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.
>
> A API é a do próprio projeto (repo web, branch `feat/APP10`), completada nesta fase pelo 10-01, capturada pelo 10-02
> e congelada no §16 do contrato pelo 10-03. A superfície abaixo é a da caixa de contatos autenticada (`PertenceAUmaEmpresa`); `PUT`,
> `POST` e `DELETE` respondem 405 e não são capacidades da rota.

| capability | decision | reason |
|---|---|---|
| list (`GET /api/contatos/`, envelope paginado, ordem `-criado_em, -id`) | INTEGRATE | |
| filter-imovel (`?imovel=<id>`) | INTEGRATE | |
| filter-periodo (`?de=AAAA-MM-DD&ate=AAAA-MM-DD`) | INTEGRATE | |
| paginate (`?page=` seguindo `next` de mesma origem) | INTEGRATE | |
| resumo (`GET /api/contatos/resumo/` → `{"sem_retorno": N}`) | INTEGRATE | |
| opcoes-imovel (`GET /api/contatos/imoveis/`) | INTEGRATE | |
| anotar-retorno (`PATCH /api/contatos/<id>/` com `{"retorno": ...}`) | INTEGRATE | |
| retrieve (`GET /api/contatos/<id>/`) | OPT-OUT | not needed — o item da lista já traz as 12 chaves e o PATCH devolve o item atualizado |
| escopo-gestor (todos os contatos da empresa, coluna `corretor_nome`) | OPT-OUT | explicitly out of scope — caixa do gestor é a APP-12 (D-03); o app só oferece a entrada ao corretor |
