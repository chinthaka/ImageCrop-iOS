import CoreGraphics
import XCTest
@testable import ImageCrop

final class CropGeometryTests: XCTestCase {
    private let limit = CGRect(x: 0, y: 0, width: 100, height: 100)

    func testAspectFitCentersAWideImage() {
        let frame = CropGeometry.aspectFitFrame(
            contentSize: CGSize(width: 400, height: 100),
            in: CGRect(x: 0, y: 0, width: 200, height: 100)
        )
        assertEqual(frame, CGRect(x: 0, y: 25, width: 200, height: 50))
    }

    func testAspectFitRespectsBoundsOrigin() {
        let frame = CropGeometry.aspectFitFrame(
            contentSize: CGSize(width: 200, height: 100),
            in: CGRect(x: 10, y: 20, width: 100, height: 100)
        )
        assertEqual(frame, CGRect(x: 10, y: 45, width: 100, height: 50))
    }

    func testAspectFitOfEmptyInputIsZero() {
        let frame = CropGeometry.aspectFitFrame(contentSize: .zero, in: limit)
        XCTAssertEqual(frame, .zero)
    }

    func testNormalizedRectUsesTheImageFrame() {
        let frame = CGRect(x: 10, y: 20, width: 100, height: 50)
        let normalized = CropGeometry.normalizedRect(
            selection: CGRect(x: 10, y: 20, width: 50, height: 25),
            in: frame
        )
        assertEqual(normalized!, CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
    }

    func testNormalizedRectClipsToTheImageFrame() {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let normalized = CropGeometry.normalizedRect(
            selection: CGRect(x: -20, y: 25, width: 70, height: 50),
            in: frame
        )
        assertEqual(normalized!, CGRect(x: 0, y: 0.25, width: 0.5, height: 0.5))
    }

    func testNormalizedRectOutsideTheFrameIsNil() {
        let normalized = CropGeometry.normalizedRect(
            selection: CGRect(x: 200, y: 200, width: 10, height: 10),
            in: limit
        )
        XCTAssertNil(normalized)
    }

    func testViewRectRoundTrips() {
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
        let frame = CropGeometry.aspectFitFrame(contentSize: CGSize(width: 400, height: 100), in: bounds)
        let selection = CGRect(x: 50, y: 25, width: 100, height: 50)
        let normalized = CropGeometry.normalizedRect(selection: selection, in: frame)
        let restored = CropGeometry.viewRect(normalized: normalized!, in: frame)
        assertEqual(restored, selection)
    }

    func testClampedNormalizedRectPullsEdgesIntoTheUnitSquare() {
        let clamped = CropGeometry.clampedNormalizedRect(CGRect(x: -0.2, y: 0.2, width: 1.5, height: 0.5))
        assertEqual(clamped, CGRect(x: 0, y: 0.2, width: 1, height: 0.5))
    }

    func testDrawingAnyDirectionProducesTheSameRect() {
        let drawn = CropGeometry.selectionByDrawing(from: CGPoint(x: 80, y: 10), to: CGPoint(x: 10, y: 60), within: limit)
        assertEqual(drawn, CGRect(x: 10, y: 10, width: 70, height: 50))
    }

    func testDrawingClampsToTheImageFrame() {
        let drawn = CropGeometry.selectionByDrawing(
            from: CGPoint(x: -40, y: 20),
            to: CGPoint(x: 150, y: 80),
            within: limit
        )
        assertEqual(drawn, CGRect(x: 0, y: 20, width: 100, height: 60))
    }

    func testMovingStopsAtTheFrameEdge() {
        let moved = CropGeometry.selectionByMoving(
            start: CGRect(x: 10, y: 10, width: 40, height: 40),
            translation: CGPoint(x: 100, y: -50),
            within: limit
        )
        assertEqual(moved, CGRect(x: 60, y: 0, width: 40, height: 40))
    }

    func testResizingKeepsTheMinimumSize() {
        let resized = CropGeometry.selectionByResizing(
            handle: .bottomRight,
            start: CGRect(x: 10, y: 10, width: 40, height: 40),
            to: CGPoint(x: 20, y: 20),
            within: limit,
            minimum: 32
        )
        assertEqual(resized, CGRect(x: 10, y: 10, width: 32, height: 32))
    }

    func testResizingTopLeftAnchorsTheOppositeCorner() {
        let resized = CropGeometry.selectionByResizing(
            handle: .topLeft,
            start: CGRect(x: 10, y: 10, width: 40, height: 40),
            to: CGPoint(x: 0, y: 0),
            within: limit,
            minimum: 32
        )
        assertEqual(resized, CGRect(x: 0, y: 0, width: 50, height: 50))
    }

    func testResizingPullsBackInsideWhenMinimumHitsTheEdge() {
        let resized = CropGeometry.selectionByResizing(
            handle: .bottomRight,
            start: CGRect(x: 80, y: 10, width: 20, height: 40),
            to: CGPoint(x: 90, y: 80),
            within: limit,
            minimum: 32
        )
        assertEqual(resized, CGRect(x: 68, y: 10, width: 32, height: 70))
    }

    func testResizingCannotLeaveTheFrame() {
        let resized = CropGeometry.selectionByResizing(
            handle: .bottomRight,
            start: CGRect(x: 10, y: 10, width: 40, height: 40),
            to: CGPoint(x: 400, y: 400),
            within: limit,
            minimum: 32
        )
        assertEqual(resized, CGRect(x: 10, y: 10, width: 90, height: 90))
    }

    func testHandleHitPrefersTheNearestCorner() {
        let selection = CGRect(x: 0, y: 0, width: 30, height: 30)
        let handle = CropGeometry.handle(at: CGPoint(x: 2, y: 1), in: selection, radius: 22)
        XCTAssertEqual(handle, .topLeft)
    }

    func testHandleMissesTheCenter() {
        let selection = CGRect(x: 0, y: 0, width: 100, height: 100)
        XCTAssertNil(CropGeometry.handle(at: CGPoint(x: 50, y: 50), in: selection, radius: 22))
    }

    func testMinimumLengthShrinksToTheFrame() {
        XCTAssertEqual(CropGeometry.minimumLength(in: CGRect(x: 0, y: 0, width: 20, height: 100)), 20)
        XCTAssertEqual(CropGeometry.minimumLength(in: limit), 32)
    }

    func testTinySelectionIsNotUsable() {
        XCTAssertFalse(CropGeometry.isUsable(CGRect(x: 0, y: 0, width: 10, height: 40), in: limit, minimum: 32))
        XCTAssertTrue(CropGeometry.isUsable(CGRect(x: 0, y: 0, width: 32, height: 32), in: limit, minimum: 32))
    }

    private func assertEqual(_ lhs: CGRect, _ rhs: CGRect, accuracy: CGFloat = 0.001, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(lhs.origin.x, rhs.origin.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.origin.y, rhs.origin.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.width, rhs.width, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(lhs.height, rhs.height, accuracy: accuracy, file: file, line: line)
    }
}
