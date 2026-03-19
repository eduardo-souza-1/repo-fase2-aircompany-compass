*** Settings ***
Resource    ../../resources/api_keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados

*** Test Cases ***
Criar produto sem nome
    ${resp_user}    ${email}=    Criar Usuario Admin
    ${token}=    Obter Token    ${email}

    ${body}=    Create Dictionary
    ...    preco=${PRECO_VALIDO}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${QUANTIDADE_VALIDA}
    ${headers}=    Create Dictionary    Authorization=${token}

    ${resp}=    POST On Session    api    /produtos    json=${body}    headers=${headers}    expected_status=400
    Status Should Be    400    ${resp}
