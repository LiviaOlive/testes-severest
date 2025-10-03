*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Variables ***
${BASE_URL}          https://serverest.dev
${ADMIN_EMAIL}       admin-hdmqwbhw@qa.com
${ADMIN_PASSWORD}    senhaforte


*** Keywords ***
# --- SETUP E HEALTH CHECK ---
Start API Session
    Create Session    serverest    ${BASE_URL}

Health Check
    ${response}=    GET On Session    serverest    /
    Status Should Be    200    ${response}

# --- AUTENTICAÇÃO ---
Get Auth Token
    [Arguments]    ${email}    ${password}
    &{credentials}=    Create Dictionary    email=${email}    password=${password}
    ${response}=    POST On Session    serverest    /login    json=${credentials}
    Status Should Be    200    ${response}
    ${token}=    Set Variable    ${response.json()}[authorization]
    Log    Token recebido: ${token}
    RETURN    ${token}

# --- KEYWORDS DE USUÁRIOS ---
Create New User
    [Arguments]    ${name}    ${email}    ${password}    ${is_admin}
    &{payload}=    Create Dictionary
    ...    nome=${name}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${is_admin}

    ${response}=    POST On Session    serverest    /usuarios    json=${payload}
    Status Should Be    201    ${response}
    Log    Usuário criado com sucesso: ${response.json()}
    RETURN    ${response.json()}[_id]

Get User By ID
    [Arguments]    ${user_id}
    ${response}=    GET On Session    serverest    /usuarios/${user_id}
    Status Should Be    200    ${response}
    RETURN    ${response.json()}

Delete User
    [Arguments]    ${user_id}    ${token}
    &{headers}=    Create Dictionary    Authorization=${token}
    ${response}=    DELETE On Session    serverest    /usuarios/${user_id}    headers=${headers}
    Status Should Be    200    ${response}
    RETURN    ${response.json()}

# --- KEYWORDS DE PRODUTOS ---
Create New Product
    [Arguments]    ${token}    ${product_name}    ${price}    ${description}    ${quantity}
    &{headers}=    Create Dictionary    Authorization=${token}
    &{payload}=    Create Dictionary
    ...    nome=${product_name}
    ...    preco=${price}
    ...    descricao=${description}
    ...    quantidade=${quantity}

    ${response}=    POST On Session    serverest    /produtos    headers=${headers}    json=${payload}
    Status Should Be    201    ${response}
    Log    Produto criado com sucesso: ${response.json()}
    RETURN    ${response.json()}[_id]

Attempt to Create a User and Expect Failure
    [Arguments]    ${name}    ${email}    ${password}    ${is_admin}    ${expected_error_message}
    &{payload}=    Create Dictionary
    ...    nome=${name}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${is_admin}

    ${response}=    POST On Session    serverest    /usuarios    json=${payload}    expected_status=400
    Should Be Equal As Strings    ${response.json()}[message]    ${expected_error_message}

Get All Products
    [Arguments]    ${token}=${EMPTY}
    &{headers}=    Create Dictionary
    Run Keyword If    '${token}' != '${EMPTY}'    Set To Dictionary    ${headers}    Authorization=${token}
    
    ${response}=    GET On Session    serverest    /produtos    headers=${headers}
    Status Should Be    200    ${response}
    RETURN    ${response.json()}

Attempt to Create a Duplicate User
    [Arguments]    ${name}    ${email}    ${password}    ${is_admin}
    &{payload}=    Create Dictionary
    ...    nome=${name}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${is_admin}

    ${response}=    POST On Session    serverest    /usuarios    json=${payload}    expected_status=400
    Should Be Equal As Strings    ${response.json()}[message]    Este email já está sendo usado

Attempt to Create a Duplicate Product
    [Arguments]    ${token}    ${product_name}    ${price}    ${description}    ${quantity}
    &{headers}=    Create Dictionary    Authorization=${token}
    &{payload}=    Create Dictionary
    ...    nome=${product_name}
    ...    preco=${price}
    ...    descricao=${description}
    ...    quantidade=${quantity}

    ${response}=    POST On Session    serverest    /produtos    headers=${headers}    json=${payload}    expected_status=400
    Should Be Equal As Strings    ${response.json()}[message]    Já existe produto com esse nome

Create Cart
    [Arguments]    ${token}    ${product_id}    ${quantity}
    &{headers}=    Create Dictionary    Authorization=${token}
    
    ${product_list}=    Create List    
    
    &{product_item}=    Create Dictionary    idProduto=${product_id}    quantidade=${quantity}
    Append To List    ${product_list}    ${product_item}
    &{payload}=    Create Dictionary    produtos=${product_list}

    ${response}=    POST On Session    serverest    /carrinhos    headers=${headers}    json=${payload}
    Status Should Be    201    ${response}
    RETURN    ${response.json()}[_id]

Conclude Purchase
    [Arguments]    ${token}
    &{headers}=    Create Dictionary    Authorization=${token}
    ${response}=    DELETE On Session    serverest    /carrinhos/concluir-compra    headers=${headers}
    Status Should Be    200    ${response}

Cancel Purchase
    [Arguments]    ${token}
    &{headers}=    Create Dictionary    Authorization=${token}
    ${response}=    DELETE On Session    serverest    /carrinhos/cancelar-compra    headers=${headers}
    Status Should Be    200    ${response}