//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

@objc protocol PluginsDirectoryManagerDelegate {
    optional func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath path: NSString)
    optional func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath path: NSString)
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
        let normalizedPath = path.stringByStandardizingPath as NSString
        let range = rangeInPath(normalizedPath, untilSubpath: subpath)
        if (range.location == NSNotFound) {
            return nil
        }
        let pathComponent = normalizedPath.substringFromIndex(range.length)
        let pathComponents = pathComponent.pathComponents

        if (pathComponents.count == 0) {
            return pathComponents
        }
        
        if (pathComponents[0] == "/") {
            // Remove the first slash if it exists
            var mutablePathComponents = NSMutableArray(array: pathComponents)
            mutablePathComponents.removeObjectAtIndex(0)
            return mutablePathComponents
        }

        return pathComponents
    }

    class func pathComponent(pathComponent: NSString, containsSubpathComponent subpathComponent: NSString) -> Bool {
        let pathComponents = pathComponent.pathComponents
        let subpathComponents = subpathComponent.pathComponents
        for index in 0..<subpathComponents.count {
            let pathComponent = pathComponents[index] as NSString
            let subpathComponent = subpathComponents[index] as NSString
            if !pathComponent.isEqualToString(subpathComponent) {
                return false
            }
        }
        return true
    }
    
    class func pathComponent(pathComponent: NSString, isPathComponent matchPathComponent: NSString) -> Bool {
        let pathComponents = pathComponent.pathComponents
        let matchPathComponents = matchPathComponent.pathComponents
        if pathComponents.count != matchPathComponents.count {
            return false
        }
        for index in 0..<pathComponents.count {
            let pathComponent = pathComponents[index] as NSString
            let matchPathComponent = matchPathComponents[index] as NSString
            if !pathComponent.isEqualToString(matchPathComponent) {
                return false
            }
        }
        return true
    }
    
    class func path(path: NSString, containsSubpath subpath: NSString) -> Bool {
        if let pathUntilSubpath = subpathFromPath(path, untilSubpath: subpath) {
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

    // TODO: Add directory was removed
    // TODO: Add directory was modified
    // TODO: Re-write fileWasRemoved
    

    // MARK: WCLDirectoryWatcherDelegate
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, directoryWasCreatedOrModifiedAtPath path: String!) {
        assert(pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")

        if pathContainsInfoDictionarySubpath(path) {
            processPotentialInfoDictionaryCreatedOrModifiedAtPath(path)
        }
    }
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, directoryWasRemovedAtPath path: String!) {
        assert(pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")
        
        if pathContainsInfoDictionarySubpath(path) {
            processPotentialInfoDictionaryWasRemovedAtPath(path)
        }
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
        assert(pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")
    
        if pathIsInfoDictionaryPath(path) {
            processPotentialInfoDictionaryCreatedOrModifiedAtPath(path)
        }
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasRemovedAtPath path: String!) {
        assert(pathIsSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")

        if pathIsInfoDictionaryPath(path) {
            processPotentialInfoDictionaryWasRemovedAtPath(path)
        }
    }
    

    // MARK: Processing Info Dictionary Events

    func processPotentialInfoDictionaryWasRemovedAtPath(path: NSString) {
        if let pluginPath = self.pluginPathFromPath(path) {
            let infoDictionaryPath = pluginPath.stringByAppendingPathComponent(ClassConstants.infoDictionaryPathComponent)
            if (!NSFileManager.defaultManager().fileExistsAtPath(infoDictionaryPath)) {
                delegate?.pluginsDirectoryManager?(self, pluginInfoDictionaryWasRemovedAtPluginPath: pluginPath)
            }
        }
    }
    
    func processPotentialInfoDictionaryCreatedOrModifiedAtPath(path: NSString) {
        if let pluginPath = self.pluginPathFromPath(path) {
            let infoDictionaryPath = pluginPath.stringByAppendingPathComponent(ClassConstants.infoDictionaryPathComponent)
            
            // TODO: in the current implementation fileExists can be false here which will cause a failure, custom handling for rename should prevent this
            //                let fileExists = NSFileManager.defaultManager().fileExistsAtPath(infoDictionaryPath)
            //                println("fileExists = \(fileExists)")
            
            if (NSFileManager.defaultManager().fileExistsAtPath(infoDictionaryPath)) {
                delegate?.pluginsDirectoryManager?(self, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath: pluginPath)
            }
        }
    }


    // MARK: Helpers

    func infoDictionaryIsSubdirectoryOfPath(path: NSString) -> Bool {
        return false
    }

    func pluginPathFromPath(path: NSString) -> NSString? {
        if let pluginPathComponent = pluginPathComponentFromPath(path) {
            if let subpath = pluginsDirectoryURL.path {
                let pluginPath = subpath.stringByAppendingPathComponent(pluginPathComponent)
                return pluginPath
            }
        }
        return nil
    }
    
    func pluginPathComponentFromPath(path: NSString) -> NSString? {
        if let subpath = pluginsDirectoryURL.path {
            if let pathComponents = PluginsPathHelper.pathComponentsOfPath(path, afterSubpath: subpath) {
                if (pathComponents.count > 0) {
                    var pluginSubpathComponents = pathComponents as Array
                    let pathComponent = pluginSubpathComponents.removeAtIndex(0) as? NSString
                    return pathComponent
                }
            }
        }
        return nil
    }

    func pluginPathComponentsFromPath(path: NSString) -> NSArray? {
        if let subpath = pluginsDirectoryURL.path {
            let pathComponents = PluginsPathHelper.pathComponentsOfPath(path, afterSubpath: subpath)
            return pathComponents
        }
        return nil
    }
    
    func pluginSubpathComponentsFromPath(path: NSString) -> NSString? {
        if let pluginPathComponents = pluginPathComponentsFromPath(path) {
            let pluginSubpathComponent = pluginSubpathComponentFromPathComponents(pluginPathComponents)
            return pluginSubpathComponent
        }
        return nil
    }
    
    func pluginSubpathComponentFromPathComponents(pathComponents: NSArray) -> NSString? {
        if pathComponents.count == 0 {
            return nil
        }
        var pluginSubpathComponents = pathComponents as Array // Coerce to Swift Array
        pluginSubpathComponents.removeAtIndex(0)
        let pluginSubpathComponent = NSString.pathWithComponents(pluginSubpathComponents)
        return pluginSubpathComponent
    }
    
    func pathContainsInfoDictionarySubpath(path: NSString) -> Bool {
        if let pluginSubpathComponent = pluginSubpathComponentsFromPath(path) {
            let containsSubpathComponent = PluginsPathHelper.pathComponent(ClassConstants.infoDictionaryPathComponent, containsSubpathComponent: pluginSubpathComponent)
            return containsSubpathComponent
        }
        return false
    }
    
    func pathIsInfoDictionaryPath(path: NSString) -> Bool {
        if let pluginSubpathComponent = pluginSubpathComponentsFromPath(path) {
            let isPathComponent = PluginsPathHelper.pathComponent(ClassConstants.infoDictionaryPathComponent, isPathComponent: pluginSubpathComponent)
            return isPathComponent
        }
        return false
    }
    
    func pathIsSubpathOfPluginsDirectory(path: NSString) -> Bool {
        if let subpath = pluginsDirectoryURL.path {
            return PluginsPathHelper.path(path, containsSubpath: subpath)
        }
        return false
    }
}