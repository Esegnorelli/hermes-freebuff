# hermes-freebuff 🆓

Rodar o **[hermes-agent](https://hermes-agent.nousresearch.com)** usando só
**modelos grátis (0800)** — via os modelos `:free` do OpenRouter (e, opcionalmente,
o OpenCode Zen). Sem cartão, sem cobrança.

> **Objetivo:** um agente de IA com tool-calling funcionando de graça, com
> uma cadeia de *fallback* que troca de modelo sozinha quando um esbarra no
> limite de requisições (o famoso `HTTP 429` dos modelos gratuitos).

---

## ⚡ Início rápido

```bash
# 1. clone
git clone https://github.com/<seu-usuario>/hermes-freebuff.git
cd hermes-freebuff

# 2. instale o hermes-agent (veja a doc oficial se ainda não tiver)
#    Arch/AUR: yay -S hermes-agent   |   pip: pipx install hermes-agent

# 3. crie seu .env e cole SUA chave do OpenRouter
cp .env.example .env
$EDITOR .env                 # OPENROUTER_API_KEY=sk-or-v1-...

# 4. configure tudo (modelo grátis padrão + fallback)
./scripts/setup.sh

# 5. use
hermes -z "Responda só: OK"
```

Pegue uma chave gratuita do OpenRouter em <https://openrouter.ai/keys>.

---

## 🧠 Como funciona

O `setup.sh`:

1. copia sua `OPENROUTER_API_KEY` do `.env` local para `~/.hermes/.env`
   (onde o hermes procura credenciais);
2. define um **modelo grátis padrão** e uma **cadeia de fallback** em
   `~/.hermes/config.yaml` (veja `examples/config.fallback.yaml`).

Quando o modelo principal falha com rate-limit/sobrecarga, o hermes desce a
lista automaticamente. Como os modelos `:free` vivem lotados, essa cadeia é o
que mantém o agente utilizável.

### Modelos grátis usados por padrão

| Ordem | Provider   | Modelo                                     |
|-------|------------|--------------------------------------------|
| 1º    | openrouter | `openai/gpt-oss-120b:free`                 |
| 2º    | openrouter | `qwen/qwen3-coder:free`                    |
| 3º    | openrouter | `meta-llama/llama-3.3-70b-instruct:free`   |
| 4º    | openrouter | `qwen/qwen3-next-80b-a3b:free`             |
| 5º    | openrouter | `openai/gpt-oss-20b:free`                  |
| 6º    | openrouter | `nvidia/nemotron-3-super-120b-a12b:free`   |

Para ver a lista atual de gratuitos:

```bash
curl -s https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  | jq -r '.data[] | select(.pricing.prompt=="0") | .id'
```

Trocar de modelo ou mexer na cadeia à mão:

```bash
hermes model       # escolhe o modelo/provider padrão
hermes fallback    # gerencia a cadeia de fallback
```

---

## 🔐 Segurança — leia antes de commitar

Este repositório é **público**. Chave que entra em repo público é chave
comprometida em minutos (há bots varrendo o GitHub o tempo todo).

- ✅ **Só** `.env.example` (com placeholders) é versionado.
- 🚫 O `.env` real está no `.gitignore` — **nunca** o force com `git add -f`.
- 🚫 O agente **não precisa** de token do GitHub, Supabase, Vercel etc. para
  usar os modelos grátis. Não coloque esses tokens aqui.
- 🛡️ Duas travas de segurança já vêm no repo:
  - `./scripts/install-hooks.sh` — hook de **pré-commit** que barra `.env` e
    conteúdo com cara de chave antes do commit.
  - `.github/workflows/secret-scan.yml` — **gitleaks** no CI, reprova o push
    se algum segredo escapar.

```bash
./scripts/install-hooks.sh   # rode logo após 'git init' / clone
```

Se você **já** expôs alguma chave: **revogue e gere outra**. Reescrever o
histórico do git não basta — assuma que já foi capturada. Detalhes em
[`SECURITY.md`](SECURITY.md).

---

## 📄 Licença

MIT — veja [`LICENSE`](LICENSE).
