//
//  WCLFileExtensionsControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/23/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class WCLFileExtensionsControllerTests: PluginsManagerTestCase {

    func extensions(extensions1: [String], matchExtensions extensions2: [String]) -> Bool {
        let sortedExtensions1: NSArray = extensions1.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        let sortedExtensions2: NSArray = extensions2.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        return sortedExtensions1 == sortedExtensions2
    }

    override func setUp() {
        super.setUp()

        // Remove all starting file extensions
        let plugins: [Plugin]! = PluginsManager.sharedInstance.plugins() as? [Plugin]
        for aPlugin in plugins {
            aPlugin.extensions = testPluginExtensionsEmpty
        }

        XCTAssertFalse(WCLFileExtensionsController.sharedFileExtensionsController().extensions().count > 0, "The file extensions count should be zero");
    }
    
    override func tearDown() {
        super.tearDown()
    }


    
    func testAddingPluginAndChangingFileExtensions() {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectationWithDescription("Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (newPlugin) -> Void in
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        
    }
    
    // TODO: Test starting `WCLFileExtensionsController` has the right count of extensions
    
//    - (void)testAddingPluginAndChangingFileExtensions
//    {
//    // Hitting file extensions early makes sure that the singletons are instantiated and observers are in place.
//    XCTAssertFalse([[[WCLFileExtensionController_old sharedFileExtensionController] extensions] count] > 0, @"There should not be any file extensions before adding a plugin.");
//    
//    WCLPlugin_old *plugin = [self addedPlugin];
//    
//    // Set file extensions to an array of file extensions
//    plugin.extensions = kTestExtensions;
//    
//    NSArray *extensions = [[WCLFileExtensionController_old sharedFileExtensionController] extensions];
//    BOOL extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensions];
//    XCTAssertTrue(extensionsMatch, @"The file extensions should match the test file extensions.");
//    
//    
//    // Set file extensions to an empty array
//    plugin.extensions = kTestExtensionsEmpty;
//    
//    extensions = [[WCLFileExtensionController_old sharedFileExtensionController] extensions];
//    extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensionsEmpty];
//    XCTAssertTrue(extensionsMatch, @"The file extensions should match the empty test file extensions.");
//    
//    
//    // Set file extensions to nil
//    plugin.extensions = nil;
//    
//    extensions = [[WCLFileExtensionController_old sharedFileExtensionController] extensions];
//    extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensionsEmpty];
//    XCTAssertTrue(extensionsMatch, @"The file extensions should match the empty test file extensions.");
//    }
}
