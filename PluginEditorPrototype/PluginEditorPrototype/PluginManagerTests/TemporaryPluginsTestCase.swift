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
    var pluginsDirectoryURL: NSURL!
    var pluginsDirectoryPath: NSString! {
        get {
            return pluginsDirectoryURL.path
        }
    }
    var pluginURL: NSURL!
    var pluginPath: NSString! {
        get {
            return pluginURL.path
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
        let bundleResourcesPluginURL: NSURL! = URLForResource(testPluginName, withExtension:pluginFileExtension)
        let filename: NSString! = testPluginName.stringByAppendingPathExtension(pluginFileExtension)
        
        pluginURL = pluginsDirectoryURL.URLByAppendingPathComponent(filename)
        var movePluginError: NSError?
        let moveSuccess = NSFileManager
            .defaultManager()
            .copyItemAtURL(bundleResourcesPluginURL,
                toURL: pluginURL,
                error: &movePluginError)
        XCTAssertTrue(moveSuccess, "The move should succeed")
        XCTAssertNil(movePluginError, "The error should be nil")
    }
    
    override func tearDown() {
        pluginsDirectoryURL = nil
        pluginURL = nil
        
        // Remove the plugins directory (containing the plugin)
        let success = removeTemporaryItemAtPathComponent(pluginsDirectoryPathComponent)
        XCTAssertTrue(success, "Removing the plugins directory should have succeeded")
        super.tearDown()
    }
    
}