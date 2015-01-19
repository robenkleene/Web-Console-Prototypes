//
//  PluginsDataControllerEventTestCase+FileSystemHelpers.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

extension PluginsDataControllerEventTestCase {
    // MARK: Move Helpers
    
    func movePluginWithConfirmation(plugin: Plugin, destinationPluginPath: NSString, handler: (plugin: Plugin?) -> Void) {
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: destinationPluginPath)
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Copy Helpers
    
    func copyPluginWithConfirmation(plugin: Plugin, destinationPluginPath: NSString, handler: (plugin: Plugin?) -> Void) {
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: destinationPluginPath)
        
        // TODO: Once the requirement that no two plugins have the same identifier is enforced, we'll also have to change the new plugins identifier here
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Remove Helpers
    
    func removePluginWithConfirmation(plugin: Plugin) {
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.removeDirectoryAtPath(pluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Modify Helpers
    
    func modifyPluginWithConfirmation(plugin: Plugin, handler: (plugin: Plugin?) -> Void) {
        let infoDictionaryPath: NSString! = plugin.infoDictionaryURL.path
        var error: NSError?
        let infoDictionaryContents: NSString! = NSString(contentsOfFile: infoDictionaryPath, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == pluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        SubprocessFileSystemModifier.writeToFileAtPath(infoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
}