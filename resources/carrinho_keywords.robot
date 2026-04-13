* Settings *
Documentation    Keywords reutilizáveis para o domínio /carrinhos — ServeRest QA.
...              Responsabilidade: operações de criação, finalização, cancelamento e validações.
...              NÃO contém lógica de teste — apenas blocos reutilizáveis.
Library          RequestsLibrary
Library          Collections
Resource         api.robot
Resource         login_keywords.robot
Resource         produto_keywords.robot
Variables        ../variables/variables.py


# ════════════════════════════════════════════════════════════════════
# OPERAÇÕES HTTP — CARRINHO
# ════════════════════════════════════════════════════════════════════

* Keywords *
Montar Item De Carrinho
    [Documentation]    Constrói um dicionário representando um item do array "produtos".
    ...                Retorna: dict {idProduto, quantidade}
    [Arguments]    ${id_produto}    ${quantidade}=${1}
    ${item}=    Create Dictionary    idProduto=${id_produto}    quantidade=${quantidade}
    RETURN    ${item}

Montar Body De Carrinho
    [Documentation]    Constrói payload JSON para POST /carrinhos a partir de uma lista de itens.
    ...                Retorna: dict {produtos: [...]}
    [Arguments]    @{itens}
    ${lista}=    Create List    @{itens}
    ${body}=     Create Dictionary    produtos=${lista}
    RETURN    ${body}

Criar Carrinho
    [Documentation]    POST /carrinhos com token e um único produto.
    ...                Atalho para o cenário mais comum — 1 produto, quantidade configurável.
    ...                Retorna: response completo.
    [Arguments]    ${token}    ${id_produto}    ${quantidade}=${1}
    ${item}=    Montar Item De Carrinho    ${id_produto}    ${quantidade}
    ${body}=    Montar Body De Carrinho    ${item}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    POST On Session    ${SESSION}    /carrinhos    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${resp}

Criar Carrinho Com Body Customizado
    [Documentation]    POST /carrinhos com payload e headers arbitrários.
    ...                Usado para cenários negativos com arrays ou payloads incomuns.
    ...                Retorna: response completo.
    [Arguments]    ${body}    ${headers}
    ${resp}=    POST On Session    ${SESSION}    /carrinhos    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${resp}

Buscar Carrinhos
    [Documentation]    GET /carrinhos — retorna response completo da listagem.
    ${resp}=    GET On Session    ${SESSION}    /carrinhos    expected_status=any
    RETURN    ${resp}

Concluir Compra
    [Documentation]    DELETE /carrinhos/concluir-compra com token informado.
    ...                Decrementa estoque e remove o carrinho do usuário.
    ...                Retorna: response completo.
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    DELETE On Session    ${SESSION}    /carrinhos/concluir-compra    headers=${headers}    expected_status=any
    RETURN    ${resp}

Cancelar Compra
    [Documentation]    DELETE /carrinhos/cancelar-compra com token informado.
    ...                Restaura o estoque e remove o carrinho do usuário.
    ...                Retorna: response completo.
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    DELETE On Session    ${SESSION}    /carrinhos/cancelar-compra    headers=${headers}    expected_status=any
    RETURN    ${resp}


# ════════════════════════════════════════════════════════════════════
# VALIDAÇÕES REUTILIZÁVEIS — CARRINHO
# ════════════════════════════════════════════════════════════════════

Validar Contrato Do Carrinho
    [Documentation]    Confirma que o response de criação de carrinho possui exatamente
    ...                2 campos: "_id" (string não-vazia) e "message" (string).
    ...                Nenhum campo adicional inesperado deve estar presente.
    [Arguments]    ${resp}
    ${json}=     Set Variable    ${resp.json()}
    ${chaves}=   Get Dictionary Keys    ${json}
    Length Should Be    ${chaves}    2
    Dictionary Should Contain Key    ${json}    _id
    Dictionary Should Contain Key    ${json}    message
    Should Not Be Empty    ${json}[_id]
    Should Be True    isinstance($json['_id'], str)
    Should Be True    isinstance($json['message'], str)

Validar Estrutura Da Listagem De Carrinhos
    [Documentation]    Confirma que GET /carrinhos retorna os campos "quantidade" (int)
    ...                e "carrinhos" (list) com os tipos corretos.
    [Arguments]    ${resp}
    ${json}=    Set Variable    ${resp.json()}
    Dictionary Should Contain Key    ${json}    quantidade
    Dictionary Should Contain Key    ${json}    carrinhos
    Should Be True    isinstance($json['quantidade'], int)
    Should Be True    isinstance($json['carrinhos'], list)

Validar Estoque Do Produto
    [Documentation]    Faz GET /produtos/{id} e confirma que o estoque atual bate
    ...                com o valor esperado. Usado para verificar efeito no sistema.
    [Arguments]    ${id_produto}    ${quantidade_esperada}
    ${get}=    Buscar Produto Por Id    ${id_produto}
    Should Be Equal As Numbers    ${get.status_code}    200
    Should Be Equal As Numbers    ${get.json()}[quantidade]    ${quantidade_esperada}

Validar Carrinho Ausente Na Listagem
    [Documentation]    Confirma que o _id do carrinho informado NÃO aparece
    ...                em GET /carrinhos. Usado após concluir ou cancelar compra.
    [Arguments]    ${id_carrinho}
    ${resp}=    Buscar Carrinhos
    Should Be Equal As Numbers    ${resp.status_code}    200
    ${ids}=    Evaluate    [c['_id'] for c in $resp.json()['carrinhos']]
    Should Not Contain    ${ids}    ${id_carrinho}

Validar Listagem De Carrinhos Vazia
    [Documentation]    Confirma que GET /carrinhos retorna quantidade=0 e array vazio.
    [Arguments]    ${resp}
    Should Be Equal As Numbers    ${resp.json()}[quantidade]    0
    ${lista}=    Set Variable    ${resp.json()}[carrinhos]
    Length Should Be    ${lista}    0

Registrar Bug Evidenciado
    [Documentation]    Loga aviso de BUG confirmado — reutilizado do padrão dos outros domínios.
    [Arguments]    ${id_bug}    ${detalhe}
    Log    ${id_bug} CONFIRMADO: ${detalhe}    WARN