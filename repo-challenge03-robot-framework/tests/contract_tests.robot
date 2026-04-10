*** Settings ***
Documentation    Testes de validação de contrato da API
Library          String
Resource         ../resources/api.robot

Suite Setup      Setup API Session
Suite Teardown   Cleanup Resources

*** Test Cases ***
Deve Retornar Contrato Valido De Login
    [Documentation]    Verifica que a resposta de login contém os campos obrigatórios
    [Tags]    contrato    positivo
    
    # Arrange - Criar usuário
    ${email}=    Create Random User
    
    # Act - Fazer login
    ${payload}=    Create Dictionary    email=${email}    password=senha@123
    ${response}=    POST On Session    ${SESSION}    /login    json=${payload}    expected_status=200
    
    # Assert - Validar estrutura da resposta
    Validate Status Code    ${response}    200
    Validate Response Contains    ${response}    authorization
    Validate Response Contains    ${response}    message
    ${json}=    Set Variable    ${response.json()}
    ${mensagem}=    Set Variable    ${json}[message]
    Should Be Equal    ${mensagem}    Login realizado com sucesso

Deve Retornar Token JWT Valido
    [Documentation]    Verifica que o token segue o formato JWT (header.payload.signature)
    [Tags]    contrato    seguranca    jwt
    
    # Arrange - Criar usuário
    ${email}=    Create Random User
    
    # Act - Fazer login e obter token
    ${token}=    Login    ${email}
    
    # Assert - Validar formato JWT
    Should Start With    ${token}    Bearer
    Validate JWT Token Format    ${token}
