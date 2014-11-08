//
//  TemporaryPluginTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

class TemporaryPluginTestCase: TemporaryDirectoryTestCase {
    var temporaryPlugin: Plugin?
    
    override func setUp() {
        super.setUp()
        
        if let pluginURL = URLForResource(testPluginName, withExtension:pluginFileExtension) {
            if let plugin = Plugin.pluginWithURL(pluginURL) {
                if let filename = plugin.name.stringByAppendingPathExtension(pluginFileExtension) {
                    if let temporaryDirectoryURL = temporaryDirectoryURL {
                        let temporaryPluginURL = temporaryDirectoryURL.URLByAppendingPathComponent(filename)
                        var error: NSError?
                        let moveSuccess = NSFileManager.defaultManager().copyItemAtURL(pluginURL, toURL: temporaryPluginURL, error: &error)
                        XCTAssertTrue(moveSuccess, "The move should succeed")
                        XCTAssertNil(error, "The error should be nil")
                        temporaryPlugin = Plugin.pluginWithURL(temporaryPluginURL)
                    }
                }
            }
        }
        
        XCTAssertNotNil(temporaryPlugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        if let temporaryPlugin = temporaryPlugin {
            let filename = temporaryPlugin.bundle.bundlePath.lastPathComponent
            let success = removeTemporaryItemWithName(filename)
            XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
        }
        super.tearDown()
    }
}