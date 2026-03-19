*** Settings ***
Resource    ../../resources/api_keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados

*** Test Cases ***
Nao permitir acesso com token invalido
    ${item}=    Create Dictionary
    ...    idProduto=id_fake
    ...    quantidade=1
    ${lista}=    Create List    ${item}
    ${body}=    Create Dictionary    produtos=${lista}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_INVALIDO}

    ${resp}=    POST On Session    api    /carrinhos    json=${body}    headers=${headers}    expected_status=401
    Status Should Be    401    ${resp}
