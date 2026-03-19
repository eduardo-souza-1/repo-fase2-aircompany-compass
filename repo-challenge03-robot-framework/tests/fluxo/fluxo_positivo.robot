*** Settings ***
Resource    ../../resources/api_keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Suite Fluxo Positivo

*** Variables ***
${token_suite}    ${EMPTY}

*** Test Cases ***
Caso de fluxo positivo de compra completo
    ${resp_user}    ${email}=    Criar Usuario Admin
    Status Should Be    201    ${resp_user}

    ${token}=    Obter Token    ${email}
    Set Suite Variable    ${token_suite}    ${token}

    ${resp_prod}=    Criar Produto    ${token}
    Status Should Be    201    ${resp_prod}
    ${id_prod}=    Set Variable    ${resp_prod.json()}[_id]

    ${item}=    Create Dictionary    idProduto=${id_prod}    quantidade=1
    ${lista}=    Create List    ${item}
    ${body}=    Create Dictionary    produtos=${lista}
    ${headers}=    Create Dictionary    Authorization=${token}

    ${resp_carrinho}=    POST On Session    api    /carrinhos    json=${body}    headers=${headers}
    Status Should Be    201    ${resp_carrinho}

    ${resp_finalizar}=    DELETE On Session    api    /carrinhos/concluir-compra    headers=${headers}
    Status Should Be    200    ${resp_finalizar}

*** Keywords ***
Limpar Suite Fluxo Positivo
    Run Keyword If    '${token_suite}' != '${EMPTY}'    Limpar Produtos Criados    ${token_suite}
    Limpar Usuarios Criados
