//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginManager: NSObject {
    let nameToPluginController: WCLKeyToObjectController
    let pluginDataController = PluginDataController()
    
    override init() {
        self.nameToPluginController = WCLKeyToObjectController(objects: pluginDataController.existingPlugins())
    }
//    func pluginWithName(name: String) -> Plugin? {
//        return self.nameToPluginController.pluginWithName(name)
//    }
}