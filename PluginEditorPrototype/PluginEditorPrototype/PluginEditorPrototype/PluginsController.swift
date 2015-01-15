//
//  PluginsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

class PluginsController {
    private let nameToPluginController: WCLKeyToObjectController
    private var mutablePlugins = NSMutableArray()
    
    init(_ plugins: [Plugin]) {
        self.nameToPluginController = WCLKeyToObjectController(key: pluginNameKey, objects: plugins)
        self.mutablePlugins.addObjectsFromArray(plugins)
    }
    
    // MARK: Accessing Plugins
    
    func pluginWithName(name: String) -> Plugin? {
        return nameToPluginController.objectWithKey(name) as? Plugin
    }
    
    func pluginWithIdentifier(identifier: String) -> Plugin? {
        let allPlugins = mutablePlugins as NSArray as [Plugin]
        for plugin in allPlugins {
            if plugin.identifier == identifier {
                return plugin
            }
        }
        return nil
    }


    // MARK: Convenience
    
    func addPlugin(plugin: Plugin) {
        insertObject(plugin, inPluginsAtIndex: 0)
    }
    
    
    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    func plugins() -> NSArray {
        return NSArray(array: mutablePlugins)
    }
    
    func insertObject(plugin: Plugin, inPluginsAtIndex index: Int) {
        nameToPluginController.addObject(plugin)
        mutablePlugins.insertObject(plugin, atIndex: index)
    }
    
    func insertPlugins(plugins: [Plugin], atIndexes indexes: NSIndexSet) {
        nameToPluginController.addObjectsFromArray(plugins)
        mutablePlugins.insertObjects(plugins, atIndexes: indexes)
    }

    func removeObjectFromPluginsAtIndex(index: Int) {
        let plugin = mutablePlugins.objectAtIndex(index) as Plugin
        nameToPluginController.removeObject(plugin)
        mutablePlugins.removeObjectAtIndex(index)
    }
    
    func removePluginsAtIndexes(indexes: NSIndexSet) {
        let plugins = mutablePlugins.objectsAtIndexes(indexes)
        nameToPluginController.removeObjectsFromArray(plugins)
        mutablePlugins.removeObjectsAtIndexes(indexes)
    }

}