//
//  ViewController.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 01/01/23.
//

import UIKit
import WebKit

let BASE_URL_WEB_WALLET = "https://wallet.consolelabs.in";
//let BASE_URL_WEB_WALLET = "https://3b24-2405-201-4002-1ec8-b4d7-7b52-1bd2-cb09.in.ngrok.io";
class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var webViewUrlObserver: NSKeyValueObservation?
//    var progressView: UIProgressView

    @IBOutlet weak var progressbar: UIProgressView!
    override func loadView() {
        super.loadView()
//        view = webView
    }

    override func viewDidLoad() {
        webView = WKWebView()
        webView.navigationDelegate = self
//        progressView = UIProgressView(progressViewStyle: .default)
//        progressView.sizeToFit()
        super.viewDidLoad()
        let url = URL(string: BASE_URL_WEB_WALLET)!
        webView.load(URLRequest(url: url))
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWebView(_:)), name: .reload, object: nil)

        webViewUrlObserver = webView.observe(\.url, options: .new){webView, change in

            if (change.newValue??.absoluteString == "\(BASE_URL_WEB_WALLET)/scan") {

                self.performSegue(withIdentifier: "goToScanner", sender: [webView: webView])
            }
        }

        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);

    }
    
    @objc func reloadWebView(_ notification: Notification)  {
        print(notification.userInfo)
        if let urlString = notification.userInfo?["urlString"] {
            print("urlString: ", urlString)
            let url = URL(string: urlString as! String)!
            webView.load(URLRequest(url: url))
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            print("estimated progress: \(self.webView.estimatedProgress)")
            if let progress = Optional(self.webView.estimatedProgress) {
                progressbar.progress = Float(progress)
            }
            
            if (self.webView.estimatedProgress == 1.0) {
                replaceProgressView()
            }
        }
    }
    
    func replaceProgressView(){
        print("testing")
        view = webView
    }


}

extension Notification.Name {
     static let reload = Notification.Name("reload")
//     static let argentina = Notification.Name("argentina")
}
