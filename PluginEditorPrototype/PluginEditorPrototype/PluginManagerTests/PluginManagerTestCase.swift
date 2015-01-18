//
//  PluginManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginManagerTestCase: TemporaryPluginsTestCase {
    var pluginManager: PluginManager!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager([temporaryPluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL)
        plugin = pluginManager.pluginWithName(testPluginName)
        XCTAssertTrue(pluginManager.plugins().containsObject(plugin), "The plugins should contain the plugin")
    }
    
    override func tearDown() {
        pluginManager = nil
        plugin = nil
        super.tearDown()
    }

}
