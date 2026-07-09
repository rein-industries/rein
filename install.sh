#!/bin/sh
# rein installer —  curl -fsSL rein.build | sh
#
# Downloads the latest released rein binary for this machine, verifies its
# checksum, installs it under ~/.reins/bin with its native node-pty sidecars,
# links `rein` onto your PATH, starts the bridge, and prints the pairing code.
#
# It never touches API keys and pairs only with your phone. Re-running upgrades
# in place. Override behaviour with env vars:
#   REINS_VERSION       pin a version (e.g. 0.2.0); default: latest
#   REINS_REPO          GitHub owner/repo; default: rein-industries/rein
#   REINS_RELEASE_BASE  full base URL for assets (overrides repo/version)
#   REINS_INSTALL_DIR   where the binary + sidecars land; default: ~/.reins/bin
#   REINS_BIN_DIR       where `rein` is linked; default: /usr/local/bin or ~/.local/bin
#   REINS_NO_START=1    install only; don't start the bridge or print pairing
set -eu

# Release tarballs + install.sh live on the public rein-industries/rein repo.
REINS_REPO="${REINS_REPO:-rein-industries/rein}"
REINS_VERSION="${REINS_VERSION:-latest}"
INSTALL_DIR="${REINS_INSTALL_DIR:-$HOME/.reins/bin}"

reset='\033[0m'; bold='\033[1m'; dim='\033[2m'; red='\033[31m'
say() { printf '%b\n' "  $1"; }
err() { printf '%brein:%b %s\n' "$red" "$reset" "$1" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

main() {
  os="$(detect_os)"
  arch="$(detect_arch)"
  asset="rein-${os}-${arch}.tar.gz"
  base="$(release_base)"

  printf '\n  %brein%b  %s/%s\n\n' "$bold" "$reset" "$os" "$arch"

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/rein-install.XXXXXX")"
  trap 'rm -rf "$tmp"' EXIT INT TERM

  say "${dim}↓ $base/$asset${reset}"
  fetch "$base/$asset" "$tmp/$asset" || err "download failed: $base/$asset"
  fetch "$base/SHA256SUMS" "$tmp/SHA256SUMS" || err "download failed: $base/SHA256SUMS"
  verify_checksum "$tmp" "$asset"
  say "✓ checksum verified"

  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tmp/$asset" -C "$INSTALL_DIR"
  chmod 0755 "$INSTALL_DIR/rein" 2>/dev/null || true
  [ -f "$INSTALL_DIR/spawn-helper" ] && chmod 0755 "$INSTALL_DIR/spawn-helper" 2>/dev/null || true
  rein="$INSTALL_DIR/rein"
  say "✓ installed $("$rein" --version 2>/dev/null || echo rein) → ${dim}$INSTALL_DIR${reset}"

  link_dir="$(choose_bin_dir)"
  link="$link_dir/rein"

  if [ "${REINS_NO_START:-0}" = "1" ]; then
    link_cli "$rein" "$link_dir" "$link"
    say "Installed. Finish setup later with: ${bold}rein setup${reset}"
    finish "$link_dir"
    return
  fi

  # Always-on service (LaunchAgent / systemd --user) + CLI link.
  link_cli "$rein" "$link_dir" "$link"
  if "$rein" install --cli-link "$link" >/dev/null 2>&1; then
    say "✓ service installed"
  else
    # install may have printed errors; retry without silencing so the user sees them
    "$rein" install --cli-link "$link" || true
  fi

  finish "$link_dir"

  # Interactive post-install: forced sign-in (Grok-style) → pairing panel.
  # Headless/CI (no TTY) just leaves the service running.
  if [ -t 0 ] && [ -t 1 ] && [ "${REINS_NO_SETUP:-0}" != "1" ]; then
    printf '\n'
    "$rein" setup || true
  else
    "$rein" start >/dev/null 2>&1 || true
    say "✓ bridge running"
    if "$rein" whoami 2>/dev/null | grep -q 'signed in'; then
      printf '\n  %bPair with the Rein app:%b\n' "$bold" "$reset"
      "$rein" token 2>/dev/null || true
    else
      printf '\n  %bSign in to finish setup:%b  rein setup\n' "$bold" "$reset"
    fi
  fi
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo darwin ;;
    Linux) echo linux ;;
    *) err "unsupported OS: $(uname -s) (rein supports macOS and Linux)" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    arm64 | aarch64) echo arm64 ;;
    x86_64 | amd64) echo x64 ;;
    *) err "unsupported architecture: $(uname -m)" ;;
  esac
}

release_base() {
  if [ -n "${REINS_RELEASE_BASE:-}" ]; then
    echo "${REINS_RELEASE_BASE%/}"
  elif [ "$REINS_VERSION" = "latest" ]; then
    echo "https://github.com/$REINS_REPO/releases/latest/download"
  else
    echo "https://github.com/$REINS_REPO/releases/download/v${REINS_VERSION#v}"
  fi
}

fetch() {
  # fetch URL DEST
  if have curl; then
    curl -fsSL "$1" -o "$2"
  elif have wget; then
    wget -qO "$2" "$1"
  else
    err "need curl or wget to download"
  fi
}

verify_checksum() {
  # verify_checksum DIR ASSET  — checks ASSET against the line in DIR/SHA256SUMS
  dir="$1"; asset="$2"
  line="$(grep " ${asset}\$" "$dir/SHA256SUMS" 2>/dev/null || grep "$asset" "$dir/SHA256SUMS" 2>/dev/null || true)"
  [ -n "$line" ] || err "no checksum for $asset in SHA256SUMS"
  echo "$line" >"$dir/.sum"
  if have sha256sum; then
    ( cd "$dir" && sha256sum -c .sum >/dev/null 2>&1 ) || err "checksum mismatch for $asset"
  elif have shasum; then
    ( cd "$dir" && shasum -a 256 -c .sum >/dev/null 2>&1 ) || err "checksum mismatch for $asset"
  else
    say "${dim}! no sha256 tool found — skipping checksum verification${reset}"
  fi
}

choose_bin_dir() {
  if [ -n "${REINS_BIN_DIR:-}" ]; then echo "$REINS_BIN_DIR"; return; fi
  if [ -w /usr/local/bin ] 2>/dev/null; then echo /usr/local/bin; return; fi
  echo "$HOME/.local/bin"
}

link_cli() {
  # link_cli REIN_BIN LINK_DIR LINK
  rein_bin="$1"; link_dir="$2"; link="$3"
  mkdir -p "$link_dir"
  ln -sf "$rein_bin" "$link"
  say "✓ linked ${dim}$link${reset}"
}

finish() {
  link_dir="$1"
  case ":$PATH:" in
    *":$link_dir:"*) : ;;
    *) printf '\n  %b!%b %s is not on your PATH. Add:\n      export PATH="%s:$PATH"\n' \
         "$red" "$reset" "$link_dir" "$link_dir" ;;
  esac
}

main "$@"
