//
//  ViewController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import WebKit

@objc protocol WebViewControllerDelegate: class {
    func webViewControllerWillAppear(webViewController: WebViewController)
}

class WebViewController: NSViewController {

    @IBOutlet weak var delegate: WebViewControllerDelegate?
    
    // MARK: Life Cycle
    
    override func viewWillAppear() {
        super.viewWillAppear()
        delegate?.webViewControllerWillAppear(self)
    }
    
    // MARK: Web View
    
    var webView: WKWebView {
        return view as! WKWebView
    }
    
    override func loadView() {
        let webView = WKWebView()
        view = webView
    }

    func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

}

