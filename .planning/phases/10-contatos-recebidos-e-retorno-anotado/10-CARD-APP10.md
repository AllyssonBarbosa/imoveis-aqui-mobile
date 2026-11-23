# Card APP 10 · Contatos recebidos e retorno anotado (tarefa A10)

Fonte: texto oficial do card, enviado pelo Allysson em 2026-11-22. Usado como PRD da Phase 10.

## História (texto do card, sem alteração)

Como corretor, eu quero ver quem procurou pelos meus imóveis para retornar e não perder negócio.
A lista traz os contatos mais recentes primeiro, com o imóvel, o canal e a data, e permite filtrar
por imóvel e por período. O corretor anota o retorno: falei, visita agendada, sem resposta ou
descartado.
Tarefa A10 do documento de histórias.

Dependência: [WEB] 11 · Contato pelo WhatsApp, registro e caixa do corretor — feito.

## Critérios de aceite (texto do card, sem alteração)

1. Lista dos contatos recebidos, mais recentes primeiro, vinda da API
2. Cada item mostra o imóvel, o canal e a data do contato
3. Filtro por imóvel e por período
4. O corretor anota o retorno, e a anotação é gravada pela API
5. Contato de imóvel de outra empresa nunca aparece
6. A tela mostra quantos contatos ainda estão sem retorno anotado

## O que a API já entrega (repo da web, `origin/main` em 8bf4448, 2026-11-22)

Repo da web: `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` (NÃO é `../imoveis-aqui/Web`).
A caixa de contatos nasceu na WEB 11 (`Web/contatos/`). O app já tem login, sessão e `Dio`
autenticado desde a APP-08 (Phase 8).

- **Lista:** `GET /api/contatos/` (`contatos/api/views.py` `ContatoViewSet`, rota em
  `contatos/api/urls.py` montada em `api/`). Permissão `PertenceAUmaEmpresa` (gestor ou corretor;
  administrador fica de fora), `EmpresaScopedQuerySetMixin` (empresa do usuário) e
  `restringir_ao_perfil` (`contatos/servicos.py`): **corretor vê só os contatos que ele recebeu**,
  gestor vê todos os da empresa. Ordem `-criado_em, -id` (`Contato.Meta.ordering`) — critério 1.
  **Sem paginação**: a API devolve a lista inteira (o site pagina de 50 em 50 em `ContatoListView`).
- **Campos do item** (`ContatoSerializer`): `id`, `imovel`, `imovel_codigo`, `imovel_titulo`,
  `corretor`, `corretor_nome`, `canal` (`WHATSAPP | TELEFONE | EMAIL`), `canal_exibicao`,
  `criado_em`, `retorno`, `retorno_exibicao`, `retorno_em` — critério 2. Nenhum dado do visitante é
  guardado (nem nome, nem telefone): o contato registra só imóvel, corretor, canal e data.
- **Filtros:** `?imovel=<id>&de=AAAA-MM-DD&ate=AAAA-MM-DD` (`filtrar_contatos`, datas inclusivas;
  `de > ate` ou `imovel` não numérico → 400 com mensagem) — critério 3.
- **Retorno anotado:** `PATCH /api/contatos/{id}/` com `{"retorno": ...}`, aceitando só
  `FALEI | VISITA_AGENDADA | SEM_RESPOSTA | DESCARTADO` (`Contato.RETORNOS_ANOTAVEIS`); grava também
  `retorno_em` (`Contato.anotar_retorno`). `PENDENTE` é só o estado inicial e não pode ser anotado de
  volta. Só o retorno muda; o resto do contato é somente leitura. Sem POST/DELETE — critério 4.
- **Isolamento:** empresa + perfil; contato de outra empresa ou de outro corretor cai em 404 pelo id;
  testado em `contatos/tests.py` (`IsolamentoTests`, `CaixaDeContatosTests`, `AnotarRetornoTests`)
  — critério 5 já garantido no servidor.
- **Regra do site:** a caixa do painel (`contatos/views.py` `ContatoListView`) usa
  `contatos_visiveis_para` + `filtrar_contatos`, e o seletor de imóvel do filtro mostra só os imóveis
  que aparecem nos contatos que o usuário pode ver.

## Lacunas na web (levantamento de 2026-11-22)

1. **Quantos estão sem retorno (critério 6):** nenhuma rota devolve a contagem de contatos com
   `retorno = PENDENTE`. Precisa vir calculada do Django (com lista paginada, o app não teria como
   contar sozinho, e a regra do projeto é não calcular no aparelho).
2. **Paginação:** a lista não é paginada; para o celular, avaliar `PageNumberPagination` como na
   APP-05/APP-08.
3. **Opções do filtro por imóvel:** não há rota com os imóveis que têm contato do usuário (o site
   monta essa lista no `ContatoListView`); o app precisa dela para o seletor do filtro.

## Decisões do Allysson (2026-11-22, antes do discuss-phase — não perguntar de novo)

- **D-A · Rota de planejamento:** fluxo completo, como na APP-08 (`/gsd-discuss-phase 10` →
  pesquisa → padrões → planejador → verificador).
- **D-B · Branches:** `feat/APP10` criada da `main` atualizada no app (já criada) e no repo web
  quando a fase precisar mexer no Django; commits locais do GSD liberados nas duas; push só com
  autorização explícita.
- **D-C · Número da fase:** Phase 10 (fase N = card APP 0N); a Phase 9 fica reservada ao card APP 09,
  de outro colega.
