import Cocoa

final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let overlay: OverlayController
    private let onShowPreferences: () -> Void

    private let showGridItem = NSMenuItem()
    private var shortcutItems: [ShortcutAction: NSMenuItem] = [:]
    private let launchItem = NSMenuItem()

    init(overlay: OverlayController, onShowPreferences: @escaping () -> Void) {
        self.overlay = overlay
        self.onShowPreferences = onShowPreferences
        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.grid.3x3.fill", accessibilityDescription: "Divide")
        }

        let menu = NSMenu()
        menu.delegate = self

        showGridItem.target = self
        showGridItem.action = #selector(showGrid)
        menu.addItem(showGridItem)

        menu.addItem(.separator())

        let shortcutsHeader = NSMenuItem(title: "Keyboard Shortcuts", action: nil, keyEquivalent: "")
        shortcutsHeader.isEnabled = false
        menu.addItem(shortcutsHeader)

        for action in ShortcutAction.allCases where action != .showGrid {
            let item = NSMenuItem(title: action.title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
            shortcutItems[action] = item
        }

        menu.addItem(.separator())

        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(showPreferences), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        launchItem.title = "Launch at Login"
        launchItem.target = self
        launchItem.action = #selector(toggleLaunchAtLogin)
        launchItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchItem)

        let permItem = NSMenuItem(title: "Open Accessibility Settings…", action: #selector(openAccessibilitySettings), keyEquivalent: "")
        permItem.target = self
        menu.addItem(permItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Divide", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        refreshDynamicTitles()
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshDynamicTitles()
        launchItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    private func refreshDynamicTitles() {
        let gridCombo = ShortcutStore.combo(for: .showGrid)
        showGridItem.title = "Show Grid" + (gridCombo.map { " (\($0.displayString))" } ?? "")

        for (action, item) in shortcutItems {
            let combo = ShortcutStore.combo(for: action)
            item.title = "\(action.title) — \(combo?.displayString ?? "—")"
        }
    }

    @objc private func showGrid() {
        overlay.toggle()
    }

    @objc private func showPreferences() {
        onShowPreferences()
    }

    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.isEnabled.toggle()
        launchItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    @objc private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
