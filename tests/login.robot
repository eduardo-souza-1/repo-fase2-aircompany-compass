* Settings *
Documentation    Suite de testes — Domínio /login
...
...              Cobertura: CT-L01 · CT-L02 · CT-L03 · CT-L05
...
...              Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
...              Versão : 1.0
...
...              ─── REFERÊNCIA DE CASOS ────────────────────────────────────────
...              CT-L01  POST /login — credenciais válidas, token JWT          [positivo]
...              CT-L02  POST /login — password incorreto                      [negativo]
...              CT-L03  POST /login — contrato completo do response           [contrato]
...              CT-L05  POST /login — email inexistente (user enumeration)    [negativo/segurança]
...              ────────────────────────────────────────────────────────────────
...
...              FORA DO ESCOPO (aguardam validação manual):
...              CT-L04  POST /login — campo password ausente
...                      Mensagem exata não confirmada no Postman. Ver plano v6.0, seção 4.2.

Resource         ../resources/keywords.robot
Resource         ../resources/login_keywords.robot

Suite Setup      Run Keywords
...              Iniciar Sessao API
...    AND       Criar Usuario Admin Para Suite De Login
Suite Teardown   Limpar Usuarios Criados

* Variables *
${EMAIL_SUITE}    ${EMPTY}    # email do usuário criado no Suite Setup

* Keywords *
Criar Usuario Admin Para Suite De Login
    [Documentation]    Cria um único usuário administrador para toda a suite de login.
    ...                O email é armazenado em variável de suite para reuso nos testes.
    ${resp}    ${email}=    Criar Usuario Admin
    Validar Status Code    ${resp}    201
    Set Suite Variable    ${EMAIL_SUITE}    ${email}


# ════════════════════════════════════════════════════════════════════
# BLOCO 1 — CENÁRIOS POSITIVOS
# ════════════════════════════════════════════════════════════════════

* Test Cases *

CT-L01 - Login com credenciais validas retorna token JWT
    # Caso   : CT-L01
    # Tipo   : Positivo
    # Rota   : POST /login
    # Oráculo: 200 · message exata · campo authorization presente · token com prefixo Bearer
    [Documentation]    Verifica que POST /login com credenciais válidas retorna 200,
    ...                message de sucesso, campo authorization presente e token no formato JWT.
    [Tags]    login    positivo    CT-L01

    ${resp}=    Realizar Login    ${EMAIL_SUITE}

    Validar Status Code       ${resp}    200
    Validar Mensagem Exata    ${resp}    ${MSG_LOGIN_OK}

    # Valida presença e formato do token
    Dictionary Should Contain Key    ${resp.json()}    authorization
    Validar Token JWT    ${resp.json()}[authorization]


# ════════════════════════════════════════════════════════════════════
# BLOCO 2 — CENÁRIOS NEGATIVOS
# ════════════════════════════════════════════════════════════════════

CT-L02 - Login com password incorreto retorna 401
    # Caso   : CT-L02
    # Tipo   : Negativo
    # Rota   : POST /login (password errado para usuário existente)
    # Oráculo: 401 · message exata · campo authorization ausente no body
    [Documentation]    Verifica que password incorreto retorna 401 com message exata.
    ...                Confirma também que nenhum token é gerado (campo authorization ausente).
    [Tags]    login    negativo    CT-L02

    ${resp}=    Realizar Login    ${EMAIL_SUITE}    password=senha_totalmente_errada_999

    Validar Status E Mensagem    ${resp}    401    ${MSG_SENHA_INVALIDA}

    # Regra de segurança: nenhum token deve ser gerado em falha de autenticação
    Validar Ausencia De Campo Authorization    ${resp}

CT-L05 - Login com email inexistente retorna 401 identico ao de password incorreto
    # Caso   : CT-L05
    # Tipo   : Negativo / Segurança (prevenção de user enumeration)
    # Rota   : POST /login (email que não existe no banco)
    # Oráculo: 401 · message idêntica ao CT-L02 · campo authorization ausente
    [Documentation]    Verifica que email inexistente retorna 401 com a MESMA message
    ...                do CT-L02 (password errado), prevenindo user enumeration.
    ...                A API não deve revelar se o email está ou não cadastrado.
    [Tags]    login    negativo    seguranca    CT-L05

    ${resp}=    Realizar Login    email=naoexiste_faker_unico_xyz_99@invalid.com.br

    Validar Status E Mensagem    ${resp}    401    ${MSG_SENHA_INVALIDA}

    # Regra de segurança: message deve ser idêntica à de password errado (sem revelar existência)
    Validar Ausencia De Campo Authorization    ${resp}


# ════════════════════════════════════════════════════════════════════
# BLOCO 3 — CONTRATO
# ════════════════════════════════════════════════════════════════════

CT-L03 - Validar contrato completo do response de login
    # Caso   : CT-L03
    # Tipo   : Contrato
    # Rota   : POST /login (credenciais válidas)
    # Oráculo: 200 · exatamente 2 campos: message (string) e authorization (string Bearer)
    [Documentation]    Verifica que o response de login possui exatamente os campos
    ...                "message" e "authorization", com os tipos corretos e sem campos extras.
    [Tags]    login    contrato    CT-L03

    ${resp}=    Realizar Login    ${EMAIL_SUITE}

    Validar Status Code        ${resp}    200
    Validar Contrato Do Login  ${resp}