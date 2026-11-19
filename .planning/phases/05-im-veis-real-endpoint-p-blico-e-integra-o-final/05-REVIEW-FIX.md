---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
fixed_at: 2026-11-16T00:00:00Z
review_path: .planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-REVIEW.md
iteration: 1
findings_in_scope: 3
fixed: 3
skipped: 0
status: all_fixed
---

# Fase 5: Relatório de Correção do Code Review

**Corrigido em:** 2026-11-16
**Revisão de origem:** `.planning/phases/05-im-veis-real-endpoint-p-blico-e-integra-o-final/05-REVIEW.md`
**Iteração:** 1

**Resumo:**
- Achados no escopo: 3 (WR-07, WR-08, WR-09, por decisão do usuário)
- Corrigidos: 3
- Ignorados: 3 outros avisos e todos os informativos, adiados pelo usuário (WR-03..WR-06, IN-*), não tocados

**Política de commit:** por decisão do usuário, **nenhum commit foi feito** em nenhum dos repositórios. Todas as correções estão sem commit na árvore de trabalho da API (`feat/APP05`, HEAD continua em `0592176`), por cima do trabalho da fase que já estava sem commit. Nada foi revertido, guardado em stash ou enviado. Por isso não há hash de commit abaixo. Não foi usado worktree, porque a árvore principal guarda o trabalho sem commit da fase.

**Onde a verificação rodou:** no checkout principal da API (`/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui/Web`), com `DATABASE_URL="sqlite://:memory:"` e o `.venv` do projeto. Sem servidor e sem tocar no banco de desenvolvimento. O `Web/.env` não foi lido.

**Verificação:**
- `manage.py test`: **359 testes OK**. A linha de base era 353 e foram somados 6 testes novos: 1 de WR-07, 4 de WR-08 e 1 de WR-09.
- `makemigrations --check --dry-run`: sem mudanças.
- Determinismo (WR-09): as classes `VitrineBuscaTests`, `VitrineLimiteDeTaxaTests`, `VitrinePublicaTests` e `empresas` (62 testes) passam com `VITRINE_TAXA_ANONIMA=3/min` no ambiente.
- WR-08: `DEBUG=False manage.py check --deploy` mostra `core.W001`. Com `NUM_PROXIES=1` o aviso some.
- Taxa inválida: `VITRINE_TAXA_ANONIMA="120 por minuto"` falha na partida com `ImproperlyConfigured`.

## Corrigidos

### WR-07: `int(item)` sem proteção em `_ids_de_caracteristicas` (id com dígitos demais)

**Arquivos alterados:** `Web/imoveis/api/views.py`, `Web/imoveis/tests.py`
**Commit:** nenhum (política do usuário)
**Status:** corrigido. É erro de lógica, então vale conferir a regra na revisão humana.
**Correção aplicada:**
- `_FORMATO_ID` passou a `[0-9]{1,18}`, que cabe no bigint da chave primária. Ids com dígitos demais, inclusive `0` * 5000, dão 400 com a mensagem existente "Informe os ids separados por vírgula." antes de qualquer `int()` ou consulta.
- A conversão acontece uma vez só (`numero = int(item)`), seguida da checagem `<= 0`.
- Testes: `test_id_de_caracteristica_fora_do_formato_da_400` ganhou `"0"*5000`, `"9"*5000`, `"9"*30`, `"0"*19` e `"<id>,<9*30>"`. O novo `test_id_de_caracteristica_comum_continua_funcionando` cobre um id comum, com zeros à esquerda e com espaços. Também cobre `"9"*18`, que é o maior aceito e devolve 200 com lista vazia.

### WR-08: `NUM_PROXIES` com padrão 0 em produção atrás de proxy

**Arquivos alterados:** `Web/config/settings.py`, `Web/core/checks.py` (novo), `Web/core/apps.py`, `Web/core/tests.py`, `Web/.env.example`, `README.md` (do repositório da API)
**Commit:** nenhum (política do usuário)
**Status:** corrigido, com uma escolha de desenho que difere da sugestão principal do review (ver abaixo).
**Correção aplicada:**
- O review sugeria falhar na partida (`env.int('NUM_PROXIES')` sem padrão fora do DEBUG). Isso foi descartado. `DEBUG` tem padrão `False` em `settings.py` e o runner de testes força `DEBUG=False`, então um erro na partida derrubaria `manage.py test` com a sqlite e sem `.env`. Foi adotada a alternativa que o próprio review aceita ("no mínimo, um check do Django").
- `settings.py` ganhou `NUM_PROXIES` e `NUM_PROXIES_CONFIGURADO`, que diz se a variável foi informada. O padrão continua 0, então o desenvolvimento e a suíte não exigem variável nova.
- A verificação `core.W001` (`core/checks.py`) é registrada com `Tags.security, deploy=True`. Ela só roda em `manage.py check --deploy`, nunca na partida nem na suíte. Avisa quando `DEBUG=False` e `NUM_PROXIES` não foi informado. Informar a variável, mesmo `0`, cala o aviso. Quem expõe a API direto, sem proxy, não recebe alarme falso depois de decidir.
- `.env.example`: a linha `NUM_PROXIES=0` virou `# NUM_PROXIES=1` comentada, com explicação. Antes, quem copiasse o arquivo ficava com `0` "informado" sem ter decidido.
- Também foi validado `VITRINE_TAXA_ANONIMA` na partida (`<número>/<período>`), como a observação final do review pedia. Formato inválido levanta `ImproperlyConfigured` em vez de dar 500 em todas as rotas públicas no primeiro uso.
- README (seção do `.env` e bullet "Limite de taxa"): documentam o aviso `core.W001`, a validação da taxa e o `check --deploy` no checklist de deploy.
- Testes (`core/tests.py`, `VerificarNumProxiesTests`, 4 testes): avisa em produção sem variável, não avisa com a variável informada, não avisa em DEBUG, e roda só no `check --deploy`.
- Limite conhecido: o aviso não impede subir em produção sem a variável. Se o usuário preferir parar a aplicação na partida, é preciso uma regra explícita (por exemplo, uma variável de ambiente que marque produção), porque `DEBUG` sozinho não distingue produção de teste.

### WR-09: a suíte da API depende de `VITRINE_TAXA_ANONIMA`

**Arquivos alterados:** `Web/imoveis/tests.py`, `Web/empresas/tests.py`
**Commit:** nenhum (política do usuário)
**Status:** corrigido
**Correção aplicada:**
- Em `imoveis/tests.py` há o helper `fixar_taxa_alta(teste)` e a constante `TAXA_ALTA_NOS_TESTES = "100000/min"`. O helper pina a taxa em `ThrottleVitrinePublica.rate` com `mock.patch.object` e restaura no cleanup. Ele é chamado no `setUp` de `VitrineBase` e de `VitrinePublicaTests`.
- Em `empresas/tests.py`, o `setUp` de `SemearVitrineDevTests` faz o mesmo patch (4 linhas, sem importar um módulo de teste de outro app).
- Os testes de limite (`VitrineLimiteDeTaxaTests`) continuam com o `mock.patch.object` explícito de `3/min`, `4/min` e `2/min`. O patch aninhado sobrepõe o da base e volta a ele ao sair, então o 429 segue provado com taxa própria.
- `test_taxa_padrao_vem_do_settings` agora compara `ThrottleVitrinePublica().get_rate()` (que lê o settings e ignora o patch) com o valor do settings. Há também `test_taxa_fixa_da_suite_nao_depende_do_ambiente`.
- Os testes das rotas `corretores/<id>/` e `empresas/<id>/` (em `contas`) não usam o throttle e não precisaram de mudança.

## Ignorados

Nenhum dos achados no escopo foi ignorado. WR-03..WR-06 e IN-10..IN-14, além dos IN-01..IN-09 carregados, ficam adiados por decisão do usuário e não foram tocados.

---

_Corrigido em: 2026-11-16_
_Corretor: Claude (gsd-code-fixer)_
_Iteração: 1_
