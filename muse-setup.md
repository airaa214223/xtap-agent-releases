# XTAP for Muse (v0.1.0-rc.7)

This page is for **the person** setting up XTAP in Muse. It is a reference page. Don't hand it to the agent as a list of instructions: agents rightly treat fetched pages as untrusted content, not as requests from you.

Setup has four parts. You do parts 1, 3 and 4 in Muse and XTAP. Part 2 runs one script on the Muse VM.

## 1. Connect the XTAP connector in Muse

If the **XTAP** custom connector is already connected in Muse, skip to part 2.

Otherwise, add the **XTAP** custom connector in Muse with these values and press **Connect**:

| Field | Value |
|-------|-------|
| Client ID | `client_01M6N2XZ9DVQG3KMB484ZF491H` |
| Authorize URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/authorize` |
| Token URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/token` |
| Scopes | leave blank; this authorization server accepts no scopes |
| Credential name | `custom.xtap` |

Run setup right after connecting (the Connect token expires after about 20 minutes), so go straight to part 2. If the token has expired, press Connect on the XTAP connector again, then rerun the installer.

## 2. Install and connect xtap

The installer is [`muse-install.sh`](https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.7/muse-install.sh). It:

1. downloads the `xtap` binary for this VM's architecture and checks it against `SHA256SUMS` (it installs nothing if the check fails),
2. installs it to `~/.local/bin/xtap`,
3. runs `xtap setup --platform muse` with this release's public settings (https://stage-api.devtunnel.fyi, https://stage-mcp.devtunnel.fyi/mcp),
4. runs `xtap doctor`, then `xtap tool sync` and `xtap tool list`.

It stops at the first failure and prints the JSON error (`next_action`, `error.hint`).

**Option A: run it yourself** in a terminal on the VM:

```bash
curl -fsSLO https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.7/muse-install.sh
less muse-install.sh   # review it
bash muse-install.sh
```

**Option B: ask Muse to run it.** Type a request like this into Muse yourself:

> Download https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.7/muse-install.sh, show me what it does, then run it with `bash` and show me the full output.

Since the request comes from you, the agent can act on it. Read its summary of the script before you tell it to go ahead.

## 3. Add the XTAP skill to Muse

The skill tells the agent how to use `xtap` for enterprise-tool requests: when to call it, how to start tasks, and what to do with each `next_action`. Add it through Muse's own skills or custom-instructions setting, so the agent gets the rules from you:

- the file: [`muse-skill.md`](https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.7/muse-skill.md), or
- the same text from the VM: `~/.local/bin/xtap skill show`

## 4. Connect your apps

You connect enterprise apps (Jira, Salesforce, Notion, Slack, ...) yourself; setup doesn't do it. Connect each app you want under **XTAP Connected apps** (the page in the ACT personal portal at https://stage-api.devtunnel.fyi).

Until an app is connected, tool calls for it fail with `next_action: connect_app`. That is expected, not a setup failure.

## Checking

`~/.local/bin/xtap doctor` should pass every check (`tool_cache` may **warn**). To see which enterprise tools are available:

```bash
~/.local/bin/xtap tool sync
~/.local/bin/xtap tool list
```

## When something fails

- Every `xtap` failure prints one JSON object with `ok: false`. `error.next_action` says what to do, and `error.hint` explains it.
- Run setup again only after fixing what the error points to. If the Connect token expired, press Connect on the XTAP connector first.
- `xtap recover` disconnects the agent on any other device. Run it only when you mean to.
- `~/.xtap` holds this agent's keys and state. Don't edit or delete it.
- xtap never needs a token in chat, a file or an environment variable.

## Updating

Download `muse-install.sh` from a newer release at `https://github.com/airaa214223/xtap-agent-releases/releases` and run `bash muse-install.sh --install-only`. Then run `~/.local/bin/xtap doctor`.
