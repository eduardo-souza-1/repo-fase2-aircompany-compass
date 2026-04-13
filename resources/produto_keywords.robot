* Settings *
Documentation    Keywords reutilizáveis para o domínio /produtos — ServeRest QA.
...              Responsabilidade: operações CRUD, geração de dados e validações.
...              NÃO contém lógica de teste — apenas blocos reutilizáveis.
Library          RequestsLibrary
Library          Collections
Library          FakerLibrary
Resource         api.robot
Resource         login_keywords.robot
Variables        ../variables/variables.py

* Variables *
@{PRODUTOS_CRIADOS}    # lista de _id para limpeza automática


# ════════════════════════════════════════════════════════════════════
# GERAÇÃO DE DADOS
# ════════════════════════════════════════════════════════════════════

* Keywords *
Gerar Nome De Produto Unico
    [Documentation]    Gera nome de produto único via FakerLibrary.
    ...                Retorna: nome como string.
    ${nome}=    FakerLibrary.Word
    RETURN    ${nome}

Montar Body De Produto
    [Documentation]    Constrói payload JSON para POST/PUT /produtos.
    ...                Todos os parâmetros têm valores padrão para facilitar cenários positivos.
    [Arguments]
    ...    ${nome}
    ...    ${preco}=${PRECO_VALIDO}
    ...    ${descricao}=${DESCRICAO_VALIDA}
    ...    ${quantidade}=${QUANTIDADE_VALIDA}
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    RETURN    ${body}


# ════════════════════════════════════════════════════════════════════
# OPERAÇÕES HTTP — PRODUTO
# ════════════════════════════════════════════════════════════════════

Criar Produto
    [Documentation]    POST /produtos com token de administrador e nome gerado automaticamente.
    ...                Registra _id em PRODUTOS_CRIADOS para cleanup automático.
    ...                Retorna: response completo.
    [Arguments]
    ...    ${token}
    ...    ${preco}=${PRECO_VALIDO}
    ...    ${quantidade}=${QUANTIDADE_VALIDA}
    ${nome}=    Gerar Nome De Produto Unico
    ${body}=    Montar Body De Produto    ${nome}    preco=${preco}    quantidade=${quantidade}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    POST On Session    ${SESSION}    /produtos    json=${body}    headers=${headers}    expected_status=any
    IF    ${resp.status_code} == 201
        Append To List    ${PRODUTOS_CRIADOS}    ${resp.json()}[_id]
    END
    RETURN    ${resp}

Criar Produto Com Body Customizado
    [Documentation]    POST /produtos com payload e headers arbitrários (para cenários negativos).
    ...                Registra _id em PRODUTOS_CRIADOS se a resposta for 201.
    ...                Retorna: response completo.
    [Arguments]    ${body}    ${headers}
    ${resp}=    POST On Session    ${SESSION}    /produtos    json=${body}    headers=${headers}    expected_status=any
    IF    ${resp.status_code} == 201
        Append To List    ${PRODUTOS_CRIADOS}    ${resp.json()}[_id]
    END
    RETURN    ${resp}

Buscar Produto Por Id
    [Documentation]    GET /produtos/{id} — retorna response completo.
    [Arguments]    ${id}
    ${resp}=    GET On Session    ${SESSION}    /produtos/${id}    expected_status=any
    RETURN    ${resp}

Buscar Produtos Com Filtro
    [Documentation]    GET /produtos com parâmetros de query — retorna response completo.
    [Arguments]    ${params}
    ${resp}=    GET On Session    ${SESSION}    /produtos    params=${params}    expected_status=any
    RETURN    ${resp}

Atualizar Produto Via PUT
    [Documentation]    PUT /produtos/{id} com body e token informados — retorna response completo.
    [Arguments]    ${id}    ${body}    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resp}=    PUT On Session    ${SESSION}    /produtos/${id}    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${resp}

Deletar Produto
    [Documentation]    DELETE /produtos/{id} com token — idempotente (ignora 404).
    [Arguments]    ${id}    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}
    DELETE On Session    ${SESSION}    /produtos/${id}    headers=${headers}    expected_status=any

Limpar Produtos Criados
    [Documentation]    Remove todos os produtos registrados durante a suite.
    ...                Idempotente: ignora 404 sem falhar. Requer token de administrador.
    [Arguments]    ${token}
    FOR    ${id}    IN    @{PRODUTOS_CRIADOS}
        Run Keyword And Ignore Error
        ...    Deletar Produto    ${id}    ${token}
    END


# ════════════════════════════════════════════════════════════════════
# VALIDAÇÕES REUTILIZÁVEIS — PRODUTO
# ════════════════════════════════════════════════════════════════════

Validar Persistencia Do Produto
    [Documentation]    Faz GET /produtos/{id} e confirma que os campos nome e quantidade
    ...                correspondem aos valores informados.
    [Arguments]    ${id}    ${nome_esperado}    ${quantidade_esperada}
    ${get}=    Buscar Produto Por Id    ${id}
    Should Be Equal As Numbers    ${get.status_code}    200
    Should Be Equal As Strings    ${get.json()}[nome]          ${nome_esperado}
    Should Be Equal As Numbers    ${get.json()}[quantidade]    ${quantidade_esperada}

Validar Ausencia Do Produto Na Listagem
    [Documentation]    Filtra /produtos por nome e confirma que nenhum resultado é retornado.
    ...                Útil para garantir que produto rejeitado não foi criado.
    [Arguments]    ${nome}
    ${params}=    Create Dictionary    nome=${nome}
    ${get}=       Buscar Produtos Com Filtro    ${params}
    Should Be Equal As Numbers    ${get.status_code}    200
    Should Be Equal As Numbers    ${get.json()}[quantidade]    0

Validar Contrato Do Produto
    [Documentation]    Confirma que o response de criação de produto possui exatamente 2 campos:
    ...                "_id" (string não-vazia) e "message" (string).
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

Validar Estrutura Da Listagem De Produtos
    [Documentation]    Confirma que GET /produtos retorna os campos "quantidade" (int)
    ...                e "produtos" (list) com os tipos corretos.
    [Arguments]    ${resp}
    ${json}=    Set Variable    ${resp.json()}
    Dictionary Should Contain Key    ${json}    quantidade
    Dictionary Should Contain Key    ${json}    produtos
    Should Be True    isinstance($json['quantidade'], int)
    Should Be True    isinstance($json['produtos'], list)

Registrar Bug Evidenciado
    [Documentation]    Loga um aviso de BUG confirmado quando a API aceita dados inválidos.
    ...                Reutilizado dos padrões do domínio /usuarios.
    [Arguments]    ${id_bug}    ${detalhe}
    Log    ${id_bug} CONFIRMADO: ${detalhe}    WARN