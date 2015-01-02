//
//  PluginDataController+Paths.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

extension PluginDataController {
    class func pathsForPluginsAtPath(paths: String) -> [String] {
        var pluginPaths = [String]()
        
        if let pathContents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(paths, error:nil) {
            let fileExtension = ".\(pluginFileExtension)"
            if let pluginPredicate = NSPredicate(format: "self ENDSWITH %@", fileExtension) {
                let pluginPathComponents = pathContents.filter {
                    pluginPredicate.evaluateWithObject($0)
                }
                for pluginPathComponent in pluginPathComponents {
                    if let pluginPathComponenet = pluginPathComponent as? String {
                        let pluginPath = paths.stringByAppendingPathComponent(pluginPathComponenet)
                        pluginPaths.append(pluginPath)
                    }
                }
            }
        }
        
        return pluginPaths
    }
    
    class func pathsForPluginsAtPaths(paths: [String]) -> [String] {
        var pluginPaths = [String]()
        for path in paths {
            pluginPaths += self.pathsForPluginsAtPath(path)
        }
        return pluginPaths
    }
    
    class func pluginsAtPluginPaths(pluginPaths: [String]) -> [Plugin] {
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.pluginWithPath(pluginPath) {
                plugins.append(plugin)
            }
        }
        return plugins
    }
}
