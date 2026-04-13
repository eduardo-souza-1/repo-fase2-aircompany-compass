* Settings *
Documentation    Keywords reutilizáveis para o domínio /login — ServeRest QA.
...              Responsabilidade: autenticação, captura de token e validações de contrato.
...              NÃO contém lógica de teste — apenas blocos reutilizáveis.
Library          RequestsLibrary
Library          Collections
Library          String
Resource         api.robot
Variables        ../variables/variables.py


# ════════════════════════════════════════════════════════════════════
# OPERAÇÕES HTTP — LOGIN
# ════════════════════════════════════════════════════════════════════

* Keywords *
Realizar Login
    [Documentation]    POST /login com email e password informados.
    ...                Retorna: response completo (expected_status=any para cenários negativos).
    [Arguments]    ${email}    ${password}=${PASSWORD}
    ${body}=    Create Dictionary    email=${email}    password=${password}
    ${resp}=    POST On Session    ${SESSION}    /login    json=${body}    expected_status=any
    RETURN    ${resp}

Realizar Login Com Body Customizado
    [Documentation]    POST /login com payload arbitrário (para cenários negativos com campos ausentes).
    ...                Retorna: response completo.
    [Arguments]    ${body}
    ${resp}=    POST On Session    ${SESSION}    /login    json=${body}    expected_status=any
    RETURN    ${resp}

Obter Token
    [Documentation]    Autentica o usuário e retorna apenas o valor do campo authorization.
    ...                Falha explicitamente se o login não retornar 200.
    [Arguments]    ${email}    ${password}=${PASSWORD}
    ${resp}=    Realizar Login    ${email}    ${password}
    Should Be Equal As Numbers    ${resp.status_code}    200
    RETURN    ${resp.json()}[authorization]


# ════════════════════════════════════════════════════════════════════
# VALIDAÇÕES REUTILIZÁVEIS — LOGIN
# ════════════════════════════════════════════════════════════════════

Validar Token JWT
    [Documentation]    Confirma que o token segue o formato "Bearer <header>.<payload>.<signature>".
    ...                Valida prefixo Bearer e que o JWT contém exatamente 3 segmentos separados por ponto.
    [Arguments]    ${token}
    Should Start With    ${token}    Bearer${SPACE}
    ${token_limpo}=    Remove String    ${token}    Bearer${SPACE}
    @{partes}=         Split String     ${token_limpo}    .
    Length Should Be   ${partes}    3
    FOR    ${parte}    IN    @{partes}
        Should Not Be Empty    ${parte}
    END

Validar Ausencia De Campo Authorization
    [Documentation]    Confirma que o campo "authorization" NÃO está presente no JSON.
    ...                Útil para garantir que falhas de login não vagem token algum.
    [Arguments]    ${resp}
    Dictionary Should Not Contain Key    ${resp.json()}    authorization

Validar Contrato Do Login
    [Documentation]    Confirma que o response de login possui exatamente 2 campos:
    ...                "message" (string) e "authorization" (string com prefixo Bearer).
    ...                Nenhum campo adicional inesperado deve estar presente.
    [Arguments]    ${resp}
    ${json}=     Set Variable    ${resp.json()}
    ${chaves}=   Get Dictionary Keys    ${json}
    Length Should Be    ${chaves}    2
    Dictionary Should Contain Key    ${json}    message
    Dictionary Should Contain Key    ${json}    authorization
    Should Be True    isinstance($json['message'], str)
    Should Be True    isinstance($json['authorization'], str)
    Should Start With    ${json}[authorization]    Bearer${SPACE}