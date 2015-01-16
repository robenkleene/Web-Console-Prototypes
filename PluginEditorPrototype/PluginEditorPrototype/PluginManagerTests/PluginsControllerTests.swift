//
//  PluginsControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsControllerTests: TemporaryPluginsTestCase {
    var pluginsController: PluginsController!
    
    override func setUp() {
        super.setUp()
        pluginsController = PluginsController([temporaryPlugin])
    }
    
    override func tearDown() {
        pluginsController = nil
        super.tearDown()
    }

    func fileURLOfDuplicatedItemAtURL(fileURL: NSURL, withFilename filename: NSString) -> NSURL {
        let destinationFileURL = fileURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(filename)
        var copyError: NSError?
        let copySuccess = NSFileManager.defaultManager().copyItemAtURL(fileURL, toURL: destinationFileURL, error: &copyError)
        XCTAssertTrue(copySuccess, "The copy should succeed")
        XCTAssertNil(copyError, "The error should be nil")
        return destinationFileURL
    }
    
    func testAddPlugin() {
        let destinationPluginURL = fileURLOfDuplicatedItemAtURL(temporaryPlugin.bundle.bundleURL, withFilename: temporaryPlugin.identifier)
        let newPlugin = Plugin.pluginWithURL(destinationPluginURL)!
        pluginsController.addPlugin(newPlugin)
        XCTAssertEqual(pluginsController.plugins().count, 1, "The plugins count should be one")
        XCTAssertEqual(pluginsController.pluginWithName(newPlugin.name)!, newPlugin, "The plugins should be equal")
        XCTAssertTrue(pluginsController.plugins().containsObject(newPlugin), "The plugins should contain the new plugin")
        XCTAssertFalse(pluginsController.plugins().containsObject(temporaryPlugin), "The plugins should not contain the temporary plugin")
        
        // Clean up
        var removeError: NSError?
        let success = NSFileManager.defaultManager().removeItemAtURL(destinationPluginURL, error: &removeError)
        XCTAssertTrue(success, "The remove should succeed")
        XCTAssertNil(removeError, "The error should be nil")
    }

    func testAddPlugins() {

        let newPluginFilename = testDirectoryName
        let newPluginURL = fileURLOfDuplicatedItemAtURL(temporaryPlugin.bundle.bundleURL, withFilename: newPluginFilename)
        let newPlugin = Plugin.pluginWithURL(newPluginURL)!

        let newPluginTwoFilename = testDirectoryNameTwo
        let newPluginTwoURL = fileURLOfDuplicatedItemAtURL(temporaryPlugin.bundle.bundleURL, withFilename: newPluginTwoFilename)
        let newPluginTwo = Plugin.pluginWithURL(newPluginURL)!

        let newPluginChangedNameFilename = testDirectoryNameThree
        let newPluginChangedNameURL = fileURLOfDuplicatedItemAtURL(temporaryPlugin.bundle.bundleURL, withFilename: newPluginChangedNameFilename)
        let newPluginChangedName = Plugin.pluginWithURL(newPluginURL)!
        let changedName = testDirectoryName
        newPluginChangedName.name = changedName

        let newPluginChangedNameTwoFilename = testDirectoryNameFour
        let newPluginChangedNameTwoURL = fileURLOfDuplicatedItemAtURL(temporaryPlugin.bundle.bundleURL, withFilename: newPluginChangedNameTwoFilename)
        let newPluginChangedNameTwo = Plugin.pluginWithURL(newPluginURL)!
        newPluginChangedNameTwo.name = changedName
        
        let newPlugins = [newPlugin, newPluginTwo, newPluginChangedName, newPluginChangedNameTwo]
        let newPluginURLs = [newPluginURL, newPluginTwoURL, newPluginChangedNameURL, newPluginChangedNameTwoURL]
        
        pluginsController.addPlugins(newPlugins)

        
        XCTAssertEqual(pluginsController.plugins().count, 2, "The plugins count should be one")
        
        // Test New Plugins
        XCTAssertEqual(pluginsController.pluginWithName(newPluginTwo.name)!, newPluginTwo, "The plugins should be equal")
        XCTAssertTrue(pluginsController.plugins().containsObject(newPluginTwo), "The plugins should contain the second new plugin")
        XCTAssertFalse(pluginsController.plugins().containsObject(newPlugin), "The plugins should not contain the new plugin")
        XCTAssertFalse(pluginsController.plugins().containsObject(temporaryPlugin), "The plugins should not contain the temporary plugin")
        
        // Test New Plugins Changed Name
        XCTAssertEqual(pluginsController.pluginWithName(newPluginChangedNameTwo.name)!, newPluginChangedNameTwo, "The plugins should be equal")
        XCTAssertTrue(pluginsController.plugins().containsObject(newPluginChangedNameTwo), "The plugins should contain the second new plugin changed name")
        XCTAssertFalse(pluginsController.plugins().containsObject(newPluginChangedName), "The plugins should not contain the new plugin changed name")

        for pluginURL: NSURL in newPluginURLs {
            // Clean up
            var removeError: NSError?
            let success = NSFileManager.defaultManager().removeItemAtURL(pluginURL, error: &removeError)
            XCTAssertTrue(success, "The remove should succeed")
            XCTAssertNil(removeError, "The error should be nil")
        }
    }
    
    // TODO: KVO tests? Assert that KVO events fire when the KVC relationship compliance mathods are used?
}
