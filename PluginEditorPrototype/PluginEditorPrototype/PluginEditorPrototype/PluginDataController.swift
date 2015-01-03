//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

protocol PluginDataControllerDelegate {
    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin)
    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin)
}

class PluginDataController: PluginsDirectoryManagerDelegate {
    var delegate: PluginDataControllerDelegate?
    var pluginDirectoryManagers: [PluginsDirectoryManager]!
    var pluginPathToPluginDictionary: [NSString : Plugin]!
    lazy var pluginCopyController = PluginCopyController()
    
    struct ClassConstants {
        static let copyPluginDestinationDirectory = Directory.ApplicationSupportPlugins
    }
    
    init(_ paths: [String]) {
        self.pluginDirectoryManagers = [PluginsDirectoryManager]()
        self.pluginPathToPluginDictionary = [NSString : Plugin]()

        for path in paths {
            let plugins = self.dynamicType.pluginsAtPluginsPath(path)
            for plugin in plugins {
                pluginPathToPluginDictionary[plugin.bundle.bundlePath] = plugin
            }
            if let pluginsDirectoryURL = NSURL(fileURLWithPath: path) {
                let pluginDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: pluginsDirectoryURL)
                pluginDirectoryManager.delegate = self
                pluginDirectoryManagers.append(pluginDirectoryManager)
            }
        }
    }


    // MARK: Plugins
    
    func plugins() -> [Plugin] {
        return Array(pluginPathToPluginDictionary.values)
    }
    

    // MARK: PluginsDirectoryManagerDelegate

    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath path: NSString) {
        
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath path: NSString) {
        
    }

    
    // MARK: Creating New Plugins
    
    func newPluginFromPlugin(plugin: Plugin) {
        newPluginFromPlugin(plugin, inDirectoryAtURL: ClassConstants.copyPluginDestinationDirectory.URL())
    }

    private func newPluginFromPlugin(plugin: Plugin, inDirectoryAtURL dstURL: NSURL) {
        pluginCopyController.copyPlugin(plugin, toDirectoryAtURL: dstURL)
    }
}
