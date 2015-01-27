//
//  WCLFileExtensionsTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/25/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class FileExtensionsTestCase: PluginsManagerTestCase {

    func emptyFileExtensions() {
        // Remove all starting file extensions
        let plugins: [Plugin]! = PluginsManager.sharedInstance.plugins() as? [Plugin]
        for aPlugin in plugins {
            aPlugin.suffixes = testPluginSuffixesEmpty
        }
        
        XCTAssertFalse(FileExtensionsController.sharedInstance.suffixes().count > 0, "The file extensions count should be zero")
    }
    
    override func setUp() {
        super.setUp()
        emptyFileExtensions()
        // Create the plugin manager
        let fileExtensionsController = FileExtensionsController(pluginsManager: PluginsManager.sharedInstance)
        FileExtensionsController.setOverrideSharedInstance(fileExtensionsController)
    }
    
    override func tearDown() {
        emptyFileExtensions()
        FileExtensionsController.setOverrideSharedInstance(nil)
        super.tearDown()
    }

}
