# Install xtap (Muse VM)

Anonymous downloads from the public releases repository (ADR 0001). No GitHub login required.

Replace `<tag>` with a release tag such as `v0.1.0-rc.1` or `v0.1.0`.

## 1. Pick the binary for this VM

```bash
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARTIFACT=xtap-linux-amd64 ;;
  aarch64|arm64) ARTIFACT=xtap-linux-arm64 ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac
TAG=v0.1.0-rc.1   # or latest release tag
BASE="https://github.com/airaa214223/xtap-agent-releases/releases/download/${TAG}"
```

## 2. Download binary + checksums

```bash
curl -fsSL -o "$ARTIFACT" "${BASE}/${ARTIFACT}"
curl -fsSL -o SHA256SUMS "${BASE}/SHA256SUMS"
```

## 3. Verify SHA-256

```bash
sha256sum -c SHA256SUMS --ignore-missing
# or: grep " ${ARTIFACT}\$" SHA256SUMS | sha256sum -c -
```

## 4. Install to `~/.local/bin/xtap`

```bash
mkdir -p ~/.local/bin
install -m 0755 "$ARTIFACT" ~/.local/bin/xtap
export PATH="$HOME/.local/bin:$PATH"
xtap version
```

## 5. Muse setup + skill

```bash
xtap setup --platform muse \
  --act-origin "<ACT_ORIGIN>" \
  --mcp-gateway "<MCP_GATEWAY_URL>" \
  --software-id "<CONNECT_SOFTWARE_ID>" \
  --credential-name custom.xtap

xtap skill show
```

On Muse, Connect credentials come from the platform helper; do not paste tokens on the command line. Prefer the skill text from `xtap skill show` for the safe task/tool sequence.

## URLs (research R11)

| Artifact | URL |
|----------|-----|
| Linux amd64 | `https://github.com/airaa214223/xtap-agent-releases/releases/download/<tag>/xtap-linux-amd64` |
| Linux arm64 | `https://github.com/airaa214223/xtap-agent-releases/releases/download/<tag>/xtap-linux-arm64` |
| Checksums | `https://github.com/airaa214223/xtap-agent-releases/releases/download/<tag>/SHA256SUMS` |
| This guide | `https://github.com/airaa214223/xtap-agent-releases/releases/download/<tag>/install.md` |
