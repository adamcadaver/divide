import XCTest
@testable import Divide

final class LayoutTests: XCTestCase {
    // A visible frame with a non-zero origin, as on a secondary monitor to the right of the main one.
    let vf = CGRect(x: 1920, y: 0, width: 1600, height: 1000)

    func testHalves() {
        XCTAssertEqual(Layout.frame(for: .leftHalf, visibleFrame: vf), CGRect(x: 1920, y: 0, width: 800, height: 1000))
        XCTAssertEqual(Layout.frame(for: .rightHalf, visibleFrame: vf), CGRect(x: 2720, y: 0, width: 800, height: 1000))
        XCTAssertEqual(Layout.frame(for: .topHalf, visibleFrame: vf), CGRect(x: 1920, y: 500, width: 1600, height: 500))
        XCTAssertEqual(Layout.frame(for: .bottomHalf, visibleFrame: vf), CGRect(x: 1920, y: 0, width: 1600, height: 500))
    }

    func testMaximizeFillsVisibleFrame() {
        XCTAssertEqual(Layout.frame(for: .maximize, visibleFrame: vf), vf)
    }

    func testCenterIsTwoThirdsAndCentered() {
        let rect = Layout.frame(for: .center, visibleFrame: vf)
        XCTAssertEqual(rect.width, vf.width * 2 / 3, accuracy: 0.001)
        XCTAssertEqual(rect.height, vf.height * 2 / 3, accuracy: 0.001)
        XCTAssertEqual(rect.midX, vf.midX, accuracy: 0.001)
        XCTAssertEqual(rect.midY, vf.midY, accuracy: 0.001)
    }

    func testQuarters() {
        XCTAssertEqual(Layout.frame(for: .topLeft, visibleFrame: vf), CGRect(x: 1920, y: 500, width: 800, height: 500))
        XCTAssertEqual(Layout.frame(for: .topRight, visibleFrame: vf), CGRect(x: 2720, y: 500, width: 800, height: 500))
        XCTAssertEqual(Layout.frame(for: .bottomLeft, visibleFrame: vf), CGRect(x: 1920, y: 0, width: 800, height: 500))
        XCTAssertEqual(Layout.frame(for: .bottomRight, visibleFrame: vf), CGRect(x: 2720, y: 0, width: 800, height: 500))
    }

    func testQuartersTileTheWholeScreenWithNoGaps() {
        let tl = Layout.frame(for: .topLeft, visibleFrame: vf)
        let tr = Layout.frame(for: .topRight, visibleFrame: vf)
        let bl = Layout.frame(for: .bottomLeft, visibleFrame: vf)
        let br = Layout.frame(for: .bottomRight, visibleFrame: vf)
        let union = tl.union(tr).union(bl).union(br)
        XCTAssertEqual(union, vf)
    }
}
