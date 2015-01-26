//
//  WCLFileExtensionsControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/23/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class FileExtensionsControllerTests: PluginsManagerTestCase {

    func extensionsTest(extensions1: [String], matchExtensions extensions2: [String]) -> Bool {
        let sortedExtensions1: NSArray = extensions1.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        let sortedExtensions2: NSArray = extensions2.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        return sortedExtensions1 == sortedExtensions2
    }

    override func setUp() {
        super.setUp()

        // Remove all starting file extensions
        let plugins: [Plugin]! = PluginsManager.sharedInstance.plugins() as? [Plugin]
        for aPlugin in plugins {
            aPlugin.fileSuffixes = testPluginExtensionsEmpty
        }

        XCTAssertFalse(FileExtensionsController.sharedInstance.extensions().count > 0, "The file extensions count should be zero")
    }


    // TODO: After starting plugins have their extensions setup, test starting `WCLFileExtensionsController` has the right count of extensions at init (sum the count of plugin extensions, remove duplicates)
    
    func testAddingPluginAndChangingFileExtensions() {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectationWithDescription("Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (newPlugin) -> Void in
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        XCTAssertFalse(FileExtensionsController.sharedInstance.extensions().count > 0, "The file extensions count should be zero")
        
        createdPlugin.fileSuffixes = testPluginExtensionsTwo
        let extensions: [String] = FileExtensionsController.sharedInstance.extensions() as [String]
        let extensionsMatch = extensionsTest(extensions, matchExtensions: testPluginExtensionsTwo)
        XCTAssertTrue(extensionsMatch, "The file extensions should match the test file extensions.")

        // Set file extensions to empty array
        plugin.fileSuffixes = testPluginExtensionsEmpty
 
        let extensionsTwo: [String] = FileExtensionsController.sharedInstance.extensions() as [String]
        let extensionsTwoMatch = extensionsTest(extensionsTwo, matchExtensions: testPluginExtensionsEmpty)
        XCTAssertTrue(extensionsMatch, "The file extensions should match the empty test file extensions.")
    }

}
