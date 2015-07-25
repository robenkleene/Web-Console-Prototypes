//
//  ViewController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {

    var webView: WKWebView {
        return view as! WKWebView
    }
    
    
    override func loadView() {
        let webView = WKWebView()
        view = webView
    }

    
    override func viewDidAppear() {
        let constraints = view.constraints
        NSLog("BEGIN")
        for constraint in constraints {
            NSLog("constraint = \(constraint)")
        }
        NSLog("END")
    }
    
    func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }


}

