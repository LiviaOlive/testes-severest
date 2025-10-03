*** Settings ***
Resource          ../resources/serverest_keywords.resource
Suite Setup       Start API Session

*** Variables ***
${ADMIN_EMAIL}       admin-hdmqwbhw@qa.com
${ADMIN_PASSWORD}    senhaforte

*** Test Cases ***
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