//
//  TemporaryDirectoryTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

class TemporaryDirectoryTestCase: XCTestCase {
    struct Constants {
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }
    var temporaryDirectoryPath: String?
    
    class func isValidTemporaryDirectoryPath (path: String?) -> Bool {
        var isDir: ObjCBool = false
        if let path = path as String! {
            return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
        }
        return false
    }
    
    class func safelyRemoveTemporaryDirectoryAtPath(path: String) -> Bool {
        if !path.hasPrefix(Constants.temporaryDirectoryPathPrefix) {
            return false
        }
        
        var error: NSError?
        let removed = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        if !removed || error != nil {
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
            if let bundleIdenetifier = NSBundle.mainBundle().bundleIdentifier as String? {
                if let className = self.className {
                    let path = temporaryDirectory
                        .stringByAppendingPathComponent(bundleIdenetifier)
                        .stringByAppendingPathComponent(className)
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        let success = self.dynamicType.safelyRemoveTemporaryDirectoryAtPath(path)
                        XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
                        XCTAssertTrue(false, "A temporary directory had to be cleaned up")
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
            }
        }
        
        XCTAssertTrue(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be valid")
    }
    
    override func tearDown() {
        super.tearDown()
        
        XCTAssertTrue(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be valid")
        
        if let path = temporaryDirectoryPath {
            var error: NSError?
            if let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error) {
                XCTAssert(contents.isEmpty, "The contents should be empty")
                XCTAssertNil(error, "The error should be nil")
            }
            
            let success = self.dynamicType.safelyRemoveTemporaryDirectoryAtPath(path)
            XCTAssertTrue(success, "Removing the temporary directory should have succeeded")
        }
        
        XCTAssertFalse(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be invalid")
        if let path = temporaryDirectoryPath {
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path), "A file should not exist at the path")
        }
        
    }
}