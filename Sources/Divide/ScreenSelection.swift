import Cocoa

/// Pure "which screen is the mouse on" logic, factored out of OverlayController
/// so multi-monitor arrangements (including screens with negative-origin
/// frames, as when a secondary display sits left of or below the main one)
/// can be unit tested without real hardware.
enum ScreenSelection {
    /// Index of the first frame containing `point`, using the same hit-testing
    /// semantics as Cocoa's `NSMouseInRect` (consistent, single-owner behavior
    /// at shared boundaries between adjacent screens).
    static func indexOfFrame(containing point: CGPoint, in frames: [CGRect]) -> Int? {
        frames.firstIndex { NSMouseInRect(point, $0, false) }
    }
}
