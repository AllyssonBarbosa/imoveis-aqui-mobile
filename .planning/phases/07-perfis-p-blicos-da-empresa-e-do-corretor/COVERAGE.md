# API Coverage — WEB 02 (perfis públicos) + vitrine do anunciante (§12)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

Superfície: rotas da API Django do repo irmão (`config/urls.py`, branch `main`) que tocam corretor e
empresa, mais a vitrine do anunciante proposta no §12 do contrato. Planos: 07-01..07-12.

| capability | decision | reason |
|---|---|---|
| GET /api/publico/corretores/{id}/ (perfil público do corretor) | INTEGRATE | |
| GET /api/publico/empresas/{id}/ (perfil público da empresa) | INTEGRATE | |
| 404 dos dois perfis (corretor desativado, empresa inativa) | INTEGRATE | |
| vitrine do anunciante: GET /api/publico/imoveis/ com empresa= ou corretor= (§12) | INTEGRATE | |
| vitrine do anunciante — DataSource real (Dio) | OPT-OUT | not needed yet — o endpoint não existe na web (PENDENTE WEB §12.8 a); nasce quando a web publicar, repetindo a defesa de origem do next |
| ativação da DataSource remota dos perfis no DI | OPT-OUT | not needed yet — a remota fica pronta e testada; a troca de uma anotação acontece junto com a Phase 5 (CONTEXT D-03) |
| campo corretores_ativos da empresa (lista de corretores da imobiliária) | OPT-OUT | explicitly out of scope — Deferred Ideas do CONTEXT (não pedido pelo card) |
| ações de contato (ligar, WhatsApp, e-mail) e registro do contato | OPT-OUT | explicitly out of scope — APP 06 / CON-01, com regra no servidor (CONTEXT D-10) |
| POST /api/auth/login/ (LoginAPIView) | OPT-OUT | explicitly out of scope — o app da vitrine não tem login; área logada é APP 08 / APP 12 |
| /api/usuarios/ (UsuarioViewSet, gestão autenticada de corretores) | OPT-OUT | explicitly out of scope — gestão de corretores é área logada (APP 08 / APP 12) |
