//
//  ViewController.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 01/01/23.
//

import UIKit
import WebKit

let BASE_URL_WEB_WALLET = "https://wallet.consolelabs.in";

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var webViewUrlObserver: NSKeyValueObservation?
    var fcmToken: String?
    var url: URL = URL(string: BASE_URL_WEB_WALLET)!
    var networkManager = NetworkManager()

    @IBOutlet weak var progressbar: UIProgressView!
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        webView = WKWebView()
        webView.navigationDelegate = self
        networkManager.delegate = self
        super.viewDidLoad()

        setupWKWebview()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWebView(_:)), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.storeFcmToken(_:)), name: .fcmToken, object: nil)

        webViewUrlObserver = webView.observe(\.url, options: .new){webView, change in

            if (change.newValue??.absoluteString == "\(BASE_URL_WEB_WALLET)/scan") {

                self.performSegue(withIdentifier: "goToScanner", sender: [webView: webView])
            }
        }

        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);

    }
    
    @objc func reloadWebView(_ notification: Notification)  {
        if let urlString = notification.userInfo?["urlString"] {
            let url = URL(string: urlString as! String)!
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc func storeFcmToken(_ notification: Notification) {
        self.fcmToken = notification.userInfo?["fcmToken"] as? String ?? "";
        webView.load(URLRequest(url: url))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {

            if let progress = Optional(self.webView.estimatedProgress) {
                progressbar.progress = Float(progress)
            }
            
            if (self.webView.estimatedProgress == 1.0) {
                replaceProgressView()
            }
        }
    }
    
    func replaceProgressView(){
        view = webView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToScanner") {
            let scannerView = segue.destination as! ScannerView
            scannerView.webView = webView
        }
    }
}

extension ViewController: WKScriptMessageHandler, NetworkManagerDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if let username = message.body as? String, let token = fcmToken {

            networkManager.createUserSubscription(username: username, token: token)

        }
    }
    
    func didCreateUserSubscribition(success: Bool) {
            print("user subscribition created ")
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
            let userController = WKUserContentController()
            userController.add(self, name: "observer")
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = userController
            return configuration
        }
    
    private func setupWKWebview() {
           self.webView = WKWebView(
               frame: self.view.bounds,
               configuration: self.getWKWebViewConfiguration()
           )
       }
}

