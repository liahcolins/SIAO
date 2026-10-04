# Plano de Implementação - SIAO / Mais Gestão

## 1. Resumo do Projeto
O **SIAO (Sistema Integrado de Apoio Operacional) / Mais Gestão** é um aplicativo mobile de apoio à gestão financeira, prestação de contas e *accountability* de **Organizações da Sociedade Civil (OSC)**. O projeto é fruto da parceria com o Projeto Mais Gestão da Universidade Federal do Maranhão (UFMA), sob coordenação do Prof. Sérgio Roberto Pinto, projetado para evolução de um protótipo inicial (Glide App) para uma solução mobile robusta, offline-first e de **escala regional/nacional** (Maranhão - 7 polos, Pará, Piauí e demais estados).

> [!IMPORTANT]
> **Premissa Fundamental de Escopo:** O SIAO **NÃO É UM APLICATIVO BANCÁRIO**. Ele não executa PIX, transferências bancárias reais, emissão de boletos ou liquidação de contas. Trata-se de uma ferramenta de **registro gerencial, organização documental e prestação de contas**.
> 
> **O SIAO NÃO substitui a contabilidade formal:** O aplicativo não realiza escrituração contábil por contador habilitado, demonstrações contábeis oficiais, obrigações fiscais/trabalhistas/previdenciárias ou sistemas oficiais exigidos pelo concedente.

---

## 2. Objetivos e Pilares de Accountability
- **4 Pilares da Accountability:**
  1. *Transparência:* Mostrar a origem e a aplicação exata dos recursos.
  2. *Responsabilização:* Definir com clareza quem registra (Alimentador), quem confere/aprova (Administrador) e quem visualiza (Conselho Fiscal / Auditoria).
  3. *Conformidade:* Manter documentos e registros coerentes com termos de fomento, convênios e editais.
  4. *Decisão:* Usar relatórios sintéticos e detalhados para correção de rotas e comunicação de resultados.
- **Rotina Financeira em 5 Passos (Baseada no Protótipo UFMA):**
  `1. Cadastrar (Fontes e Fornecedores) → 2. Receber (Origem, valor, data) → 3. Pagar (Despesa e vínculo) → 4. Comprovar (Foto da NF/Recibo) → 5. Relatar (Filtros e detalhes)`

---

## 3. Requisitos Funcionais Consolidados (Baseados nos PDFs do Projeto)

### 3.1 Cadastros Básicos (Fornecedores e Fontes de Recursos)
- **Fornecedores (Despesas):** Cadastro de Pessoas Físicas (CPF) ou Jurídicas (CNPJ), Nome/Razão Social, Tipo de operação (Receita | Despesa).
- **Fontes de Recursos (Receitas):** Cadastro de doadores, parceiros, órgãos, programas, convênios ou outras origens vinculadas às receitas.
- **Formas de Repasse/Pagamento Iniciais:** Cheque, Depósito bancário / PIX (registro informativo) e Dinheiro em espécie.

### 3.2 Lançamento de Receitas (Ingressos)
- Campos confirmados: Tipo de Recurso / Fonte (dropdown), É um produto? (Sim/Não), Valor (R$), Data do recebimento, Fonte da receita vinculada, Referente ao ano base? (Sim/Não), Descrição da Receita.
- Visualização analítica por gráfico de origem e detalhamento cronológico.

### 3.3 Lançamento de Despesas (Saídas)
- Campos confirmados: Fonte da Despesa (origem da receita vinculada), Valor (R$), Data do gasto, Descrição da Despesa, Comprovante Anexo (Nota Fiscal / Cupom Fiscal / Recibo avulso via foto da câmera ou arquivo).
- **Vínculo Obrigatório:** Nenhuma despesa existe sem documento comprobatório e sem fonte de receita vinculada.

### 3.4 Lançamento de Transferências Gerenciais (Foco da Etapa 1)
- Registro interno de movimentação de saldos entre contas gerenciais da OSC (ex: Conta Bancária Vinculada → Caixa Interno/Fundo Fixo).
- Campos: Conta de Origem, Conta de Destino, Data, Valor (R$), Finalidade.
- **Aviso Ostensivo:** Banner permanente destacando *"Registro gerencial no SIAO - Não realiza transferência bancária real"*.

### 3.5 Diferenciação Conceitual: Receita (Ingresso) vs. Transferência Gerencial
- **Receita (Ingresso de Recursos - Etapa 2):** Representa a **entrada de novos recursos financeiros na OSC vindo do meio externo** (ex: repasses de termos de fomento, doações de parceiros, mensalidades de associados ou eventos/bazares). **Aumenta o patrimônio/saldo total da organização** e exige vínculo obrigatório com uma Fonte de Recursos.
- **Transferência Gerencial (Movimentação Interna - Etapa 1):** Representa o **remanejamento interno de saldos que a OSC já possui** entre suas contas de custódia (ex: transferência da Conta Bancária do Convênio para o Caixa Interno em Espécie/Fundo Fixo para despesas miúdas). **NÃO altera o saldo total da organização**, apenas altera a localização de custódia do recurso.
- **Premissa Geral:** Ambos os módulos são exclusivamente para escrituração gerencial e prestação de contas (o SIAO não realiza PIX nem movimentações bancárias reais).

### 3.6 Fluxo de Validação Documental pelo Administrador
- **Status do Lançamento:** `PENDENTE` → Análise pelo Administrador → `APROVADO` (entra na prestação de contas) ou `REJEITADO` (pendente de correção com motivo).

### 3.7 Relatórios e Consultas por Competência
- Filtros por **Modalidade** (Receita / Despesa) e por **Competência** (Mês-base de Janeiro a Dezembro + Ano).
- Visão sintética com totais e visão detalhada que responde a 5 perguntas:
  1. *Qual lançamento ocorreu?*
  2. *Qual fornecedor ou fonte está associado?*
  3. *Qual valor foi registrado?*
  4. *Qual data e competência foram usadas?*
  5. *Qual relação existe com o projeto/recurso?*

---

## 4. Arquitetura de Banco de Dados e Escala Híbrida (Nacional/Regional)

```
┌────────────────────────────────────────────────────────────────────────┐
│                   DISPOSITIVO MOBILE (ANDROID / iOS)                  │
│                                                                        │
│   ┌────────────────────────────────┐    ┌──────────────────────────┐   │
│   │ App Flutter (Clean Arch / BLoC)│ ──│ Fila Sync (UUID v4)      │   │
│   └───────────────┬────────────────┘    └────────────┬─────────────┘   │
│                   │                                  │                 │
│                   ▼                                  │                 │
│   ┌────────────────────────────────┐                 │                 │
│   │ Cache Local SQLite (Drift)     │ ◄───────────────┘                 │
│   │ (Dados da OSC do usuário)      │                                   │
│   └────────────────────────────────┘                                   │
└───────────────────┬────────────────────────────────────────────────────┘
                    │  (Sincronização Criptografada HTTPS / TLS 1.3)
                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│             NUVEM CENTRALIZADA (BANCO DE DADOS NACIONAL/REGIONAL)      │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │ Servidor Central de APIs (PostgreSQL + Supabase / PocketBase) │   │
│   │                                                                │   │
│   │ • Multi-Tenancy (Isolamento por RLS: organizacao_id)           │   │
│   │ • Banco Centralizador com Suporte a Milhões de Registros       │   │
│   │ • Cloud Storage para Comprovantes (S3 / Buckets Protegidos)    │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

- **PostgreSQL na Nuvem:** Guarda a base completa de todas as OSCs, garantindo escala nacional, auditoria e backups centrais.
- **SQLite no Celular (Drift):** Cache local temporário da OSC do usuário para viabilizar operação offline em municípios com internet instável.

---

## 5. Divisão em 6 Etapas do Projeto (1 a 2 semanas por etapa)

| Etapa | Escopo de Entrega | Duração Est. |
| :--- | :--- | :--- |
| **ETAPA 1** | **Fundação Flutter + Identity & Design System + Dashboard/Perfil Admin (baseado nos 4 cards da UFMA) + Cadastro de Transferência Gerencial** | 1 a 2 sem. |
| **ETAPA 2** | Módulo de Cadastros Base (Fornecedores PF/PJ + Fontes de Recursos + Ingressos de Receitas com Formas de Pagamento) | 1 a 2 sem. |
| **ETAPA 3** | Módulo de Despesas + Captura de Foto de Comprovantes + Esteira de Validação do Administrador (Pendente/Aprovado/Rejeitado) | 1 a 2 sem. |
| **ETAPA 4** | Autenticação Completa + RBAC (Perfis Administrador, Alimentador, Visualizador) + Aprovação de Solicitação de Acesso | 1 a 2 sem. |
| **ETAPA 5** | Relatórios Gerenciais (Síntese e Detalhamento) + Filtros por Competência (Mês-base/Ano) | 1 a 2 sem. |
| **ETAPA 6** | Sincronização Híbrida Completa (Nuvem + Cache Local) + Resolução de Conflitos + Segurança + Refinamento de UX | 1 a 2 sem. |

---

## 6. Escopo Específico da ETAPA 1
- Estrutura inicial Flutter com Clean Architecture e GoRouter.
- Design System institucional completo (cores, tipografia, formulários monetários com máscara R$).
- **Dashboard do Administrador:** 4 cards visuais de tarefas centrais (Fornecedores/Fontes, Receitas, Despesas, Relatórios) inspirados no protótipo original da UFMA, ajustados para o perfil Administrador.
- **Perfil do Administrador:** Dados do gestor e da OSC.
- **Fluxo de Cadastro de Transferência Gerencial:**
  - Formularia com validação de campos.
  - Seleção de Conta Origem e Destino.
  - Data, Valor em R$, Descrição/Finalidade.
  - **Aviso Ostensivo de "NÃO É APLICATIVO BANCÁRIO"**.
  - Persistência em banco local SQLite de rascunho.
  - Tela de confirmação e listagem das movimentações gravadas.

---

## 7. Critérios de Aceitação da ETAPA 1
- Aplicativo compilando e rodando em simuladores/aparelhos **Android** e **iOS**.
- Interface moderna, navegável, fluida e 100% em português do Brasil.
- Fluxo de transferência gerencial validando campos e gravando registros locais.
- Sinalização clara e visível de que o app não efetua PIX nem pagamentos reais.

---

## 8. Decisões que Precisam da Sua Autorização
1. Aprovação da estrutura de campos e fluxo consolidado dos PDFs.
2. Aprovação da escolha do **Flutter + Dart** (100% Gratuito / Open-Source) e **Arquitetura Híbrida**.
3. Autorização para iniciar o desenvolvimento da **Etapa 1**.
