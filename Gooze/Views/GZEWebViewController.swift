//
//  GZEWebViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/16/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import WebKit
import ReactiveSwift
import ReactiveCocoa
import SwiftOverlays

class GZEWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    weak var delegate: GZEDismissVCDelegate?
    var viewModel: GZEWebViewModel!

    var webView: WKWebView!

    @IBOutlet weak var closeButtonView: UIImageView!
    @IBOutlet weak var titleLabel: GZELabel!
    @IBOutlet weak var webViewContainer: UIView!

    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterfaceObjects()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects(){
        self.titleLabel.setWhiteFontFormat()

        self.closeButtonView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onCloseTapped))
        )

        // WebView
        webView.load(self.viewModel.urlRequest)

        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        webViewContainer.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        webViewContainer.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
        webViewContainer.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true

        SwiftOverlays.showCenteredWaitOverlay(self.webViewContainer)
    }

    func setupBindings() {
        self.titleLabel.reactive.text <~ self.viewModel.titleLabelText
    }

    func onCloseTapped() {
        self.delegate?.onDismissTapped()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // WKNavigationDelegate
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //SwiftOverlays.showCenteredWaitOverlay(self.webViewContainer)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SwiftOverlays.removeAllOverlaysFromView(self.webViewContainer)
    }
}
