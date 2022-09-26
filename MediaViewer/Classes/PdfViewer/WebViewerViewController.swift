//
//  PdfViewerViewController.swift
//  Utils
//
//  Created by Omar on 2/22/21.
//  Copyright © 2021 Baianat. All rights reserved.
//

import UIKit
import WebKit
import PDFKit

public protocol WebViewerViewControllerDelegate: class {
    func webViewerViewController(_ webViewerViewController: WebViewerViewController, didDownloadFileInto downloadedFileURL: URL)
    func webViewerViewController(_ webViewerViewController: WebViewerViewController, didFailDownloadingWithError error: Error)
    func webViewerViewControllerWasDismissed(_ webViewerViewController: WebViewerViewController)
}
public extension WebViewerViewControllerDelegate {
    func webViewerViewController(_ webViewerViewController: WebViewerViewController, didDownloadFileInto downloadedFileURL: URL) {}
    func webViewerViewController(_ webViewerViewController: WebViewerViewController, didFailDownloadingWithError error: Error) {}
    func webViewerViewControllerWasDismissed(_ webViewerViewController: WebViewerViewController) {}
}

public class WebViewerViewController: UIViewController {
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(withUrl url: String, allowDownload: Bool) {
        self.url = url
        self.allowDownload = allowDownload
        super.init(
            nibName: String(describing: WebViewerViewController.self),
            bundle: Bundle.init(for: WebViewerViewController.self)
        )
    }
    
    // MARK:- Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK:- BarButtons
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
    
    public weak var delegate: WebViewerViewControllerDelegate?
    private let url: String
    private let allowDownload: Bool
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        displayData()
        setupNavigationBar()
    }
    private func displayData() {
        handlePdfDisplay()
        handleWebpageDisplay()
    }
    private func handlePdfDisplay() {
        guard url.isPdf else { return }
        webView.isHidden = true
        
        let pdfUrl = URL(string: url)
        let pdfData = try? Data.init(contentsOf: pdfUrl!)
        let resourceDocPath = (FileManager.default.temporaryDirectory) as URL
        let pdfNameFromUrlArr = url.components(separatedBy: "/")
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrlArr.last ?? appSignature())
        do {
            _ = try pdfData?.write(to: actualPath, options: .atomic)
        } catch{
            print("Pdf can't be saved")
        }
        if let document = PDFDocument(url: actualPath) {
            pdfView.document = document
        }
        // set scale
        if let document = pdfView.document, let page = document.page(at: 0) {
            let pageBounds = page.bounds(for: pdfView.displayBox)
            pdfView.scaleFactor = (pdfView.bounds.width / pageBounds.width)

        }
    }
    private func handleWebpageDisplay() {
        guard !url.isPdf else { return }
        pdfView.isHidden = true
        if let fileUrl = URL(string: url) {
            let myDocument = URLRequest(url: fileUrl)
            activityIndicator.startAnimating()
            navigationItem.title = fileUrl.lastPathComponent
            webView.load(myDocument)
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.navigationDelegate = self
        }
    }
    
    private func setupNavigationBar() {
        if allowDownload {
            self.navigationItem.rightBarButtonItems = [saveBarButton]
        }
        
        self.navigationItem.leftBarButtonItems = [doneBarButton]
    }
    @objc func moreAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let downloadAction = UIAlertAction(title: "save".localized,
                                           style: .default) { (_) in
            self.downloadFile()
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
            self.delegate?.webViewerViewControllerWasDismissed(self)
        }
    }
    private func downloadFile() {
        let fileURL = URL(string: url)
        self.navigationItem.rightBarButtonItems = [spinnerBarButton]
        DispatchQueue.global().async {
            let pdfData = try? Data.init(contentsOf: fileURL!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrlArr = self.url.components(separatedBy: "/")
            
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrlArr.last ?? self.appSignature())
            
            do {
                _ = try pdfData?.write(to: actualPath, options: .atomic)
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItems = [self.saveBarButton]
                    self.delegate?.webViewerViewController(self, didDownloadFileInto: actualPath)
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.delegate?.webViewerViewController(self, didFailDownloadingWithError: error)
                    self.navigationItem.rightBarButtonItems = [self.saveBarButton]
                }
            }
        }
    }
    
    private func appSignature() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MMM.yyyy.HH:mm:ss"
        let date = formatter.string(from: Date())
        return "\(appName()) \(date).pdf"
    }
    private func appName() -> String {
        (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
    }
}

extension WebViewerViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        webView.isHidden = false
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
}
