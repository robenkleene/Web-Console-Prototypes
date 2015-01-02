//
//  WCLDirectoryWatcherTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/20/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class WCLDirectoryWatcherEventManager: NSObject, WCLDirectoryWatcherDelegate {
    var fileWasCreatedOrModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    var directoryWasCreatedOrModifiedAtPathHandlers: Array<((path: NSString) -> Void)>
    var itemWasRemovedAtPathHandlers: Array<((path: NSString) -> Void)>

    override init() {
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.directoryWasCreatedOrModifiedAtPathHandlers = Array<((path: NSString) -> Void)>()
        self.itemWasRemovedAtPathHandlers = Array<((path: NSString) -> Void)>()
    }

    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
        assert(fileWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
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
    
    func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, itemWasRemovedAtPath path: String!) {
        assert(itemWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasRemovedAtPathHandlers.count > 0) {
            let handler = itemWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addFileWasCreatedOrModifiedAtPathHandler(handler: (path: NSString) -> Void) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addDirectoryWasCreatedOrModifiedAtPathHandler(handler: (path: NSString) -> Void) {
        directoryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addItemWasRemovedAtPathHandler(handler: (path: NSString) -> Void) {
        itemWasRemovedAtPathHandlers.append(handler)
    }
}

class WCLDirectoryWatcherTestCase: TemporaryDirectoryTestCase {
    var directoryWatcher: WCLDirectoryWatcher!
    var directoryWatcherEventManager: WCLDirectoryWatcherEventManager!
    
    override func setUp() {
        super.setUp()
        directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)
        directoryWatcherEventManager = WCLDirectoryWatcherEventManager()
        directoryWatcher.delegate = directoryWatcherEventManager
    }
    
    override func tearDown() {
        directoryWatcherEventManager = nil
        directoryWatcher.delegate = nil
        directoryWatcher = nil
        super.tearDown()
    }

    // MARK: Create
    func createFileAtPathWithConfirmation(path: NSString) {
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
        directoryWatcherEventManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func createDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasCreatedOrModifiedExpectation = expectationWithDescription("Directory was created")
        directoryWatcherEventManager?.addDirectoryWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
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
        directoryWatcherEventManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
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
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func removeDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasRemovedExpectation = expectationWithDescription("Directory was removed")
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
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
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let fileWasCreatedExpectation = expectationWithDescription("File was created with move")
        directoryWatcherEventManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == destinationPath) {
                fileWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveItemAtPath(path, toPath: destinationPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func moveDirectoryAtPathWithConfirmation(path: NSString, destinationPath: NSString) {
        // Remove original
        let directoryWasRemovedExpectation = expectationWithDescription("Directory was removed with move")
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let directoryWasCreatedExpectation = expectationWithDescription("Directory was created with move")
        directoryWatcherEventManager?.addDirectoryWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == destinationPath) {
                directoryWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveItemAtPath(path, toPath: destinationPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
}

class WCLDirectoryWatcherDirectoryTests: WCLDirectoryWatcherTestCase {

    func testCreateWriteAndRemoveDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testDirectoryName)
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

    func testMoveDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testDirectoryName)
            
        // Test Create
        createDirectoryAtPathWithConfirmation(testDirectoryPath)

        // Test Move
        let testDirectoryPathTwo = testDirectoryPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testDirectoryNameTwo)
        moveDirectoryAtPathWithConfirmation(testDirectoryPath, destinationPath: testDirectoryPathTwo)
        
        // Test Move Again
        moveDirectoryAtPathWithConfirmation(testDirectoryPathTwo, destinationPath: testDirectoryPath)

        // Clean up
            
        // Test Remove
        removeDirectoryAtPathWithConfirmation(testDirectoryPath)
    }

    func testMoveDirectoryContainingFile() {
        let testDirectoryPath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testDirectoryName)
        let testFilePath = testDirectoryPath.stringByAppendingPathComponent(testFilename)

        // Test Create Directory
        createDirectoryAtPathWithConfirmation(testDirectoryPath)
        
        // Test Create File
        createFileAtPathWithConfirmation(testFilePath)
        
        // Test Move
        let testDirectoryPathTwo = testDirectoryPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(testDirectoryNameTwo)
        moveDirectoryAtPathWithConfirmation(testDirectoryPath, destinationPath: testDirectoryPathTwo)
        
        // Test Modify File
        let testFilePathTwo = testDirectoryPathTwo.stringByAppendingPathComponent(testFilename)
        modifyFileAtPathWithConfirmation(testFilePathTwo)
        
        // Test Move Again
        moveDirectoryAtPathWithConfirmation(testDirectoryPathTwo, destinationPath: testDirectoryPath)
        
        // Clean up

        // Test Remove File
        removeFileAtPathWithConfirmation(testFilePath)

        // Test Remove
        removeDirectoryAtPathWithConfirmation(testDirectoryPath)
    }

    func testReplaceDirectoryWithFile() {
        let testDirectoryPath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testDirectoryName)
            
        // Test Create Directory
        createDirectoryAtPathWithConfirmation(testDirectoryPath)

        // Remove Directory
        removeDirectoryAtPathWithConfirmation(testDirectoryPath)
        
        // Test Create File
        createFileAtPathWithConfirmation(testDirectoryPath)

        // Remove File
        removeFileAtPathWithConfirmation(testDirectoryPath)
    }

    func testReplaceFileWithDirectory() {
        let testDirectoryPath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testDirectoryName)
        
        // Test Create File
        createFileAtPathWithConfirmation(testDirectoryPath)
        
        // Remove File
        removeFileAtPathWithConfirmation(testDirectoryPath)
        
        // Test Create Directory
        createDirectoryAtPathWithConfirmation(testDirectoryPath)
        
        // Remove Directory
        removeDirectoryAtPathWithConfirmation(testDirectoryPath)
    }

}


class WCLDirectoryWatcherFileTests: WCLDirectoryWatcherTestCase {
    var testFilePath: NSString!
    
    override func setUp() {
        super.setUp()
        testFilePath = temporaryDirectoryURL.path!.stringByAppendingPathComponent(testFilename)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateWriteAndRemoveFile() {
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

    func testMoveFile() {
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
    
    func testFileManager() {
        // Test Create
        
        // Create expectation
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created at \(testFilePath)")
        directoryWatcherEventManager?.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  self.testFilePath) {
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
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ path -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  self.testFilePath) {
                fileWasRemovedExpectation.fulfill()
            }
        })
            
        // Test remove the second file with NSFileManager
        var error: NSError?
        let result = NSFileManager.defaultManager().removeItemAtPath(testFilePathTwo, error: &error)
        XCTAssertTrue(result, "The move should have succeeded")
        XCTAssertNil(error, "The error should be nil")
        
        // Remove file
        SubprocessFileSystemModifier.removeFileAtPath(testFilePath)
        
        // Wait for expectation
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

    }
    
    func testFileManagerAsync() {

        
        // Test Create

        // Create expectation
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
        directoryWatcherEventManager?.addFileWasCreatedOrModifiedAtPathHandler({ path -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.testFilePath) {
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
        directoryWatcherEventManager?.addItemWasRemovedAtPathHandler({ path -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) ==  self.testFilePath) {
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