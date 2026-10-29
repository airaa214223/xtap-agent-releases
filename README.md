# xtap-agent-releases

Public, anonymous download site for **xtap** Linux binaries. Source lives in a private repository; this repo holds only release artifacts, checksums, and the install guide (ADR 0001).

## Install (Muse VM)

Replace `<tag>` with a release tag such as `v0.1.0-rc.1` or `v0.1.0`.

### 1. Pick the binary for this VM

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

### 2. Download binary + checksums

```bash
curl -fsSL -o "$ARTIFACT" "${BASE}/${ARTIFACT}"
curl -fsSL -o SHA256SUMS "${BASE}/SHA256SUMS"
```

### 3. Verify SHA-256

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

### 4. Install to `~/.local/bin/xtap`

```bash
mkdir -p ~/.local/bin
install -m 0755 "$ARTIFACT" ~/.local/bin/xtap
export PATH="$HOME/.local/bin:$PATH"
xtap version
```

### 5. Muse setup + skill

```bash
xtap setup --platform muse \
  --act-origin "<ACT_ORIGIN>" \
  --mcp-gateway "<MCP_GATEWAY_URL>" \
  --software-id "<CONNECT_SOFTWARE_ID>" \
  --credential-name custom.xtap

xtap skill show
```

Do not paste Connect tokens on the command line. Follow `xtap skill show` for the safe task/tool sequence.

## Release assets

Each tag publishes:

- `xtap-linux-amd64`
- `xtap-linux-arm64`
- `SHA256SUMS`
- `install.md`
- this `README.md`
