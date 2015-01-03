//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginManager {
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

    func pluginWithName(name: String) -> Plugin? {
        return self.nameToPluginController.objectWithName(name) as? Plugin
    }
}