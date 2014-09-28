//
//  PluginTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/28/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginTests: TemporaryDirectoryTestCase {
    var plugin: Plugin?

    
    
    override func setUp() {
        super.setUp()

        // Copy the plugin to the temporary directory

        // Load the plugin and set it as the plugin
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Delete the plugin
        super.tearDown()
    }
    
    func testSetName() {

        // TODO Test KVO?
    }

    func testSetIdentifier() {

        // TODO Test KVO?
    }

    func testSetNameAndIdentifier() {
        
        // TODO Test KVO?
    }
}
