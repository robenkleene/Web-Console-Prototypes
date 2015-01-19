//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginManagerTestCase: TemporaryPluginsTestCase {
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        
        // Create the plugin manager
        let pluginManager = PluginManager([pluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: pluginsDirectoryURL)
        PluginManager.setOverrideSharedInstance(pluginManager)

        // Set the plugin
        plugin = pluginManager.pluginWithName(testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        plugin = nil
        PluginManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }
    
}