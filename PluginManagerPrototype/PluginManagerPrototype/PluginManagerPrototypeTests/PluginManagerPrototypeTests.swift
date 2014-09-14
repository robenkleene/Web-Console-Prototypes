//
//  PluginManagerPrototypeTests.swift
//  PluginManagerPrototypeTests
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

import PluginManagerPrototype

let testPluginName = "HTML"

class PluginManagerPrototypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        PluginManager.sharedInstance.loadPlugins()
    }

//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
    
    func testPlugin() {
        let testPlugin = PluginManager.sharedInstance.plugin(testPluginName)
        XCTAssert(testPlugin!.name == testPluginName, "The test Plugin's name should match the test plugin name")
    }
}