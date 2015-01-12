//
//  PluginDataControllerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginDataControllerTestCase: PluginDataEventManagerTestCase {

    var pluginDataController: PluginDataController!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginDataController = PluginDataController([temporaryPluginsDirectoryPath], duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL)
        pluginDataController.delegate = pluginDataEventManager
        XCTAssertEqual(pluginDataController.plugins().count, 1, "The plugins count should equal one")
        plugin = pluginDataController.plugins()[0]
    }
    
    override func tearDown() {
        pluginDataController.delegate = nil
        pluginDataController = nil // Make sure this happens after setting its delegate to nil
        super.tearDown()
    }

}