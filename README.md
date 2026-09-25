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

A lista de cidades da tela de seleção vem de `GET /api/publico/cidades/`, servido pelo
Django do repositório irmão (`../imoveis-aqui/Web`) — não há mais um asset fixo empacotado
no app (D-16). O acervo de imóveis da vitrine ainda é servido por um mock em memória dentro
do próprio app até a Fase 4.

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

```bash
# a partir de ../imoveis-aqui/Web
cp .env.example .env               # preencha DATABASE_URL e ALLOWED_HOSTS com suas credenciais
python manage.py migrate
python manage.py semear_vitrine_dev  # semeia Campinas/Valinhos/Vinhedo/Indaiatuba com 1 empresa demo ativa
python manage.py runserver 0.0.0.0:8000
```

`ALLOWED_HOSTS` deve incluir `10.0.2.2` (emulador Android) e o IP da rede local da máquina
(aparelho físico). `semear_vitrine_dev` é idempotente e só roda com `DEBUG=True`.

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
