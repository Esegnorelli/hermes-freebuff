# Política de segurança

## Regra de ouro

**Nenhuma chave real entra neste repositório.** Ele é público. O único arquivo
de ambiente versionado é o `.env.example`, e ele contém apenas placeholders.

## Onde cada coisa mora

| Arquivo                 | Versionado? | Contém chave real? |
|-------------------------|-------------|--------------------|
| `.env.example`          | ✅ sim       | ❌ nunca            |
| `.env`                  | ❌ (ignorado) | ✅ (só na sua máquina) |
| `~/.hermes/.env`        | ❌           | ✅ (fora do repo)   |
| `~/.hermes/config.yaml` | ❌           | pode conter — fora do repo |

## Camadas de proteção neste repo

1. **`.gitignore`** — ignora `.env`, `*.env`, `*.key`, `*.pem`, `auth.json`,
   `config.yaml`, etc.
2. **Hook de pré-commit** (`scripts/pre-commit`, instale com
   `scripts/install-hooks.sh`) — bloqueia localmente qualquer commit que
   inclua um `.env` ou conteúdo com padrão de chave (`sk-or-v1-…`, `ghp_…`,
   `sbp_…`, `vcp_…`, token de bot do Telegram, etc.).
3. **CI `secret-scan`** (`.github/workflows/secret-scan.yml`) — roda o
   [gitleaks](https://github.com/gitleaks/gitleaks) em todo push/PR.

## Vazou uma chave — e agora?

Assuma que ela **já foi capturada**. Reescrever o histórico do git **não**
resolve. O certo é:

1. **Revogar/rotacionar** a chave no painel do serviço:
   - OpenRouter → <https://openrouter.ai/keys>
   - OpenCode → painel da conta
   - GitHub PAT → *Settings → Developer settings → Personal access tokens*
   - Telegram → `/revoke` no @BotFather
   - Supabase / Vercel → *Account/Project → Tokens*
2. Gerar uma **nova** chave e colocar só no `.env` local.
3. (Opcional) limpar o histórico com `git filter-repo` ou o BFG — mas **depois**
   de já ter revogado.

## Escopo mínimo

Para usar só os modelos grátis, o agente precisa **apenas** da
`OPENROUTER_API_KEY`. Não adicione tokens de GitHub, Supabase, Vercel, Telegram
etc. a este projeto — eles não são necessários e só aumentam a superfície de
risco.
