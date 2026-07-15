import Cocoa
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var preferencesWindowController: PreferencesWindowController?
    private let overlay = OverlayController()
    private let hotKeys = HotKeyManager()
    private var shortcutsObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        _ = WindowManager.isTrusted(promptIfNeeded: true)

        statusBarController = StatusBarController(overlay: overlay, onShowPreferences: { [weak self] in
            self?.showPreferences()
        })

        applyShortcuts()
        shortcutsObserver = NotificationCenter.default.addObserver(
            forName: ShortcutStore.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyShortcuts()
        }
    }

    private func showPreferences() {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    private func snap(_ zone: Zone) {
        guard let target = WindowManager.frontmostFocusedWindow() else { return }
        let screen = OverlayController.screenUnderMouse() ?? NSScreen.main
        guard let screen = screen else { return }
        let rect = Layout.frame(for: zone, visibleFrame: screen.visibleFrame)
        WindowManager.setFrame(target.axElement, cocoaRect: rect)
        WindowManager.refocus(target.axElement, app: target.app)
    }

    private func perform(_ action: ShortcutAction) {
        if action == .showGrid {
            overlay.toggle()
        } else if let zone = action.zone {
            snap(zone)
        }
    }

    private func applyShortcuts() {
        hotKeys.unregisterAll()
        for action in ShortcutAction.allCases {
            guard let combo = ShortcutStore.combo(for: action) else { continue } // user disabled it
            hotKeys.register(keyCode: Int(combo.keyCode), modifiers: combo.modifiers) { [weak self] in
                self?.perform(action)
            }
        }
    }
}
