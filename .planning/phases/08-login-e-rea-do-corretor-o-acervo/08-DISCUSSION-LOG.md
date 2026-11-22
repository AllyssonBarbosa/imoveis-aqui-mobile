# Phase 8: Login e Área do Corretor — o Acervo - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-20
**Phase:** 08-login-e-rea-do-corretor-o-acervo
**Areas discussed:** Tela de login, Cartão e toque, Busca e situação
**Not selected:** Sessão e Sair (ficou como Claude's Discretion no CONTEXT.md)
**Already locked before discussion:** D-A..D-E em `08-CARD-APP08.md`

---

## Tela de login

### Para onde o app vai depois de entrar

| Option | Description | Selected |
|--------|-------------|----------|
| Direto ao acervo | Abre "Meu acervo" na hora; voltar leva à vitrine; gestor/admin vão ao aviso (D-B) | ✓ |
| Volta à vitrine | Fecha o login e volta à vitrine com o botão trocado para "Meu acervo" | |

### Texto do erro de credencial (400)

| Option | Description | Selected |
|--------|-------------|----------|
| Texto fixo do app | "E-mail ou senha inválidos." (palavras do site); rede/5xx = "Não foi possível entrar agora. Tente de novo." | ✓ |
| Mensagem do servidor | Exibe o texto que a API devolve no 400 | |

### Texto do limite de tentativas (429)

| Option | Description | Selected |
|--------|-------------|----------|
| Texto com o tempo | "Tente de novo em N minutos", N do `Retry-After`; sem cabeçalho, "em alguns minutos" | ✓ |
| Texto genérico | "Tente de novo mais tarde", sem ler o cabeçalho | |

### Forma do formulário

| Option | Description | Selected |
|--------|-------------|----------|
| E-mail + senha com olho | Tela própria (push), teclado de e-mail, mostrar/ocultar senha, FilledButton com carregando; só campo vazio barrado no app | ✓ |
| Bottom sheet | Login numa folha inferior sobre a vitrine | |

**User's choice:** as quatro recomendadas.

---

## Cartão e toque

### Formato do cartão

| Option | Description | Selected |
|--------|-------------|----------|
| Compacto em linha | Miniatura quadrada à esquerda; código + título, preço e marcas à direita; 5–6 por tela | ✓ |
| ImovelCard da vitrine | Cartão grande da vitrine (foto 16:9) com marcas acrescentadas; ~2 por tela | |

### Marcas do cartão (multiSelect)

| Option | Description | Selected |
|--------|-------------|----------|
| Situação | Chip Disponível/Reservado/Vendido/Alugado | (interpretado ✓) |
| Código | Código interno, procurado pela busca do site | (interpretado ✓) |
| Publicado ou não | Marca "Não publicado" | |
| Seu | Marca quando o corretor logado é o responsável, calculada no Django | (interpretado ✓) |

**User's choice (texto livre):** "FAÇA TUDO DE ACORDO COM OS DETALHES DA FAZE QUE TE MANDEI"
**Notes:** Interpretado como "nada além do card": situação (filtro do card), código (busca do site
por código ou título) e "Seu" (o card separa os do corretor e os da imobiliária). "Não publicado"
ficou de fora. A interpretação foi dita ao Allysson antes da pergunta seguinte, e ele confirmou a
próxima rodada sem objeção.

### Toque no imóvel do acervo

| Option | Description | Selected |
|--------|-------------|----------|
| Abre se estiver na vitrine | Booleano do servidor pela regra da vitrine pública; verdadeiro abre a página existente, falso deixa o cartão inerte | ✓ |
| Sem toque nesta fase | A lista só mostra | |
| Detalhe do acervo (tela nova) | Tela só leitura com `GET /api/imoveis/<id>/`; amplia a fase | |

---

## Busca e situação

Uma única confirmação, já montada a partir do card e da regra do site (`FiltroImovelForm`):
`SearchBar` "Buscar por código ou título" resolvida no servidor com o atraso da vitrine; linha de
chips de escolha única (Todas, Disponível, Reservado, Vendido, Alugado); ordem do Django, sem botão
de ordenar.

| Option | Description | Selected |
|--------|-------------|----------|
| Seguir assim | Grava essa forma e fecha a discussão | ✓ |
| Quero ajustar | Descrever mudanças antes de escrever | |

---

## Claude's Discretion

- Sessão e Sair (não escolhida): validar a sessão ao tocar em "Meu acervo"; 401 apaga o token e
  volta ao login com aviso; token só nas rotas autenticadas; Sair com confirmação, revogação como
  melhor esforço e apagando o token local sempre. Registrar que o token único do DRF faz o Sair
  desconectar os outros aparelhos.
- Rota do acervo (adaptar `ImovelViewSet.list` ou criar rota própria), nome e campos do "quem sou
  eu", taxa do limite de tentativas, forma da rota de Sair, textos de vazio, estrutura de pastas,
  UI-SPEC opcional, configuração nativa do `flutter_secure_storage`.

## Deferred Ideas

- Detalhe do acervo (tela só leitura para qualquer imóvel do acervo).
- Marca "Não publicado" no cartão.
- Área do gestor/admin no app (APP-12).
- Token por aparelho, para o Sair não desconectar os outros aparelhos.
