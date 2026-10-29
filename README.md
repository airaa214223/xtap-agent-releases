# xtap-agent-releases

Public, anonymous download site for **xtap** Linux binaries. Source lives in a private repository; this repo holds only release artifacts, checksums, install guide, and per-platform setup one-pagers (ADR 0001).

## Setup pages

Give the agent the page for its platform (attached to every release and kept on `main`):

- **Muse**: [`muse-setup.md`](./muse-setup.md)

## Install (Linux VM)

Replace `<tag>` with a release tag such as `v0.1.0-rc.3` or `v0.1.0`. Prefer the platform setup page above when an agent is driving install.

### 1. Pick the binary for this VM

```bash
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARTIFACT=xtap-linux-amd64 ;;
  aarch64|arm64) ARTIFACT=xtap-linux-arm64 ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac
TAG=v0.1.0-rc.3   # or latest release tag
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
~/.local/bin/xtap version
```

## Release assets

Each tag publishes:

- `xtap-linux-amd64`
- `xtap-linux-arm64`
- `SHA256SUMS`
- `install.md`
- `<platform>-setup.md` for each enabled platform in `RELEASE_ENV`
- this `README.md`
