//
//  PluginManagerTests.swift
//  PluginManagerTests
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginDataControllerClassTests: XCTestCase {
    
    func testPluginPaths() {
        let pluginsPath = NSBundle.mainBundle().builtInPlugInsPath!
        let pluginPaths = PluginDataController.pathsForPluginsAtPath(pluginsPath)

        // Test plugin path counts
        if let testPluginPaths = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pluginsPath, error:nil) {
            XCTAssert(!testPluginPaths.isEmpty, "The test plugin paths count should be greater than zero")
            XCTAssert(testPluginPaths.count == pluginPaths.count, "The plugin paths count should equal the test plugin paths count")
        } else {
            XCTAssert(false, "The contents of the path should exist")
        }
        
        // Test plugins can be created from all paths
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.pluginWithPath(pluginPath) {
                plugins.append(plugin)
            } else {
                XCTAssert(false, "The plugin should exist")
            }
        }

        let testPluginsCount = PluginDataController.pluginsAtPluginPaths(pluginPaths).count
        XCTAssert(plugins.count == testPluginsCount, "The plugins count should equal the test plugins count")
    }
    
    func testBuiltInPluginsPath() {
        XCTAssert(PluginsDirectory.BuiltIn.path() == NSBundle.mainBundle().builtInPlugInsPath!, "The paths should match")
    }
    
    func testApplicationSupportPluginsPath() {
        let pluginsPathComponent = "PlugIns"
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary[nameKey] as NSString
        let applicationSupportPluginsPath = applicationSupportPath
            .stringByAppendingPathComponent(applicationName)
            .stringByAppendingPathComponent(pluginsPathComponent)
        XCTAssert(applicationSupportPluginsPath == PluginsDirectory.ApplicationSupport.path(), "The paths should match")
    }
}


class PluginDataControllerTests: XCTestCase {
    let pluginDataController = PluginDataController(testPluginPaths)
    struct Constants {
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }
    

    var temporaryDirectoryPath: String?

    class func isValidTemporaryDirectoryPath (path: String?) -> Bool {
        var isDir : ObjCBool = false
        if let path = path as String! {
            return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
        }
        return false
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

    func testExistingPlugins() {
        let plugins = pluginDataController.existingPlugins()
        
        let pluginPaths = PluginDataController.pathsForPluginsAtPaths(testPluginPaths)
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")
    }
    
    func testNewPluginFromPlugin() {
        let pluginManager = PluginManager(testPluginPaths)
        let plugin = pluginManager.pluginWithName(testPluginName)
        
        pluginDataController.newPluginFromPlugin(plugin!)
    }

}
