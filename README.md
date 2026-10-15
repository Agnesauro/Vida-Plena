# 🏥 Vida Plena - Banco de Dados Relacional (MySQL)

Este repositório contém a modelagem, criação e povoamento do banco de dados relacional para a clínica médica **Vida Plena**. O sistema foi projetado para gerenciar todas as operações essenciais da clínica, desde o cadastro de pacientes, médicos e salas, até o agendamento de consultas, emissão de prescrições, solicitações de exames e gestão financeira.

---

## 📌 Sumário

- [Características do Sistema](#-características-do-sistema)
- [Estrutura do Banco de Dados](#-estrutura-do-banco-de-dados)
- [Regras de Negócio e Restrições](#-regras-de-negócio-e-restrições)
- [Como Executar](#-como-executar)
- [Estrutura dos Dados Iniciais](#-estrutura-dos-dados-iniciais)

---

## 🛠️ Características do Sistema

* **SGBD:** MySQL / MariaDB
* **Engine:** InnoDB (Garantia de transações ACID e suporte a Chaves Estrangeiras)
* **Charset:** `utf8mb4` com collation `utf8mb4_unicode_ci` (Suporte completo a caracteres especiais e acentuação)

---

## 🗂️ Estrutura do Banco de Dados

O banco de dados é composto pelas seguintes tabelas interligadas:

1. **`consultorios`**: Cadastro das salas e andares físicos da clínica.
2. **`convenios`**: Planos de saúde parceiros e suas taxas de cobertura.
3. **`especialidades`**: Áreas médicas oferecidas (ex: Cardiologia, Pediatria).
4. **`exames`**: Catálogo de exames clínicos, prazos, categorias e valores base.
5. **`pacientes`**: Dados cadastrais dos pacientes, incluindo endereço completo.
6. **`paciente_telefones`**: Telefones adicionais associados aos pacientes (Relacionamento 1:N).
7. **`contatos_emergencia`**: Informações de contatos de emergência vinculados aos pacientes.
8. **`convenio_pacientes`**: Vínculos de convênios dos pacientes (Titular, Dependente, etc.) e números de carteirinha.
9. **`funcionarios`**: Equipe administrativa e suporte, com suporte a hierarquia de supervisão (Auto-relacionamento).
10. **`medicos`**: Corpo médico vinculado aos consultórios.
11. **`medico_especialidades`**: Associação N:M entre médicos e suas especialidades.
12. **`consultas`**: Agendamentos e histórico de consultas médicas.
13. **`prescricoes`**: Receitas e orientações médicas geradas durante uma consulta.
14. **`solicitacoes_exame`**: Exames solicitados durante uma consulta médica.
15. **`itens_exame`**: Detalhamento dos exames de uma solicitação, com status, prazos e resultados.
16. **`pagamentos`**: Registro financeiro de consultas ou exames (formas de pagamento, convênios e status).

---

## 🛡️ Regras de Negócio e Restrições

O script inclui diversas travas de integridade (`CHECK` e `UNIQUE`) para garantir a consistência dos dados:

* **Horários Médicos e de Pacientes (`uq_medico_horario` e `uq_paciente_horario`):** Um médico ou paciente não pode ter duas consultas no mesmo horário exato.
* **Consultórios Únicos (`uq_consultorio_sala`):** Combinação única de número de sala e andar.
* **Formato de Documentos (`chk_convenio_cnpj`, `chk_paciente_cpf`, `chk_func_cpf`):** Validação via expressão regular (`REGEXP`) garantindo 14 dígitos numéricos para CNPJ e 11 para CPF.
* **Valores e Prazos Positivos:** Restrições garantem que salários, valores de exames, pagamentos e prazos não sejam negativos.
* **Integridade do Status dos Exames (`chk_item_realizado`):** A data de realização e o resultado de um exame só podem ser preenchidos se o status for marcado como `Realizado`.
* **Origem de Pagamento (`chk_pag_origem`):** Um registro de pagamento vincula-se **exclusivamente** a uma consulta ou a uma solicitação de exame (nunca a ambos simultaneamente).

---

## 🚀 Como Executar

### Pré-requisitos

* MySQL Server 8.0+ ou MariaDB 10.5+ instalado.
* Cliente SQL de sua preferência (MySQL Workbench, DBeaver, VS Code ou Terminal).

### Passo a Passo

1. **Clonar o Repositório**:
   ```bash
   git clone https://github.com/Agnesauro/Vida-Plena.git
   cd Vida-Plena
   ```

2. **Executar via Linha de Comando (Terminal/CMD):**
   ```bash
   mysql -u seu_usuario -p < db_vida_plena.sql
   ```

3. **Executar via Interface Gráfica (DBeaver / MySQL Workbench):**
   * Abra o seu cliente SQL.
   * Abra o arquivo `db_vida_plena.sql`.
   * Execute todo o script (`Ctrl + Shift + Enter` ou `F5`).

---

## 📊 Estrutura dos Dados Iniciais

O script já conta com inserções de dados de teste (*seeders*) para validar a estrutura:

* **4** Consultórios.
* **3** Convênios cadastrados.
* **5** Especialidades médicas.
* **4** Exames de catálogo.
* **5** Pacientes e seus respectivos telefones/contatos.
* **4** Funcionários administrativos.
* **4** Médicos especialistas.
* Consultas, prescrições, exames solicitados e lançamentos financeiros prontos para consulta.