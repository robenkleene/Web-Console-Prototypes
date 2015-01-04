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
    struct ClassConstants {
        static let tempDirectoryName = "Copy Directory Test"
    }

    
    override func setUp() {
        super.setUp()
        copyDirectoryController = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)
    }
    
    override func tearDown() {
        super.tearDown()
        copyDirectoryController = nil
    }


    func testCleanUpOnInit() {
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

        // Assert the contents is empty
        var contentsError: NSError?
        let keys: Array<AnyObject> = [NSURLNameKey]
        let options = NSDirectoryEnumerationOptions.SkipsHiddenFiles | NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtURL(copyDirectoryController.copyTempDirectoryURL,
            includingPropertiesForKeys: keys,
            options: options,
            error: &contentsError)
        XCTAssertNil(contentsError, "The error should be nil")
        XCTAssertFalse(contents!.isEmpty, "The contents should not be empty")

        // Init a new CopyDirectoryController
        let copyDirectoryControllerTwo = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)
        
        // Assert directory is empty
        var contentsErrorTwo: NSError?
        let contentsTwo = NSFileManager.defaultManager().contentsOfDirectoryAtURL(copyDirectoryController.copyTempDirectoryURL,
            includingPropertiesForKeys: keys,
            options: options,
            error: &contentsErrorTwo)
        XCTAssertNil(contentsErrorTwo, "The error should be nil")
        XCTAssertTrue(contentsTwo!.isEmpty, "The contents should be empty")

        // Clean Up
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.TrashDirectory, .UserDomainMask, true)[0] as NSString
        let recoveredFilesPath = trashDirectory.stringByAppendingPathComponent(copyDirectoryControllerTwo.trashDirectoryName)
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(recoveredFilesPath, isDirectory: &isDir)
        XCTAssertTrue(exists, "The item should exist")
        XCTAssertTrue(isDir, "The item should be a directory")
        var removeError: NSError?
        NSFileManager.defaultManager().removeItemAtPath(recoveredFilesPath, error: &removeError)
    }
}
