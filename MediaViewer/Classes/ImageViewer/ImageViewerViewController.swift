//
//  ImageViewerViewController.swift
//  ImageViewer
//
//  Created by Omar on 2/24/21.
//

import UIKit
import Nuke

public protocol ImageViewerViewControllerDelegate: class {
    func imageViewerViewControllerWasDismissed(_ viewController: ImageViewerViewController)
    func imageViewerViewController(_ viewController: ImageViewerViewController, didDownloadImage image: UIImage)
    func imageViewerViewController(_ viewController: ImageViewerViewController, didFailDownloadingImageWith error: Error)
}
public extension ImageViewerViewControllerDelegate {
    func imageViewerViewControllerWasDismissed(_ viewController: ImageViewerViewController) {}
    func imageViewerViewController(_ viewController: ImageViewerViewController, didDownloadImage image: UIImage) {}
    func imageViewerViewController(_ viewController: ImageViewerViewController, didFailDownloadingImageWith error: Error) {}
}
public class ImageViewerViewController: UIViewController {
    
    // MARK: Initializers
    init(
        withImageUrl imageUrlString: String? = nil,
        withImage image: UIImage? = nil,
        andPlaceHolderImage placeHolderImage: UIImage? = nil,
        isEmbedded: Bool
    ) {
        self.imageUrlString = imageUrlString
        self.placeHolderImage = placeHolderImage
        self.image = image
        self.isEmbedded = isEmbedded
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK:- Views
    lazy var mainImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var blurredImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.transform = .init(scaleX: 10, y: 10)
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    // MARK:- Bar Buttons
    private lazy var spinnerBarButton: UIBarButtonItem = {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        spinner.startAnimating()
        return UIBarButtonItem(customView: spinner)
    }()
    private lazy var saveBarButton = UIBarButtonItem.init(
        title: "save".localized,
        style: .plain,
        target: self,
        action: #selector(moreAction)
    )
    private lazy var doneBarButton = UIBarButtonItem.init(
        title: "done".localized,
        style: .done,
        target: self,
        action: #selector(doneAction)
    )
    
    public weak var delegate: ImageViewerViewControllerDelegate?
    private let imageUrlString: String?
    private let image: UIImage?
    private var placeHolderImage: UIImage?
    private let isEmbedded: Bool
    
    @objc func moreAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let downloadAction = UIAlertAction(title: "save".localized,
                                           style: .default) { (_) in
            self.downloadImage()
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 0,
                                                              height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        present(alert, animated: true, completion: nil)
    }
    @objc func doneAction() {
        dismiss(animated: true) {
            self.delegate?.imageViewerViewControllerWasDismissed(self)
        }
    }
}

extension ImageViewerViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        addSubviewsToViewsHierarchy()
        addGesturesToViews()
        loadImage()
        setupNavigationBar()
        
    }
    private func setupNavigationBar() {
        if imageUrlString != nil {
            self.navigationItem.rightBarButtonItems = [saveBarButton]
        }
        self.navigationItem.leftBarButtonItems = [doneBarButton]
        
        guard
            let imageUrl = imageUrlString,
            let lastPath = URL(string: imageUrl)?.lastPathComponent else { return }
        navigationItem.title = lastPath
    }
}
// MARK: View Hierarchy Setup
extension ImageViewerViewController {
    private func addSubviewsToViewsHierarchy() {
        addImageViewToViewsHierarchy()
    }
    private func addImageViewToViewsHierarchy() {
        view.addSubview(blurredImageView)
        blurredImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurredImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurredImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        blurredImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(mainImageView)
        mainImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: Image Loading
extension ImageViewerViewController {
    private func loadImage() {
        if
            let imageUrlString = imageUrlString,
            let imageURL = URL(string: imageUrlString) {
            
            let options = ImageLoadingOptions(
                placeholder: placeHolderImage,
                transition: .fadeIn(duration: 0.33),
                failureImage: UIImage(),
                contentModes: .init(success: .scaleAspectFit, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
            )
            Nuke.loadImage(with: imageURL,
                           options: options,
                           into: mainImageView) { result  in
                switch result {
                case .success:
                    self.showTopActions()
                case .failure:
                    self.dismissAndFireDelegate(animate: true)
                }
            }
            
            let request = ImageRequest(url: imageURL, processors: [
                ImageProcessors.GaussianBlur.init(radius: 8)
            ])
            
            
            Nuke.loadImage(with: request,
                           into: blurredImageView,
                           completion:  { _ in
                           })
        }
        
        if let image = image {
            mainImageView.image = image
            blurredImageView.isHidden = true
        }
    }
    private func showTopActions() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
// MARK: ImageViews GesturesSetup
extension ImageViewerViewController {
    private func addGesturesToViews() {
        addMainImageViewGestures()
    }
    private func addMainImageViewGestures() {
        if !isEmbedded {
            addPanGestureRecognizer()
        }
        addPinchGestureRecognizer()
        addTapGestureRecognizers()
    }
    private func addPanGestureRecognizer() {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handlePanGesture(_:)))
        gesture.delegate = self
        mainImageView.addGestureRecognizer(gesture)
    }
    @objc func addPinchGestureRecognizer() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchGesture.delegate = self
        mainImageView.addGestureRecognizer(pinchGesture)
    }
    @objc func addTapGestureRecognizers() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        mainImageView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        mainImageView.addGestureRecognizer(singleTapGesture)
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    // MARK: Pan Gesture Handler
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let imageView = recognizer.view else { return }
        let translation = recognizer.translation(in: imageView)
        
        imageView.center.x += translation.x
        imageView.center.y += translation.y
        recognizer.setTranslation(.zero, in: imageView)
        self.view.backgroundColor = .clear
        let deltaY = 3 * abs((imageView.center.y / self.view.center.y) - 1)
        blurredImageView.alpha = 1 - deltaY
        
        hideNavigationBar()
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.2) {
                if self.shouldDismissUpwards() {
                    UIView.animate(withDuration: 0.25) {
                        imageView.alpha = 0
                        imageView.center.y -= 400
                        self.view.center.y -= 1000
                    } completion: { (_) in
                        self.dismissAndFireDelegate(animate: false)
                    }
                } else if self.shouldDismissDownwards() {
                    UIView.animate(withDuration: 0.25) {
                        imageView.alpha = 0
                        imageView.center.y += 400
                        self.view.center.y += 1000
                    } completion: { (_) in
                        self.dismissAndFireDelegate(animate: false)
                    }
                } else {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    imageView.center = self.view.center
                    self.blurredImageView.alpha = 1
                }
                self.view.backgroundColor = .white
            }
        }
    }
    func shouldDismissUpwards() -> Bool {
        return abs(mainImageView.center.y - view.center.y) >= 0.3 * view.frame.height && mainImageView.center.y < view.center.y
    }
    func shouldDismissDownwards() -> Bool {
        return abs(mainImageView.center.y - view.center.y) >= 0.3 * view.frame.height && mainImageView.center.y > view.center.y
    }
    // MARK: Pinch Gesture Handler
    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard let view = recognizer.view else { return }
        view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        hideNavigationBar()
        
        if recognizer.state == .ended {
            
            print(view.transform.a)
            if view.transform.a < 1 {
                UIView.animate(withDuration: 0.25) {
                    view.transform = .identity
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    
                }
            }
        }
        recognizer.scale = 1
    }
    private func animateActionsButtonsHide() {
        guard navigationController?.navigationBar.alpha != 0 else { return }
        UIView.animate(withDuration: 0.25) {
            self.navigationController?.navigationBar.alpha = 0
        }
    }
    
    // MARK: Double Tap Gesture Handler
    @objc func handleDoubleTapGesture(_ recognizer: UIPinchGestureRecognizer) {
        if mainImageView.transform.a > 1 {
            UIView.animate(withDuration: 0.25) {
                self.mainImageView.transform = .identity
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.mainImageView.transform = .init(scaleX: 2, y: 2)
            }
            self.hideNavigationBar()
        }
    }
    // MARK: Single Tap Gesture Handler
    @objc func handleSingleTapGesture(_ recognizer: UIPinchGestureRecognizer) {
        if mainImageView.transform.a > 1 {
            UIView.animate(withDuration: 0.25) {
                self.mainImageView.transform = .identity
            }
        }
        
        toggleNavigationBarVisibility()
    }
}
// MARK: Top Buttons Gesture Setup
extension ImageViewerViewController {
    @objc func handleMoreActionsTapGesture() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "save".localized, style: .default) { (_) in
            self.downloadImage()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX,
                                                              y: view.bounds.midY,
                                                              width: 0,
                                                              height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        present(alert, animated: true, completion: nil)
    }
    private func downloadImage() {
        self.navigationItem.rightBarButtonItems = [spinnerBarButton]
        DispatchQueue.global(qos: .background).async {
            if
                let imageUrlString = self.imageUrlString,
                let imageURL = URL(string: imageUrlString),
                let data = try? Data(contentsOf: imageURL),
                let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                               nil)
            }
        }
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.navigationItem.rightBarButtonItems = [saveBarButton]
        
        if error != nil {
            self.delegate?.imageViewerViewController(self, didFailDownloadingImageWith: error!)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.imageViewerViewController(self, didDownloadImage: image)
            }
        }
    }
}
extension ImageViewerViewController {
    private func hideNavigationBar() {
        guard !isEmbedded else { return }
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    private func toggleNavigationBarVisibility() {
        guard !isEmbedded else { return }
        navigationController?.setNavigationBarHidden(
            !(navigationController?.isNavigationBarHidden ?? true),
            animated: true
        )
    }
}
extension ImageViewerViewController {
    private func dismissAndFireDelegate(animate: Bool) {
        dismiss(animated: animate) {
            self.delegate?.imageViewerViewControllerWasDismissed(self)
        }
    }
}
extension ImageViewerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
