//
//  PluginDuplicateController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class PluginDuplicateController {
//    lazy var copyDirectoryController = CopyDirectoryController()

//    func duplicatePlugin(plugin: Plugin, toDirectoryAtURL destinationDirectoryURL: NSURL) -> NSURL? {
//        let uuid = NSUUID()
//        let filename = uuid.UUIDString
//        let pluginURL = plugin.bundle.bundleURL
//        let copiedPluginURL = self.dynamicType.urlOfItemCopiedFromURL(pluginURL, toDirectoryURL: duplicateTempDirectoryURL, withFilename: filename)
//
//        if let plugin = Plugin.pluginWithURL(copiedPluginURL) {
//            // TODO: Get this code using the real unique name code
//            plugin.name = "Test Name"
//            plugin.identifier = uuid.UUIDString
//
//            let destinationPluginURL = destinationDirectoryURL.URLByAppendingPathComponent(filename)
//            var error: NSError?
//            let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(copiedPluginURL, toURL: destinationPluginURL, error: &error)
//            if !moveSuccess || error != nil {
//                println("Failed to move a plugin directory to \(destinationPluginURL) \(error)")
//            }
//
//            // Rename based on plugin name if possible
//            let renamedPluginURL = destinationPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(plugin.name)
//            let renameSuccess = NSFileManager.defaultManager().moveItemAtURL(destinationPluginURL, toURL: renamedPluginURL, error: &error) // Failure delibrately ignored
//            if !renameSuccess || error != nil {
//                println("Failed to move a plugin directory to \(renamedPluginURL) \(error)")
//            }
//            
//            // Return a file URL rather than the plugin because this plugin isn't watched on the file system yet
//            // Instantiating the plugin is just a shortcut to editing the plugins properties
//            return renamedPluginURL
//        }
//        
//        // TODO: Log an error here and delete the newPluginURL?
//        
//        return nil
//    }

}