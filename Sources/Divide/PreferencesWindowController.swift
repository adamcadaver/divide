import Cocoa

/// Lets the user rebind every global shortcut: the grid-overlay trigger and
/// each fixed-size snap (halves, quarters, maximize, center).
final class PreferencesWindowController: NSWindowController {
    private var recorders: [ShortcutAction: ShortcutRecorderView] = [:]
    private var resetButtonActions: [ObjectIdentifier: ShortcutAction] = [:]

    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
                               styleMask: [.titled, .closable],
                               backing: .buffered,
                               defer: false)
        window.title = "Divide Preferences"
        window.isReleasedWhenClosed = false
        window.center()
        self.init(window: window)
        buildUI()
    }

    private func buildUI() {
        guard let window = window else { return }

        let container = NSView(frame: window.contentLayoutRect)
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let header = NSTextField(labelWithString: "Global Shortcuts")
        header.font = .boldSystemFont(ofSize: 14)
        stack.addArrangedSubview(header)

        let subheader = NSTextField(labelWithString: "Click a shortcut field, then press a new key combination (must include ⌃, ⌥, or ⌘). Press Delete to clear, Escape to cancel.")
        subheader.font = .systemFont(ofSize: 11)
        subheader.textColor = .secondaryLabelColor
        subheader.preferredMaxLayoutWidth = 420
        subheader.lineBreakMode = .byWordWrapping
        stack.addArrangedSubview(subheader)

        for action in ShortcutAction.allCases {
            let row = makeRow(for: action)
            stack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        let restoreAllButton = NSButton(title: "Restore All Defaults", target: self, action: #selector(resetAll))
        stack.addArrangedSubview(restoreAllButton)

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        container.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = container
    }

    private func makeRow(for action: ShortcutAction) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 10
        row.alignment = .centerY

        let label = NSTextField(labelWithString: action.title)
        label.alignment = .left
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let recorder = ShortcutRecorderView()
        recorder.combo = ShortcutStore.combo(for: action)
        recorder.widthAnchor.constraint(equalToConstant: 140).isActive = true
        recorder.heightAnchor.constraint(equalToConstant: 24).isActive = true
        recorder.onChange = { [weak self] newCombo in
            self?.handleChange(newCombo, for: action)
        }
        recorders[action] = recorder

        let resetButton = NSButton(title: "Reset", target: self, action: #selector(resetTapped(_:)))
        resetButton.bezelStyle = .rounded
        resetButton.controlSize = .small
        resetButtonActions[ObjectIdentifier(resetButton)] = action

        row.addArrangedSubview(label)
        row.addArrangedSubview(recorder)
        row.addArrangedSubview(resetButton)
        return row
    }

    private func handleChange(_ newCombo: KeyCombo?, for action: ShortcutAction) {
        if let newCombo = newCombo,
           let conflict = ShortcutAction.allCases.first(where: { $0 != action && ShortcutStore.combo(for: $0) == newCombo }) {
            let alert = NSAlert()
            alert.messageText = "Shortcut Already In Use"
            alert.informativeText = "\(newCombo.displayString) is currently assigned to “\(conflict.title)”. Reassign it to “\(action.title)”?"
            alert.addButton(withTitle: "Reassign")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()
            guard response == .alertFirstButtonReturn else {
                recorders[action]?.combo = ShortcutStore.combo(for: action)
                return
            }
            ShortcutStore.setCombo(nil, for: conflict)
            recorders[conflict]?.combo = nil
        }
        ShortcutStore.setCombo(newCombo, for: action)
    }

    @objc private func resetTapped(_ sender: NSButton) {
        guard let action = resetButtonActions[ObjectIdentifier(sender)] else { return }
        ShortcutStore.resetToDefault(action)
        recorders[action]?.combo = ShortcutStore.combo(for: action)
    }

    @objc private func resetAll() {
        ShortcutStore.resetAll()
        for action in ShortcutAction.allCases {
            recorders[action]?.combo = ShortcutStore.combo(for: action)
        }
    }
}
