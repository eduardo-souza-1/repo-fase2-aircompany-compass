# Suite de Testes da API ServeRest

Suíte de testes simples e limpa em Robot Framework para a API ServeRest.

## Estrutura

```
.
├── resources/
│   └── api.robot              # Todas as keywords da API em um único arquivo
├── tests/
│   ├── user_tests.robot       # Testes de validação de usuários
│   ├── product_tests.robot    # Testes de validação de produtos
│   ├── cart_tests.robot       # Testes de autenticação do carrinho
│   ├── contract_tests.robot   # Testes de contrato da API
│   └── flow_tests.robot       # Testes de fluxo end-to-end
└── requirements.txt
```

## Instalação

```bash
pip install -r requirements.txt
```

## Executando os Testes

Executar todos os testes:
```bash
robot tests/
```

Executar arquivo específico:
```bash
robot tests/user_tests.robot
```

Executar por tag:
```bash
robot --include negativo tests/
robot --include smoke tests/
```

## Cobertura de Testes

- **Testes de Usuário**: Validação de email, segurança XSS
- **Testes de Produto**: Validação de preço/quantidade, autorização
- **Testes de Carrinho**: Validação de autenticação
- **Testes de Contrato**: Estrutura da resposta, formato JWT
- **Testes de Fluxo**: Fluxo completo de compra (E2E)

## Tags

- `positivo` - Testes de caminho feliz
- `negativo` - Testes de validação de erro
- `seguranca` - Testes relacionados à segurança
- `smoke` - Testes críticos de smoke
- `e2e` - Testes de fluxo end-to-end
