//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa



class PluginDataController {
    // TODO BEGIN extension PluginDataController+PluginPaths
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
    // TODO END extension PluginDataController+PluginPaths

    let pluginsPaths = [String]()
    lazy var pluginCopyController = PluginCopyController()
    lazy var copyPluginDirectory = Directory.ApplicationSupportPlugins
    
    init(_ paths: [String]) {
        self.pluginsPaths = paths
    }

    func existingPlugins() -> [Plugin] {
        let pluginPaths = self.dynamicType.pathsForPluginsAtPaths(pluginsPaths)
        return self.dynamicType.pluginsAtPluginPaths(pluginPaths)
    }

    func newPluginFromPlugin(plugin: Plugin) {
        newPluginFromPlugin(plugin, inDirectoryAtURL: copyPluginDirectory.URL())
    }

    private func newPluginFromPlugin(plugin: Plugin, inDirectoryAtURL dstURL: NSURL) {
        pluginCopyController.copyPlugin(plugin, toDirectoryAtURL: dstURL)
    }
}