//
//  DirectoryTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/27/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class DirectoryTests: XCTestCase {

    func testBuiltInPluginsPath() {
        XCTAssert(Directory.BuiltInPlugins.path() == NSBundle.mainBundle().builtInPlugInsPath!, "The paths should match")
    }
    
    func testApplicationSupport() {
        let applicationSupportDirectoryPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary![nameKey] as NSString
        let applicationSupportPath = applicationSupportDirectoryPath
            .stringByAppendingPathComponent(applicationName)
        XCTAssert(applicationSupportPath == Directory.ApplicationSupport.path(), "The paths should match")
    }
    
    func testApplicationSupportPluginsPath() {
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary![nameKey] as NSString
        let applicationSupportPluginsPath = applicationSupportPath
            .stringByAppendingPathComponent(applicationName)
            .stringByAppendingPathComponent(pluginsDirectoryPathComponent)
        XCTAssert(applicationSupportPluginsPath == Directory.ApplicationSupportPlugins.path(), "The paths should match")
    }

    func testCachesPath() {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary![nameKey] as NSString
        let cachesPath = cachesDirectory
            .stringByAppendingPathComponent(applicationName)
        XCTAssert(cachesPath == Directory.Caches.path(), "The paths should match")
    }
}