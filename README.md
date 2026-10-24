# ImageCrop

[![CI](https://github.com/chinthaka/ImageCrop-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/chinthaka/ImageCrop-iOS/actions/workflows/ci.yml)

Chinthaka Kumarasiri

ImageCrop is a small iOS editor for cropping a photo with your finger. Drag to draw a rectangle, drag inside it to move, and drag a corner to resize. The crop is taken from the original image, including its orientation, and the on-screen border is not part of the result.

Requires iOS 15 or later. Distribute it with Swift Package Manager, or build the sample app in `CropImage.xcodeproj`.

![ScreenShot](https://github.com/chinthaka/ImageCrop-iOS/raw/master/shots/screen2.PNG)


## Swift Package Manager

Add the package `https://github.com/chinthaka/ImageCrop-iOS` from version 2.0.0, then depend on the `ImageCrop` product.

```swift
import ImageCrop
import UIKit

let crop = ImageCropViewController(image: image)
crop.onFinish = { cropped in
    if let cropped {
        self.imageView.image = cropped
    }
}
present(crop, animated: true)
```

A delegate is also available:

```swift
final class Editor: UIViewController, ImageCropViewControllerDelegate {
    func presentCrop(for image: UIImage) {
        let crop = ImageCropViewController(image: image)
        crop.delegate = self
        present(crop, animated: true)
    }

    func imageCropViewController(_ controller: ImageCropViewController, didFinishWith result: ImageCropResult) {
        if case .cropped(let image) = result {
            imageView.image = image
        }
    }
}
```

The controller dismisses itself. Full screen is the default. Cancel and Crop both report through `onFinish` or the delegate, and `onFinish` receives `nil` when the user cancels. A page-sheet swipe reports a cancel as well.

To crop without UI, pass a unit rectangle in the upright image. `(0, 0, 1, 1)` is the whole image.

```swift
let head = image.cropped(toNormalized: CGRect(x: 0.2, y: 0.1, width: 0.5, height: 0.5))
```

## Sample app

Open `CropImage.xcodeproj` and run the CropImage scheme. The sample compiles `Sources/ImageCrop` into the app target, so it does not need a separate package checkout. Signing is automatic. Pick a development team before you run on a device.

## Tests

Geometry for aspect fit, hit testing, and the draw, move, and resize gestures is covered by `Tests/ImageCropTests`. [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs those tests and builds the sample app on every push and pull request.

`xcodebuild` selects `CropImage.xcodeproj` when it is in the working directory, so test the package from a copy that contains `Package.swift`:

```sh
copy=$(mktemp -d)
rsync -a --exclude CropImage.xcodeproj --exclude .git ./ "$copy/"
(
  cd "$copy"
  xcodebuild test -scheme ImageCrop -destination 'platform=iOS Simulator,name=iPhone 16'
)
```

## Upgrading from the Objective-C editor

Replace `CropingImageViewControl`, the `CropingImageView` xib, and `presentModalViewController` with `ImageCropViewController`. The cropped image arrives through `onFinish` or `ImageCropViewControllerDelegate`.

## License

MIT. See [LICENSE](LICENSE).
