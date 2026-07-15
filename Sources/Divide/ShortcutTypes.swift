import Cocoa
import Carbon.HIToolbox

/// A key + Carbon modifier-flag combination, persisted as a global hotkey binding.
struct KeyCombo: Codable, Equatable, Hashable {
    var keyCode: UInt32
    var modifiers: UInt32 // bitmask of HotKeyModifier values

    var displayString: String {
        var s = ""
        if modifiers & HotKeyModifier.control != 0 { s += "\u{2303}" } // ⌃
        if modifiers & HotKeyModifier.option != 0 { s += "\u{2325}" }  // ⌥
        if modifiers & HotKeyModifier.shift != 0 { s += "\u{21E7}" }   // ⇧
        if modifiers & HotKeyModifier.command != 0 { s += "\u{2318}" } // ⌘
        s += KeyCombo.keyName(for: keyCode)
        return s
    }

    static func keyName(for keyCode: UInt32) -> String {
        keyCodeNames[keyCode] ?? "Key\(keyCode)"
    }

    private static let keyCodeNames: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C", UInt32(kVK_ANSI_D): "D",
        UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F", UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H",
        UInt32(kVK_ANSI_I): "I", UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O", UInt32(kVK_ANSI_P): "P",
        UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R", UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T",
        UInt32(kVK_ANSI_U): "U", UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
        UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2", UInt32(kVK_ANSI_3): "3",
        UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5", UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7",
        UInt32(kVK_ANSI_8): "8", UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_LeftArrow): "\u{2190}", UInt32(kVK_RightArrow): "\u{2192}",
        UInt32(kVK_UpArrow): "\u{2191}", UInt32(kVK_DownArrow): "\u{2193}",
        UInt32(kVK_Return): "Return", UInt32(kVK_Tab): "Tab", UInt32(kVK_Space): "Space",
        UInt32(kVK_Delete): "Delete", UInt32(kVK_Escape): "Escape",
        UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3", UInt32(kVK_F4): "F4",
        UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6", UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8",
        UInt32(kVK_F9): "F9", UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12",
    ]
}

/// The set of actions a global shortcut can be bound to. `showGrid` opens the
/// drag-to-snap overlay; the rest snap the frontmost window directly to a `Zone`.
enum ShortcutAction: String, CaseIterable, Codable, Hashable {
    case showGrid
    case leftHalf, rightHalf, topHalf, bottomHalf
    case maximize, center
    case topLeft, topRight, bottomLeft, bottomRight
    case leftThird, middleThird, rightThird
    case leftTwoThirds, rightTwoThirds

    var title: String {
        switch self {
        case .showGrid: return "Show Grid Overlay"
        case .leftHalf: return "Left Half"
        case .rightHalf: return "Right Half"
        case .topHalf: return "Top Half"
        case .bottomHalf: return "Bottom Half"
        case .maximize: return "Maximize"
        case .center: return "Center"
        case .topLeft: return "Top-Left Quarter"
        case .topRight: return "Top-Right Quarter"
        case .bottomLeft: return "Bottom-Left Quarter"
        case .bottomRight: return "Bottom-Right Quarter"
        case .leftThird: return "Left Third"
        case .middleThird: return "Middle Third"
        case .rightThird: return "Right Third"
        case .leftTwoThirds: return "Left Two-Thirds"
        case .rightTwoThirds: return "Right Two-Thirds"
        }
    }

    /// nil for `showGrid`, which isn't a fixed window size.
    var zone: Zone? {
        switch self {
        case .showGrid: return nil
        case .leftHalf: return .leftHalf
        case .rightHalf: return .rightHalf
        case .topHalf: return .topHalf
        case .bottomHalf: return .bottomHalf
        case .maximize: return .maximize
        case .center: return .center
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        case .leftThird: return .leftThird
        case .middleThird: return .middleThird
        case .rightThird: return .rightThird
        case .leftTwoThirds: return .leftTwoThirds
        case .rightTwoThirds: return .rightTwoThirds
        }
    }

    var defaultCombo: KeyCombo {
        let mod = HotKeyModifier.control | HotKeyModifier.option
        switch self {
        case .showGrid: return KeyCombo(keyCode: UInt32(kVK_ANSI_D), modifiers: mod)
        case .leftHalf: return KeyCombo(keyCode: UInt32(kVK_LeftArrow), modifiers: mod)
        case .rightHalf: return KeyCombo(keyCode: UInt32(kVK_RightArrow), modifiers: mod)
        case .topHalf: return KeyCombo(keyCode: UInt32(kVK_UpArrow), modifiers: mod)
        case .bottomHalf: return KeyCombo(keyCode: UInt32(kVK_DownArrow), modifiers: mod)
        case .maximize: return KeyCombo(keyCode: UInt32(kVK_Space), modifiers: mod)
        case .center: return KeyCombo(keyCode: UInt32(kVK_ANSI_C), modifiers: mod)
        case .topLeft: return KeyCombo(keyCode: UInt32(kVK_ANSI_U), modifiers: mod)
        case .topRight: return KeyCombo(keyCode: UInt32(kVK_ANSI_I), modifiers: mod)
        case .bottomLeft: return KeyCombo(keyCode: UInt32(kVK_ANSI_J), modifiers: mod)
        case .bottomRight: return KeyCombo(keyCode: UInt32(kVK_ANSI_K), modifiers: mod)
        case .leftThird: return KeyCombo(keyCode: UInt32(kVK_ANSI_1), modifiers: mod)
        case .middleThird: return KeyCombo(keyCode: UInt32(kVK_ANSI_2), modifiers: mod)
        case .rightThird: return KeyCombo(keyCode: UInt32(kVK_ANSI_3), modifiers: mod)
        case .leftTwoThirds: return KeyCombo(keyCode: UInt32(kVK_ANSI_4), modifiers: mod)
        case .rightTwoThirds: return KeyCombo(keyCode: UInt32(kVK_ANSI_5), modifiers: mod)
        }
    }
}
