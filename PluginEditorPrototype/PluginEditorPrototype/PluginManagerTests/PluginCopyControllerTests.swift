//
//  PluginCopyControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginCopyControllerTests: XCTestCase {
    let pluginCopyController = PluginCopyController()
    let pluginManager = PluginManager(testPluginsPaths)
    var plugin: Plugin?

    override func setUp() {
        super.setUp()
        plugin = self.pluginManager.pluginWithName(testPluginName)
    }

    override func tearDown() {
        pluginCopyController.cleanUp()
        plugin = nil
        super.tearDown()
    }
    
    func testCopyPlugin() {
        var testPluginURL = pluginCopyController.copyPlugin(plugin!, toDirectoryAtURL: pluginCopyController.copyTempDirectoryURL)
        var testPlugin = Plugin.pluginWithURL(testPluginURL!)
        
        XCTAssertNotNil(testPlugin, "The plugin should not be nil")
        XCTAssertNotEqual(plugin!.name, testPlugin!.name, "The test plugin's name should not equal the plugin's name")
        XCTAssertNotEqual(plugin!.identifier, testPlugin!.identifier, "The test plugin's identifier should not equal the plugin's name")

        // TODO: Assert that the new plugins properties can be changed
        // TODO: Assert that after moving the bundle its URL is still accurate
        // TODO: Assert the directory matches the name
        // TODO: How to resolve issues around a plugins new URL? E.g., I've loaded the plugin and then change its URL
        
        println("break")
    }
    
    func testCleanUp() {
        pluginCopyController.copyPlugin(plugin!, toDirectoryAtURL: pluginCopyController.copyTempDirectoryURL)

        // Assert the directory is not empty
        let path = pluginCopyController.copyTempDirectoryURL.path!
        var error: NSError?
        var contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssertFalse(contents!.isEmpty, "The contents should not be empty")
        
        pluginCopyController.cleanUp()

        // Assert directory is empty
        error = nil
        contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssertTrue(contents!.isEmpty, "The contents should be empty")
    }

    // TODO: If there is already an existing plugin the resulting directory name should be the same as the plugins UUID
}

//class PluginCopyControllerTests: XCTestCase {


// TODO: Copy to test directory