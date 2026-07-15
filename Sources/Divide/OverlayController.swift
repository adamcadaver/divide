import Cocoa

/// A borderless overlay window that can become key (needed so it receives
/// mouse drags and the Escape key), unlike a normal borderless NSWindow.
final class OverlayPanel: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Presents the click-and-drag grid over the screen under the mouse cursor
/// and applies the resulting rect to whatever window was frontmost when
/// the overlay was summoned.
final class OverlayController {
    private var window: NSWindow?
    private var targetWindow: AXUIElement?
    private var previousActivationPolicy: NSApplication.ActivationPolicy = .accessory

    var isVisible: Bool { window != nil }

    func toggle() {
        if window != nil {
            dismiss()
        } else {
            present()
        }
    }

    private func present() {
        guard WindowManager.isTrusted(promptIfNeeded: true) else { return }

        // Capture the currently-focused window *before* we steal focus with the overlay.
        targetWindow = WindowManager.frontmostAppFocusedWindow()

        guard let screen = Self.screenUnderMouse() ?? NSScreen.main else { return }
        let frame = screen.visibleFrame

        let panel = OverlayPanel(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        panel.ignoresMouseEvents = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let gridView = GridView(frame: NSRect(origin: .zero, size: frame.size))
        gridView.onComplete = { [weak self] rectInView in
            self?.apply(rectInView: rectInView, screenFrame: frame)
        }
        gridView.onCancel = { [weak self] in
            self?.dismiss()
        }
        panel.contentView = gridView

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(gridView)
        window = panel
    }

    private func apply(rectInView: NSRect, screenFrame: CGRect) {
        defer { dismiss() }
        guard let target = targetWindow else { return }
        let cocoaRect = CGRect(x: screenFrame.minX + rectInView.minX,
                                y: screenFrame.minY + rectInView.minY,
                                width: rectInView.width,
                                height: rectInView.height)
        WindowManager.setFrame(target, cocoaRect: cocoaRect)
    }

    private func dismiss() {
        window?.orderOut(nil)
        window = nil
        targetWindow = nil
    }

    static func screenUnderMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }
}
