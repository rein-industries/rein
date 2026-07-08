# Rein

**Your coding agents, anywhere.** Rein remote-controls the AI coding harnesses on
your own machines — **Claude Code, Codex, opencode** — from your phone, over your
own subscriptions. Your code and conversations stay between your phone and your
machines; Rein never touches your API keys.

This is Rein's public home: **bridge releases, and the issue tracker for both the
mobile app and the bridge.** The source is developed privately.

## Install the bridge

```sh
curl -fsSL rein.build | sh
```

or `npm i -g rein-bridge`, or `brew install rein-industries/tap/rein`. All
channels install the same prebuilt `rein` binary (macOS/Linux, arm64/x64),
verified against each release's `SHA256SUMS`. Then:

```sh
rein login     # link this machine to your account
rein start     # start the bridge
rein token     # show the pairing QR / code for the app
```

Manual download: grab `rein-<os>-<arch>.tar.gz` from
[Releases](https://github.com/rein-industries/rein/releases/latest), verify it
against `SHA256SUMS`, extract, and run `./rein start`.

## Report a bug

- **Mobile app** — fastest from inside the app: **Settings → Help → Report a
  bug** (it pre-fills your app version, protocol version, and device). Or
  [open an app bug report](https://github.com/rein-industries/rein/issues/new?template=bug_report.yml).
- **Bridge / CLI** —
  [open a bridge bug report](https://github.com/rein-industries/rein/issues/new?template=bug_report_bridge.yml).
  Include `rein version` and, if relevant, the tail of `~/.reins/bridge.log`.

## Request a feature

[Open a feature request](https://github.com/rein-industries/rein/issues/new?template=feature_request.yml)
and tell us the problem you're trying to solve.

## Before you open an issue

- **Search [existing issues](https://github.com/rein-industries/rein/issues)** —
  a 👍 on an existing issue helps us prioritize.
- **One issue per report.** Separate bugs and ideas are easier to track and fix.
- **Never include secrets.** Don't paste pairing tokens, access tokens, or
  anything from a session transcript. We never need your code to fix a bug.

## Privacy

Rein is built so your code and conversations stay between your phone and your own
machines. Please keep it that way in your reports — screenshots and steps are
plenty.

- Homepage: <https://rein.build>

---

© 2026 Workman Trading Company
