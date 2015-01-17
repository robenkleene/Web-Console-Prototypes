//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginManager: WCLPluginManager, PluginDataControllerDelegate {

    private let pluginsController: MultiCollectionController
    
    let pluginDataController: PluginDataController
    
    class var sharedInstance : PluginManager {
        struct Singleton {
            static let instance : PluginManager = PluginManager()
        }
        return Singleton.instance
    }
    
    init(_ paths: [String], duplicatePluginDestinationDirectoryURL: NSURL) {
        self.pluginDataController = PluginDataController(paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        self.pluginsController = MultiCollectionController(pluginDataController.plugins(), key:pluginNameKey)
        super.init()
        pluginDataController.delegate = self
    }
    
    convenience override init() {
        self.init([Directory.BuiltInPlugins.path(), Directory.ApplicationSupportPlugins.path()], duplicatePluginDestinationDirectoryURL: Directory.ApplicationSupportPlugins.URL())
    }

    
    // MARK: Accessing Plugins
    
    func pluginWithName(name: String) -> Plugin? {
        return pluginsController.objectWithKey(name) as Plugin?
    }
    
    func pluginWithIdentifier(identifier: String) -> Plugin? {
        let allPlugins = plugins()
        for plugin in allPlugins {
            if plugin.identifier == identifier {
                return plugin
            }
        }
        return nil
    }


    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    // TODO: This should return an NSArray
    func plugins() -> [Plugin] {
        return pluginsController.objects() as [Plugin]
    }
    
    // TODO: Implement rest of KVC To-Many Relationship methods
    
    
    // MARK: Adding and Removing Plugins
    
    func movePluginToTrash(plugin: Plugin) {
        pluginDataController.movePluginToTrash(plugin)
    }
    
    func duplicatePlugin(plugin: Plugin, handler: ((newPlugin: Plugin?) -> Void)?) {
        pluginDataController.duplicatePlugin(plugin, handler: handler)
    }

    func newPlugin(handler: ((newPlugin: Plugin?) -> Void)?) {
        // TODO: This needs to use default new plugin
    }

    
    // MARK: PluginDataControllerDelegate

    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        pluginsController.addObject(plugin)
    }

    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        pluginsController.removeObject(plugin)
    }
}