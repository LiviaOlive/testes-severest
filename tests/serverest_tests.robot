*** Settings ***
Resource          ../resources/serverest_keywords.resource
Suite Setup       Start API Session

*** Variables ***
${ADMIN_EMAIL}       admin-hdmqwbhw@qa.com
${ADMIN_PASSWORD}    senhaforte

*** Test Cases ***
Cenário 00: Criar um Novo Administrador
    [Tags]    SETUP
    ${random_name}=       Generate Random String    8    [LOWER]
    ${new_admin_email}=   Set Variable    admin-${random_name}@qa.com
    ${new_admin_pass}=    Set Variable    senhaforte
    
    Create New User
    ...    Admin ${random_name}
    ...    ${new_admin_email}
    ...    ${new_admin_pass}
    ...    true
    
    Log To Console    \n\n--- NOVAS CREDENCIAIS DE ADMIN ---
    Log To Console    Email: ${new_admin_email}
    Log To Console    Senha: ${new_admin_pass}
    Log To Console    ------------------------------------\n

Cenário 01: [GET] Verificar se a API está online
    [Tags]    GET    SMOKE
    Health Check

Cenário 02: [POST e GET] Criar e consultar um novo usuário
    [Tags]    POST    GET    USUARIOS
    ${random_name}=       Generate Random String    8    [LOWER]
    ${random_email}=      Set Variable    ${random_name}@qa.com
    
    ${user_id}=    Create New User
    ...    Livia ${random_name}
    ...    ${random_email}
    ...    teste123
    ...    true

    ${response}=    Get User By ID    ${user_id}
    Should Be Equal As Strings    ${response}[nome]    Livia ${random_name}
    Should Be Equal As Strings    ${response}[email]    ${random_email}

Cenário 03: [DELETE] Deletar um usuário existente
    [Tags]    DELETE    AUTH    USUARIOS
    # Pré-condição: Criar um usuário para deletar
    ${random_name}=       Generate Random String    8    [LOWER]
    ${random_email}=      Set Variable    ${random_name}@qa.com
    ${user_to_delete_id}=    Create New User
    ...    Usuario Para Deletar
    ...    ${random_email}
    ...    senhaforte
    ...    false

    # Ação Principal
    ${token}=    Get Auth Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Delete User    ${user_to_delete_id}    ${token}

    # Validação: Tentar buscar o usuário deletado e esperar um erro 400
    Run Keyword And Expect Error
    ...    *HTTPError: 400 Client Error*
    ...    Get User By ID    ${user_to_delete_id}

Cenário 04: [POST] Criar um novo produto com autorização
    [Tags]    POST    AUTH    PRODUTOS
    ${token}=    Get Auth Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    ${random_product}=    Generate Random String    10
    
    ${product_id}=    Create New Product
    ...    ${token}
    ...    ${random_product}
    ...    250
    ...    Descrição do produto novo
    ...    100
    
    Should Not Be Empty    ${product_id}

Cenário 05: [POST] Tentar criar produto sem autorização
    [Tags]    NEGATIVE    AUTH    PRODUTOS
    ${random_product}=    Generate Random String    10
    
    # Ação Principal: Tentar criar o produto com um token vazio
    Run Keyword And Expect Error
    ...    *HTTPError: 401 Client Error*
    ...    Create New Product
    ...    ${EMPTY}
    ...    ${random_product}
    ...    300
    ...    Produto sem token
    ...    50

Cenário 06: [POST] Tentar autenticar com credenciais inválidas
    [Tags]    NEGATIVE    AUTH
    Run Keyword And Expect Error
    ...    *HTTPError: 401 Client Error*
    ...    Get Auth Token    email@invalido.com    senhaerrada 

Cenário 07: [POST] Tentar criar usuário com e-mail do Gmail (ESPERADO FALHAR)
    [Tags]    NEGATIVE    RULES
    # Este teste vai FALHAR porque a API permite o cadastro, mas o teste espera um erro.
    ${random_name}=       Generate Random String    8    [LOWER]
    ${gmail_email}=       Set Variable    fail-${random_name}@gmail.com

    Run Keyword And Expect Error
    ...    *HTTPError: 400 Client Error*
    ...    Create New User
    ...    Usuario Gmail
    ...    ${gmail_email}
    ...    senha123
    ...    false

Cenário 08: [POST] Tentar criar usuário com e-mail do Hotmail (ESPERADO FALHAR)
    [Tags]    NEGATIVE    RULES
    # Este teste vai FALHAR porque a API permite o cadastro, mas o teste espera um erro.
    ${random_name}=       Generate Random String    8    [LOWER]
    ${hotmail_email}=     Set Variable    fail-${random_name}@hotmail.com

    Run Keyword And Expect Error
    ...    *HTTPError: 400 Client Error*
    ...    Create New User
    ...    Usuario Hotmail
    ...    ${hotmail_email}
    ...    senha123
    ...    false

Cenário 09: [POST] Tentar criar usuário com senha menor que 5 caracteres (ESPERADO FALHAR)
    [Tags]    NEGATIVE    RULES
    # Este teste vai FALHAR porque a API permite senhas curtas, mas o teste espera um erro.
    ${random_name}=       Generate Random String    8    [LOWER]
    ${short_pass_email}=  Set Variable    shortpass-${random_name}@qa.com

    Run Keyword And Expect Error
    ...    *HTTPError: 400 Client Error*
    ...    Create New User
    ...    Usuario Senha Curta
    ...    ${short_pass_email}
    ...    1234
    ...    false

Cenário 10: [POST] Tentar criar usuário com senha maior que 10 caracteres (ESPERADO FALHAR)
    [Tags]    NEGATIVE    RULES
    # Este teste vai FALHAR porque a API permite senhas longas, mas o teste espera um erro.
    ${random_name}=       Generate Random String    8    [LOWER]
    ${long_pass_email}=   Set Variable    longpass-${random_name}@qa.com

    Run Keyword And Expect Error
    ...    *HTTPError: 400 Client Error*
    ...    Create New User
    ...    Usuario Senha Longa
    ...    ${long_pass_email}
    ...    12345678901
    ...    false

Cenário 11: [GET] Tentar buscar produtos sem autenticação (ESPERADO FALHAR)
    [Tags]    NEGATIVE    RULES    AUTH
    # Este teste vai FALHAR porque a API permite a busca pública, mas o teste espera um erro de autorização.
    Run Keyword And Expect Error
    ...    *HTTPError: 401 Client Error*
    ...    Get All Products

Cenário 12: [POST] Tentar criar usuário com e-mail duplicado
    [Tags]    NEGATIVE    RULES    USUARIOS
    # Pré-condição: Criar um usuário para garantir que o e-mail exista
    ${random_name}=       Generate Random String    8    [LOWER]
    ${duplicate_email}=   Set Variable    duplicado-${random_name}@qa.com
    Create New User
    ...    Usuario Original
    ...    ${duplicate_email}
    ...    senha123
    ...    false

    # Ação Principal: Tentar criar outro usuário com o mesmo e-mail
    Attempt to Create a Duplicate User
    ...    Usuario Duplicado
    ...    ${duplicate_email}
    ...    outrasenha
    ...    false

Cenário 13: [POST] Tentar criar produto com nome duplicado
    [Tags]    NEGATIVE    RULES    PRODUTOS
    ${token}=    Get Auth Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    ${product_name}=    Generate Random String    12

    # Pré-condição: Criar um produto para garantir que o nome exista
    Create New Product
    ...    ${token}
    ...    ${product_name}
    ...    10
    ...    Produto Original
    ...    10

    # Ação Principal: Tentar criar outro produto com o mesmo nome
    Attempt to Create a Duplicate Product
    ...    ${token}
    ...    ${product_name}
    ...    20
    ...    Produto Duplicado
    ...    20

Cenário 14: [Fluxo Carrinho] Criar carrinho, concluir e cancelar compra
    [Tags]    FLUXO    CARRINHOS
    # --- Setup do Teste ---
    # 1. Obter token de um usuário comum (não admin)
    ${random_name}=       Generate Random String    8
    ${user_email}=        Set Variable    user-${random_name}@qa.com
    Create New User    Usuario Comum    ${user_email}    senha123    false
    ${token}=    Get Auth Token    ${user_email}    senha123

    # 2. Obter token de admin para criar um produto
    ${admin_token}=    Get Auth Token    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    ${product_name}=    Generate Random String    10
    ${product_id}=    Create New Product    ${admin_token}    ${product_name}    150    Desc    50

    # --- Ações Principais ---
    # 1. Criar um carrinho com o produto
    ${cart_id}=    Create Cart    ${token}    ${product_id}    2
    Should Not Be Empty    ${cart_id}

    # 2. Concluir a compra (isso esvazia e deleta o carrinho)
    Conclude Purchase    ${token}

    # 3. Tentar cancelar uma compra que não existe mais (deve falhar)
    Run Keyword And Expect Error
    ...    *HTTPError: 404 Client Error*
    ...    Cancel Purchase    ${token}