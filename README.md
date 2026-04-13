# ServeRest QA - Automação de Testes

Projeto de automação de testes para a API ServeRest utilizando Robot Framework.

## 📋 Descrição

Suite de testes automatizados para validação dos domínios `/usuarios`, `/login`, `/produtos` e `/carrinhos` da API ServeRest, incluindo cenários positivos, negativos, regras de negócio e evidências de bugs de segurança.

## 🚀 Tecnologias

- **Robot Framework** - Framework de automação de testes
- **RequestsLibrary** - Biblioteca para requisições HTTP
- **FakerLibrary** - Geração de dados fake para testes
- **Python 3.x** - Linguagem base

## 📁 Estrutura do Projeto

```
resources/
│   ├── api.robot              # Configurações de sessão API
│   ├── keywords.robot         # Keywords reutilizáveis (usuários)
│   ├── login_keywords.robot   # Keywords de autenticação
│   ├── produto_keywords.robot # Keywords de produtos
│   └── carrinho_keywords.robot # Keywords de carrinhos
tests/
│   ├── usuarios.robot         # Suite de testes de usuários
│   ├── login.robot            # Suite de testes de login
│   ├── produtos.robot         # Suite de testes de produtos
│   └── carrinhos.robot        # Suite de testes de carrinhos
variables/
│   └── variables.py           # Variáveis centralizadas
results/                       # Relatórios gerados (git ignored)
.gitignore
README.md
requirements.txt
```

## 🔧 Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd <nome-do-repositorio>
```

2. Instale as dependências:
```bash
pip install -r requirements.txt
```

## ▶️ Execução dos Testes

### Executar todos os testes de um domínio:
```bash
# Testes de usuários
robot tests/usuarios.robot

# Testes de login
robot tests/login.robot

# Testes de produtos
robot tests/produtos.robot

# Testes de carrinhos
robot tests/carrinhos.robot
```

### Executar todos os testes:
```bash
robot tests/
```

### Executar testes por tag:
```bash
# Apenas testes positivos
robot --include positivo tests/

# Apenas testes negativos
robot --include negativo tests/

# Testes de segurança
robot --include seguranca tests/

# Teste específico
robot --include CT-U01 tests/usuarios.robot
```

### Gerar relatório customizado:
```bash
robot --outputdir results --name "ServeRest Tests" tests/
```

## 📊 Cobertura de Testes

### Usuários (CT-U):

| ID | Descrição | Tipo | Status |
|---|---|---|---|
| CT-U01 | Criar usuário administrador válido | Positivo | ✅ |
| CT-U02 | Rejeitar email duplicado | Negativo | ✅ |
| CT-U03 | Rejeitar campo email ausente | Negativo | ✅ |
| CT-U04 | Rejeitar campo nome ausente | Negativo | ✅ |
| CT-U05 | Evidenciar XSS no campo nome | Bug/Segurança | ⚠️ |
| CT-U06 | Evidenciar nome com caracteres especiais | Bug | ⚠️ |
| CT-U07 | Evidenciar nome vazio aceito | Bug | ⚠️ |
| CT-U08 | GET listar todos os usuários | Positivo/Contrato | ✅ |
| CT-U09 | GET com filtro sem correspondência | Negativo | ✅ |
| CT-U10 | PUT com UPSERT em ID inexistente | Regra de Negócio | ✅ |

### Login (CT-L):

| ID | Descrição | Tipo | Status |
|---|---|---|---|
| CT-L01 | Login com credenciais válidas | Positivo | ✅ |
| CT-L02 | Login com password incorreto | Negativo | ✅ |
| CT-L03 | Validar contrato do response | Contrato | ✅ |
| CT-L05 | Email inexistente (user enumeration) | Negativo/Segurança | ✅ |

### Produtos (CT-P):

| ID | Descrição | Tipo | Status |
|---|---|---|---|
| CT-P01 | Criar produto como admin | Positivo | ✅ |
| CT-P02 | RBAC: não-admin rejeitado | Negativo/Regra | ✅ |
| CT-P03 | Token inválido | Negativo | ✅ |
| CT-P04 | Preço negativo | Negativo | ✅ |
| CT-P05 | Quantidade negativa | Negativo | ✅ |
| CT-P06 | Campo nome ausente | Negativo | ✅ |
| CT-P07 | Preço como string (BUG-03) | Bug | ⚠️ |
| CT-P08 | Nome duplicado | Negativo | ✅ |
| CT-P09 | DELETE com ID inexistente | Negativo | ✅ |
| CT-P10 | Estrutura da listagem | Positivo/Contrato | ✅ |
| CT-P11 | Contrato do response de criação | Contrato | ✅ |
| CT-P12 | Filtro sem resultado | Negativo | ✅ |
| CT-P13 | PUT sem token | Negativo | ✅ |

### Carrinhos (CT-C):

| ID | Descrição | Tipo | Status |
|---|---|---|---|
| CT-C01 | Criar carrinho com produto válido | Positivo | ✅ |
| CT-C02 | Rejeitar idProduto inexistente | Negativo | ✅ |
| CT-C03 | Rejeitar segundo carrinho para mesmo usuário | Negativo | ✅ |
| CT-C04 | Rejeitar quantidade maior que estoque | Negativo | ✅ |
| CT-C05 | Rejeitar idProduto duplicado no array | Negativo | ✅ |
| CT-C06 | Concluir compra (DELETE) | Positivo | ✅ |
| CT-C07 | Cancelar compra (DELETE /concluir-compra) | Positivo | ✅ |

⚠️ = Testes que evidenciam bugs conhecidos (falham intencionalmente)

## 🐛 Bugs Evidenciados

### BUG-01 (Alta Severidade)
- **Descrição**: API aceita XSS no campo nome
- **Referência**: OWASP A03:2021 - Injection
- **Teste**: CT-U05
- **Impacto**: Vulnerabilidade de segurança - Stored XSS

### BUG-02 (Média Severidade)
- **Descrição**: API aceita nome com apenas caracteres especiais
- **Teste**: CT-U06
- **Impacto**: Validação de entrada inadequada

### BUG-01 Parcial
- **Descrição**: API aceita campo nome vazio
- **Teste**: CT-U07
- **Impacto**: Campo obrigatório não validado

### BUG-03 (Média Severidade)
- **Descrição**: API aceita preço como string (coerção de tipo)
- **Teste**: CT-P07
- **Impacto**: Risco em cálculos de total

## 🔗 API Base

- **URL**: https://compassuol.serverest.dev
- **Documentação**: https://serverest.dev

## 👤 Autor

**Eduardo Neves de Souza**  
Squad 01 · Compass UOL

## 📝 Versão

2.0 - Reorganizado com rastreabilidade completa e 1 CT por teste
