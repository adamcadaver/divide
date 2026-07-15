# Divide

A native, Apple Silicon (arm64) window manager for macOS, inspired by [Divvy](https://mizage.com/divvy/).
Menu-bar only app (no Dock icon) with a click-and-drag grid for snapping windows, plus quick
keyboard shortcuts for the common layouts.

## Build

Requires Xcode Command Line Tools (Swift 5.9+).

```bash
./Scripts/build_app.sh
```

This produces `dist/Divide.app`, already ad-hoc code-signed (required for any executable to run
on Apple Silicon, even outside the App Store).

## Install

```bash
cp -R dist/Divide.app /Applications/
open /Applications/Divide.app
```

On first launch, macOS will ask you to grant **Accessibility** access — this is required so Divide
can move and resize the windows of other apps. Approve it in:

`System Settings → Privacy & Security → Accessibility → enable Divide`

(You can also jump there from Divide's menu-bar icon → "Open Accessibility Settings…".)

If you don't see the permission prompt, quit and relaunch Divide after granting access.

## Usage

Divide lives in the menu bar (a grid icon). Click it for the menu, or use these shortcuts anywhere:

| Shortcut | Action |
|---|---|
| `⌃⌥D` (Control+Option+D) | Show the Divvy-style grid overlay on the screen under your cursor |
| `⌃⌥←` / `⌃⌥→` | Snap frontmost window to left / right half |
| `⌃⌥↑` / `⌃⌥↓` | Snap to top / bottom half |
| `⌃⌥U` / `⌃⌥I` | Snap to top-left / top-right quarter |
| `⌃⌥J` / `⌃⌥K` | Snap to bottom-left / bottom-right quarter |
| `⌃⌥Return` | Maximize |
| `⌃⌥C` | Center (2/3 screen size) |

### Grid overlay

Press `⌃⌥D` to bring up a translucent grid over the screen your mouse is on. Click and drag across
cells to select a region (it snaps to grid lines); release to move/resize the window that was
frontmost when you pressed the shortcut into that region. A single click (no drag) snaps it to
that one cell. Press `Esc` to cancel without changing anything.

## Launch at login

Toggle "Launch at Login" from the menu-bar menu.

## How it works

- Window moving/resizing uses the macOS **Accessibility API** (`AXUIElement`) — the same mechanism
  Divvy, Rectangle, and Moom use. It requires the Accessibility permission grant above.
- Global keyboard shortcuts use the Carbon Event Manager's `RegisterEventHotKey`, which is still
  the standard, fully-supported way to register system-wide hotkeys on modern macOS (Carbon events,
  unlike the old Carbon UI toolkit, are not deprecated for this purpose) and works natively on
  Apple Silicon.
- The app is a plain Swift Package executable (not a full Xcode project) wrapped into a minimal
  `.app` bundle by `Scripts/build_app.sh`, then ad-hoc signed — required for any arm64 binary to
  execute on Apple Silicon.

## Known limitations (v1)

- Shortcuts are currently fixed, not user-remappable via a preferences UI.
- Grid density is fixed at 6×6 (edit `GridView.columns`/`rows` to change, then rebuild).
- No custom app icon yet (uses the default).
