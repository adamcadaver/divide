import XCTest
@testable import Divide

final class ShortcutDefaultsTests: XCTestCase {
    /// Guards against accidentally shipping two actions with the same default
    /// shortcut (e.g. when adding a new action later).
    func testNoTwoActionsShareTheSameDefaultCombo() {
        var seen: [KeyCombo: ShortcutAction] = [:]
        for action in ShortcutAction.allCases {
            let combo = action.defaultCombo
            if let existing = seen[combo] {
                XCTFail("\(action) and \(existing) both default to \(combo.displayString)")
            }
            seen[combo] = action
        }
    }

    func testThirdsDefaultToNumberKeysOneTwoThreeLeftToRight() {
        XCTAssertEqual(ShortcutAction.leftThird.defaultCombo.displayString, "\u{2303}\u{2325}1")
        XCTAssertEqual(ShortcutAction.middleThird.defaultCombo.displayString, "\u{2303}\u{2325}2")
        XCTAssertEqual(ShortcutAction.rightThird.defaultCombo.displayString, "\u{2303}\u{2325}3")
    }

    func testThirdsMapToTheCorrespondingZonesLeftToRight() {
        XCTAssertEqual(ShortcutAction.leftThird.zone, .leftThird)
        XCTAssertEqual(ShortcutAction.middleThird.zone, .middleThird)
        XCTAssertEqual(ShortcutAction.rightThird.zone, .rightThird)
    }
}
