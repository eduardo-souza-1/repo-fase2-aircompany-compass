*** Settings ***
Documentation    Testes de validação de produtos
Resource         ../resources/api.robot

Suite Setup      Run Keywords    Setup API Session    AND    Create Admin User And Login
Suite Teardown   Cleanup Resources

*** Keywords ***
Create Admin User And Login
    ${email}=    Create Random User    admin=true
    ${token}=    Login    ${email}
    Set Suite Variable    ${ADMIN_TOKEN}    ${token}

*** Test Cases ***
Nao Deve Permitir Preco Negativo
    [Documentation]    Verifica que a API rejeita produtos com preço negativo
    [Tags]    produto    validacao    negativo
    
    # Act - Tentar criar produto com preço negativo
    ${nome}=    FakerLibrary.Word
    ${payload}=    Create Dictionary    nome=${nome}    preco=-50    descricao=Teste    quantidade=10
    ${headers}=    Create Dictionary    Authorization=${ADMIN_TOKEN}
    ${response}=    POST On Session    ${SESSION}    /produtos    json=${payload}    headers=${headers}    expected_status=400
    
    # Assert - Validar rejeição
    Validate Status Code    ${response}    400

Nao Deve Permitir Quantidade Negativa
    [Documentation]    Verifica que a API rejeita produtos com quantidade negativa
    [Tags]    produto    validacao    negativo
    
    # Act - Tentar criar produto com quantidade negativa
    ${nome}=    FakerLibrary.Word
    ${payload}=    Create Dictionary    nome=${nome}    preco=100    descricao=Teste    quantidade=-10
    ${headers}=    Create Dictionary    Authorization=${ADMIN_TOKEN}
    ${response}=    POST On Session    ${SESSION}    /produtos    json=${payload}    headers=${headers}    expected_status=400
    
    # Assert - Validar rejeição
    Validate Status Code    ${response}    400

Nao Deve Permitir Produto Sem Nome
    [Documentation]    Verifica que a API rejeita produtos sem nome
    [Tags]    produto    validacao    negativo
    
    # Act - Tentar criar produto sem nome
    ${payload}=    Create Dictionary    preco=100    descricao=Teste    quantidade=10
    ${headers}=    Create Dictionary    Authorization=${ADMIN_TOKEN}
    ${response}=    POST On Session    ${SESSION}    /produtos    json=${payload}    headers=${headers}    expected_status=400
    
    # Assert - Validar rejeição
    Validate Status Code    ${response}    400

Usuario Comum Nao Deve Criar Produto
    [Documentation]    Verifica que usuários não-admin não podem criar produtos
    [Tags]    produto    autorizacao    negativo
    
    # Arrange - Criar usuário comum e fazer login
    ${email}=    Create Random User    admin=false
    ${token}=    Login    ${email}
    
    # Act - Tentar criar produto
    ${nome}=    FakerLibrary.Word
    ${payload}=    Create Dictionary    nome=${nome}    preco=100    descricao=Teste    quantidade=10
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    ${SESSION}    /produtos    json=${payload}    headers=${headers}    expected_status=403
    
    # Assert - Validar negação
    Validate Status Code    ${response}    403
