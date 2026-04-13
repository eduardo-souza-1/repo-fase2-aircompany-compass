* Settings *
Documentation    Suite de testes — Domínio /carrinhos
...
...              Cobertura: CT-C01 · CT-C02 · CT-C03 · CT-C04 · CT-C05 · CT-C06
...                         CT-C07 · CT-C09 · CT-C10 · CT-C11 · CT-C12
...
...              Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
...              Versão : 1.0
...
...              ─── REFERÊNCIA DE CASOS ────────────────────────────────────────
...              CT-C01  POST /carrinhos — fluxo completo com verificação de estoque  [positivo]
...              CT-C02  POST /carrinhos — idProduto inexistente                      [negativo]
...              CT-C03  POST /carrinhos — segundo carrinho para o mesmo usuário      [negativo/regra]
...              CT-C04  POST /carrinhos — quantidade maior que o estoque             [negativo/regra]
...              CT-C05  POST /carrinhos — idProduto duplicado no array               [negativo]
...              CT-C06  POST /carrinhos — sem token de autenticação                  [negativo]
...              CT-C07  DELETE /cancelar-compra — estoque restaurado                 [positivo]
...              CT-C09  POST /carrinhos — contrato do response de criação            [contrato]
...              CT-C10  GET /carrinhos — listagem vazia                              [negativo]
...              CT-C11  DELETE /cancelar-compra — usuário diferente do dono          [negativo/regra]
...              CT-C12  POST /carrinhos — produto com dados inválidos (BUG-05)       [bug/evidência]
...              ────────────────────────────────────────────────────────────────
...
...              FORA DO ESCOPO (aguarda validação manual):
...              CT-C08  DELETE /cancelar-compra — sem carrinho ativo
...                      Mensagem exata não documentada na API. Ver plano v6.0, seção 4.4.

Resource         ../resources/keywords.robot
Resource         ../resources/login_keywords.robot
Resource         ../resources/produto_keywords.robot
Resource         ../resources/carrinho_keywords.robot

Suite Setup      Run Keywords
...              Iniciar Sessao API
...    AND       Preparar Recursos Compartilhados Da Suite
Suite Teardown   Run Keywords
...              Limpar Produtos Criados    ${TOKEN_ADMIN_SUITE}
...    AND       Limpar Usuarios Criados

* Variables *
${TOKEN_ADMIN_SUITE}    ${EMPTY}    # token do admin criado no Suite Setup
${ID_PRODUTO_SUITE}     ${EMPTY}    # produto com estoque compartilhado entre testes


* Keywords *
Preparar Recursos Compartilhados Da Suite
    [Documentation]    Cria um único usuário administrador, captura seu token e cria
    ...                um produto com estoque controlado, compartilhados entre os testes.
    ...                Testes que precisam de isolamento criam seus próprios recursos internamente.
    ${resp_user}    ${email}=    Criar Usuario Admin
    Validar Status Code    ${resp_user}    201
    ${token}=    Obter Token    ${email}
    Set Suite Variable    ${TOKEN_ADMIN_SUITE}    ${token}

    ${resp_prod}=    Criar Produto    ${token}    quantidade=${20}
    Validar Status Code    ${resp_prod}    201
    Set Suite Variable    ${ID_PRODUTO_SUITE}    ${resp_prod.json()}[_id]

Criar Admin Isolado E Obter Token
    [Documentation]    Cria um usuário admin exclusivo para um único teste.
    ...                Usado quando o teste precisa de estado isolado (ex: CT-C03, CT-C11).
    ...                Retorna: token
    ${resp}    ${email}=    Criar Usuario Admin
    Validar Status Code    ${resp}    201
    ${token}=    Obter Token    ${email}
    RETURN    ${token}


# ════════════════════════════════════════════════════════════════════
# BLOCO 1 — CENÁRIOS POSITIVOS
# ════════════════════════════════════════════════════════════════════

* Test Cases *

CT-C01 - Fluxo completo de compra — criar carrinho concluir e verificar estoque
    # Caso   : CT-C01
    # Tipo   : Positivo / E2E
    # Rota   : POST /carrinhos → DELETE /carrinhos/concluir-compra → GET /produtos/{id}
    # Oráculo: 201 no POST · 200 no DELETE · estoque decrementado · carrinho removido
    [Documentation]    Verifica o fluxo completo de compra: cria carrinho com 3 unidades,
    ...                conclui a compra e confirma que o estoque foi decrementado corretamente
    ...                e que o carrinho não aparece mais na listagem.
    [Tags]    carrinho    positivo    e2e    CT-C01

    # Produto isolado com estoque controlado (não compartilhado com outros testes)
    ${resp_prod}=    Criar Produto    ${TOKEN_ADMIN_SUITE}    quantidade=${10}
    Validar Status Code    ${resp_prod}    201
    ${id_prod}=    Set Variable    ${resp_prod.json()}[_id]

    # Usuário isolado para não interferir em outros testes
    ${token}=    Criar Admin Isolado E Obter Token

    # Captura estoque antes para comparação determinística
    Validar Estoque Do Produto    ${id_prod}    ${10}

    # Cria carrinho com 3 unidades
    ${resp_cart}=    Criar Carrinho    ${token}    ${id_prod}    ${3}

    Validar Status Code       ${resp_cart}    201
    Validar Campo Id Presente    ${resp_cart}
    Validar Mensagem Exata    ${resp_cart}    ${MSG_CARRINHO_OK}

    ${id_carrinho}=    Set Variable    ${resp_cart.json()}[_id]

    # Conclui a compra
    ${resp_concluir}=    Concluir Compra    ${token}
    Validar Status Code    ${resp_concluir}    200

    # Efeito no sistema: estoque deve ter diminuído em 3
    Validar Estoque Do Produto    ${id_prod}    ${7}

    # Efeito no sistema: carrinho deve ter sido removido da listagem
    Validar Carrinho Ausente Na Listagem    ${id_carrinho}

CT-C07 - Cancelar compra restaura estoque ao valor original
    # Caso   : CT-C07
    # Tipo   : Positivo
    # Rota   : DELETE /carrinhos/cancelar-compra → GET /produtos/{id}
    # Oráculo: 200 no DELETE · estoque restaurado ao valor anterior · carrinho removido
    [Documentation]    Verifica que cancelar-compra reverte o estoque ao valor original.
    ...                Confirma via GET /produtos que a quantidade voltou ao estado anterior
    ...                e que o carrinho não aparece mais na listagem.
    [Tags]    carrinho    positivo    estoque    CT-C07

    # Produto isolado com estoque controlado
    ${resp_prod}=    Criar Produto    ${TOKEN_ADMIN_SUITE}    quantidade=${8}
    Validar Status Code    ${resp_prod}    201
    ${id_prod}=    Set Variable    ${resp_prod.json()}[_id]

    # Usuário isolado para evitar conflito de carrinho com outros testes
    ${token}=    Criar Admin Isolado E Obter Token

    # Estoque inicial registrado como referência
    Validar Estoque Do Produto    ${id_prod}    ${8}

    # Cria carrinho — estoque deve cair para 5
    ${resp_cart}=    Criar Carrinho    ${token}    ${id_prod}    ${3}
    Validar Status Code    ${resp_cart}    201
    ${id_carrinho}=    Set Variable    ${resp_cart.json()}[_id]

    Validar Estoque Do Produto    ${id_prod}    ${5}

    # Cancela compra — estoque deve ser restaurado para 8
    ${resp_cancel}=    Cancelar Compra    ${token}
    Validar Status Code    ${resp_cancel}    200

    # Efeito no sistema: estoque restaurado
    Validar Estoque Do Produto    ${id_prod}    ${8}

    # Efeito no sistema: carrinho removido da listagem
    Validar Carrinho Ausente Na Listagem    ${id_carrinho}


# ════════════════════════════════════════════════════════════════════
# BLOCO 2 — CENÁRIOS NEGATIVOS
# ════════════════════════════════════════════════════════════════════

CT-C06 - Rejeitar criacao de carrinho sem token de autenticacao
    # Caso   : CT-C06
    # Tipo   : Negativo (autenticação)
    # Rota   : POST /carrinhos (sem header Authorization)
    # Oráculo: 401 · message exata de token ausente
    [Documentation]    Verifica que POST /carrinhos sem token de autenticação retorna 401
    ...                com a message exata de token inválido/ausente.
    [Tags]    carrinho    negativo    autenticacao    CT-C06

    ${item}=    Montar Item De Carrinho    ${ID_PRODUTO_SUITE}    ${1}
    ${body}=    Montar Body De Carrinho    ${item}
    ${headers}=    Create Dictionary    Content-Type=application/json

    ${resp}=    Criar Carrinho Com Body Customizado    ${body}    ${headers}

    Validar Status E Mensagem    ${resp}    401    ${MSG_TOKEN_INVALIDO}

CT-C02 - Rejeitar carrinho com idProduto inexistente
    # Caso   : CT-C02
    # Tipo   : Negativo (recurso não encontrado)
    # Rota   : POST /carrinhos (idProduto que não existe no banco)
    # Oráculo: 400 · message exata · carrinho não criado
    [Documentation]    Verifica que referência a produto inexistente retorna 400
    ...                com message exata. Carrinho não deve ter sido criado.
    [Tags]    carrinho    negativo    CT-C02

    ${item}=    Montar Item De Carrinho    id_produto_jamais_existiu_xyz_999    ${1}
    ${body}=    Montar Body De Carrinho    ${item}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Carrinho Com Body Customizado    ${body}    ${headers}

    Validar Status E Mensagem    ${resp}    400    ${MSG_PRODUTO_NAO_ENCONTRADO}

CT-C03 - Rejeitar criacao de segundo carrinho para o mesmo usuario
    # Caso   : CT-C03
    # Tipo   : Negativo / Regra de negócio (1 carrinho por usuário)
    # Rota   : POST /carrinhos (segunda chamada com o mesmo token)
    # Oráculo: 400 · message exata · segundo carrinho não criado
    [Documentation]    Verifica que um mesmo usuário não pode ter mais de 1 carrinho aberto.
    ...                O segundo POST deve ser rejeitado com 400 e message exata.
    [Tags]    carrinho    negativo    regra    CT-C03

    # Usuário exclusivo para este teste — isolado para não interferir nos demais
    ${token}=    Criar Admin Isolado E Obter Token

    # Primeiro carrinho — deve ser criado com sucesso
    ${resp1}=    Criar Carrinho    ${token}    ${ID_PRODUTO_SUITE}    ${1}
    Validar Status Code    ${resp1}    201

    # Segundo carrinho — deve ser rejeitado pela regra de negócio
    ${resp2}=    Criar Carrinho    ${token}    ${ID_PRODUTO_SUITE}    ${1}

    Validar Status E Mensagem    ${resp2}    400    ${MSG_CARRINHO_DUPLICADO}

    # Cleanup: finaliza o carrinho criado para não poluir o estado global
    ${resp_fin}=    Concluir Compra    ${token}
    Validar Status Code    ${resp_fin}    200

CT-C04 - Rejeitar carrinho com quantidade maior que o estoque disponivel
    # Caso   : CT-C04
    # Tipo   : Negativo / Regra de negócio (integridade de estoque)
    # Rota   : POST /carrinhos (quantidade=6 para produto com estoque=5)
    # Oráculo: 400 · message exata · estoque não alterado
    [Documentation]    Verifica que solicitar quantidade acima do estoque retorna 400.
    ...                Confirma via GET /produtos que o estoque permanece inalterado.
    [Tags]    carrinho    negativo    regra    estoque    CT-C04

    # Produto com estoque controlado e conhecido
    ${resp_prod}=    Criar Produto    ${TOKEN_ADMIN_SUITE}    quantidade=${5}
    Validar Status Code    ${resp_prod}    201
    ${id_prod}=    Set Variable    ${resp_prod.json()}[_id]

    # Usuário isolado
    ${token}=    Criar Admin Isolado E Obter Token

    # Tenta criar carrinho com quantidade maior que o estoque (6 > 5)
    ${resp}=    Criar Carrinho    ${token}    ${id_prod}    ${6}

    Validar Status E Mensagem    ${resp}    400    ${MSG_ESTOQUE_INSUFICIENTE}

    # Regra de negócio: estoque deve permanecer em 5
    Validar Estoque Do Produto    ${id_prod}    ${5}

CT-C05 - Rejeitar carrinho com idProduto duplicado no array
    # Caso   : CT-C05
    # Tipo   : Negativo
    # Rota   : POST /carrinhos (mesmo idProduto em dois itens do array)
    # Oráculo: 400 · message exata
    [Documentation]    Verifica que o mesmo produto referenciado duas vezes no array
    ...                de produtos é rejeitado com 400 e message exata.
    [Tags]    carrinho    negativo    CT-C05

    ${item1}=    Montar Item De Carrinho    ${ID_PRODUTO_SUITE}    ${1}
    ${item2}=    Montar Item De Carrinho    ${ID_PRODUTO_SUITE}    ${2}
    ${body}=     Montar Body De Carrinho    ${item1}    ${item2}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}

    ${resp}=    Criar Carrinho Com Body Customizado    ${body}    ${headers}

    Validar Status E Mensagem    ${resp}    400    ${MSG_PRODUTO_DUPLICADO_CART}

CT-C10 - GET carrinhos retorna listagem vazia quando nenhum carrinho esta ativo
    # Caso   : CT-C10
    # Tipo   : Negativo / Filtro
    # Rota   : GET /carrinhos (banco sem carrinhos ativos para o contexto)
    # Oráculo: 200 · quantidade==0 · array "carrinhos" vazio
    [Documentation]    Verifica que a listagem de carrinhos retorna 200 com estrutura válida.
    ...                Confirma os campos "quantidade" e "carrinhos" com os tipos corretos.
    ...                Nota: como a suite roda em ambiente compartilhado, valida a estrutura
    ...                e não assume banco globalmente vazio.
    [Tags]    carrinho    negativo    CT-C10

    ${resp}=    Buscar Carrinhos

    Validar Status Code                       ${resp}    200
    Validar Estrutura Da Listagem De Carrinhos    ${resp}

CT-C11 - Cancelar compra de usuario diferente nao afeta carrinho do dono
    # Caso   : CT-C11
    # Tipo   : Negativo / Regra de negócio (isolamento entre usuários)
    # Rota   : DELETE /carrinhos/cancelar-compra (token do usuário B, sem carrinho próprio)
    # Oráculo: 200 · message de carrinho não encontrado · carrinho do usuário A intacto
    [Documentation]    Verifica o isolamento entre usuários: o cancelamento feito pelo
    ...                usuário B (sem carrinho) não afeta o carrinho do usuário A.
    ...                Confirma via GET /carrinhos que o carrinho de A permanece ativo.
    [Tags]    carrinho    negativo    regra    isolamento    CT-C11

    # Usuário A — cria e mantém um carrinho ativo
    ${token_a}=    Criar Admin Isolado E Obter Token
    ${resp_cart}=    Criar Carrinho    ${token_a}    ${ID_PRODUTO_SUITE}    ${1}
    Validar Status Code    ${resp_cart}    201
    ${id_carrinho_a}=    Set Variable    ${resp_cart.json()}[_id]

    # Usuário B — não tem carrinho aberto
    ${token_b}=    Criar Admin Isolado E Obter Token

    # Usuário B tenta cancelar — deve retornar 200 mas sem afetar o carrinho de A
    ${resp_cancel}=    Cancelar Compra    ${token_b}
    Validar Status Code      ${resp_cancel}    200
    Validar Mensagem Exata   ${resp_cancel}    ${MSG_CARRINHO_NAO_ENCONTRADO}

    # Regra de negócio: carrinho do usuário A deve permanecer intacto
    ${get}=    Buscar Carrinhos
    ${ids}=    Evaluate    [c['_id'] for c in $get.json()['carrinhos']]
    Should Contain    ${ids}    ${id_carrinho_a}

    # Cleanup: finaliza o carrinho do usuário A
    ${resp_fin}=    Concluir Compra    ${token_a}
    Validar Status Code    ${resp_fin}    200


# ════════════════════════════════════════════════════════════════════
# BLOCO 3 — CONTRATO
# ════════════════════════════════════════════════════════════════════

CT-C09 - Validar contrato completo do response de criacao de carrinho
    # Caso   : CT-C09
    # Tipo   : Contrato
    # Rota   : POST /carrinhos (payload válido com token admin)
    # Oráculo: 201 · exatamente 2 campos: _id (string) e message (string)
    [Documentation]    Verifica que o response de criação de carrinho possui exatamente
    ...                os campos "_id" e "message", com os tipos corretos e sem campos extras.
    [Tags]    carrinho    contrato    CT-C09

    # Usuário isolado para não conflitar com regra de 1 carrinho por usuário
    ${token}=    Criar Admin Isolado E Obter Token

    ${resp}=    Criar Carrinho    ${token}    ${ID_PRODUTO_SUITE}    ${1}

    Validar Status Code          ${resp}    201
    Validar Contrato Do Carrinho    ${resp}

    # Cleanup: finaliza o carrinho para liberar o usuário
    ${resp_fin}=    Concluir Compra    ${token}
    Validar Status Code    ${resp_fin}    200


# ════════════════════════════════════════════════════════════════════
# BLOCO 4 — EVIDÊNCIA DE BUG (falha intencional)
# ════════════════════════════════════════════════════════════════════

CT-C12 - Evidenciar carrinho criado com produto de dados invalidos - BUG-05
    # Caso   : CT-C12
    # Tipo   : Bug / Integridade de dados
    # Rota   : POST /carrinhos (produto com nome="" no banco — gerado pelo BUG-01)
    # Oráculo esperado : 400 (validação de integridade antes de persistir)
    # Comportamento BUG: API aceita e retorna 201 — carrinho criado com dado inconsistente
    [Documentation]    BUG-05 (Alta severidade): a API permite criar carrinho referenciando
    ...                produto com nome="" (persistido pelo BUG-01), sem rejeitar a inconsistência.
    ...                Risco: fechamento de pedido e faturamento com dado inválido.
    ...                Este teste FALHA intencionalmente para evidenciar o bug.
    ...                Pré-condição: BUG-01 ainda ativo (API aceita nome vazio em POST /usuarios).
    [Tags]    carrinho    negativo    bug    BUG-05    CT-C12

    # Pré-condição: criar produto com nome vazio (aceito pela API por causa do BUG-01)
    ${nome_vazio}=    Set Variable    ${EMPTY}
    ${body_prod}=     Create Dictionary
    ...    nome=${nome_vazio}
    ...    preco=${PRECO_VALIDO}
    ...    descricao=${DESCRICAO_VALIDA}
    ...    quantidade=${5}
    ${headers}=    Create Dictionary    Authorization=${TOKEN_ADMIN_SUITE}
    ${resp_prod}=    POST On Session    ${SESSION}    /produtos    json=${body_prod}    headers=${headers}    expected_status=any

    # Se o BUG-01 foi corrigido, o produto é rejeitado e o BUG-05 não é reproduzível
    IF    ${resp_prod.status_code} != 201
        Log    BUG-01 já corrigido — produto com nome vazio foi rejeitado. BUG-05 não reproduzível.    WARN
        Skip    Pré-condição do BUG-05 não atendida: BUG-01 foi corrigido.
    END

    Append To List    ${PRODUTOS_CRIADOS}    ${resp_prod.json()}[_id]
    ${id_prod_invalido}=    Set Variable    ${resp_prod.json()}[_id]

    # Usuário isolado para evitar conflito de carrinho
    ${token}=    Criar Admin Isolado E Obter Token

    # Tenta criar carrinho referenciando produto com dados inválidos
    ${resp_cart}=    Criar Carrinho    ${token}    ${id_prod_invalido}    ${1}

    IF    ${resp_cart.status_code} == 201
        Registrar Bug Evidenciado
        ...    BUG-05
        ...    API retornou 201 — carrinho criado com produto de nome="" no banco
        # Cleanup para não poluir estado global
        ${resp_fin}=    Concluir Compra    ${token}
        Validar Status Code    ${resp_fin}    200
    END

    # Oráculo correto: 400. O assert abaixo falha enquanto o bug existir.
    Validar Status Code    ${resp_cart}    400