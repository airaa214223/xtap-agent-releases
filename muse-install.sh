#!/usr/bin/env bash
# xtap installer for Muse (v0.1.0-rc.10).
#
# Run by the person setting up XTAP, on the Muse VM:
#   bash muse-install.sh                 # install + setup + check
#   bash muse-install.sh --install-only  # update binary + skill, skip setup
#
# Every value below is public (it ships in the release). No tokens are read,
# printed, or stored by this script; `xtap setup` gets the Connect credential
# from the platform itself.
set -euo pipefail

TAG=v0.1.0-rc.10
BASE="https://github.com/airaa214223/xtap-agent-releases/releases/download/${TAG}"
XTAP="$HOME/.local/bin/xtap"

INSTALL_ONLY=0
case "${1:-}" in
  "") ;;
  --install-only) INSTALL_ONLY=1 ;;
  -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
  *) echo "unknown argument: $1 (try --help)" >&2; exit 64 ;;
esac

step() { printf '\n==> %s\n' "$*"; }
fail() {
  local code="$1"; shift
  printf '\nxtap install stopped: %s\n' "$*" >&2
  exit "$code"
}

step "Download and verify xtap ${TAG}"
case "$(uname -m)" in
  x86_64|amd64) ARTIFACT=xtap-linux-amd64 ;;
  aarch64|arm64) ARTIFACT=xtap-linux-arm64 ;;
  *) fail 1 "unsupported architecture: $(uname -m)" ;;
esac
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
curl -fsSL -o "$WORK/$ARTIFACT" "${BASE}/${ARTIFACT}"
curl -fsSL -o "$WORK/SHA256SUMS" "${BASE}/SHA256SUMS"
(cd "$WORK" && sha256sum -c SHA256SUMS --ignore-missing) \
  || fail 1 "checksum verification failed; nothing was installed"
mkdir -p "$HOME/.local/bin"
install -m 0755 "$WORK/$ARTIFACT" "$XTAP"
"$XTAP" version

register_skill() {
  step "Register the skill (xtap skill install)"
  "$XTAP" skill install \
    || fail 5 "skill install failed (see the JSON above). xtap itself is installed."
}

if [[ "$INSTALL_ONLY" == 1 ]]; then
  register_skill
  step "Updated. Skipped setup (--install-only)."
  exit 0
fi

step "Connect (xtap setup)"
"$XTAP" setup --platform muse --act-origin https://stage-api.devtunnel.fyi --mcp-gateway https://stage-mcp.devtunnel.fyi/mcp --software-id client_01M6N2XZ9DVQG3KMB484ZF491H --credential-name custom.xtap \
  || fail 2 "setup failed. The JSON above has next_action and error.hint. Fix that, then run this script again."

step "Check (xtap doctor)"
"$XTAP" doctor \
  || fail 3 "doctor reported a failing check (see above). tool_cache may warn; anything else failing needs attention."

step "Tools (xtap tool sync, xtap tool list)"
"$XTAP" tool sync \
  || fail 4 "tool sync failed (see the JSON above). Setup itself succeeded."
"$XTAP" tool list

register_skill

step "Done"
cat <<'EOF'
Next: connect the enterprise apps you want under XTAP Connected apps
(the page in the ACT personal portal at https://stage-api.devtunnel.fyi).
EOF
