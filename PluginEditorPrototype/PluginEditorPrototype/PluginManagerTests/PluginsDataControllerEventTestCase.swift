//
//  PluginDataEventManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/9/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginDataEventManager: PluginsDataControllerDelegate {
    var pluginWasAddedHandlers: Array<(plugin: Plugin) -> Void>
    var pluginWasRemovedHandlers: Array<(plugin: Plugin) -> Void>
    var delegate: PluginsDataControllerDelegate?
    
    init () {
        self.pluginWasAddedHandlers = Array<(plugin: Plugin) -> Void>()
        self.pluginWasRemovedHandlers = Array<(plugin: Plugin) -> Void>()
    }
    
    
    // MARK: PluginsDataControllerDelegate
    
    func pluginsDataController(pluginsDataController: PluginsDataController, didAddPlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController, didAddPlugin: plugin)
        
        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasAddedHandlers.count > 0) {
            let handler = pluginWasAddedHandlers.removeAtIndex(0)
            handler(plugin: plugin)
        }
    }
    
    func pluginsDataController(pluginsDataController: PluginsDataController, didRemovePlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController, didRemovePlugin: plugin)
        
        assert(pluginWasRemovedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasRemovedHandlers.count > 0) {
            let handler = pluginWasRemovedHandlers.removeAtIndex(0)
            handler(plugin: plugin)
        }
    }
    
    // MARK: Handlers
    
    func addPluginWasAddedHandler(handler: (plugin: Plugin) -> Void) {
        pluginWasAddedHandlers.append(handler)
    }
    
    func addPluginWasRemovedHandler(handler: (plugin: Plugin) -> Void) {
        pluginWasRemovedHandlers.append(handler)
    }
    
}


class PluginsDataControllerEventTestCase: PluginsManagerTestCase {
    var pluginDataEventManager: PluginDataEventManager!
    
    override func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
        pluginDataEventManager.delegate = PluginsManager.sharedInstance
        PluginsManager.sharedInstance.pluginsDataController.delegate = pluginDataEventManager
    }
    
    override func tearDown() {
        PluginsManager.sharedInstance.pluginsDataController.delegate = PluginsManager.sharedInstance
        pluginDataEventManager.delegate = nil
        pluginDataEventManager = nil
        super.tearDown()
    }
}
