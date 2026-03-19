*** Settings ***
Resource    ../../resources/api_keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados

*** Test Cases ***
Usuario com email duplicado
    ${resp1}    ${email}=    Criar Usuario Admin
    Status Should Be    201    ${resp1}

    ${body}=    Create Dictionary
    ...    nome=Outro Nome
    ...    email=${email}
    ...    password=${PASSWORD}
    ...    administrador=${ADMIN_FLAG}

    ${resp2}=    POST On Session    api    /usuarios    json=${body}    expected_status=400
    Status Should Be    400    ${resp2}

Usuario com script malicioso
    [Documentation]    a api aceita scripts no campo nome e retorna 201.
    ...                este teste serve para evidenciar a vulnerabilidade.
    ${nome_xss}=    Set Variable    <script>alert(1)</script>
    ${email_unico}=    FakerLibrary.Email
    ${body}=    Create Dictionary
    ...    nome=${nome_xss}
    ...    email=${email_unico}
    ...    password=${PASSWORD}
    ...    administrador=${ADMIN_FLAG}

    ${resp}=    POST On Session    api    /usuarios    json=${body}    expected_status=400
    Status Should Be    400    ${resp}
