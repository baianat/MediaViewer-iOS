//
//  MutliMediaPagesViewController.swift
//  MediaViewer
//
//  Created by Omar on 21/04/2021.
//

import UIKit
import AVKit
import SafariServices

class MultiMediaPagesViewController: UIPageViewController {
    
    // MARK:- Initializers
    public static func create(for media: [String]) -> MultiMediaPagesViewController {
        let vc = MultiMediaPagesViewController.init(mediaUrls: media)
        return vc
    }
    
    public init(mediaUrls: [String]) {
        self.mediaUrls = mediaUrls
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let mediaUrls: [String]
    private var embeddedViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createEmbeddedViewControllers()
        setInitialVC()
        setupNavigationBarButtons()
        navigationItem.title = "\(1) \("of".localized) \(embeddedViewControllers.count)"

        dataSource = self
        delegate = self
    }
    
    private func createEmbeddedViewControllers() {
        for i in 0..<mediaUrls.count {
            let mediaUrl = mediaUrls[i]
            let vc: UIViewController
            if mediaUrl.isImage {
                vc = ImageViewerViewController.init(
                    withImageUrl: mediaUrl,
                    andPlaceHolderImage: nil,
                    isEmbedded: true
                )
            } else if mediaUrl.isVideo || mediaUrl.isAudio {
                guard let videoURL = URL(string: mediaUrl) else { return }
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                vc = playerViewController
            } else {
                vc = WebViewerViewController.init(
                    withUrl: mediaUrl,
                    allowDownload: true
                )
            }
            vc.view.tag = i
            embeddedViewControllers.append(vc)
        }
    }
    private func setInitialVC() {
        if let firstVC = embeddedViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupNavigationBarButtons() {
        let doneButton = UIBarButtonItem(title: "done".localized, style: .done, target: self, action: #selector(doneAction))
        navigationItem.leftBarButtonItem = doneButton
    }
    
    @objc func doneAction() {
        dismiss(animated: true, completion: nil)
    }
}

extension MultiMediaPagesViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = embeddedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard embeddedViewControllers.count > previousIndex else {
            return nil
        }
        
        return embeddedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = embeddedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = embeddedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return embeddedViewControllers[nextIndex]
    }
    
 
}
extension MultiMediaPagesViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentIndex = pageViewController.viewControllers?.first?.view.tag else { return }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "\(currentIndex + 1) \("of".localized) \(embeddedViewControllers.count)"
        
        embeddedViewControllers.compactMap({$0 as? AVPlayerViewController}).forEach({$0.player?.pause()})

    }
}
