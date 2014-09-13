//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

let pluginManagerSharedInstance = PluginManager()

class PluginManager: NSObject {
    func addedPlugin(path: String) -> Plugin? {
        return nil
    }
}

extension PluginManager {
    struct Constants {
        static let pluginsPathComponent = "PlugIns"
    }
    
    func loadPlugins() {
        let pluginsPaths = self.dynamicType.pluginsPaths()
        for pluginPath in pluginsPaths {
            loadPlugins(pluginPath)
        }
    }
    
    private func loadPlugins(pluginsPath: String) {
        let pluginFileExtension = ".\(pluginsFileExtension)"
        let pluginPredicate = NSPredicate(format: "self ENDSWITH \(pluginFileExtension)")
        if let paths = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pluginsPath, error:nil) {
            let pluginPathComponents = paths.filter {
                pluginPredicate.evaluateWithObject($0)
            }
            for pluginPathComponent in pluginPathComponents {
                if let pluginPathComponenet = pluginPathComponent as? String {
                    let pluginPath = pluginsPath.stringByAppendingPathComponent(pluginPathComponenet)
                    addedPlugin(pluginPath)
                }
            }
        }
        
    }
    
    private class func pluginsPaths() -> Array<String> {
        var pluginsPaths = [String]()
        if let path = builtInPluginsPath() {
            pluginsPaths.append(path)
        }
        if let path = applicationSupportPluginsPath() {
            pluginsPaths.append(path)
        }
        return pluginsPaths
    }
    
    private class func builtInPluginsPath() -> String? {
        return NSBundle.mainBundle().builtInPlugInsPath
    }
    
    private class func applicationSupportPluginsPath() -> String? {
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary[nameKey] as NSString
        
        return applicationSupportPath.stringByAppendingPathComponent(applicationName).stringByAppendingPathComponent(Constants.pluginsPathComponent)
    }
}

