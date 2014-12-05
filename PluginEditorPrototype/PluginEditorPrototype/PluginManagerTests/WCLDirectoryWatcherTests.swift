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
    var itemWasCreatedOrModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    var itemWasRemovedAtPathHandlers: Array<((path: NSString) -> Void)>
    override init() {
        self.itemWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.itemWasRemovedAtPathHandlers = Array<((path: NSString) -> Void)>()
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, itemWasCreatedOrModifiedAtPath path: String!) {
        assert(itemWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = itemWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, itemWasRemovedAtPath path: String!) {
        assert(itemWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasRemovedAtPathHandlers.count > 0) {
            let handler = itemWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addItemWasCreatedOrModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        itemWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addItemWasRemovedAtPathHandler(handler: ((path: NSString) -> Void)) {
        itemWasRemovedAtPathHandlers.append(handler)
    }
}

class WCLDirectoryWatcherTestCase: TemporaryDirectoryTestCase {
    var directoryWatcher: WCLDirectoryWatcher?
    var directoryWatcherTestManager: WCLDirectoryWatcherTestManager?
    
    override func setUp() {
        super.setUp()
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
            directoryWatcherTestManager = WCLDirectoryWatcherTestManager()
            directoryWatcher?.delegate = directoryWatcherTestManager
        }
    }
    
    override func tearDown() {
        directoryWatcherTestManager = nil
        directoryWatcher?.delegate = nil
        directoryWatcher = nil
        super.tearDown()
    }
}

class WCLDirectoryWatcherFileTestCase: WCLDirectoryWatcherTestCase {
    
    func createFileAtPathWithConfirmation(path: NSString) {
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
        directoryWatcherTestManager?.addItemWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }

    func modifyFileAtPathWithConfirmation(path: NSString) {
        let fileWasModifiedExpectation = expectationWithDescription("File was modified")
        directoryWatcherTestManager?.addItemWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFileAtPath(path, contents: testFileContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func removeFileAtPathWithConfirmation(path: NSString) {
        // Remove Expectation
        let fileWasRemovedExpectation = expectationWithDescription("File was removed")
        directoryWatcherTestManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func moveFileAtPathWithConfirmation(path: NSString, destinationPath: NSString) {
        // Remove original
        let fileWasRemovedExpectation = expectationWithDescription("File was removed with move")
        directoryWatcherTestManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let fileWasCreatedExpectation = expectationWithDescription("File was created with move")
        directoryWatcherTestManager?.addItemWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == destinationPath) {
                fileWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveFileAtPath(path, toPath: destinationPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func testCreateWriteAndRemoveFile() {
        if let testFilePath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testFilename) {

            // Test Create
            createFileAtPathWithConfirmation(testFilePath)
            
            // Test Modify
            modifyFileAtPathWithConfirmation(testFilePath)
            
            // Test Remove
            removeFileAtPathWithConfirmation(testFilePath)

            // Test Create again
            createFileAtPathWithConfirmation(testFilePath)
            
            // Clean up

            // Test Remove again
            removeFileAtPathWithConfirmation(testFilePath)
        }
    }

    func testMoveFile() {
        if let testFilePath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testFilename) {
            
            // Test Create With Write
            modifyFileAtPathWithConfirmation(testFilePath)

            // Test Move
            let testFilePathTwo = testFilePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testFilenameTwo)
            moveFileAtPathWithConfirmation(testFilePath, destinationPath: testFilePathTwo)
            
            // Test Modify
            modifyFileAtPathWithConfirmation(testFilePathTwo)
            
            // Test Move Again
            moveFileAtPathWithConfirmation(testFilePathTwo, destinationPath: testFilePath)

            // Modify Again
            modifyFileAtPathWithConfirmation(testFilePath)
            
            // Clean up
                
            // Test Remove
            removeFileAtPathWithConfirmation(testFilePath)
        }
    }
    
    // TODO: If we can distinguish between move and modify events, then do more tests with more ordering variations (e.g., modify before move)

    func testFileManager() {
        if let testFilePath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testFilename) {
            // Test Create
            
            // Create expectation
            let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
            directoryWatcherTestManager?.addItemWasCreatedOrModifiedAtPathHandler({ path -> Void in
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
            directoryWatcherTestManager?.addItemWasRemovedAtPathHandler({ path -> Void in
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
    
    func testFileManagerAsync() {
        if let testFilePath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testFilename) {
                
            // Test Create

            
            // Create expectation
            let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
            directoryWatcherTestManager?.addItemWasCreatedOrModifiedAtPathHandler({ path -> Void in
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
            directoryWatcherTestManager?.addItemWasRemovedAtPathHandler({ path -> Void in
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