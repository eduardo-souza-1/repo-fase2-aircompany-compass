* Settings *
Documentation    Suite de testes — Domínio /produtos
...
...              Cobertura: CT-P01 · CT-P02 · CT-P03 · CT-P04 · CT-P05 · CT-P06
...                         CT-P07 · CT-P08 · CT-P09 · CT-P10 · CT-P11 · CT-P12 · CT-P13
...
...              Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
...              Versão : 1.0
...
...              ─── REFERÊNCIA DE CASOS ────────────────────────────────────────
...              CT-P01  POST /produtos — criar com admin válido               [positivo]
...              CT-P02  POST /produtos — RBAC: não-admin rejeitado            [negativo/regra]
...              CT-P03  POST /produtos — token inválido                       [negativo]
...              CT-P04  POST /produtos — preço negativo                       [negativo]
...              CT-P05  POST /produtos — quantidade negativa                  [negativo]
...              CT-P06  POST /produtos — campo nome ausente                   [negativo]
...              CT-P07  POST /produtos — preço como string (BUG-03)           [bug/evidência]
...              CT-P08  POST /produtos — nome duplicado                       [negativo]
...              CT-P09  DELETE /produtos/:id — ID inexistente (negativo)        [negativo]
...              CT-P10  GET /produtos — estrutura da listagem                 [positivo/contrato]
...              CT-P11  POST /produtos — contrato do response de criação      [contrato]
...              CT-P12  GET /produtos — filtro sem resultado retorna vazio     [negativo]
...              CT-P13  PUT /produtos/:id — sem token de autorização          [negativo]
...              ────────────────────────────────────────────────────────────────

Resource         ../resources/keywords.robot
Resource         ../resources/login_keywords.robot
Resource         ../resources/produto_keywords.robot

Suite Setup      Run Keywords
...              Iniciar Sessao API
...    AND       Criar Admin E Obter Token Para Suite
Suite Teardown   Run Keywords
...              Limpar Produtos Criados    ${TOKEN_ADMIN_SUITE}
...    AND       Limpar Usuarios Criados

* Variables *
${TOKEN_ADMIN_SUITE}    ${EMPTY}    # token do admin criado no Suite Setup

* Keywords *
Criar Admin E Obter Token Para Suite
    [Documentation]    Cria um único usuário administrador e captura seu token JWT.
    ...                Ambos são armazenados em variáveis de suite para reuso em todos os testes.
    ${resp}    ${email}=    Criar Usuario Admin
    Validar Status Code    ${resp}    201
    ${token}=    Obter Token    ${email}
    Set Suite Variable    ${TOKEN_ADMIN_SUITE}    ${token}


# ════════════════════════════════════════════════════════════════════
# BLOCO 1 — CENÁRIOS POSITIVOS
# ════════════════════════════════════════════════════════════════════

* Test Cases *

CT-P01 - Criar produto como administrador com dados validos
    # Caso   : CT-P01
    # Tipo   : Positivo
    # Rota   : POST /produtos (token admin + payload válido)
    # Oráculo: 201 · _id presente · message exata · GET confirma nome e quantidade
    [Documentation]    Verifica que POST /produtos cria um produto com sucesso quando
    ...                autenticado como administrador. Confirma persistência via GET.
    [Tags]    produto    positivo    CT-P01

    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}    quantidade=${10}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status Code       ${resp}    201
    Validar Campo Id Presente    ${resp}
    Validar Mensagem Exata    ${resp}    ${MSG_CADASTRO_OK}

    # Confirma persistência e integridade dos dados
    ${id}=    Set Variable    ${resp.json()}[_id]
    Validar Persistencia Do Produto    ${id}    ${nome}    ${10}

CT-P10 - GET produtos retorna listagem com estrutura valida
    # Caso   : CT-P10
    # Tipo   : Positivo / Contrato
    # Rota   : GET /produtos
    # Oráculo: 200 · campo "quantidade" (int) · campo "produtos" (list) com tipos corretos
    [Documentation]    Verifica que GET /produtos retorna 200 e estrutura de listagem válida
    ...                com os campos "quantidade" e "produtos" nos tipos esperados.
    [Tags]    produto    positivo    contrato    CT-P10

    ${resp}=    GET On Session    ${SESSION}    /produtos    expected_status=200

    Validar Status Code                     ${resp}    200
    Validar Estrutura Da Listagem De Produtos    ${resp}


# ════════════════════════════════════════════════════════════════════
# BLOCO 2 — CENÁRIOS NEGATIVOS
# ════════════════════════════════════════════════════════════════════

CT-P02 - Rejeitar criacao de produto por usuario nao-admin
    # Caso   : CT-P02
    # Tipo   : Negativo / Regra de negócio (RBAC)
    # Rota   : POST /produtos (token de usuário comum)
    # Oráculo: 403 · message exata · produto NÃO aparece na listagem
    [Documentation]    Verifica que usuário sem perfil de administrador recebe 403 ao tentar
    ...                criar um produto. Confirma via GET que o produto não foi criado.
    [Tags]    produto    negativo    rbac    CT-P02

    # Cria usuário comum e obtém seu token
    ${resp_user}    ${email_comum}=    Criar Usuario Comum
    Validar Status Code    ${resp_user}    201
    ${token_comum}=    Obter Token    ${email_comum}

    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}
    ${headers}=    Create Dictionary    Authorization=${token_comum}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status E Mensagem    ${resp}    403    ${MSG_RBAC_ADMIN}

    # Regra de negócio: produto não deve ter sido criado
    Validar Ausencia Do Produto Na Listagem    ${nome}

CT-P03 - Rejeitar criacao de produto com token invalido
    # Caso   : CT-P03
    # Tipo   : Negativo (autenticação)
    # Rota   : POST /produtos (JWT adulterado no header)
    # Oráculo: 401 · message exata de token inválido
    [Documentation]    Verifica que um JWT adulterado é rejeitado com 401 e message exata.
    [Tags]    produto    negativo    autenticacao    CT-P03

    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_INVALIDO}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status E Mensagem    ${resp}    401    ${MSG_TOKEN_INVALIDO}

CT-P04 - Rejeitar produto com preco negativo
    # Caso   : CT-P04
    # Tipo   : Negativo (validação de campo numérico)
    # Rota   : POST /produtos (preco=-1)
    # Oráculo: 400 · message menciona o campo "preco"
    [Documentation]    Verifica que preço negativo é rejeitado com 400 e que a message
    ...                indica o campo inválido.
    [Tags]    produto    negativo    validacao    CT-P04

    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}    preco=${PRECO_NEGATIVO}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status Code       ${resp}    400
    Validar Mensagem Contem   ${resp}    preco

CT-P05 - Rejeitar produto com quantidade negativa
    # Caso   : CT-P05
    # Tipo   : Negativo (validação de campo numérico)
    # Rota   : POST /produtos (quantidade=-1)
    # Oráculo: 400 · message menciona o campo "quantidade"
    [Documentation]    Verifica que quantidade negativa é rejeitada com 400 e que a message
    ...                indica o campo inválido.
    [Tags]    produto    negativo    validacao    CT-P05

    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}    quantidade=${QUANTIDADE_NEGATIVA}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status Code       ${resp}    400
    Validar Mensagem Contem   ${resp}    quantidade

CT-P06 - Rejeitar produto sem campo nome obrigatorio
    # Caso   : CT-P06
    # Tipo   : Negativo (campo obrigatório ausente)
    # Rota   : POST /produtos (payload sem campo "nome")
    # Oráculo: 400 · message menciona o campo "nome"
    [Documentation]    Verifica que payload sem o campo obrigatório "nome" retorna 400.
    ...                A message deve mencionar o campo ausente.
    [Tags]    produto    negativo    validacao    CT-P06

    ${body}=    Create Dictionary
    ...    preco=${PRECO_VALIDO}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${QUANTIDADE_VALIDA}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    Validar Status Code       ${resp}    400
    Validar Mensagem Contem   ${resp}    nome

CT-P08 - Rejeitar produto com nome ja cadastrado
    # Caso   : CT-P08
    # Tipo   : Negativo (unicidade de nome)
    # Rota   : POST /produtos (nome duplicado)
    # Oráculo: 400 · message exata · segundo produto NÃO criado
    [Documentation]    Verifica que dois produtos com o mesmo nome são rejeitados com 400.
    ...                Confirma message exata de duplicidade.
    [Tags]    produto    negativo    validacao    CT-P08

    # Cria primeiro produto com nome controlado
    ${nome}=    Gerar Nome De Produto Unico
    ${body1}=   Montar Body De Produto    ${nome}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}
    ${resp1}=   Criar Produto Com Body Customizado    ${body1}    ${headers}
    Validar Status Code    ${resp1}    201

    # Tenta criar segundo produto com nome idêntico
    ${body2}=    Montar Body De Produto    ${nome}    preco=${50}    quantidade=${2}
    ${resp2}=    Criar Produto Com Body Customizado    ${body2}    ${headers}

    Validar Status E Mensagem    ${resp2}    400    ${MSG_PRODUTO_DUPLICADO}

CT-P12 - GET produtos com filtro sem correspondencia retorna lista vazia
    # Caso   : CT-P12
    # Tipo   : Negativo / Filtro
    # Rota   : GET /produtos?nome=<inexistente>
    # Oráculo: 200 · quantidade==0 · array "produtos" vazio
    [Documentation]    Verifica que filtro por nome sem correspondência retorna 200
    ...                com quantidade igual a zero e array de produtos vazio.
    [Tags]    produto    negativo    CT-P12

    ${params}=    Create Dictionary    nome=nome_produto_jamais_existira_faker_xyz_999
    ${resp}=      Buscar Produtos Com Filtro    ${params}

    Validar Status Code    ${resp}    200
    Should Be Equal As Numbers    ${resp.json()}[quantidade]    0
    ${lista}=    Set Variable    ${resp.json()}[produtos]
    Length Should Be    ${lista}    0

CT-P13 - PUT produto sem token de autorizacao retorna 401
    # Caso   : CT-P13
    # Tipo   : Negativo (autenticação)
    # Rota   : PUT /produtos/:id (sem header Authorization)
    # Oráculo: 401 · message exata · produto não alterado
    [Documentation]    Verifica que PUT /produtos/{id} sem token retorna 401 com message exata.
    ...                O produto existente não deve ser alterado.
    [Tags]    produto    negativo    autenticacao    CT-P13

    # Cria produto para ter um ID válido
    ${resp_prod}=    Criar Produto    ${TOKEN_ADMIN_SUITE}
    Validar Status Code    ${resp_prod}    201
    ${id}=    Set Variable    ${resp_prod.json()}[_id]

    # Tenta atualizar sem token (headers vazios = sem Authorization)
    ${body}=     Montar Body De Produto    Produto Atualizado Sem Token
    ${headers}=  Create Dictionary    Content-Type=application/json
    ${resp}=     PUT On Session    ${SESSION}    /produtos/${id}    json=${body}    headers=${headers}    expected_status=any

    Validar Status E Mensagem    ${resp}    401    ${MSG_TOKEN_INVALIDO}


# ════════════════════════════════════════════════════════════════════
# BLOCO 3 — CONTRATO
# ════════════════════════════════════════════════════════════════════

CT-P11 - Validar contrato completo do response de criacao de produto
    # Caso   : CT-P11
    # Tipo   : Contrato
    # Rota   : POST /produtos (payload válido com token admin)
    # Oráculo: 201 · exatamente 2 campos: _id (string) e message (string)
    [Documentation]    Verifica que o response de criação de produto possui exatamente
    ...                os campos "_id" e "message", sem campos adicionais inesperados.
    [Tags]    produto    contrato    CT-P11

    ${resp}=    Criar Produto    ${TOKEN_ADMIN_SUITE}

    Validar Status Code          ${resp}    201
    Validar Contrato Do Produto  ${resp}


# ════════════════════════════════════════════════════════════════════
# BLOCO 4 — EVIDÊNCIAS DE BUG (falham intencionalmente)
# ════════════════════════════════════════════════════════════════════

CT-P07 - Evidenciar coercao de tipo no campo preco - BUG-04
    # Caso   : CT-P07
    # Tipo   : Bug / Validação de tipo (coerção implícita)
    # Rota   : POST /produtos (preco="10" como string JSON)
    # Oráculo esperado : 400 (type mismatch)
    # Comportamento BUG: API aceita string e retorna 201 — risco em cálculos de total
    [Documentation]    BUG-03 (Média severidade): a API aceita preco="10" (string) em vez
    ...                de rejeitar o type mismatch com 400.
    ...                Este teste FALHA intencionalmente para evidenciar o bug.
    [Tags]    produto    negativo    bug    BUG-03    CT-P07

    ${nome}=    Gerar Nome De Produto Unico
    # PRECO_STRING = "10" (string) — deve ser rejeitado, mas API aceita (BUG-03)
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${PRECO_STRING}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${QUANTIDADE_VALIDA}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Produto Com Body Customizado    ${body}    ${headers}

    IF    ${resp.status_code} == 201
        produto_keywords.Registrar Bug Evidenciado
        ...    BUG-03
        ...    API retornou 201 — preco="10" (string) aceito sem rejeição de type mismatch
    END

    # Oráculo correto: 400. O assert abaixo falha enquanto o bug existir.
    Validar Status Code    ${resp}    400

CT-P09 - DELETE produto com ID inexistente retorna 400
    # Caso   : CT-P09
    # Tipo   : Negativo
    # Rota   : DELETE /produtos/:id (ID que não existe no banco)
    # Oráculo: 400 (Bad Request para ID inválido)
    [Documentation]    Verifica que DELETE de produto com ID inexistente retorna 400.
    ...                A API corretamente rejeita a operação com Bad Request.
    [Tags]    produto    negativo    CT-P09

    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}
    ${resp}=    DELETE On Session
    ...    ${SESSION}
    ...    /produtos/id_jamais_existiu_no_banco_xyz_999
    ...    headers=${headers}
    ...    expected_status=any

    Validar Status Code    ${resp}    400
