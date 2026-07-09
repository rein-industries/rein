#!/bin/sh
# rein installer —  curl -fsSL rein.build | sh
#
# Downloads the latest released rein binary for this machine, verifies its
# checksum, installs it under ~/.reins/bin with its native node-pty sidecars,
# links `rein` onto your PATH, starts the bridge, and launches interactive
# setup (sign-in + pairing). After setup, run `rein` any time to use the CLI.
#
# It never touches API keys and pairs only with your phone. Re-running upgrades
# in place. Override behaviour with env vars:
#   REINS_VERSION       pin a version (e.g. 0.2.0); default: latest
#   REINS_REPO          GitHub owner/repo; default: rein-industries/rein
#   REINS_RELEASE_BASE  full base URL for assets (overrides repo/version)
#   REINS_INSTALL_DIR   where the binary + sidecars land; default: ~/.reins/bin
#   REINS_BIN_DIR       where `rein` is linked; default: /usr/local/bin or ~/.local/bin
#   REINS_NO_START=1    install only; don't start the bridge or run setup
#   REINS_NO_SETUP=1    install + start the service; skip interactive setup
set -eu

# Release tarballs + install.sh live on the public rein-industries/rein repo.
REINS_REPO="${REINS_REPO:-rein-industries/rein}"
REINS_VERSION="${REINS_VERSION:-latest}"
INSTALL_DIR="${REINS_INSTALL_DIR:-$HOME/.reins/bin}"

reset='\033[0m'; bold='\033[1m'; dim='\033[2m'; red='\033[31m'
say() { printf '%b\n' "  $1"; }
err() { printf '%brein:%b %s\n' "$red" "$reset" "$1" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Live progress only when we're talking to a terminal (curl | sh keeps
# stdout/stderr on the tty; CI logs get plain lines instead).
TTY=0
[ -t 1 ] && [ -t 2 ] && TTY=1

main() {
  os="$(detect_os)"
  arch="$(detect_arch)"
  asset="rein-${os}-${arch}.tar.gz"
  base="$(release_base)"

  printf '\n  %brein%b  %s/%s\n\n' "$bold" "$reset" "$os" "$arch"

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/rein-install.XXXXXX")"
  trap 'rm -rf "$tmp"' EXIT INT TERM

  say "${dim}↓ $base/$asset${reset}"
  # Checksums ride down in the background while the tarball streams.
  fetch "$base/SHA256SUMS" "$tmp/SHA256SUMS" &
  sums_pid=$!
  download "$base/$asset" "$tmp/$asset" || err "download failed: $base/$asset"
  wait "$sums_pid" || err "download failed: $base/SHA256SUMS"
  verify_checksum "$tmp" "$asset"

  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tmp/$asset" -C "$INSTALL_DIR"
  chmod 0755 "$INSTALL_DIR/rein" 2>/dev/null || true
  [ -f "$INSTALL_DIR/spawn-helper" ] && chmod 0755 "$INSTALL_DIR/spawn-helper" 2>/dev/null || true
  rein="$INSTALL_DIR/rein"

  link_dir="$(choose_bin_dir)"
  link="$link_dir/rein"
  mkdir -p "$link_dir"
  ln -sf "$rein" "$link"
  ver="$("$rein" --version 2>/dev/null || true)"
  say "✓ rein${ver:+ $ver} verified and installed ${dim}$link${reset}"

  if [ "${REINS_NO_START:-0}" = "1" ]; then
    say "Installed. Finish setup later with: ${bold}rein setup${reset}"
    finish "$link_dir"
    return
  fi

  # Always-on service (LaunchAgent / systemd --user); `rein install` also
  # starts the bridge and waits until it is up.
  if step "starting the bridge service" "$rein" install --cli-link "$link"; then
    say "✓ bridge running as a service"
  else
    say "${red}!${reset} service setup failed; finish with: ${bold}rein setup${reset}"
  fi

  finish "$link_dir"

  # Interactive post-install: sign-in → pairing panel, then leave the CLI ready.
  # Under `curl | sh`, stdin is the download pipe (not a TTY) even when the user
  # is at a real terminal — open /dev/tty so setup still starts automatically.
  if [ "${REINS_NO_SETUP:-0}" != "1" ] && [ -t 1 ] && can_talk_to_tty; then
    printf '\n  %bStarting setup…%b\n\n' "$bold" "$reset"
    if [ -t 0 ]; then
      "$rein" setup || true
    else
      "$rein" setup </dev/tty || true
    fi
  # Anchored: whoami prints "signed in: …" when linked but "Not signed in." when
  # not, and an unanchored grep matches both.
  elif "$rein" whoami 2>/dev/null | grep -q '^signed in:'; then
    printf '\n  %bPair with the Rein app:%b\n' "$bold" "$reset"
    "$rein" token 2>/dev/null || true
    printf '\n  Run %brein%b any time to use the CLI.\n' "$bold" "$reset"
  else
    printf '\n  %bNext:%b run %brein setup%b to sign in and pair your phone.\n' \
      "$bold" "$reset" "$bold" "$reset"
    printf '  After that, run %brein%b any time to use the CLI.\n' "$bold" "$reset"
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
  # fetch URL DEST — quiet download for small files
  if have curl; then
    curl -fsSL "$1" -o "$2"
  elif have wget; then
    wget -qO "$2" "$1"
  else
    err "need curl or wget to download"
  fi
}

download() {
  # download URL DEST — the big tarball: progress bar on a terminal
  if have curl; then
    if [ "$TTY" = "1" ]; then
      # -# draws a single-line bar on stderr; erase it once complete so the
      # summary line replaces it.
      curl -f -# -L "$1" -o "$2" || return 1
      printf '\033[1A\r\033[2K' >&2
    else
      curl -fsSL "$1" -o "$2"
    fi
  elif have wget; then
    step "downloading" wget -qO "$2" "$1"
  else
    err "need curl or wget to download"
  fi
}

step() {
  # step LABEL CMD... — run CMD silenced with an in-place spinner on a
  # terminal; on failure replay the captured output and return non-zero.
  step_label="$1"; shift
  step_log="$tmp/step.log"
  if [ "$TTY" = "1" ]; then
    "$@" >"$step_log" 2>&1 &
    step_pid=$!
    while kill -0 "$step_pid" 2>/dev/null; do
      for f in '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'; do
        kill -0 "$step_pid" 2>/dev/null || break
        printf '\r  %b%s%b %s' "$dim" "$f" "$reset" "$step_label"
        sleep 0.1
      done
    done
    wait "$step_pid" && step_rc=0 || step_rc=$?
    printf '\r\033[2K'
  else
    say "${dim}$step_label…${reset}"
    "$@" >"$step_log" 2>&1 && step_rc=0 || step_rc=$?
  fi
  if [ "$step_rc" -ne 0 ] && [ -s "$step_log" ]; then
    sed 's/^/  /' "$step_log" >&2
  fi
  return "$step_rc"
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
    say "${dim}! no sha256 tool found, skipping checksum verification${reset}"
  fi
}

choose_bin_dir() {
  if [ -n "${REINS_BIN_DIR:-}" ]; then echo "$REINS_BIN_DIR"; return; fi
  if [ -w /usr/local/bin ] 2>/dev/null; then echo /usr/local/bin; return; fi
  echo "$HOME/.local/bin"
}

finish() {
  link_dir="$1"
  case ":$PATH:" in
    *":$link_dir:"*) : ;;
    *) printf '\n  %b!%b %s is not on your PATH. Add:\n      export PATH="%s:$PATH"\n' \
         "$red" "$reset" "$link_dir" "$link_dir" ;;
  esac
}

# True when we can drive an interactive setup UI. Stdin may be a pipe
# (`curl | sh`); /dev/tty is the user's real terminal when one exists.
can_talk_to_tty() {
  [ -t 0 ] && return 0
  [ -c /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

main "$@"
