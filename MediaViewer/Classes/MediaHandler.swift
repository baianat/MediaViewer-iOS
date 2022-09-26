//
//  MediaHandler.swift
//  MediaViewer
//
//  Created by Omar on 2/24/21.
//

import UIKit

// MARK:- Image Handler
public extension UIViewController {
    @discardableResult func displayImage(
        at imageUrl: String,
        placeHolderImage: UIImage? = nil,
        delegate: ImageViewerViewControllerDelegate? = nil
    ) -> UIViewController {
        let vc = ImageViewerViewController.init(withImageUrl: imageUrl, andPlaceHolderImage: placeHolderImage, isEmbedded: false)
        let navigationController = UINavigationController.init(rootViewController: vc)
        vc.delegate = delegate
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
        return navigationController
    }
    
    @discardableResult func displayImage(
        _ image: UIImage,
        delegate: ImageViewerViewControllerDelegate? = nil
    ) -> UIViewController {
        let vc = ImageViewerViewController(withImage: image, isEmbedded: false)
        let navigationController = UINavigationController.init(rootViewController: vc)
        vc.delegate = delegate
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
        return navigationController
    }
}

// MARK:- Pdf Handler
public extension UIViewController {
    @discardableResult func displayPdf(
        at pdfUrl: String,
        allowDownload: Bool = true,
        delegate: WebViewerViewControllerDelegate? = nil
    ) -> UIViewController {
        let vc = WebViewerViewController.init(withUrl: pdfUrl, allowDownload: allowDownload)
        let navigationController = UINavigationController.init(rootViewController: vc)
        vc.delegate = delegate
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
        return navigationController
    }
}

// MARK:- Multi-media Handler
public extension UIViewController {
    @discardableResult func displayMedia(
        at mediaUrls: [String]
    ) -> UIViewController {
        let vc = MultiMediaPagesViewController.init(mediaUrls: mediaUrls)
        let navigationController = UINavigationController.init(rootViewController: vc)
        navigationController.modalPresentationStyle = .overFullScreen
        present(navigationController, animated: true, completion: nil)
        return navigationController
    }
}
