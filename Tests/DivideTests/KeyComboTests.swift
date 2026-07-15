import XCTest
import Carbon.HIToolbox
@testable import Divide

final class KeyComboTests: XCTestCase {
    func testDisplayStringOrdersModifiersControlOptionShiftCommand() {
        let combo = KeyCombo(
            keyCode: UInt32(kVK_ANSI_C),
            modifiers: HotKeyModifier.control | HotKeyModifier.option | HotKeyModifier.shift | HotKeyModifier.command
        )
        XCTAssertEqual(combo.displayString, "\u{2303}\u{2325}\u{21E7}\u{2318}C")
    }

    func testDisplayStringWithSingleModifier() {
        let combo = KeyCombo(keyCode: UInt32(kVK_ANSI_D), modifiers: HotKeyModifier.control | HotKeyModifier.option)
        XCTAssertEqual(combo.displayString, "\u{2303}\u{2325}D")
    }

    func testArrowKeysRenderAsArrows() {
        let combo = KeyCombo(keyCode: UInt32(kVK_LeftArrow), modifiers: HotKeyModifier.option)
        XCTAssertEqual(combo.displayString, "\u{2325}\u{2190}")
    }

    func testUnknownKeyCodeFallsBackToNumericName() {
        XCTAssertEqual(KeyCombo.keyName(for: 9999), "Key9999")
    }

    func testEquatable() {
        let a = KeyCombo(keyCode: 1, modifiers: 2)
        let b = KeyCombo(keyCode: 1, modifiers: 2)
        let c = KeyCombo(keyCode: 1, modifiers: 3)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
}
