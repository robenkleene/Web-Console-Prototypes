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
    var fileWasCreatedOrModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    var fileWasRemovedAtPathHandlers: Array<((path: NSString) -> Void)>
    override init() {
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.fileWasRemovedAtPathHandlers = Array<((path: NSString) -> Void)>()
    }

    func directoryWatcher(directoryWatcher: AnyObject!, fileWasCreatedOrModifiedAtPath path: String!) {
        assert(fileWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasRemovedAtPath path: String!) {
        assert(fileWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasRemovedAtPathHandlers.count > 0) {
            let handler = fileWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addFileWasCreatedOrModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addFileWasRemovedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasRemovedAtPathHandlers.append(handler)
    }
}

class WCLDirectoryWatcherTests: TemporaryDirectoryTestCase {
    // TODO: Test just create file

    // TODO: Test just write file (should fire both callbacks)
    
    // TODO: Test write the file after blocking to create it, should only get the file modified callback
    
    func testCreateWriteAndRemoveFile() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename)
            {
                // Test Create
                
                // Setup create expectation
                let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasCreatedOrModifiedExpectation.fulfill()
                    }
                })

                // Create file
                SubprocessFileSystemModifier.createFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
                
                
                // Test Modify
                
                // Setup modified expectation
                let fileWasModifiedExpectation = expectationWithDescription("File was modified")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (path.stringByResolvingSymlinksInPath == testFilePath.stringByResolvingSymlinksInPath) {
                        fileWasModifiedExpectation.fulfill()
                    }
                })

                // Modifiy file
                SubprocessFileSystemModifier.writeToFileAtPath(testFilePath, contents: testFileContents)

                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)


                // Test Remove
                
                // Setup Remove Expectation
                let fileWasRemovedExpectation = expectationWithDescription("File was removed")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectation.fulfill()
                    }
                })
                SubprocessFileSystemModifier.removeFileAtPath(testFilePath)
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }
}

// TODO: Test deleting the file then creating it again

// TODO: Test a move (rename) event

// TODO: Test creating and modifying a file at once

// TODO: Test that events don't happen when using NSFileManager (e.g., ignore events from this process)