import Cocoa

/// A borderless overlay window that can become key (needed so it receives
/// mouse drags and the Escape key), unlike a normal borderless NSWindow.
final class OverlayPanel: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Presents a small, floating click-and-drag grid (~15% of the screen's size,
/// centered) over the screen under the mouse cursor. The rect the user drags
/// out inside that small grid is scaled up proportionally to the full screen
/// and applied to whatever window was frontmost when the overlay was summoned.
final class OverlayController {
    /// Size of the grid HUD as a fraction of the screen's visible frame.
    private static let hudScale: CGFloat = 0.15

    /// Everything OverlayController needs from the outside world, injected so
    /// the resize + refocus sequencing can be unit tested without a live
    /// NSWindow, real AXUIElements, or Accessibility permission.
    struct Dependencies {
        var isTrusted: (Bool) -> Bool = WindowManager.isTrusted
        var captureFocusedWindow: () -> WindowManager.FocusedWindow? = WindowManager.frontmostFocusedWindow
        var currentScreenFrame: () -> CGRect? = OverlayController.defaultScreenFrame
        var setFrame: (AXUIElement, CGRect) -> Void = WindowManager.setFrame
        var refocus: (AXUIElement, NSRunningApplication) -> Void = WindowManager.refocus
    }

    private let dependencies: Dependencies
    private var window: NSWindow?
    private var capturedWindow: WindowManager.FocusedWindow?
    private var resignObserver: NSObjectProtocol?

    var isVisible: Bool { window != nil }

    init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    func toggle() {
        if window != nil {
            dismiss()
        } else {
            present()
        }
    }

    private func present() {
        guard dependencies.isTrusted(true) else { return }

        // Capture the currently-focused window *before* we steal focus with the overlay.
        capturedWindow = dependencies.captureFocusedWindow()

        guard let screenFrame = dependencies.currentScreenFrame() else { return }

        let hudSize = NSSize(width: screenFrame.width * Self.hudScale, height: screenFrame.height * Self.hudScale)
        let hudOrigin = NSPoint(x: screenFrame.midX - hudSize.width / 2, y: screenFrame.midY - hudSize.height / 2)
        let hudFrame = NSRect(origin: hudOrigin, size: hudSize)

        let panel = OverlayPanel(contentRect: hudFrame, styleMask: [.borderless], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.ignoresMouseEvents = false
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let gridView = GridView(frame: NSRect(origin: .zero, size: hudSize))
        gridView.wantsLayer = true
        gridView.layer?.cornerRadius = 12
        gridView.layer?.masksToBounds = true
        gridView.onComplete = { [weak self] rectInView in
            self?.apply(selection: rectInView, hudSize: hudSize, screenFrame: screenFrame)
        }
        gridView.onCancel = { [weak self] in
            self?.dismiss()
        }
        panel.contentView = gridView

        resignObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.dismiss()
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(gridView)
        window = panel
    }

    private func apply(selection: NSRect, hudSize: NSSize, screenFrame: CGRect) {
        defer { dismiss() }
        guard let target = capturedWindow else { return }
        performApply(selection: selection, hudSize: hudSize, screenFrame: screenFrame, target: target)
    }

    /// Resizes `target` and then re-activates/raises it, so it remains the
    /// selected window for a follow-up shortcut. Exposed (not private) so the
    /// resize -> refocus sequence can be exercised directly in unit tests.
    func performApply(selection: CGRect, hudSize: CGSize, screenFrame: CGRect, target: WindowManager.FocusedWindow) {
        let rect = OverlayMath.scaledRect(selection: selection, hudSize: hudSize, screenFrame: screenFrame)
        dependencies.setFrame(target.axElement, rect)
        dependencies.refocus(target.axElement, target.app)
    }

    private func dismiss() {
        if let resignObserver = resignObserver {
            NotificationCenter.default.removeObserver(resignObserver)
            self.resignObserver = nil
        }
        window?.orderOut(nil)
        window = nil
        capturedWindow = nil
    }

    static func screenUnderMouse() -> NSScreen? {
        let screens = NSScreen.screens
        guard let index = ScreenSelection.indexOfFrame(containing: NSEvent.mouseLocation, in: screens.map(\.frame)) else {
            return nil
        }
        return screens[index]
    }

    static func defaultScreenFrame() -> CGRect? {
        (screenUnderMouse() ?? NSScreen.main)?.visibleFrame
    }
}
