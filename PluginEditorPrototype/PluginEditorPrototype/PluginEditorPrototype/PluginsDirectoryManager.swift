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
    let pluginsDirectoryURL: NSURL
    init(pluginsDirectoryURL: NSURL) {
        self.pluginsDirectoryURL = pluginsDirectoryURL
        self.directoryWatcher = WCLDirectoryWatcher(URL: pluginsDirectoryURL)
        super.init()
        self.directoryWatcher.delegate = self
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasRemovedAtPath path: String!) {
        assert(self.pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")
        
        println("fileWasRemovedAtPath path = \(path)")
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
        assert(self.pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")
        
        println("fileWasCreatedOrModifiedAtPath path = \(path)")
    }

    func pathIsSubpathOfPluginsDirectory(path: NSString) -> Bool {
        if let pluginsDirectoryPath = pluginsDirectoryURL.path {
            let pathPrefixRange = path.rangeOfString(pluginsDirectoryPath)
            let basePathLength = pathPrefixRange.location + pathPrefixRange.length
            let basePathRange = NSRange(location: 0, length: basePathLength)
            let basePath = path.substringWithRange(basePathRange)
            return basePath.stringByStandardizingPath == (pluginsDirectoryPath.stringByStandardizingPath)
        }
        return false
    }
    
}