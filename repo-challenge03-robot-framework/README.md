# Challenge 03  Automacao de Testes de API com Robot Framework

Testes automatizados da API [ServeRest](https://compassuol.serverest.dev) cobrindo fluxos de usuario, produto, carrinho e autenticacao.


## Estrutura


resources/
  api_keywords.robot   # keywords reutilizaveis e controle de teardown
  massa.robot          # variaveis centralizadas de dados e configuracao

tests/
  carrinho/            # autenticacao no acesso ao carrinho
  contrato/            # contrato do response de login
  fluxo/               # fluxo positivo de compra e fluxo negativo de permissao
  produto/             # validacoes de criacao de produto
  usuario/             # validacoes de criacao de usuario


## Pre-requisitos

- Python 3.8+
- pip



## Instalacao

pip install -r requirements.txt



## Execucao

Rodar todos os testes:

robot -d results tests


Rodar uma suite especifica:

robot -d results tests/fluxo
robot -d results tests/produto


Rodar um unico arquivo:

robot -d results tests/fluxo/fluxo_positivo.robot


## Relatorio

Apos a execucao os resultados ficam em results/:


results/
  log.html      # log detalhado de cada keyword executada
  report.html   # visao geral de passes e falhas
  output.xml    # saida bruta para integracao com CI

Abra report.html no navegador para visualizar o resultado completo.


## Massa de dados e limpeza

Todos os dados criados durante os testes (usuarios e produtos) sao deletados automaticamente ao final de cada suite via Suite Teardown. Cada execucao comeca e termina com o ambiente no mesmo estado  sem residuos no banco.