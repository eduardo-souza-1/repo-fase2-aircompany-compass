*** Settings ***
Documentation    Testes de fluxo completo end-to-end
Resource         ../resources/api.robot

Suite Setup      Run Keywords    Setup API Session    AND    Create Admin User And Login
Suite Teardown   Cleanup Resources

*** Keywords ***
Create Admin User And Login
    ${email}=    Create Random User    admin=true
    ${token}=    Login    ${email}
    Set Suite Variable    ${ADMIN_TOKEN}    ${token}

*** Test Cases ***
Deve Completar Fluxo De Compra Completo
    [Documentation]    Verifica o fluxo completo: criar produto, adicionar ao carrinho e finalizar compra
    [Tags]    e2e    positivo    smoke
    
    # Arrange - Criar produto
    ${produto}=    Create Random Product    ${ADMIN_TOKEN}
    ${json}=    Set Variable    ${produto.json()}
    ${product_id}=    Set Variable    ${json}[_id]
    
    # Act - Adicionar ao carrinho
    ${carrinho}=    Create Cart    ${ADMIN_TOKEN}    ${product_id}
    Validate Status Code    ${carrinho}    201
    
    # Assert - Finalizar compra
    ${compra}=    Complete Purchase    ${ADMIN_TOKEN}
    Validate Status Code    ${compra}    200
