//
//  PluginsDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

//class PluginsDirectoryManagerExpectationHelper: PluginsDirectoryManagerDelegate {
//    let expectation: XCTestExpectation
//    init(_ expectation: XCTestExpectation) {
//        self.expectation = expectation
//    }
//
//    func directoryWillChange(directoryURL: NSURL) {
//        println("Fulfilled")
//        expectation.fulfill()
//    }
//}

class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {
    func renameItemAtURL(srcURL: NSURL, toName newFilename: NSString) {
        var error: NSError?
        let dstURL = srcURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newFilename)
        let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(srcURL, toURL: dstURL, error: &error)
        XCTAssertTrue(moveSuccess, "The move should succeed")
        XCTAssertNil(error, "The error should be nil")
    }
    
    
//    func testMovePlugin() {
//        if let temporaryDirectoryURL = temporaryDirectoryURL {
//            if let temporaryPlugin = temporaryPlugin {
//                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
//                
//                let expectation = expectationWithDescription("Plugins Directory Event")
//
//                // Move the plugin
//                var error: NSError?
//                let newPluginFilename = temporaryPlugin.identifier
//                let oldPluginURL = temporaryPlugin.bundle.bundleURL
//                let newPluginURL = oldPluginURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newPluginFilename)
//
//                println("newPluginURL = \(newPluginURL)")
//                
//                let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(oldPluginURL, toURL: newPluginURL, error: &error)
//                XCTAssertTrue(moveSuccess, "The move should succeed")
//                XCTAssertNil(error, "The error should be nil")
//
//                // Move it again
//                error = nil
//                let moveSuccess2 = NSFileManager.defaultManager().moveItemAtURL(newPluginURL, toURL: oldPluginURL, error: &error)
//                XCTAssertTrue(moveSuccess2, "The move should succeed")
//                XCTAssertNil(error, "The error should be nil")
//
//                
//                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
//                    println("Expectation")
//                })
//                
//                // TODO: Instantiate a plugin directory manager for the parent directory
//                // TODO: Move the `info.plist`
//                // TODO: Confirm that the right call backs fire
//            }
//        }
//    }

    func testRenameInfoDictionaryPath() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            if let temporaryPlugin = temporaryPlugin {
                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
                
//                let expectation = expectationWithDescription("Plugins Directory Event")
                
                // Move the plist
//                var error: NSError?
//                let oldInfoDictionaryURL = temporaryPlugin.infoDictionaryURL
//                let newInfoDictionaryFilename = temporaryPlugin.identifier
//                renameItemAtURL(oldInfoDictionaryURL, toName: newInfoDictionaryFilename)
                
                
                // TODO: Move it again
                
//                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
//                    println("Expectation")
//                })
            }
        }
    }

    
    // TODO: Gets notified moving the file
    // TODO: Gets notified modifying the plist
}