import XCTest
@testable import Divide

final class GridMathTests: XCTestCase {
    let size = CGSize(width: 600, height: 600) // 6x6 grid -> 100pt cells
    let columns = 6
    let rows = 6

    func testCellClampsNegativeAndOutOfBoundsCoordinates() {
        XCTAssertEqual(GridMath.cell(at: CGPoint(x: -50, y: -50), size: size, columns: columns, rows: rows),
                       GridMath.Cell(col: 0, row: 0))
        XCTAssertEqual(GridMath.cell(at: CGPoint(x: 10_000, y: 10_000), size: size, columns: columns, rows: rows),
                       GridMath.Cell(col: 5, row: 5))
    }

    func testCellMapsToExpectedIndex() {
        XCTAssertEqual(GridMath.cell(at: CGPoint(x: 250, y: 350), size: size, columns: columns, rows: rows),
                       GridMath.Cell(col: 2, row: 3))
    }

    func testSingleClickSelectsExactlyOneCell() {
        let cell = GridMath.Cell(col: 2, row: 2)
        let rect = GridMath.selectionRect(from: cell, to: cell, size: size, columns: columns, rows: rows)
        XCTAssertEqual(rect, CGRect(x: 200, y: 200, width: 100, height: 100))
    }

    func testSelectionIsSymmetricRegardlessOfDragDirection() {
        let a = GridMath.Cell(col: 1, row: 1)
        let b = GridMath.Cell(col: 4, row: 3)
        let forward = GridMath.selectionRect(from: a, to: b, size: size, columns: columns, rows: rows)
        let backward = GridMath.selectionRect(from: b, to: a, size: size, columns: columns, rows: rows)
        XCTAssertEqual(forward, backward)
    }

    func testCornerToCornerDragSelectsEntireGrid() {
        let topLeft = GridMath.Cell(col: 0, row: 0)
        let bottomRight = GridMath.Cell(col: 5, row: 5)
        let rect = GridMath.selectionRect(from: topLeft, to: bottomRight, size: size, columns: columns, rows: rows)
        XCTAssertEqual(rect, CGRect(origin: .zero, size: size))
    }
}
