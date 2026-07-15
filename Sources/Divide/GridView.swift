import Cocoa

/// Draws a Divvy-style grid and lets the user click-and-drag across cells
/// to select a rectangular region. The selection snaps to grid lines.
final class GridView: NSView {
    var columns = 6
    var rows = 6

    /// Called with the selected rect in view-local coordinates (origin bottom-left).
    var onComplete: ((NSRect) -> Void)?
    var onCancel: (() -> Void)?

    private var startCell: GridMath.Cell?
    private var currentCell: GridMath.Cell?
    private var isDragging = false

    override var acceptsFirstResponder: Bool { true }
    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.65).setFill()
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
            let rect = GridMath.selectionRect(from: start, to: current, size: bounds.size, columns: columns, rows: rows)
            NSColor.controlAccentColor.withAlphaComponent(0.45).setFill()
            rect.fill()
            let border = NSBezierPath(rect: rect.insetBy(dx: 1, dy: 1))
            border.lineWidth = 2
            NSColor.controlAccentColor.setStroke()
            border.stroke()
        }
    }

    override func mouseDown(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        startCell = GridMath.cell(at: p, size: bounds.size, columns: columns, rows: rows)
        currentCell = startCell
        isDragging = true
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        let p = convert(event.locationInWindow, from: nil)
        currentCell = GridMath.cell(at: p, size: bounds.size, columns: columns, rows: rows)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDragging, let start = startCell, let current = currentCell else { return }
        isDragging = false
        let rect = GridMath.selectionRect(from: start, to: current, size: bounds.size, columns: columns, rows: rows)
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
