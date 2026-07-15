import Cocoa

/// Draws a Divvy-style grid and lets the user click-and-drag across cells
/// to select a rectangular region. The selection snaps to grid lines.
final class GridView: NSView {
    var columns = 6
    var rows = 6

    /// Called with the selected rect in view-local coordinates (origin bottom-left).
    var onComplete: ((NSRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startCell: (Int, Int)?
    private var currentCell: (Int, Int)?
    private var isDragging = false

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.35).setFill()
        bounds.fill()

        let gridPath = NSBezierPath()
        gridPath.lineWidth = 1
        for i in 1..<columns {
            let x = bounds.width * CGFloat(i) / CGFloat(columns)
            gridPath.move(to: NSPoint(x: x, y: 0))
            gridPath.line(to: NSPoint(x: x, y: bounds.height))
        }
        for i in 1..<rows {
            let y = bounds.height * CGFloat(i) / CGFloat(rows)
            gridPath.move(to: NSPoint(x: 0, y: y))
            gridPath.line(to: NSPoint(x: bounds.width, y: y))
        }
        NSColor.white.withAlphaComponent(0.5).setStroke()
        gridPath.stroke()

        let borderPath = NSBezierPath(rect: bounds.insetBy(dx: 0.5, dy: 0.5))
        NSColor.white.withAlphaComponent(0.6).setStroke()
        borderPath.stroke()

        if let start = startCell, let current = currentCell {
            let rect = selectionRect(from: start, to: current)
            NSColor.controlAccentColor.withAlphaComponent(0.45).setFill()
            rect.fill()
            let border = NSBezierPath(rect: rect.insetBy(dx: 1, dy: 1))
            border.lineWidth = 2
            NSColor.controlAccentColor.setStroke()
            border.stroke()
        }
    }

    private func cell(at point: NSPoint) -> (Int, Int) {
        let cellW = bounds.width / CGFloat(columns)
        let cellH = bounds.height / CGFloat(rows)
        let col = min(columns - 1, max(0, Int(point.x / cellW)))
        let row = min(rows - 1, max(0, Int(point.y / cellH)))
        return (col, row)
    }

    private func selectionRect(from a: (Int, Int), to b: (Int, Int)) -> NSRect {
        let minCol = min(a.0, b.0), maxCol = max(a.0, b.0)
        let minRow = min(a.1, b.1), maxRow = max(a.1, b.1)
        let cellW = bounds.width / CGFloat(columns)
        let cellH = bounds.height / CGFloat(rows)
        return NSRect(x: CGFloat(minCol) * cellW,
                       y: CGFloat(minRow) * cellH,
                       width: CGFloat(maxCol - minCol + 1) * cellW,
                       height: CGFloat(maxRow - minRow + 1) * cellH)
    }

    override func mouseDown(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        startCell = cell(at: p)
        currentCell = startCell
        isDragging = true
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        let p = convert(event.locationInWindow, from: nil)
        currentCell = cell(at: p)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDragging, let start = startCell, let current = currentCell else { return }
        isDragging = false
        let rect = selectionRect(from: start, to: current)
        startCell = nil
        currentCell = nil
        needsDisplay = true
        onComplete?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onCancel?()
        } else {
            super.keyDown(with: event)
        }
    }
}
