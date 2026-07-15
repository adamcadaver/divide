import XCTest
@testable import Divide

final class ScreenSelectionTests: XCTestCase {
    func testPicksTheScreenContainingThePoint() {
        // Two monitors side by side, as in NSScreen.screens' Cocoa coordinate space.
        let main = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let secondary = CGRect(x: 1920, y: 0, width: 1600, height: 1000)
        let frames = [main, secondary]

        XCTAssertEqual(ScreenSelection.indexOfFrame(containing: CGPoint(x: 500, y: 500), in: frames), 0)
        XCTAssertEqual(ScreenSelection.indexOfFrame(containing: CGPoint(x: 2500, y: 500), in: frames), 1)
    }

    func testPicksCorrectlyWhenSecondaryScreenHasANegativeOrigin() {
        // A built-in laptop display sitting below-left of the main external display —
        // a very common real arrangement, and one where the secondary screen's frame
        // has negative x/y in Cocoa's global coordinate space.
        let main = CGRect(x: 0, y: 0, width: 3440, height: 1440)
        let builtIn = CGRect(x: -200, y: -1440, width: 2560, height: 1440)
        let frames = [main, builtIn]

        XCTAssertEqual(ScreenSelection.indexOfFrame(containing: CGPoint(x: 1000, y: 700), in: frames), 0)
        XCTAssertEqual(ScreenSelection.indexOfFrame(containing: CGPoint(x: -100, y: -700), in: frames), 1)
    }

    func testReturnsNilWhenPointIsOutsideEveryScreen() {
        let frames = [CGRect(x: 0, y: 0, width: 1920, height: 1080)]
        XCTAssertNil(ScreenSelection.indexOfFrame(containing: CGPoint(x: 5000, y: 5000), in: frames))
    }

    func testSharedBoundaryBelongsToExactlyOneScreen() {
        // Two adjacent screens sharing the vertical line x = 1920. A point exactly
        // on that boundary must resolve to one screen only, never both or neither.
        let left = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let right = CGRect(x: 1920, y: 0, width: 1920, height: 1080)
        let frames = [left, right]

        let boundaryPoint = CGPoint(x: 1920, y: 500)
        let matches = frames.indices.filter { NSMouseInRect(boundaryPoint, frames[$0], false) }
        XCTAssertEqual(matches.count, 1, "boundary point should belong to exactly one screen")
    }

    func testEmptyScreenListReturnsNil() {
        XCTAssertNil(ScreenSelection.indexOfFrame(containing: CGPoint(x: 0, y: 0), in: []))
    }
}
