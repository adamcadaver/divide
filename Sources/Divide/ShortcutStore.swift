import Foundation

/// Persists user-customized shortcut bindings in UserDefaults, layered over
/// each ShortcutAction's built-in default. A stored entry with `disabled == true`
/// means the user explicitly cleared that shortcut.
///
/// Every function takes a `defaults` parameter (defaulting to `.standard`) so
/// tests can pass an isolated UserDefaults suite instead of touching the
/// user's real preferences.
enum ShortcutStore {
    static let didChangeNotification = Notification.Name("DivideShortcutsChanged")

    private struct StoredCombo: Codable {
        var keyCode: UInt32
        var modifiers: UInt32
        var disabled: Bool
    }

    private static let defaultsKey = "com.narmitech.divide.shortcuts.v1"

    private static func loadOverrides(_ defaults: UserDefaults) -> [String: StoredCombo] {
        guard let data = defaults.data(forKey: defaultsKey) else { return [:] }
        return (try? JSONDecoder().decode([String: StoredCombo].self, from: data)) ?? [:]
    }

    private static func saveOverrides(_ overrides: [String: StoredCombo], _ defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(overrides) {
            defaults.set(data, forKey: defaultsKey)
        }
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }

    /// The effective combo for an action, or nil if the user disabled it.
    static func combo(for action: ShortcutAction, defaults: UserDefaults = .standard) -> KeyCombo? {
        let overrides = loadOverrides(defaults)
        if let stored = overrides[action.rawValue] {
            return stored.disabled ? nil : KeyCombo(keyCode: stored.keyCode, modifiers: stored.modifiers)
        }
        return action.defaultCombo
    }

    static func setCombo(_ combo: KeyCombo?, for action: ShortcutAction, defaults: UserDefaults = .standard) {
        var overrides = loadOverrides(defaults)
        if let combo = combo {
            overrides[action.rawValue] = StoredCombo(keyCode: combo.keyCode, modifiers: combo.modifiers, disabled: false)
        } else {
            overrides[action.rawValue] = StoredCombo(keyCode: 0, modifiers: 0, disabled: true)
        }
        saveOverrides(overrides, defaults)
    }

    static func resetToDefault(_ action: ShortcutAction, defaults: UserDefaults = .standard) {
        var overrides = loadOverrides(defaults)
        overrides.removeValue(forKey: action.rawValue)
        saveOverrides(overrides, defaults)
    }

    static func resetAll(defaults: UserDefaults = .standard) {
        saveOverrides([:], defaults)
    }
}
