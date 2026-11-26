---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 04
subsystem: contrato da API + teste de contrato do app
tags: [contrato, fixtures, fotos]
requires: ["11-03"]
provides:
  - "§19 \"Fotos do imóvel (Fase 11)\" em 01-CONTRATO-API.md"
  - "Exemplos fotos_lista, foto_enviada e fotos_apos_apagar_capa em contrato/ (cópias byte a byte)"
  - "test/data/contrato_fotos_imovel_test.dart"
key-files:
  created:
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/fotos_lista.example.json"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/foto_enviada.example.json"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/fotos_apos_apagar_capa.example.json"
    - "test/data/contrato_fotos_imovel_test.dart"
  modified:
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md"
    - ".planning/REQUIREMENTS.md"
completed: 2026-11-25
---

# 11-04 — §19 do contrato e teste de contrato

## O que foi feito
- **§19** no formato do §18:
  - 19.1 rotas, perfis (403 do gestor e do administrador), 401, 404 igual para inexistente e outra empresa,
    `foto_id` de outro imóvel, rota antiga não usada;
  - 19.2 item `{id, imagem, ordem, capa}`, lista por `ordem, id`, capa marcada pelo campo e não pela posição;
  - 19.3 envio de um arquivo, ordem = maior + 1, capa automática, tipo/tamanho/teto e a tabela dos 400 com as
    mensagens reais;
  - 19.4 reordenar com a lista completa; 19.5 capa; 19.6 apagar com renumeração e promoção;
  - 19.7 onde as fotos aparecem (API pública, cartão, site, com a capa primeiro);
  - 19.8 sincronização, procedimento e travas nos dois repos.
- **Exemplos** copiados com `cp` das fixtures (o teste confere byte a byte).
- **Teste de contrato** (13 testes):
  - exemplo = fixture;
  - chaves exatas e tipos de cada foto, com URL absoluta em `/media/imoveis/fotos/`;
  - ordens `0..n-1` e capa única em todas as listas;
  - a primeira foto como capa;
  - PUT = ordem invertida pedida; capa na do meio;
  - apagar a capa renumera e promove a primeira restante;
  - os 400 com só `imagem`/`ids`, a mensagem do teto, 404/403 com só `detail`.
- **REQUIREMENTS:** linha "Planos da Phase 11 que cobrem cada ID". Os IDs já estavam como Pending desde o discuss.

## Desvios do plano
- Nenhum.

## Verificação
- `flutter test test/data/contrato_fotos_imovel_test.dart`: 13 OK. `flutter analyze` do arquivo: sem problemas.
  `dart format` aplicado.
- Sem commit no app (aguardando aprovação).
