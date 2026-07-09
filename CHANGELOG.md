# Changelog

All notable changes to rein are documented here. Versions match
GitHub Releases on this repo (built from private source).

## [0.1.13] - 2026-07-09

### Changes

- Fix p/q keys on pairing screen (raw and cooked TTYs)

## [0.1.12] - 2026-07-09

### Changes

- Speed up post-auth pairing; stop crashing after browser approval

## [0.1.11] - 2026-07-09

### Changes

- Fix setup stalling after folder note under curl | sh

## [0.1.10] - 2026-07-09

### Changes

- Let unentitled accounts pair; auto-run setup under curl | sh

## [0.1.9] - 2026-07-09

### Changes

- Ship Expo 57, terminal reclaim, and the biome fixes that redded CI
- Keep sessions honest through background-task resumes; fix auto-continue vetoes

## [0.1.8] - 2026-07-09

### Changes

- Development (#44)

## [0.1.7] - 2026-07-09

### Changes

- Self-provision the claude/codex ACP shims
- Point APNs Live Activity topic at the production bundle id

## [0.1.6] - 2026-07-09

### Changes

- Update README to simplify agent information

## [0.1.5] - 2026-07-09

### Changes

- Remove image section from README

## [0.1.4] - 2026-07-09

### Changes

- Fix macOS stop/restart and speed up install

## [0.1.3] - 2026-07-09

### Changes

- Rewrite READMEs as site-based public docs, synced on release
- Auto-release mobile production on app-relevant pushes to main

## [0.1.2] - 2026-07-09

### Changes

- Fix main check: prune dead exports flagged by knip
- Gate releases on bridge-relevant changes

## [0.1.1] - 2026-07-09

### Changes

- Switch site iOS CTA to TestFlight beta button
- Accept RELEASE_GITHUB_TOKEN in remaining release jobs

## [0.1.0] - 2026-07-09

### Changes

- Accept RELEASE_GITHUB_TOKEN as well as RELEASES_GITHUB_TOKEN
- Build darwin-x64 on macos-14 via native prebuilds
- Fix CI: biome format and lint cleanups
- Fix release version job: no bare return in node -e
- Automate public releases and harden distribution
- Call the session wall the workspace in site copy
- Point the npm and bun install tabs at @rein-industries/rein
- Lighten the hero CTA and installer chrome
- Recompose the hero CTA as a two-cell app-and-bridge panel
- Make works-with an infinite marquee and tighten landing copy
- Move account/sign-out into a page header with brand provider buttons
- Add an account row with sign-out to the device page
- Redesign the device sign-in/approve page on the drafting sheet
- Hide Grok plan-mode temp worktrees from the import list
- Keep subagent and probe-shell Grok sessions out of the import list
- Add multi-client event fanout regression test
- Never strand the transcript invisible while settling
- Add Grok CLI as a first-class harness with native-sync parity
- Auto-continue agents that announce next work then stop
- Never boot-gate the paywall; returning users get the workspace
- Polish the paywall sale: entitled quiet state, accent CTA, dev preview
- Bring the README up to date with the shipped architecture
- Dismiss the keyboard when a picker sheet opens
- Tighten empty-state and onboarding copy
- Drop the tilt-reactive sheen (and expo-sensors with it)
- Un-modal the onboarding wizard so the paywall can present over it
- Host the privacy policy at rein.build/privacy and link it everywhere
- Stash and replay Apple's once-only fullName
- Route Live Activity taps through the guarded session opener
- Stop phantom-keyboard heals from stranding the composer
