//
//  TemporaryPluginsTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

class TemporaryPluginsTestCase: TemporaryDirectoryTestCase {
    var temporaryPlugin: Plugin!
    var temporaryPluginsDirectoryURL: NSURL!
    var temporaryPluginsDirectoryPath: NSString! {
        get {
            return temporaryPluginsDirectoryURL.path
        }
    }
    
    override func setUp() {
        super.setUp()
        
        if let pluginURL = URLForResource(testPluginName, withExtension:pluginFileExtension) {
            if let plugin = Plugin.pluginWithURL(pluginURL) {
                if let filename = plugin.name.stringByAppendingPathExtension(pluginFileExtension) {
                    // Create the plugins directory
                    temporaryPluginsDirectoryURL = temporaryDirectoryURL
                        .URLByAppendingPathComponent(pluginsDirectoryPathComponent)
                    var createDirectoryError: NSError?
                    let createSuccess = NSFileManager
                            .defaultManager()
                            .createDirectoryAtURL(temporaryPluginsDirectoryURL,
                                withIntermediateDirectories: false,
                                attributes: nil,
                                error: &createDirectoryError)
                    XCTAssertTrue(createSuccess, "The create should succeed")
                    XCTAssertNil(createDirectoryError, "The error should be nil")
                    
                    // Create the plugin directory
                    let temporaryPluginURL = temporaryPluginsDirectoryURL.URLByAppendingPathComponent(filename)
                    var movePluginError: NSError?
                    let moveSuccess = NSFileManager
                        .defaultManager()
                        .copyItemAtURL(pluginURL,
                            toURL: temporaryPluginURL,
                            error: &movePluginError)
                    XCTAssertTrue(moveSuccess, "The move should succeed")
                    XCTAssertNil(movePluginError, "The error should be nil")
                    temporaryPlugin = Plugin.pluginWithURL(temporaryPluginURL)
                }
            }
        }
        
        XCTAssertNotNil(temporaryPlugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        temporaryPlugin = nil
        temporaryPluginsDirectoryURL = nil
        
        // Remove the plugins directory (containing the plugin)
        let success = removeTemporaryItemAtPathComponent(pluginsDirectoryPathComponent)
        XCTAssertTrue(success, "Removing the plugins directory should have succeeded")

        super.tearDown()
    }
}