//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginsManager: WCLPluginsManager, PluginDataControllerDelegate {

    private let pluginsController: MultiCollectionController
    
    let pluginDataController: PluginDataController
    
    // MARK: Singleton
    
    struct Singleton {
        static let instance: PluginsManager = PluginsManager()
        static var overrideSharedInstance: PluginsManager?
    }

    class var sharedInstance: PluginsManager {
        if let overrideSharedInstance = Singleton.overrideSharedInstance {
            return overrideSharedInstance
        }
        
        // TODO: Assert that the non-overridden instance is never returned when running tests
        
        return Singleton.instance
    }

    // MARK: Init
    
    class func setOverrideSharedInstance(pluginsManager: PluginsManager?) {
        Singleton.overrideSharedInstance = pluginsManager
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
        for object: AnyObject in allPlugins {
            if let plugin: Plugin = object as? Plugin {
                if plugin.identifier == identifier {
                    return plugin
                }
            }
        }
        return nil
    }


    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    // TODO: This should return an NSArray
    func plugins() -> NSArray {
        return pluginsController.objects()
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
        // TODO: Need an error handler for no default new plugin, it should just use a hardcoded backup if no default is set, probably HTML? What if the HTML plugin is missing too?
        if let plugin = defaultNewPlugin {
            duplicatePlugin(plugin, handler: handler)
        }
    }

    
    // MARK: PluginDataControllerDelegate

    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        pluginsController.addObject(plugin)
    }

    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        pluginsController.removeObject(plugin)
    }
}