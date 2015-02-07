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
    struct ClassConstants {
        static let errorCode = -44
    }
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
            if let newPlugin = Plugin.pluginWithPath(pluginPath) {
                // If there is an existing plugin and a new plugin, remove the old plugin and add the new plugin
                if !oldPlugin.isEqualToPlugin(newPlugin) {
                    removePlugin(oldPlugin)
                    addPlugin(newPlugin)
                }
            }
        } else {
            // If there is only a new plugin, add it
            if let newPlugin = Plugin.pluginWithPath(pluginPath) {
                addPlugin(newPlugin)
            }
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
        assert(plugin.editable, "The plugin should be editable")
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
    
    func duplicatePlugin(plugin: Plugin, handler: ((plugin: Plugin?, error: NSError?) -> Void)?) {

        var error: NSError?        
        let success = self.dynamicType.createDirectoryIfMissing(duplicatePluginDestinationDirectoryURL, error: &error)

        if !success || error != nil {
            handler?(plugin: nil, error: error)
            return
        }

        duplicatePluginController.duplicatePlugin(plugin,
            toDirectoryAtURL: duplicatePluginDestinationDirectoryURL)
        { (plugin, error) -> Void in
            if let plugin = plugin {
                self.addPlugin(plugin)
            }
            handler?(plugin: plugin, error: error)
        }
    }

    class func createDirectoryIfMissing(directoryURL: NSURL, error: NSErrorPointer) -> Bool {
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(directoryURL.path!, isDirectory: &isDir)
        if (exists && isDir) {
            return true
        }
        
        if (exists && !isDir) {
            if error != nil {
                let errorString = NSLocalizedString("A file exists at the destination directory.", comment: "Invalid destination directory error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
            return false
        }

        var createError: NSError?
        let success = NSFileManager.defaultManager().createDirectoryAtURL(directoryURL,
            withIntermediateDirectories: true,
            attributes: nil,
            error: &createError)
        if error != nil {
            error.memory = createError
        }
        
        return success
    }
    
}
