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
    private let pluginDataController: PluginDataController
    
    class var sharedInstance : PluginManager {
        struct Singleton {
            static let instance : PluginManager = PluginManager()
        }
        return Singleton.instance
    }
    
    init(_ paths: [String]) {
        self.pluginDataController = PluginDataController(paths)
        self.nameToPluginController = WCLKeyToObjectController(key: pluginNameKey, objects: pluginDataController.plugins())
    }
    
    convenience init() {
        self.init([Directory.BuiltInPlugins.path(), Directory.ApplicationSupportPlugins.path()])
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

    // MARK: PluginDataControllerDelegate

    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        self.nameToPluginController.addObject(plugin)
    }

    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        self.nameToPluginController.removeObject(plugin)
    }

}