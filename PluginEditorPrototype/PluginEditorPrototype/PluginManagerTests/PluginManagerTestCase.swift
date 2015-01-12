//
//  PluginManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
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

class PluginManagerTestCase: PluginDataEventManagerTestCase {
    var pluginManager: PluginManager!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager([temporaryPluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL,
            pluginDataEventManager: pluginDataEventManager)
        plugin = pluginManager.pluginWithName(testPluginName)
        XCTAssertTrue(contains(pluginManager.plugins(), plugin), "The plugins should contain the plugin")
    }
    
    override func tearDown() {
        pluginManager.pluginDataController.delegate = nil
        pluginManager = nil
        plugin = nil
        super.tearDown()
    }
}
