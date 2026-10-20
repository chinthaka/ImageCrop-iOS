import UIKit

protocol CropOverlayViewDelegate: AnyObject {
    func cropOverlayViewDidChangeSelection(_ overlay: CropOverlayView)
}

/// Draws the dimmed crop mask and tracks draw, move, and corner-resize gestures.
final class CropOverlayView: UIView {
    weak var delegate: CropOverlayViewDelegate?

    var imageFrame: CGRect = .zero {
        didSet {
            guard oldValue != imageFrame else { return }
            setNeedsDisplay()
        }
    }

    private(set) var normalizedSelection: CGRect? {
        didSet { setNeedsDisplay() }
    }

    private enum Drag {
        case draw(origin: CGPoint)
        case move(start: CGRect, origin: CGPoint)
        case resize(CropHandle, start: CGRect)
    }

    private var drag: Drag?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        contentMode = .redraw
        isMultipleTouchEnabled = false
        isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let selection = currentSelectionRect(), selection.width > 1, selection.height > 1 else { return }

        let dim = UIBezierPath(rect: bounds)
        dim.append(UIBezierPath(rect: selection))
        dim.usesEvenOddFillRule = true
        UIColor.black.withAlphaComponent(0.55).setFill()
        dim.fill()

        guard selection.width > 2, selection.height > 2 else { return }
        let border = UIBezierPath(rect: selection.insetBy(dx: 0.75, dy: 0.75))
        border.lineWidth = 1.5
        UIColor.black.withAlphaComponent(0.85).setStroke()
        border.stroke()
        border.setLineDash([5, 4], count: 2, phase: 0)
        UIColor.white.setStroke()
        border.stroke()

        for handle in CropHandle.allCases {
            let corner = handle.point(on: selection)
            let handleRect = CGRect(x: corner.x - 5, y: corner.y - 5, width: 10, height: 10)
            let knob = UIBezierPath(roundedRect: handleRect, cornerRadius: 2)
            UIColor.black.setFill()
            knob.fill()
            UIColor.white.setFill()
            UIBezierPath(roundedRect: handleRect.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 1).fill()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), imageFrame.width > 0, imageFrame.height > 0 else { return }
        if let selection = currentSelectionRect(), let handle = CropGeometry.handle(at: point, in: selection) {
            drag = .resize(handle, start: selection)
        } else if let selection = currentSelectionRect(), selection.insetBy(dx: -8, dy: -8).contains(point) {
            drag = .move(start: selection, origin: point)
        } else if imageFrame.contains(point) {
            drag = .draw(origin: point)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), let drag else { return }
        apply(drag, at: point, commitTinyDraw: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let drag {
            apply(drag, at: point, commitTinyDraw: true)
        }
        drag = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let drag {
            apply(drag, at: point, commitTinyDraw: true)
        }
        drag = nil
    }

    private func apply(_ drag: Drag, at point: CGPoint, commitTinyDraw: Bool) {
        let limit = imageFrame
        let minimum = CropGeometry.minimumLength(in: limit)
        let selection: CGRect
        switch drag {
        case .draw(let origin):
            selection = CropGeometry.selectionByDrawing(from: origin, to: point, within: limit)
            if commitTinyDraw && !CropGeometry.isUsable(selection, in: limit, minimum: minimum) {
                normalizedSelection = nil
                delegate?.cropOverlayViewDidChangeSelection(self)
                return
            }
        case .move(let start, let origin):
            let translation = CGPoint(x: point.x - origin.x, y: point.y - origin.y)
            selection = CropGeometry.selectionByMoving(start: start, translation: translation, within: limit)
        case .resize(let handle, let start):
            selection = CropGeometry.selectionByResizing(
                handle: handle,
                start: start,
                to: point,
                within: limit,
                minimum: minimum
            )
        }
        normalizedSelection = CropGeometry.normalizedRect(selection: selection, in: limit)
        delegate?.cropOverlayViewDidChangeSelection(self)
    }

    private func currentSelectionRect() -> CGRect? {
        guard let normalizedSelection else { return nil }
        let rect = CropGeometry.viewRect(normalized: normalizedSelection, in: imageFrame)
        guard rect.width > 0, rect.height > 0 else { return nil }
        return rect
    }
}
