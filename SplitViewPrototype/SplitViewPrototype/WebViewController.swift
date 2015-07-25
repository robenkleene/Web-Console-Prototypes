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
        super.viewDidAppear()

        let heightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view(>=150)]|",
            options:NSLayoutFormatOptions(0),
            metrics:nil,
            views:["view": view])
        self.view.superview!.addConstraints(heightConstraint)
        
        let constraints = view.constraints
    }
    
    func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

}

