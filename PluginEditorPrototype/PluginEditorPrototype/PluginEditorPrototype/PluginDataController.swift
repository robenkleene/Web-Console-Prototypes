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
    func URL() -> NSURL {
        return NSURL(fileURLWithPath: self.path())
    }

}

class PluginDataController {
    let pluginsPaths = [String]()
    lazy var pluginCopyController = PluginCopyController()
    lazy var copyPluginDirectory = PluginsDirectory.ApplicationSupport
    
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
        pluginCopyController.copyPlugin(plugin, toURL: dstURL)
    }
}