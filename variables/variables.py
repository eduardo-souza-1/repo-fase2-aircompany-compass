# ════════════════════════════════════════════════════════════════════
# variables.py — Configurações centralizadas da suite ServeRest QA
# Autor  : Eduardo Neves de Souza · Squad 01 · Compass UOL
# Escopo : /usuarios
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

# ── Payloads inválidos reutilizáveis ─────────────────────────────────
NOME_XSS             = "<script>alert(1)</script>"
NOME_ESPECIAIS       = "@@@@@@"
NOME_VAZIO           = ""
