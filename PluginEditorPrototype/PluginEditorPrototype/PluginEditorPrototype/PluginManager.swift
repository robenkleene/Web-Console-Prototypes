//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginManager: PluginDataControllerDelegate {
    private let nameToPluginController: WCLKeyToObjectController
    let pluginDataController: PluginDataController
    
    class var sharedInstance : PluginManager {
        struct Singleton {
            static let instance : PluginManager = PluginManager()
        }
        return Singleton.instance
    }
    
    init(_ paths: [String], duplicatePluginDestinationDirectoryURL: NSURL) {
        self.pluginDataController = PluginDataController(paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        self.nameToPluginController = WCLKeyToObjectController(key: pluginNameKey, objects: pluginDataController.plugins())
        pluginDataController.delegate = self
    }
    
    convenience init() {
        self.init([Directory.BuiltInPlugins.path(), Directory.ApplicationSupportPlugins.path()], duplicatePluginDestinationDirectoryURL: Directory.ApplicationSupportPlugins.URL())
    }

    
    // MARK: Accessing Plugins
    
    func plugins() -> [Plugin] {
        return nameToPluginController.allObjects() as [Plugin]!
    }
    
    func pluginWithName(name: String) -> Plugin? {
        return nameToPluginController.objectWithKey(name) as? Plugin
    }


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
        addPlugin(plugin)
    }

    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        removePlugin(plugin)
    }

    // MARK: Private add helper

    private func addPlugin(plugin: Plugin) {
        if let existingPlugin: Plugin = nameToPluginController.objectWithKey(plugin.name) as? Plugin {
            nameToPluginController.removeObject(existingPlugin)
        }
        
        nameToPluginController.addObject(plugin)
    }

    private func removePlugin(plugin: Plugin) {
        if let existingPlugin: Plugin = nameToPluginController.objectWithKey(plugin.name) as? Plugin {
            if existingPlugin == plugin {
                nameToPluginController.removeObject(plugin)
            }
        }
    }
}