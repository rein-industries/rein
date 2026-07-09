<div align="center">

<a href="https://rein.build">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/wordmark-dark.png">
    <img src="docs/assets/wordmark-light.png" alt="rein" width="260">
  </picture>
</a>

### Control your coding agents from anywhere.

Rein connects to the agents running on your machine.<br>
Start at your desk, pick up anywhere.

[**rein.build**](https://rein.build) · [**Download the app**](https://rein.build) · [**Changelog**](https://github.com/rein-industries/rein/blob/main/CHANGELOG.md) · [**npm**](https://www.npmjs.com/package/@rein-industries/rein)

Works with **Claude Code** · **Codex** · **Gemini** · **opencode** · **Grok**

</div>

---

Rein is two pieces:

- **The bridge**, a small daemon on your Mac or Linux machine. It drives the same
  agent CLIs you already use, with the subscriptions you already pay for, and
  streams their sessions out over an encrypted connection.
- **The Rein app** for iPhone. It pairs with your machines and puts live
  transcripts, permission prompts, diffs, terminals, and dev-server previews in
  your pocket.

Rein never calls a model API and never touches an API key. Sessions travel peer
to peer, over encrypted WebRTC or a direct socket on your own network. Rein's
servers only set up the connection; they never see what moves across it.

## Install the bridge

One command on the machine where your agents run:

```sh
curl -fsSL rein.build | sh
```

Prefer a package manager?

```sh
npm i -g @rein-industries/rein         # npm
bun i -g @rein-industries/rein         # bun
brew install rein-industries/tap/rein  # Homebrew
```

Every channel installs the same prebuilt `rein` binary (macOS and Linux, arm64
and x64), verified against the release `SHA256SUMS`. No Node, Bun, or build
toolchain required.

The install script also sets up an always-on background service (macOS
LaunchAgent / Linux systemd user unit) and, when run in a terminal, launches
`rein setup`: sign in, then pair your phone from a live QR panel. With npm, bun,
or Homebrew, run `rein setup` once after install.

**Upgrades** follow the channel you installed from: `rein update` (curl),
`npm i -g @rein-industries/rein@latest` (npm), or `brew upgrade rein` (Homebrew).
`rein update` detects a package-managed install and points you at the right
command instead of clobbering it.

<details>
<summary><b>Manual download</b></summary>
<br>

Grab `rein-<os>-<arch>.tar.gz` from the
[latest release](https://github.com/rein-industries/rein/releases/latest),
verify it against `SHA256SUMS`, extract, and run `./rein setup`.

</details>

## Get the app

Download the Rein app at [rein.build](https://rein.build). iOS first; the
bridge installs on macOS and Linux.

## Set up once, then just connect

1. **Install the bridge.** One command. It starts on your machine and shows a QR.
2. **Pair the phone.** Scan it. The credential transfers over the direct
   connection.
3. **Keep working.** Start runs, answer prompts, and review diffs from anywhere.

Three ways a phone can meet a bridge:

- **QR.** The pairing panel (`rein run`, or `rein token` any time) prints a
  `reins://` QR encoding the bridge address, a one-time pairing secret, and the
  TLS cert fingerprint. Scan it in the app.
- **Short code.** The same panel shows a short rotating code for when the QR
  isn't handy; the app resolves it through the pairing relay.
- **Same account.** `rein login` signs the bridge machine into your account. A
  phone signed into the same account discovers the machine with no QR or code at
  all.

In every path the pairing secret is strictly one-time: on the first
authenticated connection the bridge hands the durable credential straight to the
phone, and the phone stores it in the device keychain for every reconnect.

## What's in the app

- **Workspace.** Every machine and session in one place, sorted by what needs
  you.
- **Sessions.** The full transcript, streaming live: thinking, tool calls,
  output. Disconnect mid-turn and missed events replay when you're back.
- **Changes.** Real diffs straight from the worktree, file by file.
- **Live preview.** Open the dev server your agent just started, on the phone.
  Share it private, unlisted, or public.
- **Terminal.** A real terminal on your machine, from wherever you are.
- **Approvals.** Permission prompts arrive as cards. Allow once, always allow,
  or deny.

Plus: push notifications and Live Activities for turn completions and
permission prompts, worktree-isolated sessions so concurrent runs in one repo
never touch each other's files, and `rein resume` to reopen any session in its
agent's own CLI back on the desktop.

## Your phone. Your machine. Nothing in between.

```
┌─────────────┐                                ┌──────────────────┐
│  Your phone │ ◀──── encrypted, direct ─────▶ │   Your machine   │
│  Rein app   │                                │   rein bridge    │
└─────────────┘                                └──────────────────┘
```

- **Pair once.** Pairing exchanges a one-time secret; each phone gets its own
  revocable credential. Rotate it any time with `rein token --reset`.
- **Encrypted end to end.** On your own network, sessions ride a direct `wss://`
  socket secured by a certificate the phone pins by fingerprint. Away from it,
  they ride a DTLS-encrypted WebRTC channel.
- **No one in the middle.** Connection fingerprints are bound to your pairing
  trust, so the signaling service can't swap them. It sees only ciphertext.
- **Everything stays local.** Code, transcripts, and provider tokens live on
  your machine. Rein's servers only set up the connection.
- **No API keys, anywhere.** The bridge strips every `*_API_KEY`-shaped variable
  from agent child environments. Each agent authenticates with its own
  subscription login, done once on the bridge machine.
- **Approvals flow to your phone.** "Always allow" rules are scoped to the live
  session in memory; Rein never edits your agents' settings files.

There's no need to port-forward the bridge to the public internet, and you
shouldn't: the WebRTC path exists so you never have to.

## The `rein` CLI

```sh
rein setup             # interactive: always-on service + sign-in + pairing
rein start             # start the bridge in the background
rein run               # run in the foreground with the live pairing panel
rein stop              # graceful stop
rein restart           # stop then start
rein status --json     # machine-readable status
rein logs --tail 100   # bridge logs
rein token             # re-print the pairing QR / short code
rein token --reset     # rotate the pairing token
rein login             # sign this machine into your account
rein logout            # sign out and revoke the machine credential
rein whoami            # show the signed-in account
rein resume [query]    # reopen a Rein session in its agent's own CLI
rein update            # self-update to the latest release
rein version
```

The bridge listens on `0.0.0.0:8787` by default (override with `--port` /
`--host`). `rein start` and `rein run` also accept `--relay URL`,
`--signaling URL`, and `--ice-policy relay|all` to point at self-hosted
infrastructure or tune WebRTC.

Bridge state lives under `~/.reins`: `config.json` (pairing token, mode 0600),
session transcripts, and `bridge.log`. `rein uninstall` removes the service and
runtime files, and leaves your config and session history unless you pass
`--purge-data`.

## Supported agents

Rein drives the official CLIs over the
[Agent Client Protocol](https://agentclientprotocol.com) (ACP). Install at
least one on the bridge machine and log in with your subscription:

| Agent | Log in with | Driven via |
| --- | --- | --- |
| **Claude Code** | `claude` → `/login` | `claude-agent-acp` |
| **Codex** | `codex login` | `codex-acp` |
| **Gemini CLI** | `gemini` → sign in | `gemini --acp` |
| **opencode** | `opencode auth login` | `opencode acp` |
| **Grok CLI** | `grok login` | `grok agent stdio` |

Claude Code and Codex are driven through thin ACP wrapper CLIs; install them
once on the bridge machine:

```sh
npm i -g @agentclientprotocol/claude-agent-acp @agentclientprotocol/codex-acp
```

Every agent gets the same treatment in the app: model and effort pickers,
permission modes, slash commands, streaming thinking and tool output, interrupt
and resume, and usage on every turn.

<details>
<summary><b>Capability matrix</b></summary>
<br>

As verified against the pinned versions:

| | **Claude Code** (≥ 2.1.173) | **Codex** (0.137.0) | **opencode** (1.15.13) |
| --- | --- | --- | --- |
| Models | `opus`, `sonnet`, `haiku`, `default` (+`[1m]` variants) | `gpt-5.5`, `gpt-5.4`, `gpt-5.4-mini`, `gpt-5.3-codex-spark` | All credentialed providers (~36 models, `provider/model` ids) |
| Efforts | `low` `medium` `high` `xhigh` `max` | `low` `medium` `high` `xhigh` | model variants (per-model) |
| Permission modes | `default`, `acceptEdits`, `plan`, `bypassPermissions` | `read-only`, `agent`, `agent-full-access` | `build`, `plan`, `ask` |
| Slash commands | ~70 (builtin + user + plugin) | ~59 (skills native, `~/.codex/prompts` inlined) | ~51 via the command API |
| Streaming tool output | end-of-tool only (SDK limitation) | live `outputDelta` chunks | live part deltas |
| Interrupt / resume | yes / yes | yes / yes | yes / yes (Rein-created sessions only) |
| Thinking stream | yes | yes (reasoning summaries) | yes |
| Usage on turn end | tokens, cache, cost, context % | tokens, cache, context % | tokens, cache |

Gemini CLI: models `gemini-2.5-pro` / `-flash` / `-flash-lite`; approval modes
`default`, `auto_edit`, `yolo`, `plan`. Grok CLI: models `grok-4.5` /
`grok-composer-2.5-fast`; efforts `high` / `medium` / `low`; permission modes
`default`, `acceptEdits`, `plan`, `bypassPermissions`.

</details>

## Troubleshooting

**An agent shows "not found" in the app.** The bridge resolves each CLI from
`PATH` and re-probes every ~15s, so a fresh install usually appears within one
scan. Check the CLI's `--version` works in the same shell environment the
bridge runs in; if the install created a brand-new directory not on the
daemon's `PATH`, run `rein restart` so the bridge inherits the new environment.

**Phone can't connect after scanning the QR.** For the initial pairing, phone
and bridge must be on the same network (or the same tailnet); after pairing,
reconnects can fall back to the WebRTC path from anywhere. Check
`curl -k https://<host>:8787/health` returns `{"ok":true}` from another
machine. If the token was rotated, re-pair from Settings → Re-pair.

**opencode sessions don't appear in my normal opencode TUI (and vice versa).**
Deliberate: the bridge runs opencode with an isolated database so version
migrations can't break the pinned server. Rein-created opencode sessions are
only visible through Rein.

**Claude permission prompts never appear for read-only commands.** That's
Claude Code's own safe-command heuristic auto-approving them in `default` mode;
write-producing commands prompt as expected.

## FAQ

**Does my code go through Rein's servers?** No. Session content moves
phone-to-bridge over a LAN socket or an encrypted WebRTC channel. Signaling
never carries prompts, files, or output.

**Do I put API keys in the app?** No. Provider tokens stay on your computer.
The app authenticates with a per-phone credential you can revoke.

**Which agents does it work with?** Claude Code, Codex, Gemini, opencode, and
Grok. Rein drives the official CLIs over the Agent Client Protocol.

**What happens when my machine goes offline?** The workspace lets you know.
Sessions resume and missed events replay when the bridge is back.

**What does it run on?** iOS first. The bridge installs on macOS and Linux.

## Bugs and feature requests

- **Mobile app**: fastest from inside the app via **Settings → Help → Report a
  bug** (it pre-fills your app version, protocol version, and device). Or
  [open an app bug report](https://github.com/rein-industries/rein/issues/new?template=bug_report.yml).
- **Bridge / CLI**:
  [open a bridge bug report](https://github.com/rein-industries/rein/issues/new?template=bug_report_bridge.yml).
  Include `rein version` and, if relevant, the tail of `~/.reins/bridge.log`.
- **Ideas**:
  [open a feature request](https://github.com/rein-industries/rein/issues/new?template=feature_request.yml)
  and tell us the problem you're trying to solve.

Please search
[existing issues](https://github.com/rein-industries/rein/issues) first, keep
one issue per report, and never paste pairing tokens, access tokens, or session
transcripts. We never need your code to fix a bug.

## Source

Rein is developed in a private monorepo;
[github.com/rein-industries/rein](https://github.com/rein-industries/rein) is
its public home: bridge releases, `install.sh`, the changelog, and the issue
tracker. In the source tree, contributor docs live in `docs/DEVELOPMENT.md`.

---

<div align="center">

[rein.build](https://rein.build) · [Privacy](https://rein.build/privacy)

© 2026 Rein Industries, a division of Workman Trading Company

</div>
