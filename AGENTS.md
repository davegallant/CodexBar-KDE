# Agent rules for CodexBar-KDE

Rules for AI agents (and humans) working on this repo. They encode lessons
learned the hard way; follow them instead of rediscovering the failures.

## Project shape

- Plasma 6 plasmoid, id `org.rpa.codexbar`, lives in `package/`.
- All parsing/formatting/command-building logic lives in the engine-neutral
  [package/contents/code/parser.js](package/contents/code/parser.js): QML
  imports it, Node `require()`s it. New logic goes there, covered by tests in
  `tests/parser.test.mjs` (`node --test` from the repo root; do NOT pass the
  directory as an argument, `node --test tests/` misbehaves).
- TDD: write failing tests first, then implement. Run the full suite before
  every commit.
- The widget shells out to the CodexBar CLI (`codexbar usage|cost --format
  json --no-color`) through the Plasma "executable" dataengine. The CLI's
  `--provider` flag takes a single id only (no comma lists) — one process per
  selected provider.
- Design invariants: radial two-ring gauges stay (outer = session, inner =
  weekly, percent used); cached background refresh must never blank the
  panel; default provider selection is `codex,claude` so a fresh install
  shows checkboxes pre-selected in the settings.

## Testing on this machine

- Visual checks only when the user asks for them — `parser.js` logic is
  covered by `node --test` and QML tweaks are verifiable by inspection.
- If needed: `Xvfb` on display `:77` + `plasmawindowed org.rpa.codexbar`
  (applet arg required). `:99` is OCCUPIED by another agent's session — do
  not touch it. `:0` is the live desktop; Yakuake overlays eat synthetic
  clicks.
- The `bash` tool runs in a sandbox with a private `/tmp` that reaps
  background processes when the call ends — start Xvfb/plasmawindowed in a
  `tmux` window. Stale `/tmp/.X77-lock` may need removing before Xvfb starts.
- Screenshots: `~/.local/bin/uv run --with python-xlib --with pillow python`
  (root window `get_image()` + PIL).
- ALWAYS use `tests/mock-codexbar.sh` as `codexbarPath` for screenshots: it
  serves example.com accounts. The user's real e-mail must never appear in
  published images.

## Release flow

1. Bump `Version` in `package/metadata.json` — CI fails the build if it does
   not match the tag.
2. Commit, `git tag vX.Y.Z`, `git push origin main vX.Y.Z`.
3. CI (`.github/workflows/release.yml`) runs tests, builds the `.plasmoid`,
   and attaches BOTH the versioned artifact and the stable-named
   `org.rpa.codexbar.plasmoid` to the GitHub release. The stable name feeds
   `https://github.com/EvilFreelancer/CodexBar-KDE/releases/latest/download/org.rpa.codexbar.plasmoid`.
   Note: a tag pushed in the same push that ADDS a workflow does not trigger
   it — delete and re-push the tag if runs stay at zero.

## KDE Store deployment (store.kde.org/p/2365355, account EvilFreelancer)

- The product must expose exactly ONE download entry so Discover updates
  automatically without asking the user to pick a file. Preferred (current
  setup since v0.5.0): an "Add URL" entry pointing at the stable
  `releases/latest/download/org.rpa.codexbar.plasmoid` link — verified to
  stay an EXTERNAL link on the product page (the store does not snapshot the
  file), so users always download the newest release. Per release only the
  product version field needs bumping on the Basics tab. The Add URL dialog
  is `#get-url` + `#get-url-submit` after pressing the "Add URL" button on
  the Files tab (T&C checkbox must be accepted first).
- When replacing files: delete old rows via `a[data-deletepploadfile-btn]`
  on the edit form's Files tab ONE AT A TIME with pauses — parallel deletes
  race in the ppload API (`mkdir(): File exists` alerts).
- The edit form does NOT prefill the homepage field — refill
  `https://github.com/EvilFreelancer/CodexBar-KDE` before every Save or it
  gets wiped.
- Store markdown quirks: `<digit>)` and `<capital>:` sequences become
  emoticons (`58)` → smiley, `D:` eaten); `&&` inside inline code renders as
  literal `&amp;&amp;` when copied — use `;` separators in shell one-liners.
- Product description must include the CLI install one-liner: most users
  never open the README.
- Gallery pictures and the product logo are edited on the Basics tab; the
  logo source of truth is `package/contents/icons/codexbar.svg` (render PNG
  with `rsvg-convert`, NOT ImageMagick — IM's SVG renderer drops
  stroke-dasharray arcs).

## Metadata and UI conventions

- `metadata.json` `Icon` must stay a THEME icon name: system plasmoids never
  ship file-path icons and the widget explorer does not resolve
  package-relative paths. The custom icon is used in the store logo, README,
  and the compact fallback (`Qt.resolvedUrl("../icons/codexbar.svg")`).
- Store/README screenshots come from the mock, both dark and light themes
  (light = `XDG_CONFIG_HOME` pointing at a dir whose `kdeglobals` is a copy
  of `/usr/share/color-schemes/BreezeLight.colors`, with a `codexbar`
  symlink to `~/.config/codexbar` if real CLI data is wanted).
- The proxy config (`proxyUrl`) is exported as
  `http_proxy/https_proxy/HTTP_PROXY/HTTPS_PROXY/ALL_PROXY` on every CLI
  call; keep that in `parser.js buildCommands`/`buildCostCommand` so it stays
  unit-tested.
