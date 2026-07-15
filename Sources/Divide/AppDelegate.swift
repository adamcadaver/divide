import Cocoa
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private let overlay = OverlayController()
    private let hotKeys = HotKeyManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        _ = WindowManager.isTrusted(promptIfNeeded: true)
        statusBarController = StatusBarController(overlay: overlay)
        registerHotKeys()
    }

    private func snap(_ zone: Zone) {
        guard let target = WindowManager.frontmostAppFocusedWindow() else { return }
        let screen = OverlayController.screenUnderMouse() ?? NSScreen.main
        guard let screen = screen else { return }
        let rect = Layout.frame(for: zone, visibleFrame: screen.visibleFrame)
        WindowManager.setFrame(target, cocoaRect: rect)
    }

    private func registerHotKeys() {
        let mod = HotKeyModifier.control | HotKeyModifier.option

        hotKeys.register(keyCode: kVK_ANSI_D, modifiers: mod) { [weak self] in
            self?.overlay.toggle()
        }

        hotKeys.register(keyCode: kVK_LeftArrow, modifiers: mod) { [weak self] in self?.snap(.leftHalf) }
        hotKeys.register(keyCode: kVK_RightArrow, modifiers: mod) { [weak self] in self?.snap(.rightHalf) }
        hotKeys.register(keyCode: kVK_UpArrow, modifiers: mod) { [weak self] in self?.snap(.topHalf) }
        hotKeys.register(keyCode: kVK_DownArrow, modifiers: mod) { [weak self] in self?.snap(.bottomHalf) }

        hotKeys.register(keyCode: kVK_Return, modifiers: mod) { [weak self] in self?.snap(.maximize) }
        hotKeys.register(keyCode: kVK_ANSI_C, modifiers: mod) { [weak self] in self?.snap(.center) }

        // Quarters, mimicking arrow-key layout on the keyboard: U I / J K
        hotKeys.register(keyCode: kVK_ANSI_U, modifiers: mod) { [weak self] in self?.snap(.topLeft) }
        hotKeys.register(keyCode: kVK_ANSI_I, modifiers: mod) { [weak self] in self?.snap(.topRight) }
        hotKeys.register(keyCode: kVK_ANSI_J, modifiers: mod) { [weak self] in self?.snap(.bottomLeft) }
        hotKeys.register(keyCode: kVK_ANSI_K, modifiers: mod) { [weak self] in self?.snap(.bottomRight) }
    }
}
