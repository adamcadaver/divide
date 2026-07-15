import CoreGraphics

/// Pure grid-cell math used by GridView, factored out so it can be unit
/// tested without a live NSView/window.
enum GridMath {
    struct Cell: Equatable {
        var col: Int
        var row: Int
    }

    static func cell(at point: CGPoint, size: CGSize, columns: Int, rows: Int) -> Cell {
        let cellW = size.width / CGFloat(columns)
        let cellH = size.height / CGFloat(rows)
        let col = min(columns - 1, max(0, Int(point.x / cellW)))
        let row = min(rows - 1, max(0, Int(point.y / cellH)))
        return Cell(col: col, row: row)
    }

    /// The rect spanning cells `a` and `b` (inclusive), regardless of drag direction.
    static func selectionRect(from a: Cell, to b: Cell, size: CGSize, columns: Int, rows: Int) -> CGRect {
        let minCol = min(a.col, b.col), maxCol = max(a.col, b.col)
        let minRow = min(a.row, b.row), maxRow = max(a.row, b.row)
        let cellW = size.width / CGFloat(columns)
        let cellH = size.height / CGFloat(rows)
        return CGRect(x: CGFloat(minCol) * cellW,
                       y: CGFloat(minRow) * cellH,
                       width: CGFloat(maxCol - minCol + 1) * cellW,
                       height: CGFloat(maxRow - minRow + 1) * cellH)
    }
}
