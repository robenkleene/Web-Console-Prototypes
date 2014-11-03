//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

extension Plugin {
    var pluginPath: String {
        get {
            return bundle.bundlePath
        }
    }
    var pluginURL: NSURL {
        get {
            return bundle.bundleURL
        }
    }
}


class PluginTests: TemporaryDirectoryTestCase {
    var plugin: Plugin?
    var temporaryPlugin: Plugin?
    
    override func setUp() {
        super.setUp()

        if let pluginURL = URLForResource(testPluginName, withExtension:pluginFileExtension) {
            plugin = Plugin.pluginWithURL(pluginURL)
            if let plugin = plugin {
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

        XCTAssertNotNil(plugin, "The plugin should not be nil")
        XCTAssertNotNil(temporaryPlugin, "The temporary plugin should not be nil")
    }
    
    override func tearDown() {
        if let temporaryPlugin = temporaryPlugin {
            let filename = temporaryPlugin.pluginPath.lastPathComponent
            let success = removeTemporaryItemWithName(filename)
            XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
        }
        super.tearDown()
    }
    
    func testRenamePluginDirectory() {
        var reloadPluginURL: NSURL?
        if let temporaryPlugin = temporaryPlugin {
            let commandPath = temporaryPlugin.commandPath!
            
            println("commandPath = \(commandPath)")
            
            var error: NSError?
            let contents = NSString(contentsOfFile:commandPath, encoding:NSUTF8StringEncoding, error:&error) as String!
            XCTAssertNil(error, "The error should be nil")
            
            // Move the plugin
            let newPluginFilename = temporaryPlugin.identifier
            let oldPluginURL = temporaryPlugin.pluginURL

            println("oldPluginURL = \(oldPluginURL)")
            
            let newPluginURL = oldPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newPluginFilename)
            error = nil

            println("newPluginURL = \(newPluginURL)")
            
            let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(oldPluginURL, toURL: newPluginURL, error: &error)
            XCTAssertTrue(moveSuccess, "The move should succeed")
            XCTAssertNil(error, "The error should be nil")

            // TODO Refactor this test, reloading the plugin should be handled with the PluginDirectoryManager
            let newCommandPath = temporaryPlugin.commandPath!
            println("newCommandPath = \(newCommandPath)")
//            let newContents = NSString(contentsOfFile:newCommandPath, encoding:NSUTF8StringEncoding, error:&error) as String!
//            XCTAssertNil(error, "The error should be nil")
//            XCTAssertEqual(contents, newContents, "The new contents should equal the old contents")
            

            reloadPluginURL = newPluginURL
        }
        if let reloadPluginURL = reloadPluginURL {
            // Reload the plugin with the new path so the tearDown delete succeeds
            temporaryPlugin = Plugin.pluginWithURL(reloadPluginURL)
        }
    
    }

    func testRenamePlugin() {
        
    }

}
