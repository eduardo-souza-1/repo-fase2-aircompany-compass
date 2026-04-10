# ServeRest QA - Automação de Testes

Projeto de automação de testes para a API ServeRest utilizando Robot Framework.

## 📋 Descrição

Suite de testes automatizados para validação do domínio `/usuarios` da API ServeRest, incluindo cenários positivos, negativos, regras de negócio e evidências de bugs de segurança.

## 🚀 Tecnologias

- **Robot Framework** - Framework de automação de testes
- **RequestsLibrary** - Biblioteca para requisições HTTP
- **FakerLibrary** - Geração de dados fake para testes
- **Python 3.x** - Linguagem base

## 📁 Estrutura do Projeto

```
serveRest-qa-reorganizado/
├── challenge04-genai/
│   ├── resources/
│   │   ├── api.robot          # Configurações de sessão API
│   │   └── keywords.robot     # Keywords reutilizáveis
│   ├── tests/
│   │   └── usuarios.robot     # Suite de testes de usuários
│   └── variables/
│       └── variables.py       # Variáveis centralizadas
├── .gitignore
├── README.md
└── requirements.txt
```

## 🔧 Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd serveRest-qa-reorganizado
```

2. Instale as dependências:
```bash
pip install -r requirements.txt
```

## ▶️ Execução dos Testes

### Executar todos os testes:
```bash
robot challenge04-genai/tests/usuarios.robot
```

### Executar testes por tag:
```bash
# Apenas testes positivos
robot --include positivo challenge04-genai/tests/usuarios.robot

# Apenas testes negativos
robot --include negativo challenge04-genai/tests/usuarios.robot

# Testes de segurança
robot --include seguranca challenge04-genai/tests/usuarios.robot

# Teste específico
robot --include CT-U01 challenge04-genai/tests/usuarios.robot
```

### Gerar relatório customizado:
```bash
robot --outputdir results --name "ServeRest Tests" challenge04-genai/tests/usuarios.robot
```

## 📊 Cobertura de Testes

### Casos de Teste Implementados:

| ID | Descrição | Tipo | Status |
|---|---|---|---|
| CT-U01 | Criar usuário administrador válido | Positivo | ✅ |
| CT-U02 | Rejeitar email duplicado | Negativo | ✅ |
| CT-U03 | Rejeitar campo email ausente | Negativo | ✅ |
| CT-U05 | Evidenciar XSS no campo nome | Bug/Segurança | ⚠️ |
| CT-U06 | Evidenciar nome com caracteres especiais | Bug | ⚠️ |
| CT-U07 | Evidenciar nome vazio aceito | Bug | ⚠️ |
| CT-U09 | GET com filtro sem correspondência | Negativo | ✅ |
| CT-U10 | PUT com UPSERT em ID inexistente | Regra de Negócio | ✅ |

⚠️ = Testes que evidenciam bugs conhecidos (falham intencionalmente)

## 🐛 Bugs Evidenciados

### BUG-01 (Alta Severidade)
- **Descrição**: API aceita XSS no campo nome
- **Referência**: OWASP A03:2021 - Injection
- **Teste**: CT-U05

### BUG-02 (Média Severidade)
- **Descrição**: API aceita nome com apenas caracteres especiais
- **Teste**: CT-U06

### BUG-01 Parcial
- **Descrição**: API aceita campo nome vazio
- **Teste**: CT-U07

## 🔗 API Base

- **URL**: https://compassuol.serverest.dev
- **Documentação**: https://serverest.dev

## 👤 Autor

**Eduardo Neves de Souza**  
Squad 01 · Compass UOL

## 📝 Versão

2.0 - Reorganizado com rastreabilidade completa e 1 CT por teste
