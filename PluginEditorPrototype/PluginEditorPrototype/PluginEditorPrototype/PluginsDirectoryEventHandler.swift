//
//  PluginsDirectoryEventHandler.swift
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

@objc protocol PluginsDirectoryEventHandlerDelegate {
    optional func pluginsDirectoryEventHandler(pluginsDirectoryEventHandler: PluginsDirectoryEventHandler,
        handleCreatedOrModifiedEventsAtPluginPath pluginPath: NSString,
        createdOrModifiedDirectoryPaths directoryPaths: [NSString]?,
        createdOrModifiedFilePaths filePaths: [NSString]?)
    optional func pluginsDirectoryEventHandler(pluginsDirectoryEventHandler: PluginsDirectoryEventHandler,
        handleRemovedEventsAtPluginPath pluginPath: NSString,
        removedItemPaths itemPaths: [NSString]?)
}

class PluginsDirectoryEventHandler: NSObject {
    var pluginPathToCreatedOrModifiedFilePaths: [NSString : [NSString]]
    var pluginPathToCreatedOrModifiedDirectoryPaths: [NSString : [NSString]]
    var pluginPathToRemovedItemPaths: [NSString : [NSString]]
    weak var delegate: PluginsDirectoryEventHandlerDelegate?
    
    struct ClassConstants {
        static let fileEventDelay = 0.3
    }
    
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

            fireCreatedOrModifiedEventsAfterDelayForPluginPath(pluginPath)
        }
    }

    func addFileWasCreatedOrModifiedEventAtPluginPath(pluginPath: NSString, path: NSString) {
        if var paths = pluginPathToCreatedOrModifiedFilePaths[pluginPath] {
            paths.append(path)
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = paths
        } else {
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = [path]

            fireCreatedOrModifiedEventsAfterDelayForPluginPath(pluginPath)
        }
    }

    func addItemWasRemovedAtPluginPath(pluginPath: NSString, path: NSString) {
        if var paths = pluginPathToRemovedItemPaths[pluginPath] {
            paths.append(path)
            pluginPathToRemovedItemPaths[pluginPath] = paths
        } else {
            pluginPathToRemovedItemPaths[pluginPath] = [path]

            fireRemovedEventsAfterDelayForPluginPath(pluginPath)
        }
    }

    func fireCreatedOrModifiedEventsAfterDelayForPluginPath(pluginPath: NSString) {
        let delay = ClassConstants.fileEventDelay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.fireCreatedOrModifiedEventsAtPluginPath(pluginPath)
        })
    }
    
    func fireRemovedEventsAfterDelayForPluginPath(pluginPath: NSString) {
        let delay = ClassConstants.fileEventDelay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.fireRemovedEventsAtPluginPath(pluginPath)
        })
    }
    
    // MARK: Firing Handlers
    
    func fireCreatedOrModifiedEventsAtPluginPath(pluginPath: NSString) {
        let filePaths = pluginPathToCreatedOrModifiedFilePaths[pluginPath]
        let directoryPaths = pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath]
        
        if filePaths == nil && directoryPaths == nil {
            return
        }
        
        delegate?.pluginsDirectoryEventHandler?(self,
            handleCreatedOrModifiedEventsAtPluginPath: pluginPath,
            createdOrModifiedDirectoryPaths: directoryPaths,
            createdOrModifiedFilePaths: filePaths)

        pluginPathToCreatedOrModifiedFilePaths[pluginPath] = nil
        pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = nil
    }

    func fireRemovedEventsAtPluginPath(pluginPath: NSString) {
        if let itemPaths = pluginPathToRemovedItemPaths[pluginPath] {
            delegate?.pluginsDirectoryEventHandler?(self,
                handleRemovedEventsAtPluginPath: pluginPath,
                removedItemPaths: itemPaths)
            pluginPathToRemovedItemPaths[pluginPath] = nil
        }
    }
    
}
