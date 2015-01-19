//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerTests: PluginsManagerTestCase {

    func testDuplicateAndTrashPlugin() {
        var newPlugin: Plugin?

        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        PluginsManager.sharedInstance.duplicatePlugin(plugin, handler: { (duplicatePlugin) -> Void in
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 2, "The plugins count should be two")
        XCTAssertTrue(PluginsManager.sharedInstance.plugins().containsObject(newPlugin!), "The plugins should contain the plugin")
        
        // Trash the duplicated plugin
        
        // Confirm that a matching directory does not exist in the trash
        let trashedPluginDirectoryName = newPlugin!.bundle.bundlePath.lastPathComponent
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.TrashDirectory, .UserDomainMask, true)[0] as NSString
        let trashedPluginPath = trashDirectory.stringByAppendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = NSFileManager.defaultManager().fileExistsAtPath(trashedPluginPath)
        XCTAssertTrue(!beforeExists, "The item should exist")
        
        // Trash the plugin
        PluginsManager.sharedInstance.movePluginToTrash(newPlugin!)
        
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

    func testRenamePlugin() {
        let newPluginName = plugin.identifier
        plugin.name = newPluginName
        XCTAssertNotNil(PluginsManager.sharedInstance.pluginWithName(newPluginName), "The plugin should not be nil")
        XCTAssertNil(PluginsManager.sharedInstance.pluginWithName(testPluginName), "The plugin should be nil")
    }
    
    // TODO: Waiting for default new plugin API, do tests with `PluginManager` `duplicatePlugin` API, using `PluginManager` `newPlugin`

}
