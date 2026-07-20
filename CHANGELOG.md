# Changelog

All notable changes to rein are documented here. Versions match
GitHub Releases on this repo (built from private source).

## [0.1.49] - 2026-07-20

### Changes

- Bridge: sign pty.node in release tarballs + disable library validation
- Mobile: bump version to 0.2.1 for the composer paste feature

## [0.1.48] - 2026-07-17

### Changes

- Mobile: paste a copied screenshot from the composer's native edit menu
- Mobile: guard RawProps preparse against non-object payloads (TestFlight SIGABRT)

## [0.1.47] - 2026-07-17

### Changes

- Bridge: unattended auto-update sweep keeps the daemon current
- Mobile: machine tabs row sits flush on the wall gutter
- Mobile: bridge update offer becomes a trailing Update chip on the machine row

## [0.1.46] - 2026-07-16

### Changes

- Fix release check: lint, format, and knip fallout from the demo-tour push
- Bridge updates, replay batching, auto-import, context ring, demo tour, promo app
- Bridge updates from the app: out-of-date badge + one-tap remote update
- Mobile: multi-machine wall redesign — machine tabs, flat headers, recency order
- Mobile: move machine setup out of onboarding to the wall's /connect hand
- Site: new social share card (phone mockup + headline)

## [0.1.45] - 2026-07-15

### Changes

- mac: gate the pairing QR collapse on the credential roster, not push registrations

## [0.1.44] - 2026-07-15

### Changes

- Security hardening from cloud Workers audit (#58)
- Mobile: bump version to 0.1.1 for App Store submission

## [0.1.43] - 2026-07-15

### Changes

- Bridge: default pairMode to 'open' for the App Store transition
- Wall rendering: plain LegendList + hairline search border

## [0.1.42] - 2026-07-15

### Changes

- Account-match pairing: a bridge admits only its own account
- Pinned-mode borders flatten in JS on legacy clients, masked by a crossfade

## [0.1.41] - 2026-07-15

### Changes

- Fix theme-stuck hairlines on Fabric by painting edges as backgrounds
- Settings gets a Release card: version (build), bundle id, protocol
- OTA adoption: embedded-launch boot gate + apply-on-background
- Machine-cap paywall in /connect replaces the flow, never stacks it
- site: stack the hero cta at every width — button, step label, command box in one column
- Reconnecting strips read in light mode: raised surface, full-ink copy
- New-session connecting beat composed on the EmptyState stage
- Sessions wall snaps reflows while blurred so rows return unoverlapped
- Sessions wall holds its rows while blurred so reflows animate attached
- site: add the "then install the bridge" step label to the hero (#57)
- Device sign-in page hides the code until you're signed in
- site: Get Rein For iOS — swap the TestFlight beta button for the App Store link (#56)

## [0.1.40] - 2026-07-14

### Changes

- site: retire the menu bar scene — the DMG is the desktop app, not a toolbar companion
- uninstall sweeps the Applications folders for Rein.app: a DMG drag-install never wrote a receipt

## [0.1.39] - 2026-07-14

### Changes

- Sign the compiled rein binary with JIT entitlements

## [0.1.38] - 2026-07-14

### Changes

- The toolbar offer checks the Mac can run it: macOS 14 gates the prompt

## [0.1.37] - 2026-07-14

### Changes

- Restart is one supervisor job: stop-then-start dies with its own terminal

## [0.1.36] - 2026-07-14

### Changes

- release: the DMG ships without chat while chat is still in development
- site: the Mac app is included, not a second install
- rein update swaps every sidecar: stale node_datachannel.node lay in wait
- The toolbar ships with the CLI: darwin tarballs carry a bare Rein.app
- An unreachable machine holds its place: the wall classifies on settled status
- Reorder mode seats its cards under the header, not behind it
- site: hero button and install box share one baseline; Mac app joins the navbar
- A dead bridge severs the link, not the chats: offline shelves stay tappable
- Dead machines surface in seconds: the trying window is two-tier by cause
- site: round the pressed rein item's highlight in the menu bar scene
- site: the menu bar scene wears the app's real toolbar icon
- site: real popover captures land — rendered by the app itself in CI
- site: decompress the Mac app section
- site: the Mac app earns its section — menu bar scene + DMG download

## [0.1.35] - 2026-07-14

### Changes

- mac: sign the DMG container itself
- mac: per-binary Developer ID signing for the embedded Electron app
- release: notarize the DMG where package-app.sh actually writes it
- desktop: register the workspace with knip; unexport file-local helpers
- mobile: seal the process-wide mock leaks that break mac-order test runs
- Manual theme survives restart: re-force the trait, boot key outvotes blob
- The machine is the card: multi-machine wall folds each machine into one shelf
- No add-machine CLI flash on fresh sign-in
- Section the wall by machine; unreachable machines trail greyed
- Streaming can't yank a scrolling reader back to the tail
- lockfile: add the desktop app's xterm entries
- desktop: Cursor-class workspace — turn folds, dock, live mirror parity
- release: add the build-mac-app DMG job
- desktop: workspace redesign — machine tree, streaming chat, side panel
- mac: opening Rein opens the chat workspace
- packaging: build outputs move under .noindex so dev copies stay out of Launchpad
- mac+desktop: one DMG ships toolbar, bridge, and chat
- desktop: the chat/workspace client lands as an Electron app
- desktop: drop the Tauri controller — the Swift toolbar stays
- desktop: begin the Tauri migration — cross-platform tray controller
- site+mac: DMG download surface for the Mac-app bridge install
- mac: park the chat client on mac-chat; the toolbar app ships controller-only
- mac: restore chat access as a quiet footer action
- mac: rebuild the chat window Codex-style on the full bridge surface
- mac: drop the Open Rein Chat row from the popover
- mac: carry the instrument register through the whole popover
- mac: redesign the popover header as an instrument row
- mac: signal pairing demand so the QR actually arms
- mac: restore the original app from the branched session's event log
- mac: keep the bridge socket alive and connect at launch
- mac: rebuild the menu bar app as a native bridge client

## [0.1.34] - 2026-07-14

### Changes

- Key the ACP catalog cache on CLI/shim versions so upgrades re-probe
- ci: mac-snapshot ferries PNGs through the log (artifact quota)
- ci: manual mac-snapshot workflow renders the popover on macos-14

## [0.1.33] - 2026-07-13

### Changes

- Ferry release binaries via a draft release, not Actions artifacts (#54)
- Handoff copy: already on your phone, not live (#53)
- Route www.rein.build/* to the site Worker explicitly (#52)
- Cap release artifact retention at 1 day (#51)
- Paywall scrolls in short viewports; sheet keyboard lift reads live window height
- feat: site handoff (#50)
- Freeze stale liveness claims when a bridge is unreachable
- Opaque ground under full-bleed banners
- Give the response action row more air above the prose
- Bust the demo image's bridge-install layer on every rebuild

## [0.1.32] - 2026-07-12

### Changes

- Shield retry-turn tests from process-wide connection-store mocks
- Stop the DO duration blowout: legacy-TTL compat, cheap rooms, relay escape

## [0.1.31] - 2026-07-12

### Changes

- Demand-gate pairing codes and the membership probe; 60s code TTL
- Drop the QR whole on short terminals so the pairing code always wins
- Fix biome format drift in terminals tab
- Hold sessions skeleton through resume reconnect grace
- Hide unavailable providers in the machine provider sheet
- Fix stranded file picker on bridge reconnect (#46)
- Fix clipped provider chips on import sheet (#47)

## [0.1.30] - 2026-07-10

### Changes

- Free plan: 10 open sessions, 3 running in parallel (#48)
- Update site positioning copy
- Update site social share image

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
