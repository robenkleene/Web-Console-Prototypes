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

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
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

    func testCreateWriteAndRemoveFile() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename) {

                // Test Create
                
                // Create expectation
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
                
                // Modified expectation
                let fileWasModifiedExpectation = expectationWithDescription("File was modified")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasModifiedExpectation.fulfill()
                    }
                })

                // Modifiy file
                SubprocessFileSystemModifier.writeToFileAtPath(testFilePath, contents: testFileContents)

                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)


                // Test Remove
                
                // Remove Expectation
                let fileWasRemovedExpectation = expectationWithDescription("File was removed")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectation.fulfill()
                    }
                })

                // Remove file
                SubprocessFileSystemModifier.removeFileAtPath(testFilePath)

                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

                
                // Test Create again

                // Create expectation two
                let fileWasCreatedOrModifiedExpectationTwo = expectationWithDescription("File was created again")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasCreatedOrModifiedExpectationTwo.fulfill()
                    }
                })
                
                // Create file
                SubprocessFileSystemModifier.createFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
                
                
                
                // Clean up

                // Test Remove again
                
                // Remove Expectation two
                let fileWasRemovedExpectationTwo = expectationWithDescription("File was removed again")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectationTwo.fulfill()
                    }
                })
                SubprocessFileSystemModifier.removeFileAtPath(testFilePath)
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }

    func testMoveFile() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename) {

                // Test Create With Write
                
                // Create with write expectation
                let fileWasModifiedExpectation = expectationWithDescription("File was created with write")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasModifiedExpectation.fulfill()
                    }
                })
                
                // Create and write file
                SubprocessFileSystemModifier.writeToFileAtPath(testFilePath, contents: testFileContents)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
                

                // Test Move

                let testFilePathTwo = testFilePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testFilenameTwo)
                
                // Remove expectation
                let fileWasRemovedExpectation = expectationWithDescription("File was removed with move")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectation.fulfill()
                    }
                })
                
                // Create expectation
                let fileWasCreatedExpectation = expectationWithDescription("File was created with move")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePathTwo) {
                        fileWasCreatedExpectation.fulfill()
                    }
                })
                
                // Move file
                SubprocessFileSystemModifier.moveFileAtPath(testFilePath, toPath: testFilePathTwo)
                
                // Wait for expectations
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
                
                
                // Clean up
                
                // Test Remove
                
                // Remove expectation two
                let fileWasRemovedExpectationTwo = expectationWithDescription("File was removed again")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePathTwo) {
                        fileWasRemovedExpectationTwo.fulfill()
                    }
                })
                SubprocessFileSystemModifier.removeFileAtPath(testFilePathTwo)
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }

    func testFileManager() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename) {
                
                // Test Create
                
                // Create expectation
                let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasCreatedOrModifiedExpectation.fulfill()
                    }
                })
                
                // Test create a second file with NSFileManager
                let testFilePathTwo = testFilePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testFilenameTwo)
                let contentsData = testFileContents.dataUsingEncoding(NSUTF8StringEncoding)
                NSFileManager.defaultManager().createFileAtPath(testFilePathTwo, contents: contentsData, attributes: nil)
                
                // Create file
                SubprocessFileSystemModifier.createFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)


                // Test Remove
                
                // Remove Expectation
                let fileWasRemovedExpectation = expectationWithDescription("File was removed")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectation.fulfill()
                    }
                })
                
                // Test remove the second file with NSFileManager
                var error: NSError?
                let result = NSFileManager.defaultManager().removeItemAtPath(testFilePathTwo, error: &error)
                XCTAssertTrue(result, "The move should have succeeded")
                XCTAssertNil(error, "The error shoudl be nil")
                
                // Remove file
                SubprocessFileSystemModifier.removeFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }
    
    func testFileManagerAsync() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            let directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher.delegate = directoryWatcherTestManager
            
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent(testFilename) {
                
                // Test Create
                
                // Create expectation
                let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
                directoryWatcherTestManager.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasCreatedOrModifiedExpectation.fulfill()
                    }
                })
                
                // Test create a second file with NSFileManager
                let testFilePathTwo = testFilePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testFilenameTwo)
                let fileManagerCreateExpectation = expectationWithDescription("File manager created file")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let contentsData = testFileContents.dataUsingEncoding(NSUTF8StringEncoding)
                    NSFileManager.defaultManager().createFileAtPath(testFilePathTwo, contents: contentsData, attributes: nil)
                    fileManagerCreateExpectation.fulfill()
                }
                
                // Create file
                SubprocessFileSystemModifier.createFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
                
                
                // Test Remove
                
                // Remove Expectation
                let fileWasRemovedExpectation = expectationWithDescription("File was removed")
                directoryWatcherTestManager.addFileWasRemovedAtPathHandler({ path -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  testFilePath) {
                        fileWasRemovedExpectation.fulfill()
                    }
                })
                
                // Test remove the second file with NSFileManager
                let fileManagerRemoveExpectation = expectationWithDescription("File manager created file")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    var error: NSError?
                    let result = NSFileManager.defaultManager().removeItemAtPath(testFilePathTwo, error: &error)
                    XCTAssertTrue(result, "The move should have succeeded")
                    XCTAssertNil(error, "The error shoudl be nil")
                    fileManagerRemoveExpectation.fulfill()
                }
                
                // Remove file
                SubprocessFileSystemModifier.removeFileAtPath(testFilePath)
                
                // Wait for expectation
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }
}