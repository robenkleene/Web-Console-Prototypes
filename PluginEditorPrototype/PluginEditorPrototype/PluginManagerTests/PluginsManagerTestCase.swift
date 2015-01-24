//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerTestCase: TemporaryPluginsTestCase {
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        
        // Create the plugin manager
        let pluginsManager = PluginsManager([pluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: pluginsDirectoryURL)
        PluginsManager.setOverrideSharedInstance(pluginsManager)

        // Set the plugin
        plugin = pluginsManager.pluginWithName(testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")

        // TODO: This should probably be changed once a fallback exists for when no default new plugin is set
        PluginsManager.sharedInstance.defaultNewPlugin = plugin
    }
    
    override func tearDown() {
        plugin = nil
        PluginsManager.setOverrideSharedInstance(nil)
        // TODO: This should probably be changed once a fallback exists for when no default new plugin is set
        PluginsManager.sharedInstance.defaultNewPlugin = nil
        super.tearDown()
    }
 
    func movePluginToTrashAndCleanUpWithConfirmation(plugin: Plugin) {

        // Confirm that a matching directory does not exist in the trash
        let trashedPluginDirectoryName = plugin.bundle.bundlePath.lastPathComponent
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.TrashDirectory, .UserDomainMask, true)[0] as NSString
        let trashedPluginPath = trashDirectory.stringByAppendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = NSFileManager.defaultManager().fileExistsAtPath(trashedPluginPath)
        XCTAssertTrue(!beforeExists, "The item should exist")
        
        // Trash the plugin
        PluginsManager.sharedInstance.movePluginToTrash(plugin)
        
        // Confirm that the directory does exist in the trash now
        var isDir: ObjCBool = false
        let afterExists = NSFileManager.defaultManager().fileExistsAtPath(trashedPluginPath, isDirectory: &isDir)
        XCTAssertTrue(afterExists, "The item should exist")
        XCTAssertTrue(isDir, "The item should be a directory")
        
        // Clean up trash
        var removeError: NSError?
        let success = NSFileManager.defaultManager().removeItemAtPath(trashedPluginPath, error: &removeError)
        XCTAssertTrue(success, "The remove should succeed")
        XCTAssertNil(removeError, "The error should be nil")
        

    }
    
}