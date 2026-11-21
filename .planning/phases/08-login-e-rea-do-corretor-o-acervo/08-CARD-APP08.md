# Card APP 08 · Login e área do corretor: o acervo (tarefa A08)

Fonte: texto oficial do card, enviado pelo Allysson em 2026-11-20. Usado como PRD da Phase 8.

## História (texto do card, sem alteração)

Como corretor, eu quero entrar no aplicativo para ver os imóveis que eu e a imobiliária temos, de
onde eu estiver.
O login é do mesmo aplicativo — não existe app separado. Quem entra vê a área do seu papel; o
visitante continua usando o app sem login, como antes.
O corretor vê os imóveis dele e os da imobiliária, com busca e filtro por situação. Imóvel de outra
empresa não aparece, de jeito nenhum.
Tarefa A08 do documento de histórias.

Dependência: [WEB] 01 · Login, usuários, perfis e a empresa — feito.

## Critérios de aceite (texto do card, sem alteração)

1. Login pelo aplicativo, com o token vindo da API
2. A sessão fica guardada; sair apaga o token do aparelho
3. Erro de login genérico, sem revelar se o e-mail existe
4. Lista do acervo com os imóveis do corretor e os da imobiliária, com busca e filtro por situação
5. Imóvel de outra empresa não aparece nem forçando a consulta
6. Sem login, o app continua abrindo direto na vitrine

## O que a API já entrega (repo da web, branch `main` em d9ddd8f, 2026-11-20)

Repo da web: `C:\Users\allys\OneDrive\Área de Trabalho\Imoveis-aqui\Web` (NÃO é `../imoveis-aqui/Web`).

- **Login:** `POST /api/auth/login/` (`contas/api/views.py` `LoginAPIView`, `AllowAny`), corpo
  `{email, password}`, resposta `{"token": "<chave>"}` (DRF `TokenAuthentication`, header
  `Authorization: Token <chave>`). Falha → 400 com a mensagem única "E-mail ou senha inválidos."
  (usuário inexistente, senha errada e usuário inativo caem na mesma mensagem — critério 3 já
  atendido no servidor). Sem limite de tentativas. Sem endpoint de logout (o token não expira nem é
  revogado pelo servidor).
- **Papéis:** `Usuario.Perfil` = `ADMINISTRADOR` (sem empresa), `GESTOR`, `CORRETOR` (com empresa).
  Nenhuma rota devolve o papel de quem está logado.
- **Acervo do corretor:** `GET /api/imoveis/` (`ImovelViewSet`, permissão `EhCorretor`,
  `EmpresaScopedQuerySetMixin`) — devolve TODOS os imóveis da empresa do corretor (os dele e os da
  imobiliária); `GET /api/imoveis/<id>/` de outra empresa → 404 (critério 5 já garantido no
  servidor). Sem busca, sem filtro, SEM paginação (lista inteira), com o `ImovelSerializer`
  completo (detalhe por natureza, fotos, proprietário, pendências de publicação).
- **Gestor:** `GET /api/gestao/imoveis/?situacao=` (`EhGestor`) já filtra por situação.
- **Regra do site:** o painel do corretor (`imoveis/views.py` `ImovelListView`) usa
  `FiltroImovelForm` (`imoveis/forms.py`): `busca` = `codigo` OU `titulo` contém (sem acento-aware),
  `situacao` = igualdade com `DISPONIVEL | RESERVADO | VENDIDO | ALUGADO`; filtro inválido é
  ignorado (não dá erro). É a regra única que o app deve reaproveitar.

## Lacunas na web (levantamento de 2026-11-20)

1. **"Quem sou eu":** o login devolve só o token; o app precisa do papel (corretor/gestor/admin)
   para abrir a área certa e de uma forma de validar a sessão guardada ao reabrir o app.
2. **Busca e filtro por situação na rota do corretor:** `GET /api/imoveis/` não lê `busca` nem
   `situacao`; reaproveitar `FiltroImovelForm(campos=["busca", "situacao"])` dá a mesma regra do
   painel do site.
3. **Lista enxuta e paginada:** a rota devolve o acervo inteiro com o serializer completo; para o
   celular, paginação (padrão `PageNumberPagination` da APP-05) e campos de cartão.
4. (Segurança, fora do texto do card) sem limite de tentativas no login e sem revogação do token.

## Decisões do Allysson (2026-11-20, antes do discuss-phase — não perguntar de novo)

- **D-A · Escopo web = necessário + segurança.** Esta fase constrói no repo da web (branch
  `feat/APP08` do web, como a 07.1 fez com `feat/APP07`): endpoint "quem sou eu"
  (`GET /api/auth/eu/` ou nome equivalente no padrão do repo), busca + situação + paginação na rota
  do corretor reaproveitando `FiltroImovelForm(campos=["busca", "situacao"])`, lista enxuta para o
  cartão, limite de tentativas no login e um "sair" que revoga o token no servidor (além de apagar
  do aparelho).
- **D-B · Gestor/administrador no app:** o login funciona e abre uma tela de aviso ("a área do
  gestor ainda não está no app") com Sair. A APP-12 troca essa tela depois, sem mexer no login.
- **D-C · Abertura com sessão guardada:** o app continua abrindo na vitrine para todo mundo; com
  sessão, o botão do topo vira "Meu acervo" (sem sessão, "Entrar").
- **D-D · Armazenamento do token:** `flutter_secure_storage` (Keychain/Keystore). A nota do
  CLAUDE.md que o descartava valia só enquanto o app não guardava credencial.
- **D-E · Rota de planejamento:** fluxo completo (`/gsd-discuss-phase 8` → pesquisa → padrões →
  planejador → verificador).
