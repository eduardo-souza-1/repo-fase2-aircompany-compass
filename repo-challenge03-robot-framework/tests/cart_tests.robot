*** Settings ***
Documentation    Testes de autenticação do carrinho
Resource         ../resources/api.robot

Suite Setup      Setup API Session
Suite Teardown   Cleanup Resources

*** Test Cases ***
Nao Deve Permitir Token Invalido
    [Documentation]    Verifica que a API rejeita tokens inválidos
    [Tags]    carrinho    autenticacao    negativo
    
    # Act - Tentar criar carrinho com token inválido
    ${payload}=    Create Dictionary    produtos=${EMPTY}
    ${headers}=    Create Dictionary    Authorization=Bearer token_invalido
    ${response}=    POST On Session    ${SESSION}    /carrinhos    json=${payload}    headers=${headers}    expected_status=401
    
    # Assert - Validar rejeição
    Validate Status Code    ${response}    401
