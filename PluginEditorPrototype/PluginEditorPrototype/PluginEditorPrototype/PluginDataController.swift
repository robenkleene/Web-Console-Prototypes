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
    lazy var pluginDuplicateController = PluginDuplicateController()
    
    struct ClassConstants {
        static let duplicatePluginDestinationDirectory = Directory.ApplicationSupportPlugins
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

    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: NSString) {
        if let oldPlugin = removedPluginAtPluginPath(pluginPath) {
            delegate?.pluginDataController(self, didRemovePlugin: oldPlugin)
        }

        if let newPlugin = addedPluginAtPluginPath(pluginPath) {
            delegate?.pluginDataController(self, didAddPlugin: newPlugin)
        }
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: NSString) {
        if let oldPlugin = removedPluginAtPluginPath(pluginPath) {
            delegate?.pluginDataController(self, didRemovePlugin: oldPlugin)
        }
    }

    
    // MARK: Add & Remove Helpers
    
    func addedPluginAtPluginPath(pluginPath: NSString) -> Plugin? {
        if let plugin = Plugin.pluginWithPath(pluginPath) {
            pluginPathToPluginDictionary[pluginPath] = plugin
            return plugin
        }
        return nil
    }
    
    func removedPluginAtPluginPath(pluginPath: NSString) -> Plugin? {
        if let plugin = pluginPathToPluginDictionary[pluginPath] {
            pluginPathToPluginDictionary.removeValueForKey(pluginPath)
            return plugin
        }
        
        return nil
    }
    

    // MARK: Creating New Plugins
    
    func newPluginFromPlugin(plugin: Plugin) {
        newPluginFromPlugin(plugin, inDirectoryAtURL: ClassConstants.duplicatePluginDestinationDirectory.URL())
    }

    private func newPluginFromPlugin(plugin: Plugin, inDirectoryAtURL dstURL: NSURL) {
        pluginDuplicateController.duplicatePlugin(plugin, toDirectoryAtURL: dstURL)
    }
}
