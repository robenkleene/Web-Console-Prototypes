//
//  DuplicatePluginControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class DuplicatePluginControllerTests: TemporaryPluginsTestCase {
    var duplicatePluginController: DuplicatePluginController!
    
    override func setUp() {
        super.setUp()
        duplicatePluginController = DuplicatePluginController()
    }

    override func tearDown() {
        duplicatePluginController = nil
        super.tearDown()
    }
    
    func testDuplicatePlugin() {
        var duplicatePlugin: Plugin!
        let duplicateExpectation = expectationWithDescription("Duplicate")
        duplicatePluginController.duplicatePlugin(temporaryPlugin, toDirectoryAtURL: temporaryPluginsDirectoryURL) { (plugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            XCTAssertNotNil(plugin, "The plugin should not be nil")
            duplicatePlugin = plugin
            duplicateExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Test the plugins directory exists
        let duplicatePluginURL = duplicatePlugin.bundle.bundleURL
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(duplicatePluginURL.path!,
            isDirectory: &isDir)
        XCTAssertTrue(exists, "The item should exist")
        XCTAssertTrue(isDir, "The item should be a directory")

        // Test the plugins properties are accurate
        XCTAssertNotEqual(temporaryPlugin.bundle.bundleURL, duplicatePlugin.bundle.bundleURL, "The URLs should not be equal")
        XCTAssertNotEqual(temporaryPlugin.identifier, duplicatePlugin.identifier, "The identifiers should not be equal")
        XCTAssertNotEqual(temporaryPlugin.name, duplicatePlugin.name, "The names should not be equal")
        XCTAssertNotEqual(temporaryPlugin.commandPath!, duplicatePlugin.commandPath!, "The command paths should not be equal")
        XCTAssertEqual(temporaryPlugin.command!, duplicatePlugin.command!, "The commands should be equal")

        // Clean Up
        let success = removeTemporaryItemAtURL(duplicatePluginURL)
        XCTAssertTrue(success, "The remove should succeed")
    }
}