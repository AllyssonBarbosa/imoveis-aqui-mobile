# Phase 12: Área do Gestor — Acompanhamento dos Corretores (APP 12) - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-25
**Phase:** 12-area-do-gestor-acompanhamento-dos-corretores
**Areas discussed:** nenhuma interativamente. O Allysson escolheu o caminho curto antes do discuss
(D-A no `12-CARD-APP12.md`: "discuss sem perguntas, decidir pelo card, pelo padrão do site/W12 e pelas
decisões das fases anteriores; mostrar as decisões no fim").

---

## Áreas avaliadas (decididas pelo card, sem perguntas)

| Área | Alternativas consideradas | Decidido | Por quê |
|------|---------------------------|----------|---------|
| Estrutura da tela | Uma tela com 4 seções · abas · 4 telas | Uma tela, 4 seções (D-05) | Card: "a tela responde quatro perguntas" |
| Ordem das seções | Ordem dos critérios (1→4) · totais no topo e mudanças no fim | Totais, acervo, contatos, mudanças (D-06) | Totais é o resumo curto; mudanças é a única lista que cresce |
| Acervo por corretor | Ampliar `relatorios/acervo/` · rota nova · uma rota única para a tela toda | Rota nova no padrão W12 (D-11) | Aditivo, não muda rota que o site/app já usam |
| O que conta no acervo | Só disponíveis · só publicados · tudo da empresa | Tudo da empresa (D-12) | Mesma base do relatório de acervo; a soma fecha com o total |
| Quem aparece | Só quem tem imóvel · todo corretor ativo | Corretor ativo com zero + desativado com imóvel (D-13) | Mesma regra de `contatos_por_corretor`; "acervo parado" do card |
| Janela das mudanças | 7 dias · 30 dias (padrão de parcelas) · seletor no app | 7 dias, padrão no servidor, `?dias=` opcional (D-19) | "Últimos dias" do card; sem número fixo no app |
| Paginação das mudanças | `PageNumberPagination` · lista inteira | Lista inteira (D-20) | Padrão dos relatórios da W12; a janela limita |
| Período dos contatos | Padrão "últimos 30 dias" · todo o período | Todo o período, chip "Período" da APP-10 (D-16) | Igual ao site e ao servidor |
| Pendentes nos contatos | Só total · total + aguardando retorno | Os dois (D-17) | As duas colunas do relatório do site |
| Administrador | Mesma área do gestor · tela de aviso | Tela de aviso com texto do administrador (D-02) | `EhGestor` barra o administrador (sem empresa) |
| Falhas | Erro da tela inteira · erro por seção | Por seção, 401 = sessão terminada, 403 com texto próprio (D-07, D-22, D-23) | Padrão F10/D-22 e F8 |

**User's choice:** caminho curto, sem perguntas (D-A).
**Notes:** Seguindo a memória de feedback: nos discuss-phase, decidir pelo card e mostrar as
decisões no fim para o Allysson corrigir.

## Claude's Discretion

- Nomes de classes, arquivos, rotas e chaves das respostas novas.
- Um Cubit por seção ou um Cubit com quatro sub-estados.
- Visual dos blocos de totais, ícones, `Card` por seção (confirmado no human-check).
- Como montar os dados do UAT (empresa do `seed_demo` ou gestor criado na empresa da vitrine).

## Deferred Ideas

- Quebra por situação do acervo de cada corretor; tocar no corretor ou na mudança; escolher a janela
  de dias no app; filtro por imóvel nos contatos; parcelas, caixa da empresa e mudar situação pelo
  gestor; páginas novas no painel do site; rótulo neutro no botão do topo; puxar para atualizar.
