//
//  PluginDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class PluginDirectoryManagerTestCase: TemporaryPluginTestCase {
    func testPluginDirectoryManager() {
        if let temporaryPlugin = temporaryPlugin {
            println("temporaryPlugin = \(temporaryPlugin)")

            // TODO: Instantiate a plugin directory manager for the parent directory
            // TODO: Move the `info.plist`
            // TODO: Confirm that the right call backs fire
        }
    }
}