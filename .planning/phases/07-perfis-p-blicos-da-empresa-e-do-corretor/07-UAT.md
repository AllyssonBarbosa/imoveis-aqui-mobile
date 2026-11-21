---
status: complete
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
source: [07-VERIFICATION.md, 07.1-06-PLAN.md (Phase 07.1: integração da APP-07 com a API real)]
started: 2026-11-19T00:00:00Z
updated: 2026-11-21T00:52:48.957Z
---

## Current Test

[testing complete]

## Tests

Dados reais do `semear_vitrine_dev` (API Django da `feat/APP07` da web). Os ids nunca são fixos: descubra-os pelo app (ou por `curl` na API local). Valores do seed: corretor ativo "Corretor Vitrine Demo" (`corretor.vitrine.demo@example.com`, CRECI 12345-F, 35 imóveis na vitrine, 2 páginas), corretor desativado "Corretor Desativado Demo" (responsável pelo imóvel `DEV-CAMPINAS-14`) e empresa "Imobiliária Vitrine Demo (dev)" (IMOBILIÁRIA, CRECI 00000-D, 4 cidades, 36 imóveis na vitrine, 2 páginas, sem telefone, sem descrição e sem logomarca).

### 1. Perfil do Corretor Vitrine Demo a partir de um imóvel de Campinas
Passos: em Campinas, 'Mais recentes', abrir um imóvel que não seja o `DEV-CAMPINAS-14`, rolar até 'Corretor responsável' e tocar em Corretor Vitrine Demo.
expected: A página do corretor abre na hora com nome e foto da prévia e completa em instantes com 'CRECI 12345-F', 'Apresentação' com o texto do seed e 'Contato' (telefone, WhatsApp e e-mail como texto), sem botão de ligar/WhatsApp/e-mail.
result: pass

### 2. Contato selecionável, rolagem infinita, página da empresa e volta
Passos: no perfil do Corretor Vitrine Demo, pressionar e segurar o telefone; rolar 'Imóveis de Corretor Vitrine Demo' até o fim; voltar ao topo e tocar 'Ver página do anunciante'; rolar a página da empresa e tocar num imóvel; voltar página a página até a vitrine.
expected: O texto do contato é selecionável/copiável e nada é discado; a vitrine do corretor carrega mais ao rolar até 'Você chegou ao fim da lista' (2 páginas, 35 imóveis, sem card repetido); 'Imobiliária Vitrine Demo (dev)' mostra o placeholder de logomarca, 'Imobiliária', 'CRECI 00000-D', os chips das 4 cidades (Campinas, Indaiatuba, Valinhos, Vinhedo) e 'Imóveis de Imobiliária Vitrine Demo (dev)' (2 páginas, 36 imóveis); tocar num imóvel abre o detalhe e voltar devolve a vitrine na mesma posição.
result: pass

### 3. Campos vazios com dados reais (empresa demo)
Passos: abrir a página da empresa demo a partir do perfil do corretor.
expected: A empresa não mostra 'Apresentação' (sem descrição) nem a linha 'Telefone' (sem telefone) e mostra o placeholder de logomarca; o WhatsApp e o e-mail aparecem. Registro: a corretora autônoma com campos vazios do UAT antigo não existe no seed (PENDENTE WEB do D-20, extensão do seed); este teste cobre "campos vazios" só pela empresa demo.
result: pass

### 4. Corretor desativado por corrida e imóvel de corretor desativado
Passos: (a) com o detalhe de um imóvel do Corretor Vitrine Demo aberto, rodar em `Web\` `python manage.py shell -c "from contas.models import Usuario; Usuario.objects.filter(email='corretor.vitrine.demo@example.com').update(is_active=False)"` e então tocar no corretor; (b) tocar em 'Voltar'; (c) REATIVAR com `python manage.py shell -c "from contas.models import Usuario; Usuario.objects.filter(email='corretor.vitrine.demo@example.com').update(is_active=True)"` (o seed não reativa); (d) abrir o imóvel `DEV-CAMPINAS-14` (responsável desativado).
expected: (a) a prévia com o nome aparece por um instante e troca para 'Este corretor não está mais disponível' com 'Voltar', sem nome, foto nem lista; (b) 'Voltar' devolve o detalhe; (d) o imóvel abre sem a seção 'Corretor responsável'.
result: pass
note: "(d) o DEV-CAMPINAS-14 não aparece pelo código (a busca não procura código): achado pela busca 'Barão Geraldo' como 'Apartamento no bairro Barão Geraldo' (11º em 'Mais recentes'). Corretor demo desativado e reativado pelo shell do Django durante o teste; reativação confirmada (is_active=True)."

### 5. Layout em 360 dp, fidelidade visual e rótulo do cartão (suposição A7)
Passos: repetir os fluxos acima no emulador Android (`Pixel_7`); o app não tem a pasta `windows/`, então não rode no Windows.
expected: Sem overflow, sem cor fora do tema verde e branco, rótulos em português natural; confirmar também a suposição A7 (rótulo neutro 'Ver página do anunciante' no cartão da empresa).
result: pass
note: "Rótulo 'Ver página do anunciante' aprovado pelo Allysson (A7 confirmada)."

## Summary

total: 5
passed: 5
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

## Ambiente (preparação)

- Repo web: branch `feat/APP07`.
- Em `Web\` (PowerShell): `.\venv\Scripts\Activate.ps1`, `python manage.py migrate`, `python manage.py semear_vitrine_dev`, `python manage.py runserver 0.0.0.0:8000`. O `.env` local precisa de `10.0.2.2` em `ALLOWED_HOSTS` (só o nome da variável; nenhum valor do arquivo é copiado aqui) e `DEBUG=True` (o seed só roda assim).
- No app: `flutter emulators --launch Pixel_7` e `flutter run` (base URL padrão `http://10.0.2.2:8000`).
- Ao terminar: pare o `runserver` (Ctrl+C) e confirme que o corretor demo foi reativado (teste 4c).
