*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    FakerLibrary
Resource   massa.robot

*** Variables ***
@{USUARIOS_CRIADOS}
@{PRODUTOS_CRIADOS}

*** Keywords ***
Iniciar Sessao API
    Create Session    api    ${BASE_URL}

Gerar Usuario Fake
    ${nome}=     FakerLibrary.Name
    ${email}=    FakerLibrary.Email
    RETURN    ${nome}    ${email}

Criar Usuario
    [Arguments]    ${administrador}=${ADMIN_FLAG}
    ${nome}    ${email}=    Gerar Usuario Fake
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${PASSWORD}
    ...    administrador=${administrador}
    ${resp}=    POST On Session    api    /usuarios    json=${body}
    ${id}=    Set Variable    ${resp.json()}[_id]
    Append To List    ${USUARIOS_CRIADOS}    ${id}
    RETURN    ${resp}    ${email}

Criar Usuario Admin
    ${resp}    ${email}=    Criar Usuario    administrador=${ADMIN_FLAG}
    RETURN    ${resp}    ${email}

Criar Usuario Comum
    ${resp}    ${email}=    Criar Usuario    administrador=${USER_FLAG}
    RETURN    ${resp}    ${email}

Realizar Login
    [Arguments]    ${email}
    ${body}=    Create Dictionary
    ...    email=${email}
    ...    password=${PASSWORD}
    ${resp}=    POST On Session    api    /login    json=${body}
    RETURN    ${resp}

Obter Token
    [Arguments]    ${email}
    ${resp}=    Realizar Login    ${email}
    RETURN    ${resp.json()}[authorization]

Criar Produto
    [Arguments]    ${token}
    ${nome}=    FakerLibrary.Word
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${PRECO_VALIDO}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${QUANTIDADE_VALIDA}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    POST On Session    api    /produtos    json=${body}    headers=${headers}
    ${id}=    Set Variable    ${resp.json()}[_id]
    Append To List    ${PRODUTOS_CRIADOS}    ${id}
    RETURN    ${resp}

Deletar Usuario
    [Arguments]    ${id}
    DELETE On Session    api    /usuarios/${id}    expected_status=any

Deletar Produto
    [Arguments]    ${id}    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    DELETE On Session    api    /produtos/${id}    headers=${headers}    expected_status=any

Limpar Usuarios Criados
    FOR    ${id}    IN    @{USUARIOS_CRIADOS}
        Deletar Usuario    ${id}
    END
    ${vazio}=    Create List
    Set Global Variable    @{USUARIOS_CRIADOS}    @{vazio}

Limpar Produtos Criados
    [Arguments]    ${token}
    FOR    ${id}    IN    @{PRODUTOS_CRIADOS}
        Deletar Produto    ${id}    ${token}
    END
    ${vazio}=    Create List
    Set Global Variable    @{PRODUTOS_CRIADOS}    @{vazio}
