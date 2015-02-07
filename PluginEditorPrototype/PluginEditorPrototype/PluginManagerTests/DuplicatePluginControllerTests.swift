//
//  DuplicatePluginControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class DuplicatePluginControllerTests: PluginsManagerTestCase {
    var duplicatePluginController: DuplicatePluginController!
    
    override func setUp() {
        super.setUp()
        duplicatePluginController = DuplicatePluginController()
        plugin.editable = false
    }

    override func tearDown() {
        duplicatePluginController = nil
        super.tearDown()
    }
    
    func testDuplicatePlugin() {
        // Test that the plugin starts not editable
        XCTAssertFalse(plugin.editable, "The plugin should not be editable")
        var error: NSError?
        var pluginInfoDictionaryURL = Plugin.infoDictionaryURLForPluginURL(pluginURL)
        var pluginInfoDictionaryContents: NSString! = NSString(contentsOfURL: pluginInfoDictionaryURL, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil")
        var range = pluginInfoDictionaryContents.rangeOfString(Plugin.InfoDictionaryKeys.Editable)
        XCTAssertFalse(range.location == NSNotFound, "The string should have been found")

        // Duplicate the plugin
        var duplicatePlugin: Plugin!
        let duplicateExpectation = expectationWithDescription("Duplicate")
        duplicatePluginController.duplicatePlugin(plugin, toDirectoryAtURL: pluginsDirectoryURL) { (plugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            XCTAssertNotNil(plugin, "The plugin should not be nil")
            duplicatePlugin = plugin
            duplicateExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Test the plugin's directory exists
        let duplicatePluginURL = duplicatePlugin.bundle.bundleURL
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(duplicatePluginURL.path!,
            isDirectory: &isDir)
        XCTAssertTrue(exists, "The item should exist")
        XCTAssertTrue(isDir, "The item should be a directory")

        // Test that the new plugin is editable
        XCTAssertTrue(duplicatePlugin.editable, "The duplicated plugin should be editable")
        error = nil
        pluginInfoDictionaryURL = Plugin.infoDictionaryURLForPluginURL(duplicatePlugin.bundle.bundleURL)
        pluginInfoDictionaryContents = NSString(contentsOfURL: pluginInfoDictionaryURL, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil")
        range = pluginInfoDictionaryContents.rangeOfString(Plugin.InfoDictionaryKeys.Editable)
        XCTAssertTrue(range.location == NSNotFound, "The string should not have been found")

        // Test the plugins properties are accurate
        XCTAssertNotEqual(plugin.bundle.bundleURL, duplicatePlugin.bundle.bundleURL, "The URLs should not be equal")
        XCTAssertNotEqual(plugin.identifier, duplicatePlugin.identifier, "The identifiers should not be equal")
        XCTAssertNotEqual(plugin.name, duplicatePlugin.name, "The names should not be equal")
        XCTAssertEqual(plugin.hidden, duplicatePlugin.hidden, "The hidden should equal the plugin's hidden")
        let longName: NSString = duplicatePlugin.name
        XCTAssertTrue(longName.hasPrefix(plugin.name), "The new WCLPlugin's name should start with the WCLPlugin's name.")
        XCTAssertNotEqual(plugin.commandPath!, duplicatePlugin.commandPath!, "The command paths should not be equal")
        XCTAssertEqual(plugin.command!, duplicatePlugin.command!, "The commands should be equal")
        let duplicatePluginFolderName = duplicatePlugin.bundle.bundlePath.lastPathComponent as NSString
        XCTAssertEqual(DuplicatePluginController.pluginFilenameFromName(duplicatePlugin.name), duplicatePluginFolderName, "The folder name should equal the plugin's name")
        
        // Clean Up
        let success = removeTemporaryItemAtURL(duplicatePluginURL)
        XCTAssertTrue(success, "The remove should succeed")
    }
    
    func testDuplicatePluginWithFolderNameBlocked() {
        // Get the destination plugin name
        let uniqueName = WCLPlugin.uniquePluginNameFromName(plugin.name)
        let destinationName = DuplicatePluginController.pluginFilenameFromName(uniqueName)
        
        // Create a folder at the destination URL
        let destinationFolderURL = pluginsDirectoryURL.URLByAppendingPathComponent(destinationName)
        var createDirectoryError: NSError?
        let createSuccess = NSFileManager
            .defaultManager()
            .createDirectoryAtURL(destinationFolderURL,
                withIntermediateDirectories: false,
                attributes: nil,
                error: &createDirectoryError)
        XCTAssertTrue(createSuccess, "The create should succeed")
        XCTAssertNil(createDirectoryError, "The error should be nil")

        // Test that the folder exists
        var isDir: ObjCBool = false
        var exists = NSFileManager.defaultManager().fileExistsAtPath(destinationFolderURL.path!, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(isDir, "The file should be a directory")
    
        // Duplicate the plugin
        var duplicatePlugin: Plugin!
        let duplicateExpectation = expectationWithDescription("Duplicate")
        duplicatePluginController.duplicatePlugin(plugin, toDirectoryAtURL: pluginsDirectoryURL) { (plugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            XCTAssertNotNil(plugin, "The plugin should not be nil")
            duplicatePlugin = plugin
            duplicateExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Assert the folder name equals the plugin's identifier
        let duplicatePluginFolderName = duplicatePlugin.bundle.bundlePath.lastPathComponent as NSString
        XCTAssertEqual(duplicatePluginFolderName, DuplicatePluginController.pluginFilenameFromName(duplicatePlugin.identifier), "The folder name should equal the identifier")

        // Test that the folder exists
        isDir = false
        exists = NSFileManager.defaultManager().fileExistsAtPath(destinationFolderURL.path!, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(isDir, "The file should be a directory")
    }

}