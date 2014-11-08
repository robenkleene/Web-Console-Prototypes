//
//  PluginCopyController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class PluginCopyController {
    let copyTempDirectoryURL: NSURL
    
    init() {
        let copyTempDirectoryPathComponent = "PluginCopy"
        self.copyTempDirectoryURL = Directory.Caches.URL().URLByAppendingPathComponent(copyTempDirectoryPathComponent)
        self.cleanUp()
    }

    func cleanUp() {
        self.dynamicType.deleteContentsOfDirectoryAtURL(copyTempDirectoryURL)
    }
    
    class func deleteContentsOfDirectoryAtURL(directoryURL: NSURL) {
        if let path = directoryURL.path {
            assert(path.hasPrefix(Directory.Caches.path()), "The path should be prefixed by the caches path")
            let enumerator = NSFileManager.defaultManager().enumeratorAtPath(path)
            while let filename = enumerator?.nextObject() as? NSString {
                let filePath = path.stringByAppendingPathComponent(filename)
                var error: NSError?
                let success = NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
                assert(success && error == nil, "The remove should succeed")
            }
        }
    }
    
    func copyPlugin(plugin: Plugin, toDirectoryAtURL destinationDirectoryURL: NSURL) -> NSURL? {
        let uuid = NSUUID()
        let filename = uuid.UUIDString
        let pluginURL = plugin.bundle.bundleURL
        let copiedPluginURL = self.dynamicType.urlOfItemCopiedFromURL(pluginURL, toDirectoryURL: copyTempDirectoryURL, withFilename: filename)

        if let plugin = Plugin.pluginWithURL(copiedPluginURL) {
            // TODO: Get this code using the real unique name code
            plugin.name = "Test Name"
            plugin.identifier = uuid.UUIDString

            let destinationPluginURL = destinationDirectoryURL.URLByAppendingPathComponent(filename)
            var error: NSError?
            let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(copiedPluginURL, toURL: destinationPluginURL, error: &error)
            if !moveSuccess || error != nil {
                println("Failed to move a plugin directory to \(destinationPluginURL) \(error)")
            }

            // Rename based on plugin name if possible
            let renamedPluginURL = destinationPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(plugin.name)
            let renameSuccess = NSFileManager.defaultManager().moveItemAtURL(destinationPluginURL, toURL: renamedPluginURL, error: &error) // Failure delibrately ignored
            if !renameSuccess || error != nil {
                println("Failed to move a plugin directory to \(renamedPluginURL) \(error)")
            }
            
            // Return a file URL rather than the plugin because this plugin isn't watched on the file system yet
            // Instantiating the plugin is just a shortcut to editing the plugins properties
            return renamedPluginURL
        }
        
        // TODO: Log an error here and delete the newPluginURL?
        
        return nil
    }
    
    private class func urlOfItemCopiedFromURL(url: NSURL, toDirectoryURL directoryURL: NSURL, withFilename filename: String) -> NSURL {
        // TODO: Should show error messages instead of asserting
        
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager()
            .fileExistsAtPath(directoryURL.path!,
                isDirectory: &isDir)
        if !exists {
            var error: NSError?
            let createSuccess = NSFileManager.defaultManager()
                .createDirectoryAtURL(directoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil,
                    error: &error)
            println("error = \(error)")
            assert(createSuccess && error == nil, "The create should succeed")
        }
        else {
            assert(isDir ? true : false, "The file should be a directory")
        }
        
        let destinationURL = directoryURL.URLByAppendingPathComponent(filename)
        var error: NSError?
        let copySuccess = NSFileManager.defaultManager()
            .copyItemAtURL(url,
                toURL: destinationURL,
                error: &error)
        assert(copySuccess && error == nil, "The copy should succeed")

        return destinationURL
    }
}