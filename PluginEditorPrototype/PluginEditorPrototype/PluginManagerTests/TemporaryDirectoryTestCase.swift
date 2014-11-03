//
//  TemporaryDirectoryTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

class TemporaryDirectoryTestCase: XCTestCase {
    struct ClassConstants {
        static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }
    var temporaryDirectoryPath: String?
    var temporaryDirectoryURL: NSURL? {
        get {
            if let temporaryDirectoryPath = temporaryDirectoryPath {
                return NSURL(fileURLWithPath:temporaryDirectoryPath)
            }
            return nil
        }
    }
    
    class func isValidTemporaryDirectoryPath (path: String?) -> Bool {
        var isDir: ObjCBool = false
        if let path = path as String! {
            return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
        }
        return false
    }
    
    func removeTemporaryItemWithName(name: String) -> Bool {
        if let temporaryDirectoryPath = temporaryDirectoryPath {
            let path = temporaryDirectoryPath.stringByAppendingPathComponent(name)
            return self.dynamicType.safelyRemoveTemporaryItemAtPath(path)
        }
        
        return false
    }
    
    private class func safelyRemoveTemporaryItemAtPath(path: String) -> Bool {
        if !path.hasPrefix(ClassConstants.temporaryDirectoryPathPrefix) {
            return false
        }
        
        var error: NSError?
        let removed = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        if !removed || error != nil {
            println("Warning: A temporary item failed to be removed at path \(path)")
            if (error != nil) {
                println("Error removing temporary item at path \(path) \(error)")
            }
            return false
        }
        
        return true
    }
    
    override func setUp() {
        super.setUp()
        
        XCTAssertFalse(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be invalid")
        if let temporaryDirectoryPath = temporaryDirectoryPath {
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(temporaryDirectoryPath), "A file should not exist at the temporary directory path")
        }
        
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
        
        if let path = temporaryDirectoryPath {
            var error: NSError?
            if let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error) {
                if !contents.isEmpty {
                    println("Warning: A temporary directory was not empty during tear down at path \(path)")
                }
                // This is an assert because it is evidence that a plugin isn't cleaning up after itself.
                // On next run the setup will clean it up, so the assert helps identify when a test isn't
                // cleaning up without hindering future runs.
                XCTAssert(contents.isEmpty, "The contents should be empty")
            }
            XCTAssertNil(error, "The error should be nil")
            
            let success = self.dynamicType.safelyRemoveTemporaryItemAtPath(path)
            XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
        }
        
        XCTAssertFalse(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be invalid")
        if let path = temporaryDirectoryPath {
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path), "A file should not exist at the path")
        }

        println("temporaryDirectoryPath = \(temporaryDirectoryPath)")
    }
}