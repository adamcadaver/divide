import XCTest
@testable import Divide

final class ShortcutStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "com.narmitech.divide.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testComboReturnsBuiltInDefaultWhenNotCustomized() {
        XCTAssertEqual(ShortcutStore.combo(for: .showGrid, defaults: defaults), ShortcutAction.showGrid.defaultCombo)
    }

    func testSetComboOverridesDefault() {
        let custom = KeyCombo(keyCode: 99, modifiers: HotKeyModifier.command)
        ShortcutStore.setCombo(custom, for: .leftHalf, defaults: defaults)
        XCTAssertEqual(ShortcutStore.combo(for: .leftHalf, defaults: defaults), custom)
        // Unrelated actions are unaffected.
        XCTAssertEqual(ShortcutStore.combo(for: .rightHalf, defaults: defaults), ShortcutAction.rightHalf.defaultCombo)
    }

    func testSetComboNilDisablesShortcut() {
        ShortcutStore.setCombo(nil, for: .maximize, defaults: defaults)
        XCTAssertNil(ShortcutStore.combo(for: .maximize, defaults: defaults))
    }

    func testResetToDefaultRevertsOnlyThatAction() {
        ShortcutStore.setCombo(KeyCombo(keyCode: 1, modifiers: 1), for: .center, defaults: defaults)
        ShortcutStore.setCombo(KeyCombo(keyCode: 2, modifiers: 2), for: .topLeft, defaults: defaults)

        ShortcutStore.resetToDefault(.center, defaults: defaults)

        XCTAssertEqual(ShortcutStore.combo(for: .center, defaults: defaults), ShortcutAction.center.defaultCombo)
        XCTAssertEqual(ShortcutStore.combo(for: .topLeft, defaults: defaults), KeyCombo(keyCode: 2, modifiers: 2))
    }

    func testResetAllRevertsEveryAction() {
        for action in ShortcutAction.allCases {
            ShortcutStore.setCombo(KeyCombo(keyCode: 42, modifiers: 42), for: action, defaults: defaults)
        }
        ShortcutStore.resetAll(defaults: defaults)
        for action in ShortcutAction.allCases {
            XCTAssertEqual(ShortcutStore.combo(for: action, defaults: defaults), action.defaultCombo)
        }
    }
}
