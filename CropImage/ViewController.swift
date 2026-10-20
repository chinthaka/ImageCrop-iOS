import UIKit

/// Sample host. Shows a bundled photo, presents the crop editor, and displays the result.
final class ViewController: UIViewController, ImageCropViewControllerDelegate {
    private let imageView = UIImageView()
    private let cropButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let originalImage = UIImage(named: "Apple")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ImageCrop"

        imageView.image = originalImage
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "sample.preview"

        var cropConfig = UIButton.Configuration.filled()
        cropConfig.title = "Start to Crop"
        cropConfig.cornerStyle = .medium
        cropButton.configuration = cropConfig
        cropButton.addTarget(self, action: #selector(startCrop), for: .touchUpInside)
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        cropButton.accessibilityIdentifier = "sample.crop"

        var resetConfig = UIButton.Configuration.plain()
        resetConfig.title = "Show Original"
        resetButton.configuration = resetConfig
        resetButton.addTarget(self, action: #selector(showOriginal), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(cropButton)
        view.addSubview(resetButton)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: cropButton.topAnchor, constant: -16),

            cropButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            cropButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            cropButton.heightAnchor.constraint(equalToConstant: 48),

            resetButton.topAnchor.constraint(equalTo: cropButton.bottomAnchor, constant: 4),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
        ])
    }

    @objc private func startCrop() {
        guard let image = imageView.image else { return }
        let crop = ImageCropViewController(image: image)
        crop.delegate = self
        present(crop, animated: true)
    }

    @objc private func showOriginal() {
        imageView.image = originalImage
    }

    func imageCropViewController(_ controller: ImageCropViewController, didFinishWith result: ImageCropResult) {
        if case .cropped(let image) = result {
            imageView.image = image
        }
    }
}
