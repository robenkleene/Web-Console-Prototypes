//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

enum PluginsDirectory {
    case ApplicationSupport
    case BuiltIn
    func path() -> String {
        switch self {
        case .ApplicationSupport:
            let pluginsPathComponent = "PlugIns"
            let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
            let nameKey = kCFBundleNameKey as NSString
            let applicationName = NSBundle.mainBundle().infoDictionary[nameKey] as NSString
            return applicationSupportPath
                .stringByAppendingPathComponent(applicationName)
                .stringByAppendingPathComponent(pluginsPathComponent)
        case .BuiltIn:
            return NSBundle.mainBundle().builtInPlugInsPath!
        }
    }
}

class PluginDataController {
    let pluginsPaths = [String]()

    init(paths: [String]) {
        self.pluginsPaths = paths
    }

    convenience init() {
        self.init(paths: [PluginsDirectory.BuiltIn.path(), PluginsDirectory.ApplicationSupport.path()])
    }

    func existingPlugins() -> [Plugin] {
        var plugins = [Plugin]()
        for pluginsPath in pluginsPaths {
            let pluginPaths = self.dynamicType.pathsForPluginsAtPath(pluginsPath)
            let newPlugins = self.dynamicType.pluginsAtPluginPaths(pluginPaths)
            plugins += newPlugins
        }
        return plugins
    }

    func newPluginFromPlugin(plugin: Plugin) -> Plugin? {
        println("Plugin.bundle.bundleURL = \(plugin.bundle.bundleURL)")
        return nil
    }
}