//
//  PluginDataController+PluginPaths.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

extension PluginDataController {
    class func pathsForPluginsAtPath(pluginsPath: String) -> [String] {
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
                    pluginPaths.append(pluginPath)
                }
            }
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