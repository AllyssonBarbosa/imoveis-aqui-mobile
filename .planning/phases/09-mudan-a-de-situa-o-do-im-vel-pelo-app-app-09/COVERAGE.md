# API Coverage — mudança de situação do imóvel pelo app (APP 09)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

Superfície: rotas da API Django do repo web (`config/urls.py`, `origin/main@8bf4448` + o que a branch `feat/APP09`
acrescenta — só testes, D-08) que tocam o detalhe, o histórico e a situação de um imóvel do acervo do corretor.
Chamadas no app: `lib/data/datasources/gestao_imovel_remote_datasource.dart`. Planos: 09-01..09-13.

| capability | decision | reason |
|---|---|---|
| GET /api/imoveis/{id}/ (detalhe do acervo) | INTEGRATE | lê `situacao`, `situacao_desde` e `pode_mudar_situacao` |
| POST /api/imoveis/{id}/situacao/ | INTEGRATE | corpo `{situacao, observacao}`; trata 200 / 400 / 401 / 403 / 404 |
| GET /api/imoveis/{id}/historico/ | INTEGRATE | lista sem paginação, na ordem do servidor |
| 400 de recusa com a mensagem do servidor | INTEGRATE | mesma situação, situação inválida, contrato assinado |
| 403 do colega sem permissão | INTEGRATE | botão escondido por `pode_mudar_situacao`; 403 forçado tratado |
| 401 / token revogado no envio | INTEGRATE | volta ao login com "Sua sessão terminou. Entre de novo." |
| 404 de imóvel de outra empresa | INTEGRATE | isolamento coberto no Django |
| GET /api/imoveis/ (recarga do acervo ao voltar) | INTEGRATE | já integrado na fase 08; aqui só é reconsultado com `mudou` |
| corpo do 200 do POST como estado novo | OPT-OUT | not needed — D-10 manda reler imóvel e histórico; o app nunca monta estado novo (AC-2) |
| PATCH/PUT /api/imoveis/{id}/ (edição pelo app) | OPT-OUT | explicitly out of scope — Deferred Ideas do CONTEXT ("Dados completos … e edição pelo app: fora do card") |
| /api/gestao/imoveis/{id}/situacao/ e /historico/ | OPT-OUT | explicitly out of scope — área do gestor no app é a APP-12 (D-07); o gestor vê a tela de aviso |
| data informada pelo corretor na mudança | OPT-OUT | explicitly out of scope — exige campo novo em `HistoricoSituacao` e migração no Django (Deferred Ideas) |
| endereço, fotos, documentos, prédios, loteamentos, quadras | OPT-OUT | explicitly out of scope — cadastro do acervo é do painel web |
| proprietários, clientes, contratos, parcelas, baixas e relatórios | OPT-OUT | explicitly out of scope — o contrato só aparece como motivo da recusa 400, lido da mensagem do servidor |
| limite de tamanho da observação (`max_length`) | OPT-OUT | not needed now — o modelo não define limite; pedido à equipe web é decisão aberta (L8, UAT teste 5) |
