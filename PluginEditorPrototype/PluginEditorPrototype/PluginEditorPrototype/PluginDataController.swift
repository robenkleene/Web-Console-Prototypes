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
    lazy var duplicatePluginController = DuplicatePluginController()
    
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

    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager,
        pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: NSString)
    {
        if let oldPlugin = pluginAtPluginPath(pluginPath) {
            removePlugin(oldPlugin)
        }
        
        if let newPlugin = Plugin.pluginWithPath(pluginPath) {
            addPlugin(newPlugin)
        }
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager,
        pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: NSString)
    {
        if let oldPlugin = pluginAtPluginPath(pluginPath) {
            removePlugin(oldPlugin)
        }
    }

    
    // MARK: Add & Remove Helpers
    
    func addPlugin(plugin: Plugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary[pluginPath] = plugin
        delegate?.pluginDataController(self, didAddPlugin: plugin)
    }
    
    func removePlugin(plugin: Plugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary.removeValueForKey(pluginPath)
        delegate?.pluginDataController(self, didRemovePlugin: plugin)
    }
    
    func pluginAtPluginPath(pluginPath: NSString) -> Plugin? {
        return pluginPathToPluginDictionary[pluginPath]
    }


    // MARK: Creating New Plugins
    
    func duplicatePlugin(plugin: Plugin) {
        duplicatePluginController.duplicatePlugin(plugin,
            toDirectoryAtURL: ClassConstants.duplicatePluginDestinationDirectory.URL())
        { (plugin, error) -> Void in
            if let plugin = plugin {
                self.addPlugin(plugin)
            }
        }
    }

}
