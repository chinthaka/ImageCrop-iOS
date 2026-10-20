import UIKit

public enum ImageCropResult {
    case cropped(UIImage)
    case cancelled
}

@MainActor
public protocol ImageCropViewControllerDelegate: AnyObject {
    func imageCropViewController(_ controller: ImageCropViewController, didFinishWith result: ImageCropResult)
}

/// Full-screen editor. Drag to draw a rectangle, drag inside it to move, and drag a corner to resize.
public final class ImageCropViewController: UIViewController, CropOverlayViewDelegate, UIAdaptivePresentationControllerDelegate {
    public let image: UIImage
    public weak var delegate: ImageCropViewControllerDelegate?

    /// `nil` means the user cancelled. Invoked on the main queue.
    public var onFinish: ((UIImage?) -> Void)?

    private let imageView = UIImageView()
    private let overlay = CropOverlayView()
    private let hintLabel = PaddedLabel()
    private let toolbar = UIToolbar()
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private lazy var cropItem = UIBarButtonItem(
        title: "Crop",
        primaryAction: UIAction { [weak self] _ in self?.cropTapped() }
    )
    private lazy var cancelItem = UIBarButtonItem(
        title: "Cancel",
        primaryAction: UIAction { [weak self] _ in self?.cancelTapped() }
    )
    private lazy var spinnerItem = UIBarButtonItem(customView: spinner)

    private var requestID = 0

    public init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        overrideUserInterfaceStyle = .dark

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        overlay.delegate = self
        overlay.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.text = "Drag to choose the crop"
        hintLabel.textColor = .white
        hintLabel.font = .preferredFont(forTextStyle: .subheadline)
        hintLabel.textAlignment = .center
        hintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        hintLabel.layer.cornerRadius = 8
        hintLabel.clipsToBounds = true
        hintLabel.isUserInteractionEnabled = false
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        toolbar.standardAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.compactAppearance = appearance
        toolbar.tintColor = .white
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        cropItem.isEnabled = false
        cropItem.accessibilityIdentifier = "imagecrop.crop"
        cancelItem.accessibilityIdentifier = "imagecrop.cancel"
        toolbar.items = [cancelItem, UIBarButtonItem(systemItem: .flexibleSpace), cropItem]

        view.addSubview(imageView)
        view.addSubview(overlay)
        view.addSubview(hintLabel)
        view.addSubview(toolbar)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: safe.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            overlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            hintLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentationController?.delegate = self
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = CropGeometry.aspectFitFrame(contentSize: image.size, in: overlay.bounds)
        if frame != overlay.imageFrame {
            overlay.imageFrame = frame
        }
        updateChrome()
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        requestID += 1
        notify(.cancelled)
    }

    func cropOverlayViewDidChangeSelection(_ overlay: CropOverlayView) {
        updateChrome()
    }

    private func updateChrome() {
        let minimum = CropGeometry.minimumLength(in: overlay.imageFrame)
        let usable: Bool
        if let normalized = overlay.normalizedSelection {
            let rect = CropGeometry.viewRect(normalized: normalized, in: overlay.imageFrame)
            usable = CropGeometry.isUsable(rect, in: overlay.imageFrame, minimum: minimum)
        } else {
            usable = false
        }
        if !spinner.isAnimating {
            cropItem.isEnabled = usable
        }
        hintLabel.isHidden = usable
    }

    private func cropTapped() {
        guard !spinner.isAnimating, let normalized = overlay.normalizedSelection else { return }
        requestID += 1
        let token = requestID
        let source = image
        spinner.startAnimating()
        cropItem.isEnabled = false
        toolbar.items = [cancelItem, UIBarButtonItem(systemItem: .flexibleSpace), spinnerItem]
        DispatchQueue.global(qos: .userInitiated).async {
            let cropped = source.cropped(toNormalized: normalized)
            DispatchQueue.main.async { [weak self] in
                guard let self, self.requestID == token else { return }
                self.spinner.stopAnimating()
                self.toolbar.items = [self.cancelItem, UIBarButtonItem(systemItem: .flexibleSpace), self.cropItem]
                guard let cropped else {
                    self.updateChrome()
                    return
                }
                self.finish(.cropped(cropped))
            }
        }
    }

    private func cancelTapped() {
        requestID += 1
        finish(.cancelled)
    }

    private func finish(_ result: ImageCropResult) {
        notify(result)
        if let navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func notify(_ result: ImageCropResult) {
        switch result {
        case .cropped(let image):
            onFinish?(image)
        case .cancelled:
            onFinish?(nil)
        }
        delegate?.imageCropViewController(self, didFinishWith: result)
    }
}

private final class PaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        let expanded = UIEdgeInsets(top: -insets.top, left: -insets.left, bottom: -insets.bottom, right: -insets.right)
        return textRect.inset(by: expanded)
    }
}
