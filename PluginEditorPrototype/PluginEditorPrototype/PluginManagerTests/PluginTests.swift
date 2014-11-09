//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

class PluginTests: TemporaryPluginTestCase {
    
    func testRenamePluginDirectory() {
        
        var reloadPluginURL: NSURL?

        if let temporaryPlugin = temporaryPlugin {
            // Store the original command path
            let commandPath = temporaryPlugin.commandPath!
            // Store the contents at the original command path
            var error: NSError?
            let contents = NSString(contentsOfFile:commandPath, encoding:NSUTF8StringEncoding, error:&error) as String!
            XCTAssertNil(error, "The error should be nil")
            
            // Move the plugin
            let newPluginFilename = temporaryPlugin.identifier
            let oldPluginURL = temporaryPlugin.bundle.bundleURL
            
            println("oldPluginURL = \(oldPluginURL)")
            
            let newPluginURL = oldPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newPluginFilename)
            error = nil
            
            println("newPluginURL = \(newPluginURL)")
            
            let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(oldPluginURL, toURL: newPluginURL, error: &error)
            XCTAssertTrue(moveSuccess, "The move should succeed")
            XCTAssertNil(error, "The error should be nil")
            
            // TODO: Refactor this test, reloading the plugin should be handled with the PluginsDirectoryManager
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
    
    //    func testRenamePlugin() {
    //
    //    }
    
}


