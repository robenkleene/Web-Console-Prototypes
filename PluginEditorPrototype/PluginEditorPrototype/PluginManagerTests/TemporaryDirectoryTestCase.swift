//
//  TemporaryDirectoryTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

class TemporaryDirectoryTestCase: XCTestCase {
    var temporaryDirectoryPath: String!
    var temporaryDirectoryURL: NSURL! {
        get {
            return NSURL(fileURLWithPath:temporaryDirectoryPath)
        }
    }

    struct ClassConstants {
        static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }
    
    class func resolveTemporaryDirectoryPath(path: NSString) -> NSString {
        // Remove the "/private" path component because FSEvents returns paths iwth this prefix
        let testPathPrefix = "/private".stringByAppendingPathComponent(ClassConstants.temporaryDirectoryPathPrefix)
        let pathPrefixRange = path.rangeOfString(testPathPrefix);
        if (pathPrefixRange.location == 0) {
            return path.stringByReplacingCharactersInRange(pathPrefixRange, withString: ClassConstants.temporaryDirectoryPathPrefix)
        }
        
        return path
    }
    
    class func isValidTemporaryDirectoryPath(path: NSString) -> Bool {
        var isDir: ObjCBool = false

        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
    }
    
    func removeTemporaryItemAtPathComponent(pathComponent: NSString) -> Bool {
        let path = temporaryDirectoryPath.stringByAppendingPathComponent(pathComponent)
        return self.dynamicType.safelyRemoveTemporaryItemAtPath(path)
    }

    func removeTemporaryItemAtURL(URL: NSURL) -> Bool {
        if let path = URL.path {
            return removeTemporaryItemAtPath(path)
        }
        return false
    }
    
    func removeTemporaryItemAtPath(path: NSString) -> Bool {
        if !path.hasPrefix(temporaryDirectoryPath) {
            XCTAssert(false, "Attempted to delete a temporary item that is not in the temporary directory.")
            return false
        }
        return self.dynamicType.safelyRemoveTemporaryItemAtPath(path)
    }
    
    private class func safelyRemoveTemporaryItemAtPath(path: String) -> Bool {
        if !path.hasPrefix(ClassConstants.temporaryDirectoryPathPrefix) {
            XCTAssert(false, "Attempted to delete a temporary item at a path that does not have the temporary directory path prefix.")
            return false
        }
        
        var error: NSError?
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        XCTAssertTrue(success, "Removing the temporary item should succeed.")
        return success
    }
    
    override func setUp() {
        super.setUp()

        if let temporaryDirectory = NSTemporaryDirectory() as String? {
            let path = temporaryDirectory
                .stringByAppendingPathComponent(ClassConstants.bundleIdentifier)
                .stringByAppendingPathComponent(className)
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                let success = self.dynamicType.safelyRemoveTemporaryItemAtPath(path)
                XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
                // This is not an assert in order to make it easier to fix tests that aren't cleaning up after themselves.
                println("Warning: A temporary directory had to be cleaned up at path \(path)")
            }
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path), "A file should not exist at the path")
            var error: NSError?
            NSFileManager
                .defaultManager()
                .createDirectoryAtPath(path,
                    withIntermediateDirectories: true,
                    attributes: nil,
                    error: &error)
            XCTAssertNil(error, "The error should be nil")
            temporaryDirectoryPath = path
        }

        XCTAssertTrue(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be valid")
    }
    
    override func tearDown() {
        super.tearDown()
        
        XCTAssertTrue(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be valid")
        
        // Confirm the contents of the temporary directory is empty
        var error: NSError?
        if let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(temporaryDirectoryPath, error:&error) {
            if !contents.isEmpty {
                println("Warning: A temporary directory was not empty during tear down at path \(temporaryDirectoryPath)")
            }
            // This is an assert because it is evidence that a plugin isn't cleaning up after itself.
            // On next run the setup will clean it up, so the assert helps identify when a test isn't
            // cleaning up without hindering future runs.
            XCTAssert(contents.isEmpty, "The contents should be empty")
        }
        XCTAssertNil(error, "The error should be nil")

        // Remove the temporary directory
        let success = self.dynamicType.safelyRemoveTemporaryItemAtPath(temporaryDirectoryPath)
        XCTAssertTrue(success, "Removing the temporary directory should have succeeded")

        // Confirm the temporary directory is removed
        XCTAssertFalse(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be invalid")
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(temporaryDirectoryPath), "A file should not exist at the path")
        temporaryDirectoryPath = nil
    }
}
