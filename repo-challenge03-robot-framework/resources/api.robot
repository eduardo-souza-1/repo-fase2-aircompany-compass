*** Settings ***
Documentation    Keywords da API para testes do ServeRest
Library          RequestsLibrary
Library          Collections
Library          FakerLibrary

*** Variables ***
${BASE_URL}              https://serverest.dev
${SESSION}               serverest
@{USUARIOS_CRIADOS}
@{PRODUTOS_CRIADOS}

*** Keywords ***
# ===== SETUP E TEARDOWN =====

Setup API Session
    [Documentation]    Inicializa sessão da API
    Create Session    ${SESSION}    ${BASE_URL}
    Set Suite Variable    @{USUARIOS_CRIADOS}    @{EMPTY}
    Set Suite Variable    @{PRODUTOS_CRIADOS}    @{EMPTY}

Cleanup Resources
    [Documentation]    Deleta todos os recursos criados
    FOR    ${user_id}    IN    @{USUARIOS_CRIADOS}
        Run Keyword And Ignore Error    DELETE On Session    ${SESSION}    /usuarios/${user_id}    expected_status=any
    END
    FOR    ${product_id}    IN    @{PRODUTOS_CRIADOS}
        Run Keyword And Ignore Error    DELETE On Session    ${SESSION}    /produtos/${product_id}    expected_status=any
    END
    Delete All Sessions

# ===== OPERAÇÕES DE USUÁRIO =====

Create User
    [Documentation]    Cria um novo usuário e registra para limpeza
    [Arguments]    ${nome}    ${email}    ${senha}=senha@123    ${admin}=true
    ${payload}=    Create Dictionary    nome=${nome}    email=${email}    password=${senha}    administrador=${admin}
    ${response}=    POST On Session    ${SESSION}    /usuarios    json=${payload}    expected_status=201
    ${json}=    Set Variable    ${response.json()}
    ${user_id}=    Set Variable    ${json}[_id]
    Append To List    ${USUARIOS_CRIADOS}    ${user_id}
    RETURN    ${response}

Create Random User
    [Documentation]    Cria usuário com dados aleatórios e retorna o email
    [Arguments]    ${admin}=true
    ${nome}=    FakerLibrary.Name
    ${email}=    FakerLibrary.Email
    ${response}=    Create User    ${nome}    ${email}    admin=${admin}
    RETURN    ${email}

Login
    [Documentation]    Autentica usuário e retorna o token
    [Arguments]    ${email}    ${senha}=senha@123
    ${payload}=    Create Dictionary    email=${email}    password=${senha}
    ${response}=    POST On Session    ${SESSION}    /login    json=${payload}    expected_status=200
    ${json}=    Set Variable    ${response.json()}
    ${token}=    Set Variable    ${json}[authorization]
    RETURN    ${token}

# ===== OPERAÇÕES DE PRODUTO =====

Create Product
    [Documentation]    Cria um novo produto e registra para limpeza
    [Arguments]    ${token}    ${nome}    ${preco}    ${descricao}    ${quantidade}
    ${payload}=    Create Dictionary    nome=${nome}    preco=${preco}    descricao=${descricao}    quantidade=${quantidade}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    ${SESSION}    /produtos    json=${payload}    headers=${headers}    expected_status=201
    ${json}=    Set Variable    ${response.json()}
    ${product_id}=    Set Variable    ${json}[_id]
    Append To List    ${PRODUTOS_CRIADOS}    ${product_id}
    RETURN    ${response}

Create Random Product
    [Documentation]    Cria produto com nome aleatório
    [Arguments]    ${token}    ${preco}=100    ${quantidade}=10
    ${nome}=    FakerLibrary.Word
    ${response}=    Create Product    ${token}    ${nome}    ${preco}    Produto de teste    ${quantidade}
    RETURN    ${response}

# ===== OPERAÇÕES DE CARRINHO =====

Create Cart
    [Documentation]    Adiciona produto ao carrinho
    [Arguments]    ${token}    ${product_id}    ${quantidade}=1
    ${item}=    Create Dictionary    idProduto=${product_id}    quantidade=${quantidade}
    ${items_list}=    Create List    ${item}
    ${payload}=    Create Dictionary    produtos=${items_list}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    ${SESSION}    /carrinhos    json=${payload}    headers=${headers}    expected_status=201
    RETURN    ${response}

Complete Purchase
    [Documentation]    Finaliza a compra do carrinho
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    DELETE On Session    ${SESSION}    /carrinhos/concluir-compra    headers=${headers}    expected_status=200
    RETURN    ${response}

# ===== VALIDAÇÕES =====

Validate Status Code
    [Documentation]    Valida o status code da resposta
    [Arguments]    ${response}    ${status_esperado}
    Status Should Be    ${status_esperado}    ${response}

Validate Response Contains
    [Documentation]    Valida que a resposta contém o campo especificado
    [Arguments]    ${response}    ${campo}
    Dictionary Should Contain Key    ${response.json()}    ${campo}

Validate Message Contains
    [Documentation]    Valida que a mensagem da resposta contém o texto esperado
    [Arguments]    ${response}    ${texto_esperado}
    ${json}=    Set Variable    ${response.json()}
    ${message}=    Set Variable    ${json}[message]
    Should Contain    ${message}    ${texto_esperado}

Validate JWT Token Format
    [Documentation]    Valida que o token segue o formato JWT (3 partes separadas por ponto)
    [Arguments]    ${token}
    ${token_limpo}=    Remove String    ${token}    Bearer${SPACE}
    ${partes}=    Split String    ${token_limpo}    .
    ${quantidade}=    Get Length    ${partes}
    Should Be Equal As Numbers    ${quantidade}    3
    FOR    ${parte}    IN    @{partes}
        Should Not Be Empty    ${parte}
    END
