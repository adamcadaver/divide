import CoreGraphics

/// Pure geometry used by the grid HUD: mapping a selection drawn inside the
/// small HUD grid to the corresponding rect on the real screen.
enum OverlayMath {
    /// `selection` is in the HUD's local coordinates (origin bottom-left, same
    /// space as `hudSize`). Returns the proportionally-scaled rect within
    /// `screenFrame` (Cocoa screen coordinates).
    static func scaledRect(selection: CGRect, hudSize: CGSize, screenFrame: CGRect) -> CGRect {
        guard hudSize.width > 0, hudSize.height > 0 else { return screenFrame }

        let fx = selection.minX / hudSize.width
        let fy = selection.minY / hudSize.height
        let fw = selection.width / hudSize.width
        let fh = selection.height / hudSize.height

        return CGRect(x: screenFrame.minX + fx * screenFrame.width,
                       y: screenFrame.minY + fy * screenFrame.height,
                       width: fw * screenFrame.width,
                       height: fh * screenFrame.height)
    }
}
