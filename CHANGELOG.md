# Changelog

All notable changes to rein are documented here. Versions match
GitHub Releases on this repo (built from private source).

## [0.1.29] - 2026-07-10

### Changes

- Fix check: biome formatting + hermetic ACP catalog-cache tests
- 405e90c2 (#45)

## [0.1.28] - 2026-07-10

### Changes

- Harden sign-in, post-pair relay handoff, and onboarding install UX
- Fix EAS release bundling: build Metro config via getSentryExpoConfig
- Drop the at-cap caption; Create bounces straight to the paywall

## [0.1.27] - 2026-07-10

### Changes

- Remove dead RevenueCat exports, unused Lockup, and stale knip ignore
- Mobile: bind RevenueCat only after sign-in with durable app user id
- Add mobile Sentry, loading skeleton polish, and faster rendezvous rejoin
- Heal wedged transcript viewport and single-fade fold expansion

## [0.1.26] - 2026-07-10

### Changes

- Fix order-dependent mobile test poisoning from partial module mocks
- Mobile: free app client side, plan gates, archive/import views, fixes
- Bridge: auto-continue vetoes, task-resume seam, exec exit settling
- Make the core app free with live plan caps; add demo machine and bug reports

## [0.1.25] - 2026-07-09

### Changes

- Fix choose_bin_dir test PATH to use absolute entries
- Fix install test host-dependence and unexport wait helper
- Fix curl|sh installer hang and double bridge start

## [0.1.24] - 2026-07-09

### Changes

- Fix rein setup hanging the terminal after quit

## [0.1.23] - 2026-07-09

### Changes

- Unexport KeySource (knip broke the release check)
- Fix biome formatting in tty-input and App.tsx import order
- Poll /dev/tty directly; stop using tty.ReadStream (macOS setup hang)
- Site: restore 1-bit dither bands; update privacy contact
- Site: redraw the bands as a hairline ridge field; workspace shot on mobile

## [0.1.22] - 2026-07-09

### Changes

- Surface free-plan machine limit as a clear sign-in error

## [0.1.21] - 2026-07-09

### Changes

- Fix rein setup/run hanging the terminal on quit (Bun tty bugs)
- Site: update social meta tags to Rein: Coding Agent, Anywhere
- Site: make dither motion visible on mobile and smooth shot loading

## [0.1.20] - 2026-07-09

### Changes

- Make rein update interruptible; keep spinner on one line

## [0.1.19] - 2026-07-09

### Changes

- Add dots spinner to rein update; align app err with CLI palette

## [0.1.18] - 2026-07-09

### Changes

- Fix setup EBADF crash; celebrate successful phone pairing

## [0.1.17] - 2026-07-09

### Changes

- Read keys from /dev/tty so pairing p/q/Ctrl-C work
- Site: lock image drag and add a drafting-sheet 404 page
