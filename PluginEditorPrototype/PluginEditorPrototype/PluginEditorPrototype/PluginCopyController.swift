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
    
    func copyPlugin(plugin: Plugin, toURL destinationURL: NSURL) -> Plugin? {
        let uuid = NSUUID()
        let pluginURL = plugin.bundle.bundleURL
        self.dynamicType.copyItemAtURL(pluginURL, toDirectoryURL: copyTempDirectoryURL, withFilename: uuid.UUIDString)
        
        // Update the plist identifier and name
        // Load the plugin
        // Update the identifier and name via the plugin API
        // Change value for the identifier
        // Change value for the name

        // Move to the destination & rename syncronously
        
        return nil
    }
    
    private class func copyItemAtURL(url: NSURL, toDirectoryURL directoryURL: NSURL, withFilename filename: String) {
        // TODO Should show error messages instead of asserting
        
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
            assert(isDir, "The file should be a directory")
        }
        
        let destinationURL = directoryURL.URLByAppendingPathComponent(filename)
        var error: NSError?
        let copySuccess = NSFileManager.defaultManager()
            .copyItemAtURL(url,
                toURL: destinationURL,
                error: &error)
        assert(copySuccess && error == nil, "The copy should succeed")
    }
}