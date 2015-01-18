//
//  PluginManagerSingletonTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginManagerSingletonTestCase: PluginManagerTestCase {

    override func setUp() {
        super.setUp()
        PluginManager.setOverrideSharedInstance(pluginManager)
    }
    
    override func tearDown() {
        PluginManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }

}
