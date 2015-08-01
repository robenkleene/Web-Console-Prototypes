//
//  PluginWindowsController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 8/1/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import AppKit

class PluginsWindowController {
    var windowControllers: [NSWindowController] = [NSWindowController]()
    
    @IBAction func makePluginWindow(sender: AnyObject?) {
        
    }
    
    func addWindowController(windowController: NSWindowController) {
        windowControllers.append(windowController)
    }

    func removeWindowController(windowController: NSWindowController) {
        var index = find(windowControllers, windowController)
        if let index = index {
            windowControllers.removeAtIndex(index)
        }
    }
}