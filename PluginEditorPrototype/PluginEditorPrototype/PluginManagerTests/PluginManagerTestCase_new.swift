//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginManagerTestCase_new: TemporaryDirectoryTestCase {
    var plugin: Plugin!
    var pluginsDirectoryURL: NSURL!
    var pluginsDirectoryPath: NSString! {
        get {
            return pluginsDirectoryURL.path
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // Create the plugins directory
        pluginsDirectoryURL = temporaryDirectoryURL
            .URLByAppendingPathComponent(pluginsDirectoryPathComponent)
        var createDirectoryError: NSError?
        let createSuccess = NSFileManager
            .defaultManager()
            .createDirectoryAtURL(pluginsDirectoryURL,
                withIntermediateDirectories: false,
                attributes: nil,
                error: &createDirectoryError)
        XCTAssertTrue(createSuccess, "The create should succeed")
        XCTAssertNil(createDirectoryError, "The error should be nil")

        // Copy the bundle resources plugin to the plugins directory
        if let bundleResourcesPluginURL = URLForResource(testPluginName, withExtension:pluginFileExtension) {
            if let filename = testPluginName.stringByAppendingPathExtension(pluginFileExtension) {
                
                let destinationPluginURL = pluginsDirectoryURL.URLByAppendingPathComponent(filename)
                var movePluginError: NSError?
                let moveSuccess = NSFileManager
                    .defaultManager()
                    .copyItemAtURL(bundleResourcesPluginURL,
                        toURL: destinationPluginURL,
                        error: &movePluginError)
                XCTAssertTrue(moveSuccess, "The move should succeed")
                XCTAssertNil(movePluginError, "The error should be nil")
            }
        }
        // Create the plugin manager
        let pluginManager = PluginManager([pluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: pluginsDirectoryURL)
        PluginManager.setOverrideSharedInstance(pluginManager)

        // Set the plugin
        plugin = pluginManager.pluginWithName(testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        pluginsDirectoryURL = nil
        plugin = nil
        PluginManager.setOverrideSharedInstance(nil)
        
        // Remove the plugins directory (containing the plugin)
        let success = removeTemporaryItemAtPathComponent(pluginsDirectoryPathComponent)
        XCTAssertTrue(success, "Removing the plugins directory should have succeeded")
        
        super.tearDown()
    }
    
}