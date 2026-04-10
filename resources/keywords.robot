*** Settings ***
Documentation    Keywords reutilizáveis para o domínio /usuarios — ServeRest QA.
...              Responsabilidade: operações CRUD, geração de dados e validações.
...              NÃO contém lógica de teste — apenas blocos reutilizáveis.
Library          RequestsLibrary
Library          Collections
Library          String
Library          FakerLibrary
Resource         api.robot
Variables        ../variables/variables.py

# ════════════════════════════════════════════════════════════════════
# GERAÇÃO DE DADOS
# ════════════════════════════════════════════════════════════════════

*** Keywords ***
Gerar Dados Fake De Usuario
    [Documentation]    Gera nome e email únicos via FakerLibrary.
    ...                Retorna: nome, email
    ${nome}=     FakerLibrary.Name
    ${email}=    FakerLibrary.Email
    RETURN    ${nome}    ${email}

Montar Body De Usuario
    [Documentation]    Constrói payload JSON para POST/PUT /usuarios.
    ...                Argumentos: nome, email, password, administrador.
    [Arguments]    ${nome}    ${email}    ${password}=${PASSWORD}    ${administrador}=${ADMIN_FLAG}
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${administrador}
    RETURN    ${body}

# ════════════════════════════════════════════════════════════════════
# OPERAÇÕES HTTP — USUÁRIO
# ════════════════════════════════════════════════════════════════════

Criar Usuario
    [Documentation]    POST /usuarios com perfil configurável.
    ...                Registra _id em USUARIOS_CRIADOS para cleanup automático.
    ...                Retorna: response, email
    [Arguments]    ${administrador}=${ADMIN_FLAG}
    ${nome}    ${email}=    Gerar Dados Fake De Usuario
    ${body}=    Montar Body De Usuario    ${nome}    ${email}    administrador=${administrador}
    ${resp}=    POST On Session    ${SESSION}    /usuarios    json=${body}    expected_status=any
    IF    ${resp.status_code} == 201
        Append To List    ${USUARIOS_CRIADOS}    ${resp.json()}[_id]
    END
    RETURN    ${resp}    ${email}

Criar Usuario Admin
    [Documentation]    Atalho para criar usuário com perfil administrador (administrador=true).
    ${resp}    ${email}=    Criar Usuario    administrador=${ADMIN_FLAG}
    RETURN    ${resp}    ${email}

Criar Usuario Comum
    [Documentation]    Atalho para criar usuário sem perfil de administrador (administrador=false).
    ${resp}    ${email}=    Criar Usuario    administrador=${USER_FLAG}
    RETURN    ${resp}    ${email}

Criar Usuario Com Body Customizado
    [Documentation]    POST /usuarios com payload arbitrário (para cenários negativos).
    ...                Registra _id em USUARIOS_CRIADOS se a resposta for 201.
    ...                Retorna: response
    [Arguments]    ${body}
    ${resp}=    POST On Session    ${SESSION}    /usuarios    json=${body}    expected_status=any
    IF    ${resp.status_code} == 201
        Append To List    ${USUARIOS_CRIADOS}    ${resp.json()}[_id]
    END
    RETURN    ${resp}

Buscar Usuario Por Id
    [Documentation]    GET /usuarios/{id} — retorna response completo.
    [Arguments]    ${id}
    ${resp}=    GET On Session    ${SESSION}    /usuarios/${id}    expected_status=any
    RETURN    ${resp}

Buscar Usuarios Com Filtro
    [Documentation]    GET /usuarios com parâmetros de query — retorna response completo.
    [Arguments]    ${params}
    ${resp}=    GET On Session    ${SESSION}    /usuarios    params=${params}    expected_status=any
    RETURN    ${resp}

Atualizar Usuario Via PUT
    [Documentation]    PUT /usuarios/{id} com body informado — suporta UPSERT.
    ...                Registra _id retornado em USUARIOS_CRIADOS se resposta for 201.
    ...                Retorna: response
    [Arguments]    ${id}    ${body}
    ${resp}=    PUT On Session    ${SESSION}    /usuarios/${id}    json=${body}    expected_status=any
    IF    ${resp.status_code} == 201
        Append To List    ${USUARIOS_CRIADOS}    ${resp.json()}[_id]
    END
    RETURN    ${resp}

Deletar Usuario
    [Documentation]    DELETE /usuarios/{id} — idempotente (ignora 404).
    [Arguments]    ${id}
    DELETE On Session    ${SESSION}    /usuarios/${id}    expected_status=any

# ════════════════════════════════════════════════════════════════════
# VALIDAÇÕES REUTILIZÁVEIS
# ════════════════════════════════════════════════════════════════════

Validar Status Code
    [Documentation]    Confirma que o status HTTP bate com o esperado.
    [Arguments]    ${resp}    ${status_esperado}
    Should Be Equal As Numbers    ${resp.status_code}    ${status_esperado}

Validar Mensagem Exata
    [Documentation]    Confirma que o campo "message" do JSON é exatamente o esperado.
    [Arguments]    ${resp}    ${message_esperada}
    Should Be Equal As Strings    ${resp.json()}[message]    ${message_esperada}

Validar Mensagem Contem
    [Documentation]    Confirma que o campo "message" do JSON contém o trecho esperado.
    ...                Se "message" não existir, tenta validar em outros campos da resposta.
    [Arguments]    ${resp}    ${trecho}
    ${json}=    Set Variable    ${resp.json()}
    ${has_message}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json}    message
    IF    ${has_message}
        Should Contain    ${json}[message]    ${trecho}
    ELSE
        ${resp_str}=    Convert To String    ${json}
        Should Contain    ${resp_str}    ${trecho}
    END

Validar Campo Id Presente
    [Documentation]    Confirma que "_id" existe no JSON e não é vazio.
    [Arguments]    ${resp}
    Dictionary Should Contain Key    ${resp.json()}    _id
    Should Not Be Empty    ${resp.json()}[_id]

Validar Status E Mensagem
    [Documentation]    Combinação: valida status HTTP + campo message exato.
    [Arguments]    ${resp}    ${status_esperado}    ${message_esperada}
    Validar Status Code          ${resp}    ${status_esperado}
    Validar Mensagem Exata       ${resp}    ${message_esperada}

Validar Persistencia Do Usuario
    [Documentation]    Faz GET /usuarios/{id} e confirma que o email bate com o criado.
    ...                Útil para garantir que o recurso foi de fato persistido.
    [Arguments]    ${id}    ${email_esperado}
    ${get}=    Buscar Usuario Por Id    ${id}
    Should Be Equal As Numbers    ${get.status_code}    200
    Should Be Equal As Strings    ${get.json()}[email]    ${email_esperado}

Validar Unicidade Do Email
    [Documentation]    Filtra /usuarios por email e confirma que há exatamente 1 registro.
    ...                Útil para garantir que email duplicado não criou segundo registro.
    [Arguments]    ${email}
    ${params}=    Create Dictionary    email=${email}
    ${get}=       Buscar Usuarios Com Filtro    ${params}
    Should Be Equal As Numbers    ${get.status_code}    200
    Should Be Equal As Numbers    ${get.json()}[quantidade]    1

Validar Lista Vazia
    [Documentation]    Confirma que o response possui quantidade=0 e array "usuarios" vazio.
    [Arguments]    ${resp}
    Should Be Equal As Numbers    ${resp.json()}[quantidade]    0
    ${lista}=    Set Variable    ${resp.json()}[usuarios]
    Length Should Be    ${lista}    0

Registrar Bug Evidenciado
    [Documentation]    Loga um aviso de BUG confirmado quando a API aceita dados inválidos.
    ...                Usado em testes de evidência (não bloqueante per se, mas o assert final falha).
    [Arguments]    ${id_bug}    ${detalhe}
    Log    ${id_bug} CONFIRMADO: ${detalhe}    WARN
