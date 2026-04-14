*** Settings ***
Documentation    Suite de testes — Domínio /usuarios
...
...              Cobertura: CT-U01 · CT-U02 · CT-U03 · CT-U05 · CT-U06 · CT-U07 · CT-U09 · CT-U10
...
...              Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
...              Versão : 2.0 (reorganizado com 1 CT por teste e rastreabilidade completa)
...
...              ─── REFERÊNCIA DE CASOS ────────────────────────────────────────
...              CT-U01  POST /usuarios — admin válido                    [positivo]
...              CT-U02  POST /usuarios — email duplicado                 [negativo]
...              CT-U03  POST /usuarios — campo email ausente             [negativo]
...              CT-U05  POST /usuarios — XSS no campo nome              [bug/segurança]
...              CT-U06  POST /usuarios — nome com só especiais           [bug/negativo]
...              CT-U07  POST /usuarios — nome vazio                     [bug/negativo]
...              CT-U09  GET  /usuarios — filtro sem correspondência      [negativo]
...              CT-U10  PUT  /usuarios/:id — UPSERT com ID inexistente  [regra de negócio]
...              ────────────────────────────────────────────────────────────────

Resource         ../resources/keywords.robot

Suite Setup      Iniciar Sessao API
Suite Teardown   Limpar Usuarios Criados


# ════════════════════════════════════════════════════════════════════
# BLOCO 1 — CENÁRIOS POSITIVOS
# ════════════════════════════════════════════════════════════════════

*** Test Cases ***

CT-U01 - Criar usuario administrador com dados validos
    # Caso   : CT-U01
    # Tipo   : Positivo
    # Rota   : POST /usuarios
    # Oráculo: 201 · _id presente · message exata · GET confirma persistência e perfil admin
    [Documentation]    Verifica que POST /usuarios cria um administrador com sucesso.
    ...                Confirma status 201, presença de _id, message exata e persistência via GET.
    [Tags]    usuario    positivo    CT-U01

    ${resp}    ${email}=    Criar Usuario Admin

    Validar Status Code        ${resp}    201
    Validar Campo Id Presente  ${resp}
    Validar Mensagem Exata     ${resp}    ${MSG_CADASTRO_OK}

    ${id}=    Set Variable    ${resp.json()}[_id]
    Validar Persistencia Do Usuario    ${id}    ${email}

    ${get}=    Buscar Usuario Por Id    ${id}
    Should Be Equal As Strings    ${get.json()}[administrador]    true


# ════════════════════════════════════════════════════════════════════
# BLOCO 2 — CENÁRIOS NEGATIVOS
# ════════════════════════════════════════════════════════════════════

CT-U02 - Rejeitar criacao de usuario com email ja cadastrado
    # Caso   : CT-U02
    # Tipo   : Negativo
    # Rota   : POST /usuarios (2ª chamada com email duplicado)
    # Oráculo: 400 · message exata · GET confirma que apenas 1 registro existe para o email
    [Documentation]    Verifica que o segundo cadastro com o mesmo email é rejeitado com 400.
    ...                Confirma message de duplicidade e que o banco contém apenas 1 registro.
    [Tags]    usuario    negativo    CT-U02

    # Pré-condição: criar primeiro usuário com email único
    ${resp1}    ${email}=    Criar Usuario Admin
    Validar Status Code    ${resp1}    201

    # Tentativa de duplicar o mesmo email
    ${nome2}=    FakerLibrary.Name
    ${body2}=    Montar Body De Usuario    ${nome2}    ${email}    administrador=${USER_FLAG}
    ${resp2}=    Criar Usuario Com Body Customizado    ${body2}

    Validar Status E Mensagem    ${resp2}    400    ${MSG_EMAIL_DUPLICADO}

    # Regra de negócio: apenas 1 registro deve existir para esse email
    Validar Unicidade Do Email    ${email}

CT-U03 - Rejeitar criacao de usuario sem campo email obrigatorio
    # Caso   : CT-U03
    # Tipo   : Negativo
    # Rota   : POST /usuarios (payload sem campo email)
    # Oráculo: 400 · message contém "email"
    [Documentation]    Verifica que payload sem o campo obrigatório "email" retorna 400.
    ...                A message deve mencionar o campo ausente.
    [Tags]    usuario    negativo    CT-U03

    ${body}=    Create Dictionary
    ...    nome=Usuario Sem Email
    ...    password=${PASSWORD}
    ...    administrador=${ADMIN_FLAG}

    ${resp}=    Criar Usuario Com Body Customizado    ${body}

    Validar Status Code        ${resp}    400
    Validar Mensagem Contem    ${resp}    email

CT-U04 - Rejeitar criacao de usuario sem campo nome obrigatorio
    # Caso   : CT-U04
    # Tipo   : Negativo
    # Rota   : POST /usuarios (payload sem campo nome)
    # Oráculo: 400 · message contém "nome"
    [Documentation]    Verifica que payload sem o campo obrigatório "nome" retorna 400.
    ...                A message deve mencionar o campo ausente.
    [Tags]    usuario    negativo    CT-U04

    ${email}=    FakerLibrary.Email
    ${body}=    Create Dictionary
    ...    email=${email}
    ...    password=${PASSWORD}
    ...    administrador=${ADMIN_FLAG}

    ${resp}=    Criar Usuario Com Body Customizado    ${body}

    Validar Status Code        ${resp}    400
    Validar Mensagem Contem    ${resp}    nome

CT-U09 - GET usuarios com filtro de email inexistente retorna lista vazia
    # Caso   : CT-U09
    # Tipo   : Negativo / Filtro
    # Rota   : GET /usuarios?email=<inexistente>
    # Oráculo: 200 · quantidade==0 · array "usuarios" vazio
    [Documentation]    Verifica que filtro por email sem correspondência retorna 200
    ...                com quantidade igual a zero e array de usuários vazio.
    [Tags]    usuario    negativo    CT-U09

    ${params}=    Create Dictionary    email=naoexiste_faker_unico_xyz@invalid.com.br
    ${resp}=      Buscar Usuarios Com Filtro    ${params}

    Validar Status Code    ${resp}    200
    Validar Lista Vazia    ${resp}

CT-U08 - GET usuarios retorna listagem com estrutura valida
    # Caso   : CT-U08
    # Tipo   : Positivo / Contrato
    # Rota   : GET /usuarios
    # Oráculo: 200 · campo "quantidade" (int) · campo "usuarios" (list)
    [Documentation]    Verifica que GET /usuarios retorna 200 e estrutura de listagem válida
    ...                com os campos "quantidade" e "usuarios" nos tipos esperados.
    [Tags]    usuario    positivo    contrato    CT-U08

    ${resp}=    GET On Session    ${SESSION}    /usuarios    expected_status=200

    Validar Status Code    ${resp}    200
    ${json}=    Set Variable    ${resp.json()}
    Dictionary Should Contain Key    ${json}    quantidade
    Dictionary Should Contain Key    ${json}    usuarios
    Should Be True    isinstance($json['quantidade'], int)
    Should Be True    isinstance($json['usuarios'], list)


# ════════════════════════════════════════════════════════════════════
# BLOCO 3 — REGRAS DE NEGÓCIO
# ════════════════════════════════════════════════════════════════════

CT-U10 - PUT com ID inexistente realiza UPSERT e cria recurso
    # Caso   : CT-U10
    # Tipo   : Regra de negócio (UPSERT documentado)
    # Rota   : PUT /usuarios/:id (ID não existente no banco)
    # Oráculo: 201 · message de cadastro · _id presente · GET confirma criação
    [Documentation]    Verifica que PUT /usuarios/{id_inexistente} aplica o comportamento de
    ...                UPSERT documentado pela ServeRest: cria o recurso e retorna 201.
    [Tags]    usuario    regra    upsert    CT-U10

    ${nome}=     FakerLibrary.Name
    ${email}=    FakerLibrary.Email
    ${body}=     Montar Body De Usuario    ${nome}    ${email}

    # ID que certamente não existe no banco
    ${id_fake}=    Set Variable    upsert_id_nao_existente_99z
    ${resp}=       Atualizar Usuario Via PUT    ${id_fake}    ${body}

    Validar Status E Mensagem    ${resp}    201    ${MSG_CADASTRO_OK}
    Validar Campo Id Presente    ${resp}

    ${novo_id}=    Set Variable    ${resp.json()}[_id]
    Validar Persistencia Do Usuario    ${novo_id}    ${email}


# ════════════════════════════════════════════════════════════════════
# BLOCO 4 — EVIDÊNCIAS DE BUG (falham intencionalmente)
# ════════════════════════════════════════════════════════════════════

CT-U05 - Evidenciar XSS armazenado no campo nome - BUG-01
    # Caso   : CT-U05
    # Tipo   : Bug / Segurança — OWASP A03:2021 (Stored XSS)
    # Rota   : POST /usuarios (nome com payload XSS)
    # Oráculo esperado : 400 (rejeição da entrada)
    # Comportamento BUG: API aceita e retorna 201 — XSS persistido no banco
    [Documentation]    BUG-01 (Alta severidade): a API aceita script no campo nome
    ...                e retorna 201 em vez do esperado 400.
    ...                Este teste FALHA intencionalmente para evidenciar a vulnerabilidade.
    ...                Referência OWASP: A03:2021 — Injection (Stored XSS).
    [Tags]    usuario    seguranca    xss    bug    BUG-01    CT-U05

    ${email}=    FakerLibrary.Email
    ${body}=     Montar Body De Usuario    ${NOME_XSS}    ${email}

    ${resp}=    Criar Usuario Com Body Customizado    ${body}

    # Quando a API aceita (BUG confirmado): registra evidência via log
    IF    ${resp.status_code} == 201
        Registrar Bug Evidenciado
        ...    BUG-01
        ...    API retornou 201 — payload XSS no campo nome foi persistido no banco
    END

    # Oráculo correto: 400. O assert abaixo falha enquanto o bug existir.
    Validar Status Code    ${resp}    400

CT-U06 - Evidenciar nome com apenas caracteres especiais - BUG-02
    # Caso   : CT-U06
    # Tipo   : Bug / Validação de entrada
    # Rota   : POST /usuarios (nome semanticamente inválido)
    # Oráculo esperado : 400
    # Comportamento BUG: API aceita e retorna 201
    [Documentation]    BUG-02 (Média severidade): a API aceita nome composto apenas por
    ...                caracteres especiais (@@@@@@) e retorna 201 em vez de 400.
    ...                Este teste FALHA intencionalmente para evidenciar o bug.
    [Tags]    usuario    negativo    bug    BUG-02    CT-U06

    ${email}=    FakerLibrary.Email
    ${body}=     Montar Body De Usuario    ${NOME_ESPECIAIS}    ${email}    administrador=${USER_FLAG}

    ${resp}=    Criar Usuario Com Body Customizado    ${body}

    IF    ${resp.status_code} == 201
        Registrar Bug Evidenciado
        ...    BUG-02
        ...    API retornou 201 — nome semanticamente inválido (@@@@@@) foi aceito
    END

    # Oráculo correto: 400. O assert abaixo falha enquanto o bug existir.
    Validar Status Code    ${resp}    400

CT-U07 - Evidenciar campo nome com string vazia aceito pela API - BUG-03 
    # Caso   : CT-U07
    # Tipo   : Bug / Validação de campo obrigatório
    # Rota   : POST /usuarios (nome="")
    # Oráculo esperado : 400 (campo nome não pode ser vazio)
    # Comportamento BUG: API aceita e retorna 201
    [Documentation]    BUG-01 parcial: o campo nome com string vazia deveria retornar 400
    ...                mas a API aceita e persiste o registro com nome vazio.
    ...                Este teste FALHA intencionalmente como evidência do bug.
    [Tags]    usuario    negativo    bug    BUG-01    CT-U07

    ${email}=    FakerLibrary.Email
    ${body}=     Montar Body De Usuario    ${NOME_VAZIO}    ${email}

    ${resp}=    Criar Usuario Com Body Customizado    ${body}

    IF    ${resp.status_code} == 201
        Registrar Bug Evidenciado
        ...    BUG-01 parcial
        ...    API retornou 201 — nome vazio foi persistido no banco

        # Verificação adicional: confirmar que nome foi salvo vazio (evidência extra)
        ${id}=    Set Variable    ${resp.json()}[_id]
        ${get}=   Buscar Usuario Por Id    ${id}
        Should Be Equal As Strings    ${get.json()}[nome]    ${EMPTY}
    END

    # Oráculo correto: 400. O assert abaixo falha enquanto o bug existir.
    Validar Status Code    ${resp}    400
