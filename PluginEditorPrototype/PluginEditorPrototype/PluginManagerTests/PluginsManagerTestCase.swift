//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerTestCase: TemporaryPluginsTestCase {
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        
        // Create the plugin manager
        let pluginsManager = PluginsManager([pluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: pluginsDirectoryURL)
        PluginsManager.setOverrideSharedInstance(pluginsManager)

        // Set the plugin
        plugin = pluginsManager.pluginWithName(testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        plugin = nil
        PluginsManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }
    
}