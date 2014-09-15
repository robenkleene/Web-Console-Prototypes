//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class Plugin: NSObject {
    private let pluginNameKey = "WCName"
    private let bundle: NSBundle
    var name: String {
        set {
            // TODO Implement
        }
        get {
            return bundle.infoDictionary[pluginNameKey] as NSString
        }
    }
    
    private init(_ bundle: NSBundle) {
        self.bundle = bundle
    }

    class func pluginWithPath(path: String) -> Plugin? {
        if let bundle = NSBundle(path: path) as NSBundle? {
            let plugin = Plugin(bundle)
            if (countElements(plugin.name) > 0) {
               return plugin
            }
        }
        println("Failed to load a plugin at path \(path)")
        return nil
    }
    
}
