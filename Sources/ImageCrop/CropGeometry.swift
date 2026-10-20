import CoreGraphics

public enum CropHandle: CaseIterable, Equatable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    public func point(on selection: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: selection.minX, y: selection.minY)
        case .topRight:
            return CGPoint(x: selection.maxX, y: selection.minY)
        case .bottomLeft:
            return CGPoint(x: selection.minX, y: selection.maxY)
        case .bottomRight:
            return CGPoint(x: selection.maxX, y: selection.maxY)
        }
    }
}

/// View-geometry for an aspect-fit crop. These functions do not draw or touch UIImage.
public enum CropGeometry {
    public static let preferredMinimumLength: CGFloat = 32
    public static let handleRadius: CGFloat = 22

    public static func aspectFitFrame(contentSize: CGSize, in bounds: CGRect) -> CGRect {
        guard contentSize.width > 0, contentSize.height > 0, bounds.width > 0, bounds.height > 0 else {
            return .zero
        }
        let scale = min(bounds.width / contentSize.width, bounds.height / contentSize.height)
        let fitted = CGSize(width: contentSize.width * scale, height: contentSize.height * scale)
        return CGRect(
            x: bounds.midX - fitted.width / 2,
            y: bounds.midY - fitted.height / 2,
            width: fitted.width,
            height: fitted.height
        )
    }

    public static func minimumLength(in limit: CGRect, preferred: CGFloat = preferredMinimumLength) -> CGFloat {
        let cap = min(limit.width, limit.height)
        guard cap > 0 else { return 0 }
        return min(preferred, cap)
    }

    /// Selection as fractions of `imageFrame`. Coordinates outside the frame are clipped away.
    public static func normalizedRect(selection: CGRect, in imageFrame: CGRect) -> CGRect? {
        guard imageFrame.width > 0, imageFrame.height > 0 else { return nil }
        let intersection = selection.intersection(imageFrame)
        guard !intersection.isNull, !intersection.isInfinite, intersection.width > 0, intersection.height > 0 else {
            return nil
        }
        return CGRect(
            x: (intersection.minX - imageFrame.minX) / imageFrame.width,
            y: (intersection.minY - imageFrame.minY) / imageFrame.height,
            width: intersection.width / imageFrame.width,
            height: intersection.height / imageFrame.height
        )
    }

    public static func viewRect(normalized: CGRect, in imageFrame: CGRect) -> CGRect {
        let unit = clampedNormalizedRect(normalized)
        return CGRect(
            x: imageFrame.minX + unit.origin.x * imageFrame.width,
            y: imageFrame.minY + unit.origin.y * imageFrame.height,
            width: unit.width * imageFrame.width,
            height: unit.height * imageFrame.height
        )
    }

    public static func clampedNormalizedRect(_ rect: CGRect) -> CGRect {
        let minX = min(max(rect.minX, 0), 1)
        let minY = min(max(rect.minY, 0), 1)
        let maxX = min(max(rect.maxX, 0), 1)
        let maxY = min(max(rect.maxY, 0), 1)
        return CGRect(x: minX, y: minY, width: max(0, maxX - minX), height: max(0, maxY - minY))
    }

    public static func isUsable(_ selection: CGRect, in limit: CGRect, minimum: CGFloat) -> Bool {
        guard minimum > 0 else { return false }
        let clipped = selection.intersection(limit)
        guard !clipped.isNull, !clipped.isInfinite else { return false }
        return clipped.width >= minimum && clipped.height >= minimum
    }

    public static func handle(at point: CGPoint, in selection: CGRect, radius: CGFloat = handleRadius) -> CropHandle? {
        var closest: (CropHandle, CGFloat)?
        for handle in CropHandle.allCases {
            let corner = handle.point(on: selection)
            let distance = hypot(corner.x - point.x, corner.y - point.y)
            if distance <= radius, closest == nil || distance < closest!.1 {
                closest = (handle, distance)
            }
        }
        return closest?.0
    }

    public static func selectionByDrawing(from start: CGPoint, to end: CGPoint, within limit: CGRect) -> CGRect {
        let a = clamped(start, to: limit)
        let b = clamped(end, to: limit)
        return CGRect(
            x: min(a.x, b.x),
            y: min(a.y, b.y),
            width: abs(a.x - b.x),
            height: abs(a.y - b.y)
        )
    }

    public static func selectionByMoving(start: CGRect, translation: CGPoint, within limit: CGRect) -> CGRect {
        var rect = start.offsetBy(dx: translation.x, dy: translation.y)
        let maxX = max(limit.minX, limit.maxX - rect.width)
        let maxY = max(limit.minY, limit.maxY - rect.height)
        rect.origin.x = min(max(rect.origin.x, limit.minX), maxX)
        rect.origin.y = min(max(rect.origin.y, limit.minY), maxY)
        return rect
    }

    /// `point` is the finger position. The opposite corner of `start` stays put, and the result stays inside `limit`.
    public static func selectionByResizing(
        handle: CropHandle,
        start: CGRect,
        to point: CGPoint,
        within limit: CGRect,
        minimum: CGFloat
    ) -> CGRect {
        let finger = clamped(point, to: limit)
        var minX = start.minX
        var minY = start.minY
        var maxX = start.maxX
        var maxY = start.maxY

        switch handle {
        case .topLeft:
            minX = min(finger.x, maxX - minimum)
            minY = min(finger.y, maxY - minimum)
        case .topRight:
            maxX = max(finger.x, minX + minimum)
            minY = min(finger.y, maxY - minimum)
        case .bottomLeft:
            minX = min(finger.x, maxX - minimum)
            maxY = max(finger.y, minY + minimum)
        case .bottomRight:
            maxX = max(finger.x, minX + minimum)
            maxY = max(finger.y, minY + minimum)
        }

        minX = max(minX, limit.minX)
        minY = max(minY, limit.minY)
        maxX = min(maxX, limit.maxX)
        maxY = min(maxY, limit.maxY)

        if maxX - minX < minimum {
            switch handle {
            case .topLeft, .bottomLeft:
                minX = max(limit.minX, maxX - minimum)
                maxX = minX + minimum
            case .topRight, .bottomRight:
                maxX = min(limit.maxX, minX + minimum)
                minX = maxX - minimum
            }
        }
        if maxY - minY < minimum {
            switch handle {
            case .topLeft, .topRight:
                minY = max(limit.minY, maxY - minimum)
                maxY = minY + minimum
            case .bottomLeft, .bottomRight:
                maxY = min(limit.maxY, minY + minimum)
                minY = maxY - minimum
            }
        }

        return CGRect(x: minX, y: minY, width: max(0, maxX - minX), height: max(0, maxY - minY))
    }

    private static func clamped(_ point: CGPoint, to limit: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(point.x, limit.minX), limit.maxX),
            y: min(max(point.y, limit.minY), limit.maxY)
        )
    }
}
