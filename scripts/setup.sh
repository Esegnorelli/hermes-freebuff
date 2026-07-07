#!/usr/bin/env bash
# =============================================================
#  hermes-freebuff — configuração automática
# -------------------------------------------------------------
#  O que faz:
#   1. Garante que existe um .env (copia de .env.example na 1ª vez)
#   2. Valida que você trocou os placeholders por chaves reais
#   3. Copia sua OPENROUTER_API_KEY para ~/.hermes/.env
#   4. Define um modelo grátis padrão + cadeia de fallback grátis
#
#  Não commita nada. Não envia sua chave para lugar nenhum além
#  do arquivo local ~/.hermes/.env que o próprio hermes já usa.
# =============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
err() { printf '\033[1;31mERRO:\033[0m %s\n' "$*" >&2; exit 1; }

# 1. .env local -------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
  say "Criando .env a partir de .env.example"
  cp "$ROOT/.env.example" "$ENV_FILE"
  err "Edite $ENV_FILE, cole sua OPENROUTER_API_KEY e rode de novo."
fi

# 2. carrega e valida ------------------------------------------
set -a; # shellcheck disable=SC1090
source "$ENV_FILE"; set +a
: "${OPENROUTER_API_KEY:=}"

if [[ -z "$OPENROUTER_API_KEY" || "$OPENROUTER_API_KEY" == coloque-* ]]; then
  err "OPENROUTER_API_KEY ainda é um placeholder. Edite o $ENV_FILE."
fi

command -v hermes >/dev/null 2>&1 || err "hermes não encontrado no PATH."

# Interpretador Python: preferimos o do venv do hermes (já tem PyYAML).
# Caímos para o python3 do sistema só se ele tiver o módulo yaml.
HERMES_PY="$(dirname "$(readlink -f "$(command -v hermes)")")/python"
if [[ -x "$HERMES_PY" ]] && "$HERMES_PY" -c 'import yaml' 2>/dev/null; then
  PY="$HERMES_PY"
elif python3 -c 'import yaml' 2>/dev/null; then
  PY="python3"
else
  err "Nenhum Python com PyYAML disponível (nem o do hermes, nem o do sistema)."
fi

# 3. injeta a chave no .env do hermes (sem duplicar) -----------
mkdir -p "$HERMES_HOME"
HERMES_ENV="$HERMES_HOME/.env"
touch "$HERMES_ENV"; chmod 600 "$HERMES_ENV"
if grep -q '^OPENROUTER_API_KEY=' "$HERMES_ENV"; then
  say "OPENROUTER_API_KEY já existe em $HERMES_ENV — mantendo."
else
  say "Gravando OPENROUTER_API_KEY em $HERMES_ENV"
  printf '\nOPENROUTER_API_KEY=%s\n' "$OPENROUTER_API_KEY" >> "$HERMES_ENV"
fi

# 4. modelo padrão + fallback grátis ---------------------------
say "Configurando modelo grátis padrão + cadeia de fallback"
"$PY" - "$HERMES_HOME/config.yaml" "$ROOT/examples/config.fallback.yaml" <<'PY'
import sys, yaml, os
cfg_path, tmpl_path = sys.argv[1], sys.argv[2]
cfg = {}
if os.path.exists(cfg_path):
    with open(cfg_path) as f:
        cfg = yaml.safe_load(f) or {}
with open(tmpl_path) as f:
    tmpl = yaml.safe_load(f) or {}
cfg["model"] = tmpl["model"]
cfg["fallback_providers"] = tmpl["fallback_providers"]
with open(cfg_path, "w") as f:
    yaml.safe_dump(cfg, f, sort_keys=False, allow_unicode=True)
print("  ok:", cfg_path)
PY

say "Pronto! Teste com:"
echo '   hermes -z "Responda só: OK"'
