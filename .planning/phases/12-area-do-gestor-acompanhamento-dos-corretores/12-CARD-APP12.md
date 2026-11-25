# Card APP 12 · Área do gestor: acompanhamento dos corretores (tarefa A12)

Fonte: texto oficial do card, enviado pelo Allysson em 2026-11-25. Usado como PRD da Phase 12.

## História (texto do card, sem alteração)

Como gestor da imobiliária, eu quero acompanhar pelo celular o que a minha equipe está fazendo para
saber quem está com acervo parado e quem está recebendo contato.
A tela responde quatro perguntas: quantos imóveis cada corretor tem, quantos contatos cada um
recebeu, o que mudou de situação nos últimos dias e quanto a empresa tem em cada situação —
disponível, reservado, vendido e alugado.

Dependência: [WEB] 08 · Documentos, publicação, situação e histórico — feito.

## Critérios de aceite (texto do card, sem alteração)

1. Acervo por corretor, com o total de cada um
2. Contatos recebidos por corretor e por período
3. Lista dos imóveis que mudaram de situação nos últimos dias, com quem mudou
4. Totais da empresa por situação
5. Todos os números vêm da API, calculados no servidor
6. Só o gestor enxerga esta área; o corretor não

## O que a API já entrega (repo da web, `origin/main` em e2d1fa0, 2026-11-25)

Repo da web: `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` (NÃO é `../imoveis-aqui/Web`).
O app já tem login, sessão e `Dio` autenticado desde a APP-08 (Phase 8); `GET /api/auth/eu/` devolve o
perfil, e hoje o gestor e o administrador caem na `AvisoAreaScreen` ("A área do gestor ainda não está no
app", `lib/presentation/sessao/aviso_area_screen.dart`, roteada em `entrada_area_screen.dart` e
`login_screen.dart`).

- **Relatórios do gestor (W12, `Web/relatorios/`):** a API e o painel do site só chamam
  `relatorios/servicos.py` ("nada é gravado: os números saem das tabelas na hora da consulta").
  Permissão `EhGestor` (`core/permissions.py`): **só o perfil gestor** — corretor e administrador ficam
  de fora — critério 6 já garantido no servidor para estas rotas.
  - `GET /api/relatorios/acervo/` (`AcervoApiView` → `acervo_por_natureza_e_situacao`): tabela natureza ×
    situação com zeros, `totais` por situação (`DISPONIVEL`, `RESERVADO`, `VENDIDO`, `ALUGADO`) e `total`
    — **critério 4** (totais da empresa por situação). Não agrupa por corretor.
  - `GET /api/relatorios/contatos/?de=AAAA-MM-DD&ate=AAAA-MM-DD[&imovel=<id>]` (`ContatosApiView` →
    `contatos_por_corretor`): por corretor, `total` e `pendentes`; corretor ativo sem contato aparece com
    zero; contato que foi para a empresa (corretor desativado no clique) vem numa linha à parte; ordem de
    quem recebeu mais; datas inclusivas no dia de São Paulo (mesmo `filtrar_contatos` da caixa da APP-10);
    filtro inválido → 400 — **critério 2**.
  - `GET /api/relatorios/parcelas/?dias=` — fora do card.
- **Histórico de situação (WEB 08, `Web/imoveis/`):** modelo `HistoricoSituacao` (`imovel`,
  `situacao_anterior`, `situacao_nova`, `alterado_por`, `alterado_em`, `observacao`; ordem
  `-alterado_em, -id`). Rotas **só por imóvel**: `GET /api/imoveis/<id>/historico/` (corretor, APP-09) e
  `GET /api/gestao/imoveis/<id>/historico/` (`GestaoImovelViewSet`, `EhGestor`).
- **Painel do site:** `painel/relatorios/` (acervo, contatos, parcelas) com `GestorRequiredMixin`; não há
  página de "mudanças recentes" nem de "acervo por corretor".

## Lacunas na web (levantamento de 2026-11-25)

1. **Acervo por corretor (critério 1):** nenhuma rota conta os imóveis por `corretor_responsavel`.
   Precisa vir calculado do Django (regra do projeto: nada é contado no aparelho), no padrão dos
   relatórios da W12 (`relatorios/servicos.py` + `EhGestor`).
2. **Mudanças de situação recentes (critério 3):** não há lista da empresa inteira; só o histórico de um
   imóvel por vez. Falta uma rota com as mudanças dos últimos dias (imóvel, de → para, quem mudou,
   quando), recortada pela empresa do gestor.

## Decisões do Allysson (2026-11-25, antes do discuss-phase — não perguntar de novo)

- **D-A · Rota de planejamento:** caminho curto — `/gsd-discuss-phase 12` sem perguntas (decidir pelo
  card, pelo padrão do site/W12 e pelas decisões das fases anteriores; mostrar as decisões no fim) →
  planejador → verificador de planos com 1 rodada. Sem pesquisa e sem mapa de padrões (os padrões vêm da
  APP-10 e da W12).
- **D-B · Branches:** `feat/APP12` no app criada de `feat/APP10` (= `main` 2d71953 + os 2 commits de
  documentação da APP-10, que entram na `main` junto com o PR da APP-12); no repo web, `feat/APP12` nasce
  da `main` (e2d1fa0) no primeiro plano que mexer no Django. Commits locais do GSD liberados nas duas;
  push só com autorização explícita.
- **D-C · Número da fase:** Phase 12 (fase N = card APP N); a Phase 11 fica reservada ao card APP 11,
  de outro colega.
