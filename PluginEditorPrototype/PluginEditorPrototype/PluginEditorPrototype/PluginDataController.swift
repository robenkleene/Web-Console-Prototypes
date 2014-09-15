//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class PluginDataController: NSObject {
    
    func existingPlugins() -> [Plugin] {
        var plugins = [Plugin]()
        let pluginsPaths = PluginPaths.paths
        for pluginsPath in pluginsPaths {
            let pluginPaths = self.dynamicType.pluginPathsAtPluginsPath(pluginsPath)
            let newPlugins = self.dynamicType.pluginsAtPluginPaths(pluginPaths)
            plugins += newPlugins
        }
        return plugins
    }
    
    private struct Constants {
        static let pluginsPathComponent = "PlugIns"
    }
    
    private struct PluginPaths {
        private static let builtInPluginsPath = NSBundle.mainBundle().builtInPlugInsPath
        private static var applicationSupportPluginsPath: String? {
            get {
                let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
                let nameKey = kCFBundleNameKey as NSString
                let applicationName = NSBundle.mainBundle().infoDictionary[nameKey] as NSString
                return applicationSupportPath.stringByAppendingPathComponent(applicationName).stringByAppendingPathComponent(Constants.pluginsPathComponent)
            }
        }
        static var paths: [String] {
            get {
                var paths = [String]()
                if let path = builtInPluginsPath {
                    paths.append(path)
                }
                if let path = applicationSupportPluginsPath {
                    paths.append(path)
                }
                return paths
            }
        }
    }

    private class func pluginPathsAtPluginsPath(pluginsPath: String) -> [String] {
        var pluginPaths = [String]()
        
        if let pathContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pluginsPath, error:nil) {
            let pluginFileExtension = ".\(pluginsFileExtension)"
            let pluginPredicate = NSPredicate(format: "self ENDSWITH %@", pluginFileExtension)
            let pluginPathComponents = pathContents.filter {
                pluginPredicate.evaluateWithObject($0)
            }
            for pluginPathComponent in pluginPathComponents {
                if let pluginPathComponenet = pluginPathComponent as? String {
                    let pluginPath = pluginsPath.stringByAppendingPathComponent(pluginPathComponenet)
                }
            }
        }

        return pluginPaths
    }
    
    private class func pluginsAtPluginPaths(pluginPaths: [String]) -> [Plugin] {
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.pluginWithPath(pluginPath) {
                plugins.append(plugin)
            }
        }
        return plugins
    }

}