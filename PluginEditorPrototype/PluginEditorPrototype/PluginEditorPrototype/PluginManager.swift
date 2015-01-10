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
        return self.nameToPluginController.allObjects() as [Plugin]!
    }
    
    func pluginWithName(name: String) -> Plugin? {
        return self.nameToPluginController.objectWithName(name) as? Plugin
    }


    // MARK: Adding and Removing Plugins
    
    func removePlugin(plugin: Plugin) {
        self.pluginDataController.movePluginToTrash(plugin)
    }
    
    func duplicatePlugin(plugin: Plugin, handler: ((newPlugin: Plugin?) -> Void)?) {
        self.pluginDataController.duplicatePlugin(plugin, handler: handler)
    }

    func newPlugin(handler: ((newPlugin: Plugin?) -> Void)?) {
        // TODO: This needs to use default new plugin
    }
    
    // MARK: PluginDataControllerDelegate

    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        self.nameToPluginController.addObject(plugin)
    }

    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        self.nameToPluginController.removeObject(plugin)
    }

}