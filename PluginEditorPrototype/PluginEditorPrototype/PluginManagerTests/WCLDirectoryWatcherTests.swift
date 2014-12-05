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
    var directoryWasCreatedOrModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    var directoryWasRemovedAtPathHandlers: Array<((path: NSString) -> Void)>

    override init() {
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.fileWasRemovedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.directoryWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.directoryWasRemovedAtPathHandlers = Array<((path: NSString) -> Void)>()
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

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, directoryWasCreatedOrModifiedAtPath path: String!) {
        assert(directoryWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (directoryWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = directoryWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, directoryWasRemovedAtPath path: String!) {
        assert(directoryWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (directoryWasRemovedAtPathHandlers.count > 0) {
            let handler = directoryWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addFileWasCreatedOrModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addFileWasRemovedAtPathHandler(handler: ((path: NSString) -> Void)) {
        fileWasRemovedAtPathHandlers.append(handler)
    }

    func addDirectoryWasCreatedOrModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        directoryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addDirectoryWasRemovedAtPathHandler(handler: ((path: NSString) -> Void)) {
        directoryWasRemovedAtPathHandlers.append(handler)
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

    // MARK: Create
    func createFileAtPathWithConfirmation(path: NSString) {
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
        directoryWatcherTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func createDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasCreatedOrModifiedExpectation = expectationWithDescription("Directory was created")
        directoryWatcherTestManager?.addDirectoryWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                directoryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createDirectoryAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // MARK: Modify
    func modifyFileAtPathWithConfirmation(path: NSString) {
        let fileWasModifiedExpectation = expectationWithDescription("File was modified")
        directoryWatcherTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFileAtPath(path, contents: testFileContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // MARK: Remove
    func removeFileAtPathWithConfirmation(path: NSString) {
        let fileWasRemovedExpectation = expectationWithDescription("File was removed")
        directoryWatcherTestManager?.addFileWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func removeDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasRemovedExpectation = expectationWithDescription("Directory was removed")
        directoryWatcherTestManager?.addDirectoryWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectoryAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // MARK: Move
    func moveFileAtPathWithConfirmation(path: NSString, destinationPath: NSString) {
        // Remove original
        let fileWasRemovedExpectation = expectationWithDescription("File was removed with move")
        directoryWatcherTestManager?.addFileWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let fileWasCreatedExpectation = expectationWithDescription("File was created with move")
        directoryWatcherTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == destinationPath) {
                fileWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveFileAtPath(path, toPath: destinationPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func moveDirectoryAtPathWithConfirmation(path: NSString, destinationPath: NSString) {
    }
}

class WCLDirectoryWatcherDirectoryTests: WCLDirectoryWatcherTestCase {
    func testCreateWriteAndRemoveDirectory() {
        if let testDirectoryPath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testDirectoryName) {
            let testFilePath = testDirectoryPath.stringByAppendingPathComponent(testFilename)

            // Test Create Directory
            createDirectoryAtPathWithConfirmation(testDirectoryPath)
            
            // Test Create File
            createFileAtPathWithConfirmation(testFilePath)

            // Test Modify File
            modifyFileAtPathWithConfirmation(testFilePath)

            // Test Remove File
            removeFileAtPathWithConfirmation(testFilePath)
            
            // Test Remove Directory
            removeDirectoryAtPathWithConfirmation(testDirectoryPath)

            // Test Create Directory Again
            createDirectoryAtPathWithConfirmation(testDirectoryPath)
            
            // Clean up

            // Test Remove Directory Again
            removeDirectoryAtPathWithConfirmation(testDirectoryPath)
        }
    }
}

class WCLDirectoryWatcherFileTests: WCLDirectoryWatcherTestCase {

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
    
    // TODO: Test creating and moving files in subdirectories
    // TODO: If we can distinguish between move and modify events, then do more tests with more ordering variations (e.g., modify before move)

    func testFileManager() {
        if let testFilePath = temporaryDirectoryURL?.path?.stringByAppendingPathComponent(testFilename) {
            // Test Create
            
            // Create expectation
            let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
            directoryWatcherTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
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
            directoryWatcherTestManager?.addFileWasRemovedAtPathHandler({ path -> Void in
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
            directoryWatcherTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
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
            directoryWatcherTestManager?.addFileWasRemovedAtPathHandler({ path -> Void in
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