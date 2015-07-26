//
//  ViewController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import WebKit

class SplitWebView: WKWebView {
    override func viewDidMoveToSuperview() {
        if let superview = superview {
            let heightConstraint =  NSLayoutConstraint(item: self,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: 150)
            superview.addConstraint(heightConstraint)
        }
    }
}

class WebViewController: NSViewController {

    var webView: SplitWebView {
        return view as! SplitWebView
    }
    
    override func loadView() {
        let webView = SplitWebView()
        view = webView
    }

    func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

}

