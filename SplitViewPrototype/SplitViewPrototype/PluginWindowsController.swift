//
//  PluginWindowsController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 8/1/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import AppKit

class PluginsWindowController: PluginWindowControllerDelegate {
    var pluginWindowControllers: [PluginWindowController] = [PluginWindowController]()

    static let sharedInstance = PluginsWindowController()

    // `private` forces use of the singleton
    private init() {
        
    }
    
    func openNewPluginWindow() {
        let pluginWindowController = addedPluginWindowController()
        pluginWindowController.showWindow(nil)
    }
    
    private func addedPluginWindowController() -> PluginWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let pluginWindowController = storyboard.instantiateControllerWithIdentifier("PluginWindow") as! PluginWindowController
        pluginWindowController.delegate = self
        addPluginWindowController(pluginWindowController)
        return pluginWindowController
    }
    
    private func addPluginWindowController(pluginWindowController: PluginWindowController) {
        pluginWindowControllers.append(pluginWindowController)
    }

    private func removePluginWindowController(pluginWindowController: PluginWindowController) {
        var index = find(pluginWindowControllers, pluginWindowController)
        if let index = index {
            pluginWindowControllers.removeAtIndex(index)
        }
    }

    // MARK: PluginWindowControllerDelegate
    
    func pluginWindowControllerWindowDidClose(pluginWindowController: PluginWindowController) {
        removePluginWindowController(pluginWindowController)
    }
}