//
//  DuplicatePluginController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class DuplicatePluginController {
    lazy var copyDirectoryController = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)

    struct ClassConstants {
        static let tempDirectoryName = "Duplicate Plugin"
    }
    
    func duplicatePlugin(plugin: Plugin, toDirectoryAtURL destinationDirectoryURL: NSURL, completionHandler handler: (plugin: Plugin?, error: NSError?) -> Void) {
        let pluginFileURL = plugin.bundle.bundleURL
        copyDirectoryController.copyItemAtURL(pluginFileURL, completionHandler: { (URL, error) -> Void in
            assert(URL != nil, "The URL should not be nil")
            assert(error == nil, "The error should be nil")
            
            var plugin: Plugin?
            var error: NSError?
            if let URL = URL {
                let UUID = NSUUID()
                let movedFilename = UUID.UUIDString
                let movedDestinationURL = destinationDirectoryURL.URLByAppendingPathComponent(movedFilename)
                var moveError: NSError?
                let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(URL,
                    toURL: movedDestinationURL,
                    error: &moveError)
                assert(moveSuccess, "The move should succeed")
                assert(moveError == nil, "The error should be nil")
                if let movedPlugin = Plugin.pluginWithURL(movedDestinationURL) {
                    // TODO: Get this code using the real unique name code
                    movedPlugin.renameWithUniqueName()
                    movedPlugin.identifier = UUID.UUIDString
                    plugin = movedPlugin
                    
                    // Attempt to move the plugin to a directory based on its name
                    var renameError: NSError?
                    let renamedDestinationURL = movedDestinationURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(movedPlugin.name)
                    let renameSuccess = NSFileManager.defaultManager().moveItemAtURL(movedDestinationURL,
                        toURL: renamedDestinationURL,
                        error: &renameError)
                    if !renameSuccess || renameError != nil {
                        println("Failed to move a plugin directory to \(renamedDestinationURL) \(error)")
                    } else if let renamedPlugin = Plugin.pluginWithURL(renamedDestinationURL) {
                        plugin = renamedPlugin
                    }
                }
            }

            handler(plugin: plugin, error: error)
        })
    }
}