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
    
    func addPlugins(plugins: [Plugin]) {
        let range = NSMakeRange(0, plugins.count)
        let indexes = NSIndexSet(indexesInRange: range)
        insertPlugins(plugins, atIndexes: indexes)
    }
    
    func removePlugin(plugin: Plugin) {
        let index = mutablePlugins.indexOfObject(plugin)
        if index != NSNotFound {
            removeObjectFromPluginsAtIndex(index)
        }
    }
    
    
    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    func plugins() -> NSArray {
        return NSArray(array: mutablePlugins)
    }
    
    func insertObject(plugin: Plugin, inPluginsAtIndex index: Int) {
        var replacedPlugin: Plugin? = nameToPluginController.addObject(plugin) as? Plugin
        mutablePlugins.insertObject(plugin, atIndex: index)
        if let replacedPlugin: Plugin = replacedPlugin {
            let index = mutablePlugins.indexOfObject(replacedPlugin)
            if index != NSNotFound {
                removeObjectFromPluginsAtIndex(index)
            }
        }
    }
    
    func insertPlugins(plugins: [Plugin], atIndexes indexes: NSIndexSet) {
        var replacedPlugins: [Plugin]? = nameToPluginController.addObjectsFromArray(plugins) as? [Plugin]
        mutablePlugins.insertObjects(plugins, atIndexes: indexes)
        if let replacedPlugins: [Plugin] = replacedPlugins {
            let indexes = mutablePlugins.indexesOfObjectsPassingTest({
                (object: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                return contains(replacedPlugins, object as Plugin)
            })
            removePluginsAtIndexes(indexes)
        }
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