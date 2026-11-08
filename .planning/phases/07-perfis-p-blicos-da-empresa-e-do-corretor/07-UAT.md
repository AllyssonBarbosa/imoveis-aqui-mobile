---
status: testing
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
source: [07-VERIFICATION.md]
started: 2026-11-08T23:30:00Z
updated: 2026-11-08T23:30:00Z
---

## Current Test

number: 1
name: Perfil da corretora Marina Lopes a partir do card 42 (Campinas)
expected: |
  A página do corretor abre na hora com nome e foto da prévia (foto do 42 usa host fictício e mostra o avatar padrão) e completa em ~0,5 s com 'CRECI 12345-F', 'Apresentação' e 'Contato' (ícones de telefone, conversa e e-mail), sem botão de ligar/WhatsApp/e-mail.
awaiting: user response

## Tests

### 1. Perfil da corretora Marina Lopes a partir do card 42 (Campinas)
Passos: em Campinas, 'Mais recentes', abrir o card 42, rolar até 'Corretor responsável' e tocar em Marina Lopes.
expected: A página do corretor abre na hora com nome e foto da prévia (foto do 42 usa host fictício e mostra o avatar padrão) e completa em ~0,5 s com 'CRECI 12345-F', 'Apresentação' e 'Contato' (ícones de telefone, conversa e e-mail), sem botão de ligar/WhatsApp/e-mail.
result: [pending]

### 2. Contato selecionável, rolagem infinita, página da empresa e volta
Passos: no perfil de Marina, pressionar e segurar o telefone; rolar até o fim; voltar ao topo e tocar 'Ver página do anunciante'; rolar a página da empresa e tocar num imóvel; voltar até a vitrine.
expected: O texto do contato é selecionável/copiável e nada é discado; a vitrine 'Imóveis de Marina Lopes' carrega mais ao rolar até 'Você chegou ao fim da lista' (4 páginas) sem card repetido; 'Imobiliária Jequitibá' mostra logomarca (ou placeholder verde com prédio), 'Imobiliária', 'CRECI J-1234', Apresentação, Contato, chips 'Campinas, SP' / 'Valinhos, SP' / 'Vinhedo, SP' e 'Imóveis de Imobiliária Jequitibá'; voltar retorna página a página até a vitrine na mesma posição.
result: [pending]

### 3. Corretora autônoma com campos vazios (imóvel 101, Camila Duarte)
Passos: abrir o 4º card de Campinas (imóvel 101, Camila Duarte), o perfil dela e depois 'Ver página do anunciante'.
expected: Camila sem foto (avatar padrão), sem 'Apresentação' e sem a linha 'Telefone'; a empresa dela mostra 'Corretor autônomo', placeholder de logomarca, sem 'Apresentação', chip 'Vinhedo, SP' e os imóveis dela.
result: [pending]

### 4. Corretor desativado (Vinhedo, imóvel 337, Paulo Teixeira)
Passos: trocar para Vinhedo, rolar até o fim, abrir o antepenúltimo card (imóvel 337) e tocar no corretor Paulo Teixeira.
expected: O perfil abre com 'Paulo Teixeira' por um instante e troca para 'Este corretor não está mais disponível' com 'Voltar', sem nome nem foto, sem lista de imóveis; 'Voltar' devolve o detalhe 337.
result: [pending]

### 5. Layout em 360 dp, fidelidade visual e rótulo do cartão (suposição A7)
Passos: repetir os fluxos acima numa largura de 360 dp (emulador Android, dispositivo real ou `flutter run -d windows`).
expected: Sem overflow, sem cor fora do tema verde e branco, rótulos em português natural; confirmar também a suposição A7 (rótulo neutro 'Ver página do anunciante' no cartão da empresa).
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
