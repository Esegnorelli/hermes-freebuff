#!/usr/bin/env bash
# Instala o hook de pré-commit que bloqueia segredos.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_DIR="$ROOT/.git/hooks"
[[ -d "$ROOT/.git" ]] || { echo "Rode 'git init' primeiro."; exit 1; }
install -m 755 "$ROOT/scripts/pre-commit" "$HOOK_DIR/pre-commit"
echo "Hook instalado em $HOOK_DIR/pre-commit"
