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

Press `⌃⌥D` to bring up a small, floating grid HUD (about 15% of your screen's width/height,
centered on the screen your mouse is on) — the classic Divvy look, rather than a full-screen
overlay. Click and drag across the small grid to select a region (it snaps to grid lines); the
selection scales up proportionally to your full screen and is applied to the window that was
frontmost when you pressed the shortcut. A single click (no drag) snaps it to that one cell.
Press `Esc`, or click anywhere outside the HUD, to cancel without changing anything.

After the resize, Divide re-activates and raises that same window, so it stays selected — you can
immediately press `⌃⌥D` again (or any other shortcut) to keep refining the same window's size/position
without having to re-click it first.

## Customizing shortcuts

Open **Preferences…** from the menu-bar menu (or `⌘,` while the menu is open) to rebind any
shortcut — the grid-overlay trigger and each fixed-size snap (halves, quarters, maximize, center).

- Click a shortcut field, then press the new key combination. It must include at least one of
  `⌃` (Control), `⌥` (Option), or `⌘` (Command).
- Press **Delete** while recording to clear that shortcut (disables it).
- Press **Escape** while recording to cancel without changing it.
- **Reset** restores one shortcut to its default; **Restore All Defaults** resets everything.
- If you assign a combination that's already in use, Divide asks whether to reassign it — doing so
  clears it from the other action so there's never a conflicting duplicate.

Changes take effect immediately (no restart needed) and persist across launches. The menu-bar
menu's "Keyboard Shortcuts" section always reflects your current bindings.

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

## Testing

The window-frame math, grid-selection math, shortcut persistence, and the resize→refocus behavior
described above are covered by unit tests (no live window/Accessibility permission required to run
them):

```bash
swift test
```

Notably `Tests/DivideTests/OverlayControllerFocusTests.swift` pins down the "window stays selected
after a HUD resize" behavior: it drives `OverlayController` with fake dependencies and asserts that
resizing a window is always followed by a re-activate/raise call on that same window. If that
behavior ever regresses, this test fails.

## Known limitations (v1)

- Grid density is fixed at 6×6 (edit `GridView.columns`/`rows` to change, then rebuild).
- No custom app icon yet (uses the default).
- Shortcut key names in Preferences assume a US keyboard layout.
