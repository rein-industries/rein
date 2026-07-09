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
#   REINS_BIN_DIR       where `rein` is linked; default: stable dirs first
#                       (~/.local/bin, Homebrew), then first writable PATH
#                       entry that is not a version-manager bin (nvm/fnm/…)
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

  # So `rein` works for any later steps in this shell (and so the PATH note is
  # accurate if the user pastes the export into the same session).
  case ":$PATH:" in
    *":$link_dir:"*) : ;;
    *) PATH="$link_dir:$PATH"; export PATH ;;
  esac

  # Interactive post-install: sign-in → pairing panel, then leave the CLI ready.
  #
  # Under `curl | sh`, this shell's stdin IS the script pipe. Never remount the
  # shell's own fd 0 onto /dev/tty (`exec </dev/tty`): after main returns the
  # shell still needs one more read() to see EOF, and a TTY never delivers it —
  # so the installer hangs after "Setup complete." eating keystrokes as script
  # source. Redirect only the setup *command* onto /dev/tty; leave the shell's
  # stdin on the pipe so it can exit cleanly. (rein's TUI opens /dev/tty itself
  # for raw keys; the redirect only needs to make process.stdin.isTTY true.)
  if [ "${REINS_NO_SETUP:-0}" != "1" ] && [ -t 1 ] && can_talk_to_tty; then
    printf '\n  %bStarting setup…%b\n\n' "$bold" "$reset"
    if [ -t 0 ]; then
      setup_ok=0
      "$rein" setup || setup_ok=$?
    else
      # Per-command redirect — do not touch the installer's shell stdin.
      setup_ok=0
      "$rein" setup </dev/tty || setup_ok=$?
    fi
    if [ "$setup_ok" -ne 0 ]; then
      printf '\n  %bSetup did not finish.%b Run %brein setup%b to try again.\n' \
        "$bold" "$reset" "$bold" "$reset"
    fi
  # Anchored: whoami prints "signed in: …" when linked but "Not signed in." when
  # not, and an unanchored grep matches both.
  elif "$rein" whoami 2>/dev/null | grep -q '^signed in:'; then
    printf '\n  %bPair with the Rein app:%b run %brein setup%b\n' \
      "$bold" "$reset" "$bold" "$reset"
    printf '  Run %brein%b any time to use the CLI.\n' "$bold" "$reset"
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

# Where to put the `rein` symlink. Prefer a directory already on PATH so a
# fresh install doesn't print a scary PATH warning and `rein` works in the
# next terminal without editing shell config.
#
# Order:
#   1. REINS_BIN_DIR override
#   2. stable candidates already on PATH (~/.local/bin, Homebrew, /usr/local)
#   3. first absolute, writable PATH entry that is not a version-manager bin
#      (nvm/fnm/asdf/… disappear when that runtime version is uninstalled)
#   4. common package prefixes if writable, else ~/.local/bin
#
# True when $1 looks like a version-manager or tool-managed bin dir. Linking
# `rein` there makes it vanish on `nvm use` / uninstall of that Node version.
is_volatile_bin_dir() {
  case "$1" in
    */.nvm/*|*/nvm/versions/*|*/.fnm/*|*/.local/share/fnm/*|*/.asdf/*|\
    */.volta/*|*/.nodenv/*|*/.n/*|*/.local/share/mise/*|*/mise/installs/*|\
    */.pyenv/*|*/.rbenv/*|*/.jenv/*|*/.sdkman/*|*/node_modules/*)
      return 0
      ;;
  esac
  return 1
}

# True when $1 is already on PATH (exact entry match).
dir_on_path() {
  case ":$PATH:" in
    *":$1:"*) return 0 ;;
    *) return 1 ;;
  esac
}

# Print $1 if it is a usable link target: absolute, not volatile, and either
# writable or creatable under a writable parent. Returns 0 on success.
try_bin_dir() {
  dir="$1"
  [ -n "$dir" ] || return 1
  case "$dir" in
    /*) ;;
    *) return 1 ;;
  esac
  is_volatile_bin_dir "$dir" && return 1
  if [ -d "$dir" ] && [ -w "$dir" ]; then
    echo "$dir"
    return 0
  fi
  # Listed on PATH but missing (common for ~/.local/bin) — createable parent.
  if [ ! -e "$dir" ]; then
    parent=$(dirname "$dir")
    if [ -d "$parent" ] && [ -w "$parent" ]; then
      echo "$dir"
      return 0
    fi
  fi
  return 1
}

choose_bin_dir() {
  if [ -n "${REINS_BIN_DIR:-}" ]; then echo "$REINS_BIN_DIR"; return; fi

  # Prefer durable locations when they are already on PATH (or can be created
  # there). First-writable-on-PATH alone used to pick nvm's active Node bin.
  for dir in "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin; do
    if dir_on_path "$dir" && try_bin_dir "$dir"; then
      return
    fi
  done

  old_ifs=$IFS
  IFS=:
  # shellcheck disable=SC2086 # intentional word-split of PATH
  for dir in $PATH; do
    IFS=$old_ifs
    if try_bin_dir "$dir"; then
      return
    fi
  done
  IFS=$old_ifs

  for dir in /opt/homebrew/bin /usr/local/bin; do
    if try_bin_dir "$dir"; then
      return
    fi
  done
  echo "$HOME/.local/bin"
}

# Login shell the *user* runs interactively ($SHELL), not the interpreter
# running this script (`curl | sh` is always sh/dash/bash-as-sh).
detect_login_shell() {
  basename "${SHELL:-}"
}

# Print a PATH-hint line + optional "append to your rc" example tailored to
# the login shell. Fish uses different syntax than bash/zsh.
finish() {
  link_dir="$1"
  case ":$PATH:" in
    *":$link_dir:"*) : ;;
    *)
      # Tip, not an error — install succeeded; the next shell just won't see
      # `rein` until PATH is updated. Soft tone so it doesn't read as failure
      # mid-setup (the old red "!" looked like a crash).
      printf '\n  %bNote:%b %s is not on your PATH yet.\n' "$bold" "$reset" "$link_dir"
      shell_name=$(detect_login_shell)
      case "$shell_name" in
        fish)
          # fish_add_path updates the universal PATH (persists); no config edit needed.
          printf '  Run this once so %brein%b works in new fish terminals:\n' \
            "$bold" "$reset"
          printf '      fish_add_path %s\n' "$link_dir"
          ;;
        zsh)
          printf '  Add this line to your shell config so %brein%b works in new terminals:\n' \
            "$bold" "$reset"
          printf '      export PATH="%s:$PATH"\n' "$link_dir"
          printf '  (for example: echo '\''export PATH="%s:$PATH"'\'' >> ~/.zshrc)\n' \
            "$link_dir"
          ;;
        bash)
          printf '  Add this line to your shell config so %brein%b works in new terminals:\n' \
            "$bold" "$reset"
          printf '      export PATH="%s:$PATH"\n' "$link_dir"
          # macOS bash is login-shell heavy → .bash_profile; Linux more often .bashrc
          if [ "$(uname -s 2>/dev/null)" = Darwin ]; then
            rc="$HOME/.bash_profile"
          else
            rc="$HOME/.bashrc"
          fi
          printf '  (for example: echo '\''export PATH="%s:$PATH"'\'' >> %s)\n' \
            "$link_dir" "$rc"
          ;;
        *)
          printf '  Add this line to your shell config so %brein%b works in new terminals:\n' \
            "$bold" "$reset"
          printf '      export PATH="%s:$PATH"\n' "$link_dir"
          if [ -n "$shell_name" ]; then
            printf '  %b(detected login shell: %s — pick the matching rc file)%b\n' \
              "$dim" "$shell_name" "$reset"
          fi
          ;;
      esac
      ;;
  esac
}

# True when we can drive an interactive setup UI. Stdin may be a pipe
# (`curl | sh`); /dev/tty is the user's real terminal when one exists.
can_talk_to_tty() {
  [ -t 0 ] && return 0
  [ -c /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

main "$@"
