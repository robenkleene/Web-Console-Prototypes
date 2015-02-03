//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginsManager: WCLPluginsManager, PluginsDataControllerDelegate {
    
    let pluginsDataController: PluginsDataController
    
    // MARK: Singleton
    
    struct Singleton {
        static let instance: PluginsManager = PluginsManager()
        static var overrideSharedInstance: PluginsManager?
    }

    class var sharedInstance: PluginsManager {
        if let overrideSharedInstance = Singleton.overrideSharedInstance {
            return overrideSharedInstance
        }
        
        // TODO: Assert that the non-overridden instance is never returned when running tests?
        
        return Singleton.instance
    }

    class func setOverrideSharedInstance(pluginsManager: PluginsManager?) {
        Singleton.overrideSharedInstance = pluginsManager
    }

    // MARK: Init
    
    init(_ paths: [String], duplicatePluginDestinationDirectoryURL: NSURL) {
        self.pluginsDataController = PluginsDataController(paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        super.init(plugins: pluginsDataController.plugins())
        pluginsDataController.delegate = self
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


    // MARK: Convenience
    
    private func addPlugin(plugin: Plugin) {
        insertObject(plugin, inPluginsAtIndex: 0)
    }
    
    private func removePlugin(plugin: Plugin) {
        let index = pluginsController.indexOfObject(plugin)
        if index != NSNotFound {
            removeObjectFromPluginsAtIndex(UInt(index))
        }
    }
    

    // MARK: Adding and Removing Plugins
    
    func movePluginToTrash(plugin: Plugin) {
        pluginsDataController.movePluginToTrash(plugin)
    }
    
    func duplicatePlugin(plugin: Plugin, handler: ((newPlugin: Plugin?, error: NSError?) -> Void)?) {
        pluginsDataController.duplicatePlugin(plugin, handler: handler)
    }

    func newPlugin(handler: ((newPlugin: Plugin?, error: NSError?) -> Void)?) {
        // TODO: If no `defaultNewPlugin` is set it should have a (probably hardcoded) fallback, maybe HTML? And what if the HTML plugin is missing?

        if let plugin = defaultNewPlugin {
            newPluginFromPlugin(plugin, handler: handler)
        }
    }

    func newPluginFromPlugin(plugin: Plugin, handler: ((newPlugin: Plugin?, error: NSError?) -> Void)?) {
        duplicatePlugin(plugin, handler: handler)
    }


    
    // MARK: PluginsDataControllerDelegate

    func pluginsDataController(pluginsDataController: PluginsDataController, didAddPlugin plugin: Plugin) {
        addPlugin(plugin)
    }

    func pluginsDataController(pluginsDataController: PluginsDataController, didRemovePlugin plugin: Plugin) {
        if defaultNewPlugin? == plugin {
            defaultNewPlugin = nil
        }
        
        removePlugin(plugin)
    }
}