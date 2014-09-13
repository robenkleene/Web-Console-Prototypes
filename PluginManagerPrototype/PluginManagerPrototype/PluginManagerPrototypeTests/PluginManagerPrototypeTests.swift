//
//  PluginManagerPrototypeTests.swift
//  PluginManagerPrototypeTests
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

let testPluginName = "HTML"

class PluginManagerPrototypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.

        let path = self.dynamicType.pathToPlugin(testPluginName)
        
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    class func pathToPlugin(name: String) -> String {
        let bundle = NSBundle(forClass:self)
        let builtInPlugInsPath = bundle.builtInPlugInsPath
        
        println("builtInPlugInsPath = \(builtInPlugInsPath)")
        
        return ""
    }
}
