//
//  PluginManager.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

protocol PluginsDataControllerDelegate {
    func pluginsDataController(pluginsDataController: PluginsDataController, didAddPlugin plugin: Plugin)
    func pluginsDataController(pluginsDataController: PluginsDataController, didRemovePlugin plugin: Plugin)
}


class PluginsDataController: PluginsDirectoryManagerDelegate {
    var delegate: PluginsDataControllerDelegate?
    var pluginDirectoryManagers: [PluginsDirectoryManager]!
    var pluginPathToPluginDictionary: [NSString : Plugin]!
    lazy var duplicatePluginController = DuplicatePluginController()
    let duplicatePluginDestinationDirectoryURL: NSURL
    
    init(_ paths: [String], duplicatePluginDestinationDirectoryURL: NSURL) {
        self.pluginDirectoryManagers = [PluginsDirectoryManager]()
        self.pluginPathToPluginDictionary = [NSString : Plugin]()
        self.duplicatePluginDestinationDirectoryURL = duplicatePluginDestinationDirectoryURL
        
        for path in paths {
            let plugins = self.pluginsAtPluginsPath(path)
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
        delegate?.pluginsDataController(self, didAddPlugin: plugin)
    }
    
    func removePlugin(plugin: Plugin) {
        let pluginPath = plugin.bundle.bundlePath
        pluginPathToPluginDictionary.removeValueForKey(pluginPath)
        delegate?.pluginsDataController(self, didRemovePlugin: plugin)
    }
    
    func pluginAtPluginPath(pluginPath: NSString) -> Plugin? {
        return pluginPathToPluginDictionary[pluginPath]
    }


    // MARK: Duplicate and Remove

    func movePluginToTrash(plugin: Plugin) {
        removePlugin(plugin)
        let pluginPath = plugin.bundle.bundlePath
        let pluginDirectoryPath = pluginPath.stringByDeletingLastPathComponent
        let pluginDirectoryName = pluginPath.lastPathComponent
        NSWorkspace.sharedWorkspace().performFileOperation(NSWorkspaceRecycleOperation,
            source: pluginDirectoryPath,
            destination: "",
            files: [pluginDirectoryName],
            tag: nil)
        let exists = NSFileManager.defaultManager().fileExistsAtPath(pluginPath)
        assert(!exists, "The file should not exist")
    }
    
    func duplicatePlugin(plugin: Plugin, handler: ((plugin: Plugin?) -> Void)?) {

        duplicatePluginController.duplicatePlugin(plugin,
            toDirectoryAtURL: duplicatePluginDestinationDirectoryURL)
        { (plugin, error) -> Void in
            if let plugin = plugin {
                self.addPlugin(plugin)
            }
            handler?(plugin: plugin)
        }
    }

}
