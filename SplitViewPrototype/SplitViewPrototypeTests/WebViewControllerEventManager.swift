//
//  ViewControllerEventManager.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 8/3/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation

class WebViewControllerEventManager: WebViewControllerDelegate {
    typealias EventBlock = (WebViewController) -> ()
    
    weak var storedDelegate: WebViewControllerDelegate?
    var viewWillAppearBlock: EventBlock?
    var viewWillDisappearBlock: EventBlock?
    
    init(webViewController: WebViewController,
        viewWillAppearBlock: EventBlock? = nil,
        viewWillDisappearBlock: EventBlock? = nil)
    {
        self.storedDelegate = webViewController.delegate
        webViewController.delegate = self

        
        if let viewWillAppearBlock = viewWillAppearBlock {
            self.viewWillAppearBlock = { webViewController in
                viewWillAppearBlock(webViewController)
                self.storedDelegate?.webViewControllerViewWillAppear(webViewController)
                self.viewWillAppearBlock = nil
                self.blockFired(webViewController)
            }
        }
        
        if let viewWillDisappearBlock = viewWillDisappearBlock {
            self.viewWillDisappearBlock = { webViewController in
                viewWillDisappearBlock(webViewController)
                self.storedDelegate?.webViewControllerViewWillDisappear(webViewController)
                self.viewWillDisappearBlock = nil
                self.blockFired(webViewController)
            }
        }
        
    }
    
    func blockFired(webViewController: WebViewController) {
        if viewWillAppearBlock == nil && viewWillDisappearBlock == nil {
            webViewController.delegate = self.storedDelegate
        }
    }
    
    @objc func webViewControllerViewWillAppear(webViewController: WebViewController) {
        if let viewWillAppearBlock = viewWillAppearBlock {
            viewWillAppearBlock(webViewController)
        }
    }

    @objc func webViewControllerViewWillDisappear(webViewController: WebViewController) {
        if let viewWillDisappearBlock = viewWillDisappearBlock {
            viewWillDisappearBlock(webViewController)
        }
    }
    
}
