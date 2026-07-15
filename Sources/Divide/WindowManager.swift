import Cocoa
import ApplicationServices

/// Wraps the Accessibility (AX) API calls needed to read and move/resize
/// the frontmost window of whatever application currently has focus.
enum WindowManager {

    /// A window we've captured to operate on, together with the app that owns
    /// it — needed so we can re-activate that specific app (and raise this
    /// specific window) after moving/resizing it, so it stays selected for
    /// any follow-up shortcut.
    struct FocusedWindow {
        let axElement: AXUIElement
        let app: NSRunningApplication
    }

    static func isTrusted(promptIfNeeded: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: CFDictionary = [key: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// The currently focused window of the frontmost application (excluding Divide itself).
    static func frontmostFocusedWindow() -> FocusedWindow? {
        guard let runningApp = NSWorkspace.shared.frontmostApplication,
              runningApp.processIdentifier != ProcessInfo.processInfo.processIdentifier else {
            return nil
        }
        let axApp = AXUIElementCreateApplication(runningApp.processIdentifier)

        var focused: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focused) == .success,
           let focused = focused {
            return FocusedWindow(axElement: (focused as! AXUIElement), app: runningApp)
        }

        var windowsValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsValue) == .success,
           let windows = windowsValue as? [AXUIElement], let first = windows.first {
            return FocusedWindow(axElement: first, app: runningApp)
        }
        return nil
    }

    /// Moves/resizes a window to the given rect, expressed in Cocoa screen
    /// coordinates (origin bottom-left, matching NSScreen.frame).
    static func setFrame(_ window: AXUIElement, cocoaRect rect: CGRect) {
        guard let primaryScreenHeight = NSScreen.screens.first?.frame.height else { return }

        // AX expects top-left-origin ("flipped") global coordinates.
        var position = CGPoint(x: rect.origin.x, y: primaryScreenHeight - rect.origin.y - rect.height)
        var size = CGSize(width: rect.width, height: rect.height)

        guard let positionValue = AXValueCreate(.cgPoint, &position),
              let sizeValue = AXValueCreate(.cgSize, &size) else { return }

        // Some apps clamp size/position depending on order and constraints,
        // so set position, then size, then re-assert position.
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
    }

    /// Re-activates `app` and raises/focuses `window`, so it remains the
    /// selected window for any shortcut the user presses next. Without this,
    /// moving a window via the Accessibility API doesn't change which app/window
    /// the system considers frontmost, so a subsequent snap could apply to the
    /// wrong window (or none, if focus reverted to Divide itself).
    static func refocus(_ window: AXUIElement, app: NSRunningApplication) {
        if #available(macOS 14.0, *) {
            app.activate()
        } else {
            app.activate(options: [.activateIgnoringOtherApps])
        }
        AXUIElementPerformAction(window, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(window, kAXFocusedAttribute as CFString, kCFBooleanTrue)
    }
}
