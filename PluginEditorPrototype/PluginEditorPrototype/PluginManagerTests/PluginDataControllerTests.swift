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
    let temporaryDirectoryPathPrefix = "/var/folders"
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
                    // Do a manual clean up here
                    
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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        XCTAssertTrue(self.dynamicType.isValidTemporaryDirectoryPath(temporaryDirectoryPath), "The temporary directory path should be valid")

        if let path = temporaryDirectoryPath {
            var error: NSError?
            if let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error:&error) {
                XCTAssert(contents.isEmpty, "The contents should be empty")
                XCTAssertNil(error, "The error should be nil")
            }
            XCTAssertTrue(path.hasPrefix(temporaryDirectoryPathPrefix), "The path should have the temporary directory path prefix")
            
            let removed = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
            XCTAssertTrue(removed, "Removed should be true")
            XCTAssertNil(error, "The eror should be nil")
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
