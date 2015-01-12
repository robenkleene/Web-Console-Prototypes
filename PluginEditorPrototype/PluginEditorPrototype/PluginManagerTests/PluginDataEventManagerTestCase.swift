//
//  PluginDataEventManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/9/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginDataEventManager: PluginDataControllerDelegate {
    var pluginWasAddedHandlers: Array<(plugin: Plugin) -> Void>
    var pluginWasRemovedHandlers: Array<(plugin: Plugin) -> Void>
    var delegate: PluginDataControllerDelegate?
    
    init () {
        self.pluginWasAddedHandlers = Array<(plugin: Plugin) -> Void>()
        self.pluginWasRemovedHandlers = Array<(plugin: Plugin) -> Void>()
    }
    
    
    // MARK: PluginDataControllerDelegate
    
    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        delegate?.pluginDataController(pluginDataController, didAddPlugin: plugin)
        
        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasAddedHandlers.count > 0) {
            let handler = pluginWasAddedHandlers.removeAtIndex(0)
            handler(plugin: plugin)
        }
    }
    
    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        delegate?.pluginDataController(pluginDataController, didRemovePlugin: plugin)
        
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

class PluginDataEventManagerTestCase: TemporaryPluginsTestCase {
    var pluginDataEventManager: PluginDataEventManager!

    override func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
    }

    override func tearDown() {
        pluginDataEventManager = nil
        super.tearDown()
    }
}
