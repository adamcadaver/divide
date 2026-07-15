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

    func testThirds() {
        let thirdWidth = vf.width / 3
        XCTAssertEqual(Layout.frame(for: .leftThird, visibleFrame: vf),
                       CGRect(x: vf.minX, y: vf.minY, width: thirdWidth, height: vf.height))
        XCTAssertEqual(Layout.frame(for: .middleThird, visibleFrame: vf),
                       CGRect(x: vf.minX + thirdWidth, y: vf.minY, width: thirdWidth, height: vf.height))
        XCTAssertEqual(Layout.frame(for: .rightThird, visibleFrame: vf),
                       CGRect(x: vf.minX + vf.width * 2 / 3, y: vf.minY, width: thirdWidth, height: vf.height))
    }

    func testThirdsAreOrderedLeftToRightAndTileTheScreen() {
        let left = Layout.frame(for: .leftThird, visibleFrame: vf)
        let middle = Layout.frame(for: .middleThird, visibleFrame: vf)
        let right = Layout.frame(for: .rightThird, visibleFrame: vf)

        XCTAssertLessThan(left.minX, middle.minX)
        XCTAssertLessThan(middle.minX, right.minX)
        XCTAssertEqual(left.width, middle.width, accuracy: 0.001)
        XCTAssertEqual(middle.width, right.width, accuracy: 0.001)

        let union = left.union(middle).union(right)
        XCTAssertEqual(union.minX, vf.minX, accuracy: 0.001)
        XCTAssertEqual(union.maxX, vf.maxX, accuracy: 0.001)
        XCTAssertEqual(union.height, vf.height, accuracy: 0.001)
    }

    func testTwoThirds() {
        let twoThirdsWidth = vf.width * 2 / 3
        XCTAssertEqual(Layout.frame(for: .leftTwoThirds, visibleFrame: vf),
                       CGRect(x: vf.minX, y: vf.minY, width: twoThirdsWidth, height: vf.height))
        XCTAssertEqual(Layout.frame(for: .rightTwoThirds, visibleFrame: vf),
                       CGRect(x: vf.minX + vf.width / 3, y: vf.minY, width: twoThirdsWidth, height: vf.height))
    }

    func testTwoThirdsShareTheSameThirdBoundaryAsTheThirds() {
        // Left-two-thirds should end exactly where right-third begins, and
        // right-two-thirds should begin exactly where left-third ends.
        let leftTwoThirds = Layout.frame(for: .leftTwoThirds, visibleFrame: vf)
        let rightThird = Layout.frame(for: .rightThird, visibleFrame: vf)
        XCTAssertEqual(leftTwoThirds.maxX, rightThird.minX, accuracy: 0.001)

        let rightTwoThirds = Layout.frame(for: .rightTwoThirds, visibleFrame: vf)
        let leftThird = Layout.frame(for: .leftThird, visibleFrame: vf)
        XCTAssertEqual(rightTwoThirds.minX, leftThird.maxX, accuracy: 0.001)
    }
}
