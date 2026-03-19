*** Settings ***
Resource    ../../resources/api_keywords.robot
Library     Collections

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados

*** Test Cases ***
Validar contrato basico do login
    ${resp_user}    ${email}=    Criar Usuario Admin
    Status Should Be    201    ${resp_user}

    ${login}=    Realizar Login    ${email}
    Status Should Be    200    ${login}

    ${json}=    Set Variable    ${login.json()}
    Dictionary Should Contain Key    ${json}    authorization
    Should Start With    ${json["authorization"]}    Bearer
