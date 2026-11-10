# XTAP for Muse (v0.1.0-rc.10)

This page is for **the person** setting up XTAP in Muse. It is a reference page. Don't hand it to the agent as a list of instructions: agents rightly treat fetched pages as untrusted content, not as requests from you.

Setup has three parts: connect the XTAP connector, install and set up xtap (by chatting with Muse, or from a terminal), then connect your apps.

## 1. The XTAP connector

xtap gets its Connect credential from the **XTAP** custom connector in Muse. If it's already connected, skip ahead to part 2. If not, the chat flow below has Muse generate the connect link from these values:

| Field | Value |
|-------|-------|
| Client ID | `client_01M6N2XZ9DVQG3KMB484ZF491H` |
| Authorize URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/authorize` |
| Token URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/token` |
| Scopes | leave blank; this authorization server accepts no scopes |
| Resource | `https://stage-api.devtunnel.fyi/personal/register` (sent as `resource` on the authorize and token requests) |
| Credential name | `custom.xtap` |
| Registered hosts | `stage-api.devtunnel.fyi` (Muse may also list the AuthKit host; leave it) |

**Registered hosts matter.** Muse only swaps its stand-in for the real Connect token on requests to a registered host. xtap sends the Connect token to ACT (`stage-api.devtunnel.fyi`), so that host must be registered. If it isn't, ACT receives the stand-in and setup fails with `401 unauthorized` and no reason. Don't register the MCP gateway (`stage-mcp.devtunnel.fyi`): it never uses the Connect token, because tool calls use short-lived tokens that ACT issues.

**The resource matters too.** ACT only accepts a Connect token issued for `https://stage-api.devtunnel.fyi/personal/register`, and AuthKit sets the token's audience from the `resource` parameter. If the connector doesn't send it, setup fails with `connect_token_audience`.

Run setup right after connecting (the Connect token expires after about 20 minutes). If the token has expired, press Connect on the XTAP connector again, then rerun setup.

## 2. Install, set up, and register the skill

This installs the `xtap` binary (checked against `SHA256SUMS`), runs `xtap setup --platform muse` with this release's public settings (https://stage-api.devtunnel.fyi, https://stage-mcp.devtunnel.fyi/mcp), runs `xtap doctor`, then `xtap tool sync` and `xtap tool list`, and registers the XTAP skill with `xtap skill install`. Every step stops at the first failure and prints the JSON error (`next_action`, `error.hint`).

### Option A: chat with Muse (recommended)

Send these messages to Muse **yourself, one at a time**, and wait for each reply. Don't paste this page or link it: Muse treats fetched pages as untrusted content and won't act on them. Send Messages 1 and 2 in one sitting, because the Connect token from Message 1 lasts about 20 minutes.

**Message 1: connect**

```text
I want to set up XTAP in Muse. Please give me a connect link for the XTAP
custom connector with these values: client ID client_01M6N2XZ9DVQG3KMB484ZF491H,
authorize URL https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/authorize,
token URL https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/token,
scopes left blank, credential name custom.xtap,
and resource https://stage-api.devtunnel.fyi/personal/register (send it as the resource
parameter on both the authorize and the token request).
Also register stage-api.devtunnel.fyi as a host for this credential; xtap
sends the token there. Don't register stage-mcp.devtunnel.fyi.
I'll press Connect and tell you when it's done.
```

Before you press Connect, check that Muse's reply lists `stage-api.devtunnel.fyi` as a registered host and `https://stage-api.devtunnel.fyi/personal/register` as the resource. Then press Connect on the link Muse gives you, and enter the client ID if the page asks for it. Tell Muse "Connected", then send Message 2 right away.

**Message 2: install, set up, register the skill**

````text
Set up XTAP. I approve running exactly these commands, in order. Show me
each one's output. If any command fails, stop and show me the complete
error. Don't retry, change flags, or run setup again.

```
cd "$(mktemp -d)"
case "$(uname -m)" in x86_64|amd64) A=xtap-linux-amd64;; aarch64|arm64) A=xtap-linux-arm64;; *) echo "unsupported arch"; exit 1;; esac
B=https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.10
curl -fsSLO "$B/$A" && curl -fsSLO "$B/SHA256SUMS"
sha256sum -c SHA256SUMS --ignore-missing
mkdir -p ~/.local/bin && install -m 0755 "$A" ~/.local/bin/xtap && ~/.local/bin/xtap version
~/.local/bin/xtap setup --platform muse --act-origin https://stage-api.devtunnel.fyi --mcp-gateway https://stage-mcp.devtunnel.fyi/mcp --software-id client_01M6N2XZ9DVQG3KMB484ZF491H --credential-name custom.xtap
~/.local/bin/xtap doctor
~/.local/bin/xtap tool sync
~/.local/bin/xtap tool list
~/.local/bin/xtap skill install
```
````

Doctor may **warn** on `tool_cache`; every other check should pass. `skill install` writes `SKILL.md` and `skill.yaml` to `~/workspace/custom-skills/xtap/`, which is where Muse discovers custom skills.

**Message 3: test** (after you've connected an app in part 3), for example:

```text
Get me page <page id> from Notion.
```

Use a page in **your own** workspace; other people's pages aren't visible to you. The page id is the last part of the page's URL in Notion.

### Option B: run the installer yourself

From a terminal on the Muse VM, after connecting the connector:

```bash
curl -fsSLO https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.10/muse-install.sh
less muse-install.sh   # review it
bash muse-install.sh
```

### About the skill

The skill tells the agent how to use `xtap` for enterprise-tool requests: when to call it, how tasks work, and what to do with each `next_action`. `xtap skill install` writes it where Muse discovers skills. The text is the same as `xtap skill show` and [`muse-skill.md`](https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.1.0-rc.10/muse-skill.md). Rerun it after each update.

A skill makes xtap discoverable. It doesn't enforce anything: the agent sees the skill's name and description every turn and reads the full text when a request matches. Enforcement comes from xtap failing closed and from the gateway checking every call on the server.

## 3. Connect your apps

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
- Setup fails with `ACT HTTP 401; error=unauthorized` and no `xtap_reason`: the Connect token most likely never reached ACT. Check that `stage-api.devtunnel.fyi` is a registered host on the XTAP connector, add it if it's missing, reconnect, then rerun setup.
- Setup fails with `connect_token_audience`: the Connect token wasn't issued for ACT. Check that the XTAP connector sends `resource=https://stage-api.devtunnel.fyi/personal/register` on the authorize and token requests, reconnect, then rerun setup.
- Run setup again only after fixing what the error points to. If the Connect token expired, press Connect on the XTAP connector first.
- `xtap recover` disconnects the agent on any other device. Run it only when you mean to.
- `~/.xtap` holds this agent's keys and state. Don't edit or delete it.
- xtap never needs a token in chat, a file or an environment variable.

## Updating

Download `muse-install.sh` from a newer release at `https://github.com/airaa214223/xtap-agent-releases/releases` and run `bash muse-install.sh --install-only`. It replaces the binary and refreshes the skill without running setup again. Then run `~/.local/bin/xtap doctor`.
