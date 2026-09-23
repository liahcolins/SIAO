# SIAO — Sistema de Informação Accountability das Organizações Sociais

Aplicativo mobile desenvolvido no contexto do **Projeto Mais Gestão / UFMA**, com o objetivo de apoiar as Organizações da Sociedade Civil (OSC) na organização de receitas, despesas, comprovantes e relatórios, facilitando a conferência, o controle financeiro gerencial e a preparação para prestação de contas.

> **Projeto Mais Gestão / UFMA — 2026**

---

## Sobre o projeto

O **SIAO** é uma ferramenta de apoio à gestão financeira e à accountability das Organizações da Sociedade Civil.

A proposta é reunir em uma única aplicação informações que frequentemente ficam dispersas em planilhas, documentos, mensagens e arquivos, permitindo relacionar:

- origem dos recursos;
- receitas;
- despesas;
- fornecedores;
- comprovantes;
- movimentações;
- relatórios;
- informações utilizadas na conferência e prestação de contas.

O sistema busca proporcionar uma trilha mais organizada e verificável entre o recurso recebido, sua utilização e os documentos que comprovam cada lançamento.

### Importante

O SIAO **não é um aplicativo bancário**.

O sistema não realiza:

- PIX;
- transferências bancárias reais;
- pagamentos;
- liquidação de contas;
- emissão de boletos.

As movimentações registradas no sistema possuem finalidade **gerencial e documental**.

O SIAO também **não substitui a contabilidade formal**, a escrituração contábil por profissional habilitado, as obrigações fiscais, trabalhistas ou previdenciárias, nem sistemas oficiais exigidos por órgãos concedentes.

---

## Objetivos

O projeto busca apoiar cinco rotinas principais das OSC:

1. **Organização documental**  
   Associar registros financeiros aos respectivos documentos comprobatórios.

2. **Controle financeiro gerencial**  
   Acompanhar receitas, despesas, fontes e formas de movimentação.

3. **Conferência periódica**  
   Facilitar a revisão dos lançamentos por período e competência.

4. **Transparência**  
   Permitir identificar de onde vieram os recursos e como foram utilizados.

5. **Preparação para prestação de contas**  
   Organizar informações e comprovantes ao longo do ciclo da parceria.

---

## Funcionalidades previstas

O escopo completo do sistema contempla:

### Fornecedores

Cadastro das pessoas físicas ou jurídicas responsáveis por produtos ou serviços.

### Fontes de recursos

Cadastro de doadores, parceiros, programas, órgãos ou outras origens relacionadas às receitas.

### Receitas

Registro de:

- fonte do recurso;
- valor;
- data de recebimento;
- forma de recebimento;
- descrição;
- informações relacionadas à origem do recurso.

As formas inicialmente previstas incluem:

- cheque;
- depósito/PIX, apenas como registro informativo;
- dinheiro em espécie.

### Despesas

Registro de:

- tipo da despesa;
- valor;
- data;
- fonte relacionada;
- descrição;
- documento comprobatório;
- registro fotográfico do documento.

O lançamento de despesa deve permanecer associado ao respectivo documento para permitir conferência posterior.

### Relatórios

Consultas e relatórios por:

- receita;
- despesa;
- competência;
- mês;
- ano.

Os relatórios deverão permitir tanto uma visão sintética quanto o detalhamento dos lançamentos.

### Perfis de usuário

O sistema prevê três perfis principais:

- **Administrador** — responsável pelo gerenciamento da organização, usuários, validações e operações autorizadas;
- **Alimentador** — responsável pelo lançamento das informações;
- **Visualizador** — responsável pela consulta e conferência das informações sem realizar alterações.

---

## Etapas de desenvolvimento

O projeto está sendo desenvolvido de forma incremental.

### Etapa 1 — Administrador

Foco atual do desenvolvimento:

- estrutura inicial do aplicativo;
- identidade visual;
- dashboard do administrador;
- perfil do administrador;
- navegação principal;
- cadastro de transferência gerencial;
- persistência inicial dos registros;
- preparação da arquitetura para evolução das próximas etapas.

### Etapa 2 — Cadastros e receitas

Prevista para contemplar:

- fornecedores;
- fontes de recursos;
- cadastro de receitas;
- formas de recebimento.

### Etapa 3 — Despesas e comprovantes

Prevista para contemplar:

- cadastro de despesas;
- captura de comprovantes;
- registro fotográfico;
- fluxo de validação pelo administrador.

### Etapa 4 — Usuários e permissões

Prevista para contemplar:

- autenticação;
- perfis de acesso;
- administrador;
- alimentador;
- visualizador;
- solicitação e aprovação de acesso.

### Etapa 5 — Relatórios

Prevista para contemplar:

- relatórios gerenciais;
- filtros por modalidade;
- filtros por competência;
- visão sintética;
- detalhamento dos lançamentos.

### Etapa 6 — Sincronização e evolução

Prevista para contemplar:

- funcionamento offline;
- sincronização com a nuvem;
- tratamento de conflitos;
- segurança;
- backup;
- refinamentos de experiência do usuário.

---

## Etapa 1 — Estado atual

A primeira etapa prioriza o **perfil Administrador**, permitindo apresentar uma versão visual e funcional inicial do sistema.

Atualmente, a interface contempla:

- identificação da organização;
- identificação do perfil administrador;
- dashboard;
- resumo de receitas;
- resumo de despesas;
- saldo gerencial;
- acesso ao cadastro de transferência gerencial;
- acesso às áreas previstas para etapas posteriores;
- navegação entre dashboard, transferências e perfil.

A transferência registrada pelo sistema representa uma **movimentação gerencial interna**, não uma transferência bancária real.

---

## Tecnologias

O projeto está sendo desenvolvido utilizando:

- **Flutter**
- **Dart**
- **Android SDK**
- **GoRouter**
- **BLoC / Flutter BLoC**
- **Google Fonts**
- **SQLite / Drift** como parte da arquitetura planejada para persistência local e evolução do funcionamento offline.

A arquitetura está sendo estruturada para permitir a evolução gradual do aplicativo para Android e iOS.

---

## Plataforma

O aplicativo possui como objetivo atender:

- **Android**
- **iOS**

Durante o desenvolvimento atual, os testes Android podem ser realizados por meio de um dispositivo físico ou do **Android Emulator**.

---

## Estrutura do projeto

```text
SIAO/
├── android/
├── ios/
├── lib/
├── test/
├── web/
├── windows/
├── assets/
├── pubspec.yaml
├── README.md
├── implementation_plan.md
└── diretrizes_registro_alinhamento.md
```

---

## Executando o projeto

### Pré-requisitos

É necessário possuir:

- Flutter instalado;
- Android Studio;
- Android SDK;
- um dispositivo Android físico ou emulador.

Verifique a instalação do Flutter com:

```bash
flutter doctor
```

Verifique os dispositivos disponíveis:

```bash
flutter devices
```

### Instalar dependências

Na raiz do projeto:

```bash
flutter pub get
```

### Executar no Android

Com um dispositivo Android ou emulador conectado:

```bash
flutter run -d emulator-5554
```

O identificador do dispositivo pode variar. Para consultar os dispositivos disponíveis:

```bash
flutter devices
```

---

## Desenvolvimento

Durante o desenvolvimento, o projeto está sendo construído de forma incremental.

As novas funcionalidades devem ser implementadas de acordo com a etapa correspondente, evitando antecipar funcionalidades de etapas futuras sem necessidade.

As alterações devem seguir um padrão de commits baseado em **Conventional Commits**, utilizando prefixos como:

```text
feat
fix
chore
docs
refactor
test
```

Exemplos:

```text
feat(admin): implementar dashboard do administrador
feat(receitas): implementar cadastro de receitas
fix(profile): corrigir overflow horizontal no perfil admin
chore: atualizar configuração do projeto
docs: atualizar documentação da etapa 1
refactor(theme): reorganizar sistema de temas
```

---

## Documentação

O projeto possui documentos de apoio relacionados ao planejamento e ao alinhamento do desenvolvimento:

- `implementation_plan.md` — plano de implementação;
- `diretrizes_registro_alinhamento.md` — registro das diretrizes e decisões do alinhamento do projeto.

---

## Contexto do projeto

O SIAO parte de um protótipo anteriormente desenvolvido na plataforma Glide e está sendo evoluído para uma aplicação mobile estruturada, com possibilidade de expansão futura.

As necessidades relacionadas a funcionamento offline, sincronização, segurança, auditoria, compartilhamento de dados e futuras integrações serão desenvolvidas de forma modular, conforme as próximas etapas do projeto.

---

## Projeto Mais Gestão / UFMA

**SIAO — Sistema de Informação Accountability das Organizações Sociais**

Projeto desenvolvido no contexto do **Mais Gestão / Universidade Federal do Maranhão (UFMA)**.

**2026**