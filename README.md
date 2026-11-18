# Imóveis Aqui — App (Vitrine)

Aplicativo Flutter do marketplace de imóveis "Imóveis Aqui", organizado por cidade. O app
abre direto na vitrine da cidade do visitante — **sem login** — para que qualquer pessoa
navegue os imóveis à venda e para alugar.

Esta fatia do projeto cobre as tarefas **APP01, APP02 e APP03**: abertura/localização/escolha
da cidade, vitrine com lista/busca/ordenação, e filtros da vitrine. O app é "uma tela sobre os
dados": nenhuma regra de negócio (preço, parcela, situação, filtro) é decidida no celular —
tudo vem calculado e filtrado pela API Django do projeto.

## Pré-requisitos

- **Flutter 3.47.5 stable / Dart 3.13.4** (canal stable). Confirme a instalação com
  `flutter --version` e valide o toolchain com `flutter doctor`.

  - **macOS (Apple Silicon/M1):** instale pelo [instalador oficial](https://docs.flutter.dev/get-started/install)
    ou via Homebrew:

    ```bash
    brew install --cask flutter
    ```

  - **Windows:** instale pelo [instalador oficial](https://docs.flutter.dev/get-started/install/windows)
    ou via winget/Chocolatey, adicione o Flutter ao `PATH` e reabra o terminal:

    ```powershell
    winget install --id Google.Flutter
    # ou, com o Chocolatey:
    choco install flutter
    ```

    Instale também o **Android Studio + Android SDK** e habilite o **Modo de Desenvolvedor**
    do Windows (necessário para alguns plugins). Rode `flutter doctor` para conferir.

- Um dispositivo ou emulador conforme o SO da máquina de desenvolvimento (os alvos de deploy
  são Android e iOS — Windows e macOS são apenas máquinas de desenvolvimento):

  - **macOS:** emulador Android **ou** simulador iOS.
  - **Windows:** apenas Android (emulador ou dispositivo físico). Build e simulador **iOS
    exigem macOS** — não há como compilar/rodar para iOS no Windows.

  Os testes automatizados (`flutter test`) e a análise estática (`flutter analyze`) rodam em
  qualquer SO, inclusive Windows, sem necessidade de emulador.

## Preparar o ambiente (setup)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

O segundo comando roda o codegen de `freezed` / `json_serializable` / `injectable`, gerando
os arquivos `*.freezed.dart`, `*.g.dart` e `injection.config.dart` necessários para compilar
o projeto.

## Rodar o app

Com um device/emulador ativo (ver "API e servidor de desenvolvimento" abaixo para subir o
Django antes):

```bash
flutter run
```

## API e servidor de desenvolvimento

As cidades, a vitrine (lista, busca, ordenação, filtros e as opções de bairro e característica) e a
página do imóvel vêm da API real do repositório irmão (`../imoveis-aqui/Web`), na branch
`feat/APP06`: `GET /api/publico/cidades/`, `/api/publico/cidades/<id>/imoveis/`,
`/api/publico/cidades/<id>/bairros/`, `/api/publico/caracteristicas/`, `/api/publico/imoveis/<id>/` e `POST /api/publico/imoveis/<id>/contato/`.
O app não tem mock de acervo: se a API falhar, a tela mostra o estado de erro com "Tentar de novo".
O formato das respostas está em
`.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md`.

### Base URL da API (app)

O app lê a base URL via `--dart-define=API_BASE_URL=...` (D-17), com um padrão pronto para
o emulador Android:

- **Emulador Android** (padrão, nenhum define necessário): `http://10.0.2.2:8000` — alias
  que o emulador usa para o `localhost` da máquina que roda o `runserver`.
- **Simulador iOS**:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
  ```
- **Aparelho físico** (Android ou iOS), na mesma rede Wi-Fi da máquina de desenvolvimento:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://<IP-da-rede-local-da-máquina>:8000
  ```

### Subir o Django (`../imoveis-aqui/Web`)

Na branch `feat/APP06` do repositório da API (ela traz a vitrine pública da W09, as migrações
`imoveis.0003` a `0006` e a caixa de contatos da W11: o `migrate` também cria a tabela `contatos`,
migração `contatos.0001`):

```bash
# a partir de ../imoveis-aqui/Web
git switch feat/APP06
cp .env.example .env               # preencha DATABASE_URL (Postgres) e confira DEBUG=True
.venv/bin/python manage.py migrate
.venv/bin/python manage.py semear_vitrine_dev
.venv/bin/python manage.py runserver 0.0.0.0:8000
```

- `semear_vitrine_dev` é idempotente, **só roda com `DEBUG=True`** e cria imóveis das quatro
  naturezas (casa, apartamento, terreno e lote) em Campinas (24), Valinhos, Vinhedo e Indaiatuba
  (4 cada), com fotos geradas na hora. Roda de novo sem duplicar nada.
- `ALLOWED_HOSTS` deve incluir `10.0.2.2` (emulador Android) e o IP da rede local da máquina
  (aparelho físico); o `.env.example` já traz `localhost,127.0.0.1,10.0.2.2`.
- O servidor escuta em `0.0.0.0:8000` só durante o desenvolvimento; pare-o ao terminar.

### Fixtures de teste (JSON real)

Os testes do app não usam JSON escrito à mão: `test/fixtures/api/` guarda respostas **capturadas** da
API semeada (cidades, listas de Campinas, bairros, características, os quatro detalhes, os casos sem
foto e sem corretor, os erros 400 e 404 e as respostas do POST de contato). Os exemplos do contrato
(`.planning/phases/01-.../contrato/*.example.json`) são cópias exatas delas, e
`test/data/contrato_lista_test.dart` / `test/data/contrato_detalhe_test.dart` falham se divergirem.
Para recapturar tudo (por exemplo, depois que a API mudar):

```bash
# 1. em ../imoveis-aqui/Web, com um SQLite temporário (NUNCA o banco do .env)
CAPTURA_DB="sqlite:///${TMPDIR:-/tmp}/imoveis_captura_05.sqlite3"
rm -f "${TMPDIR:-/tmp}/imoveis_captura_05.sqlite3"
DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py migrate --noinput
DEBUG=True DATABASE_URL="$CAPTURA_DB" .venv/bin/python manage.py semear_vitrine_dev

# 2. servidor temporário em segundo plano
DEBUG=True ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2 DATABASE_URL="$CAPTURA_DB" \
  .venv/bin/python manage.py runserver 127.0.0.1:8000 --noreload &

# 3. na raiz do app (aguarde o servidor responder em /api/publico/cidades/)
python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo todos

# 4. pare o servidor temporário e apague o SQLite temporário
```

`--grupo todos` recaptura as 19 fixtures de uma vez (`lista`, `detalhe` e `contato` capturam só o seu grupo).
Para capturar só o contato use `--grupo contato`. Esse grupo faz o POST de contato de verdade (`contato_201_whatsapp.json`, `contato_201_telefone.json`,
`contato_201_email.json` e `erro_400_canal_contato.json`): cada POST grava um contato **só no SQLite temporário**
do passo 1, nunca no banco do `Web/.env`. Suba o servidor temporário com `CONTATO_TAXA_ANONIMA=1000/min` para
não esbarrar no limite de 10/min ao repetir a captura.
Depois, copie as fixtures para os exemplos do contrato (tabela no §12 do `01-CONTRATO-API.md`) e rode
`flutter test`.

### Verificação ponta a ponta (emulador)

Só um emulador ou simulador contra o Django semeado prova a integração de verdade (rede, imagens,
rolagem, latência). Desktop e web **não** servem: o projeto não tem a pasta `macos/` e a API não tem CORS.

1. Suba a API (veja "Subir o Django" acima), com o banco migrado e semeado:

   ```bash
   cd ../imoveis-aqui/Web
   .venv/bin/python manage.py runserver 0.0.0.0:8000
   ```

2. Rode o app:

   - **Android** (AVD `Medium_Phone_API_36.0`, base URL padrão `http://10.0.2.2:8000`):

     ```bash
     flutter emulators --launch Medium_Phone_API_36.0
     flutter run
     ```

   - **iOS** (simulador iOS 17.5):

     ```bash
     open -a Simulator
     flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
     ```

3. Roteiro (o que deve aparecer entre parênteses):
   1. Escolha Campinas (ou deixe a localização escolher) e role a lista inteira (imóveis semeados com
      fotos geradas em cores; duas páginas, sem cards repetidos).
   2. Busque `Cambuí` e depois uma palavra que não casa com nada (cards correspondentes; depois o estado
      sem resultado).
   3. Ordene por "Maior preço" (o mais caro primeiro).
   4. Abra "Filtros": marque Casa e Lote, um bairro, "Piscina" e uma faixa de preço; aplique; remova um
      chip; toque em "Limpar filtros" (o servidor responde a cada combinação; chips e contador
      acompanham; "Limpar filtros" volta à lista completa).
   5. Abra uma casa, um apartamento, um terreno e um lote (galeria começando pela capa com "N/M"; preços
      com condomínio/IPTU; "Sobre a casa"; "Sobre o apartamento" com o cartão do prédio e "Ano de
      construção"; "Sobre o terreno" com "Lateral esquerda" e "Lateral direita" e "Uso permitido" em
      português; "Sobre o lote" com "Entrada mínima", "Parcelas máximas" e o cartão "Quadra e loteamento",
      sem "Preço do lote"; posição solar em português). No lote, toque no cartão do corretor e volte (o
      perfil aberto a partir do imóvel mostra nome, foto e a barra de contato "Sobre: <título>").
   6. Abra o imóvel sem fotos e o sem corretor (placeholder sem contador; sem a seção "Corretor
      responsável").
   7. Troque para Valinhos com um filtro ativo (a lista de Valinhos mantém o filtro e os bairros
      escolhidos são limpos).
   8. Contato (APP 06): abra um imóvel de Campinas (no rodapé, a barra com o preço, o ⋮ e o botão
      "WhatsApp"). Toque em "WhatsApp" (abre o **app do WhatsApp** com a mensagem padrão do servidor já
      preenchida, com espaços entre as palavras). Toque no ⋮ (o bottom sheet oferece "Ligar", que abre o
      discador com +55, e "Enviar e-mail", que abre o e-mail com assunto e corpo). Abra o imóvel cujo corretor
      está desativado (a barra aparece e o ⋮ oferece só os canais da empresa, sem "Ligar"). Cada toque
      bem-sucedido grava um Contato no servidor (imóvel, corretor e canal), sem login. Conferir o WhatsApp
      exige um aparelho ou emulador com Play Store e o WhatsApp instalado e logado (desktop e web não valem).

   Textos e layout devem ler naturalmente em português a 360 dp, em Material 3 verde e branco.

4. Ao terminar, pare o `runserver` (Ctrl+C).

## Testes e análise

```bash
flutter test
```

```bash
flutter analyze
```

## Permissão de localização

- Android declara `ACCESS_FINE_LOCATION` e `ACCESS_COARSE_LOCATION`.
- iOS declara `NSLocationWhenInUseUsageDescription`.

O app só pede a permissão a partir do toque no CTA da tela de priming (nunca na
inicialização) e, se a localização for recusada ou estiver indisponível, cai no fallback de
escolha manual da cidade — nunca numa tela de erro.

## Arquitetura (nota curta)

Clean Architecture em camadas:

- `lib/data/` — models, datasources, repositories
- `lib/domain/` — entities, use cases, interfaces
- `lib/presentation/` — widgets + Cubits

Estado com `Cubit` (flutter_bloc), estados imutáveis (`freezed` sealed classes), erros via
`Result` selado. Injeção de dependência com `get_it`/`injectable`. Idioma do código em
português.
