# API Coverage — autenticação da API Django (WEB 01) + acervo do corretor (§14)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

Superfície: rotas da API Django do repo web (`C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web`, `config/urls.py`,
`main@d9ddd8f` + o que a branch `feat/APP08` acrescenta) que tocam login, sessão do app e imóveis do corretor. Planos:
08-01..08-12.

| capability | decision | reason |
|---|---|---|
| POST /api/auth/login/ (token DRF) — login pelo app | INTEGRATE | |
| limite de tentativas no login (429 + Retry-After, por e-mail e por IP) | INTEGRATE | |
| GET /api/auth/eu/ ("quem sou eu", papel) — rota nova | INTEGRATE | |
| POST /api/auth/sair/ (revoga o token) — rota nova | INTEGRATE | |
| GET /api/imoveis/ (acervo do corretor: paginado, busca, situação, 10 chaves) | INTEGRATE | |
| GET /api/imoveis/{id}/ de outra empresa → 404 (isolamento, testado no Django) | INTEGRATE | |
| GET /api/imoveis/{id}/ (detalhe do acervo, inclusive não publicado) | OPT-OUT | explicitly out of scope — Deferred Ideas do CONTEXT ("Detalhe do acervo"); o toque abre a página pública que já existe (D-07) |
| POST/PUT/PATCH /api/imoveis/ (cadastro e edição pelo app) | OPT-OUT | explicitly out of scope — o card APP 08 pede só a lista do acervo |
| POST /api/imoveis/{id}/situacao/ e GET /api/imoveis/{id}/historico/ | OPT-OUT | explicitly out of scope — nada que mude estado é decidido no app; o card só filtra por situação |
| /api/imoveis/{id}/endereco/, fotos, documentos, prédios, loteamentos, quadras | OPT-OUT | explicitly out of scope — cadastro do acervo é do painel web |
| /api/gestao/imoveis/ (EhGestor: publicar, despublicar, situação) | OPT-OUT | explicitly out of scope — área do gestor no app é a APP-12 (D-B) |
| GET /api/usuarios/ (corretores da empresa) | OPT-OUT | not needed — nenhuma tela da fase lista usuários; o papel vem de /api/auth/eu/ |
| proprietários, clientes, contratos, parcelas, baixas e relatórios (/api/...) | OPT-OUT | explicitly out of scope — áreas logadas de outros cards (contratos e gestão), fora do APP 08 |
| token por aparelho (Sair sem desconectar os outros aparelhos) | OPT-OUT | explicitly out of scope — Deferred Ideas do CONTEXT; consequência aceita do token único registrada no §14.4 |
