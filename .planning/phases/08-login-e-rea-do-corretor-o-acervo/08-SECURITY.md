---
phase: "08"
slug: "login-e-rea-do-corretor-o-acervo"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-11-21"
---

# Phase 08 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
> Registro montado dos `<threat_model>` dos 12 PLANs (66 linhas) e verificado pelo `gsd-security-auditor` em 2026-11-21.
> Caminhos: app = `C:/projetos/imoveis-aqui-mobile`; web = `C:/projetos/imoveis-aqui` (os PLANs citam um caminho antigo no OneDrive).

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| App → API pública (`/api/publico/`, `/api/auth/login/`) | Dio público, sem interceptor e sem token | credenciais no login (alta); dados públicos |
| App → API autenticada (`/api/auth/eu/`, `/api/auth/sair/`, `/api/imoveis/`) | Dio `@Named('autenticado')` com `InterceptadorSessao`, token só na mesma origem, `followRedirects: false` | token DRF (alta); acervo da empresa (média) |
| Aparelho (armazenamento) | `flutter_secure_storage` (Keychain/Keystore), `allowBackup="false"` | token (alta) |
| Django → banco | isolamento por empresa via mixin + `FiltroImovelForm` | imóveis de outras empresas (alta) |
| Ferramenta de captura → fixtures | SQLite temporário, credencial só por ambiente, token redigido | senha/token de teste (alta) |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-08-01 | Information Disclosure | `ImovelViewSet.list` com filtros forçados | high | mitigate | mixin de empresa antes do `FiltroImovelForm`; `AcervoApiTests` isolamento | closed |
| T-08-02 | Information Disclosure | detalhe de imóvel de outra empresa (IDOR) | high | mitigate | queryset do mixin no retrieve; teste 404 | closed |
| T-08-03 | Information Disclosure | campos do item do acervo | high | mitigate | `Meta.fields` com 10 chaves; `AcervoAllowlistExataTests` | closed |
| T-08-04 | Elevation of Privilege | gestor/administrador na lista | medium | mitigate | `EhCorretor`; testes 403/401 | closed |
| T-08-05 | Denial of Service | lista inteira / N+1 | medium | mitigate | `page_size` fixo, prefetch, `Exists`; consultas constantes testadas | closed |
| T-08-06 | Tampering | filtro inválido na query | low | accept | ignorado como no painel; §14.5 + README web | closed |
| T-08-07 | Information Disclosure | token em rota pública/outra origem | high | mitigate | Dio público sem interceptor; `mesmaOrigem` | closed |
| T-08-08 | Information Disclosure | token em repouso/backup | high | mitigate | `flutter_secure_storage`; `allowBackup="false"` | closed |
| T-08-09 | Information Disclosure | token em log | medium | mitigate | sem `LogInterceptor`/`print` em `lib/` | closed |
| T-08-10 | Tampering | 401 atrasado apagando token novo | medium | mitigate | compare-and-delete com `token_usado` | closed |
| T-08-11 | Information Disclosure | credencial seguindo 3xx | medium | mitigate | `followRedirects: false` no Dio autenticado | closed |
| T-08-12 | Denial of Service | Keystore que não decifra | low | mitigate | `PlatformException` → null | closed |
| T-08-49 | Denial of Service | `apagar()` lançando no 401 | low | mitigate | try/catch e reject sempre | closed |
| T-08-13 | Spoofing | força bruta / credential stuffing | high | mitigate | `ThrottleLoginPorEmail`/`PorIp`; testes | closed |
| T-08-14 | Information Disclosure | enumeração de e-mail | high | mitigate | mensagem única; 429 igual para e-mail existente/inexistente | closed |
| T-08-15 | Spoofing / Repudiation | token sem revogação | high | mitigate | `SairAPIView` apaga o token; `SairApiTests` | closed |
| T-08-16 | Tampering | CSRF em `eu`/`sair` | medium | mitigate | só `TokenAuthentication` | closed |
| T-08-17 | Denial of Service | token revogado derrubando o login | low | mitigate | `authentication_classes = []` no login | closed |
| T-08-18 | Information Disclosure | e-mail em texto na chave de cache | low | mitigate | SHA-256 do e-mail normalizado | closed |
| T-08-19 | Denial of Service | bloqueio dirigido / CGNAT / LocMemCache | medium | accept | §14.8 + README web + taxas configuráveis | closed |
| T-08-20 | Information Disclosure | Sair desconecta os outros aparelhos | low | accept | §14.4, §14.8, READMEs, UAT item 6 | closed |
| T-08-21 | Information Disclosure | senha/token nas fixtures ou ferramenta | high | mitigate | credencial por `os.environ`; token redigido (40 zeros) | closed |
| T-08-22 | Tampering | drift Django ↔ app | medium | mitigate | `contrato_acervo_test` + allowlist exata no Django | closed |
| T-08-23 | Information Disclosure | captura contra banco real | medium | mitigate | SQLite temporário apagado; repo web limpo | closed |
| T-08-24 | Information Disclosure | texto do servidor no erro de login | high | mitigate | falhas tipadas com `toString` fixo | closed |
| T-08-25 | Information Disclosure | senha/e-mail guardados | high | mitigate | só `salvar(token)` | closed |
| T-08-26 | Repudiation | Sair que não sai | high | mitigate | `finally` + `_apagarTokenLocal` que nunca lança | closed |
| T-08-27 | Spoofing | token velho no login | medium | mitigate | login pelo Dio público | closed |
| T-08-28 | Elevation of Privilege | papel desconhecido | low | mitigate | `FormatException` + rollback | closed |
| T-08-29 | Denial of Service | `Retry-After` hostil | low | mitigate | `tryParse`, negativo → null, teto 24 h | closed |
| T-08-31 | Tampering | `foto_capa` com esquema hostil | low | mitigate | `urlHttpOuNula`; teste `javascript:` | closed |
| T-08-32 | Tampering | "Seu"/"na vitrine" decididos no aparelho | medium | mitigate | booleanos só lidos do servidor | closed |
| T-08-33 | Denial of Service | situação/finalidade desconhecida | low | mitigate | situação → null; finalidade → `Failure` | closed |
| T-08-50 | Repudiation | Sair que não termina anônimo | high | mitigate | `SessaoCubit.sair` com `finally` | closed |
| T-08-51 | Spoofing | rollback do login lançando | medium | mitigate | `descartarSessaoLocal()` nunca lança | closed |
| T-08-52 | Denial of Service | abertura esperando a rede | low | mitigate | sessão lida só do aparelho | closed |
| T-08-30 | Information Disclosure | `next` de outra origem levando o token | high | mitigate | `mesmaOrigem` antes do `get` | closed |
| T-08-53 | Tampering | filtro/ordenação no aparelho | medium | mitigate | parâmetros só montam a query | closed |
| T-08-34 | Elevation of Privilege | toque abrindo imóvel não publicado | medium | mitigate | `InkWell` só com `naVitrine`; detalhe público 404 | closed |
| T-08-35 | Tampering | filtro/marca decididos no aparelho | medium | mitigate | cubit só repassa `ConsultaAcervo` | closed |
| T-08-36 | Denial of Service | uma requisição por tecla | low | mitigate | debounce 400 ms + versão da consulta | closed |
| T-08-37 | Information Disclosure | mensagem do servidor na tela | medium | mitigate | texto escolhido só pelo tipo da falha | closed |
| T-08-38 | Denial of Service | envio duplo do login | low | mitigate | guarda `LoginEnviando`; botão desabilitado | closed |
| T-08-39 | Information Disclosure | senha visível / cache de teclado | low | mitigate | `obscureText`, sem sugestões | closed |
| T-08-40 | Elevation of Privilege | gestor/administrador no acervo | low | mitigate | roteamento pelo Papel; Django 403 | closed |
| T-08-54 | Spoofing / Information Disclosure | acervo aberto depois do Sair/401 | medium | mitigate | `popUntil` / `pushAndRemoveUntil(LoginScreen)` | closed |
| T-08-41 | Spoofing | sessão revogada com "Meu acervo" | medium | mitigate | entrada pergunta o papel; 401 → login | closed |
| T-08-42 | Information Disclosure | "voltar" reabrindo a entrada | low | mitigate | `pushReplacement` | closed |
| T-08-43 | Elevation of Privilege | gestor/administrador pelo topo | low | mitigate | papel do servidor; Django 403 | closed |
| T-08-44 | Denial of Service | abertura presa no armazenamento | low | mitigate | `unawaited(carregar())` | closed |
| T-08-45 | Information Disclosure | token em rota pública (pilha completa) | high | mitigate | `conferirCabecalhosDeAutorizacao` nos fluxos | closed |
| T-08-46 | Repudiation | push sem autorização | medium | mitigate | nenhum commit da execução enviado; push depende do usuário (UAT 10) | closed |
| T-08-47 | Information Disclosure | senha de teste no README | medium | mitigate | senha só por variável de ambiente | closed |
| T-08-48 | Spoofing | Keychain iOS sem persistência | low | accept | UAT item 7 (Mac M1), caminho Keychain Sharing | closed |
| T-08-SC (×12) | Tampering | dependências / `requirements.txt` | low–medium | mitigate | só `flutter_secure_storage ^11.2.0` novo; `requirements.txt` igual a d9ddd8f | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| R-08-01 | T-08-06 | Filtro inválido é ignorado (lista sem filtro), igual ao painel do site; não expõe dado de outra empresa | plano 08-01 (CONTEXT D-11) | 2026-11-21 |
| R-08-02 | T-08-19 | Bloqueio dirigido de e-mail, IP compartilhado (CGNAT) e `LocMemCache` por processo: limites configuráveis por ambiente; taxas a confirmar no UAT | plano 08-03, §14.8 | 2026-11-21 |
| R-08-03 | T-08-20 | Token único por usuário: Sair desconecta os outros aparelhos | plano 08-03, §14.4 | 2026-11-21 |
| R-08-04 | T-08-48 | Persistência no Keychain do iOS só verificável num Mac; correção conhecida (Keychain Sharing) | plano 08-12, UAT item 7 | 2026-11-21 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-21 | 66 | 66 | 0 | gsd-security-auditor (opus) |

Observações não bloqueantes do auditor:
1. `origin/feat/APP08` do app já existe em `f5754dc` (commit de planejamento, anterior à execução) — confirmar no UAT.
2. §14.8 do contrato: rótulo "CGNAT" marcado como T-08-20 deveria ser T-08-19; a linha do Sair (T-08-20) só cita "D-A".
3. §14.7 diz `followRedirects: false` "nos dois Dio", mas só o autenticado define (o público nunca leva token).
4. Os PLANs ainda citam o caminho antigo do repo web no OneDrive.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-11-21
