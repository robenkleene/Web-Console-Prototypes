//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

@objc protocol PluginsDirectoryManagerDelegate {
    optional func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, infoDictionaryWasCreatedOrModifiedAtPath path: NSString)
    optional func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, infoDictionaryWasRemovedAtPath path: NSString)
}

// TODO: EXTENSION BEGIN NSString+PluginDirectoryPaths
// Can swift do inline extensions? This is probably only appropriate if this can be an extension that only this class can see
class PluginsPathHelper {

    class func rangeInPath(path: NSString, untilSubpath subpath: NSString) -> NSRange {
        // Normalize the subpath so the same range is always returned regardless of the format of the subpath (e.g., number of slashes)
        let normalizedSubpath = subpath.stringByStandardizingPath
        
        let subpathRange = path.rangeOfString(normalizedSubpath)
        if (subpathRange.location == NSNotFound) {
            return subpathRange
        }
        let untilSubpathLength = subpathRange.location + subpathRange.length
        let untilSubpathRange = NSRange(location: 0, length: untilSubpathLength)
        return untilSubpathRange
    }
    
    class func subpathFromPath(path: NSString, untilSubpath subpath: NSString) -> NSString? {
        let range = rangeInPath(path, untilSubpath: subpath)
        if (range.location == NSNotFound) {
            return nil
        }
        let pathUntilSubpath = path.substringWithRange(range)
        return pathUntilSubpath
    }
    
    class func pathComponentsOfPath(path: NSString, afterSubpath subpath: NSString) -> NSArray? {
        let range = rangeInPath(path, untilSubpath: subpath)
        if (range.location == NSNotFound) {
            return nil
        }
        let pathComponent = path.substringFromIndex(path.length)
        return pathComponent.pathComponents
    }

    class func path(path: NSString, containsSubpath subpath: NSString) -> Bool {
        if let pathUntilSubpath = PluginsPathHelper.subpathFromPath(path, untilSubpath: subpath) {
            return pathUntilSubpath.stringByStandardizingPath == subpath.stringByStandardizingPath
        }
        return false
    }
}
// TODO: EXTENSION END NSString+PluginDirectoryPaths

class PluginsDirectoryManager: NSObject, WCLDirectoryWatcherDelegate {
    struct ClassConstants {
        static let infoDictionaryPathComponent = "Contents/Info.plist"
    }
    var delegate: PluginsDirectoryManagerDelegate?
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
        
        // TODO: Get the base path, add one path component
        
        println("fileWasCreatedOrModifiedAtPath path = \(path)")
    }

    func infoDictionaryIsSubdirectoryOfPath(path: NSString) -> Bool {
        return false
    }
    
    // TODO: Replace with PluginsPathHelper.path(path, containsSubpath)
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