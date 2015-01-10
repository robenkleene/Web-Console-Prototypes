//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

extension PluginManager {
    convenience init(_ paths: [String],
        duplicatePluginDestinationDirectoryURL: NSURL,
        pluginDataEventManager: PluginDataEventManager)
    {
        self.init(paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        self.pluginDataController.delegate = pluginDataEventManager
        pluginDataEventManager.delegate = self
    }
}

class PluginManagerTests: PluginDataEventManagerTestCase {
    var pluginManager: PluginManager!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager([temporaryPluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL,
            pluginDataEventManager: pluginDataEventManager)
    }

    override func tearDown() {
        pluginManager.pluginDataController.delegate = nil
        pluginManager = nil

        super.tearDown()
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }

    // TODO: Make all the same `PluginDataControllerTests` work here and confirm `pluginWithName` behaves as it should for each
    // TODO: Test that after renaming a plugin `pluginWithName` works with the new name and not the old name
    // This should work now!
}
