//
//  PluginWindowController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 8/1/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import AppKit

protocol PluginWindowControllerDelegate {
    func pluginWindowControllerWindowDidClose(pluginWindowController: PluginWindowController)
}

class PluginWindowController: NSWindowController, NSWindowDelegate {
    var delegate: PluginWindowControllerDelegate?
    
    func windowWillClose(notification: NSNotification) {
        delegate?.pluginWindowControllerWindowDidClose(self)
    }
}