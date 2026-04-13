# ════════════════════════════════════════════════════════════════════
# variables.py — Configurações centralizadas da suite ServeRest QA
# Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
# Escopo : /usuarios · /login · /produtos
# ════════════════════════════════════════════════════════════════════

# ── Conexão ─────────────────────────────────────────────────────────
BASE_URL = "https://compassuol.serverest.dev"
SESSION  = "serverest"

# ── Credenciais ──────────────────────────────────────────────────────
PASSWORD   = "Test@123"
ADMIN_FLAG = "true"
USER_FLAG  = "false"

# ── Mensagens esperadas — Usuários ───────────────────────────────────
MSG_CADASTRO_OK      = "Cadastro realizado com sucesso"
MSG_EMAIL_DUPLICADO  = "Este email já está sendo usado"

# ── Mensagens esperadas — Login ───────────────────────────────────────
MSG_LOGIN_OK        = "Login realizado com sucesso"
MSG_SENHA_INVALIDA  = "Email e/ou senha inválidos"

# ── Mensagens esperadas — Autenticação (compartilhada) ───────────────
MSG_TOKEN_INVALIDO  = "Token de acesso ausente, inválido, expirado ou usuário do token não existe mais"

# ── Mensagens esperadas — Produtos ───────────────────────────────────
MSG_RBAC_ADMIN          = "Rota exclusiva para administradores"
MSG_PRODUTO_DUPLICADO   = "Já existe produto com esse nome"

# ── Produto — valores válidos ─────────────────────────────────────────
PRECO_VALIDO      = 100
QUANTIDADE_VALIDA = 10
DESCRICAO_VALIDA  = "produto de teste automatizado"

# ── Produto — valores inválidos ───────────────────────────────────────
PRECO_NEGATIVO        = -1
QUANTIDADE_NEGATIVA   = -1
PRECO_STRING          = "10"   # coerção de tipo — BUG-03

# ── Payloads inválidos reutilizáveis — Usuários ───────────────────────
NOME_XSS       = "<script>alert(1)</script>"
NOME_ESPECIAIS = "@@@@@@"
NOME_VAZIO     = ""

# ── Token inválido simulado ───────────────────────────────────────────
TOKEN_INVALIDO = "Bearer token_fake_adulterado_para_teste"