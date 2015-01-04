//
//  CopyDirectoryControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/4/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class CopyDirectoryControllerTests: TemporaryPluginsTestCase {
    var copyDirectoryController: CopyDirectoryController!
    
    override func setUp() {
        super.setUp()
        copyDirectoryController = CopyDirectoryController(tempDirectoryName: "Copy Directory Test")
    }
    
    override func tearDown() {
        super.tearDown()
        copyDirectoryController = nil
    }


    func testCleanUp() {
        // Copy the plugin to the temp directory
        // Init a new CopyDirectoryController
        // Confirm the directory is empty
        // Confirm the items are in the trash
        // Delete the items from the trash

        let pluginFileURL = temporaryPlugin.bundle.bundleURL
        let copyExpectation = expectationWithDescription("Copy")
        copyDirectoryController.copyItemAtURL(pluginFileURL, completionHandler: { (URL, error) -> Void in
            XCTAssertNotNil(URL, "The URL should not be nil")
            XCTAssertNil(error, "The error should be nil")

            if let URL = URL {
                let movedFilename = testDirectoryName
                let movedDirectoryURL: NSURL! = URL.URLByDeletingLastPathComponent
                let movedDestinationURL = movedDirectoryURL.URLByAppendingPathComponent(movedFilename)
                var moveError: NSError?
                let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(URL, toURL: movedDestinationURL, error: &moveError)
                copyExpectation.fulfill()
            }
        })
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        

//        // Assert the directory is not empty
//        let path = pluginDuplicateController.duplicateTempDirectoryURL.path!
//        var error: NSError?
//        var contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
//        XCTAssertNil(error, "The error should be nil")
//        XCTAssertFalse(contents!.isEmpty, "The contents should not be empty")
//
//        pluginDuplicateController.cleanUp()
//
//        // Assert directory is empty
//        error = nil
//        contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error)
//        XCTAssertNil(error, "The error should be nil")
//        XCTAssertTrue(contents!.isEmpty, "The contents should be empty")
    }



}
