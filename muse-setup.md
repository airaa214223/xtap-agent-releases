# LunarFence for Muse (v0.2.0-rc.2)

This page is for **the person** setting up LunarFence in Muse. It is a reference page. Don't hand it to the agent as a list of instructions: agents rightly treat fetched pages as untrusted content, not as requests from you.

Setup has three parts: connect the LunarFence connector, install and set up xtap (by chatting with Muse, or from a terminal), then connect your apps.

## 1. The LunarFence connector

xtap gets its Connect credential from the **LunarFence** custom connector in Muse. If it's already connected, skip ahead to part 2. If not, the chat flow below has Muse generate the connect link from these values:

| Field | Value |
|-------|-------|
| Client ID | `client_01M6N2XZ9DVQG3KMB484ZF491H` |
| Authorize URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/authorize` |
| Token URL | `https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/token` |
| Scopes | leave blank; this authorization server accepts no scopes |
| Resource | `https://stage-api.devtunnel.fyi/personal/register` (sent as `resource` on the authorize and token requests) |
| Credential name | `custom.lunarfence` |
| Registered hosts | `stage-api.devtunnel.fyi` (Muse may also list the AuthKit host; leave it) |

**Registered hosts matter.** Muse only swaps its stand-in for the real Connect token on requests to a registered host. xtap sends the Connect token to the LunarFence server (`stage-api.devtunnel.fyi`), so that host must be registered. If it isn't, the LunarFence server receives the stand-in and setup fails with `401 unauthorized` and no reason. Don't register the LunarFence tool gateway's host (`stage-mcp.devtunnel.fyi`): it never uses the Connect token, because tool calls use short-lived tokens that the LunarFence server issues.

**The resource matters too.** The LunarFence server only accepts a Connect token issued for `https://stage-api.devtunnel.fyi/personal/register`, and AuthKit sets the token's audience from the `resource` parameter. If the connector doesn't send it, setup fails with `connect_token_audience`.

Run setup right after connecting (the Connect token expires after about 20 minutes). If the token has expired, press Connect on the LunarFence connector again, then rerun setup.

## 2. Install, set up, and register the skill

This installs the `xtap` binary (checked against `SHA256SUMS`), runs `xtap setup --platform muse` with this release's public settings (LunarFence server https://stage-api.devtunnel.fyi, tool gateway https://stage-mcp.devtunnel.fyi/mcp), runs `xtap doctor`, then `xtap tool sync` and `xtap tool list`, and registers the LunarFence skill with `xtap skill install`. Every step stops at the first failure and prints the JSON error (`next_action`, `error.hint`).

### Option A: chat with Muse (recommended)

Send these messages to Muse **yourself, one at a time**, and wait for each reply. Don't paste this page or link it: Muse treats fetched pages as untrusted content and won't act on them. Send Messages 1 and 2 in one sitting, because the Connect token from Message 1 lasts about 20 minutes. Messages 3 and 4 come in part 3, after setup.

**Message 1: connect**

```text
I want to set up LunarFence in Muse. Please give me a connect link for the LunarFence custom connector with these values: client ID client_01M6N2XZ9DVQG3KMB484ZF491H, authorize URL https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/authorize, token URL https://spiritual-theme-76-xtap-stage.authkit.app/oauth2/token, scopes left blank, credential name custom.lunarfence, and resource https://stage-api.devtunnel.fyi/personal/register (send it as the resource parameter on both the authorize and the token request).
Also register stage-api.devtunnel.fyi as a host for this credential; xtap sends the token there. Don't register stage-mcp.devtunnel.fyi.
I'll press Connect and tell you when it's done.
```

Before you press Connect, check that Muse's reply lists `stage-api.devtunnel.fyi` as a registered host and `https://stage-api.devtunnel.fyi/personal/register` as the resource. Then press Connect on the link Muse gives you, and enter the client ID if the page asks for it. Tell Muse "Connected", then send Message 2 right away.

**Message 2: install, set up, register the skill**

````text
Set up LunarFence. I approve running exactly these commands, in order. Show me each one's output. If any command fails, stop and show me the complete error. Don't retry, change flags, or run setup again.

```
cd "$(mktemp -d)"
case "$(uname -m)" in x86_64|amd64) A=xtap-linux-amd64;; aarch64|arm64) A=xtap-linux-arm64;; *) echo "unsupported arch"; exit 1;; esac
B=https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.2.0-rc.2
curl -fsSLO "$B/$A" && curl -fsSLO "$B/SHA256SUMS"
sha256sum -c SHA256SUMS --ignore-missing
mkdir -p ~/.local/bin && install -m 0755 "$A" ~/.local/bin/xtap && ~/.local/bin/xtap version
~/.local/bin/xtap setup --platform muse --act-origin https://stage-api.devtunnel.fyi --mcp-gateway https://stage-mcp.devtunnel.fyi/mcp --software-id client_01M6N2XZ9DVQG3KMB484ZF491H --credential-name custom.lunarfence --brand 'LunarFence' --connector-name 'LunarFence' --console-url https://stage-console.devtunnel.fyi
~/.local/bin/xtap doctor
~/.local/bin/xtap tool sync
~/.local/bin/xtap skill install
```

When every command has succeeded, give me the brief from xtap setup.
````

Doctor may **warn** on `tool_cache`; every other check should pass. `skill install` writes `SKILL.md` and `skill.yaml` to `~/workspace/custom-skills/xtap/`, which is where Muse discovers custom skills.

### Option B: run the installer yourself

From a terminal on the Muse VM, after connecting the connector:

```bash
curl -fsSLO https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.2.0-rc.2/muse-install.sh
less muse-install.sh   # review it
bash muse-install.sh
```

### About the skill

The skill tells the agent how to use `xtap` for enterprise-tool requests: when to call it, how tasks work, and what to do with each `next_action`. `xtap skill install` writes it where Muse discovers skills. The text is the same as `xtap skill show` and [`muse-skill.md`](https://github.com/airaa214223/xtap-agent-releases/releases/download/v0.2.0-rc.2/muse-skill.md). Rerun it after each update.

A skill makes xtap discoverable. It doesn't enforce anything: the agent sees the skill's name and description every turn and reads the full text when a request matches. Enforcement comes from xtap failing closed and from the LunarFence tool gateway checking every call on the server.

## 3. Connect your apps

You connect your apps (Notion, Gmail, Google Calendar, Outlook, Slack, ...) from the agent; setup doesn't do it. Send Muse Message 3 to see the full list, then say "Connect <app>", for example "Connect Gmail". Open the link it gives you and press **Connect**. You can also connect apps yourself under Connectors in the LunarFence console: https://stage-console.devtunnel.fyi/connectors

**Message 3: apps**

```text
Which apps does LunarFence support?
```

This needs the agent's **Allow this agent to ask you to connect apps or give it access** switch, which is in the LunarFence console. If the switch is off, the agent tells you to turn it on.

Until an app is connected, tool calls for it fail with `next_action: connect_app`. That is expected, not a setup failure.

**Message 4: try it** (after you've connected your email, for example Gmail or Outlook):

```text
What's in my inbox from today?
```

## Checking

`~/.local/bin/xtap doctor` should pass every check (`tool_cache` may **warn**). To see which enterprise tools are available:

```bash
~/.local/bin/xtap tool sync
~/.local/bin/xtap tool list
```

## When something fails

- Every `xtap` failure prints one JSON object with `ok: false`. `error.next_action` says what to do, and `error.hint` explains it. Fix what the error points to, then rerun.
- Setup fails with `LunarFence returned HTTP 401; error=unauthorized` and no `xtap_reason`: the Connect token most likely never reached the LunarFence server. Check that `stage-api.devtunnel.fyi` is a registered host on the LunarFence connector, add it if it's missing, reconnect, then rerun setup.
- Setup fails with `connect_token_audience`: the Connect token wasn't issued for the LunarFence server. Check that the LunarFence connector sends `resource=https://stage-api.devtunnel.fyi/personal/register` on the authorize and token requests, reconnect, then rerun setup.
- If more than about 20 minutes have passed since you pressed Connect, the Connect token has expired: press Connect again, then send Message 2 again.
- If the agent later says to reconnect, press Connect on the LunarFence connector, sign in, then tell the agent to continue.
- If the agent says it isn't allowed to ask you to connect apps, turn on the setting that lets this agent ask you to connect apps, on the agent's page in the LunarFence console.
- `xtap recover` disconnects the agent on any other device. Run it only when you mean to.
- `~/.xtap` holds this agent's keys and state. Don't edit or delete it.
- xtap never needs a token in chat, a file or an environment variable.

## Updating

Download `muse-install.sh` from a newer release at `https://github.com/airaa214223/xtap-agent-releases/releases` and run `bash muse-install.sh --install-only`. It replaces the binary and refreshes the skill without running setup again. Then run `~/.local/bin/xtap doctor`.
