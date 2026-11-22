# Fase 08 — Revisão de UI (Login e Área do Corretor / Acervo)

**Auditada em:** 2026-11-21
**Baseline:** padrões abstratos dos 6 pilares + restrições do CLAUDE.md (Material 3 estrito, `ColorScheme.fromSeed` verde e branco, widgets de `material.dart`, tipografia só de `Theme.of(context).textTheme`, sem regra de negócio no widget, textos em pt-BR). Não há UI-SPEC.md para esta fase; as decisões D-01..D-11 do 08-CONTEXT.md serviram de contrato de UI.
**Screenshots:** não capturadas (app Flutter mobile, sem servidor de desenvolvimento web; auditoria somente de código).
**Interaction captures:** off (`interaction_capture: false`; app mobile, não web).

**Escopo auditado:** `lib/presentation/acervo/` (incl. `widgets/`), `lib/presentation/login/`, `lib/presentation/sessao/`, slot `acaoSessao` em `vitrine_screen.dart`, `cidade_selecao_screen.dart`, `priming_screen.dart`, e `lib/main.dart`, `lib/app_theme.dart`.

**Limitação importante:** os SUMMARYs 08-09, 08-10 e 08-11 registram que nenhuma aparência foi verificada em aparelho (itens `human_judgment: true` D5/D7/D5). Esta revisão confirma o que o código faz, não como a tela renderiza. Os riscos visuais abaixo são inferências de layout e precisam de confirmação no aparelho.

---

## Pillar Scores

| Pilar | Nota | Achado principal |
|-------|------|------------------|
| 1. Copywriting | 3/4 | Textos pt-BR com acentos e fiéis ao D-03/D-04/D-08; faltam ações nos estados vazios e o erro de login não é anunciado |
| 2. Visuals | 3/4 | Hierarquia clara (busca, chips, cartão em linha); chips horizontais sem indicação de rolagem; estado vazio sem ícone |
| 3. Color | 3/4 | Só `ColorScheme`, sem `Colors.` literal; mas todas as situações usam a mesma cor de marca (`secondaryContainer`) |
| 4. Typography | 3/4 | Só `textTheme`, poucos tamanhos; o preço, dado mais importante ao comprador, não se destaca do código e da marca |
| 5. Spacing | 3/4 | Valores literais sempre múltiplos de 4 (4, 8, 12, 16, 24, 48, 96); desalinhamento de gutter entre busca e cartões |
| 6. Experience Design | 3/4 | Estados completos (carregando, vazio, sem resultado, erro, sessão terminada), debounce, botão desabilitado em envio, confirmação de Sair; sem pull-to-refresh e risco no topo em 360 dp não verificado |

**Overall: 18/24**

---

## Top 3 Priority Fixes

1. **Chips de situação podem cortar "Alugado" sem indicar que a linha rola** — em 360 dp, cinco `ChoiceChip` com `SizedBox(width: 8)` somam cerca de 420 dp, então a última opção fica fora da tela sem pista visual. O usuário pode não descobrir o filtro "Alugado" — **Impacto:** o filtro de situação (D-09) fica parcialmente oculto em telas estreitas. **Correção:** trocar o `SingleChildScrollView` por `Wrap(spacing: 8, runSpacing: 4)` em `lib/presentation/acervo/widgets/chips_situacao.dart`, ou manter a rolagem com `ScrollbarTheme`/gradiente de borda; validar em 360 dp.

2. **Todas as situações têm a mesma cor de marca no cartão** — `CartaoImovelAcervo` usa `secondaryContainer` para qualquer situação (Disponível, Reservado, Vendido, Alugado) e `primaryContainer` para "Seu". A situação só se distingue pelo texto, e a marca "Seu" se confunde com as situações. **Impacto:** o corretor escaneia a lista pela cor e não consegue ler o estado do imóvel rapidamente. **Correção:** mapear a cor por situação dentro de `_LinhaDoCartao` usando só `ColorScheme` (por exemplo `primaryContainer` para Disponível, `tertiaryContainer` para Reservado, `errorContainer` para Vendido, `surfaceContainerHighest` para Alugado), mantendo "Seu" com cor própria distinta.

3. **Preço sem destaque e topo do app não verificado em 360 dp** — em `cartao_imovel_acervo.dart` o preço usa `textTheme.bodyMedium`, igual à linha de código e às marcas, então o valor não ganha peso. Em paralelo, `vitrine_screen.dart` põe `SeletorCidadeTopo` em `Expanded` ao lado do `BotaoSessaoTopo` (`TextButton.icon` com ícone e rótulo "Meu acervo"); a largura de sobra pode truncar o nome da cidade, o que o próprio 08-11 deixou pendente. **Impacto:** o dado de maior valor perde hierarquia e o cabeçalho da vitrine pode ficar apertado. **Correção:** preço em `textTheme.titleSmall` (ou `bodyLarge` com `FontWeight` do próprio tema, sem literal); no topo, verificar o `SeletorCidadeTopo` com `maxLines: 1` e `TextOverflow.ellipsis` em 360 dp, e considerar `IconButton` com `tooltip` no lugar do `TextButton.icon` quando a largura for pequena.

---

## Detailed Findings

### Pillar 1: Copywriting (3/4)

**Pontos fortes (verificados no código):**
- `apresentacao_acervo.dart`: "Buscar por código ou título", "Nenhum imóvel no acervo ainda.", "Nenhum imóvel encontrado para esta busca ou situação.", "Não foi possível carregar o acervo.", "Sua sessão terminou. Entre de novo.", "Todas/Disponível/Reservado/Vendido/Alugado", "Seu". Todos batem com o 08-CONTEXT.md e com os acentos corretos.
- `apresentacao_login.dart`: "E-mail ou senha inválidos.", "Não foi possível entrar agora. Tente de novo.", e a regra singular/plural de "Muitas tentativas. Tente de novo em N minutos." (pluralização correta, mínimo 1).
- `dialogo_sair.dart`: "Sair da conta?" com "Cancelar" e "Sair"; `aviso_area_screen.dart`: "A área do gestor ainda não está no app.".
- Nenhuma string do servidor é exibida (T-08-37), conferido pela estrutura de `mensagemDeFalhaDoLogin`.

**Achados:**
- **WARNING — estado vazio sem próxima ação** (`acervo_screen.dart`, `_MensagemDoAcervo` para `AcervoVazio`): "Nenhum imóvel no acervo ainda." não orienta o corretor. Sugestão: complementar com uma frase de próximo passo, por exemplo "Os imóveis cadastrados pela sua imobiliária aparecem aqui."
- **WARNING — erro de login sem anúncio para leitor de tela** (`login_screen.dart`, `Text(mensagem)` com `colorScheme.error`): a falha surge só visualmente. Sugestão: envolver em `Semantics(liveRegion: true, child: ...)`.
- **INFO — rótulos duplicados**: o título da `LoginScreen` e o botão do topo são ambos "Entrar"; é coerente com o site, sem ação necessária.

### Pillar 2: Visuals (3/4)

**Pontos fortes:**
- A hierarquia da `AcervoScreen` é clara: busca no topo, chips, lista. O foco principal é a lista.
- O cartão em linha (`CartaoImovelAcervo`) segue D-05: miniatura 96x96 com `ClipRRect`, código, título com `maxLines: 2` e reticências, preço e marcas.
- Ícone "Sair" na `AppBar` tem `tooltip: 'Sair'` (acessível). O "Limpar busca" também tem tooltip.

**Achados:**
- **BLOCKER? não — WARNING — chips sem pista de rolagem** (`chips_situacao.dart`): ver Top 3 #1.
- **WARNING — estado vazio e de erro sem elemento visual** (`_MensagemDoAcervo`): só texto centralizado com `bodyLarge`. Não há ícone, então os estados têm peso visual igual ao de uma lista carregando. Sugestão: ícone 48 dp em `colorScheme.primary`, como faz `AvisoAreaScreen`, para manter o padrão.
- **WARNING — cartão sem toque não tem indicação** (`cartao_imovel_acervo.dart`, linha `(imovel.naVitrine && aoTocarNaVitrine != null)`): o cartão sem `naVitrine` parece igual ao que abre o detalhe, sem chevron nem sinal visual. D-07 proíbe o toque, mas a diferença não aparece. Confirmar com o time se é intencional; se não, considerar um ícone discreto de "não publicado" fora de escopo, ou aceitar como decisão.
- **INFO — sem imagem de fallback distinta**: `ImagemRede` cobre o placeholder (confirmado pelo 08-09), mas a aparência do placeholder não foi verificada.

### Pillar 3: Color (3/4)

**Pontos fortes:**
- `app_theme.dart`: `ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32), brightness: Brightness.light)` com `useMaterial3: true`. Verde e branco conforme CLAUDE.md.
- Grep confirma **zero** `Colors.` literal, `Color(0x` e `#hex` nos diretórios `acervo/`, `login/`, `sessao/` e `main.dart`. Todas as cores vêm de `colorScheme`.
- Erro de login usa `colorScheme.error`; aviso de sessão usa `secondaryContainer`/`onSecondaryContainer`.

**Achados:**
- **WARNING — situações sem diferenciação de cor** (`cartao_imovel_acervo.dart`, `_LinhaDoCartao`): `situacao != null` sempre aplica `secondaryContainer`, independentemente de qual situação seja. Ver Top 3 #2.
- **WARNING — "Seu" e situação usam o mesmo par de tons** em termos de peso visual: `primaryContainer` (Seu) e `secondaryContainer` (situação) são tons próximos do verde derivado. A marca do próprio corretor se mistura com as situações.
- **INFO — distribuição 60/30/10 não verificada**: o uso de acento (`primary`) no acervo se resume a ícones do `FilledButton` e do `ChoiceChip` selecionado. Sem captura de tela não há como medir a proporção; o aviso do gestor usa `primary` no ícone. Confirmar no aparelho.
- **INFO — tema sem override de fundo branco**: o `Scaffold` usa a superfície padrão M3 derivada da semente, que não é branca pura. Aceitável, mas não é um "branco" explícito da marca.

### Pillar 4: Typography (3/4)

**Pontos fortes:**
- Toda tipografia vem de `Theme.of(context).textTheme` (grep confirma zero `fontSize`, `FontWeight`, `TextStyle(`). Esta é a restrição do CLAUDE.md, cumprida.
- Escala usada no acervo: `labelMedium` (código e marcas), `titleMedium` (título), `bodyMedium` (preço e aviso), `bodyLarge` (mensagens de estado), `titleMedium` (aviso do gestor). Quatro níveis, consistentes.

**Achados:**
- **WARNING — preço sem peso** (`cartao_imovel_acervo.dart`): `linhasDePrecoPorFinalidade` é renderizado com `textTheme.bodyMedium`, a mesma escala do texto corrido. O preço é o dado de decisão do comprador e fica abaixo do título em hierarquia. Ver Top 3 #3.
- **INFO — `labelMedium` para o código** com `onSurfaceVariant`: 12 sp, adequado para referência; em 360 dp pode ser pequeno para leitura em sol, mas está dentro do padrão M3.

### Pillar 5: Spacing (3/4)

**Pontos fortes:**
- Todos os valores literais são múltiplos de 4: `EdgeInsets` de 12, 16, 24; `SizedBox` de 4, 8, 12, 16, 20, 24, 48; miniatura 96. Consistente com o grid de 4 dp.
- `login_screen.dart` usa `ConstrainedBox(maxWidth: 480)` e `SingleChildScrollView`, bom para tablets e para o teclado aberto.

**Achados:**
- **WARNING — gutter desalinhado**: a `SearchBar` e os chips ficam com `horizontal: 16` (`acervo_screen.dart`), mas cada `Card` adiciona a margem padrão M3 de 4 dp e padding interno de 12. A borda do cartão fica em 20 dp, e a busca em 16 dp. Sugestão: `Card(margin: EdgeInsets.zero)` dentro do `ListView` com `padding: EdgeInsets.symmetric(horizontal: 0)` ou zerar o padding externo para alinhar.
- **WARNING — lista sem respiro inferior e sem `SafeArea`**: `ListView.builder` não define `padding`, então o último cartão e o `RodapePaginacaoLista` encostam na borda inferior, inclusive com barra de gestos do Android/iOS. Sugestão: `padding: EdgeInsets.only(bottom: 16)`.
- **INFO — cartões sem espaçamento vertical explícito**: dependem da margem padrão de 4 dp do `Card`, o que dá 8 dp entre dois cartões. Adequado, mas não é um valor declarado no tema.

### Pillar 6: Experience Design (3/4)

**Pontos fortes (verificados):**
- **Estados explícitos e distintos** em `ConteudoAcervo` (carregando, vazio, semResultado, erro, sessaoExpirada, carregada) com `switch` exaustivo em `acervo_screen.dart`.
- **Busca com atraso de 400 ms e descarte de respostas obsoletas** (08-09), e limpar busca volta na hora (D-08).
- **Rodapé de paginação** com "Tentar de novo" para `erroAoCarregarMais`, e carregamento a 90% da rolagem.
- **Login**: `AutofillGroup`, `AutofillHints.email`/`password`, `obscureText` com `Mostrar senha`/`Ocultar senha`, `enableSuggestions: false`, `autocorrect: false`. Botão `onPressed: null` em `enviando` com `CircularProgressIndicator` (D-01).
- **Sair com confirmação** (`confirmarESair`) na `AppBar` do acervo e na `AvisoAreaScreen`, com "Cancelar" (sem ação destrutiva acidental).
- **401 do acervo** → `marcarAnonima()` + `pushAndRemoveUntil(... isFirst)` (T-08-54), e "Meu acervo" pergunta o papel ao servidor (`EntradaAreaScreen`).
- **Abertura sem espera** (`main.dart`: `unawaited(_sessao.carregar())`, AC-6). `BotaoSessaoTopo` ocupa `SizedBox(height: 48)` enquanto verifica, sem piscar "Entrar".

**Achados:**
- **WARNING — sem pull-to-refresh na lista do acervo** (`acervo_screen.dart`): o corretor não tem como reatualizar a lista depois de um imóvel mudar de situação em outro aparelho, a não ser voltando e reabrindo a tela. Sugestão: `RefreshIndicator` em volta do `ListView` chamando `carregar()`.
- **WARNING — topo da vitrine em 360 dp não verificado** (`vitrine_screen.dart`, linha `if (widget.acaoSessao case final acao?) Row(...)`): o 08-11 deixou isso como `human_judgment`. Pode truncar o seletor de cidade. Ver Top 3 #3.
- **WARNING — senha permanece preenchida após falha** (`login_screen.dart`): o `LoginFalha` mostra a mensagem, mas o campo de senha não é limpo nem focado. Em teclado móvel, o corretor precisa apagar e redigitar. Sugestão: após `LoginFalha` com `CredenciaisInvalidas`, focar o campo de senha e selecionar o texto.
- **WARNING — falha de login não anunciada** (ver Pillar 1): o erro só aparece visualmente.
- **INFO — "Sair" limpa o token mas não a lista em cache**: fora do escopo visual; registrado por consistência com o 08-10 (T-08-54 cobre a pilha, não o cache de imagem).
- **INFO — registro de análise pré-existente**: os SUMMARYs registram 38 `info` `deprecated_member_use` de `material.dart` no baseline do repositório, dos quais 2 a 3 são dos arquivos novos. Não é achado de UI desta fase; não foi pontuado.

---

## Files Audited

- `lib/presentation/acervo/acervo_screen.dart`
- `lib/presentation/acervo/acervo_state.dart`
- `lib/presentation/acervo/apresentacao_acervo.dart`
- `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart`
- `lib/presentation/acervo/widgets/chips_situacao.dart`
- `lib/presentation/login/login_screen.dart`
- `lib/presentation/login/apresentacao_login.dart`
- `lib/presentation/sessao/botao_sessao_topo.dart`
- `lib/presentation/sessao/aviso_area_screen.dart`
- `lib/presentation/sessao/dialogo_sair.dart`
- `lib/presentation/sessao/entrada_area_screen.dart`
- `lib/presentation/vitrine/vitrine_screen.dart` (slot `acaoSessao`, linhas ~35-43 e ~151-154)
- `lib/main.dart` (`ImoveisAquiApp`, `_TelaInicial`)
- `lib/app_theme.dart`
- Resumos: `08-09-SUMMARY.md`, `08-10-SUMMARY.md`, `08-11-SUMMARY.md`; planos `08-09-PLAN.md`, `08-10-PLAN.md`, `08-11-PLAN.md`; `08-CONTEXT.md`

**Não auditados nesta revisão:** `seletor_cidade_topo.dart` (apenas para checar overflow; não lido em detalhe), `imagem_rede.dart`, `rodape_paginacao_lista.dart`, `apresentacao_imovel.dart` (formatação de preço). Recomendado para a próxima rodada.
