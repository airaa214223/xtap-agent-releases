# XTAP setup for Muse (v0.1.0-rc.4)

Give Muse this page. Follow the steps in order. Do not skip verification.

## 1. Ask the person

If the **XTAP** custom connector is already connected in Muse, skip this step and continue.

Otherwise, ask the person to add or Connect the **XTAP** custom connector, then **wait until they confirm** it is connected.

Custom connector values (only needed when connecting):

| Field | Value |
|-------|-------|
| Client ID | `client_01M5X33QZNTYBED5N6P6JASHA4` |
| Authorize URL | `https://euphoric-heart-43-development.authkit.app/oauth2/authorize` |
| Token URL | `https://euphoric-heart-43-development.authkit.app/oauth2/token` |
| Scopes | leave blank; this authorization server accepts no scopes |
| Credential name | `custom.xtap` |

After they confirm, run setup right after connecting (the Connect token expires after about 20 minutes): do step 3 straight away. If the token has expired, ask the person to press Connect on the XTAP connector again, then re-run step 3.

## 2. Install

```bash
cd "$(mktemp -d)"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARTIFACT=xtap-linux-amd64 ;;
  aarch64|arm64) ARTIFACT=xtap-linux-arm64 ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac
TAG=v0.1.0-rc.4
BASE="https://github.com/airaa214223/xtap-agent-releases/releases/download/${TAG}"
curl -fsSL -o "$ARTIFACT" "${BASE}/${ARTIFACT}"
curl -fsSL -o SHA256SUMS "${BASE}/SHA256SUMS"
sha256sum -c SHA256SUMS --ignore-missing
mkdir -p ~/.local/bin
install -m 0755 "$ARTIFACT" ~/.local/bin/xtap
~/.local/bin/xtap version
```

If checksum verification is anything other than OK, **stop**. Do not install a bad binary.

## 3. Connect

```bash
~/.local/bin/xtap setup --platform muse \
  --act-origin https://abhiact.devtunnel.fyi \
  --mcp-gateway https://abhimcp.devtunnel.fyi/mcp \
  --software-id client_01M5X33QZNTYBED5N6P6JASHA4 \
  --credential-name custom.xtap
```

## 4. Check

```bash
~/.local/bin/xtap doctor
```

Doctor checks should all **pass** (`tool_cache` may **warn**).

Then sync and list tools; show the person the tool list:

```bash
~/.local/bin/xtap tool sync
~/.local/bin/xtap tool list
```

## Connect your apps

Enterprise apps (Jira, Salesforce, Notion, Slack, ...) are connected by the person, not by this setup. Tell them to connect each app they want to use under **XTAP Connected apps**, the page in the ACT personal portal at https://abhiact.devtunnel.fyi.

Until an app is connected, tool calls for it fail with `next_action: connect_app`. That is expected: tell the person to connect the app, then stop. It is not a setup failure.

## 5. Standing instructions

```bash
~/.local/bin/xtap skill show
```

Keep that skill text as the rules for any request that needs an enterprise tool.

## 6. Rules

- If a step fails, stop and report the full JSON output, including `next_action` and `error.hint`, to the person. Do not retry with different flags, do not run setup again, and do not run recover unless the person says so.
- Never paste or store tokens in chat, files, or environment variables.
- Never edit or delete `~/.xtap`.
- Ask the person before running `~/.local/bin/xtap recover`.

## 7. Update

Repeat **Install** (and **Check**) with a newer `TAG` from `https://github.com/airaa214223/xtap-agent-releases/releases`.
