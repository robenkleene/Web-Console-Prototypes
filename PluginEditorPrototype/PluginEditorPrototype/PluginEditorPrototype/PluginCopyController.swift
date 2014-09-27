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
        // TODO Move contents to the trash on init
        let copyTempDirectoryPathComponent = "PluginCopy"
        // Move all the contents to the trash
        
        self.copyTempDirectoryURL = Directory.Caches.URL().URLByAppendingPathComponent(copyTempDirectoryPathComponent)
    }
    
    func copyPlugin(plugin: Plugin, toURL destinationURL: NSURL) -> Plugin? {
        let uuid = NSUUID()
        let pluginURL = plugin.bundle.bundleURL
        let tempDestinationURL = copyTempDirectoryURL.URLByAppendingPathComponent(uuid.UUIDString)

        // TODO Create the directory if it is missing?
        
        println("pluginURL = \(pluginURL)")
        println("tempDestinationURL = \(tempDestinationURL)")
        
//        var error: NSError?
//        NSFileManager.defaultManager().copyItemAtURL(pluginURL, toURL: tempDestinationURL, error: &error)
//
//        // TODO This should display na error message, not assert
//        assert(error != nil, "The copy should succeed")
        
        
        // Update the plist and filename
        
        // Copy to the destination

        return nil
    }

//    func uniqueFolderNameFromName:(name: String, inDirectoryURL directoryURL: NSURL) -> String {
//        
//    }
}