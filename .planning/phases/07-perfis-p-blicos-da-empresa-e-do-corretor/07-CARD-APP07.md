# Card APP 07 · Perfis públicos da empresa e do corretor (tarefa A07)

Fonte: texto oficial do card, enviado pelo Allysson em 2026-11-08. Usado como PRD da Phase 7
(`/gsd-plan-phase 7 --prd`). As decisões abaixo do card foram tomadas seguindo o padrão das
fases 1–4 (o usuário pediu: "fazer de acordo com o que já vinha sendo feito, seguindo padrões
de cores e layout").

## História (texto do card, sem alteração)

Como visitante, eu quero ver quem está anunciando para saber com quem vou negociar.
A página da empresa traz logomarca, CRECI, apresentação, contato e as cidades onde atua. A do
corretor traz foto, CRECI, apresentação e contato. As duas trazem a vitrine dos imóveis daquele
anunciante.
Corretor desativado não abre: quem chegar pelo caminho antigo vê um aviso, não uma tela quebrada.

Dependência: [WEB] 02 · Corretores da empresa e perfil público — feito.

## Critérios de aceite (texto do card, sem alteração)

1. Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação
2. Página do corretor com foto, CRECI, apresentação e contato
3. As duas mostram a vitrine dos imóveis daquele anunciante
4. Os dados vêm da API dos perfis públicos
5. Perfil de corretor desativado mostra aviso, e não tela quebrada
6. Dá para chegar ao perfil a partir da página do imóvel

## O que a API já entrega (WEB 02, branch `main` do repo da web)

Repo da web: `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` (NÃO é
`../imoveis-aqui/Web`). Ambos públicos (`AllowAny`), sem paginação, URLs de imagem absolutas.

### `GET /api/publico/corretores/{id}/`
View `CorretorPublicoAPIView` (`contas/api/views.py`), queryset
`Usuario.objects.filter(perfil=CORRETOR, is_active=True)` → **404** para corretor desativado,
inexistente ou que não é corretor. Serializer `CorretorPublicoSerializer`:

```json
{
  "id": 7,
  "empresa_id": 3,
  "foto": "http://host/media/... | null",
  "nome": "Ana Souza",
  "email": "ana@imob.com",
  "creci": "12345-F",
  "telefone": "(19) 3333-4444",
  "whatsapp": "19999998888",
  "apresentacao": "texto livre"
}
```

Regra do servidor (`Usuario.dados_perfil_publico`): corretor autônomo herda da Empresa o que
não preencheu (creci, foto→logomarca, telefone, whatsapp, apresentacao→descricao). O app
mostra o que vier, sem completar nada.

### `GET /api/publico/empresas/{id}/`
View `EmpresaPublicaAPIView` (`empresas/api/views.py`), queryset `Empresa.objects.filter(ativa=True)`
→ **404** para empresa inativa ou inexistente. Serializer `EmpresaPublicaSerializer`:

```json
{
  "id": 3,
  "tipo": "IMOBILIARIA | AUTONOMO",
  "razao_social_ou_nome": "Imobiliária Exemplo",
  "creci": "J-1234",
  "telefone": "(19) 3333-0000",
  "whatsapp": "19988887777",
  "email": "contato@imob.com",
  "descricao": "texto livre",
  "logomarca": "http://host/media/... | null",
  "cidades_atuacao": [{"id": 1, "nome": "Campinas", "uf": "SP"}],
  "corretores_ativos": [ { "...mesmo formato do corretor público..." } ]
}
```

Campos de texto opcionais no Django são `blank=True` sem `null=True`: quando não preenchidos
chegam como **string vazia `""`**, não `null`.

### Lacunas conhecidas na web (não são deste app — registrar, não resolver aqui)
- **Não existe endpoint da vitrine do anunciante** (imóveis de uma empresa / de um corretor).
  O site público (WEB 10, branch `WEB-09`) monta isso dentro da view HTML, sem API.
- A API do corretor não confere se a empresa dele está ativa (o site confere com
  `empresa__ativa=True`). Correção é da WEB 02 (do Allysson), fora do app.
- O detalhe público da WEB 09 expõe o corretor como `corretor_responsavel` (perfil completo,
  `null` se desativado); o contrato do app (§11) usa `corretor: {id, nome, foto, slug}`.
  Conciliação é da Phase 5. Esta fase só depende do `id` do corretor.

## Decisões (padrão das fases 1–4)

### Dados e contrato
- **D-01:** Perfis do corretor e da empresa consomem os endpoints da WEB 02 exatamente como
  estão acima (sem pedir mudança no Django). Models freezed + json_serializable, entidades de
  domínio próprias (`PerfilCorretor`, `PerfilEmpresa`), parse defensivo: `""` e `null` viram
  `null` na camada de dados (campo vazio omite a linha, como F4/D-14); URLs de foto/logomarca
  passam por `urlHttpOuNula` (F4, V12/V13).
- **D-02:** A vitrine do anunciante ganha **adendo de contrato §12** em
  `01-CONTRATO-API.md`: o mesmo `GET /api/publico/imoveis/` da lista (mesmo envelope com
  cursor, mesmos campos do card, mesmo serializer público com allowlist) aceitando
  `empresa=<id>` ou `corretor=<id>` no lugar de `cidade`; só imóveis publicados; ordenação
  padrão "mais recentes". Documentado para sign-off da frente web, como fizeram §9–§11.
  — **Reversibility:** costly — contrato compartilhado com a web.
- **D-03:** Mesmo padrão da API-04/F4: DataSource **real (Dio)** para os perfis da WEB 02 e
  DataSource **mock** sobre JSON de wire, trocáveis por DI. Enquanto o detalhe e a lista de
  imóveis forem mock (até a Phase 5), o DI registra o **mock** dos perfis, com fixtures
  coerentes com os corretores que o mock do detalhe já devolve (ids batendo) — senão o
  corretor do detalhe mock cairia em 404 na API real. A real fica pronta e testada (Dio
  mockado) e a troca é uma linha de DI, junto com a Phase 5. A vitrine do anunciante é só mock
  (não há endpoint), parseada pelo mesmo Model da lista.
- **D-04:** Erros tipados só na camada de dados (padrão F4/D-17): 404 → exceção de domínio
  "perfil não encontrado"; presentation decide pelo tipo, sem `try/catch` na UI.

### Navegação e entrada
- **D-05:** Substitui a F4/D-15 (perfil stub com objeto em memória): tocar no cartão do
  corretor na página do imóvel abre o perfil **buscando na API pelo `id`** do corretor.
  A abertura mostra na hora a **prévia** que o detalhe já tem (nome + foto), como F4/D-16, e
  completa quando a resposta chega.
- **D-06:** Página da empresa: aberta a partir do perfil do corretor (usa `empresa_id`), por
  um cartão "Ver imobiliária" (ou "Ver página do anunciante" quando `tipo == AUTONOMO` —
  texto é Claude's Discretion). Sem atalho direto da página do imóvel (o contrato do detalhe
  não expõe a empresa — F4 §11.5 g).
- **D-07:** Navegação por `Navigator.push` + `MaterialPageRoute` (F4/D-18). Sem go_router.
  Tocar num imóvel da vitrine do anunciante abre a página do imóvel com o fluxo existente
  (`abrirDetalheImovel`).

### Layout (Material 3, `ColorScheme.fromSeed` verde e branco, `Theme.of(context).textTheme`)
- **D-08:** Corretor, de cima para baixo: foto grande (`AvatarCorretor`) + nome + CRECI →
  apresentação → contato → cartão da empresa (D-06) → "Imóveis de {nome}" (vitrine do
  anunciante).
- **D-09:** Empresa: logomarca + nome + CRECI (+ "Imobiliária"/"Corretor autônomo") →
  apresentação (`descricao`) → contato → cidades de atuação (chips) → "Imóveis de {nome}".
- **D-10:** Contato mostra telefone, WhatsApp e e-mail **como texto** (selecionável), com
  ícone. **Sem botões de ligar/WhatsApp/e-mail e sem registrar contato** — isso é o APP 06
  (CON-01), que tem regra no servidor. Nenhuma dependência nova (sem `url_launcher`).
- **D-11:** Campo vazio/nulo omite a linha; seção vazia some inteira (F4/D-14).
- **D-12:** Vitrine do anunciante reaproveita o `ImovelCard` da vitrine e o padrão de lista
  paginada por cursor com rodapés loading/erro/fim (F2/VIT-05). Vazio: "Nenhum imóvel
  anunciado no momento." Página única rolável (`CustomScrollView` com o cabeçalho do perfil e
  a lista em sliver).
- **D-13:** Reaproveitar componentes existentes: `AvatarCorretor`, `ImagemRede`,
  `Card.outlined` (como `CartaoCorretor`), formatação de preço da vitrine. Nada de cor
  hard-coded fora do `ColorScheme`.

### Estados e erros
- **D-14:** Cubits próprios (`PerfilCorretorCubit`, `PerfilEmpresaCubit`; a vitrine do
  anunciante pode ter o seu) com estados freezed explícitos Loading/Success/Failure.
- **D-15:** Corretor desativado/inexistente (404): "Este corretor não está mais disponível"
  com "Voltar"; empresa inativa (404): "Esta página não está mais disponível" com "Voltar";
  demais erros: "Tentar de novo". Mesmo desenho do F4/D-17 (DET-06).
- **D-16:** Sem `/gsd-ui-phase` para esta fase (mesmo caminho do F4/D-20): D-08..D-13 são o
  contrato de UI; ícones e rótulos confirmados no human-check de fim de fase.

### Rastreabilidade
- **D-17:** Novos IDs em `REQUIREMENTS.md` (seção "Perfis públicos (APP07)"), mapeados para
  a Phase 7 no ROADMAP e na tabela de rastreabilidade, como o 04-02 fez:
  PERF-01 (página da empresa), PERF-02 (página do corretor), PERF-03 (vitrine do
  anunciante), PERF-04 (dados da API de perfis públicos), PERF-05 (aviso de perfil
  desativado), PERF-06 (chegar ao perfil pela página do imóvel) e API-08 (adendo §12 do
  contrato da vitrine do anunciante + DataSource trocável).

## Claude's Discretion
- Ícones e textos exatos (rótulos de contato, título da seção de imóveis, texto do cartão da
  empresa).
- Estrutura de pastas (sugestão: `presentation/perfis/` e `domain`/`data` com arquivos novos,
  mexendo o mínimo nos arquivos existentes — há trabalho paralelo da Phase 5 em outra branch).
- Formato do CRECI na tela (mostrar o texto como vem).
- Fixtures: pelo menos um corretor completo, um com campos vazios, um id reservado para 404
  (desativado); uma empresa IMOBILIARIA e uma AUTONOMO; vitrine com e sem imóveis.

## Fora do escopo
- Botão de WhatsApp/telefone/e-mail e registro do contato na API → APP 06 (CON-01).
- Login e área do corretor → APP 08. Área do gestor → APP 12.
- Qualquer mudança no Django: endpoint da vitrine do anunciante e checagem de empresa ativa
  ficam registrados como pendências para a frente web.
- Favoritos (FAV-01) e mapa.

## Restrições do projeto (lembrete)
- Nenhuma regra de negócio no app; o app é uma tela sobre os dados.
- Clean Architecture data/domain/presentation, Cubit, freezed, get_it + injectable, dio,
  Result/sealed, Material 3 verde e branco, testes antes do código (bloc_test + mocktail).
- Código, nomes e comentários em português.
- Commits locais do fluxo GSD liberados na `feat/APP07`; **push só com autorização**.
