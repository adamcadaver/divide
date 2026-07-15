import XCTest
import Cocoa
import ApplicationServices
@testable import Divide

/// Regression test for: after dragging a selection in the grid HUD, the window
/// that was resized must be re-activated/raised so it stays the selected
/// window for a follow-up shortcut (previously it lost focus, and a second
/// ⌃⌥D press wouldn't know which window to act on).
final class OverlayControllerFocusTests: XCTestCase {
    private enum Call: Equatable {
        case setFrame(CGRect)
        case refocus(pid_t)
    }

    private final class Recorder {
        var calls: [Call] = []
    }

    func testResizingRefocusesTheSameWindowThatWasCaptured() {
        let recorder = Recorder()
        // A real (harmless) AXUIElement/NSRunningApplication pair standing in for
        // "some other app's window" — we never actually read/write AX attributes
        // on it since setFrame/refocus are stubbed below, so no Accessibility
        // permission is required to run this test.
        let axElement = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        let app = NSRunningApplication.current
        let target = WindowManager.FocusedWindow(axElement: axElement, app: app)

        var deps = OverlayController.Dependencies()
        deps.setFrame = { _, rect in recorder.calls.append(.setFrame(rect)) }
        deps.refocus = { _, refocusedApp in recorder.calls.append(.refocus(refocusedApp.processIdentifier)) }

        let controller = OverlayController(dependencies: deps)
        controller.performApply(
            selection: CGRect(x: 0, y: 0, width: 100, height: 100),
            hudSize: CGSize(width: 200, height: 200),
            screenFrame: CGRect(x: 0, y: 0, width: 2000, height: 1000),
            target: target
        )

        XCTAssertEqual(recorder.calls, [
            .setFrame(CGRect(x: 0, y: 0, width: 1000, height: 500)),
            .refocus(app.processIdentifier)
        ])
    }

    func testRefocusIsCalledEvenWhenSelectionIsASingleCell() {
        // Guards against a regression that only refocuses on drags, not single clicks.
        let recorder = Recorder()
        let axElement = AXUIElementCreateApplication(ProcessInfo.processInfo.processIdentifier)
        let app = NSRunningApplication.current
        let target = WindowManager.FocusedWindow(axElement: axElement, app: app)

        var deps = OverlayController.Dependencies()
        deps.setFrame = { _, rect in recorder.calls.append(.setFrame(rect)) }
        deps.refocus = { _, refocusedApp in recorder.calls.append(.refocus(refocusedApp.processIdentifier)) }

        let controller = OverlayController(dependencies: deps)
        controller.performApply(
            selection: CGRect(x: 0, y: 0, width: 33, height: 33),
            hudSize: CGSize(width: 200, height: 200),
            screenFrame: CGRect(x: 0, y: 0, width: 2000, height: 1000),
            target: target
        )

        XCTAssertEqual(recorder.calls.count, 2, "expected both a resize and a refocus call")
        guard case .refocus = recorder.calls.last else {
            return XCTFail("expected the last call to be refocus, got \(String(describing: recorder.calls.last))")
        }
    }
}
