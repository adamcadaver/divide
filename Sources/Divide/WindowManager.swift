import Cocoa
import ApplicationServices

/// Wraps the Accessibility (AX) API calls needed to read and move/resize
/// the frontmost window of whatever application currently has focus.
enum WindowManager {

    static func isTrusted(promptIfNeeded: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options: CFDictionary = [key: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// The currently focused window of the frontmost application (excluding Divide itself).
    static func frontmostAppFocusedWindow() -> AXUIElement? {
        guard let runningApp = NSWorkspace.shared.frontmostApplication,
              runningApp.processIdentifier != ProcessInfo.processInfo.processIdentifier else {
            return nil
        }
        let axApp = AXUIElementCreateApplication(runningApp.processIdentifier)

        var focused: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focused) == .success,
           let focused = focused {
            return (focused as! AXUIElement)
        }

        var windowsValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsValue) == .success,
           let windows = windowsValue as? [AXUIElement], let first = windows.first {
            return first
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
}
