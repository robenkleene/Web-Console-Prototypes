//
//  WCLDirectoryWatcherTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/20/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class WCLDirectoryWatcherTestManager: NSObject, WCLDirectoryWatcherDelegate {
    var fileWasCreatedAtPathHandlers: Array<((path: NSString) -> Void)>
    var fileWasModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    override init() {
        self.fileWasCreatedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.fileWasModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
    }

    func directoryWatcher(directoryWatcher: AnyObject!, fileWasCreatedAtPath path: String!) {
        assert(fileWasCreatedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addFileWasCreatedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasCreatedAtPathHandlers.append(handler)
    }

    func addFileWasModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasCreatedAtPathHandlers.append(handler)
    }

}

class WCLDirectoryWatcherTests: TemporaryDirectoryTestCase {

    func testFileSystemEvent() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename) {

                let fileWasCreatedExpectation = expectationWithDescription("directoryWatcher:fileWasCreatedAtPath:")
                directoryWatcherTestManager.addFileWasCreatedAtPathHandler({ (path) -> Void in
                    if (path.stringByResolvingSymlinksInPath == testFilePath.stringByResolvingSymlinksInPath) {
                        fileWasCreatedExpectation.fulfill()
                    }
                })
                let fileWasModifiedExpectation = expectationWithDescription("directoryWatcher:fileWasModifiedAtPath:")
                directoryWatcherTestManager.addFileWasModifiedAtPathHandler({ (path) -> Void in
                    if (path.stringByResolvingSymlinksInPath == testFilePath.stringByResolvingSymlinksInPath) {
                        fileWasModifiedExpectation.fulfill()
                    }
                })

                SubprocessFileSystemModifier.createFileAtPath(testFilePath)
                SubprocessFileSystemModifier.appendToFileAtPath(testFilePath, contents: testFileContents)
                
                // TODO: Add editing a file at path
                
                // TODO: Add deleting a file at path
                
                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
                    // Clean Up
//                    var error: NSError?
//                    let success = NSFileManager.defaultManager().removeItemAtPath(testFilePath, error: &error)
//                    assert(success && error == nil, "The remove should succeed")
                })
            }
        }
    }
}

// TODO: Test creating and modifying a file at once

// TODO: Test that events don't happen when using NSFileManager (e.g., ignore events from this process)