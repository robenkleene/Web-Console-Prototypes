//
//  PluginCopyControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginCopyControllerTests: XCTestCase {
    let pluginCopyController = PluginCopyController()
    
    func testCleanup() {
        let pluginManager = PluginManager(testPluginPaths)
        let plugin = pluginManager.pluginWithName(testPluginName)
        
        pluginCopyController.copyPlugin(plugin!, toURL: pluginCopyController.copyTempDirectoryURL)

        // Assert the directory is not empty
        let path = pluginCopyController.copyTempDirectoryURL.path!
        var error: NSError?
        var contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssert(!contents!.isEmpty, "The contents should be empty")
        
        pluginCopyController.cleanUp()

        // Assert directory is empty
        error = nil
        contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssert(contents!.isEmpty, "The contents should be empty")
    }
}
