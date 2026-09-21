# Phase 1: Localização, Escolha de Cidade e Contrato da API - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-21
**Phase:** 1-Localização, Escolha de Cidade e Contrato da API
**Areas discussed:** Contrato da API, Fluxo de permissão, Match da cidade, Lista fixa de cidades

---

## Contrato da API (API-01)

### Envelope de paginação
| Option | Description | Selected |
|--------|-------------|----------|
| Cursor | DRF CursorPagination `{next, previous, results}`; imune a duplicar/embaralhar; sem count | ✓ |
| PageNumber | `{count, next, previous, results}` com page/page_size; dá total, risco de embaralho | |
| LimitOffset | `{count, next, previous, results}` com limit/offset; mesmo risco | |

### Campos ainda inexistentes (natureza/quartos/suítes/vagas/área)
| Option | Description | Selected |
|--------|-------------|----------|
| Congelar completo | Contrato inteiro com tipologia marcada "pendente E2"; APP02/03 buildam contra fixtures | ✓ |
| Só o que existe | Congela só campos atuais; aditivo depois | |
| Você decide | Delegar à pesquisa/planejamento | |

### Formato e local do documento
| Option | Description | Selected |
|--------|-------------|----------|
| Markdown + JSON exemplo | Doc legível + JSON (fixture do mock), nos dois repos | ✓ |
| OpenAPI/schema | YAML formal e checkable, porém cerimonioso | |
| Só Markdown no .planning | Só no repo do app, sem JSON | |

### Idioma dos campos/params
| Option | Description | Selected |
|--------|-------------|----------|
| Português snake_case | cidade, preco_min, quartos_min, natureza... coerente com o código PT | ✓ |
| Inglês snake_case | city, price_min... destoa do resto | |
| Você decide | Seguir o padrão mais consistente | |

**Notes:** Contexto-chave: critério de sucesso das Fases 2/3 exige scroll infinito "sem cards
duplicados ou embaralhados" — o que motivou cursor pagination apesar de perder o count.

---

## Fluxo de permissão de localização

### Como pedir na 1ª abertura
| Option | Description | Selected |
|--------|-------------|----------|
| Priming antes | Tela curta explicando + CTA que dispara o prompt do OS | ✓ |
| Pedir direto | Prompt nativo assim que abre | |

### Desfecho deniedForever
| Option | Description | Selected |
|--------|-------------|----------|
| Lista + CTA Ajustes | Cai na lista + botão para abrir configurações do sistema | ✓ |
| Só a lista | Cai na lista sem atalho | |

### Estrutura de UI dos 5 desfechos
| Option | Description | Selected |
|--------|-------------|----------|
| Mesma tela, msg/CTA variando | Uma tela; cada desfecho é um estado (sealed/enum) | ✓ |
| Telas/widgets distintos | Widget próprio por desfecho | |

### Reabertura com cidade guardada
| Option | Description | Selected |
|--------|-------------|----------|
| Vai direto pra guardada | Abre sem re-pedir GPS; localização só na 1ª vez ou ao trocar | ✓ |
| Revalida localização sempre | Detecta e sugere trocar a cada abertura | |

---

## Match da cidade detectada

### Estratégia de casamento
| Option | Description | Selected |
|--------|-------------|----------|
| Nome + UF normalizado | Normaliza acentos/caixa/espaços; casa com unique(nome,uf) | ✓ |
| Só nome do município | Sem UF; risco de homônimas | |
| Você decide | Delegar | |

### Cidade atendida
| Option | Description | Selected |
|--------|-------------|----------|
| Entra direto | Abre a vitrine, nome no topo, trocável | ✓ |
| Confirma antes | "Detectamos X, é essa?" | |

### Cidade não atendida
| Option | Description | Selected |
|--------|-------------|----------|
| Lista + aviso | Fallback com "ainda não atendemos [Cidade]" | ✓ |
| Lista silenciosa | Fallback sem menção | |

### Falha no geocoding
| Option | Description | Selected |
|--------|-------------|----------|
| Cai na lista | Desfecho explícito, sem tela de erro | ✓ |
| Retry + depois lista | Tenta uma vez, depois lista | |

---

## Lista fixa de cidades (Fase 1)

### Formato
| Option | Description | Selected |
|--------|-------------|----------|
| Asset JSON espelhando /cidades | assets/cidades.json com a forma do contrato | ✓ |
| Hardcoded em Dart | const List<Cidade> no código | |

### Acesso / DI
| Option | Description | Selected |
|--------|-------------|----------|
| Mesma interface, impl local | CidadeRepository local → remota por DI na Fase 2 | ✓ |
| Acesso direto agora | Lê o asset no Cubit, refatora depois | |

### O que persistir
| Option | Description | Selected |
|--------|-------------|----------|
| nome + uf (chave natural) | Estável na transição fixa→API; casa com unique(nome,uf) | ✓ |
| id do contrato | Alinhado à API, exige semear ids reais | |
| Você decide | Delegar | |

### Conteúdo da lista
| Option | Description | Selected |
|--------|-------------|----------|
| Espelhar cidades já no banco | Gerar JSON das Cidades cadastradas na API | ✓ |
| Lista curada manual | Lista curta à mão | |
| Você decide | Delegar | |

---

## Claude's Discretion

Nenhuma — o usuário respondeu todas as áreas explicitamente (nenhum "você decide" selecionado).

## Deferred Ideas

- `GET /cidades` real via API → Fase 2 (API-02/VIT-06).
- Endpoint real `/imoveis` + troca do DataSource por DI → Fase 4 (API-03).
- Result-count "Ver N imóveis" → v2 (API-05).
- Tipologia do imóvel no model Django (natureza/quartos/suítes/vagas/área) → dependência E2;
  nesta fase só congelada no contrato.

## Nota de auditoria

Achado durante o scout: o model `Imovel` **já existe** em `../imoveis-aqui/Web/imoveis/models.py`,
contrariando o PROJECT.md. Registrado no CONTEXT.md (code_context) para a auditoria de API-01.
