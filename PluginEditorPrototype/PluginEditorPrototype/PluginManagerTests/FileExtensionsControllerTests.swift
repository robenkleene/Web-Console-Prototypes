//
//  WCLFileExtensionsControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/23/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class FileExtensionsControllerTests: FileExtensionsTestCase {

    func extensionsTest(extensions1: [String], matchExtensions extensions2: [String]) -> Bool {
        let sortedExtensions1: NSArray = extensions1.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        let sortedExtensions2: NSArray = extensions2.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        return sortedExtensions1 == sortedExtensions2
    }
    
    // TODO: After starting plugins have their extensions setup, test starting `WCLFileExtensionsController` has the right count of extensions at init (sum the count of plugin extensions, remove duplicates)
    
    func testAddingPluginAndChangingFileExtensions() {
        var createdPlugin = newPluginWithConfirmation()
        XCTAssertFalse(FileExtensionsController.sharedInstance.suffixes().count > 0, "The file extensions count should be zero")
        
        createdPlugin.suffixes = testPluginSuffixesTwo
        let extensions: [String] = FileExtensionsController.sharedInstance.suffixes() as [String]
        let extensionsMatch = extensionsTest(extensions, matchExtensions: testPluginSuffixesTwo)
        XCTAssertTrue(extensionsMatch, "The file extensions should match the test file extensions.")

        // Set file extensions to empty array
        plugin.suffixes = testPluginSuffixesEmpty
 
        let extensionsTwo: [String] = FileExtensionsController.sharedInstance.suffixes() as [String]
        let extensionsTwoMatch = extensionsTest(extensionsTwo, matchExtensions: testPluginSuffixesEmpty)
        XCTAssertTrue(extensionsMatch, "The file extensions should match the empty test file extensions.")
    }

}
