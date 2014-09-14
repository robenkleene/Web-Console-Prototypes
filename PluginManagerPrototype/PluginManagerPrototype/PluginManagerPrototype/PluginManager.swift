//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginManager: NSObject {
    class var sharedInstance : PluginManager {
        struct Singleton {
            static let instance : PluginManager = PluginManager()
        }
        return Singleton.instance
    }
    
    var nameToPlugin: [String : Plugin]
    override init() {
        self.nameToPlugin = [String : Plugin]()
    }
    
    func addedPlugin(path: String) -> Plugin? {
        if let plugin = Plugin.pluginWithPath(path) {
            nameToPlugin[plugin.name] = plugin
        }
        return nil
    }

    func plugin(name: String) -> Plugin? {
        let plugin = nameToPlugin[name]
        return plugin
    }
    
    func plugins() -> [Plugin] {
        // TODO Why can't I do something like this? `return nameToPlugin.values as [Plugin]`
        
        var plugins = [Plugin]()
        let values = nameToPlugin.values
        for value in values {
            plugins.append(value)
        }
        return plugins
    }
}