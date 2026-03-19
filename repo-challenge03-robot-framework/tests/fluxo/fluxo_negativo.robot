*** Settings ***
Resource    ../../resources/api_keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados

*** Test Cases ***
Usuario comum nao pode criar produto
    ${resp_user}    ${email}=    Criar Usuario Comum
    Status Should Be    201    ${resp_user}

    ${token}=    Obter Token    ${email}

    ${produto}=    Create Dictionary
    ...    nome=produto nao autorizado
    ...    preco=${PRECO_VALIDO}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${QUANTIDADE_VALIDA}
    ${headers}=    Create Dictionary    Authorization=${token}

    ${resp}=    POST On Session    api    /produtos    json=${produto}    headers=${headers}    expected_status=403
    Status Should Be    403    ${resp}
