*** Settings ***
Documentation    Keywords de infraestrutura da API ServeRest.
...              Responsabilidade: sessão HTTP, setup e teardown de suite.
...              Escopo: reutilizável por qualquer suite do projeto.
Library          RequestsLibrary
Library          Collections
Variables        ../variables/variables.py

*** Variables ***
@{USUARIOS_CRIADOS}    # lista de _id para limpeza automática

# ════════════════════════════════════════════════════════════════════
# SETUP / TEARDOWN
# ════════════════════════════════════════════════════════════════════

*** Keywords ***
Iniciar Sessao API
    [Documentation]    Abre sessão HTTP com a API e inicializa lista de cleanup.
    Create Session    ${SESSION}    ${BASE_URL}    verify=True
    Set Suite Variable    @{USUARIOS_CRIADOS}    @{EMPTY}

Limpar Usuarios Criados
    [Documentation]    Remove todos os usuários registrados durante a suite.
    ...                Idempotente: ignora 404 sem falhar.
    FOR    ${id}    IN    @{USUARIOS_CRIADOS}
        Run Keyword And Ignore Error
        ...    DELETE On Session    ${SESSION}    /usuarios/${id}    expected_status=any
    END
