//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

class PluginTests: PluginsManagerTestCase {
    
//    func testRenamePluginDirectory() {
//        
//        var reloadPluginURL: NSURL?
//
//        if let temporaryPlugin = plugin {
//            // Store the original command path
//            let commandPath = temporaryPlugin.commandPath!
//            // Store the contents at the original command path
//            var error: NSError?
//            let contents = NSString(contentsOfFile:commandPath, encoding:NSUTF8StringEncoding, error:&error) as String!
//            XCTAssertNil(error, "The error should be nil")
//            
//            // Move the plugin
//            let newPluginFilename = temporaryPlugin.identifier
//            let oldPluginURL = temporaryPlugin.bundle.bundleURL
//            
//            let newPluginURL = oldPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newPluginFilename)
//            error = nil
//            
//            let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(oldPluginURL, toURL: newPluginURL, error: &error)
//            XCTAssertTrue(moveSuccess, "The move should succeed")
//            XCTAssertNil(error, "The error should be nil")
//            
//            // TODO: Refactor this test, reloading the plugin should be handled with the PluginsDirectoryManager
//            let newCommandPath = temporaryPlugin.commandPath!
//            //            let newContents = NSString(contentsOfFile:newCommandPath, encoding:NSUTF8StringEncoding, error:&error) as String!
//            //            XCTAssertNil(error, "The error should be nil")
//            //            XCTAssertEqual(contents, newContents, "The new contents should equal the old contents")
//            
//            
//            reloadPluginURL = newPluginURL
//        }
//        if let reloadPluginURL = reloadPluginURL {
//            // Reload the plugin with the new path so the tearDown delete succeeds
//            temporaryPlugin = Plugin.pluginWithURL(reloadPluginURL)
//        }
//        
//    }
    
//    func testRenamePlugin() {
//
//    }

    func infoDictionaryContentsForPluginWithConfirmation(plugin: Plugin) -> String {
        let pluginInfoDictionaryPath = Plugin.infoDictionaryURLForPlugin(plugin).path!
        var error: NSError?
        let infoDictionaryContents: NSString! = NSString(contentsOfFile: pluginInfoDictionaryPath, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        return infoDictionaryContents
    }
    
    func testEditPluginProperties() {
        let contents = infoDictionaryContentsForPluginWithConfirmation(plugin)

        plugin.name = testPluginNameTwo
        let contentsTwo = infoDictionaryContentsForPluginWithConfirmation(plugin)
        XCTAssertNotEqual(contents, contentsTwo, "The contents should not be equal")

        plugin.command = testPluginCommandTwo
        let contentsThree = infoDictionaryContentsForPluginWithConfirmation(plugin)
        XCTAssertNotEqual(contentsTwo, contentsThree, "The contents should not be equal")

        let uuid = NSUUID()
        let uuidString = uuid.UUIDString
        plugin.identifier = uuidString
        let contentsFour = infoDictionaryContentsForPluginWithConfirmation(plugin)
        XCTAssertNotEqual(contentsThree, contentsFour, "The contents should not be equal")

        plugin.suffixes = testPluginSuffixesTwo
        let contentsFive = infoDictionaryContentsForPluginWithConfirmation(plugin)
        XCTAssertNotEqual(contentsFour, contentsFive, "The contents should not be equal")
        let newPlugin: Plugin! = Plugin.pluginWithURL(pluginURL)

        XCTAssertEqual(plugin.name, newPlugin.name, "The names should be equal")
        XCTAssertEqual(plugin.command!, newPlugin.command!, "The commands should be equal")
        XCTAssertEqual(plugin.identifier, newPlugin.identifier, "The identifiers should be equal")
        XCTAssertEqual(plugin.suffixes, newPlugin.suffixes, "The file extensions should be equal")
    }

    func testNameValidation() {
        plugin.name = testPluginName

        // Test that the name is valid for this plugin
        var error: NSError?
        var name: AnyObject? = testPluginName
        var valid = plugin.validateName(&name, error: &error)
        XCTAssertTrue(valid, "The name should be valid")
        XCTAssertNil(error, "The error should be nil")

        // Create a new plugin
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectationWithDescription("Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (newPlugin) -> Void in
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Test that the name is not valid for another plugin
        error = nil
        name = testPluginName
        valid = createdPlugin.validateName(&name, error: &error)
        XCTAssertFalse(valid, "The name should not be valid")
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test that the new plugins name is invalid
        error = nil
        name = createdPlugin.name
        valid = plugin.validateName(&name, error: &error)
        XCTAssertFalse(valid, "The name should not be valid")
        XCTAssertNotNil(error, "The error should not be nil.")
        // Inverse
        error = nil
        name = plugin.name
        valid = createdPlugin.validateName(&name, error: &error)
        XCTAssertFalse(valid, "The name should not be valid")
        XCTAssertNotNil(error, "The error should not be nil.")
        
        // Test that the name is now valid for the second plugin
        name = plugin.name
        plugin.name = testPluginNameNoPlugin
        error = nil
        valid = createdPlugin.validateName(&name, error:&error)
        XCTAssertTrue(valid, "The name should be valid")
        XCTAssertNil(error, "The error should be nil.")

        // Test that the new name is now invalid
        error = nil
        name = plugin.name
        valid = createdPlugin.validateName(&name, error:&error)
        XCTAssertFalse(valid, "The name should not be valid")
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test that the created plugins name is valid after deleting
        error = nil
        name = createdPlugin.name
        valid = plugin.validateName(&name, error: &error)
        XCTAssertFalse(valid, "The name should not be valid")
        XCTAssertNotNil(error, "The error should not be nil.")
        // Delete
        movePluginToTrashAndCleanUpWithConfirmation(createdPlugin)
        // Test that the new name is now valid
        error = nil;
        valid = plugin.validateName(&name, error:&error)
        XCTAssertTrue(valid, "The name should be valid")
        XCTAssertNil(error, "The error should be nil.")
    }

    // WARNING Don't copy this as is, figure out a way to do this with mocks!
    // - (void)testPluginNames
    // {
    //     for (NSUInteger i = 0; i < 105; i++) {
    //         WCLPlugin_old *plugin = [self addedPlugin];
    //
    //         if (i == 0) {
    //             XCTAssertTrue([plugin.name isEqualToString:kTestDefaultNewPluginName], @"The WCLPlugin's name equal the default new plugin name.");
    //             continue;
    //         }
    //
    //         NSUInteger suffixCount = i + 1;
    //         if (suffixCount > 99) {
    //             XCTAssertTrue([plugin.name isEqualToString:plugin.identifier], @"The WCLPlugin's name should equal its identifier.");
    //             continue;
    //         }
    //
    //
    //         XCTAssertTrue([plugin.name hasPrefix:kTestDefaultNewPluginName], @"The WCLPlugin's name should start with the default new plugin name.");
    //         NSString *suffix = [NSString stringWithFormat:@"%lu", (unsigned long)suffixCount];
    //         XCTAssertTrue([plugin.name hasSuffix:suffix], @"The WCLPlugin's name should end with the suffix.");
    //     }
    // }

}

// TODO: Test extension validation
// TODO: Test KVO fires when modifying plugin properties. Only `dynamic` properties work with KVO?
// TODO: Test trying to run a plugin that has been unloaded? After deleting it's resources
// TODO: Add tests for invalid plugin info dictionaries, e.g., file extensions and commands can be nil

