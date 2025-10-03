# Automação de Testes de API - ServeRest com Robot Framework

<p align="center">
  <img src="https://avatars.githubusercontent.com/u/574284?s=280&v=4" alt="Robot Framework Logo" width="230"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Framework-Robot%20Framework-green.svg" alt="Framework">
  <img src="https://img.shields.io/badge/Library-Requests-orange.svg" alt="Library">
  <img src="https://img.shields.io/badge/Python-3.x-blue.svg" alt="Python">
</p>

> Este repositório contém um projeto de automação de testes para a API **ServeRest**, desenvolvido utilizando **Robot Framework** e a biblioteca **RequestsLibrary**. O objetivo é validar os principais endpoints e regras de negócio da aplicação.

---

### 📖 Índice

* [Sobre o Projeto](#-sobre-o-projeto)
* [Estrutura de Arquivos](#-estrutura-de-arquivos)
* [Tecnologias Utilizadas](#-tecnologias-utilizadas)
* [Como Executar o Projeto](#-como-executar-o-projeto)
  * [Pré-requisitos](#-pré-requisitos)
  * [Instalação](#-instalação)
  * [Executando os Testes](#-executando-os-testes)
* [Cenários de Teste](#-cenários-de-teste)
* [Relatórios de Teste](#-relatórios-de-teste)

---

### 💡 Sobre o Projeto

Este projeto foi criado para automatizar a verificação dos serviços da API de testes [ServeRest](https://serverest.dev/). Ele simula as ações de um usuário, como login, cadastro de usuários e produtos, gerenciamento de carrinhos e validação de regras de negócio através de requisições HTTP.

As keywords foram estruturadas para serem reutilizáveis, facilitando a criação de novos testes e a manutenção do código.

---

### 📁 Estrutura de Arquivos

O projeto está organizado da seguinte forma para separar as responsabilidades:

```
SERVERESTAPI/
├── resources/
│   └── serverest_keywords.resource  # Arquivo com as keywords reutilizáveis
│
├── tests/
│   ├── serverest_tests_falha.robot    # Suíte de testes para cenários de falha
│   └── serverest_tests_sucesso.robot  # Suíte de testes para cenários de sucesso
│
├── .gitignore                     # Arquivo para ignorar arquivos não versionados
├── requirements.txt               # Dependências do projeto Python
├── README.md                      # Documentação do projeto
```

---

### 🛠️ Tecnologias Utilizadas

* **[Robot Framework](https://robotframework.org/):** Framework principal para a automação dos testes.
* **[Python](https://www.python.org/):** Linguagem de programação base para o Robot Framework.
* **[RequestsLibrary](https://robotframework.org/RequestsLibrary/):** Biblioteca do Robot para realizar requisições HTTP e testar APIs REST.

---

### 🚀 Como Executar o Projeto

Siga os passos abaixo para configurar e executar os testes em sua máquina local.

#### Pré-requisitos

Antes de começar, você precisa ter o **Python 3.x** e o **pip** instalados.

* [Instalar Python](https://www.python.org/downloads/)

#### Instalação

1.  **Clone o repositório:**
    ```sh
    git clone [https://github.com/SEU_USUARIO/NOME_DO_REPOSITORIO.git](https://github.com/SEU_USUARIO/NOME_DO_REPOSITORIO.git)
    ```

2.  **Navegue até o diretório do projeto:**
    ```sh
    cd SERVERESTAPI
    ```

3.  **Instale as dependências do projeto:**
    O arquivo `requirements.txt` contém todas as bibliotecas necessárias. Instale-as com o seguinte comando:
    ```sh
    pip install -r requirements.txt
    ```

#### Executando os Testes

Você pode executar todos os testes ou suítes específicas usando o comando `robot`.

1.  **Para executar todos os testes (sucesso e falha):**
    ```sh
    robot tests/
    ```

2.  **Para executar apenas os testes de sucesso:**
    ```sh
    robot tests/serverest_tests_sucesso.robot
    ```

3.  **Para executar apenas os testes de falha:**
    ```sh
    robot tests/serverest_tests_falha.robot
    ```

4.  **Para executar testes por tag (ex: apenas `SMOKE` tests):**
    ```sh
    robot -i SMOKE tests/
    ```

---

### 🧪 Cenários de Teste

O projeto cobre os seguintes fluxos e validações:

* ✅ **Usuários:** Criação, consulta e exclusão de usuários.
* ✅ **Autenticação:** Geração de token com credenciais válidas e inválidas.
* ✅ **Produtos:** Criação de produtos com e sem autorização.
* ✅ **Carrinhos:** Fluxo completo de criação de carrinho e conclusão de compra.
* ❌ **Testes Negativos:** Validação de mensagens de erro para e-mails duplicados, produtos duplicados, tokens inválidos, etc.

---

### 📊 Relatórios de Teste

Após cada execução, o Robot Framework gera automaticamente os seguintes relatórios na raiz do projeto:

* **`report.html`**: Um relatório de alto nível com gráficos e estatísticas gerais dos resultados.
* **`log.html`**: Um log detalhado com cada passo executado, requisições, respostas e validações. É ideal para depurar testes que falharam.


