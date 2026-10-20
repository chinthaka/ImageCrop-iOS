import UIKit

public extension UIImage {
    /// Crops this image to a unit rectangle in the upright image the user sees.
    /// `(0, 0, 1, 1)` is the whole image. Orientation is applied, so the result matches the on-screen pixels.
    func cropped(toNormalized rect: CGRect) -> UIImage? {
        let normalized = CropGeometry.clampedNormalizedRect(rect)
        guard normalized.width > 0, normalized.height > 0 else { return nil }
        guard size.width > 0, size.height > 0 else { return nil }

        let scale = self.scale > 0 ? self.scale : 1
        let minX = floor(normalized.minX * size.width * scale) / scale
        let minY = floor(normalized.minY * size.height * scale) / scale
        let maxX = min(size.width, ceil(normalized.maxX * size.width * scale) / scale)
        let maxY = min(size.height, ceil(normalized.maxY * size.height * scale) / scale)
        let cropSize = CGSize(width: maxX - minX, height: maxY - minY)
        guard cropSize.width * scale >= 1, cropSize.height * scale >= 1 else { return nil }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: cropSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(x: -minX, y: -minY, width: size.width, height: size.height))
        }
    }
}
