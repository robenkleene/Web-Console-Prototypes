//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

//protocol PluginsDirectoryManagerDelegate {
//// infoDictionaryWasCreatedOrModified
//// infoDictionaryWasRemoved
//    optional func directoryWillChange(directoryURL: NSURL)
//}

class PluginsDirectoryManager: NSObject, WCLDirectoryWatcherDelegate {
//    var delegate: PluginsDirectoryManagerDelegate?
    struct ClassConstants {
//        static let infoDictionaryPathComponent = ""
    }
    
    let directoryWatcher: WCLDirectoryWatcher
    init(pluginsDirectoryURL: NSURL) {
        self.directoryWatcher = WCLDirectoryWatcher(URL: pluginsDirectoryURL)
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasRemovedAtPath path: String!) {
        // TODO: Assert that the path matches the watched path
        
        println("fileWasRemovedAtPath path = \(path)")
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
        // TODO: Assert that the path matches the watched path
        
        println("fileWasCreatedOrModifiedAtPath path = \(path)")
    }
}