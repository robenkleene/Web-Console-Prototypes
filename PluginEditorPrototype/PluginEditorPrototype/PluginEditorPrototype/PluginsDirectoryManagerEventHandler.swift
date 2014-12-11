//
//  PluginsDirectoryManagerEventHandler.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/10/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

// What needs to be unique are created events 

// The reason events are coalesced by sending the events after the delay period,
// as opposed to sending an event right away then preventing events from being
// sent for the delay period, is that only former works in the following case:
// 1. The plugin is edited
// 2. The plugin is loaded
// 3. The plugin is edited again
// In this case, the plugin should be loaded again for the second edit. The
// plugin would not be reloaded for the second edit if events are prevented
// from firing during the delay period.

@objc protocol PluginsDirectoryManagerEventHandlerDelegate {
    optional func pluginsDirectoryManagerEventHandler(pluginsDirectoryManagerEventHandler: PluginsDirectoryManagerEventHandler,
        handleCreatedOrModifiedEventsAtPluginPath pluginPath: NSString,
        createdOrModifiedDirectoryPaths directoryPaths: [NSString]?,
        createdOrModifiedFilePaths filePaths: [NSString]?)
    optional func pluginsDirectoryManagerEventHandler(pluginsDirectoryManagerEventHandler: PluginsDirectoryManagerEventHandler,
        handleRemovedEventsAtPluginPath pluginPath: NSString,
        removedItemPaths itemPaths: [NSString]?)
}

class PluginsDirectoryManagerEventHandler: NSObject {
    var pluginPathToCreatedOrModifiedFilePaths: [NSString : [NSString]]
    var pluginPathToCreatedOrModifiedDirectoryPaths: [NSString : [NSString]]
    var pluginPathToRemovedItemPaths: [NSString : [NSString]]
    var delegate: PluginsDirectoryManagerEventHandlerDelegate?
    
    override init() {
        self.pluginPathToCreatedOrModifiedFilePaths = [NSString : [NSString]]()
        self.pluginPathToCreatedOrModifiedDirectoryPaths = [NSString : [NSString]]()
        self.pluginPathToRemovedItemPaths = [NSString : [NSString]]()
    }
    
    // MARK: Collecting Handlers
    
    func addDirectoryWasCreatedOrModifiedEventAtPluginPath(pluginPath: NSString, path: NSString) {
        if var paths = pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] {
            paths.append(path)
            pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = paths
        } else {
            pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = [path]

            fireCreatedOrModifiedEventsAtPluginPath(pluginPath) // TODO: Perform selector after delay
        }
    }

    func addFileWasCreatedOrModifiedEventAtPluginPath(pluginPath: NSString, path: NSString) {
        if var paths = pluginPathToCreatedOrModifiedFilePaths[pluginPath] {
            paths.append(path)
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = paths
        } else {
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = [path]

            fireCreatedOrModifiedEventsAtPluginPath(pluginPath) // TODO: Perform selector after delay
        }
    }

    func addItemWasRemovedAtPluginPath(pluginPath: NSString, path: NSString) {
        if var paths = pluginPathToRemovedItemPaths[pluginPath] {
            paths.append(path)
            pluginPathToRemovedItemPaths[pluginPath] = paths
        } else {
            pluginPathToRemovedItemPaths[pluginPath] = [path]

            fireRemovedEventsAtPluginPath(pluginPath) // TODO: Perform selector after delay
        }
    }

    // MARK: Firing Handlers
    
    func fireCreatedOrModifiedEventsAtPluginPath(pluginPath: NSString) {
        let filePaths = pluginPathToCreatedOrModifiedFilePaths[pluginPath]
        let directoryPaths = pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath]
        
        if filePaths == nil && directoryPaths == nil {
            return
        }
        
        delegate?.pluginsDirectoryManagerEventHandler?(self,
            handleCreatedOrModifiedEventsAtPluginPath: pluginPath,
            createdOrModifiedDirectoryPaths: directoryPaths,
            createdOrModifiedFilePaths: filePaths)

        pluginPathToCreatedOrModifiedFilePaths[pluginPath] = nil
        pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = nil
    }

    func fireRemovedEventsAtPluginPath(pluginPath: NSString) {
        if let itemPaths = pluginPathToRemovedItemPaths[pluginPath] {
            delegate?.pluginsDirectoryManagerEventHandler?(self,
                handleRemovedEventsAtPluginPath: pluginPath,
                removedItemPaths: itemPaths)
            pluginPathToRemovedItemPaths[pluginPath] = nil
        }
    }
    
}
