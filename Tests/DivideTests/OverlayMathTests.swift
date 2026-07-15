import XCTest
@testable import Divide

final class OverlayMathTests: XCTestCase {
    func testFullHudSelectionMapsToFullScreen() {
        let hudSize = CGSize(width: 300, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1000)
        let selection = CGRect(origin: .zero, size: hudSize)

        let result = OverlayMath.scaledRect(selection: selection, hudSize: hudSize, screenFrame: screenFrame)
        XCTAssertEqual(result, screenFrame)
    }

    func testQuarterSelectionMapsToQuarterOfScreen() {
        let hudSize = CGSize(width: 300, height: 200)
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1000)
        // Top-right quarter of the HUD.
        let selection = CGRect(x: 150, y: 100, width: 150, height: 100)

        let result = OverlayMath.scaledRect(selection: selection, hudSize: hudSize, screenFrame: screenFrame)
        XCTAssertEqual(result, CGRect(x: 1000, y: 500, width: 1000, height: 500))
    }

    func testRespectsNonZeroScreenOrigin() {
        // A secondary monitor to the right of the main display.
        let hudSize = CGSize(width: 300, height: 200)
        let screenFrame = CGRect(x: 1920, y: 0, width: 1600, height: 1000)
        let selection = CGRect(x: 0, y: 0, width: 150, height: 200) // left half of the HUD

        let result = OverlayMath.scaledRect(selection: selection, hudSize: hudSize, screenFrame: screenFrame)
        XCTAssertEqual(result, CGRect(x: 1920, y: 0, width: 800, height: 1000))
    }

    func testDegenerateHudSizeDoesNotCrashAndReturnsScreenFrame() {
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1000)
        let result = OverlayMath.scaledRect(selection: .zero, hudSize: .zero, screenFrame: screenFrame)
        XCTAssertEqual(result, screenFrame)
    }
}
