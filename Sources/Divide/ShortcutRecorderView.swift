import Cocoa

/// A click-to-record control for capturing a global keyboard shortcut, similar to
/// the shortcut recorder used in System Settings. Click it, then press a key
/// combination (must include ⌃, ⌥, or ⌘). Press Delete while recording to clear
/// the shortcut, or Escape to cancel without changing it.
final class ShortcutRecorderView: NSView {
    var combo: KeyCombo? {
        didSet { needsDisplay = true }
    }
    var onChange: ((KeyCombo?) -> Void)?

    private var isRecording = false {
        didSet { needsDisplay = true }
    }

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        isRecording = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        isRecording = false
        return true
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        if event.keyCode == 53 { // Escape cancels, leaves combo untouched
            window?.makeFirstResponder(nil)
            return
        }
        if event.keyCode == 51 || event.keyCode == 117 { // Delete / Forward Delete clears
            combo = nil
            onChange?(nil)
            window?.makeFirstResponder(nil)
            return
        }

        let flags = event.modifierFlags.intersection([.command, .control, .option, .shift])
        guard flags.contains(.command) || flags.contains(.control) || flags.contains(.option) else {
            NSSound.beep()
            return
        }

        var carbonModifiers: UInt32 = 0
        if flags.contains(.control) { carbonModifiers |= HotKeyModifier.control }
        if flags.contains(.option) { carbonModifiers |= HotKeyModifier.option }
        if flags.contains(.command) { carbonModifiers |= HotKeyModifier.command }
        if flags.contains(.shift) { carbonModifiers |= HotKeyModifier.shift }

        let newCombo = KeyCombo(keyCode: UInt32(event.keyCode), modifiers: carbonModifiers)
        combo = newCombo
        onChange?(newCombo)
        window?.makeFirstResponder(nil)
    }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 5, yRadius: 5)
        (isRecording ? NSColor.controlAccentColor.withAlphaComponent(0.15) : NSColor.controlBackgroundColor).setFill()
        path.fill()
        (isRecording ? NSColor.controlAccentColor : NSColor.separatorColor).setStroke()
        path.lineWidth = 1
        path.stroke()

        let text = isRecording ? "Type shortcut…" : (combo?.displayString ?? "Click to record")
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: isRecording ? NSColor.secondaryLabelColor : NSColor.labelColor
        ]
        let size = text.size(withAttributes: attrs)
        let point = NSPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2)
        text.draw(at: point, withAttributes: attrs)
    }
}
