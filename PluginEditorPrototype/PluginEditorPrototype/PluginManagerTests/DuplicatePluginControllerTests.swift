//
//  DuplicatePluginControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class DuplicatePluginControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Mine here
    }

    override func tearDown() {
        // Mine here
        super.tearDown()
    }
    
    func testDuplicatePlugin() {
        
//        XCTAssertNotNil(testPlugin, "The plugin should not be nil")
//        XCTAssertNotEqual(plugin!.name, testPlugin!.name, "The test plugin's name should not equal the plugin's name")
//        XCTAssertNotEqual(plugin!.identifier, testPlugin!.identifier, "The test plugin's identifier should not equal the plugin's name")

        // TODO: Assert that the new plugins properties can be changed
        // TODO: Assert that after moving the bundle its URL is still accurate
        // TODO: Assert the directory matches the name
        // TODO: How to resolve issues around a plugins new URL? E.g., I've loaded the plugin and then change its URL
    }
}