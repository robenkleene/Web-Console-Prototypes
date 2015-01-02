//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa



class PluginDataController {
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
