//
//  WebSplitViewController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import WebKit

class PluginViewController: NSSplitViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad")
        NSLog("splitView = \(splitView)")
        NSLog("splitView.delegate = \(splitView.delegate)")
    }

    override func splitViewDidResizeSubviews(notification: NSNotification) {
        super.splitViewDidResizeSubviews(notification)
        NSLog("splitViewDidResizeSubviews")
    }

    override func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        NSLog("constrainMaxCoordinate")
        return proposedMaximumPosition
    }
    
    override func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        NSLog("constrainMinCoordinate")
        return proposedMinimumPosition
    }
    
    func splitView(splitView: NSSplitView,
        constrainMinCoordinat proposedMinimumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int) -> CGFloat
    {
//            if (proposedMinimumPosition < 75) {
//                proposedMinimumPosition = 75;
//            }
//            return proposedMinimumPosition;    

NSLog("dividerIndex = \(dividerIndex)")
        
        return proposedMinimumPosition + 200
    }
    
}
